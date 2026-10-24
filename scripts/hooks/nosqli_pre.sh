#!/usr/bin/env bash
if [[ ! -d nosqlilab ]]; then
    git clone https://github.com/madamantis-leviathan/nosqlilab.git || exit
fi
cd nosqlilab || exit
sed -i 's/^version: .*$/version: "3.7-3.9"/' docker-compose.yml
if ! grep -q 'container_name: nosqli-web' docker-compose.yml; then
    sed -i '/web:/a\    container_name: nosqli-web' docker-compose.yml
fi
sed -i 's|"8080:80"|"127.22.0.1:8080:80"|' docker-compose.yml
sed -i 's|"27017:27017"|"127.22.0.1:27017:27017"|' docker-compose.yml
