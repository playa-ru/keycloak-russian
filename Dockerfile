FROM bellsoft/liberica-openjdk-centos:17 AS ubi-micro-install

ARG TMP_DIST=/tmp/keycloak

ENV KEYCLOAK_VERSION 21.1.1
ENV KEYCLOAK_ADMIN_THEME_VERSION 21.1.1.rsp-12
ENV PLAYA_THEMES_VERSION 1.0.22
ENV RUSSIAN_PROVIDER_VERSION 1.0.49
ENV KAFKA_PROVIDER_VERSION 1.0.8

ENV MAVEN_CENTRAL_URL https://repo1.maven.org/maven2
ENV NEXUS_URL https://nexus.playa.ru/nexus/content/repositories/releases

ARG KEYCLOAK_DIST=https://github.com/keycloak/keycloak/releases/download/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz
ARG KEYCLOAK_ADMIN_UI_DIST=https://maven.pkg.github.com/playa-ru/keycloak-ui/org/keycloak/keycloak-admin-ui/$KEYCLOAK_ADMIN_THEME_VERSION/keycloak-admin-ui-$KEYCLOAK_ADMIN_THEME_VERSION.jar
ARG RUSSIAN_PROVIDER_DIST=$MAVEN_CENTRAL_URL/ru/playa/keycloak/keycloak-russian-providers/$RUSSIAN_PROVIDER_VERSION/keycloak-russian-providers-$RUSSIAN_PROVIDER_VERSION.jar
ARG KAFKA_PROVIDER_DIST=$MAVEN_CENTRAL_URL/ru/playa/keycloak/keycloak-kafka-provider/$KAFKA_PROVIDER_VERSION/keycloak-kafka-provider-$KAFKA_PROVIDER_VERSION.jar
ARG PLAYA_THEMES_DIST=$NEXUS_URL/ru/playa/keycloak/keycloak-playa-themes/$PLAYA_THEMES_VERSION/keycloak-playa-themes-$PLAYA_THEMES_VERSION.jar

RUN yum install -y curl tar gzip unzip

RUN curl -X GET --location "https://maven.pkg.github.com/playa-ru/keycloak-ui/org/keycloak/keycloak-admin-ui/$KEYCLOAK_ADMIN_THEME_VERSION/keycloak-admin-ui-$KEYCLOAK_ADMIN_THEME_VERSION.jar" -H "Authorization: Bearer $GITHUB_TOKEN" -o $PROVIDERS_TMP/keycloak-admin-ui-$KEYCLOAK_ADMIN_THEME_VERSION.jar

ADD $KEYCLOAK_DIST $TMP_DIST/
ADD $RUSSIAN_PROVIDER_DIST $TMP_DIST/
ADD $PLAYA_THEMES_DIST $TMP_DIST/
ADD $KAFKA_PROVIDER_DIST $TMP_DIST/
ADD /esia-jcp/* $TMP_DIST/esia-jcp/

RUN cd /tmp/keycloak && tar -xvf /tmp/keycloak/keycloak-*.tar.gz && rm /tmp/keycloak/keycloak-*.tar.gz

RUN mkdir -p $TMP_DIST/themes-base && \
    unzip $TMP_DIST/keycloak-$KEYCLOAK_VERSION/lib/lib/main/org.keycloak.keycloak-themes-$KEYCLOAK_VERSION.jar -d $TMP_DIST/themes-base && \
    mv $TMP_DIST/themes-base/theme/* $TMP_DIST/keycloak-$KEYCLOAK_VERSION/themes

RUN mkdir -p $TMP_DIST/themes-playa && \
    unzip $TMP_DIST/keycloak-playa-themes-$PLAYA_THEMES_VERSION.jar -d $TMP_DIST/themes-playa && \
    mv $TMP_DIST/themes-playa/theme/* $TMP_DIST/keycloak-$KEYCLOAK_VERSION/themes

RUN mv $TMP_DIST/esia-jcp/* $TMP_DIST/keycloak-$KEYCLOAK_VERSION/providers
RUN mv $TMP_DIST/keycloak-admin-ui-$KEYCLOAK_ADMIN_THEME_VERSION.jar $TMP_DIST/keycloak-$KEYCLOAK_VERSION/lib/lib/main/org.keycloak.keycloak-admin-ui-$KEYCLOAK_VERSION.jar
RUN mv $TMP_DIST/keycloak-russian-providers-$RUSSIAN_PROVIDER_VERSION.jar $TMP_DIST/keycloak-$KEYCLOAK_VERSION/providers/keycloak-russian-providers-$RUSSIAN_PROVIDER_VERSION.jar
RUN mv $TMP_DIST/keycloak-kafka-provider-$KAFKA_PROVIDER_VERSION.jar $TMP_DIST/keycloak-$KEYCLOAK_VERSION/providers/keycloak-kafka-provider-$KAFKA_PROVIDER_VERSION.jar

RUN mkdir -p /opt/keycloak && mv /tmp/keycloak/keycloak-$KEYCLOAK_VERSION/* /opt/keycloak && mkdir -p /opt/keycloak/data

RUN chmod -R g+rwX /opt/keycloak

FROM bellsoft/liberica-openjdk-centos:17 AS ubi-micro-chown
ENV LANG en_US.UTF-8

COPY --from=ubi-micro-install --chown=1000:0 /opt/keycloak /opt/keycloak

RUN echo "keycloak:x:0:root" >> /etc/group && \
    echo "keycloak:x:1000:0:keycloak user:/opt/keycloak:/sbin/nologin" >> /etc/passwd

USER 1000

EXPOSE 8080
EXPOSE 8443

ENTRYPOINT [ "/opt/keycloak/bin/kc.sh" ]
