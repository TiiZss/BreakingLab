#!/bin/bash
# 2023/09/16 - TiiZss añade JavaVulnerableLab
# 2023/09/18 - TiiZss modifica parámetros. Se incluye Web For Pentester
# 2023/10/30 - TiiZss corrección de errores
# 2023/11/01 - TiiZss - JavaVulnerableLab no funciona. No hay conectividad con mysql desde WSL.
# 2023/11/09 - TiiZss - w4p no funciona no arranca mysql. web4pentester funciona.
# 2023/12/15 - TiiZss - Audi 1 SQLi Labs
# 2023/12/17 - TiiZss - OxNinja SQLi Lab
# 2023/12/24 - TiiZss - corrección de errores y optimización. Se añade RedTiger's Hackit Online
# 2024/01/26 - TiiZss - se modifica el sistema de menus
# 2024/03/15 - TiiZss - Se añaden HackTheBox/TryHackMe Online
# 2024/03/16 - TiiZss - Se añaden PortSwigger / VulnHub / CTFTime Online
# 2024/04/17 - Cryoox - Se añade OWASP Bricks

ETC_HOSTS=/etc/hosts

#Tmux vars
session_name="breakinglab"
tmux_main_window="breakinglab-Main"
no_hardcore_exit=0

#########################
# Text Style            #
#########################
TxDefault="\e[0m"
TxBold="\e[1m"
TxUnderline="\e[2m"

#########################
# Text Colors           #
#########################
TCD="\e[0;0m"
TCBlack="\e[0;30m"
TCR="\e[0;31m"
TCG="\e[0;32m"
TCY="\e[1;33m"
TCB="\e[0;34m"
TCM="\e[0;35m"
TCC="\e[0;36m"
TCW="\e[0;37m"

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
	echo -e "$BGGreen               35$BGWhite$TCG                                       TiiZss  $TCW$BGGreen               57$BGWhite$TCG         $TCW"
	echo -e "$BGGreen ██████  ██████  $BGWhite$TCG ███████  █████  ██   ██ ██ ███    ██  ██████  $TCW$BGGreen ██       █████  $BGWhite$TCG ██████  $TCW"
	echo -e "$BGGreen ██   ██ ██   ██ $BGWhite$TCG ██      ██   ██ ██  ██  ██ ████   ██ ██       $TCW$BGGreen ██      ██   ██ $BGWhite$TCG ██   ██ $TCW"
	echo -e "$BGGreen ██████  ██████  $BGWhite$TCG █████   ███████ █████   ██ ██ ██  ██ ██   ███ $TCW$BGGreen ██      ███████ $BGWhite$TCG ██████  $TCW"
	echo -e "$BGGreen ██   ██ ██   ██ $BGWhite$TCG ██      ██   ██ ██  ██  ██ ██  ██ ██ ██    ██ $TCW$BGGreen ██      ██   ██ $BGWhite$TCG ██   ██ $TCW"
	echo -e "$BGGreen ██████  ██   ██ $BGWhite$TCG ███████ ██   ██ ██   ██ ██ ██   ████  ██████  $TCW$BGGreen ███████ ██   ██ $BGWhite$TCG ██████  $TCW"
	echo -e "$BGGreen                 $BGWhite$TCG v.$(print_date)         $TCW$BGGreen                 $BGWhite$TCG    BETA $TCW"
	echo -e "$TCD-----------------------------------------------------------------------------------------"
}

function display_info {
	echo -e "  BreakingLab Script a Local Pentest Lab Management Script (Docker based)"
	echo -e "  Modified by TiiZss. Version: $(print_date)"
    echo -e "  This scripts uses docker and hosts alias to make web apps available on localhost"
    #echo -e "-----------------------------------------------------------------------------------------"
}

#########################
# The command line help #
#########################
display_help() {
    echo -e "  Usage: $0 {list|status|info|start|startpublic|stop|online} [projectname]" >&2
    echo -e "   Ex."
    echo -e "   $0 list"
    echo -e "   	List all available projects"
    echo -e "   $0 status"
    echo -e "  	Show status for all docker projects"
    echo -e "   $0 start w4p"
    echo -e "   	Start w4p docker project and make it available on localhost" 
    echo -e "   $0 startpublic w4p"
    echo -e "   	Start w4p docker project and make it publicly available (to anyone with network connectivity to the machine)" 
    echo -e "   $0 info w4p"
    echo -e "   	Show information about w4p project"
    echo -e "   $0 stop w4p"
    echo -e "   	Stop w4p docker project "
    echo -e "   $0 online w4p"
    echo -e "   	Start Online w4p project "
    #exit 1
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
      echo "  Docker está instalado y funcionando"
      return 0
    else
      # Docker está instalado pero no está funcionando
      echo "  Docker está instalado pero no está funcionando"
      return 1
    fi
  else
    # Docker no está instalado
    echo "  Docker no está instalado"
    return 1
  fi
}

