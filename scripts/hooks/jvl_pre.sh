#!/usr/bin/env bash
if [ -d JavaVulnerableLab/.git ]; then git -C JavaVulnerableLab pull --ff-only || true; else git clone https://github.com/CSPF-Founder/JavaVulnerableLab.git; fi
