#!/usr/bin/env bash
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/lib/lab_dir.sh"
bl_prepare_lab Damn-Vulnerable-RESTaurant-API-Game https://github.com/theowni/Damn-Vulnerable-RESTaurant-API-Game.git || exit
