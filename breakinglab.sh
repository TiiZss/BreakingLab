#!/bin/bash
# 2025/03/15 Resideño completo
# 2025/10/11 Corrección errores

# Colores y estilos
TxDefault="\e[0m" TxBold="\e[1m" TxUnderline="\e[2m"
TCD="\e[0;0m" TCR="\e[0;31m" TCG="\e[0;32m" TCY="\e[1;33m" TCB="\e[0;34m" TCM="\e[0;35m" TCC="\e[0;36m" TCW="\e[0;37m"
BGBlack="\e[40m" BGRed="\e[41m" BGGreen="\e[42m" BGYellow="\e[43m" BGBlue="\e[44m" BGCian="\e[45m" BGMagenta="\e[46m" BGWhite="\e[47m"
ETC_HOSTS=/etc/hosts

# Proyectos Docker (nombre => [image|ip|port|desc|url|start_info|compose_path|pre_commands|post_commands])
declare -A DOCKER_PROJECTS
DOCKER_PROJECTS=(
    ["bwapp"]="raesene/bwapp|127.5.0.1|80|bWAPP PHP/MySQL based from itsecgames.com|http://127.5.0.1/install.php|Default username/password: bee/bug\nRun install first at http://bwapp/install.php|||"
    ["webgoat7"]="webgoat/webgoat-7.1|127.6.0.1|8080|OWASP WebGoat 7.1|http://webgoat7/WebGoat|WebGoat 7.0 now running at http://webgoat7/WebGoat|||"
    ["webgoat8"]="webgoat/webgoat-8.0|127.7.0.1|8080|OWASP WebGoat 8.0|http://webgoat8/WebGoat|WebGoat 8.0 now running at http://webgoat8/WebGoat|||"
    ["webgoat81"]="webgoat/goatandwolf|127.17.0.1|8080|OWASP WebGoat 8.1|http://webgoat81/WebGoat|WebGoat 8.1 now running at http://webgoat81/WebGoat\nWebWolf is not mapped yet|||"
    ["dvwa"]="vulnerables/web-dvwa|127.8.0.1|80|Damn Vulnerable Web Application|http://dvwa|Default username/password: admin/password\nClick CREATE DATABASE before starting|||"
    ["mutillidae"]="citizenstig/nowasp|127.9.0.1|80|OWASP Mutillidae II|http://mutillidae|Click create database: http://127.0.0.1/set-up-database.php|mutillidae-docker|git clone https://github.com/webpwnized/mutillidae-docker.git && cd mutillidae-docker && sed -i 's|_name: database|_name: mutillidae-database|g' .build/docker-compose.yml && sed -i 's|_name: www|_name: mutillidae-www|g' .build/docker-compose.yml && sed -i 's|_name: directory|_name: mutillidae-directory|g' .build/docker-compose.yml|cd mutillidae-docker && docker compose -f .build/docker-compose.yml up --build -d && cd .."
    ["juiceshop"]="bkimminich/juice-shop|127.10.0.1|3000|OWASP Juice Shop|http://juiceshop|OWASP Juice Shop now running|||"
    ["securitysheperd"]="owasp/security-shepherd:latest|127.11.0.1|80|OWASP Security Shepherd|http://securitysheperd|OWASP Security Shepherd running\nadmin / password|||"
    ["vulnerablewp"]="eystsen/vulnerablewordpress|127.12.0.1|80|WPScan Vulnerable Wordpress|http://vulnerablewp|WPScan Vulnerable Wordpress site now running|||"
    ["securityninjas"]="opendns/security-ninjas|127.13.0.1|80|OpenDNS Security Ninjas|http://securityninjas|Open DNS Security Ninjas site now running|||"
    ["altoro"]="eystsen/altoro|127.14.0.1|8080|Altoro Mutual Vulnerable Bank|http://altoro|Sign in with jsmith/demo1234 or admin/admin|||"
    ["graphql"]="carvesystems/vulnerable-graphql-api|127.15.0.1|3000|Vulnerable GraphQL API|http://graphql|Vulnerable GraphQL mapped to port 80\nSee https://carvesystems.com/news/the-5-most-common-graphql-security-vulnerabilities/|||"
    ["jvl"]="m4n3dw0lf/javavulnerablelab|127.16.0.1|8080|CSPF Java Vulnerable Lab|http://jvl|Install: http://localhost:8080/JavaVulnerableLab/install.jsp|JavaVulnerableLab|git clone https://github.com/CSPF-Founder/JavaVulnerableLab.git && cd JavaVulnerableLab|cd JavaVulnerableLab && docker-compose up -d && cd .."
    ["w4p"]="tiizss/webforpentester1:1.0|127.18.0.1|80|PentesterLab Web For Pentester I|http://w4p|Web For Pentester I|||"
    ["web4pentester"]="tiizss/webforpentester:1.0|127.18.0.1|80|PentesterLab Web For Pentester I|http://web4pentester|Go to IP shown (e.g., 172.17.0.2)|||sudo docker run --name web4pentester -h w4p -i -t --rm -p 127.18.0.1:80:80 tiizss/webforpentester:1.0 bash -c \"service apache2 start && service mysql start && bash\""
    ["sqlilabs"]="c0ny1/sqli-labs:0.1|127.19.0.1|80|Audi-1 SQLi Labs|http://sqlilabs|SQLI-LABS for GET and POST scenarios|||"
    ["oxninja"]="tiizss/oxninja-sqlilab|127.20.0.1|80|OxNinja SQLi-Lab|http://oxninja|SQL injection playground|oxninja-sqlilab|git clone https://github.com/OxNinja/SQLi-lab oxninja-sqlilab && cd oxninja-sqlilab && sed -i \"/web:/at        container_name: oxninja-web\" docker-compose.yml && sed -i \"s/^t//\" docker-compose.yml && sed -i \"s|-\s*80\:\s*80|-\s*127.20.0.1\:\s*80\:\s*80|g\" docker-compose.yml && sed -i \"s/172.16.0/172.16.1/g\" docker-compose.yml|cd oxninja-sqlilab && docker-compose up -d --build && cd .."
    ["bricks"]="citizenstig/owaspbricks|127.21.0.1|80|OWASP Bricks|http://bricks|Install: http://127.21.0.1/config/|||"
    ["nosqli"]="tiizss/nosqlibab|127.22.0.1|8080|Digininja NoSqli Lab|http://127.22.0.1:8080/|Access: http://127.22.0.1:8080/index.php|nosqlilab|git clone https://github.com/madamantis-leviathan/nosqlilab.git && cd nosqlilab && sed -i 's/^version: .*$/version: \"3.7-3.9\"/' docker-compose.yml && sed -i \"/web:/at    container_name: nosqli-web\" docker-compose.yml && sed -i \"s/^t//\" docker-compose.yml|cd nosqlilab && docker-compose up -d --build && cd .."
    ["vulnado"]="vulnado|127.23.0.1|1337|Intentionally Vulnerable Java App|http://127.23.0.1:1337|OWASP top 10\nAccess: http://127.23.0.1:1337/index.php|vulnado|git clone https://github.com/ScaleSec/vulnado && cd vulnado|cd vulnado && sudo docker compose up -d && cd .."
    ["ssrflab"]="php:8.1.28-apache-bullseye|127.24.0.1|80|SSRF-LAB|http://ssrflab|Access: http://127.24.0.1/index.php|SSRF-LAB|git clone https://github.com/ph4nt0m-py/SSRF-LAB.git && cd SSRF-LAB|cd SSRF-LAB && docker cp ./index.php ssrflab:/var/www/html && cd .."
    ["damnvulnrest"]="damnvulnrest|127.25.0.1|8080|Damn Vulnerable RESTaurant|http://damnvulnrest|Access: http://127.25.0.1:8080|Damn-Vulnerable-RESTaurant-API-Game|git clone https://github.com/theowni/Damn-Vulnerable-RESTaurant-API-Game.git && cd Damn-Vulnerable-RESTaurant-API-Game|cd Damn-Vulnerable-RESTaurant-API-Game && bash ./start_app.sh && cd .."
    ["btslab"]="tomsik68/xampp:5|127.26.0.1|80|BTS PenTesting Lab|http://btslab|Access: http://127.26.0.1/btslab|btslab|git clone https://github.com/CSPF-Founder/btslab|docker cp btslab/ btslab:/opt/lampp/htdocs"
    ["exploitcoil"]="tomsik68/xampp:5|127.27.0.1|80|exploit.co.il Vulnerable Web App|http://exploitcoil|Access: http://127.27.0.1|exploit.co.il-Docker|git clone https://github.com/Cryoox/exploit.co.il-Docker.git && cd exploit.co.il-Docker|cd exploit.co.il-Docker && docker compose up -d && cd .."
    ["vulpy"]="devsecopsacademy/vulpy:v1.2.0|127.28.0.1|5000|Vulpy Web Application Security Lab|http://vulpy|Access: http://127.28.0.1|||"
)

