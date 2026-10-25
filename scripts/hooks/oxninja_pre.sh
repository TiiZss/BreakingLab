#!/usr/bin/env bash
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/lib/lab_dir.sh"
bl_prepare_lab oxninja-sqlilab https://github.com/OxNinja/SQLi-lab || exit
if ! grep -q "container_name: oxninja-web" docker-compose.yml; then
    sed -i "/web:/at        container_name: oxninja-web" docker-compose.yml
    sed -i "s/^t//" docker-compose.yml
fi
sed -i 's|"80:80"|"127.20.0.1:80:80"|' docker-compose.yml
sed -i 's|"3306:3306"|"127.20.0.1:3306:3306"|' docker-compose.yml
sed -i "s/172.16.0/172.16.1/g" docker-compose.yml
