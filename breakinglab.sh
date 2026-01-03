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
source "$DIR/lib/yaml_utils.sh"
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
    execute_hook "${proj}_pre"

    if [ -n "${compose_path:-}" ]; then
        [ -d "$compose_path" ] || { echo "Error: $compose_path not found"; return 1; }
        
        local hook_script="${DIR}/scripts/hooks/${proj}_post.sh"
        if [ -f "$hook_script" ]; then
             execute_hook "${proj}_post"
        else
             echo "Starting Docker Compose project..."
             pushd "$compose_path" >/dev/null
             # Use project name to ensure isolation and consistent naming
             docker compose -p "breakinglab_${proj}" up -d || { echo -e "$TCR Docker Compose failed $TCD"; popd >/dev/null; return 1; }
             popd >/dev/null
        fi
    else
        echo "Checking if container $proj exists..."
        # || true to prevent failure if grep finds nothing (though -q usually handles it, pipefail catches grep failure)
        local container_exists
        # Check for breakinglab_<proj> first (new convention), then fallback to <proj> (legacy)
        if docker ps -a -q -f "name=^breakinglab_${proj}$" >/dev/null; then
            container_exists="breakinglab_${proj}"
        elif docker ps -a -q -f "name=^${proj}$" >/dev/null; then
             container_exists="${proj}"
        else
             container_exists=""
        fi
        
        if [ -n "$container_exists" ]; then
            echo "Container $container_exists exists. Starting..."
            docker start "$container_exists" >/dev/null && echo "Started." || { echo -e "$TCR Failed to start $container_exists $TCD"; return 1; }
        else
            echo "Creating container $proj..."
            execute_hook "${proj}_post"
            # Fallback if no hook but we want to confirm (though logic implies hook handles creation if present in old config)
            # In old config, post_commands usually did "docker-compose up" OR nothing.
            # If we don't have a hook for post, do we run default docker run?
            # The python script created hooks for ALL non-empty post_commands.
            # So if post_commands was empty, hook won't exist, and execute_hook returns silently.
            # BUT we need to know if we should run default logic.
            # Original logic: if [ -n post_commands ] then eval else docker run.
            # We can check if hook file exists using the same logic as execute_hook or check strict file existence here.
            
            if [ -f "${DIR}/scripts/hooks/${proj}_post.sh" ]; then
                : # Hook executed above
            else
                # Enforce naming convention: breakinglab_<slug>
                # Also ensure it's grouped under BreakingLab stack in Docker Desktop
                docker run --name "breakinglab_${proj}" --label "com.docker.compose.project=BreakingLab" -d -p "$ip:$port:$port" "$image"
            fi
        fi
        
        # Validation Loop
        echo "Waiting for $proj..."
        local timeout=60
        local elapsed=0
        while ! docker ps -q -f "name=^breakinglab_${proj}$" >/dev/null && ! docker ps -q -f "name=^${proj}$" >/dev/null; do
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
        if docker ps -a --format '{{.Names}}' | grep -q "^breakinglab_$proj$"; then
             echo "Stopping and removing existing private instance..."
             docker rm -f "breakinglab_$proj" >/dev/null
        elif docker ps -a --format '{{.Names}}' | grep -q "^$proj$"; then
             echo "Stopping and removing existing private instance (legacy)..."
             docker rm -f "$proj" >/dev/null
        fi

        echo "Running public container..."
        echo "Running public container..."
        if [ -f "${DIR}/scripts/hooks/${proj}_post.sh" ]; then
             echo -e "$TCY Executing custom start command. Public binding might depend on hardcoded values in the command. $TCD"
             # Warn user that public binding IP override might not work if hook hardcodes it
             execute_hook "${proj}_post"
        else
             docker run --name "breakinglab_$proj" --label "com.docker.compose.project=BreakingLab" -d -p "$public_ip:$public_port:$internal_port" "$image"
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
             pushd "$(dirname "$compose_path")" >/dev/null && docker compose -p "breakinglab_${proj}" -f "$(basename "$compose_path")" down >/dev/null 2>&1 && popd >/dev/null
        elif [ -d "$compose_path" ]; then
             pushd "$compose_path" >/dev/null && docker compose -p "breakinglab_${proj}" down >/dev/null 2>&1 && popd >/dev/null
        fi
        echo -e "$proj --> $TCR stack stopped $TCD"
    else
        # Try stopping new convention name first, then legacy
        docker stop "breakinglab_$proj" >/dev/null 2>&1 && docker rm "breakinglab_$proj" >/dev/null 2>&1
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
     
     if docker ps --format '{{.Names}}' | grep -q "^breakinglab_$proj$"; then
         status_text="running"
         status_color="$TCG"
     elif docker ps -q --filter "label=com.docker.compose.project=breakinglab_${proj}" | grep -q .; then
         # Check if ANY container with the project label exists
         status_text="running (stack)"
         status_color="$TCG"
     elif docker ps --format '{{.Names}}' | grep -q "^$proj$"; then
          status_text="running (legacy)"
          status_color="$TCY"
     fi
     
     printf "%b%-55s %b%-12s%b\n" "$TCC" "$desc ($proj)" "$status_color" "$status_text" "$TCD"
}

