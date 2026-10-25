#!/usr/bin/env bash
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/lib/stack.sh"
cd "$ROOT/labs/btslab" || exit
sed -i 's|"8080:80"|"127.26.0.1:80:80"|' docker-compose.yml
bl_compose btslab "$PWD" docker-compose.yml up -d || exit
cd .. || exit
