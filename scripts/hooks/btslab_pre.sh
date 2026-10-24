#!/usr/bin/env bash
if [[ ! -d btslab/.git ]]; then
    git clone https://github.com/CSPF-Founder/btslab || exit
fi
