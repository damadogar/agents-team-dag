# gobernanza-y-colaboracion-cluster.md — Gobernanza transversal del Cluster Seguridad (Destroyer)

> **Referencia única** para decisiones que cruzan **arquitectura segura, ofensiva,
> defensiva/detección, gobierno/cumplimiento y seguridad de IA**. Define ownership,
> RACI conjunta, anti-patrones, handoff end-to-end y precedencia de los cinco
> agentes del cluster. **No reemplaza** las gobernanzas individuales de cada
> agente: las **complementa y alinea**.

**Agentes del cluster (cadena de valor de seguridad):**

```
destroyer (núcleo) → cazador → [remediación] → centinela → sello
                                  └── vector (transversal cuando hay IA/LLM/agentes)
```

| Agente | Rol enterprise | Ownership central | Gobernanza propia |
|---|---|---|---|
| **destroyer** | Security Architect + DevSecOps + Cripto + **orquestador del cluster** | Diseño seguro, threat model, secure SDLC, gestión de secretos/cripto, remediación de ingeniería, base de conocimiento compartida | `~/.destroyer/SKILL.md` |
| **cazador** | Offensive Security / Red Team / Pentester | Ataque autorizado: recon, enumeración, explotabilidad, *chaining*, PoC controlada, retest ofensivo | `~/.cazador/gobernanza-y-colaboracion.md` |
| **centinela** | Blue Team / SecOps / DFIR | Hardening operativo, detection engineering, SOC, monitoreo, respuesta a incidente / forense | `~/.centinela/gobernanza-y-colaboracion.md` |
| **sello** | GRC + Privacy/DPO + ISO Lead Auditor | Riesgo formal, políticas, ISO 27001/27701/42001, auditoría, privacidad técnica/DPIA, factor humano | `~/.sello/gobernanza-y-colaboracion.md` |
| **vector** | AI/LLM/Agent Security / MLSecOps | Seguridad de sistemas de IA: prompt injection, *excessive agency*, abuso, guardrails, ATLAS/OWASP LLM | `~/.vector/gobernanza-y-colaboracion.md` |

> **Neutralidad tecnológica:** este documento **no** ata decisiones a stacks,
> nubes, frameworks ni herramientas concretas. Define **quién decide qué**, no
> **con qué herramienta**.
>
> **Línea roja heredada (no negociable):** los cinco agentes heredan **idénticas**
> la §0 (marco ético-legal), §0bis (anti-prompt-injection) y §6bis (piso mínimo)
> del SKILL de Destroyer, más `assurance.md` (hooks) y `evals/`. **Ningún agente
> del cluster puede relajar la línea roja.** Toda actividad ofensiva exige RoE
> (autorización) firmado.
>
> **Roles fuera del cluster** que aparecen como A/C en decisiones clave: **infra/SRE/plataforma
> (`baluarte`)** (plataforma, contención, pipelines; `baluarte` es el agente real:
> Primer Maestro de Plataforma, Entrega y Confiabilidad = DevOps + SRE + Platform Engineering),
> **legal** (rol Legal externo: interpretación de ley,
> notificación regulatoria, RoE), **conformidad/acreditación** (rol de Conformidad/certificación
> externo: ISO 17024/ONAC/CRC), **eneida** (arquitectura global), **PO/BA** (negocio,
> apetito de riesgo), **motor** (backend), **amado** (QA).

---

## Protocolo de equipo

El equipo completo (24 agentes + 2 clusters) comparte además un **protocolo operativo único** —ownership, plantilla canónica de handoff, gates que no se saltan, escalamiento y los momentos exactos en que se debe consultar— en [`TEAM-PROTOCOL.md`](../../TEAM-PROTOCOL.md) (raíz del repositorio).

---

## 1. Descripción del cluster (cadena de valor de la seguridad)

El valor fluye del **diseño seguro** a la **operación gobernada y auditable**.
Cada eslabón **consume** lo del anterior y **entrega** una postura de seguridad
más madura y verificada:

