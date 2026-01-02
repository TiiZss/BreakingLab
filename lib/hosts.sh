#!/bin/bash

ETC_HOSTS=/etc/hosts

add_host() { grep -q "$2" $ETC_HOSTS || sudo sh -c "echo '$1\t$2' >> $ETC_HOSTS"; }

remove_host() {
    local ip=$1
    local proj=$2
    if grep -q "$proj" $ETC_HOSTS; then
        echo "Removing $proj from $ETC_HOSTS"
        sudo sed -i "/\s$proj$/d" $ETC_HOSTS || { echo -e "$TCR Failed to remove $proj from $ETC_HOSTS $TCD"; return 1; }
    else
        echo "$proj not found in $ETC_HOSTS"
    fi
}