# Proyectos Online (nombre => [url|desc])
declare -A ONLINE_PROJECTS
ONLINE_PROJECTS=(
    ["redtiger"]="http://redtiger.labs.overthewire.org/|RedTiger's Hackit (online)"
    ["portswigger"]="https://portswigger.net/web-security/sql-injection|PortSwigger SQLi Labs (online)"
    ["hacksplaining"]="https://www.hacksplaining.com/exercises/sql-injection|Hacksplanning SQLi Lab (online)"
    ["synk"]="https://learn.snyk.io/catalog/|Synk Learn (online)"
    ["thmsqli"]="https://tryhackme.com/room/sqlilab|Try Hack Me SQLi Lab (online)"
    ["kontra"]="https://application.security/free-application-security-training/owasp-top-10-sql-injection|Kontra SQLi Lab (online)"
    ["thm"]="https://tryhackme.com|Try Hack Me (online)"
    ["hdb"]="https://www.hackthebox.com/|Hack The Box (online)"
    ["vulnhub"]="https://www.vulnhub.com/|VulnHub (online)"
    ["ps"]="https://portswigger.net/web-security|PortSwigger WebSecurity Academy (online)"
    ["ctftime"]="https://ctftime.org/ctfs|CTFTime (online)"
    ["hackmyvm"]="https://hackmyvm.eu/|HackMyVM (online)"
    ["vuln"]="https://www.vulnmachines.com/|VulnMachines (online)"
    ["blueteam"]="https://blueteamlabs.online/|BlueTeam Lab (online)"
    ["pentest2"]="https://www.pentesterlab.com/|Web Pentester II (online)"
    ["rootme"]="https://www.root-me.org/|Root-Me Org (online)"
)

