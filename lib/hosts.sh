#!/bin/bash

ETC_HOSTS=/etc/hosts

add_host() {
    grep -q "$2" $ETC_HOSTS && return 0
    if ! sudo -n true 2>/dev/null; then
        echo "Sin sudo. Abre $1. No se ha escrito el alias $2 en $ETC_HOSTS."
        return 0
    fi
    sudo sh -c "echo '$1\t$2' >> $ETC_HOSTS"
}

remove_host() {
    local proj=$2
    if grep -q "$proj" $ETC_HOSTS; then
        if ! sudo -n true 2>/dev/null; then
            echo "Sin sudo. No se ha borrado $proj de $ETC_HOSTS."
            return 0
        fi
        echo "Removing $proj from $ETC_HOSTS"
        sudo sed -i "/\s$proj$/d" $ETC_HOSTS || { echo -e "$TCR Failed to remove $proj from $ETC_HOSTS $TCD"; return 1; }
    else
        echo "$proj not found in $ETC_HOSTS"
    fi
}
