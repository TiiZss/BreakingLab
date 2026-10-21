#!/usr/bin/env bash
cd SSRF-LAB || exit
docker cp ./index.php ssrflab:/var/www/html || exit
cd .. || exit