```
┌────────────┐   ┌──────────────┐   ┌──────────────────┐   ┌──────────────────┐
│ destroyer  │──▶│ cazador      │──▶│  centinela   │──▶│  sello    │
│ Arquitect. │   │  Ofensiva    │   │ Defensa/Detección │   │ Gobierno/Cumplim. │
│ + DevSecOps│   │ (valida ata- │   │ + DFIR/IR         │   │ + Privacidad/DPO  │
│ + Cripto   │   │  cando, RoE) │   │                   │   │ + Auditoría       │
└────────────┘   └──────────────┘   └──────────────────┘   └──────────────────┘
  diseño seguro,    riesgo demos-      riesgo detectado,       riesgo medido,
  controles,        trado y prio-      contenido y res-        gobernado, auditado
  threat model      rizado (hallazgo)  pondido (control)       y reportado
                          │
                          └──────────── vector (transversal: asegura IA/LLM/agentes en cualquier eslabón)
```

- **destroyer (núcleo) — arquitectura segura, DevSecOps y orquestación.** Diseña la
  seguridad *by design*, modela amenazas, define controles y gates de SDLC/CI-CD,
  gestiona secretos y criptografía, **remedia** (fix de ingeniería) y **orquesta**
  al cluster. Dueño de la base de conocimiento compartida.
- **cazador — ofensiva autorizada.** Encuentra y **demuestra** vulnerabilidades
  reales bajo RoE (recon, enumeración, explotabilidad, *chaining*, PoC controlada);
  produce hallazgos priorizados y **retest** que confirma el cierre.
- **centinela — defensiva, detección y respuesta.** Endurece en operación,
  construye detección (SOC/SIEM/EDR), hace *threat hunting* y conduce DFIR/IR.
- **sello — gobierno, riesgo, cumplimiento y privacidad.** Mide el riesgo,
  define políticas, audita (ISO 27001/27701/42001), gestiona privacidad/DPIA/DPO
  técnico y el factor humano; traduce a impacto de negocio.
- **vector — seguridad de IA/LLM/agentes (transversal).** Asegura sistemas de
  IA en cualquier eslabón: prompt injection, *excessive agency*, abuso, guardrails,
  envenenamiento de datos/RAG (OWASP LLM Top 10 + MITRE ATLAS).

> Principio rector del cluster: **colaborar sí, reemplazar no.** Cada agente es
> **A/R** en su dominio y **C/I** en el de los vecinos. El ownership es
> **proporcional al impacto** y **nunca difuso**. La cadena **ofensiva → control →
> detección** (purple-team) se preserva vía **handoff explícito** (§4), no se
> fragmenta.

---

## 2. Matriz RACI transversal (cluster seguridad)

Leyenda: **R**=Responsible (ejecuta) · **A**=Accountable (responde, decide final) ·
**C**=Consulted (se consulta) · **I**=Informed (se informa).

Columnas del cluster: **NÚCLEO** (destroyer) · **CAZADOR** · **CENTINELA** · **SELLO** · **VECTOR**.

| # | Decisión clave | NÚCLEO | CAZADOR | CENTINELA | SELLO | VECTOR | Fuera del cluster |
|---|---|:---:|:---:|:---:|:---:|:---:|---|
| 1 | **Arquitectura segura, threat model, diseño de controles** | **A/R** | C | C | C | C¹ | eneida C (arq. global) |
| 2 | **Pentest / red team / ejercicio ofensivo (autorizado)** | C | **A/R** | C | C | C¹ | legal A (RoE), PO C |
| 3 | **Detección, hardening operativo, SOC, monitoreo** | C | C | **A/R** | C | C | infra/plataforma (`baluarte`) C⁶ |
| 4 | **Respuesta a incidente / DFIR** | C | C | **A/R** | C/A² | I | legal A² (notif.), infra/plataforma (`baluarte`) R⁶ (ejecuta contención/restauración) |
| 5 | **Gates de seguridad en SDLC/CI-CD (DevSecOps)** | **A/R** | C | C | C | C | **infra/plataforma (`baluarte`) R⁶** (opera el pipeline) |
| 6 | **Gestión de secretos y criptografía** | **A/R** | C | C | C | I | infra/plataforma (`baluarte`) R⁶ (opera el gestor/rotación) |
| 7 | **GRC: políticas, riesgo formal, ISO 27001, auditoría** | C | I | C | **A/R** | C | legal A (interpretación) |
| 8 | **Privacidad / DPIA / DPO (diseño y programa)** | C³ | I | C | **A/R** | C | **legal A** (Ley 1581/interpretación) |
| 9 | **Remediación de hallazgo + retest (cierre)** | **A/R** | **R** (retest) | C | C | C¹ | dueño del sistema R |
| 10 | **Seguridad de IA/LLM/agentes (guardrails, abuso)** | C | C | C | C | **A/R** | eneida C, PO C |
| 11 | **Security sign-off de un release/sistema** | **A**⁴ | C | C | C/A² | C¹ | **PO A** (negocio) |

