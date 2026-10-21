## Plan: BreakingLab 60-90 días

Este documento es la versión maestra del plan de mejora de BreakingLab. Su propósito es ordenar prioridades, fijar límites de alcance, alinear backlog y roadmap, y servir como referencia para decisiones técnicas y operativas durante los próximos 60-90 días.

La tesis del plan es simple: BreakingLab no necesita una reescritura, necesita una secuencia disciplinada de estabilización. El mayor riesgo está en el core Bash, en la ejecución dinámica, en la mutación del host, en la fragilidad del contrato de configuración y en la falta de un proceso robusto de actualización y validación. Por eso la prioridad correcta es endurecer el runtime, formalizar la configuración, hacer reproducible la operación y gobernar los labs embebidos según ownership real.

**Document Map**
- Este archivo: versión maestra, estratégica y operativa.
- `.github/prompts/plan-breakingLab-execution.prompt.md`: versión orientada a ejecución estricta por fases.
- `.github/prompts/plan-breakingLab-compact.prompt.md`: versión ejecutiva resumida.
- `.github/prompts/plan-breakingLab-en.prompt.md`: versión equivalente en inglés.
- `docs/plan-breakingLab-roadmap.md`: versión publicable del roadmap y marco de trabajo.
- `docs/rfc-breakingLab-roadmap.md`: resumen corto de decisión y contexto.
- `docs/github-planning-conventions.md`: convención de labels, epics, issues y PRs.
- `docs/issue-batch-1.md`: primer lote priorizado de trabajo listo para abrir.
- `docs/planning-handoff.md`: punto de reentrada para retomar el trabajo en otra sesión.
- `docs/README.md`: índice de documentación de planificación.

**Kanban**
- Backlog: trabajo identificado pero aún no preparado.
- Ready: historia con alcance, criterio de aceptación y archivos afectados claros.
- In Progress: implementación activa con rama y prueba local definida.
- Blocked: dependencias externas, decisiones de producto o limitaciones de upstream.
- Review: cambios listos con pruebas, revisión técnica y validación manual.
- Done: mergeado, documentado, liberado y con rollback definido.

**Policy Gates**
- Runtime safety: ninguna ruta de uso normal puede instalar paquetes, añadir repositorios del sistema o mutar persistencia del host fuera de flujos explícitos de install/doctor/update.
- Dynamic execution scope: toda eliminación o encapsulado de ejecución dinámica debe incluir breakinglab.sh, lib/menu.sh, lib/utils.sh, config/projects.conf y scripts/hooks.
- Contract migration: ningún cambio del contrato de configuración puede desplegarse sin estrategia de migración, compatibilidad temporal y criterio de retirada del modo legacy.
- Platform validation: todo cambio que toque Docker, apertura de URLs, instalación, update o privilegios debe validarse explícitamente en Linux y WSL2.
- Scope control: archive/ queda fuera del roadmap operativo salvo referencia histórica o necesidad excepcional justificada.

**Strategic Priorities**
1. P0: runtime safety, ejecución dinámica, contrato de configuración, rollback y validación Linux/WSL2.
2. P1: pinning de imágenes, rendimiento del runtime, migración del contrato, red configurable y pruebas mínimas.
3. P2: modularización del core, observabilidad útil y auditoría más profunda de labs propios.
4. P3: modernización extensa de labs o mejoras de UX no bloqueantes.

