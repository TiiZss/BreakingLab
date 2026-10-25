# Arranque público

`startpublic` y la opción 3 del menú tienen que dejar una máquina en la red del aula. Hoy el compose no arranca, y los `docker run` que sí arrancan publican en `127.x.0.1`. Otro ordenador no llega.

## Cambio

- `BREAKINGLAB_BIND` vale `0.0.0.0` o la IP que escriba el profesor. Si no está, el arranque privado sigue en su `127.x`.
- El compose renderizado cambia solo `host_ip`. El `127.0.0.1` de dentro del contenedor, el del healthcheck, se queda.
- Los ganchos que hacen `docker run` usan esa variable en el `-p`.
- Antes de publicar se quita el contenedor anterior, porque un `docker start` conservaría el `127.x`.
- Al terminar se imprimen las IPv4 de la red, no `http://0.0.0.0`. El puerto de entrada lo tiene que permitir el cortafuegos de Windows.

## Una sola máquina en público

En el menú, la opción 3 lista todas las máquinas. No pide IP ni puerto: publica en `0.0.0.0` con el puerto de esa máquina. `startpublic` en la línea de comandos sigue aceptando IP y puerto.

Comparten la IP del ordenador, así que solo puede haber una en marcha. Si el menú marca otra como ON, avisa y pregunta si la apaga. Si la respuesta no es sí, la nueva no arranca. La misma máquina se vuelve a publicar sin esa pregunta.
