# 2026-10-25 — un stack por máquina

## Hecho

Todo el arranque comparte el proyecto Compose `breakinglab`. Bricks es el único compose de `projects/` que monta un fichero del repo (`init.sql`). jvl2013, vulnado, dvwsnode2 y vulpy5 ya arrancan solo con imágenes `tiizss`.

## Cambio

- El proyecto Compose de cada máquina es `breakinglab_<clave>`. Los contenedores siguen ` <clave>_`, por ejemplo `breakinglab_jvl2013` y `jvl2013_mysql`.
- `down` apaga todos los stacks `breakinglab` y `breakinglab_*`.
- Bricks deja de montar `init.sql`. La imagen `tiizss/bricks-mysql-5.7:5.7` lleva ese SQL.
