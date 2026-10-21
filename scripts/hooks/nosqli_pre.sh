#!/usr/bin/env bash
git clone https://github.com/madamantis-leviathan/nosqlilab.git || exit
cd nosqlilab || exit
sed -i 's/^version: .*$/version: "3.7-3.9"/' docker-compose.yml
sed -i "/web:/at    container_name: nosqli-web" docker-compose.yml
sed -i "s/^t//" docker-compose.yml
