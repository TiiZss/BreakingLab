#!/usr/bin/env bash
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/lib/stack.sh"
cd Damn-Vulnerable-RESTaurant-API-Game || exit
sed -i 's|- 8091:8091|- "127.25.0.1:8080:8091"|' docker-compose.yml
bl_compose damnvulnrest "$PWD" docker-compose.yml up -d || exit
cd .. || exit