function docker_is_running() {
  # Verifica si el proceso de Docker Desktop está en ejecución
  ps -ef | grep -q "dockerd"
  if [ $? -eq 0 ]; then
    # Docker Desktop está en funcionamiento
    echo "  Docker Desktop está en funcionamiento"
    return 0
  else
    # Docker Desktop no está en funcionamiento
    echo "  Docker Desktop no está en funcionamiento"
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
			echo -e "$TCR Docker Desktop isn't running. $TCD"
			start_docker
		else
			echo -e "$TCG Docker is running. $TCD "
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
			echo -e "$TCG Docker is running. $TCD "
		then 
			echo -e "$TCR Docker isn't running. $TCD"
			start_docker
		fi
	fi
}

function start_docker () {
	echo -n " Do you want to start docker now (y/n)?"
	read answer
	if echo "$answer" | grep -iq "^y"; then
		if is_wsl; then
			cmd.exe /c "C:\Program Files\Docker\Docker\docker desktop.exe"
		else
			sudo service docker start
		fi
		echo -e "$TCG Starting Docker. $TCD"
		return 1
	else	
		echo -e "$TCR If you don't start docker script will not be able to run docker applications. Quitting. $TCD"
		return 0 # exit
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
    echo " Available Docker Pentest Applications " >&2
    echo "-----------------------------------------------------------------------------------------"
	echo "  bwapp           - bWAPP PHP/MySQL based from itsecgames.com"
    echo "  webgoat7        - OWASP WebGoat 7.1"
    echo "  webgoat8        - OWASP WebGoat 8.0"
    echo "  webgoat81       - OWASP WebGoat 8.1"
    echo "  dvwa            - Damn Vulnerable Web Application"
    echo "  mutillidae      - OWASP Mutillidae II"
    echo "  juiceshop       - OWASP Juice Shop"
    echo "  securitysheperd - OWASP Security Shepherd"
	echo "  vulnerablewp    - WPScan Vulnerable Wordpress"
    echo "  securityninjas  - OpenDNS Security Ninjas"
    echo "  altoro          - Altoro Mutual Vulnerable Bank"
    echo "  graphql         - Vulnerable GraphQL API"
    echo "  jvl             - CSPF Java Vulnerable Lab Web Application"
    echo "  w4p             - PentesterLab Web For Pentester I "
    echo "  web4pentester   - PentesterLab Web For Pentester I "
    echo "  sqlilabs        - Audi-1 SQLi labs"
	echo "  oxninja         - OxNinja SQLi-lab"
	echo "  bricks          - OWASP Bricks"
	echo "-----------------------------------------------------------------------------------------"
    echo " Available Online Pentest Applications " >&2
    echo "-----------------------------------------------------------------------------------------"
    echo "  redtiger        - RedTiger's Hackit               (online)"
	echo "  portswigger     - PortSwigger SQLi Labs           (online)"
	echo "  hacksplaining   - Hacksplanning SQLi Lab          (online)"
	echo "  synk            - Synk Learn                      (online)"
	echo "  thmsqli         - Try Hack Me SQLi Lab            (online)"
	echo "-----------------------------------------------------------------------------------------"
	echo " Available Online Hacking Training Webs - User registration needed" >&2
    echo "-----------------------------------------------------------------------------------------"
	echo "  kontra          - Kontra SQLi Lab                 (online)"
	echo "  thm             - Try Hack Me                     (online)"
	echo "  hdb             - Hack The Box                    (online)"
	echo "  vulnhub         - VulnHub                         (online)"
	echo "  ps              - PortSwigger WebSecurity Academy (online)"
	echo "  ctftime         - CTFTime                         (online)"
	echo "-----------------------------------------------------------------------------------------"
    #exit 1
}

function list_dockerapps() {
    echo -en "$TCC"
	echo -e " Available Docker Pentest Applications " >&2
    echo -e "-----------------------------------------------------------------------------------------"
	echo -en "$TCD"
	echo -e "$TCG bwapp           $TCD- bWAPP PHP/MySQL based from itsecgames.com"
    echo -e "$TCG webgoat7        $TCD- OWASP WebGoat 7.1"
    echo -e "$TCG webgoat8        $TCD- OWASP WebGoat 8.0"
    echo -e "$TCG webgoat81       $TCD- OWASP WebGoat 8.1"
    echo -e "$TCG dvwa            $TCD- Damn Vulnerable Web Application"
    echo -e "$TCG mutillidae      $TCD- OWASP Mutillidae II"
    echo -e "$TCG juiceshop       $TCD- OWASP Juice Shop"
    echo -e "$TCG securitysheperd $TCD- OWASP Security Shepherd"
	echo -e "$TCG vulnerablewp    $TCD- WPScan Vulnerable Wordpress"
    echo -e "$TCG securityninjas  $TCD- OpenDNS Security Ninjas"
    echo -e "$TCG altoro          $TCD- Altoro Mutual Vulnerable Bank"
    echo -e "$TCG graphql         $TCD- Vulnerable GraphQL API"
    echo -e "$TCG jvl             $TCD- CSPF Java Vulnerable Lab Web Application"
    echo -e "$TCG w4p             $TCD- PentesterLab Web For Pentester I "
    echo -e "$TCG web4pentester   $TCD- PentesterLab Web For Pentester I "
    echo -e "$TCG sqlilabs        $TCD- Audi-1 SQLi labs"
	echo -e "$TCG oxninja         $TCD- OxNinja SQLi-lab"
	echo -e "$TCG bricks          $TCD- OWASP Bricks"
	echo -e "-----------------------------------------------------------------------------------------"
}

