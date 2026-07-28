# ADR-001 — Decomposición de Destroyer en el Cluster Seguridad (5 agentes)

- **Estado:** Aceptado
- **Fecha:** 2026-06-29
- **Decisores:** Owner del ecosistema + Destroyer (núcleo)
- **Ámbito:** Cluster Seguridad (destroyer + cazador/centinela/sello/vector)

---

## Contexto

`destroyer` era un agente monolítico "Primer Maestro de Ciberseguridad" de espectro
completo (arquitectura, ofensiva, defensiva, detección/IR, DevSecOps, GRC, privacidad,
IA). El objetivo del proyecto es un **equipo de agentes autónomo y profesional
(modelo enterprise)**, adaptable a cualquier proyecto. Un solo agente full-spectrum
diluye el contexto por tarea, mezcla audiencias (red team vs C-level) y no refleja la
organización real de una función de seguridad. Ya existía el precedente del cluster
`andulfo` (5 agentes auto-contenidos + gobernanza transversal), validado y en uso.

## Decisión

Descomponer `destroyer` en un **cluster de 5 agentes** siguiendo el patrón `andulfo`
(carpeta maestra `~/.<nombre>` + `sincronizar.ps1` con junctions + gobernanza
transversal), con el **modelo delegador**: el núcleo conserva arquitectura, DevSecOps,
criptografía, remediación y la **orquestación**, y delega el detalle profundo a los
satélites.

| Agente | Rol | Dominios propios |
|---|---|---|
| **destroyer** (núcleo) | Security Architect + DevSecOps + Cripto + Remediación + Orquestador | arquitectura-seguridad, devsecops, criptografia, remediacion, dominios-sistemas, auditoria-evaluacion, seguridad-fisica, herramientas, elite-mundial + base compartida |
| **cazador** | Ofensiva / Red Team / Pentest | ofensiva |
| **centinela** | Defensiva / Detección / SOC / DFIR-IR | defensiva, deteccion-respuesta |
| **sello** | GRC / ISO / Privacy-DPO / Factor humano / TPRM | grc, privacidad, factor-humano |
| **vector** | Seguridad de IA/LLM/agentes (transversal) | ia-llm-seguridad |

Reglas que blindan la decomposición:
- **Línea roja heredada idéntica** (§0/§0bis/§6bis + assurance + evals) en los 5 agentes.
- **Un único A por decisión** (RACI en `gobernanza-y-colaboracion-cluster.md`).
- **Un archivo de dominio = un solo dueño**; base compartida con dueño canónico (núcleo)
  y copia auto-contenida en cada satélite (patrón andulfo).
- **Cadena purple intacta** vía handoff explícito red→núcleo→blue.
- **Cobertura adjunta declarada** cuando un satélite no está disponible.

## Alternativas consideradas

1. **Monolito con modos (statu quo).** Rechazada: no escala como equipo profesional,
   diluye contexto y mezcla audiencias.
2. **Cluster mínimo (núcleo + grc, ai opcional).** Buena relación valor/coste, pero el
   usuario pidió **máximo enterprise**: Red y Blue separados como en una org real.
3. **Cluster máximo de 5 (elegida).** Refleja la organización CISO real (SecArch/
   DevSecOps, Red, Blue/SecOps, GRC, AI Security) y maximiza claridad de ownership.
4. **Absorber roles no-seguridad** (infra/SRE, acreditación ISO 17024/ONAC, legal):
   rechazada — son dominios distintos (otros agentes del equipo), no del cluster.

## Consecuencias

**Positivas:** ownership nítido, invocación enfocada, paridad con org enterprise,
agentes maestros/neutrales/universales y auto-contenidos, gobernanza transversal única.

**Costes / riesgos asumidos:**
- **Drift de la base compartida** entre 5 copias → mitigación: dueño canónico (núcleo) +
  re-copiar al actualizar (futuro: paso en `sincronizar`).
- **Gaps en costuras** → mitigación: checklist anti-gap (abajo) + handoffs en la gobernanza.
- **Pérdida de línea roja en un satélite** → mitigación: herencia obligatoria + eval.

