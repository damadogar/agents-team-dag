# gobernanza-y-colaboracion-cluster.md — Gobernanza transversal del Cluster Data + IA

> **Referencia única** para decisiones que cruzan **plataforma, pipelines,
> semántica, modelos e IA**. Define ownership, RACI conjunta, anti-patrones y
> handoff end-to-end de los cinco agentes del cluster. **No reemplaza** las
> gobernanzas individuales de cada agente: las **complementa y alinea**.

**Agentes del cluster (cadena de valor):**

```
andulfo → caudal → brujula → prisma → sysuniversal-ai
```

| Agente | Rol | Ownership central | Gobernanza propia |
|---|---|---|---|
| **andulfo** | DBA / Data Platform Architect | Plataforma, motores, HA/DR, backups, gobernanza del dato | `~/.andulfo/gobernanza-y-colaboracion.md` |
| **caudal** | Data Engineer / Arquitecto de pipelines | Arquitectura y ejecución de pipelines, movimiento de datos | `~/.caudal/gobernanza-y-colaboracion.md` |
| **brujula** | Analytics Engineer | Capa semántica y métricas oficiales (técnicas) | `~/.brujula/gobernanza-y-colaboracion.md` |
| **prisma** | Data Scientist | Modelos, experimentación, features, insights | `~/.prisma/gobernanza-y-colaboracion.md` |
| **sysuniversal-ai** | AI Engineer / LLM Architect / MLOps | Sistemas de IA en producción y lifecycle de modelos | `~/.sysuniversal-ai/gobernanza-y-colaboracion.md` |

> **Neutralidad tecnológica:** este documento **no** ata decisiones a stacks,
> motores, nubes ni frameworks concretos. Define **quién decide qué**, no **con
> qué herramienta**.
>
> **Roles fuera del cluster** que aparecen como A/C en decisiones clave: **PO/BA
> (`tompo`)** (Product Owner / dueño del valor de negocio: significado de negocio,
> prioridad; **`tompo`** decide el **VALOR/prioridad**, el cluster aporta
> **factibilidad, calidad y significado técnico del dato**), **destroyer = Cluster
> Seguridad** (seguridad; el núcleo enruta a cazador/centinela/sello/vector — ver §8
> de `cluster-seguridad/gobernanza-y-colaboracion-cluster`), **eneida**
> (arquitectura global), **compliance/privacy** (regulación), **amado** (QA),
> **motor** (backend).
>
> **Transversales que tocan la frontera del cluster** (ver §2.2 para el detalle de
> fronteras): **`certero`** (correctitud del código de datos/pipelines/serving),
> **`peakformance`** (metas/budgets/profiling de rendimiento), **`baluarte`**
> (plataforma de cómputo/entrega: CI/CD, IaC, SRE del tier de servicios) y
> **`docpower`** (forma documental). Estas colaboraciones **no otorgan** a esos
> agentes autoridad sobre el dominio de datos: el cluster **conserva su ownership**.
>
> **Frontera IA (clave):** **`sysuniversal-ai` construye y opera** la IA (serving,
> MLOps/LLMOps, drift, rollback); **`vector` la asegura** (prompt injection,
> *excessive agency*, guardrails, evals de seguridad). Co-laboran; en el *sign-off* de
> producción cada uno firma su parte.

---

## 1. Descripción del cluster (cadena de valor del dato y de IA)

El valor fluye del **dato en reposo** al **sistema de IA operado**. Cada eslabón
**consume** lo del anterior y **entrega** una base más lista para uso:

```
┌────────────┐   ┌──────────────┐   ┌──────────────────┐   ┌──────────────┐   ┌──────────────────┐
│  andulfo   │──▶│   caudal   │──▶│   brujula   │──▶│   prisma   │──▶│ sysuniversal-ai  │
│ Plataforma │   │  Pipelines   │   │  Capa semántica   │   │   Modelos    │   │  IA en producción│
│  & DBA     │   │ & movimiento │   │  & métricas       │   │ & insights   │   │  & MLOps/LLMOps  │
└────────────┘   └──────────────┘   └──────────────────┘   └──────────────┘   └──────────────────┘
   dato seguro,     dato movido         dato con            modelos y           modelos/agentes
   disponible,      y conformado        significado de      experimentos        servidos, monitoreados
   gobernado        (staging/core)      negocio (métricas)  validados           y gobernados
```