function list_onlineapps () {
	clear
	display_logo
	echo -en "$TCC"
    echo -e " Available Online Pentest Applications " >&2
    echo -e "-----------------------------------------------------------------------------------------"
	echo -en "$TCD"
    echo -e " $TCG redtiger      $TCD- RedTiger's Hackit      (online)"
	echo -e " $TCG portswigger   $TCD- PortSwigger SQLi Labs  (online)"
	echo -e " $TCG hacksplaining $TCD- Hacksplanning SQLi Lab (online)"
	echo -e " $TCG synk          $TCD- Synk Learn             (online)"
	echo -e " $TCG thmsqli       $TCD- Try Hack Me SQLi Lab   (online)"
	echo -e " $TCG kontra        $TCD- Kontra SQLi Lab        (online)"
	echo -e "-----------------------------------------------------------------------------------------"
	echo -en "$TCB"
    echo -e " Available Online Hacking Training Webs. User registration needed" >&2
    echo -e "-----------------------------------------------------------------------------------------"
	echo -en "$TCD"
    echo -e " $TCG thm           $TCD- Try Hack Me                     (online)"
	echo -e " $TCG hdb           $TCD- Hack The Box                    (online)"
	echo -e " $TCG vulnhub       $TCD- VulnHub                         (online)"
	echo -e " $TCG ps            $TCD- PortSwigger WebSecurity Academy (online)"
	echo -e " $TCG ctftime       $TCD- CTFTime                         (online)"
	echo -e "-----------------------------------------------------------------------------------------"
    #exit 1
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
			echo -e "$TCC Information about bWAPP an extremely buggy web app! - bwapp $TCD"
			echo -e "$TCY Description: $TCD bWAPP, or a buggy web application, is a free and open source deliberately insecure web application."
			echo -e "              It helps security enthusiasts, developers and students to discover and to prevent web vulnerabilities."
			echo -e "              bWAPP prepares one to conduct successful penetration testing and ethical hacking projects."
			echo -e "$TCY Rules: $TCD The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "$TCY Tutorial: $TCD https://www.youtube.com/playlist?list=PLSbrmTUy4daOsm6ky-M5QmUnV31BkZ_6X"
			echo -e "$TCY Solutions: $TCD https://wooly6bear.files.wordpress.com/2016/01/bwapp-tutorial.pdf"
			echo -e "$TCY Source: $TCD http://www.itsecgames.com"
		;;
		webgoat*)
			echo -e "$TCC Information about OWASP WebGoat 7,8,8.1 $TCD"
			echo -e "$TCY Description: $TCD WebGoat is a deliberately insecure application that allows interested developers just like you to test"
			echo -e "              vulnerabilities commonly found in Java-based applications that use common and popular open source components."
			echo -e "$TCY Source: $TCD https://www.owasp.org/index.php/Category:OWASP_WebGoat_Project"
			echo -e "         https://github.com/WebGoat/WebGoat"
			echo -e "$TCY Rules: $TCD The goal of this lab is to train like a hacker not a script kiddie"
		;;
		dvwa)
			echo -e "$TCC Information about Damn Vulnerable Web Application - dvwa $TCD"
			echo -e "$TCY Description: $TCD DVWA is a PHP/MySQL web application that is damn vulnerable."
			echo -e "	           Its main goal is to be an aid for security professionals to test their skills and tools in a legal environment, "
			echo -e "              help web developers better understand the processes of securing web applications and to aid both students"
			echo -e "	           & teachers to learn about web application security in a controlled class room environment"
			echo -e "$TCY Source: $TCD https://github.com/digininja/DVWA"
			echo -e "$TCY Rules: $TCD The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "$TCY Solutions: $TCD http://www.adminso.es/recursos/Proyectos/PFM/2011_12/PFM_DVWA.pdf"
			echo -e "            https://bughacking.com/dvwa-ultimate-guide-first-steps-and-walkthrough/"
		;;    
		mutillidae)
			echo -e "$TCC Information about OWASP Mutillidae 2 Project - mutillidae $TCD"
			echo -e "$TCY Description: $TCD OWASP Mutillidae II is a free, open-source, deliberately vulnerable web application providing a target for web-security training."
			echo -e "	           This is an easy-to-use web hacking environment designed for labs, security enthusiasts, classrooms, CTF, and vulnerability assessment tool targets."
			echo -e "$TCY Source: $TCD https://www.owasp.org/index.php/OWASP_Mutillidae_2_Project"
			echo -e "         https://github.com/webpwnized/mutillidae"
			echo -e "$TCY Rules: $TCD The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "$TCY Tutorial: $TCD https://www.youtube.com/user/webpwnized"
			echo -e "$TCY Solutions: $TCD https://matrixlabsblog.wordpress.com/2019/04/14/owasp-mutillidae-walkthrough/"
		;;
		juiceshop)
			echo -e "$TCC Information about OWASP Juice Shop - juiceshop $TCD"
			echo -e "$TCY Description: $TCD OWASP Juice Shop is probably the most modern and sophisticated insecure web application!"
			echo -e "$TCY Source: $TCD https://owasp-juice.shop"
			echo -e "         https://github.com/juice-shop/juice-shop"
			echo -e "$TCY Rules: $TCD The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "$TCY Solutions: $TCD https://systemweakness.com/owasp-juice-shop-tryhackme-walkthrough-2023-detailed-bea74989325b"
			echo -e "            https://medium.com/@corybantic/tryhackme-owasp-juice-shop-walkthrough-ab07d12dbdc"
			echo -e "            https://tomsitcafe.com/2023/01/16/tryhackme-owasp-juice-shop-write-up/"
		;;
		securitysheperd)
			echo -e "$TCC Information about OWASP Security Shepherd - securitysheperd $TCD"
			echo -e "$TCY Description: $TCD OWASP Security Shepherd is a web and mobile application security training platform. "
			echo -e "              Security Shepherd has been designed to foster and improve security awareness among a varied skill-set demographic. "
			echo -e "              The aim of this project is to take AppSec novices or experienced engineers and sharpen their penetration testing skillset to security expert status"
			echo -e "$TCY Rules: $TCD The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "$TCY Source: $TCD https://www.owasp.org/index.php/OWASP_Security_Shepherd"
			echo -e "         https://github.com/OWASP/SecurityShepherd"
		;;
		vulnerablewp)
			echo -e "$TCC Information about Vulnerable WordPRess - vulnerablewp $TCD"
			echo -e "$TCY Source: $TCD https://github.com/wpscanteam/VulnerableWordpress"
		;;
		securityninjas)    
			echo -e "$TCC Information about OpenDNS Security Ninjas - securityninjas $TCD"
			echo -e "$TCY Description: $TCD OpenDNS Security Ninjas AppSec Training. "
			echo -e "              This hands-on training lab consists of 10 fun real world like hacking exercises, corresponding to each of the 2013 OWASP Top 10 vulnerabilities."
			echo -e "$TCY Source: $TCD https://github.com/opendns/Security_Ninjas_AppSec_Training"
			echo -e "$TCY Rules: $TCD The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "$TCY Course: $TCD https://es.slideshare.net/OpenDNS/security-ninjas-opensource"
		;;
		altoro)    
			echo -e "$TCC Information about Altoro Mutual Vulnerable Bank - altoro $TCD"
			echo -e "$TCY Description: $TCD AltoroJ is a sample banking J2EE web application."
			echo -e "              It shows what happens when web applications are written with consideration of app functionality but not app security"
			echo -e "$TCY Source: $TCD https://github.com/HCL-TECH-SOFTWARE/AltoroJ"
			echo -e "$TCY Rules: $TCD The goal of this lab is to train like a hacker not a script kiddie"
		;;
		graphql)
			echo -e "$TCC Information about Grap QL - graphql $TCD"
			echo -e "$TCY Rules: $TCD The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "$TCY Source: $TCD https://carvesystems.com/news/the-5-most-common-graphql-security-vulnerabilities/"
		;;
		jvl)    
			echo -e "$TCC Information about Java Vulnerable Lab - jvl $TCD"
			echo -e "$TCY Description: $TCD This is a Vulnerable Web Application developed by Cyber Security and Privacy Foundation(www.cysecurity.org). This app is intended for the Java Programmers and other people who wish to learn about Web application vulnerabilities and write secure code"
			echo -e "$TCY Source: $TCD https://github.com/CSPF-Founder/JavaVulnerableLab"
			echo -e "$TCY Install: $TCD Go to install.jsp anc click on the button"
			echo -e "$TCY Rules: $TCD The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "        No automated tools (like SQLmap, dirb...)"
			echo -e "        Only hand-crafted payloads or home-made scripts"
			echo -e "        It's recommended to not read the source code. If you are stuck: Inspect element for (big) nudges."
			echo -e "$TCY Solutions: $TCD https://github.com/CSPF-Founder/JavaSecurityCourse"
		;;
		w4p | web4pentester)
			echo -e "$TCC Information about Web for Pentester I - web4pentester/w4p $TCD"
			echo -e "$TCY Source: $TCD https://pentesterlab.com/exercises/web_for_pentester/course"
			echo -e "$TCY Rules: $TCD The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "        No automated tools (like SQLmap, dirb...)"
			echo -e "        Only hand-crafted payloads or home-made scripts"
			echo -e "        It's recommended to not read the source code. If you are stuck: Inspect element for (big) nudges."
		;;
		sqlilabs)
			echo -e "$TCC Information about Audi-1 SQLi labs - sqlilabs $TCD"
			echo -e "$TCY Source: $TCD https://github-com.translate.goog/Audi-1/sqli-labs"
			echo -e "$TCY Install: $TCD Click on the link setup/resetDB to create database, create tables and populate Data"
			echo -e "$TCY Rules: $TCD The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "        No automated tools (like SQLmap, dirb...)"
			echo -e "        Only hand-crafted payloads or home-made scripts"
			echo -e "        It's recommended to not read the source code. If you are stuck: Inspect element for (big) nudges."
			echo -e "$TCY Solutions: $TCD http://dummy2dummies.blogspot.com"
			echo -e "            http://www.securitytube.net/user/Audi"
			echo -e "            https://www.facebook.com/sqlilabs"
			;;
		oxninja)
			echo -e "$TCC Information about OxNinja SQLi-Lab machine - oxninja $TCD"
			echo -e "$TCY Source: $TCD https://github.com/OxNinja/SQLi-lab"
			echo -e "$TCY Rules: $TCD The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "        No automated tools (like SQLmap, dirb...)"
			echo -e "        Only hand-crafted payloads or home-made scripts"
			echo -e "        It's recommended to not read the source code. If you are stuck: Inspect element for (big) nudges."
			echo -e "$TCY Solutions: $TCD https://0xninja.fr/posts/sqli-lab/"
			;;
		bricks)
			echo -e "$TCC Information about OWASP Bricks - bricks $TCD"
			echo -e "$TCY Source: $TCD https://sechow.com/bricks/download.html"
			echo -e "$TCY Solutions: $TCD https://sechow.com/bricks/docs/"
			;;
		redtiger)
			echo -e "$TCC Information about RedTigers HackIit - redtiger (ONLINE) $TCD"
			echo -e "$TCY Source: $TCD http://redtiger.labs.overthewire.org/"
			echo -e "$TCY Rules: $TCD The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "        No automated tools (like SQLmap, dirb...)"
			echo -e "        Only hand-crafted payloads or home-made scripts"
			echo -e "        Be honest. Dont bruteforce the passwords and dont make any solutions public!!!"
			;;
		
		portswigger)
			echo -e "$TCC Information about PortSwigger SQLi Lab - portswigger (ONLINE) $TCD"
			echo -e "$TCY Source: https://portswigger.net/web-security/sql-injection $TCD "
			echo -e "$TCY Rules: $TCD The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "        No automated tools (like SQLmap, dirb...)"
			echo -e "        Only hand-crafted payloads or home-made scripts"
			echo -e "        Be honest. Dont bruteforce the passwords and dont make any solutions public!!!"
			;;
			
		hacksplaining)
			echo -e "$TCC Information about Hacksplanning SQLi Lab - hacksplaining (ONLINE) $TCD"
			echo -e "$TCY Source: $TCD https://www.hacksplaining.com/exercises/sql-injection"
			echo -e "$TCY Rules: $TCD The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "        No automated tools (like SQLmap, dirb...)"
			echo -e "        Only hand-crafted payloads or home-made scripts"
			echo -e "        Be honest. Dont bruteforce the passwords and dont make any solutions public!!!"
			;;
		
		synk)
			echo -e "$TCC Information about Synk Learn Labs - synk (ONLINE) $TCD"
			echo -e "$TCY Source: $TCD https://learn.snyk.io/catalog/"
			;;	
		
		thmsqli)
			echo -e "$TCC Information about Try Hack Me SQLi Lab - thmsqli (ONLINE) $TCD"
			echo -e "$TCY Source: $TCD https://tryhackme.com/room/sqlilab"
			echo -e "$TCY Rules: $TCD The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "        No automated tools (like SQLmap, dirb...)"
			echo -e "        Only hand-crafted payloads or home-made scripts"
			echo -e "        Be honest. Dont bruteforce the passwords."
			;;
		
		thm)
			echo -e "$TCC Information about Try Hack Me - thm (ONLINE) $TCD"
			echo -e "$TCY Source: $TCD https://tryhackme.com"
			echo -e "$TCY Rules: $TCD The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "        No automated tools (like SQLmap, dirb...)"
			echo -e "        Only hand-crafted payloads or home-made scripts"
			echo -e "        Be honest. Dont bruteforce the passwords."
			;;
		
		kontra)
			echo -e "$TCC Information about Kontra SQLi Lab - kontra (ONLINE) $TCD"
			echo -e "$TCY Source: $TCD https://application.security/free-application-security-training/owasp-top-10-sql-injection"
			echo -e "$TCY Rules: $TCD The goal of this lab is to train like a hacker not a script kiddie"
			echo -e "        No automated tools (like SQLmap, dirb...)"
			echo -e "        Only hand-crafted payloads or home-made scripts"
			echo -e "        Be honest. Dont bruteforce the passwords."
			;;

		vulnhub)
			echo -e "$TCC Information about VulnHub Virtual Machines Labs - vulnhub (ONLINE) $TCD"
			echo -e "$TCY Source: $TCD https://www.vulnhub.com/"
			echo -e "$TCY Rules: $TCD Before you can run, you need to be able to walk."
			echo -e "        You do so by learning the basics so you can gain of the theory. "
			echo -e "        Once you're up and walking, you need 'something' to run to (Something to aim for) & you need 'somewhere' that's padded with foam to run about in (so it doesn't matter if you fall over)."
			echo -e "        This is where VulnHub comes in."
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

