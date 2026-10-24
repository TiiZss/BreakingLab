# Levantar todos los laboratorios

Fecha: 2026-10-21

## Qué se pide

Un arranque automático de todos los contenedores a la vez, del estilo de Portainer o Traefik.

## Qué se hace

`breakinglab.sh up` recorre `DOCKER_PROJECTS` y arranca cada laboratorio en la IP y el puerto de su ficha. `breakinglab.sh down` los para. Un fallo no corta el resto. No hay pausa de tecla ni navegador. Cada laboratorio tiene un tope de 10 minutos.

Traefik queda fuera: un proxy único dejaría las `127.x` sin uso. Portainer tampoco asigna esas IP ni ejecuta los ganchos.

## Qué se toca

- `breakinglab.sh`: `up` y `down`, y saltar la pausa cuando `BREAKINGLAB_BATCH=1`.
- `lib/hosts.sh`: `down` no espera una contraseña de sudo.
- Ganchos que hoy no vuelven solos: `web4pentester` (sin `sudo` ni terminal), `damnvulnrest` y `btslab` (`compose up -d` en su `127.x`), `ssrflab` (contenedor en `127.24.0.1`) y `vulnado` (clon si falta, sin `sudo`).

## Qué no se hace

No se cambian las aplicaciones vulnerables. No se inventan imágenes para las que Docker ya rechaza. `w4p` y `web4pentester` siguen compartiendo `127.18.0.1:80`: entra el que consiga la dirección.
