#!/usr/bin/env bash
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/lib/lab_dir.sh"
bl_prepare_lab SSRF-LAB https://github.com/ph4nt0m-py/SSRF-LAB.git || exit
