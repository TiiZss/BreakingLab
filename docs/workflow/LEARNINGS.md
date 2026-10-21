# Lecciones

- **[2026-10-20] El bloque de graft no es el mapa del proyecto.** `AGENTS.md`, `GEMINI.md` y las instrucciones de Copilot repetían solo ese bloque. El mapa de trabajo tiene que vivir en `CLAUDE.md` y en `.cursor/rules/workflow.mdc`, fuera de los marcadores `graft:start` / `graft:end`.
- **[2026-10-20] `git config --global` no es un arreglo aceptable.** El mensaje de `dubious ownership` lo propone. La regla del entorno prohíbe cambiar la configuración de git. Hay que parar y decírselo a quien usa la máquina.
- **[2026-10-20] Copiar 261 y 818 skills al repo no aporta el comportamiento.** Esas carpetas ya están en `D:\Scripts\Z-externos`. El agente las lee ahí. Vendorizarlas hincha el árbol y mezcla licencias.
- **[2026-10-20] Caveman full y el español no caben en la misma frase.** El modo full quita artículos. En español el artículo distingue el sentido. El nivel lite mantiene la frase corta y gramatical.
- **[2026-10-21] GitHub rechaza `github@tiizss.com`.** Con “Keep my email addresses private” el push de línea de comandos tiene que llevar `9557246+TiiZss@users.noreply.github.com`. No se guarda en `git config`. Se pasa en las variables del comando.
