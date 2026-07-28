# Changelog — Motor (Backend Prime Developer)

Formato basado en Keep a Changelog. Versionado semántico.

## [2.2.0] — 2026-07-28

### Added
- **Párrafo "Protocolo de equipo"** en `SKILL.md` (tras la frontera de rol,
  §"Frontera de rol y delegación"): referencia a `TEAM-PROTOCOL.md` (raíz del
  repositorio), el protocolo operativo único compartido por los 22 agentes + 2
  clusters (ownership, plantilla canónica de handoff, gates, escalamiento y los
  momentos exactos en que se debe consultar).

### Notas
- Adición aditiva: no cambia frontmatter, la frontera de rol existente ni ningún
  otro contenido de este archivo. motor es el único agente sin gobernanza separada
  (su frontera vive en `SKILL.md`), de ahí el tratamiento especial en el rollout
  del protocolo de equipo (canario: orquesta).

## [2.1.0] — 2026-07-12

### Changed
- **§2 bis (Delegación y cadena de mando) reescrita como mapa autoritativo de
  ownership.** motor cede la titularidad de disciplinas/plataformas transversales
  conservando su oficio de construir: plataforma y entrega (pipeline CI/CD,
  estrategias de despliegue, rollback, GitOps, IaC de plataforma, orquestación) →
  `baluarte`; plataforma de datos (modelado físico, índices a escala, tuning,
  HA/DR) → `andulfo`; correctitud del código y code review → `certero`; ingeniería
  de rendimiento (metas/budgets/profiling) → `peakformance`; seguridad
  (arquitectura/threat model/gates) → `destroyer`; sistemas de IA/LLM →
  `sysuniversal-ai`. Se separan las dos autoridades upstream: `eneida`
  (arquitectura/tecnología) vs `orquesta` (flujo/secuencia, sin autoridad técnica);
  se retira la atribución de autoridad de arquitectura al "orquestador".
- §9 (cloud-plataforma) alineado: motor empaqueta su servicio y consume el paved
  road; el pipeline/despliegue/rollback/IaC de plataforma son de `baluarte`.

### Added
- **cláusula de invocación standalone** — motor es plenamente utilizable por sí
  solo; si no hay arquitecto/`eneida` ni `orquesta` upstream, no se bloquea (asume
  diseño razonable con `[SUPUESTO]`).

### Changed (refinamiento QA-2)
- Aclarada en §1 "Cadena de mando" la distinción `eneida` (arquitectura) vs `orquesta`
  (flujo, sin autoridad técnica); en el cuerpo, "arquitecto/orquestador" → "arquitecto
  (`eneida`)" donde se decide arquitectura.

### Changed (cierre QA-3)
- Cuerpo y frontmatter: se completó la conversión "arquitecto/orquestador" y
  "eneida/orquestador" → "eneida" donde se decide arquitectura; `orquesta` queda solo
  como flujo/secuencia.

### Notas
- sin cambio de objetivo (Backend Prime Developer); solo se corrigen
  contradicciones de ownership detectadas en la auditoría del equipo (2026-07-12).

## [2.0.1] - 2026-07-11

### Added — cross-link al nuevo agente mobile `palma`
- Se crea **`palma`** (Ingeniería Mobile): constructor de apps nativas y
  cross-platform. Motor **construye** el BFF/API que la app consume; el cliente móvil
  nativo/cross-platform es `palma` (el web es `farola`). Nota añadida en
  `apis-integracion` §5 (BFF). Sin cambios en el dominio, la cadena de mando ni las
  demás relaciones de Motor.

## [2.0.0] - 2026-06-29
### Changed (cambio mayor de identidad)
- **Reposicionamiento:** Motor deja de ser "Backend Prime Architect" y pasa a ser
  **"Backend Prime Developer" (Maestro Desarrollador Backend)**: un
  **desarrollador/implementador** de clase mundial que **recibe órdenes del
  orquestador/arquitecto** y las **construye con excelencia**. **El diseño de
  sistemas/arquitectura ya no es suyo**: lo decide el arquitecto (`eneida`) /
  orquestador; Motor lo implementa y **escala** las dudas de diseño.