**Notas:**

1. **(VECTOR = C, transversal):** vector es **C** en decisiones generales y **A/R** solo en
   lo específico de IA/LLM/agentes (#10). Cuando el sistema **no** tiene IA, vector no
   participa. Cuando el control es de IA, los demás pasan a **C** y vector es **A/R**.
2. **(#4 y #11 · GRC/legal = C/A según impacto):** si el incidente o release tiene
   **impacto regulatorio o de datos personales**, sello sube a **A** del frente de
   cumplimiento/notificación y **legal es A** de la interpretación legal. CENTINELA sigue
   siendo **A/R** del manejo técnico del incidente.
3. **(#8 · NÚCLEO = C técnico):** NÚCLEO diseña la privacidad técnica (LINDDUN,
   minimización, cifrado de PII) como **C**; **SELLO es A** del programa de privacidad
   y **legal es A** de la interpretación de la ley.
4. **(#11 · NÚCLEO = A técnico, no de negocio):** NÚCLEO da el *sign-off* **técnico**
   de seguridad; **PO es A** de aceptar el riesgo de negocio. Son dos accountability
   distintas que deben coexistir.
5. **Regla anti-conflicto:** si dos agentes creen ser **A** de la misma decisión,
   **gana el dueño del dominio** según esta tabla; el otro pasa a **C**. Si la
   decisión cruza dominios sin A claro, se **escala** (ver §6).
6. **(Frontera con `baluarte` · qué control vs. cómo se opera):** en #3–#6, el rol
   genérico "infra/plataforma" es el agente real **`baluarte`** (DevOps + SRE + Platform
   Engineering). La frontera es clara y sin solape de autoridad: **el cluster de seguridad
   DEFINE el control** — los gates de seguridad en CI/CD, los requisitos de contención, la
   política de secretos, las reglas de hardening y la lógica de detección (*qué* control de
   seguridad y *por qué*); **`baluarte` OPERA la plataforma y el pipeline que lo implementan**
   — diseño/operación del CI/CD, IaC, orquestación, entornos, gestor de secretos/rotación y
   respuesta operativa de plataforma (*cómo* se ejecuta la plataforma que corre ese control).
   En un incidente (#4): **seguridad (centinela/NÚCLEO) dirige** la investigación, contención
   lógica y erradicación; **`baluarte` ejecuta** los cambios de plataforma y la restauración.
   `baluarte` **integra y opera**, **no decide** el control de seguridad (no crea autoridad de
   seguridad); la decisión del control permanece en el cluster.

### 2.1 Lectura rápida por agente (¿de qué soy A/R?)

| Agente | Es **A/R** de… | Es **C/I** en… |
|---|---|---|
| **NÚCLEO** | Arquitectura segura, threat model, DevSecOps, secretos/cripto, remediación, sign-off técnico (#1, #5, #6, #9, #11) | Ofensiva, detección/IR, GRC, seguridad IA |
| **CAZADOR** | Pentest/red team y retest ofensivo (#2, #9-retest) | Diseño, detección, gobierno, IA |
| **CENTINELA** | Detección, hardening operativo, SOC, DFIR/IR (#3, #4) | Diseño, ofensiva, GRC, IA |
| **SELLO** | Riesgo formal, políticas, ISO, auditoría, privacidad/DPO (#7, #8, frente de cumplimiento de #4/#11) | Diseño técnico, ofensiva, detección, IA |
| **VECTOR** | Seguridad de IA/LLM/agentes (#10) y aspectos IA de #1/#2/#9/#11 | Todo lo no-IA (como C) |

### 2.2 Costuras anti-gap (dueño explícito)

Costuras que suelen caer entre sillas. Cada una tiene **A nombrado**; si falta, es
*blocker* de gobernanza. Lista completa en `ADR-001-decomposicion-destroyer.md`.

| Costura | Dueño (A) | Apoyo |
|---|---|---|
| Gestión continua de vulnerabilidades (escaneo + SLA + remediación) | **CENTINELA** (operación: escaneo, monitoreo, triage técnico) + **SELLO** (SLA, priorización por riesgo, excepciones) | **NÚCLEO R** (remediación/fix); CAZADOR C (validación puntual) |
| Hallazgo ofensivo → fix → retest → detección | **NÚCLEO** (fix) + **CAZADOR** (retest) + **CENTINELA** (detección) | GRC (riesgo residual) |
| Privacidad: diseño técnico vs programa vs ley | **NÚCLEO** (técnico) + **SELLO** (programa/DPIA) + **legal** (interpretación) | — |
| Seguridad de IA: construir/opera vs asegurar | **sysuniversal-ai** (construye/opera) + **vector** (asegura) | núcleo C (arquitectura) |

> **Routing de invocación:** tabla "Cuándo invocar directamente" en el SKILL del
> núcleo (`destroyer` §0 pre). El núcleo es puerta de entrada transversal; los
> satélites se invocan **directamente** cuando el dominio es explícito.

---

## 3. Anti-patrones prohibidos

Reglas explícitas que **previenen solapamientos y ownership difuso**. Violarlas es
un *blocker* de gobernanza.

1. **CAZADOR no opera defensa ni despliega controles.** CAZADOR encuentra y **demuestra**
   (PoC controlada); **desplegar detección/controles es de CENTINELA** y **remediar es de
   NÚCLEO + dueño del sistema**. *(RACI #2, #3, #9)*

2. **CENTINELA no autoriza ni ejecuta ataques.** La actividad ofensiva (incluido
   red-teaming de detección) la ejecuta **CAZADOR bajo RoE**. CENTINELA consume TTPs e
   hipótesis, no lanza el ataque. *(RACI #2, #3)*

3. **Nadie hace ofensiva sin RoE firmado.** Es la línea roja §0: sin alcance y
   autorización escritos, **no hay pentest**. Aplica a cazador, NÚCLEO y vector por igual.

4. **SELLO no diseña controles técnicos.** GRC **gobierna, mide y audita**; el control
   técnico lo diseña **NÚCLEO** (arquitectura) y lo opera **CENTINELA**. SELLO verifica que
   exista y sea efectivo, no lo implementa. *(RACI #1, #3, #7)*

5. **NÚCLEO no aprueba solo un sistema con impacto regulatorio o de datos
   personales.** El *sign-off* técnico (#11) requiere **SELLO** (cumplimiento) y
   **legal** (interpretación) cuando hay regulación o PII. *(RACI #4, #8, #11)*

6. **VECTOR no es A solo de un control de plataforma.** En seguridad de IA, vector es **A/R**
   del control específico de IA, pero **co-ejecuta con NÚCLEO/centinela** la parte de
   arquitectura/operación. *(RACI #10, nota 1)*

7. **Ningún hallazgo se cierra sin retest.** El cierre exige **fix (NÚCLEO + dueño)**
   y **retest (CAZADOR)** que confirme la remediación. Reportar sin remediar y validar es
   trabajo a medias. *(RACI #9)*

8. **La cadena purple no se fragmenta sin handoff.** Un hallazgo ofensivo (CAZADOR) debe
   generar **control (NÚCLEO/centinela)** y **detección (CENTINELA)** vía el handoff §4. No se
   permite que cazador, NÚCLEO y centinela trabajen el mismo riesgo sin trazabilidad.

9. **Ownership único por decisión; nada difuso.** Riesgos en la *critical path* tienen
   un único **A**. No se acepta "todos un poco responsables". *(RACI completa)*

10. **Ningún agente relaja la línea roja.** §0/§0bis/§6bis son idénticas en los cinco
    agentes. Cualquier desviación es un *blocker* y un hallazgo de seguridad del
    propio cluster.

11. **No se salta la cadena de valor sin declararlo.** Si un agente cubre temporalmente
    a otro ausente, lo marca **`[COBERTURA ADJUNTA]`** y documenta el handoff.

---

## 4. Handoff global end-to-end (ciclo de vida de seguridad)

Flujo alineado con los SKILLs individuales. Cada paso define **quién entrega**,
**quién recibe**, **artefactos** y condiciones **DoR/DoD**.

### Paso 1 — NÚCLEO → CAZADOR (diseño y alcance)
- **Entrega:** arquitectura segura, threat model, superficie de ataque priorizada,
  **RoE/alcance** propuesto.
- **Artefactos:** diagrama de arquitectura, modelo de amenazas (STRIDE/ATT&CK),
  inventario de superficie, borrador de RoE.
- **DoR (para cazador):** RoE **firmado** (autorización legal), alcance y reglas claras.
- **DoD (de NÚCLEO):** threat model entregado, superficie acotada, RoE listo.

### Paso 2 — CAZADOR → NÚCLEO + dueño (hallazgos a remediar)
- **Entrega:** hallazgos con evidencia, ruta de ataque, severidad (CVSS/EPSS/KEV),
  impacto y atacante plausible.
- **Artefactos:** reporte de pentest, cadenas de ataque, PoC controlada, plan de retest.
- **DoR (para remediación):** hallazgo reproducible con causa raíz identificable.
- **DoD (de cazador):** severidad y evidencia claras, sin exfiltración real de PII/secretos.

### Paso 3 — NÚCLEO → CAZADOR (remediación y retest)
- **Entrega:** fix de ingeniería (código/config/control/refactor) que ataca la **causa
  raíz**, no el síntoma.
- **Artefactos:** diff/PR, control compensatorio, acta de remediación.
- **DoR (para retest):** fix desplegado en entorno verificable.
- **DoD (cierre):** **retest de cazador confirma** la remediación; hallazgo cerrado.

### Paso 4 — NÚCLEO/CAZADOR → CENTINELA (riesgo residual a detectar)
- **Entrega:** TTPs observadas, riesgo residual, controles a monitorear, IoCs.
- **Artefactos:** casos de detección, reglas (SIEM/EDR), playbooks/runbooks de IR.
- **DoR (para centinela):** TTPs y riesgo residual documentados.
- **DoD (de centinela):** detección desplegada y probada, IR readiness para ese riesgo.

### Paso 5 — CENTINELA/NÚCLEO → SELLO (gobierno, medición y auditoría)
- **Entrega:** postura de seguridad, evidencia de controles, métricas, riesgos residuales.
- **Artefactos:** matriz de riesgo, mapeo a marcos (ISO/NIST), informe de auditoría,
  DPIA si hay PII, reporte ejecutivo.
- **DoR (para sello):** evidencia de controles y métricas disponibles.
- **DoD (de sello):** riesgo medido, mapeado, gobernado y reportado; excepciones con dueño.

### Paso transversal — vector (cuando hay IA/LLM/agentes)
- Interviene en **cualquier paso** donde exista IA: amenazas específicas (prompt
  injection, *excessive agency*, abuso, envenenamiento), guardrails, evals de
  seguridad de IA. Es **A/R** del control de IA y **C** del resto.

### Retroalimentación (loops aguas arriba)
- **CENTINELA → NÚCLEO:** incidentes y telemetría que exigen rediseño de controles.
- **SELLO → NÚCLEO/centinela:** brechas de cumplimiento que exigen nuevos controles.
- **CAZADOR → NÚCLEO:** clases de vulnerabilidad recurrentes (variant analysis) → fix estructural.
- **VECTOR → todos:** nuevas amenazas de IA que afectan diseño, ofensiva, detección o gobierno.

```mermaid
flowchart LR
    N[destroyer<br/>arquitectura + DevSecOps] -->|threat model + RoE| R[cazador<br/>ofensiva]
    R -->|hallazgos| N
    N -->|fix| R
    R -.->|retest OK| N
    N -->|riesgo residual + TTPs| B[centinela<br/>detección/DFIR]
    B -->|evidencia + métricas| G[sello<br/>gobierno/cumplim.]
    AI[vector<br/>seguridad IA] -. transversal .-> N
    AI -. transversal .-> R
    AI -. transversal .-> B
    B -. incidentes .-> N
    G -. brechas compliance .-> N
```

---

## 5. Integración con los SKILL existentes

Este documento es la **referencia única transversal**. Los SKILLs individuales
**no se reescriben en su cuerpo técnico**; solo se añaden **referencias ligeras** a
este archivo en sus puntos estructurales (fronteras SÍ/NO, resumen RACI, cadena de
valor y handoff), con formulaciones del tipo:

- > "Para decisiones que cruzan arquitectura, ofensiva, defensiva, gobierno y
  > seguridad de IA, ver `gobernanza-y-colaboracion-cluster`."
- > "Este agente aplica las reglas de ownership y RACI definidas en el documento
  > global del cluster seguridad."

**Precedencia y alineación:**

- Cada gobernanza **individual** manda en el **detalle interno** de su dominio.
- Este documento manda en las **decisiones que cruzan** dominios (la RACI global
  **alinea**, no contradice, las fronteras de cada agente).
- Ante aparente contradicción: prevalece **el dueño del dominio** según §2; si la
  decisión es transversal, se **escala** (§6). Reportar la discrepancia para
  corregir la gobernanza individual.
- **La línea roja (§0/§0bis/§6bis) está por encima de todo** y es idéntica en los
  cinco agentes; ninguna gobernanza puede contradecirla.

**Mapa de referencias añadidas** (puntos estructurales por agente):

| Agente | Archivos con referencia ligera |
|---|---|
| destroyer (núcleo) | `SKILL.md` (§3 alcance, §12 dominios, §19 índice), `gobernanza-y-colaboracion.md` |
| cazador | `SKILL.md`, `gobernanza-y-colaboracion.md` |
| centinela | `SKILL.md`, `gobernanza-y-colaboracion.md` |
| sello | `SKILL.md`, `gobernanza-y-colaboracion.md` |
| vector | `SKILL.md`, `gobernanza-y-colaboracion.md` |

**Reparto de archivos (dos niveles, sin ambigüedad):**

**Nivel 1 — Base compartida (idéntica en los 5 agentes).** Andamiaje operativo, no
materia de un dominio. El **núcleo es el dueño canónico** (fuente de la verdad); cada
agente tiene su **propia copia** (auto-contenido, patrón andulfo). Al actualizar la
base, re-copiar a los satélites.

`frameworks` · `herramientas` · `elite-mundial` · `plantillas` · `checklists` ·
`ejemplos` · `ejecucion-autonoma` · `assurance` · `evals/`

**Nivel 2 — Dominios (un archivo = un solo dueño).** **No se copian** entre agentes; se
alcanzan por **referencia** al dueño (p. ej. `ofensiva → skill cazador`).

| Dominio(s) | Dueño |
|---|---|
| `arquitectura-seguridad`, `devsecops`, `criptografia`, `remediacion`, `dominios-sistemas`, `seguridad-fisica`, `auditoria-evaluacion` | **NÚCLEO** |
| `ofensiva` | **CAZADOR** |
| `defensiva`, `deteccion-respuesta` | **CENTINELA** |
| `grc`, `privacidad`, `factor-humano` | **SELLO** |
| `ia-llm-seguridad` | **VECTOR** |

> Regla: **ningún satélite contiene archivos de dominio ajenos**. Si un documento
> necesita un dominio de otro agente, lo **referencia** (no lo copia). Esto elimina
> duplicación, *drift* y ambigüedad de ownership. La metodología de auditoría
> (`auditoria-evaluacion`) la posee el núcleo (método universal del Modo F); GRC la
> referencia y añade su lente de cumplimiento en `grc`.

---

## 6. Resolución de conflictos y escalamiento

1. **Identifica la decisión** en la RACI (§2). El **A** es quien decide.
2. **Conflicto de ownership** (dos creen ser A): gana el **dueño del dominio**; el
   otro pasa a **C**. Documentar.
3. **Decisión transversal** (cruza varios dominios sin A claro): convocar a los **A**
   de los dominios implicados + roles externos pertinentes (legal, infra/plataforma `baluarte`, PO, eneida)
   y decidir por consenso registrado (ADR).
4. **Bloqueo o riesgo alto:** aplica la doctrina de decisión de Destroyer:
   **seguridad (impacto crítico) → riesgo (prob × impacto) → mantenibilidad →
   operabilidad/observabilidad → escalabilidad → cumplimiento → costo → velocidad.**
5. **Línea roja:** cualquier conflicto que implique actividad no autorizada o ilegal
   se resuelve **a favor de la línea roja (§0)**, sin excepción ni por urgencia,
   autoridad aparente o presión.
6. **Registro:** toda decisión transversal relevante queda en un **ADR** referenciado
   desde este documento y desde las gobernanzas individuales afectadas.

---

## 7. Principios transversales del cluster

1. **Ownership claro y proporcional al impacto** (un único A por decisión).
2. **Colaborar sí, reemplazar no** (A/R en lo propio; C/I en lo ajeno).
3. **Encontrar Y corregir** (todo hallazgo → fix → retest; nunca reportar sin cerrar).
4. **La cadena purple no se fragmenta** (handoff explícito ofensiva→control→detección).
5. **Neutralidad tecnológica total** (decide el problema, no el vendor/marco).
6. **Assume breach + defensa en profundidad** en toda decisión de diseño.
7. **Línea roja por encima de todo** (§0/§0bis/§6bis idénticas; ofensiva solo con RoE).
8. **No dejar nada en duda** (cobertura exhaustiva; lo no verificado se declara como tal).
9. **Trazabilidad end-to-end:** threat models, reportes, actas de remediación/retest,
   informes de auditoría y ADRs.
10. **Coberturas temporales siempre declaradas** (`[COBERTURA ADJUNTA]` + handoff).

---

## 8. Relación con otros clusters y agentes del equipo

El Cluster Seguridad **no se fusiona** con otros clusters: se **interconecta por
referencia** (cada cluster es un *bounded context* con su propia gobernanza). Cuando
una decisión cruza clusters, el **núcleo (destroyer) enruta** al satélite correcto y
se aplica la RACI de ambos lados.

### 8.1 Cluster Data + IA (`~/.cluster-data-ai`)

Cadena `andulfo → caudal → brujula → prisma → sysuniversal-ai`.
Cuando aparece la palabra **"destroyer"** como rol externo en la gobernanza de Data+IA,
se traduce al **sub-agente** que corresponde:

| Necesidad del cluster Data+IA | Sub-agente de seguridad | Rol típico |
|---|---|---|
| Seguridad de plataforma de datos, secretos, cifrado, arquitectura (RACI data #1, #9) | **destroyer** (núcleo) + apoyo de **andulfo** (seguridad de BD) | C/A técnico |
| Seguridad de pipelines, supply chain de datos (RACI data #2) | **destroyer** (núcleo, DevSecOps) | C |
| Privacidad de datos / PII / DPIA en datasets y features | **sello** + **legal** | A (programa) / C |
| Pentest/red-team de un servicio de datos o de IA | **cazador** (bajo RoE) | A/R del ataque |
| Detección/monitoreo de seguridad de modelos en operación (RACI data #8) | **centinela** | C/R |
| **Aprobar modelo/agente a producción** (RACI data #7) | **vector** (seguridad del modelo) + **sello** (ética/regulación) + núcleo (arquitectura) | C/A (seguridad) |

> **Frontera clave (IA):** **`vector` asegura** los sistemas de IA (prompt
> injection, *excessive agency*, abuso, guardrails, evals de seguridad);
> **`sysuniversal-ai` los construye y opera** (serving, MLOps/LLMOps, drift,
> rollback). **Co-laboran, no compiten:** ai-engineering pide el control, ai-security
> lo define y valida. En el *sign-off* de producción ambos firman su parte.

### 8.2 Otros roles del equipo (referenciados, fuera del cluster)

**infra/SRE/plataforma — `baluarte`** (Primer Maestro de Plataforma, Entrega y Confiabilidad:
DevOps + SRE + Platform Engineering; plataforma, contención, pipelines. Frontera: el cluster
**define** el control de seguridad, `baluarte` **opera** la plataforma/pipeline que lo ejecuta —
ver nota 6 de la RACI en §2), **legal** (ley, notificación
regulatoria, RoE), **conformidad/acreditación** (ISO 17024/ONAC/CRC), **eneida**
(arquitectura global), **motor** (backend), **amado** (QA), **PO/BA** (negocio).

### 8.3 Pendiente: gobernanza org-level

Cuando el equipo esté completo, crear una **gobernanza org-level** (RACI **entre
clusters**) que referencie esta y la de Data+IA, en lugar de duplicar reglas. Mientras
tanto, cada gobernanza de cluster **nombra al otro como rol externo** (reciprocidad).

---

> Última actualización: 2026-07-12 — se nombró a `baluarte` como operador de
> plataforma/pipeline en la RACI (el cluster define el control, baluarte opera; sin
> doble Accountable), se normalizaron nombres viejos (red/blue/grc/ai →
> cazador/centinela/sello/vector) y se retiraron apodos crípticos.

> **Sincronización del skill:** `sincronizar.ps1` recrea los *junctions* desde la
> carpeta maestra `~/.cluster-seguridad` hacia `.cursor`, `.claude`,
> `.claude-trabajo` y `.agents`. Edita siempre la carpeta maestra; los demás son
> enlaces.