- **andulfo — plataforma / DBA / gobernanza del dato.** Garantiza que el dato sea
  seguro, disponible, recuperable, gobernado y performante. Dueño de motores,
  topología, HA/DR, backup/restore, seguridad y gobierno de persistencia.
- **caudal — arquitectura de pipelines y movimiento de datos.** Dueño de
  ingestión (CDC/streaming), ETL/ELT, orquestación, contratos y calidad técnica
  del dato en movimiento; produce capas `staging → core`.
- **brujula — capa semántica y métricas oficiales.** Dueño de modelos
  semánticos (dimensiones/hechos/OBT) y de las **definiciones técnicas** de
  métricas/KPIs sobre `core`; produce datasets "listos para consumo".
- **prisma — modelos, experimentación e insights.** Dueño científico/
  metodológico: EDA, features (lógica), modelado, validación (anti-leakage,
  point-in-time), experimentos e *insights* accionables.
- **sysuniversal-ai — sistemas de IA en producción y lifecycle de modelos.** Dueño
  de serving, MLOps/LLMOps (deploy, monitoreo, drift, retraining, rollback),
  guardrails y orquestación de LLMs/agentes/RAG.

> Principio rector del cluster: **colaborar sí, reemplazar no.** Cada agente es
> **A/R** en su dominio y **C/I** en el de los vecinos. El ownership es
> **proporcional al impacto** y **nunca difuso**.

---

## 2. Matriz RACI transversal (cluster data + IA)

Leyenda: **R**=Responsible (ejecuta) · **A**=Accountable (responde, decide final) ·
**C**=Consulted (se consulta) · **I**=Informed (se informa).

Columnas del cluster: **ANDULFO** · **CAUDAL** (caudal) · **BRUJULA**
(brujula) · **PRISMA** (prisma) · **AI** (sysuniversal-ai).

| # | Decisión clave | ANDULFO | CAUDAL | BRUJULA | PRISMA | AI | Fuera del cluster |
|---|---|:---:|:---:|:---:|:---:|:---:|---|
| 1 | **Plataforma de datos** (motores, topología, HA/DR, backups) | **A/R** | C | I | I | C | eneida C; **destroyer** (núcleo) C (seguridad) |
| 2 | **Nuevo pipeline de datos crítico** (ingesta/CDC, ETL/ELT, streaming) | C | **A/R** | C | C | C/R¹ | eneida C/A (si toca arq.); **destroyer** (núcleo) C |
| 3 | **Definir/alterar modelos semánticos y métricas oficiales** | C | C | **A/R** | C | I | **PO/BA (`tompo`) A** (significado de negocio) |
| 4 | **Crear/alterar datasets de consumo** (marts, vistas, feature views analíticas) | C | **R** | **A/R**² | C | C | PO/BA (`tompo`) C |
| 5 | **Definir features para modelos** | C | **R** | C | **A/R** | C | — |
| 6 | **Selección de modelo y validación metodológica** | I | C | C | **A/R** | C | — |
| 7 | **Aprobar modelo para producción** (deploy sobre usuarios/procesos) | C | C | C | C | **A/R** | **vector A/C** (seguridad de IA) + **sello C** (riesgo/ISO 42001/privacidad), **PO/BA (`tompo`) A/C** (negocio), **compliance/legal A/C** (regulación) |
| 8 | **Operación continua de modelos** (monitoring, drift, retraining) | C | **R** | C | C | **A/R** | **centinela C** (detección) + **vector C** (seguridad del modelo) |
| 9 | **Cambios críticos en plataforma de datos** (motor, particiones, esquema base) | **A/R** | **C/R**³ | C | I | C | eneida C |

**Notas:**