# Funciones utilitarias
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

open_url() {
    local url=$1
    if is_wsl; then
        if ! command -v wslview >/dev/null 2>&1; then
            echo -e "$TCC wslview not found. Adding wslu repository and installing wslu... $TCD"
            # Añadir el repositorio de wslu
            sudo apt update -y
            sudo apt install -y gnupg2 apt-transport-https
            wget -O - https://pkg.wslutiliti.es/public.key | sudo gpg --dearmor -o /usr/share/keyrings/wslu-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/wslu-archive-keyring.gpg] https://pkg.wslutiliti.es/debian $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/wslu.list
            sudo apt update -y
            # Instalar wslu
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
add_host() { grep -q "$2" $ETC_HOSTS || sudo sh -c "echo '$1\t$2' >> $ETC_HOSTS"; }

remove_host() {
    local ip=$1
    local proj=$2  # Pasamos el nombre del proyecto como segundo argumento
    if grep -q "$proj" $ETC_HOSTS; then
        echo "Removing $proj from $ETC_HOSTS"
        sudo sed -i "/\s$proj$/d" $ETC_HOSTS || { echo -e "$TCR Failed to remove $proj from $ETC_HOSTS $TCD"; return 1; }
    else
        echo "$proj not found in $ETC_HOSTS"
    fi
}

# Funciones de verificación de Docker
is_wsl() { [[ $(uname -r) =~ [Mm]icrosoft ]] && return 0 || return 1; }

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
    if is_wsl; then
        # Evitar rutas UNC ejecutando desde un directorio Windows
        if powershell.exe -NoProfile -Command "Get-Process 'Docker Desktop' -ErrorAction SilentlyContinue" | grep -q "Docker Desktop"; then
            # Verificar que Docker esté funcional en WSL
            if docker ps >/dev/null 2>&1; then
                echo -e "$TCG Docker Desktop is running and integrated with WSL $TCD"
                return 0
            else
                echo -e "$TCR Docker Desktop is running but not integrated with WSL $TCD"
                return 1
            fi
        else
            echo -e "$TCR Docker Desktop is not running (WSL) $TCD"
            return 1
        fi
    else
        if docker info >/dev/null 2>&1; then
            echo -e "$TCG Docker service is running (Linux) $TCD"
            return 0
        else
            echo -e "$TCR Docker service is not running (Linux) $TCD"
            return 1
        fi
    fi
}

