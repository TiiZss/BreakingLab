#!/bin/bash
# 2023/09/16 - TiiZss añade JavaVulnerableLab
# 2023/09/18 - TiiZss modifica parámetros. Se incluye Web For Pentester
# 2023/10/30 - TiiZss corrección de errores
# 2023/11/01 - TiiZss - JavaVulnerableLab no funciona. No hay conectividad con mysql desde WSL.
# 2023/11/09 - TiiZss - w4p no funciona no arranca mysql. web4pentester funciona.
# 2023/12/15 - TiiZss - Audi 1 SQLi Labs
# 2023/12/17 - TiiZss - OxNinja SQLi Lab
# 2023/12/24 - TiiZss - corrección de errores y optimización

ETC_HOSTS=/etc/hosts

#Tmux vars
session_name="breakinglab"
tmux_main_window="breakinglab-Main"
no_hardcore_exit=0

#########################
# Text Style            #
#########################
TDefault="\e[0m"
TBold="\e[1m"
TUnderline="\e[2m"

#########################
# Text Colors           #
#########################
TDefault="\e[0;0m"
TBlack="\e[0;30m"
TRed="\e[0;31m"
TGreen="\e[0;32m"
TYellow="\e[1;33m"
TBlue="\e[0;34m"
TMagenta="\e[0;35m"
TCian="\e[0;36m"
TWhite="\e[0;37m"

#########################
# Background Colors     #
#########################
#BGDefault="\e[4m"
BGBlack="\e[40m"
BGRed="\e[41m"
BGGreen="\e[42m"
BGYellow="\e[43m"
BGBlue="\e[44m"
BGCian="\e[45m"
BGMagenta="\e[46m"
BGWhite="\e[47m"

#########################
# Script Date Creation  #
#########################
function print_date () {
	# Obtener la fecha de creación del script
	fecha_creacion=$(stat -c %y "$0")

	# Imprimir la fecha de creación
	echo "$fecha_creacion"
}

#########################
# Display Logo and Info #
#########################
display_logo() {                                                                             
	echo -e "-----------------------------------------------------------------------------------------"
	echo -e "$BGGreen               35$BGWhite$TGreen                                       TiiZss  $TWhite$BGGreen               57$BGWhite$TGreen         $TWhite"
	echo -e "$BGGreen ██████  ██████  $BGWhite$TGreen ███████  █████  ██   ██ ██ ███    ██  ██████  $TWhite$BGGreen ██       █████  $BGWhite$TGreen ██████  $TWhite"
	echo -e "$BGGreen ██   ██ ██   ██ $BGWhite$TGreen ██      ██   ██ ██  ██  ██ ████   ██ ██       $TWhite$BGGreen ██      ██   ██ $BGWhite$TGreen ██   ██ $TWhite"
	echo -e "$BGGreen ██████  ██████  $BGWhite$TGreen █████   ███████ █████   ██ ██ ██  ██ ██   ███ $TWhite$BGGreen ██      ███████ $BGWhite$TGreen ██████  $TWhite"
	echo -e "$BGGreen ██   ██ ██   ██ $BGWhite$TGreen ██      ██   ██ ██  ██  ██ ██  ██ ██ ██    ██ $TWhite$BGGreen ██      ██   ██ $BGWhite$TGreen ██   ██ $TWhite"
	echo -e "$BGGreen ██████  ██   ██ $BGWhite$TGreen ███████ ██   ██ ██   ██ ██ ██   ████  ██████  $TWhite$BGGreen ███████ ██   ██ $BGWhite$TGreen ██████  $TWhite"
	echo -e "$BGGreen                 $BGWhite$TGreen v.$(print_date)         $TWhite$BGGreen                 $BGWhite$TGreen    BETA $TWhite"
	echo -e "$TDefault-----------------------------------------------------------------------------------------"
}

function display_info {
	echo -e "  BreakingLab Script a Local Pentest Lab Management Script (Docker based)"
	echo -e "  Modified by TiiZss. Version: $(print_date)"
    echo -e "  This scripts uses docker and hosts alias to make web apps available on localhost"
    echo -e "-----------------------------------------------------------------------------------------"
}

#########################
# The command line help #
#########################
display_help() {
    echo "Usage: $0 {list|status|info|start|startpublic|stop} [projectname]" >&2
    echo " Ex."
    echo " $0 list"
    echo " 	List all available projects"
    echo " $0 status"
    echo "	Show status for all projects"
    echo " $0 start w4p"
    echo " 	Start w4p project and make it available on localhost" 
    echo " $0 startpublic w4p"
    echo " 	Start w4p project and make it publicly available (to anyone with network connectivity to the machine)" 
    echo " $0 info w4p"
    echo " 	Show information about w4p project"
    echo " $0 stop w4p"
    echo " 	Stop w4p project "
    exit 1
}

############################################
# Check if docker is installed and running #
############################################
function docker_is_installed() {
  # Verifica si el comando docker está disponible
  if command -v docker >/dev/null; then
    # Verifica si el demonio de Docker está en ejecución
    if docker info >/dev/null; then
      # Docker está instalado y funcionando
      echo "Docker está instalado y funcionando"
      return 0
    else
      # Docker está instalado pero no está funcionando
      echo "Docker está instalado pero no está funcionando"
      return 1
    fi
  else
    # Docker no está instalado
    echo "Docker no está instalado"
    return 1
  fi
}