- `SKILL.md` reescrito: identidad de desarrollador maestro + **cadena de mando**;
  frontmatter; principios rectores ahora centrados en el **oficio de codificar**
  (construir no rediseñar, código limpio/idiomático, correctitud, rendimiento
  medido, pruebas propias); §2 bis "Delegación y cadena de mando" (qué recibe vs
  qué ejecuta); modos A-D ahora **COMPRENSIÓN DEL ENCARGO → IMPLEMENTACIÓN →
  PRUEBAS PROPIAS+HARDENING → OPTIMIZACIÓN/DEPURACIÓN**; workflow, entradas,
  salidas, §6 (decisiones de implementación vs arquitectura), reglas de oro,
  estilo de respuesta y checklist de cierre alineados a "entregar código".
### Added
- **`oficio-desarrollo.md`** — el oficio del desarrollador maestro: código limpio,
  maestría idiomática por lenguaje, manejo de errores, refactorización segura,
  lectura de código ajeno, metodología de **depuración**, rendimiento a nivel de
  código, control de versiones/PRs y **test-craft** (§9 ampliada: qué pruebas
  escribe el dev, test doubles, fixtures/builders, casos borde/concurrencia/
  idempotencia, property-based, cobertura con sentido y anti-patrones de testing;
  E2E/contract/carga/chaos/regresión y no funcional quedan en `amado`).
### Renamed
- **`diseno-sistemas.md` → `escalabilidad-resiliencia.md`** y reencuadrado: ya no
  enseña "cómo hacer system design" (eso es del arquitecto), sino **cómo
  implementar** la escalabilidad/resiliencia/caching/colas que el arquitecto
  especificó. Referencias actualizadas en `SKILL.md`, `fundamentos-backend.md` y
  `stacks-tecnologias.md`.
### Reframed (a postura de implementación, sin perder profundidad)
- `fundamentos-backend.md`: estilos arquitectónicos pasan a "reconócelos para
  implementarlos"; heurística "cómo aplicarlo" → "cómo implementarlo".
- `stacks-tecnologias.md`: de "cómo elegir" a **"dominar la herramienta elegida"**;
  la elección y el cambio de stack los decide/aprueba el arquitecto.
- `apis-integracion.md`, `datos-persistencia.md`, `cloud-plataforma.md`: la
  **selección** (estilo de API, motor de datos, plataforma) es del arquitecto;
  estos archivos son para **implementar** y, si algo es inadecuado, **escalarlo**.
- `plantillas.md`: formato de respuesta del **desarrollador** (Encargo entendido →
  Plan de implementación → Código → Pruebas propias → Cómo correr/probar →
  Riesgos/escalamientos); "diseño de servicio" → "ficha de implementación"; RFC →
  "propuesta de implementación".
- `ejemplos.md`: ejemplos centrados en **implementar, depurar, refactorizar y
  escalar defectos de diseño** (ya no en decidir arquitectura).