**Steps**
1. Fase 0. Baseline y gobierno del plan. Congelar alcance de 60-90 días, clasificar todo el repo en core propio vs labs vendorizados vs labs propios, y crear un inventario con owner, criticidad, tipo de mantenimiento y estrategia de actualización. Esto bloquea todas las fases posteriores.
2. Fase 0.5. Policy gates. Formalizar reglas no negociables para runtime safety, validación Linux/WSL2, control de alcance sobre archive/ y separación entre flujos de uso normal frente a install/update/doctor. Esto debe quedar cerrado antes de tocar seguridad o updates.
3. Definir reglas de priorización kanban. Prioridad P0 para seguridad operativa y reproducibilidad, P1 para rendimiento y escalabilidad del core, P2 para funcionalidad y UX, P3 para modernización profunda de labs. Esto puede hacerse en paralelo con el paso 1, pero no debe cerrar sprint sin inventario.
4. Fase 1. Seguridad crítica del core. Sustituir ejecución peligrosa y validación débil en d:\Scripts\BreakingLab\breakinglab.sh, d:\Scripts\BreakingLab\lib\hosts.sh, d:\Scripts\BreakingLab\lib\utils.sh, d:\Scripts\BreakingLab\lib\menu.sh y d:\Scripts\BreakingLab\config\projects.conf. Objetivo: eliminar source ciego y eval inseguro donde sea viable, endurecer add_host, validar slug/IP/puerto, acotar permisos, separar flujos que hoy mutan el sistema desde runtime normal y normalizar hooks. Depende de 1 y 2.
5. Diseñar un esquema de configuración versionado para proyectos. Migrar el formato pipe-delimited a un formato con validación explícita o, como mínimo, introducir un validador fuerte y un version field compatible hacia atrás. Reutilizar d:\Scripts\BreakingLab\config\projects.conf y d:\Scripts\BreakingLab\config\projects.d\_template.conf.example como base de transición. Depende de 4.
6. Fase de migración del contrato. Añadir inventario de compatibilidad, migrador o asistente semiautomático, modo legacy temporal, criterio de retirada y validación de catálogo existente antes de hacer obligatorio el nuevo contrato. Depende de 5.
7. Formalizar política de supply chain. Pinning de imágenes Docker por tag o digest, política para git clone/import, allowlist de repos soportados, checksum o commit pin para labs importados, y revisión de hooks post-import. Afecta d:\Scripts\BreakingLab\breakinglab.sh, d:\Scripts\BreakingLab\config\projects.d y d:\Scripts\BreakingLab\scripts\hooks. Depende de 4 y puede avanzar en paralelo con 5.
8. Fase 2. Rendimiento del core. Reducir llamadas repetidas a docker, cachear estado, mejorar polling de arranque y refactorizar la detección de estado para no recalcular cada render del menú. Reutilizar patrones en d:\Scripts\BreakingLab\lib\menu.sh y d:\Scripts\BreakingLab\lib\utils.sh. Depende de 4.
9. Replantear asignación de red y colisiones. Hacer configurable el rango IP, reservar espacio por instancia o mover progresivamente hacia networking Docker más nativo para no depender de 127.100.0.x como único límite. Afecta d:\Scripts\BreakingLab\lib\utils.sh, d:\Scripts\BreakingLab\breakinglab.sh y las definiciones en d:\Scripts\BreakingLab\config\projects.d. Depende de 5 y 8.
10. Introducir límites de recursos y perfiles de ejecución por lab. Añadir CPU, memoria, timeout y healthcheck como metadatos de proyecto para evitar que un lab degrade todo el host. Depende de 5 y 8.
11. Carril de plataforma. Mantener una lane específica Linux/WSL2 para validar comportamiento de Docker, apertura de URLs, dependencias, permisos y update antes de cerrar cualquier fase que toque runtime o instalación. Depende de 2 y avanza en paralelo con 4, 8, 13 y 16.
12. Fase 3. Escalabilidad y mantenibilidad. Dividir responsabilidades del orquestador principal en módulos más pequeños: lifecycle, config, docker runtime, networking, import/update y UX. El objetivo es reducir complejidad en d:\Scripts\BreakingLab\breakinglab.sh y estabilizar contratos internos entre librerías. Depende de 4, 5 y 8.
13. Rehacer la sanitización de docker compose con una estrategia menos frágil que el AWK actual. Primero documentar casos soportados y no soportados; después sustituir o encapsular d:\Scripts\BreakingLab\lib\yaml_utils.sh con validación y pruebas. Depende de 5 y 8.
14. Fase 4. Funcionalidad. Crear capacidades operativas que ahora faltan: doctor, validate, dry-run, verify, lock, update-lab, start-all por lotes, estado enriquecido y diagnóstico de errores. La superficie principal estará en d:\Scripts\BreakingLab\breakinglab.sh, d:\Scripts\BreakingLab\lib\utils.sh y d:\Scripts\BreakingLab\README.md. Depende de 4, 5 y 8.
15. Mejorar UX de CLI y menú. Mantener el flujo actual, pero añadir errores accionables, estado más fiable, filtros útiles y salida no interactiva apta para scripting. Depende de 8 y puede hacerse en paralelo con 14.
16. Fase 5. Proceso de actualización y release. Rediseñar install/update para soportar prechecks, backup, rollback, migración de configs y validación post-update. Afecta d:\Scripts\BreakingLab\install.sh, d:\Scripts\BreakingLab\breakinglab.sh, d:\Scripts\BreakingLab\README.md y d:\Scripts\BreakingLab\CHANGELOG.md. Debe incluir la regla explícita de no auto-instalar dependencias desde rutas de uso normal como open/start. Depende de 5, 6, 11 y 14.
17. Formalizar versión y compatibilidad. Introducir semver real, política de deprecación, matriz de compatibilidad Bash/Docker/WSL2 y notas de migración por release. Depende de 16.
18. Extender CI desde shellcheck a validación real. Mantener d:\Scripts\BreakingLab\.github\workflows\shellcheck.yml y añadir validación de configs, tests unitarios, pruebas de integración mínimas y gates para release. Depende de 4, 5, 11 y 13; puede avanzar en paralelo con 16.
19. Fase 6. Calidad y observabilidad. Sustituir los scripts ad hoc de prueba por una suite formal, instrumentar logs con rotación, niveles de severidad y trazas de operaciones críticas, y añadir comandos de soporte para diagnóstico. Reutilizar d:\Scripts\BreakingLab\test_awk.sh, d:\Scripts\BreakingLab\test_gh_fetch.sh y d:\Scripts\BreakingLab\lib\utils.sh como punto de partida. Depende de 13, 16 y 18.
20. Fase 7. Gestión de labs embebidos. Separar labs propios de labs de terceros dentro de d:\Scripts\BreakingLab\projects. Para terceros: no reescribir funcionalidad salvo fixes de integración, seguridad de packaging y reproducibilidad. Para propios o claramente mantenidos aquí: auditar dependencias, Dockerfiles, compose files, timeouts de arranque, credenciales por defecto y healthchecks. Depende de 1, 7 y 18.
21. Crear una política de actualización por lab. Cada directorio de d:\Scripts\BreakingLab\projects debe tener estrategia explícita: vendorizado con upstream pinned, fork mantenido, o snapshot interno. Esto reduce deuda y evita cambios accidentales durante upgrades globales. Depende de 20.
22. Auditar especialmente d:\Scripts\BreakingLab\projects\dvws-node-2, d:\Scripts\BreakingLab\projects\dvwsnode2 y d:\Scripts\BreakingLab\projects\vulpy5 por duplicación, drift, dependencias antiguas, startup frágil y exposición innecesaria. Depende de 20 y puede correr en paralelo con 21.
23. Fase 8. Documentación operativa. Completar README con límites, troubleshooting y flujo de mantenimiento; añadir guía de contribución, guía de seguridad de hooks/configs y runbook de release/rollback. Depende de 14, 16, 18 y 20.
24. Fase 9. Despliegue controlado. Ejecutar primero endurecimiento en core, luego migración de configuración, luego rollout de CI y por último la modernización de labs. No mezclar refactor interno y cambios de comportamiento de actualización en el mismo lote. Depende de 4 a 23.
25. Cerrar cada tarjeta con una definición estricta de Done: pruebas automatizadas pasando, validación manual documentada, impacto en CHANGELOG, ruta de rollback y actualización de documentación. Aplica a todos los pasos.