function docker_is_running() {
  # Verifica si el proceso de Docker Desktop está en ejecución
  ps -ef | grep -q "dockerd"
  if [ $? -eq 0 ]; then
    # Docker Desktop está en funcionamiento
    echo "Docker Desktop está en funcionamiento"
    return 0
  else
    # Docker Desktop no está en funcionamiento
    echo "Docker Desktop no está en funcionamiento"
    return 1
  fi
}

function is_wsl() {
  # Verifica si la variable de entorno WSL_DISTRO está definida
  #if [[ -n "$WSL_DISTRO" ]]; then
  if [[ $(uname -a) =~ "WSL" ]]; then
  # El bash es de un WSL
    #echo "WSL"
    return 0
  else
    # El bash no es de un WSL
    #echo "Ubuntu"
    return 1
  fi
}

function check_docker2() {
	if is_wsl; then
		echo "WSL"
		docker_is_running
	else
		docker_is_installed
	fi
}

function check_docker() {
	echo -ne " Checking if Docker is running:"
	if [[ $(uname -r) =~ WSL ]]; then
		#if ! command -v docker &> /dev/null; then
		if ! docker &> /dev/null; then
			echo -e "$TRed Docker Desktop isn't running. $TDefault"
			start_docker
		else
			echo -e "$TGreen Docker is running. $TDefault "
		fi
	else
		if ! [ -x "$(command -v docker)" ]; then
			echo 
			echo "Docker was not found. Please install docker before running this script."
			echo "For kali linux you can install docker with the following commands:"
			echo " sudo apt update "
			echo " sudo apt install -y docker.io"
			echo " sudo systemctl enable docker --now"
			echo " sudo usermod -aG docker $USER"
			echo " docker"
			echo "For other Linux Distros please visit: https://docs.docker.com/desktop/install/linux-install/"
			echo "Thank You!"
			exit
		fi		
		if sudo service docker status | grep inactive > /dev/null
			echo -e "$TGreen Docker is running. $TDefault "
		then 
			echo -e "$TRed Docker isn't running. $TDefault"
			start_docker
		fi
	fi
}

function start_docker () {
	echo -n "Do you want to start docker now (y/n)?"
	read answer
	if echo "$answer" | grep -iq "^y"; then
		if is_wsl; then
			cmd.exe /c "C:\Program Files\Docker\Docker\docker desktop.exe"
		else
			sudo service docker start
		fi
		echo -e " Starting Docker."
	else	
		echo -e "$TRed Not starting. Script will not be able to run applications. $TDefault"
		exit
	fi
}

#########################################
# Open URL with the default web browser #
#########################################
function openUrl() {
	local URL="$1";
	if [[ $(uname -r) =~ WSL ]]; then
		explorer.exe $URL
	else
		xdg-open $URL || sensible-browser $URL || x-www-browser $URL || gnome-open $URL
	fi
}

#########################
# List all pentest apps #
#########################
list() {
    echo "Available pentest applications" >&2
    echo "-----------------------------------------------------------------------------------------"
	echo "  bwapp            - bWAPP PHP/MySQL based from itsecgames.com"
    echo "  webgoat7         - OWASP WebGoat 7.1"
    echo "  webgoat8         - OWASP WebGoat 8.0"
    echo "  webgoat81        - OWASP WebGoat 8.1"
    echo "  dvwa             - Damn Vulnerable Web Application"
    echo "  mutillidae       - OWASP Mutillidae II"
    echo "  juiceshop        - OWASP Juice Shop"
    echo "  securitysheperd  - OWASP Security Shepherd"
	echo "  vulnerablewp     - WPScan Vulnerable Wordpress"
    echo "  securityninjas   - OpenDNS Security Ninjas"
    echo "  altoro           - Altoro Mutual Vulnerable Bank"
    echo "  graphql          - Vulnerable GraphQL API"
    echo "  jvl				 - CSPF Java Vulnerable Lab Web Application"
    echo "  w4p              - PentesterLab Web For Pentester I "
    echo "  web4pentester    - PentesterLab Web For Pentester I "
    echo "  sqlilabs         - Audi-1 SQLi labs"
	echo "  oxninja          - OxNinja SQLi-lab"
	echo "-----------------------------------------------------------------------------------------"
    exit 1
}

#########################
# hosts file util       #
#########################  
# Based on https://gist.github.com/irazasyed/a7b0a079e7727a4315b9
function removehost() {
    if [ -n "$(grep $1 /etc/hosts)" ]
    then
        echo "Removing $1 from $ETC_HOSTS";
        sudo sed -i".bak" "/$1/d" $ETC_HOSTS
    else
        echo "$1 was not found in your $ETC_HOSTS";
    fi
}


function addhost() { # ex.   127.5.0.1	bwapp
    HOSTS_LINE="$1\t$2"
    if [ -n "$(grep $2 /etc/hosts)" ]
        then
            echo "$2 already exists in /etc/hosts"
        else
            echo "Adding $2 to your $ETC_HOSTS";
            sudo -- sh -c -e "echo '$HOSTS_LINE' >> /etc/hosts";

            if [ -n "$(grep $2 /etc/hosts)" ]
                then
                    echo -e "$HOSTS_LINE was added succesfully to /etc/hosts";
                else
                    echo "Failed to Add $2, Try again!";
            fi
    fi
}


