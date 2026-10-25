# BreakingLab — mapa del agente

Las carpetas guardan el código. Este archivo dice cómo leerlas. Cursor carga el mismo criterio en `.cursor/rules/workflow.mdc`. Gemini y Copilot llegan aquí desde `GEMINI.md` y `.github/copilot-instructions.md`.

## Qué es este repositorio

BreakingLab es un script Bash para practicar skills de ciberseguridad. Arranca y para, con Docker, máquinas y aplicaciones vulnerables a propósito. Esas vulnerabilidades son el material de práctica. No se parchean, no se eliminan y no se tratan como un defecto del lanzador. La entrada es `breakinglab.sh`. `install.sh` comprueba dependencias y puede enlazar el script. No hay frontend propio ni módulos Python.

## Dónde está cada cosa

- `breakinglab.sh` — entrada.
- `lib/` — `colors.sh`, `hosts.sh`, `menu.sh`, `utils.sh`, `yaml_utils.sh`, `stack.sh`, `lab_dir.sh`.
- `config/projects.conf` y `config/projects.d/` — laboratorios declarados.
- `scripts/hooks/` — ganchos pre y post de algunos laboratorios.
- `projects/` — compose del lanzador (`bricks`, `jvl2013`, `vulnado`, `dvwsnode2`) y el submódulo `vulpy5`.
- `labs/` — clones de terceros. Git no los versiona.
- `archive/` — `bl2023.sh` y `bl2024.sh`.
- `assets/` — logo.
- `docs/` — planificación. La memoria del agente está en `docs/workflow/`.
- `.github/workflows/shellcheck.yml` — el CI que hay hoy en el repositorio.

`test_awk.sh` y `test_gh_fetch.sh` siguen en la raíz. Moverlos cambiaría rutas sin que nadie lo haya pedido.

## Antes de tocar código

1. Lee `.claude/napkin.md` y aplica lo que siga vigente.
2. Pregunta a graft (`graft ask`, `graft grep`, `graft skeleton`, `graft callers`, `graft map`) antes de abrir fuentes. El índice `graft/` no se versiona: se regenera con `graft build`.
3. Escribe el plan en `docs/workflow/plans/` y trabaja sobre ese fichero, no sobre la memoria de la sesión.
4. Antes de un cambio que borre o reescriba lógica, copia los ficheros afectados a `.backups/AAAA-MM-DD/`. La rama es la otra copia. No dupliques el repositorio entero.
5. Una funcionalidad, una rama.

Si una función estable no es el objetivo del cambio, no la reescribas. Lo nuevo entra por un fichero o un gancho aparte, y el flujo anterior sigue respondiendo igual. Los ficheros nuevos van en UTF-8.

Este repositorio no tiene Python. Si entra, el entorno será un virtualenv gestionado con `uv`, no con `pip`. Hasta entonces no añadas `pyproject.toml`.

## Qué reutilizar

Antes de escribir una funcionalidad, busca en GitHub un proyecto que ya la cubra. Úsalo de base cuando la licencia cuadre y el ajuste sea real.

En esta máquina:

- `D:\Scripts\Z-externos\ECC\skills` tiene 261 skills. Aquí aplican `docker-patterns`, `security-review`, `security-scan`, `git-workflow`, `github-ops`, `verification-loop`, `terminal-ops`, `architecture-decision-records`, `search-first`, `context-budget`, `codebase-onboarding` y `production-audit`. El resto no corresponde a un lanzador Bash. No copies el catálogo al repositorio: se lee desde esa ruta.
- `D:\Scripts\Z-externos\Anthropic-Cybersecurity-Skills\skills` tiene 818 skills de un proyecto de comunidad. Sirven cuando el trabajo es practicar contra un laboratorio que este script ha arrancado en una máquina propia. No las copies al repositorio. No las uses contra un sistema que no sea ese laboratorio.

No hay interfaz web propia. Impeccable, Frontend Design, UI UX Pro Max, Theme Factory y las reglas visuales de Vercel esperan a que esa interfaz exista.

## Herramientas

- Graft, ya cableado.
- Caveman en español, nivel lite. El nivel full elimina artículos; en español la frase deja de decir lo mismo.
- Napkin en `.claude/napkin.md`.
- Diagram Design (https://github.com/cathrynlavery/diagram-design) cuando haya que dibujar. No está clonado en `D:\Scripts\Z-externos`. Si hace falta un diagrama y la skill no está disponible, dilo y para. No lo sustituyas por un esquema inventado.
- Humanizer en `D:\Scripts\Z-externos\humanizer`. La prosa nueva sigue esa guía. El comando no está en el PATH.
- MCP presentes en la sesión al escribir esto: GitHub, Context7, Playwright, Filesystem, Sentry y graft. `markitdown` no estaba conectado. No inventes su configuración. `.cursor/mcp.json` solo declara graft; los secretos no van al repositorio.

Elige el agente más estrecho que resuelva la tarea. Un cambio de una línea no lleva subagente.

## Publicación

El remoto local `origin` apunta a GitHub. El repo también existe en Gitea, en `https://gitea.tiizss.internal/tiizss/BreakingLab`, y ese es el primer destino. GitHub va después, cuando Gitea ya tiene el mismo commit.

Sube cuando ShellCheck esté en verde, el panel de problemas no marque avisos de ese cambio y la documentación tocada coincida con el código. Entonces etiqueta, publica la release y, con la rama ya fusionada y verde, deja `main` como única rama. Si el CI falla, se corrige antes de fusionar.

Si git dice `dubious ownership`, no ejecutes `git config --global`. Para un comando concreto basta `git -c safe.directory=D:/Scripts/BreakingLab`. Esa opción no se guarda.

## Memoria

- `docs/workflow/MEMORY.md` — hechos que siguen siendo verdad.
- `docs/workflow/LEARNINGS.md` — lecciones reutilizables.
- `docs/workflow/decisions.md` — qué se decidió y por qué.

Esos tres ficheros no están en la raíz. La raíz ya tiene `README.md`, `CHANGELOG.md`, `LICENSE`, `AGENTS.md`, `GEMINI.md` y este archivo. El motivo está en `docs/workflow/decisions.md`.
