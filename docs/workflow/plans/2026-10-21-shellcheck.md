# Plan: ShellCheck en verde

Fecha: 2026-10-21. Rama `docs/agent-map`.

## Hechos

El workflow falla con 415 avisos. 316 están en `archive/bl2023.sh` y `archive/bl2024.sh`. El lanzador no los ejecuta. Reescribirlos cambiaría el archivo histórico.

Los otros 99 están en `breakinglab.sh`, `lib/` y `scripts/hooks/`. Tres hooks no son shell válido: `mutillidae_pre.sh`, `oxninja_pre.sh` y `oxninja_post.sh`. El texto completo del arranque está en `archive/bl2024.sh`.

## Qué se cambia

1. `ignore_paths: archive` en el workflow.
2. `.shellcheckrc` con `external-sources=true` para que el análisis siga los `source` de `lib/`.
3. En el lanzador y en `lib/`: `read -r`, asignaciones separadas del `local`, y las comparaciones sin comillas que ShellCheck marca. No se cambia el flujo de arranque.
4. Shebang en los hooks que ya son una orden válida, y `cd ... || exit` donde el `cd` iba en una cadena `&&`.
5. `mutillidae_*.sh` y `oxninja_*.sh` vuelven a las órdenes de `bl2024.sh`.
6. Los cambios locales sin commit de `jvl` no entran en este commit. Se copian a `.backups/` antes de tocar el hook versionado.

## Qué no se hace

No se fusiona `main` hasta que el ShellCheck de GitHub termine en verde. No se toca `git config`.