**Relevant files**
- d:\Scripts\BreakingLab\breakinglab.sh — orquestador principal; lifecycle, import, update, startpublic y validación general.
- d:\Scripts\BreakingLab\install.sh — instalación global, prechecks y rollback de instalación.
- d:\Scripts\BreakingLab\lib\utils.sh — docker checks, hooks, logging, WSL helpers y utilidades transversales.
- d:\Scripts\BreakingLab\lib\hosts.sh — modificación de hosts y principal superficie de privilegios.
- d:\Scripts\BreakingLab\lib\menu.sh — renderizado, consulta de estado y experiencia de usuario.
- d:\Scripts\BreakingLab\lib\yaml_utils.sh — sanitización compose y principal foco de fragilidad técnica.
- d:\Scripts\BreakingLab\config\projects.conf — carga de configuración y punto actual de source dinámico.
- d:\Scripts\BreakingLab\config\projects.d\_template.conf.example — plantilla del contrato de proyectos.
- d:\Scripts\BreakingLab\config\projects.d — catálogo real de labs, pinning y metadatos operativos.
- d:\Scripts\BreakingLab\scripts\hooks — automatizaciones per-project que requieren política de seguridad y contrato.
- d:\Scripts\BreakingLab\README.md — instalación, uso, troubleshooting y procesos operativos.
- d:\Scripts\BreakingLab\CHANGELOG.md — versionado y comunicación de cambios/migraciones.
- d:\Scripts\BreakingLab\test_awk.sh — referencia actual de pruebas manuales para compose sanitization.
- d:\Scripts\BreakingLab\test_gh_fetch.sh — referencia actual de pruebas manuales para import y fetch.
- d:\Scripts\BreakingLab\.github\workflows\shellcheck.yml — base del pipeline de calidad.
- d:\Scripts\BreakingLab\projects\dvws-node-2 — lab embebido a clasificar por ownership y mantenimiento.
- d:\Scripts\BreakingLab\projects\dvwsnode2 — lab embebido con aparente duplicidad y posible drift.
- d:\Scripts\BreakingLab\projects\vulpy5 — lab embebido con Docker/Python que debe auditarse por seguridad y reproducibilidad.
- d:\Scripts\BreakingLab\archive — referencia histórica; fuera del roadmap operativo salvo necesidad excepcional justificada.

