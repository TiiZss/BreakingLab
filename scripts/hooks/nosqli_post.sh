#!/usr/bin/env bash
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/lib/stack.sh"
cd nosqlilab || exit
bl_compose nosqli "$PWD" docker-compose.yml up -d || exit
cd .. || exit
