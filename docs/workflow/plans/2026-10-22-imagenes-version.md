# Imágenes base con la versión en el nombre

Cada versión de MySQL, PHP, Postgres y Mongo es un repositorio distinto en `tiizss`. El tag repite esa versión.

- `tiizss/mysql-5.5:5.5`
- `tiizss/mysql-5.7:5.7`
- `tiizss/mysql-8:8`
- `tiizss/php-8.1.28-apache-bullseye:8.1.28-apache-bullseye`
- `tiizss/postgres-15.4-alpine:15.4-alpine`
- `tiizss/mongo-3.4.1:3.4.1`
- `tiizss/mongo-4.0.4:4.0.4`

Los compose, los `.conf` y el gancho de SSRF-LAB pasan a esos nombres. Las imágenes de aplicación (`bricks`, `bwapp`, `juice-shop`, etc.) no cambian.

## El lanzador traduce el nombre

`bl_pin_image` en `lib/stack.sh` convierte el nombre de origen al de `tiizss` antes de `docker run` y al renderizar un compose. Un clon que vuelva a traer `mysql:5.7` o `cspf/jvl` arranca igual con la copia de `tiizss`. WebGoat 8, WebGoat 8.1, GraphQL y Vulnado se quedan con su nombre: no hay copia en el Hub.

Security Ninjas sale de la imagen oficial de 2015-05-01. El manifiesto schema1 se convierte en local y, si la página responde, se publica como `tiizss/security-ninjas:2015.05.01`. El `.conf` y `bl_pin_image` usan ese nombre.

GraphQL deja `carvesystems/vulnerable-graphql-api`. La máquina es DVGA `dolevf/dvga`, versión que trae la imagen (`version.py`). Si `http://127.0.0.1:5013/` responde, se publica `tiizss/dvga:<versión>`. El gancho arranca con `WEB_HOST=0.0.0.0` y publica `127.15.0.1:5013`.

DVWS-node se construye desde `snoopysecurity/dvws-node` commit `8e2e9a52` (2026-10-21). Si la web responde, la imagen es `tiizss/dvws-node:2026.10.21`. MySQL 8 y Mongo 4.0.4 siguen en sus repositorios con versión. El compose del laboratorio ya no construye el árbol local.

WebGoat 8.1 usa los jar de la release `v8.1.0`. `webgoat/webgoat:v8.1.0` no está en el Hub. Si `/WebGoat` y `/WebWolf` responden, se publica `tiizss/webgoat-8.1.0:v8.1.0` en `127.17.0.1`, puertos 8080 y 9090.

WebGoat 8.2 usa los jar de la release `v8.2.2`. `owasp/webgoat:v8.2.2` no está en el Hub. La imagen corre en Java 17 porque el JDK 16 del Dockerfile ya no existe. Si `/WebGoat` y `/WebWolf` responden, se publica `tiizss/webgoat-8.2.2:v8.2.2`. En el lanzador la máquina es `webgoat82`, en `127.7.0.1`, puertos 8080 y 9090.

WebGoat 8.0 sale de la etiqueta git `v8.0.0`. El repositorio `webgoat/webgoat-8.0` ya no existe y el `pom` de esa etiqueta sigue en `v8.0.0.M15`. Los jar se construyen con Maven y Java 8. WebGoat escucha en el 8080 y WebWolf, en esta versión, se publica en el 9090. Si `/WebGoat` y `/WebWolf` responden, se publica `tiizss/webgoat-8.0.0:v8.0.0`. En el lanzador la máquina es `webgoat80`, en `127.4.0.1`, puertos 8080 y 9090. `webgoat/webgoat-8.0` deja de apuntar a la imagen 8.2.2.