**Verification**
1. Inventario completo del repo con clasificación core/lab propio/lab tercero y estrategia de update para cada elemento.
2. Validación de configuración: carga de todos los projects sin source inseguro ni campos ambiguos no detectados.
3. Pruebas de seguridad sobre add_host, hooks, import y startpublic con entradas inválidas y casos de abuso conocidos.
4. Benchmark antes/después del menú y del arranque de labs representativos para medir reducción de llamadas docker y tiempo total.
5. Pruebas de integración mínimas para start, stop, status, update y import en Linux y WSL2.
6. Simulación de upgrade con backup y rollback verificando que la instalación queda consistente tras fallo parcial.
7. Auditoría de imágenes y dependencias en labs embebidos: tags, digests, paquetes críticos, puertos, credenciales por defecto y healthchecks.
8. Revisión documental: README, CHANGELOG y guías de mantenimiento alineadas con el comportamiento real.
9. Verificación explícita de que ninguna ruta de uso normal instala paquetes, añade repositorios o muta persistencia del sistema fuera de install/doctor/update.
10. Validación de migración del contrato: catálogo actual compatible, modo legacy temporal y retirada planificada.

**Decisions**
- Incluido: todo el repo, con foco prioritario en el core y en release/CI durante los primeros sprints.
- Incluido: labs embebidos, pero con dos niveles de intervención. Los labs de terceros se tratan como componentes vendorizados y se prioriza packaging, actualización y aislamiento. Los labs propios o mantenidos localmente sí entran en refactor técnico más profundo.
- Excluido en la primera ola: reescritura completa de aplicaciones vulnerables de terceros cuyo valor del repo es didáctico y no el hardening interno de la app.
- Excluido del roadmap operativo: archive/, salvo consulta histórica o necesidad excepcional aprobada.
- Recomendación de ejecución: 4 tableros o épicas en paralelo. Seguridad y supply chain; rendimiento y escalabilidad; actualización y release; labs embebidos y documentación. Seguridad bloquea cualquier rollout amplio.

**Further Considerations**
1. Recomendación organizativa: mantener un board con swimlanes P0, P1, P2 y una etiqueta extra de Ownership para distinguir core, config, hooks y labs.
2. Recomendación táctica: cerrar primero el contrato de configuración antes de tocar en masa scripts hooks o compose sanitization; de lo contrario, se moverán dos interfaces a la vez.
3. Recomendación de riesgo: tratar la coexistencia de d:\Scripts\BreakingLab\projects\dvws-node-2 y d:\Scripts\BreakingLab\projects\dvwsnode2 como incidencia temprana del backlog porque apunta a drift y duplicación operativa.
4. Recomendación de secuencia: insertar un mini-sprint 0.5 para policy gates y validación Linux/WSL2 antes del endurecimiento principal del core.
5. Recomendación de entrega: separar cambios de update/release de cambios de CI/testing en tracks distintos para reducir riesgo de regresión y facilitar revisión.

