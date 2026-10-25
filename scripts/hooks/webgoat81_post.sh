#!/usr/bin/env bash
docker run --name webgoat81_webgoat \
    --label "com.docker.compose.project=breakinglab_webgoat81" \
    --label "com.docker.compose.service=webgoat81" \
    --label "breakinglab.lab=webgoat81" \
    -d -p 127.17.0.1:8080:8080 -p 127.17.0.1:9090:9090 \
    tiizss/webgoat-8.1.0:v8.1.0
