#!/bin/bash
# BreakingLab Refactored

# Safety first
set -euo pipefail

# Import Libraries and Config
# Resolve symbolic links to find the real directory
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do 
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" 
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

source "$DIR/lib/colors.sh"
source "$DIR/lib/utils.sh"
source "$DIR/lib/hosts.sh"
source "$DIR/lib/menu.sh"
source "$DIR/config/projects.conf"

# Initialization
check_dependencies

# --- Main Logic Functions ---

start_docker_project() {
    local proj="${1:-}"
    # If no project provided, ask using menu
    if [ -z "$proj" ]; then
        select_project "docker" "Start Docker Project (enter number or name): " proj || return 0
    fi

    if [[ -z "${DOCKER_PROJECTS[$proj]+x}" ]]; then
        echo -e "$TCR Project '$proj' not found in DOCKER_PROJECTS $TCD"
        return 1
    fi
    check_docker
    IFS='|' read -r image ip port desc url start_info compose_path pre_commands post_commands <<< "${DOCKER_PROJECTS[$proj]}"
    echo "Starting $desc"
    add_host "$ip" "$proj"
    [ -n "${pre_commands:-}" ] && eval "$pre_commands"

    if [ -n "${compose_path:-}" ]; then
        [ -d "$compose_path" ] || { echo "Error: $compose_path not found"; return 1; }
        eval "$post_commands"
    else
        echo "Checking if container $proj exists..."
        # || true to prevent failure if grep finds nothing (though -q usually handles it, pipefail catches grep failure)
        local container_exists
        container_exists=$(docker ps -a -q -f "name=^$proj$" || true)
        
        if [ -n "$container_exists" ]; then
            echo "Container $proj exists. Starting..."
            docker start "$proj" >/dev/null && echo "Started." || { echo -e "$TCR Failed to start $proj $TCD"; return 1; }
        else
            echo "Creating container $proj..."
            if [ -n "${post_commands:-}" ]; then
                eval "$post_commands"
            else
                docker run --name "$proj" --label "com.docker.compose.project=BreakingLab" -d -p "$ip:$port:$port" "$image"
            fi
        fi
        
        # Validation Loop
        echo "Waiting for $proj..."
        local timeout=60
        local elapsed=0
        while ! docker ps -q -f "name=^$proj$" >/dev/null; do
            sleep 1; ((elapsed++))
            [ "$elapsed" -ge "$timeout" ] && { echo -e "$TCR Timeout awaiting start $TCD"; return 1; }
        done
        echo "Checking port $port..."
        while ! nc -z "$ip" "$port" 2>/dev/null; do
             sleep 1; ((elapsed++))
             [ "$elapsed" -ge "$timeout" ] && { echo -e "$TCR Timeout awaiting port $TCD"; return 1; }
        done
        
        echo "Container $proj is running at $url"
    fi
    echo "DONE! Available at $url"
    echo -e "$start_info"
    open_url "$url"
    read -n 1 -s -r -p "Press key to continue..."
}

start_public_project() {
    local proj="${1:-}"
    local public_ip="${2:-0.0.0.0}" # Default to all interfaces
    local public_port="${3:-}"      # Default to configured port if empty

    # If no project provided, ask using menu
    if [ -z "$proj" ]; then
        select_project "docker" "Start Public Project (enter number or name): " proj || return 0
        
        read -p "Enter Bind IP (default 0.0.0.0): " input_ip
        [ -n "$input_ip" ] && public_ip="$input_ip"
        
        read -p "Enter Public Port (leave empty for default): " input_port
        [ -n "$input_port" ] && public_port="$input_port"
    fi

    if [[ -z "${DOCKER_PROJECTS[$proj]+x}" ]]; then
        echo -e "$TCR Project '$proj' not found $TCD"
        return 1
    fi
    check_docker
    IFS='|' read -r image ip internal_port desc url start_info compose_path pre_commands post_commands <<< "${DOCKER_PROJECTS[$proj]}"
    
    # Use internal port if public port not specified
    if [ -z "$public_port" ]; then
        public_port=$internal_port
    fi

    echo -e "$TCG Starting Public Access for $desc $TCD"
    echo -e "Binding to $public_ip:$public_port"

    [ -n "${pre_commands:-}" ] && eval "$pre_commands"

    if [ -n "${compose_path:-}" ]; then
        echo -e "$TCW Note: Public start for Compose stacks requires manual yaml editing or overrides. $TCD"
        [ -d "$compose_path" ] || { echo "Error: $compose_path not found"; return 1; }
        eval "$post_commands"
    else
        # Stop existing instance if it conflicts
        # || true because grep might return 1
        if docker ps -a --format '{{.Names}}' | grep -q "^$proj$"; then
             echo "Stopping and removing existing private instance..."
             docker rm -f "$proj" >/dev/null
        fi

        echo "Running public container..."
        if [ -n "${post_commands:-}" ]; then
             echo -e "$TCY Executing custom start command. Public binding might depend on hardcoded values in the command. $TCD"
             eval "$post_commands" 
        else
             docker run --name "$proj" --label "com.docker.compose.project=BreakingLab" -d -p "$public_ip:$public_port:$internal_port" "$image"
        fi
    fi

    echo -e "$TCG Public instance started! Access via http://$public_ip:$public_port (or your server LAN IP) $TCD"
    read -n 1 -s -r -p "Press key to continue..."
}

