#!/usr/bin/env bash
if [[ ! -d mutillidae-docker ]]; then
    git clone https://github.com/webpwnized/mutillidae-docker.git || exit
fi
cd mutillidae-docker || exit
sed -i 's|_name: database|_name: mutillidae-database|g' .build/docker-compose.yml
sed -i 's|_name: www|_name: mutillidae-www|g' .build/docker-compose.yml
sed -i 's|_name: directory|_name: mutillidae-directory|g' .build/docker-compose.yml