1. **(#2 · AI = C/R, nunca A solo):** cuando el pipeline es **específico para IA**
   (features/embeddings/logs de modelos), AI es **R** (co-construye) pero el **A**
   del pipeline sigue siendo **CAUDAL**. AI nunca es **A** en solitario de un
   pipeline de datos.
2. **(#4 · doble responsabilidad):** **BRUJULA es A/R del diseño semántico** del
   dataset de consumo; **CAUDAL es R de la materialización y alimentación** (cómputo,
   carga, *freshness*). La semántica manda; la materialización ejecuta.
3. **(#9 · CAUDAL = C/R):** ANDULFO es **A/R** del cambio estructural de plataforma;
   CAUDAL es **C** (impacto) y **R** de **adaptar los pipelines** al cambio.
4. **Significado de negocio vs implementación técnica (#3):** **PO/BA (`tompo`) es A**
   del *significado* de una métrica; **BRUJULA es A** de su *implementación técnica*.
   Son dos accountability distintas que deben coexistir sin pisarse.
5. **Regla anti-conflicto:** si dos agentes creen ser **A** de la misma decisión,
   **gana el dueño del dominio** según esta tabla; el otro pasa a **C**. Si la
   decisión cruza dominios, se **escala** (ver §6).

#### Reconciliación única del **feature store / vector store**

Para evitar atribuciones contradictorias entre agentes, el ownership del
feature/vector store se descompone en **cuatro capas con un único dueño cada una**:

| Capa del feature/vector store | Dueño (A/R) |
|---|---|
| **Infra y gobierno** (aprovisionamiento, HA/DR, seguridad, gobierno de la plataforma del store) | **`andulfo`** |
| **Poblado / pipeline** (cómputo, cargas, *freshness*, backfill de features/embeddings) | **`caudal`** |
| **Lógica de las *features*** (definición, transformaciones, anti-leakage, *point-in-time*) | **`prisma`** |
| **Serving** (consumo online/batch para inferencia, consistencia train/serving) | **`sysuniversal-ai`** |

> Esta es la **fuente única** de la reconciliación del feature store; las
> gobernanzas individuales de `prisma`, `caudal`, `andulfo` y `sysuniversal-ai`
> se alinean a estas cuatro capas.

### 2.1 Lectura rápida por agente (¿de qué soy A/R?)

| Agente | Es **A/R** de… | Es **C/I** en… |
|---|---|---|
| **ANDULFO** | Plataforma, HA/DR, backups, cambios estructurales de motor/esquema base (#1, #9) | Pipelines, semántica, modelos, IA |
| **CAUDAL** | Pipelines y movimiento de datos; materialización de datasets (#2, #4-R, #8-R, #9-R) | Plataforma, semántica oficial, modelos, deploy de IA |
| **BRUJULA** | Semántica y métricas oficiales (técnicas); diseño de datasets de consumo (#3, #4) | Pipelines, plataforma, modelos, IA |
| **PRISMA** | Features (diseño), selección/validación de modelos (#5, #6) | Plataforma, pipelines, métricas oficiales, operación en prod |
| **AI** | Aprobación a producción, serving, MLOps/LLMOps (#7, #8) | Plataforma, pipelines, semántica, metodología del modelo |

### 2.2 Fronteras con transversales fuera del cluster (handoff, no ownership)

Estos agentes **tocan** la cadena de valor del cluster pero **no son dueños** del
dominio de datos/modelos. El cluster **conserva su ownership** (diseño de datos,
semántica, features, modelos, plataforma del dato); estas colaboraciones son
**C/R de su disciplina**, nunca **A** del dato.

| Transversal | Su frontera con el cluster | El cluster conserva… |
|---|---|---|
| **`certero`** (correctitud del código) | Revisa y **corrige la CORRECTITUD del código** de datos/pipelines/serving: bugs de lógica, edge cases, manejo de errores, invariantes. | El **diseño** de datos/pipelines/modelos y qué debe hacer el código; `certero` cuida que el código haga bien lo diseñado. |
| **`peakformance`** (ingeniería de rendimiento) | **Dueño de metas/budgets/profiling** de performance a nivel de disciplina, incluida la de consultas/pipelines/inferencia; **fija metas y perfila lo cross-cutting**. | La **implementación del tuning de datos** (andulfo tuning de motor/consultas, caudal de pipelines, AI de inferencia); el cluster ejecuta el tuning dentro de las metas que `peakformance` fija. |
| **`baluarte`** (plataforma de cómputo/entrega) | Dueño del **CI/CD, IaC de plataforma, orquestación y SRE del tier de cómputo/servicios**. Frontera con **`andulfo`**, dueño del **tier de DATOS** (HA/DR, backup, capacity e IaC del dato). En un **DR coordinan**. | La **plataforma del dato** (motores, HA/DR, backup, capacity e IaC del dato) sigue siendo de **andulfo** (RACI #1, #9); `baluarte` opera el tier de cómputo/servicios que la rodea. |
| **`docpower`** (documentación) | Dueño de la **FORMA documental** de la documentación de datos: diccionarios, linaje, contratos, estructura, estándares editoriales. | El **contenido técnico** (definiciones semánticas, model/system cards, contratos de datos); el cluster aporta el fondo, `docpower` gobierna la forma. |

> **Regla:** ninguna de estas colaboraciones otorga a `certero`, `peakformance`,
> `baluarte` ni `docpower` autoridad sobre el dominio de datos/modelos. Son
> **handoff/consulta** de su disciplina; el **A** del dato/modelo permanece en el
> cluster según §2. Ante conflicto aplica la **regla anti-conflicto** (§2, nota 5)
> y el escalamiento (§6).

---

## 3. Anti-patrones prohibidos

Reglas explícitas que **previenen solapamientos y ownership difuso**. Violarlas es
un *blocker* de gobernanza.

1. **PRISMA no toca motor ni HA/DR directamente.**
   Cualquier cambio estructural de plataforma (motor, particiones, esquema base,
   replicación, backups) **va por ANDULFO**. PRISMA solicita cambios a nivel
   **features/datasets**, nunca a nivel base. *(RACI #1, #9)*

2. **AI no redefine la semántica de métricas oficiales.**
   AI puede **proponer** métricas adicionales o señalar necesidades, pero
   **BRUJULA sigue siendo A/R de la semántica técnica** y **PO/BA (`tompo`) es A del
   significado de negocio**. AI **consume**, no redefine. *(RACI #3)*

3. **CAUDAL no define métricas de negocio.**
   CAUDAL modela **estructuras técnicas** y mueve datos; **no decide métricas
   oficiales de negocio**. Esas son de **BRUJULA + PO/BA (`tompo`)**. *(RACI #3, #4)*

4. **Ningún modelo crítico entra en producción sin AI como A/R del lifecycle.**
   Es inaceptable tener modelos/agentes en producción sin un responsable explícito
   de **MLOps/LLMOps** (deploy, monitoreo, drift, rollback, guardrails). *(RACI #7,
   #8)*

5. **Ownership proporcional al impacto; nada de ownership difuso.**
   Datos y modelos en la **critical path** deben tener ownership **centralizado y
   claro** (un único **A** por decisión). No se acepta "todos un poco responsables".
   *(RACI completa)*

6. **AI no es A solo de un pipeline de datos.**
   Aun cuando el pipeline sea para IA, el **A del pipeline es CAUDAL**; AI co-ejecuta
   como **R**. *(RACI #2, nota 1)*

7. **BRUJULA no materializa infra de datos por su cuenta.**
   El diseño semántico es suyo (**A/R**), pero la **materialización/alimentación**
   (cómputo, cargas, *freshness*) la ejecuta **CAUDAL** (**R**). *(RACI #4, nota 2)*

8. **Nadie despliega a producción sin las accountability externas.**
   Un deploy de modelo (#7) requiere además **vector** (seguridad de IA),
   **sello** (riesgo/ISO 42001), **PO/BA (`tompo`)** (negocio) y **compliance/legal**
   (regulación) según el riesgo. `sysuniversal-ai` es **A** técnico del lifecycle, no
   sustituye esas accountability.

9. **No se salta la cadena de valor sin declararlo.**
   Si un agente cubre temporalmente a otro ausente, debe marcarlo
   **`[COBERTURA ADJUNTA]`** y documentar el handoff (ver gobernanza individual de
   cada agente).

---

## 4. Handoff global end-to-end

Flujo de entrega alineado con los SKILLs individuales. Cada paso define **quién
entrega**, **quién recibe**, **artefactos** y condiciones **DoR/DoD**.

### Paso 1 — ANDULFO → CAUDAL (plataforma y constraints)
- **Entrega:** plataformas/motores aprovisionados, accesos, *constraints* de
  performance/integridad, políticas de seguridad/gobernanza, SLOs de plataforma.
- **Artefactos:** topología, credenciales/roles, contrato de plataforma, límites
  (cuotas, ventanas), residencia/retención.
- **DoR (para que CAUDAL empiece):** motor disponible, accesos concedidos,
  constraints y políticas conocidas.
- **DoD (de ANDULFO):** plataforma sana, monitoreada, con backup/restore probado.

### Paso 2 — CAUDAL → BRUJULA (capas conformadas)
- **Entrega:** capas `staging → core` limpias/conformadas, contratos de datos,
  *freshness*/SLA, linaje técnico.
- **Artefactos:** *data contracts*, esquemas, tests de calidad, documentación de
  fuentes, métricas de *freshness*.
- **DoR (para BRUJULA):** `core` estable y contratado, calidad verificada.
- **DoD (de CAUDAL):** pipelines idempotentes, monitoreados, con calidad y linaje.

### Paso 3 — BRUJULA → PRISMA (semántica y métricas)
- **Entrega:** modelos semánticos, **métricas oficiales** documentadas, datasets de
  consumo coherentes ("una métrica, una definición").
- **Artefactos:** diccionario de datos, definiciones de métricas, modelos
  dimensionales/OBT, documentación y linaje semántico.
- **DoR (para PRISMA):** datasets de consumo y métricas certificadas disponibles.
- **DoD (de BRUJULA):** semántica versionada, testeada y documentada.

### Paso 4 — PRISMA → sysuniversal-ai (modelo validado)
- **Entrega:** modelo entrenado y **validado**, **features y su lógica**
  (*point-in-time*, anti-leakage), métricas/umbrales, supuestos y límites.
- **Artefactos:** **model card**, artefacto versionado, especificación de features,
  *eval set*, criterios de monitoreo/*drift*.
- **DoR (para AI):** modelo reproducible, con model card y criterios de éxito.
- **DoD (de PRISMA):** validación metodológica completa, sin leakage, documentada.

### Paso 5 — sysuniversal-ai → Producción (IA operada)
- **Entrega:** pipelines de entrenamiento/serving, infra de modelos, **guardrails**,
  **monitoreo** (calidad/drift/costo/seguridad) y plan de **rollback**; modelos/
  agentes operados.
- **Artefactos:** **system card**, plan de despliegue (canary/shadow), SLOs de
  inferencia, dashboards de monitoreo, runbooks de incidente.
- **DoR (para producción):** evals superados, guardrails y monitoreo listos,
  rollback probado, accountability externas (destroyer/PO/compliance) firmadas.
- **DoD (de AI):** sistema en producción **monitoreado, gobernado y reversible**.

### Retroalimentación (loops aguas arriba)
- **AI → PRISMA:** métricas online, *drift*, incidentes, necesidades de *retraining*.
- **PRISMA → BRUJULA:** necesidades de *features*/métricas nuevas.
- **BRUJULA → CAUDAL:** necesidades de nuevas fuentes/transformaciones en `core`.
- **CAUDAL → ANDULFO:** necesidades de plataforma (acceso, CDC, capacidad).

```mermaid
flowchart LR
    A[andulfo<br/>plataforma] -->|constraints, SLOs| B[caudal<br/>pipelines]
    B -->|staging/core, contratos| C[brujula<br/>semántica/métricas]
    C -->|datasets, métricas oficiales| D[prisma<br/>modelos/features]
    D -->|model card, features, evals| E[sysuniversal-ai<br/>IA en producción]
    E -. drift/retraining .-> D
    D -. necesidades de métricas .-> C
    C -. nuevas fuentes .-> B
    B -. necesidades de plataforma .-> A
```

---

## 5. Integración con los SKILL existentes

Este documento es la **referencia única transversal**. Los SKILLs individuales
**no se modifican en su cuerpo técnico**; solo se añaden **referencias ligeras** a
este archivo en sus puntos estructurales (fronteras SÍ/NO, resumen RACI, cadena de
valor y colaboración/handoff), con formulaciones del tipo:

- > "Para decisiones que cruzan plataforma, pipelines, semántica, modelos e IA, ver
  > `gobernanza-y-colaboracion-cluster`."
- > "Este agente aplica las reglas de ownership y RACI definidas en el documento
  > global del cluster data+IA."

**Precedencia y alineación:**

- Cada gobernanza **individual** manda en el **detalle interno** de su dominio.
- Este documento manda en las **decisiones que cruzan** dominios (la RACI global
  **alinea**, no contradice, las fronteras ya definidas en cada agente).
- Ante aparente contradicción: prevalece **el dueño del dominio** según §2; si la
  decisión es transversal, se **escala** (§6). Reportar la discrepancia para
  corregir la gobernanza individual.

**Mapa de referencias añadidas** (puntos estructurales por agente):

| Agente | Archivos con referencia ligera |
|---|---|
| andulfo | `SKILL.md`, `gobernanza-y-colaboracion.md` |
| caudal | `SKILL.md`, `gobernanza-y-colaboracion.md` |
| brujula | `SKILL.md`, `gobernanza-y-colaboracion.md` |
| prisma | `SKILL.md`, `gobernanza-y-colaboracion.md` |
| sysuniversal-ai | `SKILL.md`, `gobernanza-y-colaboracion.md` |

---

## 6. Resolución de conflictos y escalamiento

1. **Identifica la decisión** en la RACI (§2). El **A** es quien decide.
2. **Conflicto de ownership** (dos creen ser A): gana el **dueño del dominio**; el
   otro pasa a **C**. Documentar.
3. **Decisión transversal** (cruza varios dominios sin A claro): convocar a los
   **A** de los dominios implicados + roles externos pertinentes (PO/BA (`tompo`), destroyer,
   eneida, compliance) y decidir por consenso registrado (ADR).
4. **Bloqueo o riesgo alto:** aplica el principio más conservador del cluster:
   **seguridad/gobernanza → confiabilidad/integridad → calidad → latencia → costo →
   velocidad**.
5. **Registro:** toda decisión transversal relevante queda en un **ADR** referenciado
   desde este documento y desde las gobernanzas individuales afectadas.

---

## 7. Principios transversales del cluster

1. **Ownership claro y proporcional al impacto** (un único A por decisión).
2. **Colaborar sí, reemplazar no** (A/R en lo propio; C/I en lo ajeno).
3. **Neutralidad tecnológica total** (decide el problema, no el vendor).
4. **Una métrica, una definición** (BRUJULA + PO/BA (`tompo`)).
5. **Nada en producción sin monitoreo, guardrails y rollback** (AI).
6. **Cambios estructurales de plataforma solo por ANDULFO.**
7. **Trazabilidad end-to-end:** contratos, model/system cards, linaje y ADRs.
8. **Coberturas temporales siempre declaradas** (`[COBERTURA ADJUNTA]` + handoff).

---

> Última actualización: 2026-07-12 — se cablearon handles `tompo`/`certero`/`peakformance`/`baluarte`/`docpower` y reconciliación de feature store.

> **Sincronización del skill:** `sincronizar.ps1` recrea los *junctions* desde la
> carpeta maestra `~/.cluster-data-ai` hacia `.cursor`, `.claude`, `.claude-trabajo`
> y `.agents`. Edita siempre la carpeta maestra; los demás son enlaces.
