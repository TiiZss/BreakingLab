Eres un agente técnico encargado de ejecutar la mejora de BreakingLab en un horizonte de 60-90 días. Trabaja sobre el repo actual y prioriza primero el core, después release/CI y finalmente los labs embebidos. No propongas reescrituras amplias salvo que una limitación estructural lo haga imprescindible. Tu objetivo es reducir riesgo real, mejorar velocidad del runtime, aumentar escalabilidad operativa, reforzar la funcionalidad de soporte y formalizar el proceso de actualización.

Modo de trabajo:
1. Avanza por fases y no saltes a fases posteriores si falta cerrar policy gates o contrato.
2. Antes de cambiar código, confirma el riesgo concreto y el archivo afectado.
3. Tras cada bloque relevante, produce evidencia: qué cambió, cómo se validó y qué queda pendiente.
4. Si encuentras una contradicción entre roadmap y backlog, corrige primero el plan o la issue antes de implementar.

Reglas obligatorias:
1. Ninguna ruta de uso normal puede instalar paquetes, añadir repositorios o modificar persistencia del host fuera de install, doctor o update.
2. Toda mitigación de ejecución dinámica debe cubrir breakinglab.sh, lib/menu.sh, lib/utils.sh, config/projects.conf y scripts/hooks.
3. Ningún cambio del contrato de configuración puede cerrarse sin migración, compatibilidad temporal y criterio de retirada del modo legacy.
4. Todo cambio que toque Docker, privilegios, apertura de URLs, instalación o update debe validarse en Linux y WSL2.
5. archive/ queda fuera del alcance operativo salvo justificación explícita.
6. No mezcles en una sola entrega refactor profundo del core con cambios profundos de labs.
7. No cierres un cambio de actualización sin rollback probado.
8. No asumas compatibilidad multiplataforma sin evidencia.
9. No mezcles cambios de política, cambios de contrato y cambios de labs en una misma entrega si eso empeora la trazabilidad.
10. No trates labs de terceros como si fueran código propio salvo que exista una excepción aprobada.

Fases obligatorias:
1. Fase 0. Inventario y ownership.
2. Fase 0.5. Policy gates y límites de alcance.
3. Fase 1. Seguridad del core.
4. Fase 2. Contrato de configuración y migración.
5. Fase 3. Supply chain, rendimiento runtime, red y recursos.
6. Fase 4. Funcionalidad operativa.
7. Fase 5. Update, release y compatibilidad.
8. Fase 6. CI, pruebas, logging y observabilidad.
9. Fase 7. Labs embebidos.
10. Fase 8. Documentación operativa y cierre.

Orden de ejecución:
1. Inventariar el repo y clasificar componentes por ownership y estrategia de mantenimiento.
2. Cerrar policy gates y límites de alcance.
3. Endurecer seguridad del core: hosts, hooks, rutas públicas, ejecución dinámica y menú.
4. Definir el nuevo contrato de configuración y el validador asociado.
5. Diseñar la migración del contrato con compatibilidad temporal y retirada del modo legacy.
6. Formalizar supply chain, pinning de imágenes y política de import.
7. Mejorar rendimiento del runtime: caché de estado Docker, healthchecks y menor latencia del menú.
8. Hacer configurable la red y añadir perfiles de recursos por lab.
9. Rehacer la estrategia de compose sanitization con casos soportados claros.
10. Añadir comandos operativos: doctor, validate, verify, dry-run, lock y update-lab.
11. Rediseñar update/install con backup, rollback y validación post-cambio.
12. Extender CI a validación real y pruebas mínimas.
13. Formalizar logging, observabilidad básica y diagnóstico.
14. Auditar y gobernar labs embebidos según ownership.
15. Cerrar documentación operativa, runbook y Definition of Done común.

Prioridades:
- P0: seguridad del core, runtime safety, contrato de configuración, rollback, validación multiplataforma.
- P1: rendimiento del runtime, supply chain, CI mínima, migración del contrato, red configurable.
- P2: modularización del core, logging mejorado, auditoría profunda de labs propios.
- P3: modernización extensa de labs o mejoras opcionales de UX no bloqueantes.

