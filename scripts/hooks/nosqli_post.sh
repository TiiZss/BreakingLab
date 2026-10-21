#!/usr/bin/env bash
cd nosqlilab || exit
docker-compose up -d --build || exit
cd .. || exit