**Artifacts**
- Kanban board listo para GitHub Projects/Jira con épicas, columnas, etiquetas y prioridad.
- Desglose de historias y tareas con estimación de esfuerzo.
- Sprint 1 detallado con criterios de aceptación y definición de done.
- Export CSV importable para tickets.
- Adaptación exacta a GitHub Projects con campos personalizados.
- Sprint 2 priorizado y detallado con criterios de aceptación.
- Sprint 3 priorizado y detallado con criterios de aceptación.
- CSV adaptado a importación tipo Jira.
- Descripciones completas de issues listas para pegar en GitHub/Jira.
- Descripciones completas de las 25 issues del backlog.
- Sprint 4 y roadmap consolidado a 90 días.
- Documento maestro tipo PM para seguimiento ejecutivo y técnico.
- Versiones derivadas coherentes: compacta, execution prompt e inglés.

**Backlog Alignment**
La alineación entre roadmap y backlog debe mantenerse explícita para evitar que el documento estratégico y las issues diverjan.

| Fase / Workstream | Objetivo | Issues principales |
|---|---|---|
| Fase 0: Inventario y gobierno | Clasificar repo, ownership y estrategia de mantenimiento | BL-00, BL-01, BL-25 |
| Fase 0.5: Policy gates | Runtime safety, alcance, Linux/WSL2, exclusiones | BL-02, BL-03, BL-24, BL-25 |
| Fase 1: Seguridad del core | Endurecer hosts, eval/source, hooks, rutas públicas y menú | BL-02, BL-03, BL-07 |
| Contrato de configuración | Definir contrato fuerte y reglas de validación | BL-04, BL-05 |
| Migración de contrato | Compatibilidad temporal, migración y retirada legacy | BL-04, BL-05, BL-15 |
| Supply chain | Pinning de imágenes e import controlado | BL-06, BL-07 |
| Fase 2: Rendimiento runtime | Cache de estado, healthchecks y menor latencia | BL-08, BL-09 |
| Red y recursos | Escalabilidad operativa, IP configurable y límites | BL-10, BL-11 |
| Fase 3: Mantenibilidad técnica | Modularización del core y compose sanitization robusta | BL-12, BL-13 |
| Fase 4: Funcionalidad operativa | doctor, validate, verify, dry-run y soporte | BL-14, BL-19 |
| Fase 5: Update y release | install/update seguros, rollback y semver | BL-15, BL-16, BL-24 |
| Fase 6: Calidad y observabilidad | CI real, pruebas mínimas, logging y diagnóstico | BL-17, BL-18, BL-19 |
| Fase 7: Labs embebidos | Ownership, drift y auditoría de labs prioritarios | BL-20, BL-21, BL-22 |
| Fase 8: Documentación operativa | README, runbook, troubleshooting y release docs | BL-23, BL-25 |

Reglas de consistencia entre plan e issues:
1. Ninguna issue P0 debe existir sin criterio de rollback y validación manual.
2. Toda issue que toque config debe enlazar con BL-04 o BL-05 como referencia contractual.
3. Toda issue de plataforma debe enlazar con BL-24 o con la lane Linux/WSL2.
4. Toda issue que afecte labs debe indicar si el componente es propio, fork mantenido, snapshot o vendorizado.
5. Si una tarjeta no encaja en alguna fase anterior, debe revisarse su prioridad o alcance antes de entrar en sprint.

**Use Guidance**
Usa este archivo como referencia maestra para estrategia, prioridades, dependencias, validación y alineación con backlog. Para ejecución estricta, usa `.github/prompts/plan-breakingLab-execution.prompt.md`. Para comunicación rápida, usa `.github/prompts/plan-breakingLab-compact.prompt.md`. Para compartir fuera del idioma original, usa `.github/prompts/plan-breakingLab-en.prompt.md`. Para retomar el trabajo en otra sesión, empieza por `docs/planning-handoff.md`.

**Definition of Success**
El plan habrá funcionado si BreakingLab sigue siendo simple de usar, pero pasa a ser claramente más seguro, más predecible al actualizarse, más medible en runtime y más gobernable como producto evolutivo.