project_startinfo_bricks ()
{
	echo "OWASP Bricks"
	echo "First Install: http://127.21.0.1/config/"
	echo "Access: http://127.21.0.1/index.php"
}

#########################
# Common start          #
#########################
function project_start ()
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


function project_startpublic ()
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
function project_stop ()
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

function project_running()
{
  projectname=$1
  shortname=$2
  url=$3
  running=0

  if [ "$(sudo docker ps -q -f name=^/${shortname}$)" ]; then
    echo -e "$projectname:$shortname	$TCG	running at $url (localhost) $TCD"
    running=1
  fi
  if [ "$(sudo docker ps -q -f name=^/${shortname}public$)" ]; then
    echo -e "$projectname:$shortname	$TCG	running (public) $TCD"
    running=1
  fi  
  if [ $running -eq 0 ];
  then
    echo -e "$projectname:$shortname		$TCR not running $TCD"
  fi 
}


function project_status()
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
  project_running "OWASP Bricks                 " "bricks" "http://bricks http://127.21.0.1"
}


function project_start_dispatch()
{
  case "$1" in
    bwapp)
		project_start "bWAPP" "bwapp" "raesene/bwapp" "127.5.0.1" "80"
		project_startinfo_bwapp
		openUrl "http://127.5.0.1/install.php"
    ;;
    webgoat7)
		project_start "WebGoat 7.1" "webgoat7" "webgoat/webgoat-7.1" "127.6.0.1" "8080"
		project_startinfo_webgoat7
		openUrl "http://127.6.0.1/WebGoat"
    ;;
    webgoat8)
		project_start "WebGoat 8.0" "webgoat8" "webgoat/webgoat-8.0" "127.7.0.1" "8080"
		project_startinfo_webgoat8
		openUrl "http://127.7.0.1/WebGoat"
    ;;    
    webgoat81)
		project_start "WebGoat 8.1" "webgoat81" "webgoat/goatandwolf" "127.17.0.1" "8080"
		project_startinfo_webgoat81
		openUrl "http://127.17.0.1/WebGoat"
    ;;    
    dvwa)
		project_start "Damn Vulnerable Web Appliaction" "dvwa" "vulnerables/web-dvwa" "127.8.0.1" "80"
		project_startinfo_dvwa
		openUrl "http://127.8.0.1"		
    ;;    
    mutillidae)
		project_start "Mutillidae II" "mutillidae" "citizenstig/nowasp" "127.9.0.1" "80"
		project_startinfo_mutillidae
		openUrl "http://127.9.0.1"
    ;;
    juiceshop)
		project_start "OWASP Juice Shop" "juiceshop" "bkimminich/juice-shop" "127.10.0.1" "3000"
		project_startinfo_juiceshop
		#openUrl "http://127.10.0.1:3000"
		openUrl "http://127.10.0.1"
    ;;
    securitysheperd)
		project_start "OWASP Security Shepard" "securitysheperd" "ismisepaul/securityshepherd" "127.11.0.1" "80"
		project_startinfo_securitysheperd
		openUrl "http://127.11.0.1"
    ;;
    vulnerablewp)
		project_start "WPScan Vulnerable Wordpress" "vulnerablewp" "eystsen/vulnerablewordpress" "127.12.0.1" "80" "3306"
		project_startinfo_vulnerablewp
		openUrl "http://127.12.0.1"
    ;;
    securityninjas)    
		project_start "Open DNS Security Ninjas" "securityninjas" "opendns/security-ninjas" "127.13.0.1" "80"
		project_startinfo_securityninjas
		openUrl "http://127.13.0.1"
    ;;
    altoro)    
		project_start "Altoro Mutual" "altoro" "eystsen/altoro" "127.14.0.1" "8080"
		project_startinfo_altoro
		openUrl "http://127.14.0.1:8080"
		openUrl "http://127.14.0.1"
    ;;
    graphql)
		project_start "Vulnerable GraphQL API" "graphql" "carvesystems/vulnerable-graphql-api" "127.15.0.1" "3000"
		project_startinfo_graphql
		openUrl "http://127.15.0.1:3000"    
		openUrl "http://127.15.0.1"    
    ;;
    jvl)    
		#project_start "Java Vulnerable Lab" "jvl" "m4n3dw0lf/javavulnerablelab" "127.16.0.1" "8080"
		openUrl "http://127.16.0.1:8080/JavaVulnerableLab/install.jsp"
		openUrl "http://127.16.0.1/JavaVulnerableLab/install.jsp"
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
	  openUrl "http://127.18.0.1"
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
	bricks)
		project_startinfo_bricks
		project_start "OWASP Bricks" "bricks" "citizenstig/owaspbricks" "127.21.0.1" "80"
		openUrl "http://127.21.0.1/index.php"
		;;
	*)
      echo "ERROR: Project start dispatch doesn't recognize the project name $1" 
    ;;
  esac  
}

