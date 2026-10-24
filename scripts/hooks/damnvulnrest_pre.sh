#!/usr/bin/env bash
if [[ ! -d Damn-Vulnerable-RESTaurant-API-Game/.git ]]; then
    git clone https://github.com/theowni/Damn-Vulnerable-RESTaurant-API-Game.git || exit
fi
cd Damn-Vulnerable-RESTaurant-API-Game || exit
