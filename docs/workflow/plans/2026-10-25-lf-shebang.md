# 2026-10-25 — shebang y CRLF

## Hecho

`./breakinglab.sh` falla en WSL con `/bin/bash^M: bad interpreter`. El índice guarda LF. `core.autocrlf=true` del Git de Windows escribe CRLF en `/mnt/d`.

## Cambio

- `.gitattributes`: `*.sh text eol=lf`, para que un checkout no vuelva a poner CR.
- Reescribir la copia de trabajo de los `.sh` en LF.

Sin cambio de lógica. Sin commit hasta que se pida.
