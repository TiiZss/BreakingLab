#!/usr/bin/env bash
if [[ ! -d oxninja-sqlilab ]]; then
    git clone https://github.com/OxNinja/SQLi-lab oxninja-sqlilab || exit
fi
cd oxninja-sqlilab || exit
if ! grep -q "container_name: oxninja-web" docker-compose.yml; then
    sed -i "/web:/at        container_name: oxninja-web" docker-compose.yml
    sed -i "s/^t//" docker-compose.yml
fi
# shellcheck disable=SC1001
sed -i "s|-\s*80\:\s*80|-\s*127.20.0.1\:\s*80\:\s*80|g" docker-compose.yml
sed -i "s/172.16.0/172.16.1/g" docker-compose.yml
