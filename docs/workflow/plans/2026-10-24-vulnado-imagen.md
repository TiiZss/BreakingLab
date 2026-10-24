# Vulnado desde bbhunter

El origen es https://github.com/bbhunter/vulnado, commit `53336e14` (2020-06-02). El `pom` dice `0.0.1-SNAPSHOT`. En el Hub de tiizss no había imagen.

La aplicación son cuatro servicios. Se publican tres imágenes y Postgres ya existente:

- `tiizss/vulnado-0.0.1:0.0.1` — API Java. El arranque oficial lanza Maven; la imagen publicada lleva el jar, `cowsay` y `netcat`.
- `tiizss/vulnado-client-0.0.1:0.0.1` — el cliente nginx. El JavaScript llama a `127.23.0.1:8080`, la IP de esta máquina.
- `tiizss/vulnado-internal-0.0.1:0.0.1` — el sitio interno, sin puerto publicado.
- `tiizss/postgres-15.4-alpine:15.4-alpine`

En el lanzador: `127.23.0.1:1337` el cliente y `127.23.0.1:8080` la API. El gancho ya no clona ni construye. Los contenedores salen con prefijo `vulnado_`.
