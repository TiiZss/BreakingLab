#!/usr/bin/env bash
docker run --name webgoat82_webgoat \
    --label "com.docker.compose.project=breakinglab" \
    --label "com.docker.compose.service=webgoat82" \
    --label "breakinglab.lab=webgoat82" \
    -d -p 127.7.0.1:8080:8080 -p 127.7.0.1:9090:9090 \
    -e WEBGOAT_HSQLDB=true tiizss/webgoat-8.2.2:v8.2.2
