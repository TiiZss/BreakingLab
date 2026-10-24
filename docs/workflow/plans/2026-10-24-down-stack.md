# Apagar el stack

La opción 11 recorre cada laboratorio y llama a `stop`. Todos los contenedores del lanzador llevan `com.docker.compose.project=breakinglab`.

`docker compose down` de un fichero renderizado solo conoce los servicios de ese fichero. Los laboratorios arrancados con `docker run` llevan la etiqueta y Compose no los posee.

`down_all` para y borra los contenedores con esa etiqueta, y borra las redes del mismo proyecto. No toca volúmenes ni contenedores de otros stacks.