update_breakinglab() {
    echo -e "$TCC Updating BreakingLab... $TCD"
    if [ -d ".git" ]; then
        git pull origin main || { echo -e "$TCR Update failed $TCD"; return 1; }
        echo -e "$TCG Update successful. Restarting... $TCD"
        sleep 1
        exec "$0" "$@"
    else
        echo -e "$TCR Not a git repository. Cannot auto-update. $TCD"
        return 1
    fi
}


add_new_project() {
    echo -e "$TCW BreakingLab Project Wizard $TCD"
    
    echo "Select Project Type:"
    echo "1) Manual - Docker Image (Single Container)"
    echo "2) Manual - Docker Compose (Stack)"
    echo "3) Import from GitHub"
    read -p "Choice [1]: " p_type_choice
    local p_type="${p_type_choice:-1}"
    
    if [ "$p_type" == "3" ]; then
        import_github_project
        return
    fi
    
    read -p "Project Slug (e.g. my-app): " p_slug
    [[ -z "$p_slug" ]] && return 0
    if [[ -n "${DOCKER_PROJECTS[$p_slug]+x}" ]]; then
        echo -e "$TCR Project $p_slug already exists! $TCD"
        return 0
    fi
    
    local p_image=""
    local p_compose=""
    
    if [ "$p_type" == "2" ]; then
        read -p "Absolute Path to Compose Folder: " p_compose
        if [ ! -d "$p_compose" ] && [ ! -f "$p_compose" ]; then
            echo -e "$TCR Path does not exist. $TCD"
            return 0
        fi
        # Default image placeholder for config format compatibility
        p_image="docker-compose"
    else
        read -p "Docker Image Name: " p_image
    fi
    
    
    read -p "Main Service Port (for browser checking): " p_port
    
    # Auto-assign IP
    echo "Finding available IP..."
    local p_ip=$(get_next_available_ip)
    echo -e "Assigned IP: $TCG$p_ip$TCD"
    
    read -p "Description: " p_desc
    read -p "Start Info Message: " p_info
    
    # Construct config string
    # "image|ip|port|desc|http://ip|info|compose_path|pre|post"
    local p_url="http://${p_ip}"
    [ -n "$p_port" ] && [ "$p_port" != "80" ] && p_url="${p_url}:${p_port}"
    
    # Write to file
    local config_file="${DIR}/config/projects.d/docker_${p_slug}.conf"
    echo "DOCKER_PROJECTS[\"$p_slug\"]=\"$p_image|$p_ip|$p_port|$p_desc|$p_url|$p_info|$p_compose||\"" > "$config_file"
    
    # Reload config
    source "$config_file"
    echo -e "$TCG Project $p_slug added successfully! $TCD"
    read -n 1 -s -r -p "Press key to continue..."
}

# --- GitHub Import Function ---

