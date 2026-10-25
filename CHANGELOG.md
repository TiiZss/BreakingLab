# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Changed
- Los laboratorios que el lanzador clona van a `labs/`. La raíz deja de recibir esos árboles.
- El compose de Bricks y el de DVWS-node quedan en `projects/`. `bricks/` y `stacks/` salen de la raíz.
- Cada máquina tiene su stack `breakinglab_<clave>`. Los contenedores llevan el prefijo de la máquina (`jvl2013_`).
- Bricks arranca con `tiizss/bricks-mysql-5.7:5.7`. El SQL de usuarios va dentro de esa imagen.

## [2.2.0] - 2026-10-24

### Added
- Mapa de trabajo del agente en `CLAUDE.md` y `.cursor/rules/workflow.mdc`. Memoria en `docs/workflow/`.
- Documentos de planificación en `docs/` y `.github/prompts/`, enlazados desde el README.
- ShellCheck del lanzador, de `lib/` y de los hooks. `archive/` queda fuera del análisis.
- Un solo stack de Docker, `breakinglab`. Cada laboratorio nombra sus contenedores con su clave (`jvl2013_`, `web4pentester_w4p`).
- `up` y `down` (opciones 10 y 11). `down` apaga el stack. El estado muestra la IP y el puerto cuando el laboratorio está en marcha.
- Máquinas nuevas: WebGoat 8.0, 8.1 y 8.2, Java Vulnerable Lab 2013, DVWS-node, DVGA y Bricks 2.2.
- Las imágenes de los laboratorios salen de `tiizss` en Docker Hub, con la versión en el nombre del repositorio.

### Changed
- Vulnado arranca desde `tiizss/vulnado-0.0.1` (origen `bbhunter/vulnado`). El lanzador ya no clona ese repositorio.
- WebGoat 8.2 es la máquina `webgoat82`. `webgoat8` deja de existir.

## [2.1.0] - 2026-01-03

### Added
- **GitHub Import Feature**: Import Docker projects directly from GitHub URLs.
- **Auto-Sanitization**: Automatically sanitizes imported `docker-compose.yml` files (removes naming conflicts, rebinds ports to assigned IP).
- **Auto-IP Assignment**: The "Add New Project" wizard now automatically assigns the next available IP in the `127.100.0.X` range.
- **Delete Project**: Added option to cleanly delete project configurations and resources via menu or CLI (`delete` command).
- **Stack Status Detection**: Improved `status` and menu checks to correctly identify running Docker Compose stacks using project labels.

### Changed
- **Menu Alignment**: Optimized "Online Projects" list to a single-column layout for better readability.
- **Wizard Improvements**: Clarified port prompts and optimized the flow for adding new projects.

## [2.0.0] - 2026-01-02

### Added
- Created `CHANGELOG.md`.
- Implemented `start_public` command to allow exposing containers to external networks.
- Added modular structure with `lib/` and `config/` directories.
- Added `install.sh` for global installation.
- Added GitHub Actions workflow for ShellCheck.
- Implemented robust `check_dependencies` function.
- Implemented dynamic menu system in `lib/menu.sh` allowing selection by number or name.
- Added visual status indicators (`[ON]`/`[OFF]`) to menu lists.
- Implemented 2-column layout for better menu readability.
- Improved WSL compatibility by using IP:PORT instead of hostnames for project URLs.
- Replaced unreliable Docker check with robust polling mechanism.
- Fixed script exit bug when cancelling menu selection.

### Changed
- Refactored `breakinglab.sh` to be a lightweight wrapper.
- Enforced strict mode (`set -euo pipefail`) for better reliability.
- Moved project configuration to `config/projects.conf`.
- Moved utility functions to `lib/utils.sh`, `lib/colors.sh`, and `lib/hosts.sh`.
- Improved security by removing unnecessary `eval` calls where possible.
- Moved old scripts to `archive/` and assets to `assets/`.
