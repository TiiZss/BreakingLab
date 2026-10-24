#!/usr/bin/env bash
if [[ ! -d mutillidae-docker ]]; then
    git clone https://github.com/webpwnized/mutillidae-docker.git || exit
fi
cd mutillidae-docker || exit
sed -i 's|_name: database|_name: mutillidae-database|g' .build/docker-compose.yml
sed -i 's|_name: www|_name: mutillidae-www|g' .build/docker-compose.yml
sed -i 's|_name: directory|_name: mutillidae-directory|g' .build/docker-compose.yml
sed -i 's|127\.0\.0\.1:|127.9.0.1:|g' .build/docker-compose.yml
sed -i 's|webpwnized/mutillidae:|tiizss/mutillidae:|g' .build/docker-compose.yml
python3 - <<'PY'
from pathlib import Path
p = Path(".build/docker-compose.yml")
lines = p.read_text(encoding="utf-8").splitlines(True)
out = []
skip = False
for line in lines:
    if line.startswith("    build:"):
        skip = True
        continue
    if skip:
        if line.startswith("    ") and not line.startswith("      "):
            skip = False
        else:
            continue
    out.append(line)
p.write_text("".join(out), encoding="utf-8")
PY