function start_online () {
	case "$1" in
		redtiger)
			echo -e "$TCR Opening -->$TCD  RedTiger's Hackit SQLi Lab is an Online machine. So only web browser is needed."
			sleep 2
			openUrl "http://redtiger.labs.overthewire.org/"
			;;
			
		portswigger)
			echo -e "$TCR Opening -->$TCD  PortSwigger SQL injection Labs. This are all online. So only web browser is needed."
			sleep 2
			openUrl "https://portswigger.net/web-security/sql-injection"
			;;

		hacksplaining)
			echo -e "$TCR Opening -->$TCD Hacksplanning SQL Injection Lab. This are all online. So only web browser is needed. "
			sleep 2
			openUrl "https://www.hacksplaining.com/exercises/sql-injection"
			;;

		synk)
			echo -e "$TCR Opening -->$TCD Synk Lab. This an Online lab. So only webbrowser is needed."
			echo -e "  Synk Learn teaches developers how to stay secure with interactive lessons exploring "
			echo -e "  vulnerabilities across a variety of languages and ecosystems. "
			echo -e "  This are all online. So only web browser is needed. "
			sleep 2
			openUrl "https://learn.snyk.io/catalog/"
			;;

		thmsqli)
			echo -e "$TCR Opening -->$TCD  Try Hack Me SQLi Lab. This are all online. So only web browser is needed."
			sleep 2
			openUrl "https://tryhackme.com/room/sqlilab"
			;;
		
		thm)
			echo -e "$TCR Opening -->$TCD  Try Hack Me. This are all online. So only web browser is needed."
			sleep 2
			openUrl "https://tryhackme.com"
			;;
		
		kontra)
			echo -e "$TCR Opening -->$TCD  Kontra Aplication Security SQLi Lab is an online Lab, so only web browser is needed."
			sleep 2
			openUrl "https://application.security/free-application-security-training/owasp-top-10-sql-injection"
			;;
		
		vulnhub)
			echo -e "$TCR Opening -->$TCD  VulnHub Online Virtual Vulnerable Machines, so only web browser is needed."
			sleep 2
			openUrl "https://www.vulnhub.com/"
			;;
		
		hdb)
			echo -e "$TCR Opening -->$TCD  Hack The Box Online Virtual Vulnerable Machines, so only web browser is needed."
			sleep 2
			openUrl "https://www.hackthebox.com/"
			;;
		
		ps)
			echo -e "$TCR Opening -->$TCD  PortSwigger Web Security Academy is an online resource, so only web browser is needed."
			sleep 2
			openUrl "https://portswigger.net/web-security"
			;;
		
		ctftime)
			echo -e "$TCR Opening -->$TCD  CTFTime is an online resource, so only web browser is needed."
			sleep 2
			openUrl "https://ctftime.org/ctfs"
			;;
		
		*)
			echo -e "$TCR ERROR: Project start online doesn't recognize the online project name $TCD $1 "
			echo -e " Trying Docker Project if exists it will be launched. "
			sleep 2
			project_start_dispatch $1
		;;
	esac		
}

