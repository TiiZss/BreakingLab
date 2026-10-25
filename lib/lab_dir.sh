#!/usr/bin/env bash

# Árboles de terceros que el lanzador clona. Viven en labs/, no en la raíz.

bl_prepare_lab() {
    local name="$1"
    local url="$2"
    local pull="${3:-}"
    local repo dest
    repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    dest="$repo/labs/$name"
    mkdir -p "$repo/labs"
    if [ -d "$repo/$name" ] && [ ! -d "$dest" ]; then
        mv "$repo/$name" "$dest"
    fi
    if [ ! -d "$dest/.git" ]; then
        git clone "$url" "$dest" || return 1
    elif [ "$pull" = "pull" ]; then
        git -C "$dest" pull --ff-only || true
    fi
    cd "$dest" || return 1
}