start_docker() {
    echo -n "Do you want to start Docker now? (y/n): "
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        if is_wsl; then
            echo -e "$TCG Starting Docker Desktop (WSL) $TCD"
            # Ruta predeterminada de Docker Desktop en Windows
            local win_path="C:/Program Files/Docker/Docker/Docker Desktop.exe"
            local wsl_path=$(wslpath -u "$win_path" 2>/dev/null)
            if [ -z "$wsl_path" ] || [ ! -f "$wsl_path" ]; then
                echo -e "$TCR Docker Desktop not found at $win_path $TCD"
                echo "Please ensure Docker Desktop is installed and adjust the path if necessary."
                return 1
            fi
            # Usar powershell.exe para iniciar Docker Desktop evitando UNC
            powershell.exe -Command "Start-Process -FilePath '$win_path'" 2>/dev/null &
            sleep 10  # Dar tiempo para que Docker Desktop inicie completamente
            if docker_is_running; then
                return 0
            else
                echo -e "$TCR Failed to start Docker Desktop. Ensure WSL integration is enabled. $TCD"
                return 1
            fi
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
    # Verificación adicional en WSL para asegurarse de que Docker está integrado
    if is_wsl; then
        if ! docker ps >/dev/null 2>&1; then
            echo -e "$TCR Docker Desktop is running but not integrated with WSL. $TCD"
            echo "Please enable WSL integration in Docker Desktop settings."
            exit 1
        fi
    fi
    echo -e "$TCG Docker is ready $TCD"
}

# Funciones genéricas para proyectos


