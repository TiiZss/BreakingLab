#!/bin/bash

print_date() { stat -c %y "$0"; }

display_logo() {
    echo -e "-----------------------------------------------------------------------------------------"
    echo -e "$BGGreen               35$BGWhite$TCG                                       TiiZss  $TCW$BGGreen               57$BGWhite$TCG         $TCW"
    echo -e "$BGGreen ██████  ██████  $BGWhite$TCG ███████  █████  ██   ██ ██ ███    ██  ██████  $TCW$BGGreen ██       █████  $BGWhite$TCG ██████  $TCW"
    echo -e "$BGGreen ██   ██ ██   ██ $BGWhite$TCG ██      ██   ██ ██  ██  ██ ████   ██ ██       $TCW$BGGreen ██      ██   ██ $BGWhite$TCG ██   ██ $TCW"
    echo -e "$BGGreen ██████  ██████  $BGWhite$TCG █████   ███████ █████   ██ ██ ██  ██ ██   ███ $TCW$BGGreen ██      ███████ $BGWhite$TCG ██████  $TCW"
    echo -e "$BGGreen ██   ██ ██   ██ $BGWhite$TCG ██      ██   ██ ██  ██  ██ ██  ██ ██ ██    ██ $TCW$BGGreen ██      ██   ██ $BGWhite$TCG ██   ██ $TCW"
    echo -e "$BGGreen ██████  ██   ██ $BGWhite$TCG ███████ ██   ██ ██   ██ ██ ██   ████  ██████  $TCW$BGGreen ███████ ██   ██ $BGWhite$TCG ██████  $TCW"
    echo -e "$BGGreen                 $BGWhite$TCG v.$(print_date)         $TCW$BGGreen                 $BGWhite$TCG    BETA $TCW"
    echo -e "$TCD-----------------------------------------------------------------------------------------"
}

is_wsl() { [[ $(uname -r) =~ [Mm]icrosoft ]] && return 0 || return 1; }

open_url() {
    local url=$1
    if is_wsl; then
        if ! command -v wslview >/dev/null 2>&1; then
            echo -e "$TCC wslview not found. Adding wslu repository and installing wslu... $TCD"
            sudo apt update -y
            sudo apt install -y gnupg2 apt-transport-https
            wget -O - https://pkg.wslutiliti.es/public.key | sudo gpg --dearmor -o /usr/share/keyrings/wslu-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/wslu-archive-keyring.gpg] https://pkg.wslutiliti.es/debian $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/wslu.list
            sudo apt update -y
            sudo apt install -y wslu
            if [ $? -eq 0 ]; then
                echo -e "$TCG wslu installed successfully $TCD"
            else
                echo -e "$TCR Failed to install wslu. Falling back to powershell $TCD"
                powershell.exe -NoProfile -Command "Start-Process '$url'" 2>/dev/null || { echo -e "$TCR Failed to open URL in WSL $TCD"; return 1; }
                return
            fi
        fi
        wslview "$url" 2>/dev/null || { echo -e "$TCR Failed to open URL with wslview. Trying powershell $TCD"; powershell.exe -NoProfile -Command "Start-Process '$url'" 2>/dev/null || echo -e "$TCR Failed to open URL in WSL $TCD"; }
    else
        xdg-open "$url" 2>/dev/null || sensible-browser "$url" 2>/dev/null || x-www-browser "$url" 2>/dev/null || gnome-open "$url" 2>/dev/null || echo -e "$TCR Failed to open URL $TCD"
    fi
}

docker_is_installed() {
    if command -v docker >/dev/null 2>&1; then
        echo -e "$TCG Docker command found $TCD"
        return 0
    else
        echo -e "$TCR Docker command not found $TCD"
        return 1
    fi
}

docker_is_running() {
    # Functional check first: If we can talk to the daemon, we are good.
    if docker ps >/dev/null 2>&1; then
        echo -e "$TCG Docker is running $TCD"
        return 0
    fi

    # Diagnostics / Fallback checks
    if is_wsl; then
        if powershell.exe -NoProfile -Command "Get-Process 'Docker Desktop' -ErrorAction SilentlyContinue" | grep -q "Docker Desktop"; then
            echo -e "$TCR Docker Desktop is running but not integrated with WSL (or daemon not ready) $TCD"
            return 1
        else
            echo -e "$TCR Docker Desktop is not running (WSL) $TCD"
            return 1
        fi
    else
        # Linux service check fallback
        if systemctl is-active --quiet docker; then
             echo -e "$TCR Docker service active but socket unresponsive (permissions?) $TCD"
        else
             echo -e "$TCR Docker service is not running (Linux) $TCD"
        fi
        return 1
    fi
}