### QA (pasada de coherencia)
- Eliminados role-bleeds residuales de la era "arquitecto": `observabilidad-
  operacion.md` (SLO/incidentes/capacity los define arquitecto/SRE; Motor
  instrumenta/participa/corrige/informa; costo se informa, no se decide),
  `ia-llm-backend.md` (§1 "cuándo aplica un LLM" lo decide el arquitecto),
  `cloud-plataforma.md` (DORA = métrica de equipo; platform engineering se
  consume, no se diseña), y checklists de `datos`, `cloud` y `apis` ("confirmado
  por el arquitecto" en vez de "elegido"). Sin enlaces rotos; índice maestro al día.

## [1.1.0] - 2026-06-29
### Changed
- **Reencuadre de rol:** Motor pasa a ser un agente de **ejecución/ingeniería
  backend** con frontera de rol explícita; deja de duplicar responsabilidades ya
  delegadas a otros agentes del ecosistema.
- `SKILL.md`: nueva sección **§2 bis "Delegación y colaboración"** con tabla de
  dueños; identidad con "Frontera de rol y delegación"; descripción (frontmatter)
  ajustada; modos reducidos a **A-D** (eliminado el modo LIDERAZGO/GOBIERNO);
  checklists, salidas y reglas de oro actualizadas hacia testabilidad + handoff;
  ADR pasa a **borrador** (lo gobierna eneida).
### Removed
- **`liderazgo-gestion.md`** — liderazgo técnico, governance, Team Topologies,
  roadmap, métricas DORA, organización/equipos → ahora responsabilidad del
  **arquitecto (`eneida`)**.
- **`calidad-testing.md`** — estrategia/diseño/ejecución de pruebas, contract/
  carga/chaos, gestión de defectos, métricas de calidad, code review de calidad →
  ahora responsabilidad del **QA (`amado`)**.
### Delegated (referencias actualizadas, no duplicadas)
- Selección de **modelos LLM** → `eneida`; **evals/red-teaming de IA** → `amado`
  (`ia-llm-backend.md` ahora cubre solo integración backend).
- DAST/fuzzing/pentest y herramientas de prueba → `amado`; ADR macro → `eneida`
  (`stacks-tecnologias.md`, `apis-integracion.md`, `observabilidad-operacion.md`,
  `plantillas.md`, `ejemplos.md` actualizados con punteros de delegación).
- Motor conserva **testabilidad por diseño** (código testeable, DI, puertos/
  adaptadores, hooks, instrumentación) y la corrección de defectos.

## [1.0.0] - 2026-06-29
### Added
- Versión inicial del agente skill **Motor — Backend Prime Architect**:
  arquitecto/staff/principal backend de clase mundial, integral, global y sin
  sesgo de stack, nube o industria.
- `SKILL.md` orquestador: identidad, 12 principios rectores, modos A-E
  (diagnóstico, diseño, ejecución, liderazgo, operación/incidentes), protocolo de
  elevación + checklist maestro, formato de respuesta obligatorio, índice maestro
  y checklist de cierre.
- Base de conocimiento (13 archivos) que cubre el rubro backend completo:
  - `fundamentos-backend.md` — SOLID, clean/hexagonal/onion, DDD, patrones,
    sistemas distribuidos, CAP/PACELC, consistencia, idempotencia, tolerancia a fallos.
  - `diseno-sistemas.md` — system design, escalabilidad, HA, resiliencia, caching,
    sharding, colas/streaming, backpressure, DR (RPO/RTO).
  - `apis-integracion.md` — REST/GraphQL/gRPC/WebSockets/webhooks, contratos,
    versionado, gateways, service mesh, orquestación vs coreografía.
  - `datos-persistencia.md` — selección de motor, modelado, índices, transacciones/
    concurrencia, replicación/sharding, migraciones, outbox/CDC/event sourcing, OLTP/OLAP.
  - `seguridad-backend.md` — authn/authz, OAuth2/OIDC/JWT, RBAC/ABAC/ReBAC, OWASP
    (web/API/ASVS/LLM), secretos, cifrado, hardening, auditoría, compliance.
  - `cloud-plataforma.md` — cómputo, contenedores, Kubernetes, serverless, IaC,
    networking/IAM, CI/CD, estrategias de release, platform engineering.
  - `observabilidad-operacion.md` — logs/métricas/trazas, OpenTelemetry, RED/USE,
    SLI/SLO/SLA + error budget, incidentes, runbooks, capacity, profiling, FinOps.
  - `calidad-testing.md` — estrategia de pruebas, contract/load/chaos testing,
    testability, code review, quality gates, docs como código.
  - `liderazgo-gestion.md` — colaboración con roles, priorización, deuda técnica,
    gobierno de arquitectura, Team Topologies, roadmap, métricas DORA.
  - `ia-llm-backend.md` — LLMs en backend, RAG, tool calling, agentes, costo/
    latencia/fiabilidad, evals, OWASP-LLM, observabilidad de pipelines de IA.
  - `stacks-tecnologias.md` — criterio comparativo neutral (lenguajes, frameworks,
    DBs, brokers, caches, search, observabilidad, CI/CD, seguridad).
  - `plantillas.md` — respuesta estándar, ADR, matriz de trade-offs, diseño de
    servicio, RFC, production readiness, plan de migración, postmortem.
  - `ejemplos.md` — ejemplos resueltos (few-shot) incl. diagramas Mermaid.
- Globalización en 4 entornos (Cursor, Claude personal, claude-trabajo, agentes)
  con sincronización por junctions desde la carpeta maestra `~/.motor`
  (`sincronizar.ps1`).