start_docker_project() {
    local proj=$1
    if [[ -z "${DOCKER_PROJECTS[$proj]}" ]]; then
        echo -e "$TCR Project $proj not found in DOCKER_PROJECTS $TCD"
        return 1
    fi
    check_docker
    IFS='|' read -r image ip port desc url start_info compose_path pre_commands post_commands <<< "${DOCKER_PROJECTS[$proj]}"
    echo "Starting $desc"
    add_host "$ip" "$proj"
    [ -n "$pre_commands" ] && eval "$pre_commands"

    if [ -n "$compose_path" ]; then
        [ -d "$compose_path" ] || { echo "Error: $compose_path not found"; return 1; }
        eval "$post_commands"
    else
        echo "Checking if container $proj exists..."
        local container_exists=$(docker ps -a -q -f "name=^$proj$")
        if [ -n "$container_exists" ]; then
            echo "Container $proj exists with ID: $container_exists"
            local running=$(docker inspect "$proj" | grep -c '"Running": true')
            if [ "$running" -eq 1 ]; then
                echo "Container $proj is already running"
            else
                echo "Starting existing container $proj"
                docker start "$proj" && echo "Container $proj started successfully" || { echo -e "$TCR Failed to start container $proj $TCD"; return 1; }
            fi
        else
            echo "Container $proj does not exist. Creating it with image $image..."
            if [ -n "$post_commands" ]; then
                eval "$post_commands" || { echo -e "$TCR Failed to execute post commands for $proj $TCD"; return 1; }
            else
                echo "Running: docker run --name $proj -d -p $ip:$port:$port $image"
                docker run --name "$proj" -d -p "$ip:$port:$port" "$image"
                if [ $? -eq 0 ]; then
                    echo "Container $proj created and started successfully"
                else
                    echo -e "$TCR Failed to create container $proj. Check Docker logs with 'docker logs $proj' $TCD"
                    return 1
                fi
            fi
        fi
        # Esperar a que el contenedor esté corriendo
        echo "Waiting for $proj to be fully running..."
        local timeout=60  # Aumentado a 60 segundos
        local elapsed=0
        while ! docker ps -q -f "name=^$proj$" >/dev/null; do
            sleep 1
            elapsed=$((elapsed + 1))
            if [ "$elapsed" -ge "$timeout" ]; then
                echo -e "$TCR Timeout waiting for $proj to start $TCD"
                return 1
            fi
        done
        # Verificar que el puerto esté escuchando
        echo "Checking if port $port is ready on $ip..."
        while ! nc -z "$ip" "$port" 2>/dev/null; do
            sleep 1
            elapsed=$((elapsed + 1))
            if [ "$elapsed" -ge "$timeout" ]; then
                echo -e "$TCR Timeout waiting for port $port on $ip to be ready $TCD"
                return 1
            fi
        done
        # Verificar que la página esté disponible con curl
        echo "Checking if $url is fully available..."
        while ! curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "200"; do
            sleep 1
            elapsed=$((elapsed + 1))
            if [ "$elapsed" -ge "$timeout" ]; then
                echo -e "$TCR Timeout waiting for $url to be available $TCD"
                return 1
            fi
        done
        echo "Container $proj is running and $url is available"
    fi
    echo "DONE! Available at $url"
    echo -e "$start_info"
    open_url "$url"
}

#list_running_docker_projects() {
#    echo -e "$TCC Running Docker Projects $TCD"
#    local found_running=0
#    for proj in "${!DOCKER_PROJECTS[@]}"; do
#        # Capturar el ID del contenedor corriendo
#        local container_id=$(docker ps -q -f "name=^$proj$")
#        if [ -n "$container_id" ]; then
#            IFS='|' read -r image ip port desc url start_info compose_path pre_commands post_commands <<< "${DOCKER_PROJECTS[$proj]}"
#            echo -e "$TCG $proj $TCD- $desc"
#            found_running=1
#        fi
#    done
#    if [ "$found_running" -eq 0 ]; then
#        echo -e "$TCR No Docker projects are currently running $TCD"
#    fi
#}

list_running_docker_projects() {
    echo -e "$TCC Running Docker Projects $TCD"
    local found_running=0
    for proj in "${!DOCKER_PROJECTS[@]}"; do
        IFS='|' read -r image ip port desc url start_info compose_path pre_commands post_commands <<< "${DOCKER_PROJECTS[$proj]}"

        if [ -n "$compose_path" ]; then
            if [ -f "$compose_path" ]; then
                local compose_dir=$(dirname "$compose_path")
                if [ -d "$compose_dir" ]; then
                    pushd "$compose_dir" > /dev/null
                    # Solo mostrar si algún servicio está realmente 'Up'
                    local running_services=$(docker compose ps --format json 2>/dev/null)
                    if [ -n "$running_services" ]; then
                        # Buscar algún servicio con "State":"running" en el JSON
                        if echo "$running_services" | grep -q '"State":"running"'; then
                            echo -e "$TCG $proj $TCD- $desc (Stack)"
                            found_running=1
                        fi
                    fi
                    popd > /dev/null
                fi
            fi
        else
            # Solo mostrar si el contenedor está en estado running
            local running_container=$(docker ps --filter "name=^$proj$" --filter "status=running" -q)
            if [ -n "$running_container" ]; then
                echo -e "$TCG $proj $TCD- $desc"
                found_running=1
            fi
        fi
    done
    if [ "$found_running" -eq 0 ]; then
        echo -e "$TCR No Docker projects are currently running $TCD"
    fi
}

