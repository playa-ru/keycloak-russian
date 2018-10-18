FROM jboss/keycloak:4.5.0.Final

ENV JBOSS_HOME /opt/jboss/keycloak
ENV THEMES_HOME $JBOSS_HOME/themes
ENV THEMES_VERSION 1.0.7
ENV PROVIDERS_VERSION 1.0.1
ENV THEMES_TMP /tmp/keycloak-themes
ENV PROVIDERS_TMP /tmp/keycloak-providers
ENV NEXUS_URL https://nexus.playa.ru/nexus/content/repositories/releases

RUN mkdir -p $PROVIDERS_TMP
RUN mkdir -p $THEMES_TMP
ADD $NEXUS_URL/ru/playa/keycloak/keycloak-russian-providers/$PROVIDERS_VERSION/keycloak-russian-providers-$PROVIDERS_VERSION.jar $PROVIDERS_TMP
ADD $NEXUS_URL/ru/playa/keycloak/keycloak-playa-themes/$THEMES_VERSION/keycloak-playa-themes-$THEMES_VERSION.jar $THEMES_TMP

USER root

RUN unzip $PROVIDERS_TMP/keycloak-russian-providers-$PROVIDERS_VERSION.jar -d $PROVIDERS_TMP
RUN cat $PROVIDERS_TMP/theme/base/admin/messages/admin-messages_en.custom >> $THEMES_HOME/base/admin/messages/admin-messages_en.properties
RUN cat $PROVIDERS_TMP/theme/base/admin/messages/admin-messages_ru.custom >> $THEMES_HOME/base/admin/messages/admin-messages_ru.properties
RUN cat $PROVIDERS_TMP/theme/base/admin/resources/partials/* >> $THEMES_HOME/base/admin/resources/partials

RUN unzip $THEMES_TMP/keycloak-playa-themes-$THEMES_VERSION.jar -d $THEMES_TMP
RUN mv $THEMES_TMP/theme/* $THEMES_HOME

RUN ls -l $THEMES_HOME

RUN chmod -R a+r $JBOSS_HOME

RUN cp $PROVIDERS_TMP/keycloak-russian-providers-$PROVIDERS_VERSION.jar $JBOSS_HOME/standalone/deployments

RUN rm -rf $PROVIDERS_TMP
RUN rm -rf $THEMES_TMP

USER jboss