**Rollback:** existe backup completo del `destroyer` monolítico (copia renombrada fuera
de ruta). Revertir = restaurar esa carpeta a `~/.destroyer`, eliminar
`~/.cazador|blue|grc|ai` y `~/.cluster-seguridad`, y re-ejecutar `sincronizar.ps1`.

---

## Checklist anti-gap (costuras con dueño explícito)

| Costura (riesgo de caer entre sillas) | Dueño | Apoyo |
|---|---|---|
| Gestión de secretos y criptografía | **núcleo** (A/R) | centinela C (detección de fugas) |
| Gates de seguridad en CI/CD (DevSecOps) | **núcleo** (define el control) | **infra/plataforma `baluarte` R** (opera el pipeline) |
| Hallazgo ofensivo → fix → retest → detección | **núcleo** (fix) + **cazador** (retest) + **centinela** (detección) | sello (riesgo residual) |
| Incidente con impacto regulatorio (notificación) | **centinela** (técnico) + **sello** (cumplimiento) + **legal** (interpretación/plazos) | — |
| Privacidad: diseño técnico vs programa vs ley | **núcleo** (técnico) + **sello** (programa/DPIA) + **legal** (Ley 1581/GDPR) | — |
| Seguridad de IA en arquitectura general | **vector** (control IA) + **núcleo** (arquitectura) | cazador (red-teaming IA), centinela (detección IA) |
| Security sign-off de release | **núcleo** (técnico) + **PO** (negocio) + **sello** (regulación) | — |
| Gestión continua de vulnerabilidades (escaneo + SLA + remediación) | **centinela** (A/R operación: escaneo, monitoreo, triage técnico) + **sello** (A/R SLA, priorización por riesgo, excepciones) | **núcleo R** (remediación/fix); cazador C (validación puntual) |

> Regla: ninguna de estas costuras puede quedar sin un **A** nombrado. Si aparece una
> nueva costura, se asigna dueño en la gobernanza del cluster antes de operarla.

## Conexión con el equipo completo (futuro)

El Cluster Seguridad interactúa con el resto del equipo (eneida=arquitectura global,
motor=backend, farola/uxui=frontend/UX, amado=QA, cluster andulfo=datos, `baluarte`=DevOps/SRE/plataforma (infra: define seguridad el cluster, opera plataforma/pipeline baluarte),
legal, conformidad, PO, orquestador, documentador). Cuando el equipo esté completo,
crear una **gobernanza org-level** (RACI entre clusters) que referencie esta del cluster
seguridad — análoga a cómo `cluster-data-ai` coordina a los agentes de datos.

## Criterios de éxito (verificados)

- [x] 5 agentes creados, sincronizados (junctions en 4 entornos) y validados.
- [x] Línea roja (§0/§0bis/§6bis) presente en los 5.
- [x] Núcleo refactorizado a delegador, sin referencias colgantes, línea roja intacta.
- [x] Gobernanza transversal con RACI, anti-patrones, handoff y precedencia.
- [x] Un archivo de dominio = un dueño; base compartida con dueño canónico.
- [ ] (Pendiente equipo) Gobernanza org-level entre clusters.

---

## Addendum 1 (2026-06-29) — Limpieza de consistencia de archivos y enlaces

Auditoría posterior a la construcción detectó **copias generosas** de archivos de
dominio en satélites (sin justificación de ownership) y una **base inconsistente**. Se
corrigió hacia un **modelo de dos niveles, sin ambigüedad**:

- **Nivel 1 — Base compartida idéntica en los 5:** `frameworks`, `herramientas`,
  `elite-mundial`, `plantillas`, `checklists`, `ejemplos`, `ejecucion-autonoma`,
  `assurance`, `evals/`. (`herramientas` y `elite-mundial` se **reclasifican de dominio
  a base**: son andamiaje/excelencia transversal, no materia de un dominio.)
- **Nivel 2 — Dominios, un único dueño, alcanzados por referencia** (no copia).

**Cambios aplicados:**

- **Eliminados (mal ubicados):** `cazador/remediacion.md` y
  `cazador/dominios-sistemas.md` (son del núcleo; red no remedia, retesta);
  `centinela/seguridad-fisica.md` (núcleo); `sello/auditoria-evaluacion.md`
  (núcleo es dueño del método universal del Modo F; grc lo referencia).
