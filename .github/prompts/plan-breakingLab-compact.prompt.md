# BreakingLab Plan 60-90 días

## Executive Summary
BreakingLab no necesita una reescritura, sino una secuencia disciplinada de estabilización. El orden correcto es: asegurar el core, formalizar el contrato de configuración, controlar supply chain y runtime, convertir updates y CI en flujos confiables, y gobernar los labs embebidos según ownership real.

## Decisión recomendada
Ejecutar un roadmap de 90 días centrado en core, configuración, runtime, update/release y gobierno de labs. No abrir modernización profunda de labs de terceros hasta cerrar seguridad, contrato, rollback y validación multiplataforma.

## Prioridades
1. P0: runtime safety, ejecución dinámica, contrato de configuración, rollback y validación Linux/WSL2.
2. P1: pinning de imágenes, rendimiento del runtime, migración del contrato, red configurable y pruebas mínimas.
3. P2: modularización del core, logging/observabilidad y auditoría más profunda de labs propios.

## Guardrails
1. Las rutas normales no pueden instalar paquetes ni añadir repositorios.
2. No se cierra ningún cambio de configuración sin migración y modo legacy temporal.
3. No se cierra ningún cambio de update sin rollback probado.
4. No se asume compatibilidad Linux/WSL2 sin evidencia.
5. `archive/` queda fuera del roadmap operativo.

## Roadmap
1. Baseline y gobierno: inventario, ownership, Definition of Done y rollback mínimo.
2. Policy gates: runtime safety, lane Linux/WSL2 y control de alcance.
3. Seguridad del core: hosts, hooks, menú, rutas públicas y ejecución dinámica.
4. Configuración y migración: contrato, validador y retirada planificada del modo legacy.
5. Supply chain y runtime: pinning, política de import, caché Docker, healthchecks, red y recursos.
6. Operación y calidad: doctor, validate, verify, dry-run, update seguro, CI real y tests mínimos.
7. Labs y documentación: ownership, drift, auditoría prioritaria y runbook operativo.

## Hitos
1. Hito 1: core seguro y contrato definido.
2. Hito 2: runtime más rápido y reproducible.
3. Hito 3: update, CI y soporte confiables.
4. Hito 4: core mantenible y labs gobernados.

## Riesgos a controlar
1. Auto-instalación de dependencias desde flujos normales.
2. Persistencia de eval/source inseguros en rutas no cubiertas.
3. Cambio de contrato sin migración real.
4. Validación incompleta en WSL2.
5. Scope creep sobre `archive/` o sobre labs de terceros.

## Backlog núcleo
1. Gobierno: BL-00, BL-01, BL-25.
2. Seguridad: BL-02, BL-03, BL-07.
3. Configuración: BL-04, BL-05.
4. Runtime: BL-06, BL-08, BL-09, BL-10, BL-11, BL-13.
5. Release y calidad: BL-14, BL-15, BL-16, BL-17, BL-18, BL-19, BL-24.
6. Labs y docs: BL-20, BL-21, BL-22, BL-23.

## Verificación final
1. Configuración validable antes de runtime.
2. Linux y WSL2 cubiertos en rutas críticas.
3. Update con rollback y validación post-cambio.
4. Menú y arranque con mejora medible.
5. Labs con ownership y policy de update.

## Criterio de éxito ejecutivo
El plan habrá funcionado si BreakingLab sigue siendo simple de usar, pero pasa a ser claramente más seguro, más predecible de actualizar, más medible en runtime y más gobernable como producto.