function project_startpublic_dispatch()
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


function project_stop_dispatch()
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
	bricks)
		project_stop "OWASP Bricks" "bricks"
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
	echo -e "$TCC Checking user privileges $TCD"
	echo -en " Running docker without sudo:  "
	if groups | grep -q docker; then
		echo -e "$TCG YES $TCD"
	else
		echo -e "$TCY NEED SUDO $TCD"
	fi
	echo -en " User has sudo privileges:     "
	if groups | grep -q sudo; then
		echo -e "$TCG YES - Elevating privileges $TCD"
		sudo docker &> /dev/null
	else
		echo -e "$TCR NO $TCD - To run the script you have to use a user that can run docker."
		exit
	fi
}

##############################
# List Docker Script Options #
##############################
function list_docker_options () {
	echo -en "$TCC"
	echo -e "-----------------------------------------------------------------------------------------"
	echo -e " Available docker apps options "
	echo -en "-----------------------------------------------------------------------------------------"
	echo -e "$TCD"
	echo -e "$TCG list        $TCD- List all available docker projects" 
	echo -e "$TCG status      $TCD- Show status for all docker projects"
	echo -e "$TCG start       $TCD- Start app docker project and make it available on localhost" 
	echo -e "$TCG startpublic $TCD- Start app docker project and make it publicly available (to anyone with network connectivity to the machine)" 
	echo -e "$TCG info        $TCD- Show information about app project"
	echo -e "$TCG stop        $TCD- Stop app docker project "			
}

