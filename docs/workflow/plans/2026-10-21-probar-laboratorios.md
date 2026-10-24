# Plan: probar el arranque de los laboratorios

Fecha: 2026-10-21.

Hay 27 laboratorios Docker y 16 en línea. Docker responde. Hay unos 92 GB libres. `sudo` en WSL no es interactivo.

El arranque de `breakinglab.sh` mira `docker ps` y tira la salida. El comando sale 0 aunque no haya contenedor, así que intenta `docker start` de un nombre que no existe y no llega a `docker run`. `add_host` pide `sudo` y, si falla, el script se para. `open_url` intenta instalar `wslu` y abre el navegador.

Cambios de arranque, sin tocar la vulnerabilidad del laboratorio:

1. Considerar que el contenedor existe solo si `docker ps` devuelve un id.
2. Si no hay `sudo`, seguir y publicar en la IP `127.x`. El alias de `/etc/hosts` no se escribe.
3. Si la salida no es una terminal, no abrir el navegador. Así se puede probar en serie.
4. El contador de espera no puede tumbar `set -e`.

Luego, un laboratorio detrás de otro: arrancar, comprobar el puerto y la URL, dejarlo en marcha si responde. Los de internet solo se consultan con una petición.