#########################
# PROJECT INFO & STARTUP#
#########################
function project_info () {
	case "$1" in
		bwapp)
			echo -e "$TCian Information about bWAPP an extremely buggy web app! - bwapp $TDefault"
			echo -e "$TYellow Description: $TDefault bWAPP, or a buggy web application, is a free and open source deliberately insecure web application."
			echo -e "              It helps security enthusiasts, developers and students to discover and to prevent web vulnerabilities."
			echo -e "              bWAPP prepares one to conduct successful penetration testing and ethical hacking projects."
			echo -e "$TYellow Rules: $TDefault The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "$TYellow Tutorial: $TDefault https://www.youtube.com/playlist?list=PLSbrmTUy4daOsm6ky-M5QmUnV31BkZ_6X"
			echo -e "$TYellow Solutions: $TDefault https://wooly6bear.files.wordpress.com/2016/01/bwapp-tutorial.pdf"
			echo -e "$TYellow Source: $TDefault http://www.itsecgames.com"
		;;
		webgoat*)
			echo -e "$TCian Information about OWASP WebGoat 7,8,8.1 $TDefault"
			echo -e "$TYellow Description: $TDefault WebGoat is a deliberately insecure application that allows interested developers just like you to test"
			echo -e "              vulnerabilities commonly found in Java-based applications that use common and popular open source components."
			echo -e "$TYellow Source: $TDefault https://www.owasp.org/index.php/Category:OWASP_WebGoat_Project"
			echo -e "         https://github.com/WebGoat/WebGoat"
			echo -e "$TYellow Rules: $TDefault The goal of this lab is to train like a hacker not a script kiddie"
		;;
		dvwa)
			echo -e "$TCian Information about Damn Vulnerable Web Application - dvwa $TDefault"
			echo -e "$TYellow Description: $TDefault DVWA is a PHP/MySQL web application that is damn vulnerable."
			echo -e "	           Its main goal is to be an aid for security professionals to test their skills and tools in a legal environment, "
			echo -e "              help web developers better understand the processes of securing web applications and to aid both students"
			echo -e "	           & teachers to learn about web application security in a controlled class room environment"
			echo -e "$TYellow Source: $TDefault https://github.com/digininja/DVWA"
			echo -e "$TYellow Rules: $TDefault The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "$TYellow Solutions: $TDefault http://www.adminso.es/recursos/Proyectos/PFM/2011_12/PFM_DVWA.pdf"
			echo -e "            https://bughacking.com/dvwa-ultimate-guide-first-steps-and-walkthrough/"
		;;    
		mutillidae)
			echo -e "$TCian Information about OWASP Mutillidae 2 Project - mutillidae $TDefault"
			echo -e "$TYellow Description: $TDefault OWASP Mutillidae II is a free, open-source, deliberately vulnerable web application providing a target for web-security training."
			echo -e "	           This is an easy-to-use web hacking environment designed for labs, security enthusiasts, classrooms, CTF, and vulnerability assessment tool targets."
			echo -e "$TYellow Source: $TDefault https://www.owasp.org/index.php/OWASP_Mutillidae_2_Project"
			echo -e "         https://github.com/webpwnized/mutillidae"
			echo -e "$TYellow Rules: $TDefault The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "$TYellow Tutorial: $TDefault https://www.youtube.com/user/webpwnized"
			echo -e "$TYellow Solutions: $TDefault https://matrixlabsblog.wordpress.com/2019/04/14/owasp-mutillidae-walkthrough/"
		;;
		juiceshop)
			echo -e "$TCian Information about OWASP Juice Shop - juiceshop $TDefault"
			echo -e "$TYellow Description: $TDefault OWASP Juice Shop is probably the most modern and sophisticated insecure web application!"
			echo -e "$TYellow Source: $TDefault https://owasp-juice.shop"
			echo -e "         https://github.com/juice-shop/juice-shop"
			echo -e "$TYellow Rules: $TDefault The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "$TYellow Solutions: $TDefault https://systemweakness.com/owasp-juice-shop-tryhackme-walkthrough-2023-detailed-bea74989325b"
			echo -e "            https://medium.com/@corybantic/tryhackme-owasp-juice-shop-walkthrough-ab07d12dbdc"
			echo -e "            https://tomsitcafe.com/2023/01/16/tryhackme-owasp-juice-shop-write-up/"
		;;
		securitysheperd)
			echo -e "$TCian Information about OWASP Security Shepherd - securitysheperd $TDefault"
			echo -e "$TYellow Description: $TDefault OWASP Security Shepherd is a web and mobile application security training platform. "
			echo -e "              Security Shepherd has been designed to foster and improve security awareness among a varied skill-set demographic. "
			echo -e "              The aim of this project is to take AppSec novices or experienced engineers and sharpen their penetration testing skillset to security expert status"
			echo -e "$TYellow Rules: $TDefault The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "$TYellow Source: $TDefault https://www.owasp.org/index.php/OWASP_Security_Shepherd"
			echo -e "         https://github.com/OWASP/SecurityShepherd"
		;;
		vulnerablewp)
			echo -e "$TCian Information about Vulnerable WordPRess - vulnerablewp $TDefault"
			echo -e "$TYellow Source: $TDefault https://github.com/wpscanteam/VulnerableWordpress"
		;;
		securityninjas)    
			echo -e "$TCian Information about OpenDNS Security Ninjas - securityninjas $TDefault"
			echo -e "$TYellow Description: $TDefault OpenDNS Security Ninjas AppSec Training. "
			echo -e "              This hands-on training lab consists of 10 fun real world like hacking exercises, corresponding to each of the 2013 OWASP Top 10 vulnerabilities."
			echo -e "$TYellow Source: $TDefault https://github.com/opendns/Security_Ninjas_AppSec_Training"
			echo -e "$TYellow Rules: $TDefault The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "$TYellow Course: $TDefault https://es.slideshare.net/OpenDNS/security-ninjas-opensource"
		;;
		altoro)    
			echo -e "$TCian Information about Altoro Mutual Vulnerable Bank - altoro $TDefault"
			echo -e "$TYellow Description: $TDefault AltoroJ is a sample banking J2EE web application."
			echo -e "              It shows what happens when web applications are written with consideration of app functionality but not app security"
			echo -e "$TYellow Source: $TDefault https://github.com/HCL-TECH-SOFTWARE/AltoroJ"
			echo -e "$TYellow Rules: $TDefault The goal of this lab is to train like a hacker not a script kiddie"
		;;
		graphql)
			echo -e "$TCian Information about Grap QL - graphql $TDefault"
			echo -e "$TYellow Rules: $TDefault The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "$TYellow Source: $TDefault https://carvesystems.com/news/the-5-most-common-graphql-security-vulnerabilities/"
		;;
		jvl)    
			echo -e "$TCian Information about Java Vulnerable Lab - jvl $TDefault"
			echo -e "$TYellow Description: $TDefault This is a Vulnerable Web Application developed by Cyber Security and Privacy Foundation(www.cysecurity.org). This app is intended for the Java Programmers and other people who wish to learn about Web application vulnerabilities and write secure code"
			echo -e "$TYellow Source: $TDefault https://github.com/CSPF-Founder/JavaVulnerableLab"
			echo -e "$TYellow Install: $TDefault Go to install.jsp anc click on the button"
			echo -e "$TYellow Rules: $TDefault The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "        No automated tools (like SQLmap, dirb...)"
			echo -e "        Only hand-crafted payloads or home-made scripts"
			echo -e "        It's recommended to not read the source code. If you are stuck: Inspect element for (big) nudges."
			echo -e "$TYellow Solutions: $TDefault https://github.com/CSPF-Founder/JavaSecurityCourse"
		;;
		w4p | web4pentester)
			echo -e "$TCian Information about Web for Pentester I - web4pentester/w4p $TDefault"
			echo -e "$TYellow Source: $TDefault https://pentesterlab.com/exercises/web_for_pentester/course"
			echo -e "$TYellow Rules: $TDefault The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "        No automated tools (like SQLmap, dirb...)"
			echo -e "        Only hand-crafted payloads or home-made scripts"
			echo -e "        It's recommended to not read the source code. If you are stuck: Inspect element for (big) nudges."
		;;
		sqlilabs)
			echo -e "$TCian Information about Audi-1 SQLi labs - sqlilabs $TDefault"
			echo -e "$TYellow Source: $TDefault https://github-com.translate.goog/Audi-1/sqli-labs"
			echo -e "$TYellow Install: $TDefault Click on the link setup/resetDB to create database, create tables and populate Data"
			echo -e "$TYellow Rules: $TDefault The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "        No automated tools (like SQLmap, dirb...)"
			echo -e "        Only hand-crafted payloads or home-made scripts"
			echo -e "        It's recommended to not read the source code. If you are stuck: Inspect element for (big) nudges."
			echo -e "$TYellow Solutions: $TDefault http://dummy2dummies.blogspot.com"
			echo -e "            http://www.securitytube.net/user/Audi"
			echo -e "            https://www.facebook.com/sqlilabs"
			;;
		oxninja)
			echo -e "$TCian Information about OxNinja SQLi-Lab machine - oxninja $TDefault"
			echo -e "$TYellow Source: $TDefault https://github.com/OxNinja/SQLi-lab"
			echo -e "$TYellow Rules: $TDefault The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "        No automated tools (like SQLmap, dirb...)"
			echo -e "        Only hand-crafted payloads or home-made scripts"
			echo -e "        It's recommended to not read the source code. If you are stuck: Inspect element for (big) nudges."
			echo -e "$TYellow Solutions: $TDefault https://0xninja.fr/posts/sqli-lab/"
			;;
		*)
		  echo "ERROR: WTH! I don't recognize the project name $1" 
		  list
		;;
	esac  
	echo -e "----------------------------------------------"
}

