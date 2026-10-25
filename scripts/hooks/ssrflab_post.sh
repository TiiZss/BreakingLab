#!/usr/bin/env bash
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT/labs/SSRF-LAB" || exit
if [ -z "$(docker ps -aq -f "name=^ssrflab_")" ]; then
    docker run --name ssrflab_web --label "com.docker.compose.project=breakinglab_ssrflab" --label "com.docker.compose.service=ssrflab" --label "breakinglab.lab=ssrflab" -d -p 127.24.0.1:80:80 -v "$PWD":/var/www/html tiizss/php-8.1.28-apache-bullseye:8.1.28-apache-bullseye || exit
else
    docker start ssrflab_web || exit
fi
cd .. || exit
