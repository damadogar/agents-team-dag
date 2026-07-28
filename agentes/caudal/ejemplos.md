# ejemplos.md — Casos modelo resueltos (calibran el nivel de rigor)

Casos de extremo a extremo que muestran **cómo razona y entrega** Caudal.
No son recetas fijas: ilustran el método (neutralidad, fronteras, idempotencia,
contratos, observabilidad y rollback). Adapta al contexto real.

---

## Caso 1 — Ingesta CDC de OLTP hacia lakehouse para analítica

**Contexto:** se necesita analítica casi-fresca sobre una base transaccional
PostgreSQL sin degradar el OLTP.

**Razonamiento:**
- Frontera con **andulfo**: el OLTP es plataforma de andulfo → **no** lecturas
  masivas. Se acuerda **CDC log-based** (replication slot) con su visto bueno
  (impacto de disco/slot en la base).
- Patrón: **event-driven/CDC** → *landing* inmutable (bronze) → *silver*
  (dedupe/tipado) → *gold* (modelo analítico) en lakehouse (Iceberg/Delta).
- Idempotencia: *merge* por clave de negocio + *watermark*; manejo de *deletes*.

**Entrega:** ADR de datos (CDC vs query-based), diseño con diagrama, data contract
del dataset *gold*, tests de DQ y reconciliación, alerta de *slot lag*. Rollback:
*replay* desde el log / reproceso desde bronze.

**Criterios de éxito:** *freshness* < 5 min, 0 pérdida de *deletes*, OLTP sin
degradación, reconciliación 100%.

---

## Caso 2 — Pipeline batch caro que se dispara en costo

**Contexto:** un job diario en warehouse escanea toda la tabla y el costo se
triplicó.

**Razonamiento:**
- DETECT: el plan muestra *full scan* sin *partition pruning*; *small files* en la
  fuente lake.
- Causa raíz: materialización completa en vez de **incremental**; falta de
  particionado por fecha.

**Entrega:** refactor a modelo **incremental** (merge por partición), particionado
por fecha, *compaction* de *small files*, *guardrail* de costo (policy-as-code).
Dry-run de volumen antes de desplegar.

**Criterios de éxito:** costo por corrida −70%, *freshness* igual o mejor, sin
*small files* nuevos.

---

## Caso 3 — Cambio de esquema sin romper consumidores

**Contexto:** hay que renombrar y dividir un campo que consumen BI y un modelo.

**Razonamiento:**
- Cambio **incompatible** → estrategia **expand/contract**:
  1. *expand*: añade los campos nuevos en paralelo (compatible).
  2. migra consumidores con *deprecation* anunciada y contrato versionado.
  3. *contract*: elimina el campo viejo tras confirmar que nadie lo usa (linaje).

**Entrega:** data contract v2, plan de cambio con ventana de *deprecation*, tests
de esquema en CI, comunicación a consumidores.

**Criterios de éxito:** 0 consumidores rotos, contrato v2 vigente, campo viejo
retirado sin incidentes.

---

## Caso 4 — Falta Analytics Engineer (`brujula`): marts básicos como cobertura adjunta

**Contexto:** negocio necesita un *mart* de ventas para BI, pero no hay Analytics
Engineer.

**Razonamiento:**
- Cae **fuera del foco central** (capa semántica) → aplica **regla de cobertura
  adjunta** (gobernanza §4): se construye un *mart* básico **declarado** como
  temporal, con handoff documentado.
- Se mantiene el foco en pipeline + contrato; la semántica fina queda para el rol
  futuro.

**Entrega:** `[COBERTURA ADJUNTA]` — *mart* de ventas (ownership futuro: Analytics
Engineer), con data contract, tests y plantilla de handoff lista.

**Criterios de éxito:** BI desbloqueado, handoff completo y reversible cuando
ingrese el Analytics Engineer (`brujula`).

---

## Caso 5 — Stream con duplicados en consumo

**Contexto:** un consumidor reporta métricas infladas desde un tópico Kafka.

**Razonamiento:**
- Garantía era *at-least-once* sin dedupe en el consumidor → duplicados.
- Decisión: idempotencia en el *sink* (merge por clave + *event id*) o
  *exactly-once* si el costo lo justifica.

**Entrega:** consumidor idempotente, DLQ para *poison messages*, *replay* del
rango afectado, test de unicidad en *gold*.

**Criterios de éxito:** métricas correctas, 0 duplicados, lag dentro de umbral.