project_startinfo_bwapp () 
{
  echo "Default username/password:  bee/bug"  

  if [ -z $1 ]
  then
    echo "Run install first to use bWapp at http://bwapp/install.php"
  else
    echo "Run install first to use bWapp at http://$1/install.php"
  fi
}

project_startinfo_webgoat7 () 
{
  echo "WebGoat 7.0 now runnung at http://webgoat7/WebGoat or http://127.6.0.1/WebGoat"
}

project_startinfo_webgoat8 () 
{
  echo "WebGoat 8.0 now runnung at http://webgoat8/WebGoat or http://127.7.0.1/WebGoat"
}

project_startinfo_webgoat81 () 
{
  echo "WebGoat 8.1 now runnung at http://webgoat81/WebGoat or http://127.17.0.1/WebGoat"
  echo "WebWolf is not mapped yet, so only challenges not using WebWolf can be completed"
}

project_startinfo_dvwa () 
{
  echo "Default username/password:   admin/password"
  echo "Remember to click on the CREATE DATABASE Button before you start"
}

project_startinfo_mutillidae () 
{
  echo "Remember to click on the create database link before you start"
}

project_startinfo_juiceshop () 
{
  echo "OWASP Juice Shop now running"
}

project_startinfo_securitysheperd () 
{
  echo "OWASP Security Sheperd running"
  echo " admin / password"
}

