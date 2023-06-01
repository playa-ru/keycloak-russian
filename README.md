# keycloak-russian

Docker build for Keycloak server with russian identity providers and two additional login themes included.

See also:

https://github.com/playa-ru/keycloak-russian-providers

https://github.com/playa-ru/keycloak-playa-themes

Get it from [Docker Hub](https://hub.docker.com/r/playaru/keycloak-russian/): 
```
docker pull playaru/keycloak-russian
```

Сборка Keycloak версии 18.0.2 и выше осуществляется комадной:

```
docker build --build-arg PLAYA_RU_GITHUB_TOKEN=XXX . -t keycloak:postres_18.0.2
```
В переменную `PLAYA_RU_GITHUB_TOKEN` пишется токен к GitHub (у токена должны быть выданы права чтение репозитория)

