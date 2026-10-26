# Decisiones

## 2026-10-26 — Panel local en el navegador

`./breakinglab.sh web` ejecuta `web/server.py` y escucha solo en `127.0.0.1:8765`. El panel enciende, apaga y elige privado o público. No se publica el panel en la red del aula. No hay `pyproject.toml`: el proceso es el Python 3 que ya trae WSL.

## 2026-10-25 — Una máquina en la red del aula

`start` sigue publicando cada laboratorio en su `127.x`. La opción 3 y `startpublic` publican en la IP del ordenador, así que solo puede haber una en marcha. Si ya hay otra, el menú pregunta antes de apagarla.

## 2026-10-25 — La licencia del lanzador es GPL-3.0

El 2024-01-11 `LICENSE` pasó de MIT a la GPL-3.0. GitHub lee ese fichero. El README de la 2.0.0 volvió a escribir MIT. Cryoox y Matope tienen commits posteriores a ese cambio, así que el texto que se queda es la GPL-3.0. El README apunta a `LICENSE`.

## 2026-10-20 — Mapa del agente en CLAUDE.md y en una regla de Cursor

Claude Code lee `CLAUDE.md` en la raíz. Cursor lee `.cursor/rules/*.mdc`. Hace falta los dos. `AGENTS.md`, `GEMINI.md` y `.github/copilot-instructions.md` solo apuntan al mapa, detrás del bloque de graft, para no duplicar cinco copias que se desfasarían.

## 2026-10-20 — MEMORY, LEARNINGS y decisions fuera de la raíz

El encargo pedía esos tres nombres en la raíz y, en el mismo texto, una raíz con pocos ficheros. La raíz ya tiene `README.md`, `CHANGELOG.md`, `LICENSE`, `AGENTS.md`, `GEMINI.md` y `CLAUDE.md`. Los tres registros quedan en `docs/workflow/`. El 2026-10-21 se confirmó que se quedan ahí.

## 2026-10-21 — El laboratorio vulnerable no se parchea

El autor lo fijó: BreakingLab sirve para practicar skills de ciberseguridad contra máquinas y scripts vulnerables. El fallo del laboratorio es el ejercicio. Un cambio del lanzador puede hacer que el script arranque, pare y pase ShellCheck. No convierte el laboratorio en una aplicación segura. Las skills de `Anthropic-Cybersecurity-Skills` se leen desde `D:\Scripts\Z-externos` y se aplican a ese laboratorio, en una máquina propia.

## 2026-10-20 — Skills por referencia, no por copia

ECC y el catálogo de ciberseguridad se usan desde `D:\Scripts\Z-externos`. Al repo solo entra la lista de skills que encajan con un lanzador Bash/Docker. El 2026-10-20 no había interfaz. El panel de 2026-10-26 está en `web/`. Las skills ofensivas no se copian.

## 2026-10-20 — MCP sin secretos nuevos

`.cursor/mcp.json` sigue declarando solo graft. GitHub, Context7, Playwright, Filesystem y Sentry ya existen a nivel de usuario. `markitdown` no estaba conectado y no se ha añadido un servidor inventado.

## 2026-10-21 — Gitea primero, GitHub después

El login de `tea` se llama `tiizss` y su URL es `https://gitea.tiizss.internal`. Ahí está `tiizss/BreakingLab`, rama `main`, commit `baf498d`, el mismo que `origin/main` en GitHub (`https://github.com/TiiZss/BreakingLab`). El clon local no tiene un remoto de Gitea: `origin` es solo GitHub. SSH al puerto 22 de `gitea.tiizss.internal` responde `Connection refused`. HTTPS sí responde.

`dubious ownership` no es un rechazo de Gitea ni de GitHub. Git ve que la carpeta `D:/Scripts/BreakingLab` pertenece a otra cuenta de Windows y se niega a trabajar ahí. El mensaje propone `git config --global --add safe.directory`. Esa línea no se ejecuta. Para leer o commitear en un comando basta `-c safe.directory=D:/Scripts/BreakingLab`, que no se guarda.

## 2026-10-25 — exploit.co.il y Vulpy 5 salen de imágenes

Un clon limpio de `c86f018` construía exploit.co.il desde Cryoox y no encontraba el compose de Vulpy 5, porque esa ruta era un gitlink sin `.gitmodules`. Los dos quedan como compose en `projects/` y arrancan con `tiizss/exploitcoil:latest` y `tiizss/vulpy5:latest`. La prueba de los 28 laboratorios sobre `0c2c2d9` está en `docs/workflow/lab-check-2026-10-25.md`.

## 2026-10-25 — Un stack por máquina

El proyecto Compose deja de ser uno solo. Cada laboratorio usa `breakinglab_<clave>` y sus contenedores `<clave>_`. La opción de apagar todos recorre esas etiquetas. Bricks no monta `init.sql`: esa tabla va en `tiizss/bricks-mysql-5.7:5.7`, así el compose de `projects/` arranca solo con imágenes.

## 2026-10-25 — Un solo sitio para el compose del lanzador

`bricks/` y `stacks/` salen de la raíz. El compose que versiona el lanzador queda en `projects/`: bricks, jvl2013, vulnado y dvwsnode2. Los clones de DVWS-node que estaban sueltos en `projects/` pasan a `labs/`, con el resto de árboles de terceros. `test_awk.sh` y `test_gh_fetch.sh` siguen en la raíz porque hay prompts que citan esa ruta.

## 2026-10-25 — Los clones de terceros van a labs/

El arranque clonaba en el directorio de trabajo. Desde la raíz, el repositorio se llenaba de árboles ajenos. `projects/` ya tiene compose del lanzador, así que los clones van a `labs/`, que git ignora. Una copia que aún esté en la raíz se mueve a `labs/` la siguiente vez que ese laboratorio arranca.

## 2026-10-24 — Imágenes en tiizss y prefijo por laboratorio

Los laboratorios publicados tiran de imágenes `tiizss` en Docker Hub. La versión va en el nombre del repositorio. Dentro del stack `breakinglab`, los contenedores de un laboratorio empiezan por la clave de ese laboratorio. Los árboles clonados de terceros no entran en el commit: el compose que es del lanzador sí (`projects/jvl2013`, `projects/vulnado`, `stacks/dvwsnode2`, `bricks/docker-compose.yml`).

## 2026-10-20 — Sin commit, tag ni merge en este cambio

El árbol de trabajo mezcla el mapa del agente con cambios ajenos (`README.md`, hooks de `jvl`, `projects/vulpy5` y otros ficheros sin seguimiento). No se hace un commit de todo eso junto. La copia previa del mapa está en `.backups/2026-10-20-workflow/`.

## 2026-10-20 — Copia de seguridad acotada

Antes de reescribir lógica se copian los ficheros afectados a `.backups/`. Esa carpeta no se versiona. No se hace un segundo árbol completo del repositorio en cada cambio: la rama cubre ese papel cuando git funciona.