project_startinfo_vulnerablewp () 
{
  echo "WPScan Vulnerable Wordpress site now running"
}

project_startinfo_securityninjas ()
{
  echo "Open DNS Security Ninjas site now running"
}

project_startinfo_altoro ()
{
  echo "Sign in with username jsmith and password demo1234 to initialize database." 
  echo "Second known credential is admin/admin"
}

project_startinfo_graphql ()
{
  echo "Vulnerable GraphQL now mapped to port 80 (not 3000 as documentation states)." 
  echo "Have a look at this post for more information on this API: https://carvesystems.com/news/the-5-most-common-graphql-security-vulnerabilities/"
}

project_startinfo_jvl ()
{
  echo "Java Vulnerable Lab now mapped to port 80."
  echo "First Install: http://127.16.0.1/JavaVulnerableLab/instal.jsp"
  echo "Access: http://127.16.0.1/JavaVulnerableLab"  
}

project_startinfo_web4pentester ()
{
	echo "Web For Pentester I."
	#echo "If needed in the bash shell type: service apache2 restart && service mysql restart"
	echo "Open web explorer and go to ip that bash shell indicate you, probably (172.17.0.2 / 127.18.0.2)"
	echo "Now open bash... Type exit for quit bash shell"
	echo "----------------------------------------------"
}

project_startinfo_sqlilabs ()
{
	echo "SQLI-LABS is a platform to learn SQLI Following labs are covered for GET and POST scenarios"
}

project_startinfo_oxninja ()
{
	echo "An SQL injection playground, from basic to advanced"
}

#########################
# Common start          #
#########################
project_start ()
{
  fullname=$1	 # ex. WebGoat 7.1
  projectname=$2 # ex. webgoat7
  dockername=$3  # ex. raesene/bwapp
  ip=$4   	 # ex. 127.5.0.1
  port=$5	 # ex. 80
  port2=$6	 # optional override port (if app doesn't support portmapping)
  
  echo "Starting $fullname"
  addhost "$ip" "$projectname"

  if [ "$(sudo docker ps -aq -f name=^/$projectname$)" ]; 
  then
    echo "Running command: docker start $projectname"
    sudo docker start $projectname
  else
    if [ -n "${6+set}" ]; then
      echo "Running command: docker run --name $projectname -d -p $ip:80:$port -p $ip:$port2:$port2 $dockername"
      sudo docker run --name $projectname -d -p $ip:80:$port -p $ip:$port2:$port2 $dockername
    else echo "not set";
      echo "Running command: docker run --name $projectname -d -p $ip:80:$port $dockername"
      sudo docker run --name $projectname -d -p $ip:80:$port $dockername
    fi
  fi
  echo "DONE!"
  echo
  echo "Docker mapped to http://$projectname or http://$ip"
  echo
}


project_startpublic ()
{
  fullname=$1		# ex. WebGoat 7.1
  projectname=$2public  # ex. webgoat7
  dockername=$3  	# ex. raesene/bwapp
  internalport=$4       # ex. 8080
  publicip=$5           # ex. 192.168.0.105
  port=$6	   	# ex. 80
  
  echo "Starting $fullname for public access"

  if [ "$(sudo docker ps -aq -f name=^/$projectname$)" ]; 
  then
    echo "Running command: docker start $projectname"
    sudo docker start $projectname
  else
    echo "Running command: docker run --name $projectname -d -p $publicip:$port:$internalport $dockername"
    sudo docker run --name $projectname -d -p $publicip:$port:$internalport $dockername
  fi
  
  echo "DONE!"
  echo
  if [ $port -eq 80 ]
  then
    echo "$fullname now available on http://$publicip"
  else
    echo "$fullname now available on http://$publicip:$port"
  fi  
  echo
}


#########################
# Common stop           #
#########################
project_stop ()
{
  fullname=$1	 # ex. WebGoat 7.1
  projectname=$2 # ex. webgoat7

  if [ "$(sudo docker ps -q -f name=^/$projectname$)" ]; 
  then
    echo "Stopping... $fullname"
    echo "Running command: docker stop $projectname"
    sudo docker stop $projectname
    removehost "$projectname"
  fi

  projectname=${projectname}public
  if [ "$(sudo docker ps -q -f name=^/$projectname$)" ]; 
  then
    echo "Stopping... $fullname"
    echo "Running command: docker stop $projectname"
    sudo docker stop $projectname
  fi
}

project_running()
{
  projectname=$1
  shortname=$2
  url=$3
  running=0

  if [ "$(sudo docker ps -q -f name=^/${shortname}$)" ]; then
    echo -e "$projectname:$shortname	$TGreen	running at $url (localhost) $TDefault"
    running=1
  fi
  if [ "$(sudo docker ps -q -f name=^/${shortname}public$)" ]; then
    echo -e "$projectname:$shortname	$TGreen	running (public) $TDefault"
    running=1
  fi  
  if [ $running -eq 0 ];
  then
    echo -e "$projectname:$shortname		$TRed not running $TDefault"
  fi 
}


