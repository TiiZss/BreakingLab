#!/usr/bin/env bash
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/lib/stack.sh"
cd "$ROOT/projects/jvl2013" || exit
bl_compose jvl2013 "$PWD" docker-compose.yml up -d || exit