start_docker() {
    echo -n "Do you want to start Docker now? (y/n): "
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        if is_wsl; then
            echo -e "$TCG Starting Docker Desktop (WSL) $TCD"
            local win_path="C:/Program Files/Docker/Docker/Docker Desktop.exe"
            local wsl_path=$(wslpath -u "$win_path" 2>/dev/null)
            if [ -z "$wsl_path" ] || [ ! -f "$wsl_path" ]; then
                echo -e "$TCR Docker Desktop not found at $win_path $TCD"
                echo "Please ensure Docker Desktop is installed and adjust the path if necessary."
                return 1
            fi
            powershell.exe -Command "Start-Process -FilePath '$win_path'" 2>/dev/null &
            
            echo -e "$TCC Waiting for Docker to start... (this may take a minute) $TCD"
            local max_attempts=45 # 45 * 2s = 90s timeout
            local attempt=0
            while [ $attempt -lt $max_attempts ]; do
                if docker_is_running >/dev/null 2>&1; then
                    echo -e "$TCG Docker started successfully! $TCD"
                    return 0
                fi
                echo -n "."
                sleep 2
                ((attempt++))
            done
            echo ""
            
            echo -e "$TCR Failed to start Docker Desktop. Timeout reached. $TCD"
            echo "Please start Docker Desktop manually and enable WSL integration."
            return 1
        else
            echo -e "$TCG Starting Docker service (Linux) $TCD"
            sudo systemctl start docker || sudo service docker start
            sleep 2
            docker_is_running && return 0 || { echo -e "$TCR Failed to start Docker service $TCD"; return 1; }
        fi
    else
        echo -e "$TCR Docker is required for this operation. Exiting. $TCD"
        return 1
    fi
}

install_docker() {
    if is_wsl; then
        echo -e "$TCR Docker must be installed manually on Windows (Docker Desktop). $TCD"
        echo "1. Download from: https://docs.docker.com/desktop/install/windows-install/"
        echo "2. Enable WSL integration in Docker Desktop settings (Resources > WSL Integration)."
        echo "3. Run this script again after installation."
        exit 1
    else
        echo -e "$TCC Installing docker.io on Linux $TCD"
        sudo apt-get update -y && sudo apt-get install -y docker.io && sudo systemctl enable docker --now
        sudo usermod -aG docker "$USER"
        echo -e "$TCG Docker installed. Log out and back in, or use sudo. $TCD"
        docker_is_running || start_docker
    fi
}

check_docker() {
    echo -e "$TCC Checking Docker status $TCD"
    if ! docker_is_installed; then
        echo -e "$TCR Docker is not installed $TCD"
        install_docker || { echo "Installation failed"; exit 1; }
    fi
    if ! docker_is_running; then
        echo -e "$TCR Docker is not running $TCD"
        start_docker || { echo "Could not start Docker"; exit 1; }
    fi
    if is_wsl; then
        if ! docker ps >/dev/null 2>&1; then
            echo -e "$TCR Docker Desktop is running but not integrated with WSL. $TCD"
            echo "Please enable WSL integration in Docker Desktop settings."
            exit 1
        fi
    fi

    echo -e "$TCG Docker is ready $TCD"
}

check_dependencies() {
    local dependencies=("docker" "git" "curl" "grep" "sed")
    local missing=()
    echo -e "$TCC Checking dependencies... $TCD"
    for cmd in "${dependencies[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done
    
    # netcat check (nc, ncat, or netcat)
    if ! command -v nc >/dev/null 2>&1 && ! command -v ncat >/dev/null 2>&1 && ! command -v netcat >/dev/null 2>&1; then
        missing+=("nc (netcat)")
    fi

    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "$TCR Missing dependencies: ${missing[*]} $TCD"
        echo "Please install them via your package manager."
        exit 1
    fi
    echo -e "$TCG All dependencies found. $TCD"
}
