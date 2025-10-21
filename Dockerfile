FROM quay.io/keycloak/keycloak:26.4.0

ENV PLAYA_THEMES_VERSION=1.0.26
ENV RUSSIAN_PROVIDER_VERSION=26.4.0.rsp
ENV BANKS_PROVIDER_VERSION=26.4.0
ENV KAFKA_PROVIDER_VERSION=26.4.0

ENV MAVEN_CENTRAL_URL=https://repo1.maven.org/maven2

ARG RUSSIAN_PROVIDER_DIST=$MAVEN_CENTRAL_URL/ru/playa/keycloak/keycloak-russian-providers/$RUSSIAN_PROVIDER_VERSION/keycloak-russian-providers-$RUSSIAN_PROVIDER_VERSION.jar
ARG BANKS_PROVIDER_DIST=$MAVEN_CENTRAL_URL/ru/playa/keycloak/keycloak-banks-providers/$BANKS_PROVIDER_VERSION/keycloak-banks-providers-$BANKS_PROVIDER_VERSION.jar
ARG KAFKA_PROVIDER_DIST=$MAVEN_CENTRAL_URL/ru/playa/keycloak/keycloak-kafka-provider/$KAFKA_PROVIDER_VERSION/keycloak-kafka-provider-$KAFKA_PROVIDER_VERSION.jar
ARG PLAYA_THEMES_DIST=$MAVEN_CENTRAL_URL/ru/playa/keycloak/keycloak-playa-themes/$PLAYA_THEMES_VERSION/keycloak-playa-themes-$PLAYA_THEMES_VERSION.jar

ARG PROVIDER_DIR=/opt/keycloak/providers

ADD $BANKS_PROVIDER_DIST $PROVIDER_DIR
ADD $RUSSIAN_PROVIDER_DIST $PROVIDER_DIR
ADD $PLAYA_THEMES_DIST $PROVIDER_DIR
ADD $KAFKA_PROVIDER_DIST $PROVIDER_DIR

USER root
RUN chown -R 1000:1000 /opt/keycloak/providers && \
    chmod -R g+rwX /opt/keycloak/providers
USER 1000

EXPOSE 8080
EXPOSE 8443

ENTRYPOINT [ "/opt/keycloak/bin/kc.sh" ]