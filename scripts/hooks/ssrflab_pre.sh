#!/usr/bin/env bash
if [[ ! -d SSRF-LAB/.git ]]; then
    git clone https://github.com/ph4nt0m-py/SSRF-LAB.git || exit
fi
cd SSRF-LAB || exit
