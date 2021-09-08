FROM jboss/keycloak:15.0.2

ENV JBOSS_HOME /opt/jboss/keycloak
ENV THEMES_HOME $JBOSS_HOME/themes
ENV THEMES_VERSION 1.0.22
ENV PROVIDERS_VERSION 1.0.38
ENV THEMES_TMP /tmp/keycloak-themes
ENV PROVIDERS_TMP /tmp/keycloak-providers
ENV MAVEN_CENTRAL_URL https://repo1.maven.org/maven2
ENV NEXUS_URL https://nexus.playa.ru/nexus/content/repositories/releases

RUN mkdir -p $PROVIDERS_TMP
RUN mkdir -p $THEMES_TMP
ADD $MAVEN_CENTRAL_URL/ru/playa/keycloak/keycloak-russian-providers/$PROVIDERS_VERSION/keycloak-russian-providers-$PROVIDERS_VERSION.jar $PROVIDERS_TMP
ADD $NEXUS_URL/ru/playa/keycloak/keycloak-playa-themes/$THEMES_VERSION/keycloak-playa-themes-$THEMES_VERSION.jar $THEMES_TMP

USER root

RUN microdnf install -y unzip

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
