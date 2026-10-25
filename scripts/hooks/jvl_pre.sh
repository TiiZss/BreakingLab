#!/usr/bin/env bash
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/lib/lab_dir.sh"
bl_prepare_lab JavaVulnerableLab https://github.com/CSPF-Founder/JavaVulnerableLab.git pull || exit
