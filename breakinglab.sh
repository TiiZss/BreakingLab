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
source "$DIR/lib/stack.sh"
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
    IFS='|' read -r image ip port desc url start_info compose_path _ _ <<< "${DOCKER_PROJECTS[$proj]}"
    if [ -n "${compose_path:-}" ] && [[ "$compose_path" != /* ]]; then
        compose_path="$DIR/$compose_path"
    fi
    image="$(bl_pin_image "$image")"
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
             local compose_file="docker-compose.yml"
             if [ -f "$compose_path/.build/docker-compose.yml" ]; then
                 compose_file=".build/docker-compose.yml"
             elif [ -f "$compose_path/docker-compose.yaml" ]; then
                 compose_file="docker-compose.yaml"
             fi
             bl_compose "$proj" "$compose_path" "$compose_file" up -d || { echo -e "$TCR Docker Compose failed $TCD"; return 1; }
        fi
    else
        echo "Checking if container $proj exists..."
        # || true to prevent failure if grep finds nothing (though -q usually handles it, pipefail catches grep failure)
        local container_exists
        # Check for breakinglab_<proj> first (new convention), then fallback to <proj> (legacy)
        if [ -n "$(docker ps -aq -f "name=^${proj}_")" ]; then
            container_exists="${proj}"
        elif [ -n "$(docker ps -aq -f "name=^breakinglab_${proj}$")" ]; then
            container_exists="breakinglab_${proj}"
        elif [ -n "$(docker ps -aq -f "name=^${proj}$")" ]; then
             container_exists="${proj}"
        else
             container_exists=""
        fi
        
        if [ -n "$container_exists" ]; then
            echo "Container $container_exists exists. Starting..."
            local id started=0
            while IFS= read -r id; do
                [ -z "$id" ] && continue
                docker start "$id" >/dev/null || return 1
                started=1
            done < <(docker ps -aq -f "name=^${proj}_")
            if [ "$started" -eq 0 ]; then
                docker start "$container_exists" >/dev/null || return 1
            fi
            echo "Started."
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
                docker run --name "${proj}_app" --label "com.docker.compose.project=breakinglab_${proj}" --label "com.docker.compose.service=${proj}" --label "breakinglab.lab=${proj}" -d -p "${BREAKINGLAB_BIND:-$ip}:${BREAKINGLAB_PORT:-$port}:$port" "$image"
            fi
        fi
        
        # Validation Loop
        echo "Waiting for $proj..."
        local timeout=60
        local elapsed=0
        while [ -z "$(docker ps -q -f "name=^${proj}_")" ] && [ -z "$(docker ps -q -f "name=^breakinglab_${proj}$")" ] && [ -z "$(docker ps -q -f "name=^${proj}$")" ]; do
            sleep 1
            elapsed=$((elapsed + 1))
            [ "$elapsed" -ge "$timeout" ] && { echo -e "$TCR Timeout awaiting start $TCD"; return 1; }
        done
        local probe_ip="$ip"
        local probe_port="$port"
        if [ -n "${BREAKINGLAB_BIND:-}" ]; then
            if [ "$BREAKINGLAB_BIND" = "0.0.0.0" ]; then
                probe_ip="127.0.0.1"
            else
                probe_ip="$BREAKINGLAB_BIND"
            fi
            probe_port="${BREAKINGLAB_PORT:-$port}"
        fi
        echo "Checking port $probe_port..."
        while ! nc -z "$probe_ip" "$probe_port" 2>/dev/null; do
             sleep 1
             elapsed=$((elapsed + 1))
             [ "$elapsed" -ge "$timeout" ] && { echo -e "$TCR Timeout awaiting port $TCD"; return 1; }
        done
        
        echo "Container $proj is running at $url"
    fi
    if [ -n "${BREAKINGLAB_BIND:-}" ]; then
        local class_ip="127.0.0.1"
        local class_path
        bl_show_public_urls "$proj" "$url"
        [ "$BREAKINGLAB_BIND" != "0.0.0.0" ] && class_ip="$BREAKINGLAB_BIND"
        class_path="$(printf '%s\n' "$url" | sed -E 's#^https?://[^/]*##')"
        url="http://${class_ip}:${BREAKINGLAB_PORT:-$port}${class_path}"
    fi
    echo "DONE! Available at $url"
    echo -e "$start_info"
    if [ "${BREAKINGLAB_BATCH:-}" != 1 ]; then
        open_url "$url"
        read -n 1 -s -r -p "Press key to continue..."
    fi
}

bl_other_running_labs() {
    local wanted="$1"
    local key
    for key in "${!DOCKER_PROJECTS[@]}"; do
        [ "$key" = "$wanted" ] && continue
        if [ "$(docker_lab_state "$key")" != "down" ]; then
            printf '%s\n' "$key"
        fi
    done | sort
}

bl_public_make_room() {
    local proj="$1"
    local running=()
    local key answer
    while IFS= read -r key; do
        [ -z "$key" ] && continue
        running+=("$key")
    done < <(bl_other_running_labs "$proj")
    [ "${#running[@]}" -eq 0 ] && return 0

    echo -e "$TCY En público solo puede haber una máquina. En marcha: ${running[*]}. $TCD"
    if [ "${BREAKINGLAB_BATCH:-}" = 1 ]; then
        echo "No se arranca $proj."
        return 1
    fi
    read -r -p "¿Apagar ${running[*]} y levantar ${proj}? (s/N) " answer
    case "$answer" in
        s|S|y|Y) ;;
        *) echo "Se queda ${running[*]}."; return 1 ;;
    esac
    for key in "${running[@]}"; do
        bl_compose_down "$key"
        echo -e "$key --> $TCR apagada $TCD"
    done
}

start_public_project() {
    local proj="${1:-}"
    local public_ip="${2:-0.0.0.0}"
    local public_port="${3:-}"

    if [ -z "$proj" ]; then
        select_project "docker" "Máquina pública (número o nombre): " proj || return 0
    fi

    if [[ -z "${DOCKER_PROJECTS[$proj]+x}" ]]; then
        echo -e "$TCR Project '$proj' not found $TCD"
        return 1
    fi
    if ! bl_public_make_room "$proj"; then
        return 1
    fi

    echo -e "$TCG Starting Public Access for $proj on ${public_ip} $TCD"
    bl_compose_down "$proj"
    export BREAKINGLAB_BIND="$public_ip"
    if [ -n "$public_port" ]; then
        export BREAKINGLAB_PORT="$public_port"
    else
        unset BREAKINGLAB_PORT
    fi
    if ! start_docker_project "$proj"; then
        unset BREAKINGLAB_BIND BREAKINGLAB_PORT
        return 1
    fi
    unset BREAKINGLAB_BIND BREAKINGLAB_PORT
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
    IFS='|' read -r image ip port desc url start_info compose_path _ _ <<< "${DOCKER_PROJECTS[$proj]}"
    if [ -n "${compose_path:-}" ] && [[ "$compose_path" != /* ]]; then
        compose_path="$DIR/$compose_path"
    fi

    bl_compose_down "$proj"
    if [ -n "${compose_path:-}" ]; then
        if [ -f "$compose_path" ]; then
             pushd "$(dirname "$compose_path")" >/dev/null
             docker compose -p "breakinglab_${proj}" -f "$(basename "$compose_path")" down >/dev/null 2>&1 || true
             docker compose -f "$(basename "$compose_path")" down >/dev/null 2>&1 || true
             popd >/dev/null
        elif [ -d "$compose_path" ]; then
             local compose_file="docker-compose.yml"
             if [ -f "$compose_path/.build/docker-compose.yml" ]; then
                 compose_file=".build/docker-compose.yml"
             fi
             pushd "$compose_path" >/dev/null
             docker compose -p "breakinglab_${proj}" -f "$compose_file" down >/dev/null 2>&1 || true
             docker compose -f "$compose_file" down >/dev/null 2>&1 || true
             popd >/dev/null
        fi
        echo -e "$proj --> $TCR stack stopped $TCD"
    else
        # Try stopping new convention name first, then legacy
        docker rm -f "breakinglab_$proj" >/dev/null 2>&1 || true
        docker rm -f "$proj" >/dev/null 2>&1 || true
        echo -e "$proj --> $TCR container stopped $TCD"
        remove_host "$ip" "$proj"
    fi
    if [ "${BREAKINGLAB_BATCH:-}" != 1 ]; then
        read -n 1 -s -r -p "Press key to continue..."
    fi
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
     local where=""
     
     case "$(docker_lab_state "$proj")" in
         running)
             status_text="running"
             status_color="$TCG"
             where="$ip:$port"
             ;;
         stack|legacy)
             status_text="running (stack)"
             status_color="$TCG"
             where="$ip:$port"
             ;;
         namelegacy)
             status_text="running (legacy)"
             status_color="$TCY"
             where="$ip:$port"
             ;;
     esac
     
     printf "%b%-55s %b%-18s%b %s\n" "$TCC" "$desc ($proj)" "$status_color" "$status_text" "$TCD" "$where"
}

update_breakinglab() {
    echo -e "$TCC Updating BreakingLab... $TCD"
    if [ -d ".git" ]; then
        git pull origin main || { echo -e "$TCR Update failed $TCD"; return 1; }
        echo -e "$TCG Update successful. Restarting... $TCD"
        sleep 1
        exec "$0"
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
    read -r -p "Choice [1]: " p_type_choice
    local p_type="${p_type_choice:-1}"
    
    if [ "$p_type" == "3" ]; then
        import_github_project
        return
    fi
    
    read -r -p "Project Slug (e.g. my-app): " p_slug
    [[ -z "$p_slug" ]] && return 0
    if [[ -n "${DOCKER_PROJECTS[$p_slug]+x}" ]]; then
        echo -e "$TCR Project $p_slug already exists! $TCD"
        return 0
    fi
    
    local p_image=""
    local p_compose=""
    
    if [ "$p_type" == "2" ]; then
        read -r -p "Absolute Path to Compose Folder: " p_compose
        if [ ! -d "$p_compose" ] && [ ! -f "$p_compose" ]; then
            echo -e "$TCR Path does not exist. $TCD"
            return 0
        fi
        # Default image placeholder for config format compatibility
        p_image="docker-compose"
    else
        read -r -p "Docker Image Name: " p_image
    fi
    
    
    read -r -p "Main Service Port (for browser checking): " p_port
    
    # Auto-assign IP
    echo "Finding available IP..."
    local p_ip
    p_ip=$(get_next_available_ip)
    echo -e "Assigned IP: $TCG$p_ip$TCD"
    
    read -r -p "Description: " p_desc
    read -r -p "Start Info Message: " p_info
    
    # Construct config string
    # "image|ip|port|desc|http://ip|info|compose_path|pre|post"
    local p_url="http://${p_ip}"
    [ -n "$p_port" ] && [ "$p_port" != "80" ] && p_url="${p_url}:${p_port}"
    
    # Write to file
    local config_file="${DIR}/config/projects.d/docker_${p_slug}.conf"
    echo "DOCKER_PROJECTS[\"$p_slug\"]=\"$p_image|$p_ip|$p_port|$p_desc|$p_url|$p_info|$p_compose||\"" > "$config_file"
    
    # Reload config
    # shellcheck disable=SC1090
    source "$config_file"
    echo -e "$TCG Project $p_slug added successfully! $TCD"
    read -n 1 -s -r -p "Press key to continue..."
}

# --- GitHub Import Function ---

import_github_project() {
    echo -e "$TCW GitHub Import Wizard $TCD"
    
    # 1. Get URL and Path
    read -r -p "GitHub Repository URL: " repo_url
    [ -z "$repo_url" ] && return 0
    
    local default_slug
    default_slug=$(basename "$repo_url" .git)
    read -r -p "Project Slug / Folder Name (default: $default_slug): " p_slug
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
        read -r -p "Path to docker-compose file (relative to $projects_dir/$p_slug): " rel_path
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
    local found_ports
    found_ports=$(grep -oP "^\s*-\s*\"\d+:\d+\"" "$compose_file" | tr -d ' "-' | cut -d: -f1 | tr '\n' ' ')
    local default_port
    if [ -n "$found_ports" ]; then
        echo -e "Found ports: $TCY $found_ports $TCD"
        default_port=$(echo "$found_ports" | awk '{print $1}')
    else
        echo "No explicit exposed ports found in standard format."
        default_port="80"
    fi
    
    read -r -p "Main Service Port (default: $default_port): " p_port
    p_port="${p_port:-$default_port}"
    
    # 4. Auto-IP
    echo "Assigning IP..."
    local p_ip
    p_ip=$(get_next_available_ip)
    echo -e "Assigned IP: $TCG$p_ip$TCD"
    
    # --- SANITIZE COMPOSE ---
    sanitize_compose "$compose_file" "$p_ip" "$p_port"
    
    # --- FETCH DESCRIPTION ---
    echo "Fetching repository details..."

    # Extract Owner/Repo from URL
    # Supports: https://github.com/owner/repo or git@github.com:owner/repo.git
    local gh_repo_path
    gh_repo_path=$(echo "$repo_url" | sed -E 's/.*github.com[:/](.*)(\.git)?/\1/' | sed 's/\.git$//')
    
    local gh_desc=""
    if [ -n "$gh_repo_path" ]; then
        local api_url="https://api.github.com/repos/${gh_repo_path}"
        # Fetch JSON, try to extract description field
        # Using grep/sed fallback since jq might not be installed
        gh_desc=$(curl -s "$api_url" | grep '"description":' | sed -E 's/.*"description": "(.*)",/\1/' | sed 's/\\"/\"/g')
    fi
    
    if [ -n "$gh_desc" ] && [ "$gh_desc" != "null" ]; then
         echo -e "Found Description: $TCC $gh_desc $TCD"
         read -r -p "Description (default: imported): " p_desc_input
         p_desc="${p_desc_input:-$gh_desc}"
    else 
         read -r -p "Description: " p_desc
    fi
    
    # Sanitize description to remove newlines and pipes
    p_desc=$(echo "$p_desc" | tr -d '\n' | tr '|' '-')

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
    
    # shellcheck disable=SC1090
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
    
    read -r -p "Are you sure? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Deletion cancelled."
        return 0
    fi

    # Retrieve info for remove_host before deletion
    IFS='|' read -r image ip port desc url start_info compose_path _ _ <<< "${DOCKER_PROJECTS[$proj]}"

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
    unset "DOCKER_PROJECTS[$proj]"

    echo -e "$TCG Project '$proj' has been deleted. $TCD"
    read -n 1 -s -r -p "Press key to continue..."
}

# Arranca o para cada laboratorio en la IP de su ficha. Un fallo no corta el resto.
_each_docker_project() {
    local action="$1"
    local proj ok=0 fail=0
    local -a projects=()

    check_docker
    while IFS= read -r proj; do
        [ -n "$proj" ] && projects+=("$proj")
    done < <(printf '%s\n' "${!DOCKER_PROJECTS[@]}" | sort)

    for proj in "${projects[@]}"; do
        echo "---- $proj ----"
        if command -v timeout >/dev/null 2>&1; then
            if env BREAKINGLAB_BATCH=1 timeout -k 20 600 bash "$0" "$action" "$proj"; then
                ok=$((ok + 1))
            else
                fail=$((fail + 1))
                echo "Sin completar: $proj"
            fi
        elif env BREAKINGLAB_BATCH=1 bash "$0" "$action" "$proj"; then
            ok=$((ok + 1))
        else
            fail=$((fail + 1))
            echo "Sin completar: $proj"
        fi
    done

    echo "Completados: $ok. Sin completar: $fail."
    if [ "$action" = "start" ]; then
        for proj in "${projects[@]}"; do
            status_docker_project "$proj"
        done
    fi
}

up_all() { _each_docker_project start; }

# Cada máquina es un stack breakinglab_<clave>. Esto apaga todos. Un contenedor ajeno no lleva la etiqueta.
down_all() {
    check_docker
    local id project n=0
    while IFS= read -r id; do
        [ -z "$id" ] && continue
        docker rm -f "$id" >/dev/null 2>&1 || true
        n=$((n + 1))
    done < <(docker ps -aq --filter "label=breakinglab.lab")
    while IFS= read -r id; do
        [ -z "$id" ] && continue
        docker rm -f "$id" >/dev/null 2>&1 || true
        n=$((n + 1))
    done < <(docker ps -aq --filter "label=com.docker.compose.project=${STACK_NAME}")
    while IFS= read -r id; do
        [ -z "$id" ] && continue
        project="$(docker network inspect -f '{{index .Labels "com.docker.compose.project"}}' "$id" 2>/dev/null || true)"
        case "$project" in
            breakinglab|breakinglab_*) docker network rm "$id" >/dev/null 2>&1 || true ;;
        esac
    done < <(docker network ls -q)
    echo "Stacks breakinglab_* apagados. Contenedores parados: $n."
}

# --- Menu & Entry Point ---

main_menu() {
    display_logo
    echo -e "$TCC Options: $TCD\n1) List Projects\n2) Start Docker Project\n3) Start one lab on the classroom network\n4) Stop Docker Project\n5) Status Docker Projects\n6) Start Online Project\n7) Update\n8) Add New Project\n9) Delete Project\n10) Start all labs\n11) Stop all labs\n99) Exit"
    read -r -p "Select an option: " choice
    case $choice in
        1) list_projects; read -n 1 -s -r -p "Press key..." ; main_menu;;
        2) 
           start_docker_project
           main_menu;;
        3)
           start_public_project || true
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
        10) up_all; read -n 1 -s -r -p "Press key to continue..."; main_menu;;
        11) down_all; read -n 1 -s -r -p "Press key to continue..."; main_menu;;
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
        up) up_all;;
        down) down_all;;
        online) start_online_project "${2:-}";;
        update) update_breakinglab;;
        delete) delete_project "${2:-}";;
        *) echo "Usage: $0 {list|start|startpublic|stop|status|up|down|online|delete|update} [project] [ip] [port]";;
    esac
fi