project_status()
{
  project_running "bWapp                        " "bwapp" "http://bwapp"
  project_running "WebGoat 7.1                  " "webgoat7" "http://webgoat7/WebGoat"
  project_running "WebGoat 8.0                  " "webgoat8" "http://webgoat8/WebGoat"
  project_running "WebGoat 8.1                  " "webgoat81" "http://webgoat81/WebGoat"
  project_running "DVWA                         " "dvwa" "http://dvwa"
  project_running "Mutillidae II                " "mutillidae" "http://mutillidae"
  project_running "OWASP Juice Shop             " "juiceshop" "http://juiceshop"
  project_running "WPScan Vulnerable Wordpress  " "vulnerablewp" "http://vulnerablewp"
  project_running "OpenDNS Security Ninjas      " "securityninjas" "http://securityninjas"
  project_running "Altoro Mutual                " "altoro" "http://altoro"
  project_running "Vulnerable GraphQL API       " "graphql" "http://graphql"
  #project_running "Java Vulnerable Lab          " "jvl" "http://jvl"
  #project_running "Web For Pentester I          " "w4p" "http://w4p"
  project_running "Web For Pentester I          " "web4pentester" "http://w4p http://127.18.0.1"
  project_running "Audi-1 SQLi Labs             " "sqlilabs" "http://sqlilabs http://127.19.0.1"
  project_running "OxNinja SQLi-Lab             " "oxninja" "http://oxninja http://127.20.0.1"
}


project_start_dispatch()
{
  case "$1" in
    bwapp)
		openUrl "http://127.5.0.1/install.php"
		project_start "bWAPP" "bwapp" "raesene/bwapp" "127.5.0.1" "80"
		project_startinfo_bwapp
    ;;
    webgoat7)
		openUrl "http://127.6.0.1/WebGoat"
		project_start "WebGoat 7.1" "webgoat7" "webgoat/webgoat-7.1" "127.6.0.1" "8080"
		project_startinfo_webgoat7
    ;;
    webgoat8)
		openUrl "http://127.7.0.1/WebGoat"
		project_start "WebGoat 8.0" "webgoat8" "webgoat/webgoat-8.0" "127.7.0.1" "8080"
		project_startinfo_webgoat8
    ;;    
    webgoat81)
		openUrl "http://127.17.0.1/WebGoat"
		project_start "WebGoat 8.1" "webgoat81" "webgoat/goatandwolf" "127.17.0.1" "8080"
		project_startinfo_webgoat81
    ;;    
    dvwa)
		openUrl "http://127.8.0.1"		
		project_start "Damn Vulnerable Web Appliaction" "dvwa" "vulnerables/web-dvwa" "127.8.0.1" "80"
		project_startinfo_dvwa
    ;;    
    mutillidae)
		openUrl "http://127.9.0.1"
		project_start "Mutillidae II" "mutillidae" "citizenstig/nowasp" "127.9.0.1" "80"
		project_startinfo_mutillidae
    ;;
    juiceshop)
		openUrl "http://127.10.0.1:3000"
		project_start "OWASP Juice Shop" "juiceshop" "bkimminich/juice-shop" "127.10.0.1" "3000"
		project_startinfo_juiceshop
    ;;
    securitysheperd)
		openUrl "http://127.11.0.1"
		project_start "OWASP Security Shepard" "securitysheperd" "ismisepaul/securityshepherd" "127.11.0.1" "80"
		project_startinfo_securitysheperd
    ;;
    vulnerablewp)
		openUrl "http://127.12.0.1"
		project_start "WPScan Vulnerable Wordpress" "vulnerablewp" "eystsen/vulnerablewordpress" "127.12.0.1" "80" "3306"
		project_startinfo_vulnerablewp
    ;;
    securityninjas)    
		openUrl "http://127.13.0.1"
		project_start "Open DNS Security Ninjas" "securityninjas" "opendns/security-ninjas" "127.13.0.1" "80"
		project_startinfo_securityninjas
    ;;
    altoro)    
		openUrl "http://127.14.0.1:8080"
		project_start "Altoro Mutual" "altoro" "eystsen/altoro" "127.14.0.1" "8080"
		project_startinfo_altoro
    ;;
    graphql)
		openUrl "http://127.15.0.1:3000"    
		project_start "Vulnerable GraphQL API" "graphql" "carvesystems/vulnerable-graphql-api" "127.15.0.1" "3000"
		project_startinfo_graphql
    ;;
    jvl)    
		project_start "Java Vulnerable Lab" "jvl" "m4n3dw0lf/javavulnerablelab" "127.16.0.1" "8080"
		openUrl "http://127.16.0.1:8080/JavaVulnerableLab/install.jsp"
		sudo docker run --name javavulnerablelab -h jvl -i -t --rm -p 127.16.0.1:8080:8080 m4n3dw0lf/javavulnerablelab bash -c "service apache2 start && service mysql start && bash"
		project_startinfo_jvl
    ;;
    web4pentester)
      project_startinfo_web4pentester
      #In this particular case in the dockername is attached the command we need to launch on the container
      #sudo docker run --name web4pentester -h w4p -i -t --rm -p 127.18.0.1:80:80 tiizss/webforpentester bash
	  openUrl "http://127.18.0.1"
	  sudo docker run --name web4pentester -h w4p -i -t --rm -p 127.18.0.1:80:80 tiizss/webforpentester:1.0 bash -c "service apache2 start && service mysql start && bash"
	  #project_start "Web for Pentester I" "w4p" "tiizss/webforpentester:1.0 bash -c 'service apache2 start && service mysql start && bash'" "127.18.0.1" "80"
    ;;
	w4p)
      project_startinfo_web4pentester
      # In this particular case in the dockername is attached the command we need to launch on the container
      project_start "Web for Pentester I" "w4p" "tiizss/webforpentester1:1.0" "127.18.0.1" "80"
	  ;;
	sqlilabs)
		project_startinfo_sqlilabs
		project_start "Audi-1 SQLi Labs" "sqlilabs" "c0ny1/sqli-labs:0.1" "127.19.0.1" "80"
		openUrl "http://127.19.0.1"
		;;
    oxninja)
		project_startinfo_oxninja
		if [[ ! -d "oxninja-sqlilab" ]]; then
			git clone https://github.com/OxNinja/SQLi-lab oxninja-sqlilab
		fi
		cd oxninja-sqlilab	
		if ! grep -q "container_name: oxninja" docker-compose.yml; then
			sed -i "/web:/at        container_name: oxninja" docker-compose.yml
			sed -i "s/^t//" docker-compose.yml
		fi
		sed -i "s|-\s*80\:\s*80|-\s*127.20.0.1\:\s*80\:\s*80|g" docker-compose.yml
		sed -i "s/172.16.0/172.16.1/g" docker-compose.yml
		openUrl "http://127.20.0.1" 
		bash ./build.sh	&
	#	project_start "OxNinja SQLi-Lab" "oxninja" "tiizss/oxninja-sqlilab" "172.16.0.2" "80"
		;;
    *)
      echo "ERROR: Project start dispatch doesn't recognize the project name $1" 
    ;;
  esac  
}


