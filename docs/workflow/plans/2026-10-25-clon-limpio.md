# 2026-10-25 — fallos del clon limpio

## Hecho

`exploitcoil` clona Cryoox y ese compose dice `build: .`. No usa `tiizss/exploitcoil:latest`.

`projects/vulpy5` es un gitlink sin `.gitmodules`. El clon llega con la carpeta vacía y sin `docker-compose.yml`.

## Cambio

- Compose propio en `projects/exploitcoil`. El gancho ya no clona.
- El gitlink de Vulpy 5 se sustituye por `projects/vulpy5/docker-compose.yml`, que usa `tiizss/vulpy5:latest`.
