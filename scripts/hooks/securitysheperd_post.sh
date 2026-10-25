#!/usr/bin/env bash
docker run --name securitysheperd_shepherd \
    --label "com.docker.compose.project=breakinglab_securitysheperd" \
    --label "com.docker.compose.service=securitysheperd" \
    --label "breakinglab.lab=securitysheperd" \
    -d -p "${BREAKINGLAB_BIND:-127.11.0.1}:80:8080" tiizss/security-shepherd:latest
