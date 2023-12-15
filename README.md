# BreakingLab
Bash script to manage web apps using docker and hosts aliases.  
Idea taken from script: https://github.com/eystsen/pentestlab
Working and tested on Ubuntu 23.04 and WSL.

### Current available webapps

* bWAPP
* WebGoat 7.1
* WebGoat 8.0
* WebGoat 8.1
* Damn Vulnerable Web App
* Mutillidae II
* OWASP Juice Shop
* WPScan Vulnerable Wordpress
* OpenDNS Security Ninjas
* Altoro Mutual
* Vulnerable GraphQL API
* Java Vulnerable Lab (New 20230916) --> Not working :-(
* Web for Pentester I (New 20230918)

### Get started 

Using any of these apps can be done in 3 quick and simple steps.

#### 1) Clone the repo
Clone this repo, or download it any way you prefer
```
git clone https://github.com/TiiZss/BreakingLab.git
cd breakinglab
```

#### 2) Installing and enabling docker for your user
##### Linux
This script is prepared to install Docker in Kali: https://www.kali.org/docs/containers/installing-docker-on-kali/  
```
sudo apt install -y docker.io
sudo systemctl enable docker --now
sudo usermod -aG docker $USER
docker
```
For any other distro, use the prefered way to install docker. Here you have how to install Docker Desktop on linux: https://docs.docker.com/desktop/install/linux-install/  

##### Mac  
If you want to install Docker in your Mac, please follow this guide: https://docs.docker.com/desktop/install/mac-install/  

##### Windows  
If you want to install Docker in your Windows, please follow this guide: https://docs.docker.com/desktop/install/windows-install/  

#### 3) Start an app on localhost
Now you can start and stop one or more of these apps on your system.
As an example, to start w4p just run this command
```
./breakinglab.sh start w4p
```
This will download the docker, add w4p to hosts file and run the docker mapped to one of the localhost IPs.
That means you can just point your browser to http://w4p and it will be up and running.


#### 4) Start an app and expose it from machine
Use the startpublic command to bind the app to your IP
```
./breakinglab.sh startpublic w4p
```
If you have multiple interfaces and/or IPs, **or** you need to expose the app on a different port specify it like this
```
./breakinglab.sh startpublic w4p 192.168.1.118 8080
```
IP needs to be an IP on the machine and port in this example is 8080

You can only have one app exposed on any given port. If you need to expose more than one app, you need to use different ports.


#### 5) Stopp any app
To stop any app use the stop command
```
./breakinglab.sh stop bwapp
```


#### Print a complete list of available projects use the list command
```
./breakinglab.sh list 
```

#### Running just the script will print help info
```
./breakinglab.sh 
```


### Usage
```
Usage: ./breakinglab.sh {list|status|info|start|startpublic|stop} [projectname]

 This scripts uses docker and hosts alias to make web apps available on localhost"

Ex.
./breakinglab.sh list
   List all available projects  

./breakinglab.sh status
   Show status for all projects  

./breakinglab.sh start w4p
   Start docker container with w4p and make it available on localhost  

./breakinglab.sh startpublic w4p
   Start docker container with w4p and make it available on machine IP 

./breakinglab.sh stop w4p
   Stop docker container

./breakinglab.sh info w4p
   Show information about w4p project
```

 ### Dockerfiles from
 * DVWA                   - Ryan Dewhurst (vulnerables/web-dvwa)  
 * Mutillidae II          - OWASP Project (citizenstig/nowasp)  
 * bWapp                  - Rory McCune (raesene/bwapp)  
 * Webgoat(s)             - OWASP Project 7, 8 & 8.1  
 * Juice Shop             - OWASP Project (bkimminich/juice-shop)  
 * Vulnerable Wordpress   - github.com/wpscanteam/VulnerableWordpress  
 * Security Ninjas        - OpenDNS Security Ninjas  
 * Altoro Mutual          - github.com/hclproducts/altoroj  
 * Vulnerable GraphQL API - Carve Systems LLC (carvesystems/vulnerable-graphql-api)  
 * Java Vulnerable Lab    - Java Vulnerable Lab CSPF-Founder (m4n3dw0lf/javavulnerablelab) --> :-( Not working
 * Web For Pentester I    - PentesterLab Web For Pentester I (tiizss/webforpentester)

github references means the docker is custom created and hosted in dockerhub.


## Troubleshoot / FAQ

### I can't connect to the application I just stared, what is wrong?
- Make sure you are using HTTP not HTTPS
- Try using the IP address instead of the name (to see if the issue is with host file or docker)

### I still cannot make it work, how do I create an issue to get help?
Do these steps and record ouput (image, copy paste from screen, whatever works for you)
- Stop the application first (to clean up some configuration that are done during start)
- Start the application again 
- Run this command to get information about running dockers
```
sudo docker ps
```
- Try to access the application using the IP address
