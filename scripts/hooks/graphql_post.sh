#!/usr/bin/env bash
docker run --name graphql_dvga \
    --label "com.docker.compose.project=breakinglab_graphql" \
    --label "com.docker.compose.service=graphql" \
    --label "breakinglab.lab=graphql" \
    -d -p 127.15.0.1:5013:5013 -e WEB_HOST=0.0.0.0 tiizss/dvga:2.1.2
