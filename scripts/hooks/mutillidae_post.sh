#!/usr/bin/env bash
cd mutillidae-docker || exit
docker compose -f .build/docker-compose.yml up --build -d || exit
cd .. || exit