stop_docker_project() {
    local proj=$1
    if [ -z "$proj" ]; then
        echo -e "$TCR No project name provided $TCD"
        return 1
    fi
    if [[ -z "${DOCKER_PROJECTS[$proj]}" ]]; then
        echo -e "$TCR Project $proj not found in DOCKER_PROJECTS $TCD"
        return 1
    fi
    check_docker >/dev/null 2>&1
    IFS='|' read -r image ip port desc url start_info compose_path pre_commands post_commands <<< "${DOCKER_PROJECTS[$proj]}"

    if [ -n "$compose_path" ]; then
        # Si compose_path es un archivo, usarlo directamente
        if [ -f "$compose_path" ]; then
            local compose_dir=$(dirname "$compose_path")
            pushd "$compose_dir" > /dev/null
            docker compose -f "$(basename "$compose_path")" down >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo -e "$proj --> $TCR stack stopped using docker compose down $TCD"
            else
                echo -e "$TCR Failed to stop stack $proj using docker compose down $TCD"
                popd > /dev/null
                return 1
            fi
            popd > /dev/null
        # Si compose_path es un directorio, buscar docker-compose.yml o compose.yaml
        elif [ -d "$compose_path" ]; then
            local compose_file=""
            if [ -f "$compose_path/docker-compose.yml" ]; then
                compose_file="docker-compose.yml"
            elif [ -f "$compose_path/compose.yaml" ]; then
                compose_file="compose.yaml"
            fi
            if [ -n "$compose_file" ]; then
                pushd "$compose_path" > /dev/null
                docker compose -f "$compose_file" down >/dev/null 2>&1
                if [ $? -eq 0 ]; then
                    echo -e "$proj --> $TCR stack stopped using docker compose down $TCD"
                else
                    echo -e "$TCR Failed to stop stack $proj using docker compose down $TCD"
                    popd > /dev/null
                    return 1
                fi
                popd > /dev/null
            else
                echo -e "$TCR No docker-compose.yml or compose.yaml found in $compose_path $TCD"
                return 1
            fi
        else
            echo -e "$TCR Compose file or directory not found at $compose_path $TCD"
            return 1
        fi
    else
        # Manejar contenedores individuales
        local container_id=$(docker ps -q -f "name=^$proj$")
        if [ -n "$container_id" ]; then
            echo "Stopping $desc"
            docker stop "$proj" >/dev/null && echo "Container $proj stopped successfully" || { echo -e "$TCR Failed to stop container $proj $TCD"; return 1; }
            remove_host "$ip" "$proj"
        else
            echo -e "$TCR Container $proj is not running $TCD"
            return 1
        fi
    fi
}

#stop_docker_project() {
#    local proj=$1
#    if [ -z "$proj" ]; then
#        echo -e "$TCR No project name provided $TCD"
#        return 1
#    fi
#    if [[ -z "${DOCKER_PROJECTS[$proj]}" ]]; then
#        echo -e "$TCR Project $proj not found in DOCKER_PROJECTS $TCD"
#        return 1
#    fi
#    check_docker
#    IFS='|' read -r image ip port desc url start_info compose_path pre_commands post_commands <<< "${DOCKER_PROJECTS[$proj]}"
#    if [ -n "$compose_path" ]; then
#        docker ps --filter "name=$proj" --format "{{.Names}}" | grep "^$proj" | while read -r container; do
#            docker stop "$container" >/dev/null && echo -e "$container --> $TCR stopped $TCD"
#        done
#    else
#        local container_id=$(docker ps -q -f "name=^$proj$")
#        if [ -n "$container_id" ]; then
#            echo "Stopping $desc"
#            docker stop "$proj" >/dev/null && echo "Container $proj stopped successfully" || { echo -e "$TCR Failed to stop container $proj $TCD"; return 1; }
#            remove_host "$ip" "$proj"
#        else
#            echo -e "$TCR Container $proj is not running $TCD"
#            return 1
#        fi
#    fi
#}