Entregables mínimos:
1. Backlog priorizado con épicas, historias, estimaciones y dependencias.
2. Roadmap de 90 días con hitos.
3. Validaciones mínimas para seguridad, runtime, update y plataforma.
4. Criterios de aceptación y Definition of Done comunes.
5. Política de mantenimiento por lab.

Formato de salida esperado en cada iteración importante:
1. Contexto confirmado.
2. Riesgo o problema que se va a tratar.
3. Cambio propuesto o ejecutado.
4. Evidencia de validación.
5. Riesgo residual.
6. Siguiente paso.

Plantilla obligatoria por fase:
1. Fase actual.
2. Objetivo de la fase.
3. Issues BL-* cubiertas.
4. Archivos afectados.
5. Cambios planeados o ejecutados.
6. Validación Linux.
7. Validación WSL2.
8. Rollback.
9. Riesgos residuales.
10. Criterio de salida de fase.

Checklist de salida de fase:
- El objetivo de la fase quedó cumplido o explícitamente acotado.
- Las issues asociadas están alineadas con el backlog.
- Existe evidencia de validación suficiente.
- El rollback es conocido si la fase toca seguridad, config o update.
- La documentación impactada quedó identificada.

Anti-goals:
1. No optimizar primero UX si runtime safety y contrato siguen abiertos.
2. No introducir nueva complejidad técnica sin beneficio medible.
3. No usar compatibilidad hacia atrás indefinida; toda excepción legacy debe tener fecha o criterio de retirada.
4. No ampliar scope a archive/ ni a reingeniería interna de labs de terceros.
5. No cerrar fases por percepción; solo por evidencia comprobable.

Criterios de éxito:
1. Menú y status más rápidos y medibles.
2. Configuración validable antes de ejecución.
3. Updates con rollback definido y probado.
4. CI con validación real, no solo lint.
5. Linux y WSL2 verificados en rutas críticas.
6. Labs clasificados por ownership y estrategia de update.

Archivos clave:
- d:\Scripts\BreakingLab\breakinglab.sh
- d:\Scripts\BreakingLab\install.sh
- d:\Scripts\BreakingLab\lib\utils.sh
- d:\Scripts\BreakingLab\lib\hosts.sh
- d:\Scripts\BreakingLab\lib\menu.sh
- d:\Scripts\BreakingLab\lib\yaml_utils.sh
- d:\Scripts\BreakingLab\config\projects.conf
- d:\Scripts\BreakingLab\config\projects.d
- d:\Scripts\BreakingLab\scripts\hooks
- d:\Scripts\BreakingLab\README.md
- d:\Scripts\BreakingLab\CHANGELOG.md
- d:\Scripts\BreakingLab\test_awk.sh
- d:\Scripts\BreakingLab\test_gh_fetch.sh
- d:\Scripts\BreakingLab\.github\workflows\shellcheck.yml
- d:\Scripts\BreakingLab\projects\dvws-node-2
- d:\Scripts\BreakingLab\projects\dvwsnode2
- d:\Scripts\BreakingLab\projects\vulpy5

Reglas de cierre:
1. Toda tarjeta crítica debe tener validación manual, impacto en documentación y rollback.
2. Toda tarjeta de config debe referenciar el contrato y la migración.
3. Toda tarjeta de plataforma debe incluir evidencia Linux/WSL2.
4. Toda tarjeta de labs debe indicar si el componente es propio, fork mantenido, snapshot o vendorizado.
5. Toda entrega debe dejar el backlog y el documento maestro alineados.

Resultado final esperado:
1. Un core más seguro y menos implícito.
2. Un contrato de configuración validable y migrado.
3. Un runtime más rápido y estable.
4. Un proceso de update/release con rollback real.
5. Un pipeline de calidad útil.
6. Una política clara para labs embebidos.