project_startpublic_dispatch()
{
  publicip=$2
  port=$3
  
  case "$1" in
    bwapp)
      project_startpublic "bWAPP" "bwapp" "raesene/bwapp" "80" $publicip $port
      project_startinfo_bwapp $publicip
    ;;
    webgoat7)
      project_startpublic "WebGoat 7.1" "webgoat7" "webgoat/webgoat-7.1" "8080" $publicip $port
      project_startinfo_webgoat7 $publicip
    ;;
    webgoat8)
      project_startpublic "WebGoat 8.0" "webgoat8" "webgoat/webgoat-8.0" "8080" $publicip $port
      project_startinfo_webgoat8 $publicip
    ;;    
    webgoat81)
      project_startpublic "WebGoat 8.1" "webgoat81" "webgoat/goatandwolf" "8080" $publicip $port
      project_startinfo_webgoat8 $publicip
    ;;    
    dvwa)
      project_startpublic "Damn Vulnerable Web Appliaction" "dvwa" "vulnerables/web-dvwa" "80" $publicip $port
      project_startinfo_dvwa $publicip
    ;;    
    mutillidae)
      project_startpublic "Mutillidae II" "mutillidae" "citizenstig/nowasp" "80" $publicip $port
      project_startinfo_mutillidae $publicip
    ;;
    juiceshop)
      project_startpublic "OWASP Juice Shop" "juiceshop" "bkimminich/juice-shop" "3000" $publicip $port
      project_startinfo_juiceshop $publicip
    ;;
    securitysheperd)
      project_startpublic "OWASP Security Shepard" "securitysheperd" "ismisepaul/securityshepherd" "80" $publicip $port
      project_startinfo_securitysheperd $publicip
    ;;
    vulnerablewp)
      project_startpublic "WPScan Vulnerable Wordpress" "vulnerablewp" "eystsen/vulnerablewordpress" "3306" $publicip $port
      project_startinfo_vulnerablewp $publicip
    ;;
    securityninjas)    
      project_startpublic "Open DNS Security Ninjas" "securityninjas" "opendns/security-ninjas" "80" $publicip $port
      project_startinfo_securityninjas $publicip
    ;;
    altoro)    
      project_startpublic "Altoro Mutual" "altoro" "eystsen/altoro" "8080" $publicip $port
      project_startinfo_altoro $publicip
    ;;
    graphql)    
      project_startpublic "Vulnerable GraphQL API" "graphql" "carvesystems/vulnerable-graphql-api" "3000" $publicip $port
      project_startinfo_graphql $publicip
    ;;
    jvl)    
      project_startpublic "Java Vulnerable Lab" "jvl" "m4n3dw0lf/javavulnerablelab" "8080" $publicip $port
      project_startinfo_jvl $publicip
    ;;
    w4p)    
      # In this particular case in the dockername is attached the command we need to launch on the container
      project_startpublic "Web For Pentester" "web4pentester" "tiizss/webforpentester1:1.0" "80" $publicip $port
      project_startinfo_web4pentester $publicip
    ;;
    web4pentester)    
      # In this particular case in the dockername is attached the command we need to launch on the container
      project_startpublic "Web For Pentester" "web4pentester" "tiizss/webforpentester bash" "80" $publicip $port
      project_startinfo_web4pentester $publicip
    ;;
	sqlilabs)
      project_startpublic "Audi-1 SQLi Labs" "sqlilabs" "c0ny1/sqli-labs:0.1" "80" $publicip $port
      project_startinfo_sqlilabs $publicip
    ;;
    oxninja)
      #project_startpublic "OxNinja SQLi-Lab" "oxninja" "tiizss/oxninja-sqlilab" "80" $publicip $port
      #	project_startinfo_oxninja $publicip
    ;;
    *)
    echo "ERROR: Project public dispatch doesn't recognize the project name $1" 
    ;;
  esac  
}