status_docker_project() {
    local proj=$1
    if [[ -z "${DOCKER_PROJECTS[$proj]}" ]]; then
        echo -e "$TCR Project $proj not found in DOCKER_PROJECTS $TCD"
        return 1
    fi
    IFS='|' read -r image ip port desc url start_info compose_path pre_commands post_commands <<< "${DOCKER_PROJECTS[$proj]}"
    local status status_color status_text
    if [ -n "$compose_path" ]; then
        local running_stack=$(docker ps --filter "name=^${proj}" --filter "status=running" -q)
        if [ -n "$running_stack" ]; then
            status_color="$TCG"
            status_text="running"
        else
            status_color="$TCR"
            status_text="not running"
        fi
    else
        local running_container=$(docker ps --filter "name=^$proj$" --filter "status=running" -q)
        if [ -n "$running_container" ]; then
            status_color="$TCG"
            status_text="running"
        else
            status_color="$TCR"
            status_text="not running"
        fi
    fi
    # Ajustar ancho: 55 para desc+proyecto, 12 para status
    printf "%b%-55s %b%-12s%b" "$TCC" "$desc ($proj)" "$status_color" "$status_text" "$TCD"
    if [ "$status_text" = "running" ]; then
        printf " %s\n" "$url"
    else
        printf "\n"
    fi
}

start_online_project() {
    local proj=$1
    if [[ -z "${ONLINE_PROJECTS[$proj]}" ]]; then
        echo -e "$TCR Project $proj not found in ONLINE_PROJECTS $TCD"
        return 1
    fi
    IFS='|' read -r url desc <<< "${ONLINE_PROJECTS[$proj]}"
    echo -e "$TCR Opening --> $TCD $desc"
    sleep 2
    open_url "$url"
}

list_docker_projects() {
    echo -e "$TCC Available Docker Projects $TCD"
    for proj in "${!DOCKER_PROJECTS[@]}"; do
        IFS='|' read -r image ip port desc url start_info compose_path pre_commands post_commands <<< "${DOCKER_PROJECTS[$proj]}"
        echo -e "$TCG $proj $TCD- $desc"
    done
}

list_online_projects() {
	echo -e "$TCC Available Online Projects $TCD"
    for proj in "${!ONLINE_PROJECTS[@]}"; do
        IFS='|' read -r url desc <<< "${ONLINE_PROJECTS[$proj]}"
        echo -e "$TCG $proj $TCD- $desc"
    done
}

list_projects() {
    echo -e "$TCC Available Docker Projects $TCD"
    for proj in "${!DOCKER_PROJECTS[@]}"; do
        IFS='|' read -r image ip port desc url start_info compose_path pre_commands post_commands <<< "${DOCKER_PROJECTS[$proj]}"
        echo -e "$TCG $proj $TCD- $desc"
    done
    echo -e "$TCC Available Online Projects $TCD"
    for proj in "${!ONLINE_PROJECTS[@]}"; do
        IFS='|' read -r url desc <<< "${ONLINE_PROJECTS[$proj]}"
        echo -e "$TCG $proj $TCD- $desc"
    done
}

