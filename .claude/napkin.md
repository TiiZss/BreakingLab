# Napkin Runbook

## Curation Rules
- Re-prioritize on every read.
- Keep recurring, high-value notes only.
- Max 10 items per category.
- Each item includes date + "Do instead".

## User Directives
1. **[2026-10-20] Responder en español**
   Do instead: escribe al usuario en español. Caveman en nivel lite, con artículos, porque el nivel full rompe la gramática.
2. **[2026-10-20] No dar la razón sin contraste**
   Do instead: si el encargo choca con el repo o con otra regla del mismo encargo, dilo y aplica la variante que conserve el código estable.
3. **[2026-10-20] No inventar**
   Do instead: si un comando, servidor MCP o skill no está, dilo. No rellenes con una configuración supuesta.
4. **[2026-10-20] Una funcionalidad, una rama**
   Do instead: crea la rama antes de editar código de producto. No mezcles documentación de agente con un cambio de `lib/` en el mismo diff si el usuario pidió las dos cosas por separado.

## Execution & Validation (Highest Priority)
1. **[2026-10-20] Graft antes de abrir fuentes**
   Do instead: `graft ask`, `graft grep`, `graft skeleton`, `graft callers` o `graft map`. Abre solo el tramo `file:line` que el grafo no haya cerrado.
2. **[2026-10-20] Plan en fichero**
   Do instead: crea `docs/workflow/plans/AAAA-MM-DD-tema.md` antes de editar código.
3. **[2026-10-21] Git con dueño dudoso**
   Do instead: no ejecutes `git config --global`. Usa `git -c safe.directory=D:/Scripts/BreakingLab` en el comando. `tea` dentro de esta carpeta falla por lo mismo: lánzalo desde otro directorio.
4. **[2026-10-21] Gitea antes que GitHub**
   Do instead: el primer remoto es `https://gitea.tiizss.internal/tiizss/BreakingLab`. GitHub (`origin`, `TiiZss/BreakingLab`) va después. SSH al puerto 22 está cerrado; usa HTTPS.
5. **[2026-10-20] Copia antes de reescribir lógica**
   Do instead: copia los ficheros afectados a `.backups/AAAA-MM-DD/`. No archives el repo entero.

## Domain Behavior Guardrails
1. **[2026-10-20] Laboratorios vulnerables a propósito**
   Do instead: el lanzador puede arrancar imágenes vulnerables. No añadas exploits ni copies skills ofensivas al repo. Una auditoría mira el script, los hooks y la exposición de red.
2. **[2026-10-20] Sin Python y sin UI**
   Do instead: no crees `pyproject.toml` ni apliques skills de frontend. `uv` queda escrito para el día en que haya Python.
