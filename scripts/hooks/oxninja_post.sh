#!/usr/bin/env bash
cd oxninja-sqlilab || exit
docker-compose up -d --build || exit
cd .. || exit
