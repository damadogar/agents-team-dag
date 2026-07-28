# estrategia-vision.md — Participación del PO en visión, estrategia, Product Goal y roadmap

> **Referencia del Modo B (Estrategia y Alineación).** Cubre la **contribución** de
> tompo (Product Owner) a la **visión y la estrategia de producto**, la formulación
> del **Product Goal**, los **OKRs**, la **North Star** y el **roadmapping
> now-next-later** orientado a outcomes.
>
> **Frontera de rol (crítica):** tompo **NO** es dueño de la estrategia de mercado ni
> del portafolio —eso es del **PM de negocio / sponsor (rol externo)**—. El PO **contribuye, traduce
> y ejecuta** la estrategia en un Product Goal y un backlog priorizado. Mientras no
> exista PM, tompo cubre la contribución estratégica **a nivel de producto** (no de
> portafolio) y lo marca **`[COBERTURA ADJUNTA]`** (ver
> [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)).

---

## 1. La jerarquía estratégica: dónde encaja el PO

Roman Pichler propone un **Product Strategy Model** con una jerarquía clara que
conecta la dirección de largo plazo con el trabajo diario del equipo
(Pichler, *My Product Strategy Model*,
https://romanpichler.medium.com/my-product-strategy-model-cdb9e2673853):

```
   VISIÓN          ¿Por qué existe el producto? (propósito, cambio en el mundo)
      │            Horizonte: años. Estable, inspiradora.
      ▼
   ESTRATEGIA      ¿Cómo se hace realidad la visión? (mercado, necesidades,
      │            diferenciadores, business goals). Horizonte: trimestres-año.
      ▼
   ROADMAP         ¿Qué outcomes perseguimos y cuándo, aproximadamente?
      │            (now-next-later orientado a resultados). Horizonte: meses.
      ▼
   PRODUCT BACKLOG ¿Qué construimos a continuación? (épicas, historias, criterios)
                   Horizonte: sprint/flujo. Detallado y priorizado.
```

**Lectura para tompo:**
- **Visión y estrategia de mercado:** el PO **contribuye** (aporta voz de usuario,
  evidencia de discovery, factibilidad con el equipo), pero el **A** es el PM cuando
  existe. Ver RACI #1 en [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md).
- **Roadmap (de outcomes) y Product Backlog:** el PO es **A/R**. Aquí manda tompo.
- **Product Goal:** el puente. Es el objetivo **del producto** que el PO desarrolla,
  posee y comunica para que el backlog tenga un "porqué" (Scrum Guide 2020).

> Regla: el PO **no inventa** la visión en el vacío; la **recibe o co-construye** y
> garantiza que cada ítem del backlog sea trazable hacia ella:
> **visión → estrategia → outcome de roadmap → Product Goal → historia → métrica.**

---

## 2. Product Vision y Product Vision Board (Roman Pichler)

La **visión** describe el cambio o propósito último del producto: el "para qué"
inspirador y estable que orienta todas las decisiones. Pichler propone el
**Product Vision Board** para capturarla con su contexto de validación, en **5
secciones** (Pichler, *The Product Vision Board*,
https://www.romanpichler.com/blog/the-product-vision-board/):

| Sección | Pregunta que responde | Ejemplo (app de finanzas personales) |
|---|---|---|
| **Vision** | ¿Qué cambio en el mundo busca el producto? | "Que cualquier persona controle su dinero sin estrés ni conocimientos financieros." |
| **Target Group** | ¿Quiénes son los clientes y usuarios? | Jóvenes 20-35 sin hábito de ahorro, con ingresos variables. |
| **Needs** | ¿Qué problema/necesidad resolvemos? (el "porqué") | Saber a dónde se va el dinero y ahorrar sin esfuerzo. |
| **Product** | ¿Qué es el producto, qué lo hace especial, es viable? | App que automatiza ahorro y categoriza gastos con reglas simples. |
| **Business Goals** | ¿Cómo nos beneficia? (modelo, métricas de negocio) | Suscripción premium; meta: 100k usuarios activos, 8% conversión. |

**Las 3 secciones inferiores** (Target Group, Needs, Business Goals) son hipótesis
**a validar con discovery** ([descubrimiento.md](descubrimiento.md)). El PO usa el
board para **alinear al equipo y a stakeholders** y para detectar dónde falta
evidencia.

> Frontera: las secciones **Target Group / Needs / Business Goals** rozan la
> estrategia de mercado (PM) y el modelo de negocio. El PO **aporta evidencia de
> usuario y co-llena el board**; las decisiones de mercado/portafolio se validan con
> el PM. La viabilidad técnica del "Product" se consulta con eneida/motor/farola.

---

## 3. Product Goal (Scrum Guide 2020)

El **Product Goal** es el **compromiso (commitment) asociado al Product Backlog**
introducido en la actualización 2020 de la Scrum Guide. Describe un **estado futuro
del producto** que sirve de **objetivo a largo plazo del Scrum Team** y da
**contexto** ("el porqué") a todo el backlog (Schwaber & Sutherland, vía Scrum.org,
*Scrum Guide 2020 Update: Introducing the Product Goal*,
https://www.scrum.org/resources/blog/scrum-guide-2020-update-introducing-product-goal):

- **El Product Backlog emerge para definir "qué cumplirá mejor el Product Goal".**
- **Un objetivo a la vez:** el equipo debe **cumplir (o abandonar) un Product Goal
  antes de tomar el siguiente**. Da foco.
- **El PO es accountable** de **desarrollarlo y comunicarlo** explícitamente (es una
  de sus responsabilidades en la gestión del backlog).
- Vive **en el Product Backlog**; el resto del backlog **emerge** para alcanzarlo.

### 3.1 Relación con la jerarquía
```
Visión (PM/co-construida) ─► Estrategia ─► [PRODUCT GOAL = ancla del backlog] ─► Sprint Goals
```
El **Product Goal** es más concreto que la visión y más amplio que un Sprint Goal.
Cada **Sprint Goal** es un **paso** hacia el Product Goal.

### 3.2 Cómo formular un buen Product Goal

Un Product Goal de calidad es **medible, orientado a outcome, con horizonte y único**.
Plantilla recomendada:

```
PRODUCT GOAL
- Estado futuro buscado (outcome, no feature):
  "Convertirnos en la forma más rápida de [X] para [segmento], de modo que [resultado]."
- Métrica(s) de éxito que evidencian el logro:
  (ej. activación 7 días pasa de 22% a 40%)
- Horizonte aproximado: (ej. próximos 2-4 meses / varios sprints)
- Para quién y por qué importa (job-to-be-done):
- Qué NO incluye (anti-alcance):
- Cómo contribuye a la visión/estrategia:
```

**Ejemplo (bueno):** *"En el próximo trimestre, lograr que los nuevos usuarios
ahorren por primera vez en menos de 7 días, subiendo la activación del 22% al 40%."*
→ outcome claro, medible, con horizonte, conecta con la visión.

**Ejemplo (malo):** *"Lanzar el módulo de reportes y el rediseño del dashboard."*
→ es una lista de outputs, sin outcome ni métrica; describe el *qué construir*, no el
*qué lograr*.

| Prueba de calidad | Pregunta de control |
|---|---|
| ¿Es outcome, no output? | ¿Describe un resultado o solo features a entregar? |
| ¿Es medible? | ¿Sabremos sin discusión si se cumplió? |
| ¿Es único y enfocado? | ¿Es **un** objetivo o varios disfrazados? |
| ¿Tiene horizonte? | ¿En cuánto tiempo, aproximadamente? |
| ¿Es trazable a la estrategia? | ¿Por qué este goal y no otro? |
| ¿Inspira y alinea? | ¿El equipo y stakeholders lo entienden igual? |

> Handoff: la **medición** del Product Goal se define con el significado de negocio
> que posee tompo y la **implementación técnica de la métrica** que posee
> brujula ("una métrica, una definición", ver
> [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md) y
> [metricas-datos.md](metricas-datos.md)).

---

## 4. North Star Framework / North Star Metric

La **North Star Metric (NSM)** es la **única métrica** que mejor captura el **valor
central** que el producto entrega al cliente; el **North Star Framework** la rodea de
**input metrics** (palancas que el equipo puede mover) para conectar trabajo diario y
resultado de negocio (Amplitude, *The North Star Playbook / Product North Star
Metric*, https://amplitude.com/blog/product-north-star-metric).

```
                NORTH STAR METRIC  (leading indicator del valor entregado)
                        ▲
      ┌────────────┬────┴────┬────────────┐
   Input 1      Input 2   Input 3      Input 4   (3-5 palancas accionables)
 (breadth)    (depth)   (frequency)  (efficiency)
      ▲           ▲          ▲             ▲
  trabajo del equipo (features, experimentos, mejoras)
```

**Propiedades de una buena NSM:**
- Refleja **valor para el cliente** (no ingresos directos: es *leading*, no *lagging*).
- Es **accionable** vía sus inputs y **medible**.
- Ejemplos clásicos: "mensajes enviados", "noches reservadas", "minutos de contenido
  consumido por usuario activo".

**Anti-patrón:** confundir NSM con una **vanity metric** (ej. registros totales) o con
una métrica puramente de negocio (ingresos). La NSM debe **predecir** el éxito de
negocio capturando el valor entregado.

> Frontera: la **elección de la NSM de la compañía** suele ser decisión de PM/negocio;
> tompo **propone y opera** la NSM y sus inputs **a nivel de producto**, y traza su
> backlog hacia esos inputs.

---

## 5. OKRs (Objectives and Key Results)

Marco de definición de metas popularizado por **John Doerr** (de Andy Grove/Intel a
Google) en *Measure What Matters*: un **Objetivo** cualitativo e inspirador + **3-5
Key Results** cuantitativos y verificables que miden el avance hacia él
(Doerr / What Matters, *OKR: Meaning, Definition, Example*,
https://www.whatmatters.com/faqs/okr-meaning-definition-example):

```
OBJETIVO (qué quiero lograr — cualitativo, ambicioso, con foco)
  └─ KR1 (resultado medible 1)   ┐
  └─ KR2 (resultado medible 2)   ├─ 3-5 KR, cada uno con métrica y meta
  └─ KR3 (resultado medible 3)   ┘
```

**Plantilla:**
```
Objetivo: <verbo + estado futuro inspirador>
KR1: <métrica> de <baseline> a <meta>   (medible)
KR2: <métrica> de <baseline> a <meta>
KR3: <métrica> de <baseline> a <meta>
```

**Ejemplo (producto):**
- **Objetivo:** Hacer del primer ahorro una experiencia inmediata y motivadora.
- **KR1:** Activación a 7 días del 22% → 40%.
- **KR2:** Tiempo hasta el primer ahorro de 5 días → < 1 día (mediana).
- **KR3:** NPS de onboarding de 18 → 35.

**Buenas prácticas:** KRs de **resultado** (no de actividad); ambición (aspiracionales
~0.7 de logro esperado); pocos y enfocados; transparentes; **desacoplar de la
compensación** para evitar sandbagging.

### 5.1 Relación Product Goal ↔ OKR ↔ NSM
- El **Product Goal** suele expresarse **como un OKR de producto** (objetivo + KRs).
- Los **KRs** suelen ser **movimientos en los inputs de la North Star**.
- No multipliques marcos: elige **uno** como ancla de outcome y mantén la
  trazabilidad. *Outcome over output* en todos ellos.

---

## 6. Roadmapping now-next-later orientado a outcomes

### 6.1 Por qué NO un roadmap de features con fechas

Janna Bastow (ProdPad) **inventó el now-next-later roadmap** como reacción al
**timeline/feature-roadmap** tradicional, que promete *features* en *fechas* fijas y
genera tres patologías: se convierte en una **lista de compromisos** que mata la
agilidad, **confunde output con outcome**, y obliga a "mentir" sobre certezas que no
existen (Bastow, ProdPad, *I Invented the Now-Next-Later Roadmap*,
https://www.prodpad.com/blog/invented-now-next-later-roadmap/; y
*Outcome-Based Roadmaps*, https://www.prodpad.com/blog/outcome-based-roadmaps/).

El roadmap debe organizarse por **horizonte de confianza, no por fechas**, y expresar
**outcomes/problemas a resolver**, no una lista cerrada de soluciones.

### 6.2 Estructura now-next-later

| Columna | Horizonte / confianza | Qué contiene | Detalle |
|---|---|---|---|
| **NOW** | Alta confianza, en curso | Outcomes que perseguimos **ya**; problemas en discovery/delivery | Alto: oportunidades e ideas de solución concretas |
| **NEXT** | Confianza media | Outcomes que siguen; aún en exploración | Medio: problema claro, solución por validar |
| **LATER** | Baja confianza | Apuestas y problemas grandes, sin compromiso | Bajo: dirección, no detalle |

**Plantilla de roadmap now-next-later (outcome-based):**
```
PRODUCT GOAL: <ancla del periodo>
NSM / OKR de referencia: <métrica que movemos>

NOW  (estamos en ello)
- Outcome: <resultado buscado>  | Problema: <...> | Métrica: <...> | Confianza: alta
- Outcome: ...

NEXT (a continuación)
- Outcome: <resultado buscado>  | Problema/hipótesis: <...> | Métrica: <...> | Confianza: media

LATER (apuestas futuras)
- Tema/outcome grande: <...>    | Por qué importa: <...> | Confianza: baja
```

> Cada ítem se expresa como **outcome/problema** ("reducir el abandono en el
> onboarding"), **no** como feature con fecha ("lanzar wizard v2 el 15 de marzo"). Las
> soluciones concretas viven en el **backlog**, no en el roadmap.

### 6.3 Alternativa de Pichler: el GO Product Roadmap

Para contextos que necesitan algo más estructurado, Roman Pichler propone el **GO
Product Roadmap** (Goal-Oriented), donde cada release se describe por **fecha
(aproximada), nombre, GOAL (outcome), features (pocas, de alto nivel) y métricas**. El
foco sigue siendo el **goal/outcome de cada periodo**, no una lista exhaustiva de
features. Útil cuando los stakeholders exigen algún marco temporal: el PO mantiene el
goal como ancla y las features como *indicativas*, no como promesa contractual.

### 6.4 Higiene del roadmap
- **Es un documento vivo:** se revisa con cada aprendizaje de discovery/métricas.
- **No es el backlog:** el roadmap son outcomes; el backlog son historias.
- **Gestiona expectativas:** comunica explícitamente que NOW/NEXT/LATER reflejan
  **confianza**, no fechas garantizadas (clave con stakeholders, ver
  [stakeholders-liderazgo.md](stakeholders-liderazgo.md)).

---

## 7. Cómo el PO conecta Visión → Product Goal → Backlog (flujo operativo)

```
1. VISIÓN / ESTRATEGIA   ── (co-construida con PM; PO aporta voz de usuario y evidencia)
        │
2. NORTH STAR + INPUTS   ── elegir la métrica de valor y sus palancas
        │
3. PRODUCT GOAL (OKR)    ── PO formula el outcome ancla del periodo (mide el avance)
        │
4. ROADMAP now-next-later── PO organiza outcomes por confianza (no fechas)
        │
5. DISCOVERY (OST/JTBD)  ── PO + product trio descubren oportunidades y validan riesgos
        │                    ([descubrimiento.md](descubrimiento.md))
6. PRODUCT BACKLOG       ── PO crea/ordena historias INVEST con criterios de aceptación
        │                    ([backlog-requisitos.md](backlog-requisitos.md))
7. MÉTRICAS              ── PO mide el outcome; aprende; re-prioriza (loop a 3-4)
                            ([metricas-datos.md](metricas-datos.md))
```

**Regla de trazabilidad (no negociable):** ningún ítem entra al backlog si no se puede
responder *"¿a qué outcome de roadmap y a qué Product Goal contribuye?"*. Si no
contribuye a ninguno, es candidato a posponer o rechazar.

---

## 8. Frontera con el PM (qué contribuye tompo vs qué posee el PM)

| Tema | PM de negocio / sponsor (rol externo) (A) | Tompo / PO (contribuye o es A en su capa) |
|---|---|---|
| **Visión de mercado y posicionamiento** | **Posee** | Aporta voz de usuario y evidencia de discovery |
| **Estrategia de portafolio (multi-producto)** | **Posee** | No la asume; alinea su producto a ella |
| **Estrategia de un producto** | **A/C** (posee la dirección; alinea con visión) | **Co-construye (R/C)**; es **A de su formulación solo en `[COBERTURA ADJUNTA]`** — con PM presente, tompo es A **solo del Product Goal y el backlog** |
| **Product Goal** | A/C de su alineación | **A/R**: lo desarrolla, posee y comunica |
| **North Star de compañía** | Suele poseerla | Propone/opera NSM e inputs a nivel de producto |
| **Roadmap de outcomes del producto** | **Consultado** (alinea con portafolio/visión) | **A/R a nivel de producto**: lo construye y mantiene |
| **Product Backlog** | Informado | **A/R**: contenido y orden |

> Si **no hay PM**, tompo cubre la contribución estratégica **a nivel de producto**
> (no de portafolio ni de mercado completo) y lo declara **`[COBERTURA ADJUNTA]`**.
> Cuando un tema toca mercado, pricing o portafolio, hay **handoff al PM**; cuando toca
> factibilidad técnica de la visión, **handoff a eneida/motor/farola**; cuando toca el
> significado vs implementación de una métrica, **handoff a brujula**. Ver
> [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md).

---

## 9. Cierre del documento

- **Outcome buscado:** que el PO conecte estrategia y ejecución mediante un **Product
  Goal medible** y un **roadmap de outcomes**, sin invadir la estrategia de mercado.
- **Cómo se medirá:** todo ítem del backlog es trazable a un outcome de roadmap y al
  Product Goal; el avance del Product Goal se mide con NSM/OKR.
- **Próximo paso:** correr **discovery** sobre los outcomes del NOW
  ([descubrimiento.md](descubrimiento.md)) y bajar a backlog priorizado
  ([backlog-requisitos.md](backlog-requisitos.md), [priorizacion-valor.md](priorizacion-valor.md)).