# Menú principal
# Menú principal
main_menu() {
    display_logo
    echo -e "$TCC Options: $TCD\n1) List Projects\n2) Start Docker Project\n3) Stop Docker Project\n4) Status Docker Projects\n5) Start Online Project\n99) Exit"
    read -p "Select an option: " choice
    case $choice in
        1) list_projects; main_menu;;
        2) while true; do
               list_docker_projects
               echo -e "$TCC Enter '0' to return to menu, '99' to exit script, or 'q' to quit this option $TCD"
               read -p "Enter Docker project name: " proj
               if [ "$proj" = "99" ]; then
                   echo -e "$TCG Exiting script... $TCD"
                   exit 0
               elif [ "$proj" = "0" ] || [ "$proj" = "q" ]; then
                   break
               elif [ -n "$proj" ] && [[ -n "${DOCKER_PROJECTS[$proj]}" ]]; then
                   start_docker_project "$proj"
                   break
               else
                   echo -e "$TCR Invalid project name. Please choose from the list or use 0/99/q. $TCD"
                   sleep 2
               fi
           done
           main_menu;;
        3)
           echo -e "$TCC Running Docker Projects $TCD"
           local found_running=0
           declare -A running_projects
           for proj in "${!DOCKER_PROJECTS[@]}"; do
               IFS='|' read -r image ip port desc url start_info compose_path pre_commands post_commands <<< "${DOCKER_PROJECTS[$proj]}"
               local status_text="not running"
               if [ -n "$compose_path" ]; then
                   local running_stack=$(docker ps --filter "name=^${proj}" --filter "status=running" -q)
                   if [ -n "$running_stack" ]; then
                       status_text="running"
                   fi
               else
                   local running_container=$(docker ps --filter "name=^$proj$" --filter "status=running" -q)
                   if [ -n "$running_container" ]; then
                       status_text="running"
                   fi
               fi
               if [ "$status_text" = "running" ]; then
                   echo -e "$TCG $proj $TCD- $desc"
                   running_projects[$proj]=1
                   found_running=1
               fi
           done
           if [ "$found_running" -eq 0 ]; then
               echo -e "$TCR No Docker projects are currently running $TCD"
               echo -e "$TCR No projects are running to stop. Returning to menu... $TCD"
               sleep 2
               main_menu
           else
               read -p "Enter Docker project name: " proj
               if [ -n "$proj" ] && [[ -n "${running_projects[$proj]}" ]]; then
                   stop_docker_project "$proj"
                   # Mostrar el estado actualizado solo de ese proyecto
                   status_docker_project "$proj"
               else
                   echo -e "$TCR Please enter a valid running project name $TCD"
               fi
               echo
               read -n 1 -s -r -p "Presiona cualquier tecla para continuar..."
               echo
               main_menu
           fi;;
          4)
              check_docker >/dev/null 2>&1
              for proj in "${!DOCKER_PROJECTS[@]}"; do status_docker_project "$proj"; done
              echo
              read -n 1 -s -r -p "Presiona cualquier tecla para continuar..."
              echo
              main_menu;;
        5) while true; do
               list_online_projects
               echo -e "$TCC Enter '0' to return to menu, '99' to exit script, or 'q' to quit this option $TCD"
               read -p "Enter Online project name: " proj
               if [ "$proj" = "99" ]; then
                   echo -e "$TCG Exiting script... $TCD"
                   exit 0
               elif [ "$proj" = "0" ] || [ "$proj" = "q" ]; then
                   break
               elif [ -n "$proj" ] && [[ -n "${ONLINE_PROJECTS[$proj]}" ]]; then
                   start_online_project "$proj"
                   break
               else
                   echo -e "$TCR Invalid project name. Please choose from the list or use 0/99/q. $TCD"
                   sleep 2
               fi
           done
           main_menu;;
        99) echo -e "$TCG Exiting script... $TCD"; exit 0;;
        *) echo "Invalid option"; main_menu;;
    esac
}

# Ejecución principal
if [ $# -eq 0 ]; then
    main_menu
else
    case "$1" in
        list) list_projects;;
        start) start_docker_project "$2";;
        stop) stop_docker_project "$2";;
        status) for proj in "${!DOCKER_PROJECTS[@]}"; do status_docker_project "$proj"; done;;
        online) start_online_project "$2";;
        *) echo "Usage: $0 {list|start|stop|status|online} [projectname]";;
    esac
fi
