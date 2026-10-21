#!/usr/bin/env bash
cd vulnado || exit
sudo docker compose up -d || exit
cd .. || exit
