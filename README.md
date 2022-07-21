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
docker build --build-arg db=postgres . -t keycloak:postres_18.0.2
```
В переменную db пишется название драйвера БД. Возможные значения:
* h2 - H2
* postgres - Postgres
* mysql - MySql
* mariadb - MariaDB
* oracle - Oracle
* mssql - Microsoft SQL Server
