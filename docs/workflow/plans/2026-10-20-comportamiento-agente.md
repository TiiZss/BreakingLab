# Plan: comportamiento del agente

Fecha: 2026-10-20. Hecho antes de editar las reglas. El código de `breakinglab.sh`, `lib/` y `config/` no entra en este cambio.

## Hechos comprobados

- El repositorio es Bash y Docker. La entrada es `breakinglab.sh`. No hay aplicación web propia ni Python.
- `AGENTS.md`, `GEMINI.md` y `.github/copilot-instructions.md` solo traían el bloque de graft. No existía `CLAUDE.md`.
- `.cursor/mcp.json` y `.mcp.json` solo declaran graft.
- En esta sesión aparecen los servidores GitHub, Context7, Playwright, Filesystem, Sentry y graft. `markitdown` no aparece.
- `D:\Scripts\Z-externos\ECC\skills` tiene 261 skills. `D:\Scripts\Z-externos\Anthropic-Cybersecurity-Skills\skills` tiene 818.
- `graft` y `uv` están en el PATH. `humanizer` está en `D:\Scripts\Z-externos\humanizer` y no está en el PATH. `napkin` y `diagram-design` no están clonados en `D:\Scripts\Z-externos`.
- Git existe (hay `.git`) y falla con `dubious ownership`. No se toca `git config`.
- El CI versionado es `.github/workflows/shellcheck.yml`.

## Qué se escribe

1. `CLAUDE.md` en la raíz, porque Claude Code solo carga ese nombre ahí.
2. `.cursor/rules/workflow.mdc` con `alwaysApply: true`, el equivalente en Cursor.
3. Un puntero corto, detrás del bloque de graft, en `AGENTS.md`, `GEMINI.md` y `.github/copilot-instructions.md`.
4. `.claude/napkin.md`, que es la ruta que exige Napkin.
5. `docs/workflow/MEMORY.md`, `LEARNINGS.md` y `decisions.md`.
6. Entrada en `docs/README.md` y nota `Unreleased` en `CHANGELOG.md`.
7. `.backups/` en `.gitignore`.

## Qué no se hace en este paso

- No se copia ECC ni el catálogo de ciberseguridad al repositorio.
- No se inventa un servidor `markitdown` ni se meten secretos en `mcp.json`.
- No se añaden skills de interfaz web: no hay interfaz que diseñar.
- No se mueve `test_awk.sh` ni `test_gh_fetch.sh`.
- No hay commit, tag, release, push ni merge. El remoto y el CI de este cambio no están verificados, y git no opera hasta resolver la propiedad del directorio sin tocar la configuración global.