import_github_project() {
    echo -e "$TCW GitHub Import Wizard $TCD"
    
    # 1. Get URL and Path
    read -p "GitHub Repository URL: " repo_url
    [ -z "$repo_url" ] && return 0
    
    local default_slug=$(basename "$repo_url" .git)
    read -p "Project Slug / Folder Name (default: $default_slug): " p_slug
    p_slug="${p_slug:-$default_slug}"
    
    if [[ -n "${DOCKER_PROJECTS[$p_slug]+x}" ]]; then
        echo -e "$TCR Project $p_slug already exists! $TCD"
        return 0
    fi
    
    local projects_dir="${DIR}/projects"
    [ -d "$projects_dir" ] || mkdir -p "$projects_dir"
    local target_path="${projects_dir}/${p_slug}"
    
    if [ -d "$target_path" ]; then
        echo -e "$TCY Directory $target_path already exists. Using existing files... $TCD"
    else
        echo -e "$TCC Cloning $repo_url to $target_path... $TCD"
        git clone "$repo_url" "$target_path" || { echo -e "$TCR Clone failed. $TCD"; return 1; }
    fi
    
    # 2. Setup Compose
    local compose_file=""
    if [ -f "$target_path/docker-compose.yml" ]; then
        compose_file="$target_path/docker-compose.yml"
    elif [ -f "$target_path/docker-compose.yaml" ]; then
        compose_file="$target_path/docker-compose.yaml"
    else
        echo -e "$TCR No docker-compose.yml found in root. $TCD"
        read -p "Path to docker-compose file (relative to $projects_dir/$p_slug): " rel_path
        if [ -f "$target_path/$rel_path" ]; then
            compose_file="$target_path/$rel_path"
        else
            echo -e "$TCR File not found. You may need to configure manually. $TCD"
            return 1
        fi
    fi
    
    echo -e "$TCG Found compose file: $compose_file $TCD"
    
    # 3. Port Scanning
    echo "Scanning for ports..."
    local found_ports=$(grep -oP "^\s*-\s*\"\d+:\d+\"" "$compose_file" | tr -d ' "-' | cut -d: -f1 | tr '\n' ' ')
    if [ -n "$found_ports" ]; then
        echo -e "Found ports: $TCY $found_ports $TCD"
        local default_port=$(echo "$found_ports" | awk '{print $1}')
    else
        echo "No explicit exposed ports found in standard format."
        local default_port="80"
    fi
    
    read -p "Main Service Port (default: $default_port): " p_port
    p_port="${p_port:-$default_port}"
    
    # 4. Auto-IP
    echo "Assigning IP..."
    local p_ip=$(get_next_available_ip)
    echo -e "Assigned IP: $TCG$p_ip$TCD"
    
    # --- SANITIZE COMPOSE ---
    sanitize_compose "$compose_file" "$p_ip" "$p_port"
    
    read -p "Description: " p_desc
    local p_info="Imported from $repo_url"
    
    # 5. Save Config
    local p_url="http://${p_ip}"
    [ "$p_port" != "80" ] && p_url="${p_url}:${p_port}"
    
    # Prepare absolute path for config
    # We should store ABSOLUTE path in config to avoid CWD issues?
    # Or relative to DIR? Existing configs vary.
    # The existing logic in start_docker_project checks [ -d "$compose_path" ].
    # If we put absolute path, it should work fine.
    
    local config_file="${DIR}/config/projects.d/docker_${p_slug}.conf"
    # p_image is 'docker-compose' for type 2
    echo "DOCKER_PROJECTS[\"$p_slug\"]=\"docker-compose|$p_ip|$p_port|$p_desc|$p_url|$p_info|$target_path||\"" > "$config_file"
    
    source "$config_file"
    echo -e "$TCG Project $p_slug imported successfully! $TCD"
    read -n 1 -s -r -p "Press key to continue..."
}

# --- Delete Function ---

delete_project() {
    local proj="${1:-}"

    if [ -z "$proj" ]; then
        select_project "docker" "Delete Project (enter number or name): " proj || return 0
    fi

    if [[ -z "${DOCKER_PROJECTS[$proj]+x}" ]]; then
        echo -e "$TCR Project '$proj' not found in DOCKER_PROJECTS $TCD"
        return 1
    fi

    echo -e "$TCR WARNING: You are about to DELETE project '$proj'. $TCD"
    echo -e "This will:"
    echo -e "  - Stop and remove the Docker container/stack"
    echo -e "  - Remove the hosts entry"
    echo -e "  - DELETE the configuration file: ${DIR}/config/projects.d/docker_${proj}.conf"
    
    read -p "Are you sure? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Deletion cancelled."
        return 0
    fi

    # Retrieve info for remove_host before deletion
    IFS='|' read -r image ip port desc url start_info compose_path pre_commands post_commands <<< "${DOCKER_PROJECTS[$proj]}"

    # Stop the project first
    echo "Stopping project..."
    stop_docker_project "$proj"
    
    # Explicitly remove host entry (in case stop_docker_project skipped it)
    remove_host "$ip" "$proj"

    # Remove config file
    local config_file="${DIR}/config/projects.d/docker_${proj}.conf"
    if [ -f "$config_file" ]; then
        rm "$config_file"
        echo -e "$TCG Configuration file removed. $TCD"
    else
        echo -e "$TCY Configuration file not found at $config_file (skipping) $TCD"
    fi

    # Unset from current session array
    unset DOCKER_PROJECTS["$proj"]

    echo -e "$TCG Project '$proj' has been deleted. $TCD"
    read -n 1 -s -r -p "Press key to continue..."
}

# --- Menu & Entry Point ---

main_menu() {
    display_logo
    echo -e "$TCC Options: $TCD\n1) List Projects\n2) Start Docker Project\n3) Start Public Project\n4) Stop Docker Project\n5) Status Docker Projects\n6) Start Online Project\n7) Update\n8) Add New Project\n9) Delete Project\n99) Exit"
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
        7) update_breakinglab; main_menu;;
        8) add_new_project; main_menu;;
        9) delete_project; main_menu;;
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
        update) update_breakinglab;;
        delete) delete_project "${2:-}";;
        *) echo "Usage: $0 {list|start|startpublic|stop|status|online|delete|update} [project] [ip] [port]";;
    esac
fi
