#!/usr/bin/env bash
if [[ ! -d oxninja-sqlilab ]]; then
    git clone https://github.com/OxNinja/SQLi-lab oxninja-sqlilab || exit
fi
cd oxninja-sqlilab || exit
if ! grep -q "container_name: oxninja-web" docker-compose.yml; then
    sed -i "/web:/at        container_name: oxninja-web" docker-compose.yml
    sed -i "s/^t//" docker-compose.yml
fi
sed -i 's|"80:80"|"127.20.0.1:80:80"|' docker-compose.yml
sed -i 's|"3306:3306"|"127.20.0.1:3306:3306"|' docker-compose.yml
sed -i "s/172.16.0/172.16.1/g" docker-compose.yml
