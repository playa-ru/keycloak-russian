FROM bellsoft/liberica-openjdk-centos:17 AS ubi-micro-install

ARG PLAYA_RU_GITHUB_TOKEN
ENV PLAYA_RU_GITHUB_TOKEN ${PLAYA_RU_GITHUB_TOKEN}

RUN echo $PLAYA_RU_GITHUB_TOKEN

ARG TMP_DIST=/tmp/keycloak

ENV KEYCLOAK_VERSION 24.0.1
ENV PLAYA_THEMES_VERSION 1.0.22
ENV RUSSIAN_PROVIDER_VERSION 24.0.1.rsp
ENV KAFKA_PROVIDER_VERSION 24.0.1

ENV MAVEN_CENTRAL_URL https://repo1.maven.org/maven2
ENV NEXUS_URL https://nexus.playa.ru/nexus/content/repositories/releases

ARG KEYCLOAK_DIST=https://github.com/keycloak/keycloak/releases/download/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz
ARG RUSSIAN_PROVIDER_DIST=$MAVEN_CENTRAL_URL/ru/playa/keycloak/keycloak-russian-providers/$RUSSIAN_PROVIDER_VERSION/keycloak-russian-providers-$RUSSIAN_PROVIDER_VERSION.jar
ARG KAFKA_PROVIDER_DIST=$MAVEN_CENTRAL_URL/ru/playa/keycloak/keycloak-kafka-provider/$KAFKA_PROVIDER_VERSION/keycloak-kafka-provider-$KAFKA_PROVIDER_VERSION.jar
ARG PLAYA_THEMES_DIST=$NEXUS_URL/ru/playa/keycloak/keycloak-playa-themes/$PLAYA_THEMES_VERSION/keycloak-playa-themes-$PLAYA_THEMES_VERSION.jar

RUN yum install -y curl tar gzip unzip

ADD $KEYCLOAK_DIST $TMP_DIST/
ADD $RUSSIAN_PROVIDER_DIST $TMP_DIST/
ADD $PLAYA_THEMES_DIST $TMP_DIST/
ADD $KAFKA_PROVIDER_DIST $TMP_DIST/

RUN cd /tmp/keycloak && tar -xvf /tmp/keycloak/keycloak-*.tar.gz && rm /tmp/keycloak/keycloak-*.tar.gz

RUN mkdir -p $TMP_DIST/themes-base && \
    unzip $TMP_DIST/keycloak-$KEYCLOAK_VERSION/lib/lib/main/org.keycloak.keycloak-themes-$KEYCLOAK_VERSION.jar -d $TMP_DIST/themes-base && \
    mv $TMP_DIST/themes-base/theme/* $TMP_DIST/keycloak-$KEYCLOAK_VERSION/themes

RUN mkdir -p $TMP_DIST/themes-playa && \
    unzip $TMP_DIST/keycloak-playa-themes-$PLAYA_THEMES_VERSION.jar -d $TMP_DIST/themes-playa && \
    mv $TMP_DIST/themes-playa/theme/* $TMP_DIST/keycloak-$KEYCLOAK_VERSION/themes

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