stop_docker_project() {
    local proj="${1:-}"
    
    if [ -z "$proj" ]; then
        # For stop, maybe we only want running projects? 
        # But for now, showing all is consistent, or we can improve selection logic later to filter running.
        # Let's keep consistent: select from all projects.
        select_project "docker" "Stop Project (enter number or name): " proj || return 0
    fi

    [ -z "$proj" ] && { echo -e "$TCR No project name $TCD"; return 1; }
    [[ -z "${DOCKER_PROJECTS[$proj]+x}" ]] && { echo -e "$TCR Project '$proj' not found $TCD"; return 1; }
    
    check_docker >/dev/null 2>&1
    IFS='|' read -r image ip port desc url start_info compose_path pre_commands post_commands <<< "${DOCKER_PROJECTS[$proj]}"

    if [ -n "${compose_path:-}" ]; then
        if [ -f "$compose_path" ]; then
             pushd "$(dirname "$compose_path")" >/dev/null && docker compose -f "$(basename "$compose_path")" down >/dev/null 2>&1 && popd >/dev/null
        elif [ -d "$compose_path" ]; then
             pushd "$compose_path" >/dev/null && docker compose down >/dev/null 2>&1 && popd >/dev/null
        fi
        echo -e "$proj --> $TCR stack stopped $TCD"
    else
        docker stop "$proj" >/dev/null 2>&1 && docker rm "$proj" >/dev/null 2>&1
        echo -e "$proj --> $TCR container stopped $TCD"
        remove_host "$ip" "$proj"
    fi
    read -n 1 -s -r -p "Press key to continue..."
}

start_online_project() {
    local proj="${1:-}"
    
    if [ -z "$proj" ]; then
        select_project "online" "Start Online Project (enter number or name): " proj || return 0
    fi

    if [[ -z "${ONLINE_PROJECTS[$proj]+x}" ]]; then
        echo -e "$TCR Project '$proj' not found $TCD"
        return 1
    fi
    IFS='|' read -r url desc <<< "${ONLINE_PROJECTS[$proj]}"
    echo -e "$TCR Opening --> $TCD $desc"
    sleep 2
    open_url "$url"
}

list_projects() {
    echo -e "$TCC Available Docker Projects $TCD"
    print_menu_items "docker"
    
    echo -e "$TCC Available Online Projects $TCD"
    print_menu_items "online"
}

status_docker_project() {
     local proj="${1:-}"
     [[ -z "${DOCKER_PROJECTS[$proj]+x}" ]] && return
     IFS='|' read -r image ip port desc url rest <<< "${DOCKER_PROJECTS[$proj]}"
     local status_text="not running"
     local status_color="$TCR"
     
     if docker ps --format '{{.Names}}' | grep -q "^$proj$"; then
         status_text="running"
         status_color="$TCG"
     fi
     
     printf "%b%-55s %b%-12s%b\n" "$TCC" "$desc ($proj)" "$status_color" "$status_text" "$TCD"
}


# --- Menu & Entry Point ---

main_menu() {
    display_logo
    echo -e "$TCC Options: $TCD\n1) List Projects\n2) Start Docker Project\n3) Start Public Project\n4) Stop Docker Project\n5) Status Docker Projects\n6) Start Online Project\n99) Exit"
    read -p "Select an option: " choice
    case $choice in
        1) list_projects; read -n 1 -s -r -p "Press key..." ; main_menu;;
        2) 
           start_docker_project
           main_menu;;
        3)
           start_public_project
           main_menu;;
        4) 
           stop_docker_project
           main_menu;;
        5) 
           for proj in "${!DOCKER_PROJECTS[@]}"; do status_docker_project "$proj"; done
           read -n 1 -s -r -p "Press key to continue..."
           main_menu;;
        6)
           start_online_project
           main_menu;;
        99) exit 0;;
        *) main_menu;;
    esac
}

if [ $# -eq 0 ]; then
    main_menu
else
    # shift arguments handling if we were to process flags, but direct mapping is fine
    case "$1" in
        list) list_projects;;
        start) start_docker_project "${2:-}";;
        startpublic) start_public_project "${2:-}" "${3:-}" "${4:-}";;
        stop) stop_docker_project "${2:-}";;
        status) for proj in "${!DOCKER_PROJECTS[@]}"; do status_docker_project "$proj"; done;;
        online) start_online_project "${2:-}";;
        *) echo "Usage: $0 {list|start|startpublic|stop|status|online} [project] [ip] [port]";;
    esac
fi
