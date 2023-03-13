FROM registry.access.redhat.com/ubi9 AS ubi-micro-build
RUN mkdir -p /mnt/rootfs
RUN dnf install --installroot /mnt/rootfs unzip --releasever 9 --setopt install_weak_deps=false --nodocs -y; dnf --installroot /mnt/rootfs clean all

FROM quay.io/keycloak/keycloak:21.0.1 as builder
COPY --from=ubi-micro-build /mnt/rootfs /

ARG db

ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_FEATURES=token-exchange
ENV KC_DB=$db
ENV KC_HTTP_RELATIVE_PATH=/auth

ENV KEYCLOAK_VERSION 21.0.1
ENV THEMES_VERSION 1.0.22
ENV PROVIDERS_VERSION 1.0.46
ENV KEYCLOAK_ADMIN_THEME 1.0.7

ENV MAVEN_CENTRAL_URL https://repo1.maven.org/maven2
ENV NEXUS_URL https://nexus.playa.ru/nexus/content/repositories/releases

ENV JBOSS_HOME /opt/keycloak
ENV THEMES_HOME $JBOSS_HOME/themes
ENV THEMES_PLAYA_TMP /tmp/keycloak-themes
ENV THEMES_BASE_TMP /tmp/keycloak-base-themes
ENV PROVIDERS_TMP /tmp/keycloak-providers

RUN mkdir -p $PROVIDERS_TMP
RUN mkdir -p $THEMES_PLAYA_TMP
RUN mkdir -p $THEMES_BASE_TMP

ADD $MAVEN_CENTRAL_URL/ru/playa/keycloak/keycloak-russian-providers/$PROVIDERS_VERSION/keycloak-russian-providers-$PROVIDERS_VERSION.jar $PROVIDERS_TMP
ADD $NEXUS_URL/ru/playa/keycloak/keycloak-playa-themes/$THEMES_VERSION/keycloak-playa-themes-$THEMES_VERSION.jar $THEMES_PLAYA_TMP
ADD $NEXUS_URL/org/keycloak/keycloak-admin-ui/$KEYCLOAK_ADMIN_THEME/keycloak-admin-ui-$KEYCLOAK_ADMIN_THEME.jar $PROVIDERS_TMP

USER root

RUN echo "DataBase is $db"

RUN unzip /opt/keycloak/lib/lib/main/org.keycloak.keycloak-themes-$KEYCLOAK_VERSION.jar -d $THEMES_BASE_TMP
RUN mv $THEMES_BASE_TMP/theme/* $THEMES_HOME

RUN unzip $THEMES_PLAYA_TMP/keycloak-playa-themes-$THEMES_VERSION.jar -d $THEMES_PLAYA_TMP
RUN mv $THEMES_PLAYA_TMP/theme/* $THEMES_HOME

RUN ls -al $PROVIDERS_TMP

RUN cp $PROVIDERS_TMP/keycloak-admin-ui-$KEYCLOAK_ADMIN_THEME.jar $JBOSS_HOME/lib/lib/main/org.keycloak.keycloak-admin-ui-$KEYCLOAK_VERSION.jar

RUN cp $PROVIDERS_TMP/keycloak-russian-providers-$PROVIDERS_VERSION.jar $JBOSS_HOME/providers
RUN unzip $PROVIDERS_TMP/keycloak-russian-providers-$PROVIDERS_VERSION.jar -d $PROVIDERS_TMP
RUN cat $PROVIDERS_TMP/theme/base/login/messages/messages_en.custom >> $THEMES_HOME/base/login/messages/messages_en.properties
RUN cat $PROVIDERS_TMP/theme/base/login/messages/messages_ru.custom >> $THEMES_HOME/base/login/messages/messages_ru.properties
RUN cat $PROVIDERS_TMP/theme/base/admin/messages/admin-messages_en.custom >> $THEMES_HOME/base/admin/messages/admin-messages_en.properties
RUN cat $PROVIDERS_TMP/theme/base/admin/messages/admin-messages_ru.custom >> $THEMES_HOME/base/admin/messages/admin-messages_ru.properties

RUN chmod -R a+r $JBOSS_HOME

RUN rm -rf $PROVIDERS_TMP
RUN rm -rf $THEMES_PLAYA_TMP
RUN rm -rf $THEMES_BASE_TMP

USER 1000

RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:21.0.1
COPY --from=builder /opt/keycloak/ /opt/keycloak/
WORKDIR /opt/keycloak

# for demonstration purposes only, please make sure to use proper certificates in production instead
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
# change these values to point to a running postgres instance

ENV KC_DB_URL=<DBURL>
ENV KC_DB_USERNAME=<DBUSERNAME>
ENV KC_DB_PASSWORD=<DBPASSWORD>
ENV KC_HTTP_ENABLED=<HTTPENABLED>
ENV KC_HOSTNAME_STRICT=<HOSTNAMESTRICT>

ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start"]
