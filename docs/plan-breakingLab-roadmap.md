# BreakingLab Roadmap 60-90 días

> Related documents:
> - `.github/prompts/plan-breakingLab.prompt.md`
> - `.github/prompts/plan-breakingLab-execution.prompt.md`
> - `.github/prompts/plan-breakingLab-compact.prompt.md`
> - `.github/prompts/plan-breakingLab-en.prompt.md`
> - `docs/rfc-breakingLab-roadmap.md`
> - `docs/github-planning-conventions.md`
> - `docs/issue-batch-1.md`
> - `docs/planning-handoff.md`
> - `docs/README.md`

## Resumen ejecutivo
BreakingLab necesita una estabilización por capas, no una reescritura. El riesgo principal no está en la funcionalidad visible, sino en la seguridad y previsibilidad del core, en la fragilidad del contrato de configuración, en la falta de un proceso robusto de actualización y en la ausencia de un gobierno claro sobre los labs embebidos.

La estrategia recomendada es endurecer primero el runtime y la configuración, después mejorar rendimiento y escalabilidad operativa, luego formalizar updates, CI y rollback, y finalmente cerrar el gobierno de labs y la documentación de mantenimiento.

## Objetivos
1. Reducir el riesgo operativo y de seguridad del core.
2. Mejorar la velocidad y fiabilidad del runtime.
3. Hacer la configuración validable, migrable y gobernable.
4. Convertir updates y releases en flujos reproducibles y reversibles.
5. Establecer una base mínima real de calidad, observabilidad y documentación.
6. Tratar los labs embebidos según ownership real: propios, forks mantenidos, snapshots o vendorizados.

## Guardrails
1. Las rutas normales no pueden instalar paquetes ni añadir repositorios.
2. Ningún cambio de configuración se cierra sin migración y modo legacy temporal.
3. Ningún cambio de update se cierra sin rollback probado.
4. Linux y WSL2 son plataformas objetivo y deben validarse explícitamente.
5. `archive/` queda fuera del roadmap operativo salvo necesidad excepcional.

## Roadmap
### Fase 0: Baseline y gobierno
- Inventariar el repo.
- Clasificar ownership y estrategia de mantenimiento.
- Definir Definition of Done y rollback mínimos.

### Fase 0.5: Policy gates
- Formalizar runtime safety.
- Fijar alcance operativo y exclusiones.
- Abrir lane Linux/WSL2.

### Fase 1: Seguridad del core
- Endurecer hosts, hooks, menú, rutas públicas y ejecución dinámica.
- Normalizar privilegios y validación de entradas.

### Fase 2: Configuración y migración
- Definir contrato versionado de proyectos.
- Añadir validación fuerte.
- Implementar migración y retirada planificada del modo legacy.

### Fase 3: Supply chain y runtime
- Pinning de imágenes.
- Política de import y allowlist.
- Caché de estado Docker y mejores healthchecks.
- Red configurable y perfiles de recursos.
- Estrategia robusta de compose sanitization.

### Fase 4: Funcionalidad operativa
- Añadir doctor, validate, verify, dry-run, lock y update-lab.
- Mejorar diagnóstico operativo.
- Mejorar UX de CLI y menú donde aporte valor real.

### Fase 5: Release y calidad
- Rediseñar install/update con backup y rollback.
- Formalizar semver y compatibilidad.
- Extender CI más allá de ShellCheck.
- Sustituir tests ad hoc por una suite mínima repetible.
- Mejorar logging y observabilidad.

### Fase 6: Labs embebidos y documentación
- Clasificar labs por ownership.
- Resolver drift entre dvws-node-2 y dvwsnode2.
- Auditar vulpy5.
- Cerrar README, runbook y documentación de mantenimiento.

## Hitos de 90 días
1. Hito 1: core seguro y contrato definido.
2. Hito 2: runtime más rápido y reproducible.
3. Hito 3: update, CI y soporte confiables.
4. Hito 4: core mantenible y labs gobernados.

## Backlog núcleo
1. Gobierno: BL-00, BL-01, BL-25.
2. Seguridad: BL-02, BL-03, BL-07.
3. Configuración: BL-04, BL-05.
4. Runtime: BL-06, BL-08, BL-09, BL-10, BL-11, BL-13.
5. Release y calidad: BL-14, BL-15, BL-16, BL-17, BL-18, BL-19, BL-24.
6. Labs y documentación: BL-20, BL-21, BL-22, BL-23.

## Verificación
1. Configuración validable antes de runtime.
2. Linux y WSL2 cubiertos en rutas críticas.
3. Update con rollback y validación post-cambio.
4. Menú y arranque con mejora medible.
5. Labs con ownership y policy de update.

## Criterio de éxito
El plan habrá funcionado si BreakingLab sigue siendo simple de usar, pero pasa a ser más seguro, más predecible al actualizarse, más medible en runtime y más gobernable como producto evolutivo.

## Navegación
1. Usa `.github/prompts/plan-breakingLab.prompt.md` como fuente de verdad estratégica y operativa.
2. Usa `.github/prompts/plan-breakingLab-execution.prompt.md` para ejecución estricta por fases.
3. Usa `docs/rfc-breakingLab-roadmap.md` como versión corta de decisión y contexto.
4. Usa `docs/github-planning-conventions.md` para labels, epics, issues y PRs.
5. Usa `docs/issue-batch-1.md` para abrir el primer lote priorizado de trabajo.
6. Usa `docs/planning-handoff.md` para retomar rápidamente en otra sesión.