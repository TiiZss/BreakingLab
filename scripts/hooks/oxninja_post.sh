#!/usr/bin/env bash
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/lib/stack.sh"
cd oxninja-sqlilab || exit
bl_compose oxninja "$PWD" docker-compose.yml up -d || exit
cd .. || exit