project_stop_dispatch()
{
  case "$1" in
    bwapp)
      project_stop "bWAPP" "bwapp"
    ;;
    webgoat7)
      project_stop "WebGoat 7.1" "webgoat7"
    ;;
    webgoat8)
      project_stop "WebGoat 8.0" "webgoat8"
    ;;
    webgoat81)
      project_stop "WebGoat 8.1" "webgoat81"
    ;;
    dvwa)
      project_stop "Damn Vulnerable Web Appliaction" "dvwa"
    ;;
    mutillidae)
      project_stop "Mutillidae II" "mutillidae"
    ;;
    juiceshop)
      project_stop "OWASP Juice Shop" "juiceshop"
    ;;
    securitysheperd)
      project_stop "OWASP Security Sheperd" "securitysheperd"
    ;;
    vulnerablewp)
      project_stop "WPScan Vulnerable Wordpress" "vulnerablewp"
    ;;
    securityninjas)
      project_stop "Open DNS Security Ninjas" "securityninjas"
    ;;
    altoro)
      project_stop "Altoro Mutual" "altoro"
    ;;
    graphql)
      project_stop "Vulnerable GraphQL API" "graphql"
    ;;
    jvl)
      project_stop "Java Vulnerable Lab" "jvl"
    ;;
    web4pentester)
      project_stop "Web For Pentester" "web4pentester"
    ;;
    w4p)
      project_stop "Web For Pentester" "w4p"
    ;;
	sqlilabs)
		project_stop "Audi-1 SQLi Labs" "sqlilabs"
	;;
    oxninja)
		project_stop "OxNinja SQLi-Lab" "oxninja"
	;;
    *)
    echo "ERROR: Project stop dispatch doesn't recognize the project name $1" 
    ;;
  esac  
}

#########################
# Checking Privileges   #
#########################
function check_runpriv (){
	echo -e "$TCian Checking user privileges $TDefault"
	echo -en " Running docker without sudo:  "
	if groups | grep -q docker; then
		echo -e "$TGreen YES $TDefault"
	else
		echo -e "$TYellow NEED SUDO $TDefault"
	fi
	echo -en " User has sudo privileges:     "
	if groups | grep -q sudo; then
		echo -e "$TGreen YES - Elevating privileges $TDefault"
		sudo docker &> /dev/null
	else
		echo -e "$TRed NO $TDefault - To run the script you have to use a user that can run docker."
		exit
	fi
}


#########################
# Main switch case      #
#########################
	display_logo
	display_info
	check_runpriv
	check_docker
	echo -e "$TDefault-----------------------------------------------------------------------------------------"
	
	case "$1" in
		start)
			if [ -z "$2" ]
			then
				echo "ERROR: Option start needs project name in lowercase"
				echo 
					list # call list ()
				break
			fi
			project_start_dispatch $2
			;;
			
		startpublic)
			if [ -z "$2" ]
			then
				echo "ERROR: Option start needs project name in lowercase"
				echo 
				list # call list ()
				break
			fi

			if [ -z "$4" ]
			then
				port=80
			else
				port=$4
			fi

			if [ "$3" ]
			then
				publicip=$3
			else
				publicip=`hostname -I | cut -d" " -f1`
		
				echo "Continue using local IP address $publicip?"
				
				select yn in "Yes" "No"; do
					case $yn in
						Yes)  
							break;;
						No) 
							echo "Specify the correct IP address.";  
							echo " ex."; 
							echo "   $0 startpublic w4p 192.168.0.105"; 
							exit;;
					esac
				done
			fi
		
			listen="$publicip:$port"
			if [ "$(netstat -ln4 | grep -w $listen )" ]
			then
				echo "$publicip already listening on port $port"
				echo "Free up the port or select a different port to bind $2"
				exit
			fi

			project_startpublic_dispatch $2 $publicip $port
				echo "WARNING! Only do this in trusted lab environment. WARNING!"
				echo "WARNING! Anyone with nettwork access can now pwn this machine! WARNING!" 
			;;
			
		stop)
			if [ -z "$2" ]
			then
				echo "ERROR: Option start needs project name in lowercase"
				echo 
				list # call list ()
				break
			fi
			project_stop_dispatch $2
			;;
			
		list)
			list # call list ()
			;;
			
		status)
			echo " Showing STATUS of the Docker containers"
			echo "-----------------------------------------------------------------------------------------"
			project_status # call project_status ()
			echo "-----------------------------------------------------------------------------------------"
			;;
			
		info)
			if [ -z "$2" ]
			then
				echo -en "Please choose one 4 detailed information: "
				list # call list ()
			break
			fi
			project_info $2
			#info $2
			;;
			
		*)
			display_help
			;;
	esac

	