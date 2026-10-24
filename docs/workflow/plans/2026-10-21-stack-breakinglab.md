# Un solo stack breakinglab

Fecha: 2026-10-21

## Qué se pide

Todas las máquinas tienen que crearse dentro del stack BreakingLab.

## Límite de Compose

`docker compose -p BreakingLab` lo rechaza: el nombre de proyecto solo admite minúsculas, números, guiones y guiones bajos. Compose además pisa la etiqueta `com.docker.compose.project` con ese nombre. El stack común queda en `breakinglab`, que es la forma válida de BreakingLab. Las imágenes sueltas llevan la misma etiqueta para entrar en ese stack.

## Qué se hace

`lib/stack.sh` prepara un compose por laboratorio con los servicios, volúmenes y la red `default` prefijados, y lo levanta con `-p breakinglab`. Cada servicio conserva el nombre original como alias de red, así `db` sigue resolviendo dentro de su laboratorio. `down` para un laboratorio solo baja el fichero generado de ese laboratorio.

## Qué no se hace

No se juntan dos servicios llamados `web` en el mismo nombre. No se toca la aplicación vulnerable ni `archive/`.
