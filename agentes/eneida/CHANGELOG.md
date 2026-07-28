# Changelog — Eneida (Primer Maestro)

Formato basado en Keep a Changelog. Versionado semántico.

## [3.1.1] — 2026-07-12

### Added
- `prisma` (Data Science: modelos/experimentos/inferencia causal) añadido al mapa de
  colaboración, RACI de especialistas y handoff (antes omitido).

### Added (cierre QA-3)
- Añadida cláusula de invocación standalone (paridad textual).

### Notas
- **Sin cambio de objetivo** (arquitectura).

## [3.1.0] - 2026-07-11

### Added — cross-links a handles del equipo (estandarización) + agente `palma`
- Se estandariza la interoperabilidad de Eneida nombrando a los **agentes concretos**
  del equipo por handle, **conservando el razonamiento por rol** (Eneida sigue siendo
  un arquitecto universal aplicable a cualquier organización). En `gobernanza-y-colaboracion`:
  handles inline en §2 "Frontera con cada rol"; nueva **§2.1 Mapa rol → agente**; nota de
  mapeo bajo la tabla RACI (§3); handles en cada "Handoff típico" (§4), añadiendo las
  flechas **→ Mobile (`palma`)** y **→ Performance (`peakformance`)**.
- Se incorpora **`palma`** (Ingeniería Mobile) como especialista de ejecución mobile.
- **Sin cambios** en el objetivo, el alcance (§1), el principio rol-basado, el RACI, los
  foros (§5), el escalamiento (§6), los anti-patrones (§7) ni el checklist.

## [3.0.0] - 2026-06-29
Reestructuración a **nivel de equipo enterprise**: Eneida pasa de "experto
integral" a **arquitecto de software/solución + líder técnico con disciplina de
alcance y colaboración**.

### Added
- **`gobernanza-y-colaboracion.md`** (nuevo): alcance estricto (SÍ hace / NO
  hace), frontera con cada rol (PO, BA, Delivery Manager/Orquestador,
  Platform/SRE, especialistas), **RACI de arquitectura**, **protocolo de
  handoff técnico** por disciplina, foros de gobernanza (architecture review,
  paved paths, fitness functions, excepciones con caducidad), escalamiento/
  desempate y anti-patrones de gobernanza.
- **Neutralidad tecnológica total** como eje de identidad (sin proveedor/stack
  por defecto).
- **GCP Architecture Framework / Well-Architected** y **ATAM (SEI)** en
  `frameworks.md`; ahora la matriz de trade-offs se fundamenta con ATAM.
- **Zero Trust (NIST SP 800-207)** como sección de primera clase en
  `seguridad-confiabilidad.md` (§1.b) y referenciado en `frameworks.md`.
- Roles **Business Analyst** y **Delivery Manager / Orquestador** explícitos en
  `liderazgo-gestion.md`.

### Changed
- `SKILL.md` reescrito a **v3.0**: nueva identidad (solution architect + tech
  lead), §1 Alcance (SÍ/NO/colaboración), principios innegociables (5 absolutos +
  operativos), **modo de trabajo de 6 pasos**, **entregables permanentes
  INFORME/ANÁLISIS/EJECUCIÓN GUIADA**, §9 Colaboración y handoffs, Modo D ampliado
  a Liderazgo/Gobernanza, checklist de cierre con verificación de ownership.
- `liderazgo-gestion.md` alineado con el modelo de límites y enlazado a la nueva
  gobernanza.

## [2.1.0] - 2026-06-26
### Added
- **Índice maestro** en `SKILL.md` (§0): mapa de secciones + tabla "qué consultar
  según el problema" y declaración de cobertura extremo a extremo.
- Nuevo archivo **`dominios-transversales.md`**: diseño de API/integración,
  ingeniería y plataforma de datos (OLTP/OLAP, lakehouse, ETL/ELT, gobernanza),
  arquitectura frontend/UX/móvil (render, Core Web Vitals, WCAG, i18n),
  rendimiento/capacidad y FinOps/TCO. Cierra los gaps para "experto integral".
### Changed
- Pasada de QA de coherencia: deduplicado DS&A entre `frameworks.md §10` y
  `fundamentos-ingenieria.md` (ahora §10 es selección de almacén + punteros).
- Cross-references añadidas para evitar contradicciones: auditoría
  (`frameworks.md §11` → `modernizacion-y-auditorias.md §7`) y SRE
  (`seguridad-confiabilidad.md §2` → `frameworks.md §3`).

## [2.0.0] - 2026-06-25
### Added
- Protocolo de **elevación** (Paso 0): reinterpretar instrucciones débiles y
  declarar supuestos antes de responder.
- Disciplina de decisión "por contexto, no por moda" + **heurísticas
  cuantitativas** (cuándo extraer microservicios, EDA, serverless, K8s, IA).
- Tipos de intervención: modernización por fases, migraciones, reingeniería,
  **rescate técnico**, **auditorías/due diligence** (`modernizacion-y-auditorias.md`).
- **GenAI como arquitectura**: RAG, agentes, tools, memoria, embeddings, vector
  stores, guardrails, gobernanza, evals, rollback/fallback (`genai-arquitectura.md`).
- **Seguridad/confiabilidad de primera clase**: STRIDE, OWASP, SRE, observabilidad,
  incident mgmt, runbooks (`seguridad-confiabilidad.md`).
- **Fundamentos de ingeniería** ampliados: datos, algoritmos, concurrencia,
  transacciones, consistencia, GoF + patrones distribuidos, testing
  (`fundamentos-ingenieria.md`).
- **Ejemplos resueltos (few-shot)**: ADR rellenado, matriz puntuada,
  mini-diagnóstico, C4 (`ejemplos.md`).
- Roles ampliados (PO/PM/EM/Tech Lead/QA/DevOps-Platform/Security/Data-AI) + RACI
  y modelo operativo (`liderazgo-gestion.md`).
- Plantillas nuevas: diagnóstico, arquitectura objetivo/transición, modernización,
  auditoría (`plantillas.md`).

### Changed
- `SKILL.md` reescrito como orquestador élite (11 principios, modos A-D con
  diagnóstico, estilo de respuesta, checklist ampliado).

## [1.0.0] - 2026-06-25
### Added
- Versión inicial: identidad, principios, modos A-D, workflow, marcos
  (AWS/Azure WAF, SRE/DORA, NASA Power of 10, DDD, Team Topologies, 12-Factor,
  C4/arc42, ADR), liderazgo PO/PM, método de selección de LLMs, plantillas.
- Globalización en 4 entornos (Cursor, Claude personal, claude-trabajo, agentes)
  con sincronización por junctions desde la carpeta maestra `~/.eneida`.
- Renombrado a "Eneida"; referencia siempre en masculino.
