#!/usr/bin/env bash
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/lib/stack.sh"
cd "$ROOT/projects/vulnado" || exit
bl_compose vulnado "$PWD" docker-compose.yml up -d || exit
