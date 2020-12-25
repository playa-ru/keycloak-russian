FROM registry.access.redhat.com/ubi8-minimal

ENV KEYCLOAK_VERSION 12.0.0
ENV JDBC_POSTGRES_VERSION 42.2.5
ENV JDBC_MYSQL_VERSION 8.0.22
ENV JDBC_MARIADB_VERSION 2.5.4
ENV JDBC_MSSQL_VERSION 8.2.2.jre11

ENV LAUNCH_JBOSS_IN_BACKGROUND 1
ENV PROXY_ADDRESS_FORWARDING false
ENV JBOSS_HOME /opt/jboss/keycloak
ENV LANG en_US.UTF-8

ENV THEMES_HOME $JBOSS_HOME/themes
ENV THEMES_VERSION 1.0.22
ENV PROVIDERS_VERSION 1.0.27
ENV THEMES_TMP /tmp/keycloak-themes
ENV PROVIDERS_TMP /tmp/keycloak-providers
ENV NEXUS_URL https://nexus.playa.ru/nexus/content/repositories/releases

ARG GIT_REPO
ARG GIT_BRANCH
ARG KEYCLOAK_DIST=https://github.com/keycloak/keycloak/releases/download/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz

USER root

RUN microdnf update -y && microdnf install -y glibc-langpack-en gzip unzip hostname java-11-openjdk-headless openssl tar which && microdnf clean all

ADD tools /opt/jboss/tools

RUN chmod +x /opt/jboss/tools/*.sh && chmod +x /opt/jboss/tools/databases/change-database.sh

RUN ls -al /opt/jboss/tools

RUN /opt/jboss/tools/build-keycloak.sh

RUN mkdir -p $PROVIDERS_TMP
RUN mkdir -p $THEMES_TMP
ADD $NEXUS_URL/ru/playa/keycloak/keycloak-russian-providers/$PROVIDERS_VERSION/keycloak-russian-providers-$PROVIDERS_VERSION.jar $PROVIDERS_TMP
ADD $NEXUS_URL/ru/playa/keycloak/keycloak-playa-themes/$THEMES_VERSION/keycloak-playa-themes-$THEMES_VERSION.jar $THEMES_TMP

RUN unzip $PROVIDERS_TMP/keycloak-russian-providers-$PROVIDERS_VERSION.jar -d $PROVIDERS_TMP
RUN cat $PROVIDERS_TMP/theme/base/login/messages/messages_en.custom >> $THEMES_HOME/base/login/messages/messages_en.properties
RUN cat $PROVIDERS_TMP/theme/base/login/messages/messages_ru.custom >> $THEMES_HOME/base/login/messages/messages_ru.properties
RUN cat $PROVIDERS_TMP/theme/base/admin/messages/admin-messages_en.custom >> $THEMES_HOME/base/admin/messages/admin-messages_en.properties
RUN cat $PROVIDERS_TMP/theme/base/admin/messages/admin-messages_ru.custom >> $THEMES_HOME/base/admin/messages/admin-messages_ru.properties
RUN cat $PROVIDERS_TMP/theme/base/admin/resources/partials/realm-identity-provider-mailru.html >> $THEMES_HOME/base/admin/resources/partials/realm-identity-provider-mailru.html
RUN cat $PROVIDERS_TMP/theme/base/admin/resources/partials/realm-identity-provider-mailru-ext.html >> $THEMES_HOME/base/admin/resources/partials/realm-identity-provider-mailru-ext.html
RUN cat $PROVIDERS_TMP/theme/base/admin/resources/partials/realm-identity-provider-ok.html >> $THEMES_HOME/base/admin/resources/partials/realm-identity-provider-ok.html
RUN cat $PROVIDERS_TMP/theme/base/admin/resources/partials/realm-identity-provider-ok-ext.html >> $THEMES_HOME/base/admin/resources/partials/realm-identity-provider-ok-ext.html
RUN cat $PROVIDERS_TMP/theme/base/admin/resources/partials/realm-identity-provider-yandex.html >> $THEMES_HOME/base/admin/resources/partials/realm-identity-provider-yandex.html
RUN cat $PROVIDERS_TMP/theme/base/admin/resources/partials/realm-identity-provider-yandex-ext.html >> $THEMES_HOME/base/admin/resources/partials/realm-identity-provider-yandex-ext.html
RUN cat $PROVIDERS_TMP/theme/base/admin/resources/partials/realm-identity-provider-vk.html >> $THEMES_HOME/base/admin/resources/partials/realm-identity-provider-vk.html
RUN cat $PROVIDERS_TMP/theme/base/admin/resources/partials/realm-identity-provider-vk-ext.html >> $THEMES_HOME/base/admin/resources/partials/realm-identity-provider-vk-ext.html

RUN unzip $THEMES_TMP/keycloak-playa-themes-$THEMES_VERSION.jar -d $THEMES_TMP
RUN mv $THEMES_TMP/theme/* $THEMES_HOME

RUN cp $PROVIDERS_TMP/keycloak-russian-providers-$PROVIDERS_VERSION.jar $JBOSS_HOME/standalone/deployments

RUN ls -l $THEMES_HOME

RUN chmod -R a+r $JBOSS_HOME

RUN rm -rf $PROVIDERS_TMP
RUN rm -rf $THEMES_TMP

USER 1000

EXPOSE 8080
EXPOSE 8443

ENTRYPOINT [ "/opt/jboss/tools/docker-entrypoint.sh" ]

CMD ["-b", "0.0.0.0"]
