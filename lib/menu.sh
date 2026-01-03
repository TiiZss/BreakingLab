#!/bin/bash
# Library for dynamic menus


print_menu_items() {
    local type=$1 # "docker" or "online"
    local keys=()
    local display_lines=()
    
    # Get running containers efficiently
    local running_containers=""
    if [ "$type" == "docker" ]; then
        if command -v docker >/dev/null 2>&1; then
             running_containers=$(docker ps --format '{{.Names}}' 2>/dev/null || true)
        fi
    fi

    # Sort keys
    if [ "$type" == "docker" ]; then
        mapfile -t sorted_keys < <(for k in "${!DOCKER_PROJECTS[@]}"; do echo "$k"; done | sort)
    else
        mapfile -t sorted_keys < <(for k in "${!ONLINE_PROJECTS[@]}"; do echo "$k"; done | sort)
    fi

    local total=${#sorted_keys[@]}
    local i=0

    # Single Column for Online Projects
    if [ "$type" == "online" ]; then
        for ((i=0; i<total; i++)); do
            local key="${sorted_keys[$i]}"
            local desc=""
            IFS='|' read -r _ desc <<< "${ONLINE_PROJECTS[$key]}"
            
            # Format: No truncation needed mostly, or large limit
            printf " %2d) %b%-20s%b - %s\n" "$((i+1))" "$TCG" "$key" "$TCD" "$desc"
        done
        return
    fi
    
    while [ $i -lt $total ]; do
        # Item 1
        local key1="${sorted_keys[$i]}"
        local desc1=""
        local stat1=""
        local stat1_color=""
        
        if [ "$type" == "docker" ]; then
             IFS='|' read -r _ _ _ desc1 _ <<< "${DOCKER_PROJECTS[$key1]}"
             if docker ps --format '{{.Names}}' | grep -q "^breakinglab_$key1$"; then
                stat1="ON"
                stat1_color="$TCG"
            elif docker ps -q --filter "label=com.docker.compose.project=breakinglab_${key1}" | grep -q .; then
                 stat1="ON"
                 stat1_color="$TCG"
            elif docker ps --format '{{.Names}}' | grep -q "^$key1$"; then
                stat1="ON"
                stat1_color="$TCY"
            else
                stat1="OFF"
                stat1_color="$TCR"
            fi
        else
             IFS='|' read -r _ desc1 <<< "${ONLINE_PROJECTS[$key1]}"
        fi
        
        # Truncate description. Reduced to 30 to make space for status
        desc1="${desc1:0:30}"
        
        # Format string 1
        local str1
        if [ "$type" == "docker" ]; then
             # With Status: key(16) status(5) desc(30)
             printf -v str1 " %2d) %b%-16s%b %b%s%b - %-30s" "$((i+1))" "$TCG" "$key1" "$TCD" "$stat1_color" "$stat1" "$TCD" "$desc1"
        else
             # Without Status: key(15) desc(35) - keep consistent total width ~ similar
             printf -v str1 " %2d) %b%-15s%b - %-35s" "$((i+1))" "$TCG" "$key1" "$TCD" "$desc1"
        fi
        
        # Item 2
        local str2=""
        if [ $((i+1)) -lt $total ]; then
             local key2="${sorted_keys[$((i+1))]}"
             local desc2=""
             local stat2=""
             local stat2_color=""
             
             if [ "$type" == "docker" ]; then
                 IFS='|' read -r _ _ _ desc2 _ <<< "${DOCKER_PROJECTS[$key2]}"
                 if echo "$running_containers" | grep -q "^${key2}$"; then
                     stat2="[ON] "
                     stat2_color="$TCG"
                 else
                     stat2="[OFF]"
                     stat2_color="$TCR"
                 fi
             else
                 IFS='|' read -r _ desc2 <<< "${ONLINE_PROJECTS[$key2]}"
             fi
             
             desc2="${desc2:0:30}"
             
             if [ "$type" == "docker" ]; then
                  printf -v str2 " %2d) %b%-16s%b %b%s%b - %-30s" "$((i+2))" "$TCG" "$key2" "$TCD" "$stat2_color" "$stat2" "$TCD" "$desc2"
             else
                  desc2="${desc2:0:35}" # Re-expand for online
                  printf -v str2 " %2d) %b%-15s%b - %-35s" "$((i+2))" "$TCG" "$key2" "$TCD" "$desc2"
             fi
        fi
        
        # Print combined line
        echo -e "${str1}   ${str2}"
        i=$((i+2))
    done
}

select_project() {
    local type=$1 # "docker" or "online"
    local prompt_msg=${2:-"Select a project (number or name): "}
    local selected_var=$3 # Name of variable to store result name

    # Header
    if [ "$type" == "docker" ]; then
        echo -e "$TCC Available Docker Projects:$TCD"
    else
        echo -e "$TCC Available Online Projects:$TCD"
    fi

    print_menu_items "$type"

    printf " %2d) %bBack / Cancel%b\n" "0" "$TCR" "$TCD"
    echo ""

    # Need to rebuild keys array for selection logic mapping
    # (Checking against array size)
    if [ "$type" == "docker" ]; then
        local count=${#DOCKER_PROJECTS[@]}
    else
        local count=${#ONLINE_PROJECTS[@]}
    fi

    # Read Input
    local selection
    read -r -p "$prompt_msg" selection

    # 1. Empty Input or 0
    if [ -z "$selection" ] || [ "$selection" == "0" ]; then
        return 1
    fi

    # 2. Number Input
    if [[ "$selection" =~ ^[0-9]+$ ]]; then
        if [ "$selection" -ge 1 ] && [ "$selection" -le "$count" ]; then
            # We need the sorted key at this index
            if [ "$type" == "docker" ]; then
                mapfile -t sorted_keys < <(for k in "${!DOCKER_PROJECTS[@]}"; do echo "$k"; done | sort)
            else
                mapfile -t sorted_keys < <(for k in "${!ONLINE_PROJECTS[@]}"; do echo "$k"; done | sort)
            fi
            local real_index=$((selection-1))
            eval "$selected_var='${sorted_keys[$real_index]}'"
            return 0
        fi
    fi



    # 3. Name Input
    if [ "$type" == "docker" ]; then
        if [[ -n "${DOCKER_PROJECTS[$selection]+x}" ]]; then
            eval "$selected_var='$selection'"
            return 0
        fi
    else
        if [[ -n "${ONLINE_PROJECTS[$selection]+x}" ]]; then
            eval "$selected_var='$selection'"
            return 0
        fi
    fi

    echo -e "$TCR Invalid selection '$selection'. Please try again. $TCD"
    return 1
}
