# 2026-10-25 — laboratorios fuera de la raíz

## Hecho

`bricks/` sigue en la raíz. `stacks/` guarda un solo compose, el de DVWS-node. `projects/` mezcla ese papel con dos clones sin seguimiento (`dvwsnode2`, `dvws-node-2`).

`test_awk.sh` y `test_gh_fetch.sh` se quedan en la raíz: los prompts de `.github/prompts/` apuntan a esa ruta.

## Cambio

- `bricks/` pasa a `projects/bricks/`.
- El compose de `stacks/dvwsnode2` pasa a `projects/dvwsnode2`. `stacks/` desaparece.
- Los dos clones de DVWS-node pasan a `labs/`, con el resto de árboles de terceros.
- `projects/` queda para lo que el lanzador versiona: bricks, jvl2013, vulnado, dvwsnode2 y el submódulo vulpy5.
