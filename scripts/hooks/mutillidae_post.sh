#!/usr/bin/env bash
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/lib/stack.sh"
cd mutillidae-docker || exit
bl_compose mutillidae "$PWD" .build/docker-compose.yml up -d || exit
cd .. || exit
