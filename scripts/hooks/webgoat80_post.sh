#!/usr/bin/env bash
docker run --name webgoat80_webgoat \
    --label "com.docker.compose.project=breakinglab" \
    --label "com.docker.compose.service=webgoat80" \
    --label "breakinglab.lab=webgoat80" \
    -d -p 127.4.0.1:8080:8080 -p 127.4.0.1:9090:9090 \
    tiizss/webgoat-8.0.0:v8.0.0
