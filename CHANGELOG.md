# Changelog

All notable changes to this project will be documented in this file.

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
