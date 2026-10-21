# Issue Batch 1

## Purpose
This document defines the first prioritized batch of issues to open from the BreakingLab roadmap.

## Batch Goal
Reduce the highest operational risk before moving into broader runtime, release, and lab-governance work.

## Recommended Opening Order
1. `EP-01` Security and Runtime Safety
2. `EP-02` Configuration Contract and Migration
3. `EP-03` Release and Quality Baseline
4. `BL-00` Inventario total del repositorio
5. `BL-01` Matriz de ownership y estrategia de actualización
6. `BL-25` Definition of Done y checklist de rollback
7. `BL-02` Endurecer modificación de hosts y privilegios
8. `BL-03` Eliminar o encapsular ejecución insegura en core y hooks
9. `BL-04` Definir contrato versionado de configuración
10. `BL-05` Crear validador de slug, IP, puerto, rutas y campos

## Why This Batch First
1. It closes the highest-risk gaps first.
2. It creates the contract and governance base for all later work.
3. It reduces the chance of rework in runtime, CI, and update flows.

## Suggested Epic Mapping
### EP-01 Security and Runtime Safety
- BL-02
- BL-03

### EP-02 Configuration Contract and Migration
- BL-04
- BL-05

### EP-03 Release and Quality Baseline
- BL-00
- BL-01
- BL-25

## Suggested Labels
1. `priority:P0`
2. `type:epic` or `type:story`
3. `scope:core` or `scope:config`
4. `area:security`, `area:update-process`, or `area:docs`
5. `platform:cross-platform` or `platform:wsl2` when relevant

## Minimum Acceptance Expectations
1. Each item must define affected files.
2. Each item must define manual validation.
3. Each security/config/update item must define rollback expectations.
4. Each item must remain aligned with the roadmap and planning prompts.

## Next Batch Preview
The next batch should cover image pinning, runtime performance, healthchecks, configurable networking, resource profiles, and compose sanitization.
