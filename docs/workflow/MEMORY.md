# Memoria

Hechos comprobados el 2026-10-20. Si uno deja de ser cierto, se corrige aquí y se anota la fecha.

- BreakingLab es un lanzador de práctica. Las máquinas y los scripts que arranca son vulnerables a propósito. Entrada: `breakinglab.sh`. Librerías en `lib/`. Definiciones en `config/projects.d/`. Confirmado por el autor el 2026-10-21.
- El remoto documentado en el README es `https://github.com/TiiZss/BreakingLab`. La versión del changelog es 2.2.0 (2026-10-24).
- El CI en el repositorio es ShellCheck (`.github/workflows/shellcheck.yml`).
- No hay módulos Python ni aplicación web propia. `projects/` contiene árboles importados: `dvws-node-2`, `dvwsnode2`, `vulpy5`.
- Graft está instalado y el repo tiene índice. `graft/` está en `.gitignore`.
- `uv` está en el PATH. No hay proyecto Python que lo use.
- Humanizer está en `D:\Scripts\Z-externos\humanizer` y no está en el PATH.
- ECC tiene 261 skills en `D:\Scripts\Z-externos\ECC\skills`. El catálogo de ciberseguridad de comunidad tiene 818 en `D:\Scripts\Z-externos\Anthropic-Cybersecurity-Skills\skills`.
- Los MCP vistos en la sesión de esa fecha: GitHub, Context7, Playwright, Filesystem, Sentry, graft. `markitdown` no estaba.
- El remoto `origin` es `https://github.com/TiiZss/BreakingLab`. El remoto `gitea` es `https://gitea.tiizss.internal/tiizss/BreakingLab` (login `tea` `tiizss`). El 2026-10-21, tras fusionar el pull request, GitHub `main` quedó en `99ebc05` y Gitea `main` en `64bd6f9`. El árbol de ficheros coincide. Gitea aún tiene la rama `docs/agent-map`. SSH al puerto 22 de ese host responde `Connection refused`.
- Git avisa `dubious ownership` en `D:/Scripts/BreakingLab` para `ALMANSA4/Puper`. No se añade `safe.directory` global. El atajo de un comando es `git -c safe.directory=D:/Scripts/BreakingLab`.