- **Completada la base:** `herramientas.md` y `elite-mundial.md` copiados a
  `sello` y `vector` (faltaban).
- **Creado:** `destroyer/gobernanza-y-colaboracion.md` (el núcleo no la tenía).
- **Normalizados todos los enlaces cruzados** a referencia del agente dueño
  (`[x.md](x.md)` → `… → skill destroyer-Y`). Verificado: **0 enlaces rotos** en los 5.
- **Cross-cluster wired:** la gobernanza de seguridad gana §8 (relación con Data+IA y
  equipo); la de `cluster-data-ai` traduce "destroyer" a sub-agentes (núcleo/red/blue/
  grc/ai) en RACI #1/#2/#7/#8 y declara la frontera `sysuniversal-ai` (construye/opera)
  vs `vector` (asegura).

**Decisión de ownership de `auditoria-evaluacion`:** queda en el **núcleo** (método
universal de auditoría/evaluación del Modo F, usado por todo el cluster); **GRC** lo
**referencia** y aporta su lente de cumplimiento en `grc`. Evita doble dueño.

- [x] Base idéntica en los 5; dominios sin copias ajenas; 0 enlaces rotos.
- [x] Reciprocidad de referencias entre Cluster Seguridad ↔ Cluster Data+IA.

---

## Addendum 2 (2026-06-29) — Cierre QA (D-01 a D-04)

Auditoría Amado (Modo A brownfield) identificó 4 observaciones no bloqueantes.
Todas **cerradas** en esta pasada:

| ID | Fix aplicado |
|---|---|
| **D-01** | Tabla **"Cuándo invocar directamente (routing)"** en `destroyer/SKILL.md` §0 pre + referencia en gobernanza cluster §2.2 |
| **D-02** | Fila **gestión continua de vulnerabilidades** en checklist anti-gap (ADR) y §2.2 costuras anti-gap (gobernanza cluster): centinela A/R operación, sello A/R SLA/riesgo, NÚCLEO R remediación |
| **D-03** | Versiones alineadas a **1.3** en los 5 agentes (`last_reviewed: 2026-06-29`) |
| **D-04** | Bloque **neutralidad de marco** explícito en `sello/SKILL.md` §3 Alcance |

**Veredicto QA post-fix:** gate **8/8** — apto para enlazar al equipo. Pendiente
estructural único: gobernanza **org-level** entre clusters (cuando el equipo esté
completo).

- [x] Routing directo documentado (D-01).
- [x] Costura VM continua con dueño explícito (D-02).
- [x] Versiones alineadas (D-03).
- [x] Neutralidad de marco reforzada en GRC (D-04).

---

## Addendum 3 (2026-07-08) — Renombrado de satélites (Esquema B)

Para reducir confusión de delegación por prefijo compartido `destroyer-*` y colores
genéricos (red/blue) que el modelo asocia con tareas ambiguas, los **cuatro satélites**
se renombran a **nombres propios** alineados con su área de operación. El núcleo
**destroyer** y su labor **no cambian**.

| Nombre anterior | Nombre nuevo | Área (sin cambio de labor) |
|---|---|---|
| `destroyer-red` | **`cazador`** | Ofensiva / Red Team / Pentest |
| `destroyer-blue` | **`centinela`** | Defensiva / SOC / DFIR |
| `destroyer-grc` | **`sello`** | GRC / ISO / Privacidad-DPO / Factor humano |
| `destroyer-ai` | **`vector`** | Seguridad de IA/LLM/agentes |

**Alcance del cambio:** solo identificadores (`name:` en SKILL, carpetas maestras
`~/.cazador` etc., junctions, referencias cruzadas en cluster/equipo enterprise y
columnas RACI). **No se modifica** el contenido técnico ni los dominios de cada agente.

**Rollback:** restaurar carpetas `~/.destroyer-red|blue|grc|ai`, revertir junctions y
referencias (backup implícito en historial git del ecosistema de skills, si aplica).

- [x] 4 carpetas maestras renombradas y junctions recreados (4 entornos).
- [x] Referencias actualizadas en destroyer, cluster-seguridad, tompo, docpower,
  cluster-data-ai.
- [x] RACI transversal alineada a CAZADOR / CENTINELA / SELLO / VECTOR.
