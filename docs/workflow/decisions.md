# Decisiones

## 2026-10-20 — Mapa del agente en CLAUDE.md y en una regla de Cursor

Claude Code lee `CLAUDE.md` en la raíz. Cursor lee `.cursor/rules/*.mdc`. Hace falta los dos. `AGENTS.md`, `GEMINI.md` y `.github/copilot-instructions.md` solo apuntan al mapa, detrás del bloque de graft, para no duplicar cinco copias que se desfasarían.

## 2026-10-20 — MEMORY, LEARNINGS y decisions fuera de la raíz

El encargo pedía esos tres nombres en la raíz y, en el mismo texto, una raíz con pocos ficheros. La raíz ya tiene `README.md`, `CHANGELOG.md`, `LICENSE`, `AGENTS.md`, `GEMINI.md` y `CLAUDE.md`. Los tres registros quedan en `docs/workflow/`. El 2026-10-21 se confirmó que se quedan ahí.

## 2026-10-21 — El laboratorio vulnerable no se parchea

El autor lo fijó: BreakingLab sirve para practicar skills de ciberseguridad contra máquinas y scripts vulnerables. El fallo del laboratorio es el ejercicio. Un cambio del lanzador puede hacer que el script arranque, pare y pase ShellCheck. No convierte el laboratorio en una aplicación segura. Las skills de `Anthropic-Cybersecurity-Skills` se leen desde `D:\Scripts\Z-externos` y se aplican a ese laboratorio, en una máquina propia.

## 2026-10-20 — Skills por referencia, no por copia

ECC y el catálogo de ciberseguridad se usan desde `D:\Scripts\Z-externos`. Al repo solo entra la lista de skills que encajan con un lanzador Bash/Docker. Las skills de interfaz web no se activan: no hay interfaz. Las skills ofensivas no se copian.

## 2026-10-20 — MCP sin secretos nuevos

`.cursor/mcp.json` sigue declarando solo graft. GitHub, Context7, Playwright, Filesystem y Sentry ya existen a nivel de usuario. `markitdown` no estaba conectado y no se ha añadido un servidor inventado.

## 2026-10-21 — Gitea primero, GitHub después

El login de `tea` se llama `tiizss` y su URL es `https://gitea.tiizss.internal`. Ahí está `tiizss/BreakingLab`, rama `main`, commit `baf498d`, el mismo que `origin/main` en GitHub (`https://github.com/TiiZss/BreakingLab`). El clon local no tiene un remoto de Gitea: `origin` es solo GitHub. SSH al puerto 22 de `gitea.tiizss.internal` responde `Connection refused`. HTTPS sí responde.

`dubious ownership` no es un rechazo de Gitea ni de GitHub. Git ve que la carpeta `D:/Scripts/BreakingLab` pertenece a otra cuenta de Windows y se niega a trabajar ahí. El mensaje propone `git config --global --add safe.directory`. Esa línea no se ejecuta. Para leer o commitear en un comando basta `-c safe.directory=D:/Scripts/BreakingLab`, que no se guarda.

## 2026-10-24 — Imágenes en tiizss y prefijo por laboratorio

Los laboratorios publicados tiran de imágenes `tiizss` en Docker Hub. La versión va en el nombre del repositorio. Dentro del stack `breakinglab`, los contenedores de un laboratorio empiezan por la clave de ese laboratorio. Los árboles clonados de terceros no entran en el commit: el compose que es del lanzador sí (`projects/jvl2013`, `projects/vulnado`, `stacks/dvwsnode2`, `bricks/docker-compose.yml`).

## 2026-10-20 — Sin commit, tag ni merge en este cambio

El árbol de trabajo mezcla el mapa del agente con cambios ajenos (`README.md`, hooks de `jvl`, `projects/vulpy5` y otros ficheros sin seguimiento). No se hace un commit de todo eso junto. La copia previa del mapa está en `.backups/2026-10-20-workflow/`.

## 2026-10-20 — Copia de seguridad acotada

Antes de reescribir lógica se copian los ficheros afectados a `.backups/`. Esa carpeta no se versiona. No se hace un segundo árbol completo del repositorio en cada cambio: la rama cubre ese papel cuando git funciona.