#########################
# Main switch case      #
#########################
function main () {
	display_logo
	display_info
	
	case "$1" in
		online)
			if [ -z "$2" ]
			then
				echo -e "$TCR ERROR: Option online needs project name in lowercase $TCD"
				list # call list ()
				break
			fi
			start_online $2
			;;
		
		info)
			if [ -z "$2" ]
			then
				echo -en " Please choose one 4 detailed information: "
				list # call list ()
			break
			fi
			project_info $2
		;;
		
		list)
			list # call list ()
			;;
		
		*)
			check_runpriv
			check_docker
		;;
	esac

	echo -e "$TCD-----------------------------------------------------------------------------------------"
	
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
			
		status)
			echo " Showing STATUS of the Docker containers"
			echo "-----------------------------------------------------------------------------------------"
			project_status # call project_status ()
			echo "-----------------------------------------------------------------------------------------"
			;;
			
		list | info | online)
			;;

		*)
			display_help
			;;
	esac
}

#Script starts to execute stuff from this point, traps and then the main function
for f in SIGINT SIGHUP INT SIGTSTP; do
	trap_cmd="trap \"capture_traps ${f}\" \"${f}\""
	eval "${trap_cmd}"
done

display_logo
display_info

while true; do
	echo -e "$TCC-----------------------------------------------------------------------------------------"
	echo -e " Available script options:"
	echo -e "-----------------------------------------------------------------------------------------$TCD"
	echo -e "$TCG   1 $TCD- Online Apps "
	echo -e "$TCG   2 $TCD- Docker Apps "
	echo -e "$TCG  99 $TCD- Exit"
	echo -e "-----------------------------------------------------------------------------------------"
	echo -en " Select an option: $TCG"		
	read choice
	echo -en "$TCD"
	
	case $choice in
		1)
			list_onlineapps
			echo -en "Select an online app: "
			read oapp
			if [ -z "$oapp" ]
			then
				echo -e "$TCR ERROR: Option online needs project name in lowercase $TCD"
				list_onlineapps # call list ()
				#break
			fi
			start_online $oapp
			;;
		2)
			list_docker_options
			echo -e "-----------------------------------------------------------------------------------------"
			echo -en " Select an option for docker app: "
			read dockeroption
			echo -e "-----------------------------------------------------------------------------------------"
			
			#list_dockerapps
			#echo -en "Select a Docker app: "
			#read dapp
			
			#display_help
			#echo -e "-----------------------------------------------------------------------------------------"
					
			case $dockeroption in
				start)
					list_dockerapps # call list ()
					echo -en "Select a Docker app: "
					read dapp	
					echo -e "-----------------------------------------------------------------------------------------"
					if [ -z "$dapp" ]
					then
						echo -e "ERROR: Option start needs project name in lowercase"
						echo 
						list_dockerapps # call list ()
						break
					fi
					project_start_dispatch $dapp
					;;
					
				startpublic)
					list_dockerapps # call list ()	
					echo -en "Select a Docker app: "
					read dapp
					echo -e "-----------------------------------------------------------------------------------------"
					if [ -z "$dapp" ]
					then
						echo -e "ERROR: Option start needs project name in lowercase"
						echo 
						list_dockerapps # call list ()
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
					project_status
					echo -e "-----------------------------------------------------------------------------------------"
					echo -en "Select a Docker app: "
					read dapp
					echo -e "-----------------------------------------------------------------------------------------"
					if [ -z "$dapp" ]
					then
						echo "ERROR: Option start needs project name in lowercase"
						echo 
						list_dockerapps # call list ()
						break
					fi
					project_stop_dispatch $dapp
					echo -e "-----------------------------------------------------------------------------------------"
					echo -e "$TCC Showing new app status after stopping $TCG $dapp $TCC docker application $TCD "
					echo -e "-----------------------------------------------------------------------------------------"
					project_status
					echo -e "-----------------------------------------------------------------------------------------"
					;;
					
				status)
					echo " Showing STATUS of the Docker containers"
					echo "-----------------------------------------------------------------------------------------"
					project_status # call project_status ()
					echo "-----------------------------------------------------------------------------------------"
					;;
				
				info)
					list_dockerapps # call list ()
					echo -en "Select a Docker app: "
					read dapp	
					echo -e "-----------------------------------------------------------------------------------------"
					if [ -z "$dapp" ]
					then
						echo -en " Please choose one 4 detailed information: "
						list_dockerapps # call list ()
					break
					fi
					echo "-----------------------------------------------------------------------------------------"
					project_info $dapp
					;;
					
				list)
					list_dockerapps
					;;

				*)
					display_help
					;;
			esac
			;;
			
		99)
			break
			;;
			
		*)
			echo -e "$TCR"
			echo -e "Invalid choice. Please try again."
			echo -e "$TCD"
			;;
	esac
done

#main "$@"