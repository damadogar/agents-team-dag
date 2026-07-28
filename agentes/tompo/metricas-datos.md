# metricas-datos.md — Métricas, datos y experimentación (tompo, Product Owner)

> Referencia del **Modo E (Medición y Aprendizaje)** de tompo. Cómo el PO **define
> qué medir y por qué** (significado de negocio), formula hipótesis y métricas de
> éxito, y decide con evidencia en lugar de opinión o *vanity metrics*.
>
> **Frontera de rol (clave en métricas):** tompo es **A del SIGNIFICADO DE NEGOCIO**
> de cada métrica; **brujula** es **A de la IMPLEMENTACIÓN TÉCNICA** (capa
> semántica, definición SQL/evento, una métrica = una definición); la **plataforma y
> los datos** son de **andulfo (+caudal/prisma)**. El **A/B testing y los feature flags
> se construyen con ingeniería (motor/farola) y datos (andulfo)**; tompo aporta la
> **hipótesis, la métrica de éxito y los guardrails**, no el motor de experimentación.
> Detalle en [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md).

---

## 1. Principio: empezar por la pregunta de negocio, no por la métrica

Antes de instrumentar nada, el PO responde: **¿qué decisión vamos a tomar con este
dato?** Si una métrica no cambia una decisión, es ruido. La secuencia correcta es
**pregunta de negocio → outcome → métrica → señal → evento instrumentado**, nunca al
revés. Evita las *vanity metrics* (totales acumulados, page views, descargas sin
contexto): suben siempre, no se accionan y no distinguen causa de efecto.

Criterios de una buena métrica (Croll & Yoskovitz, *Lean Analytics*):
- **Comparable** (vs. periodo, cohorte o variante), no un número aislado.
- **Comprensible** por el equipo y el stakeholder.
- **Una razón (tasa o ratio)**, no un total acumulado.
- **Cambia comportamiento**: al verla, alguien actúa distinto.

> Regla del PO: por cada métrica que propongo, escribo la **pregunta** que responde y
> la **acción** que dispararía un cambio en ella. Sin eso, no entra al dashboard.

---

## 2. OKRs (Objectives & Key Results)

> **Delimitación con [estrategia-vision.md](estrategia-vision.md):** la **NSM** y los
> **OKR** se **formulan/fijan** en estrategia-vision.md (**Modo B**); aquí se
> **instrumentan, miden e interpretan** (**Modo E**). Este documento no los redefine:
> los convierte en evento, definición acordada y decisión con evidencia.

Marco de alineación de John Doerr (*Measure What Matters*): **un Objetivo**
cualitativo, inspirador y memorable, con **3-5 Key Results** cuantitativos y
medibles que prueban que se logró. *(Doerr, https://www.whatmatters.com/faqs/okr-meaning-definition-example)*

```
Objetivo (O):  cualitativo, ambicioso, con plazo (el QUÉ / hacia dónde)
   KR1:  métrica de resultado, con línea base → meta   (el cómo sabremos que llegamos)
   KR2:  métrica de resultado, con línea base → meta
   KR3:  métrica de resultado, con línea base → meta
```

Reglas que el PO aplica:
- **KR = outcome, no output.** "Lanzar onboarding nuevo" es una tarea, no un KR;
  "subir activación D1 del 28% al 40%" sí lo es.
- **Stretch vs. committed:** los OKR aspiracionales se cumplen ~70%; un 100% suele
  significar que la meta era floja (cultura Google).
- **No atar compensación al OKR**: incentiva sandbagging y métricas amañadas.
- **Cadencia:** trimestral típico, con check-in (confidence level) semanal/quincenal.
- **Trazabilidad:** cada KR enlaza al **Product Goal** y, hacia abajo, a las
  oportunidades e historias del backlog (ver [estrategia-vision.md](estrategia-vision.md)).

**Ejemplo (SaaS B2B):**
> **O:** Convertir el trial en un hábito que el usuario no quiera abandonar.
> **KR1:** activación (llegar al "aha") en 7 días: 35% → 55%.
> **KR2:** retención de logos a 90 días: 62% → 75%.
> **KR3:** NPS de usuarios activados: +18 → +30.

---

## 3. North Star Metric (NSM) + inputs + guardrails

La **North Star Metric** es la **única métrica** que mejor captura el valor que el
producto entrega al cliente; la organización se alinea en moverla. Por debajo viven
**inputs** (palancas que el equipo influye directamente) y **guardrails** (métricas
que no debemos romper al perseguir la NSM). *(Amplitude, https://amplitude.com/books/north-star/amplitudes-north-star-metric-and-inputs)*

- **Buena NSM:** refleja **valor entregado al usuario** y **predice ingreso a largo
  plazo** (ej. Spotify: tiempo de escucha; Airbnb: noches reservadas; Slack: mensajes
  enviados dentro de equipos activos). Mala NSM: ingreso bruto (es resultado, no valor)
  o un *vanity total*.
- **Inputs (3-5):** factores controlables que, combinados, mueven la NSM. La fórmula
  `NSM ≈ f(breadth, depth, frequency, efficiency)` ayuda a derivarlos.
- **Guardrails:** calidad, coste, latencia, churn, satisfacción, carga de soporte,
  cumplimiento. Evitan optimizar la NSM destruyendo el negocio.

### 3.1 Árbol de métricas de ejemplo (NSM → inputs → señales)

Producto: app de aprendizaje de idiomas. NSM = **lecciones completadas con
aprovechamiento por usuario activo semanal**.

```
NORTH STAR
└─ Lecciones completadas con aprovechamiento / usuario activo semanal (WAU)
   │
   ├─ INPUT 1 · Amplitud:  % de WAU que inicia ≥1 lección
   │     └─ señales: notificación abierta, streak vivo, recomendación mostrada
   ├─ INPUT 2 · Profundidad: lecciones completadas por sesión
   │     └─ señales: dificultad adecuada, sin abandono a mitad, hints usados
   ├─ INPUT 3 · Frecuencia: días activos / semana (stickiness DAU/WAU)
   │     └─ señales: recordatorios efectivos, hábito/streak, valor percibido
   └─ INPUT 4 · Eficacia: % de respuestas correctas tras la lección (aprendizaje real)
         └─ señales: refuerzo espaciado, corrección, dominio de la unidad

GUARDRAILS (no romper al subir la NSM):
   · CSAT ≥ 4.3/5   · churn mensual ≤ 4%   · coste de notificación/usuario
   · tasa de reportes "demasiadas notificaciones"   · accesibilidad WCAG AA
```

> **Frontera:** tompo define este árbol y **qué significa** "aprovechamiento" y
> "usuario activo" en términos de negocio; **brujula** lo traduce en la
> definición técnica única (qué evento, qué ventana, qué filtros) y **andulfo/caudal**
> garantizan el dato. Una métrica, una definición.

---

## 4. Frameworks de métricas de producto

### 4.1 AARRR — Pirate Metrics (Dave McClure)
Embudo de ciclo de vida del usuario; útil para ver **dónde se pierde valor**.
*(McClure / Amplitude, https://amplitude.com/blog/pirate-metrics-framework)*

| Etapa | Pregunta | Métrica típica |
|---|---|---|
| **Acquisition** | ¿Cómo llegan? | visitas → signups, CAC, fuente |
| **Activation** | ¿Tienen una primera buena experiencia? | % que alcanza el *aha moment* |
| **Retention** | ¿Vuelven? | retención por cohorte D1/D7/D30, churn |
| **Referral** | ¿Recomiendan? | factor viral (k), NPS, invitaciones |
| **Revenue** | ¿Pagan / generan valor? | conversión a pago, ARPU, LTV |

El PO prioriza la etapa con mayor fuga: subir adquisición con activación rota es
desperdicio (llenar un balde agujereado).

### 4.2 HEART (Kerry Rodden / Google)
Para medir **experiencia de usuario** de un producto o feature, con el proceso
**Goals → Signals → Metrics**: define la meta, luego la señal observable, luego la
métrica. *(Rodden, https://kerryrodden.com/heart/)*

| Dimensión | Qué mide | Ejemplo de métrica |
|---|---|---|
| **Happiness** | satisfacción / actitud | CSAT, NPS, encuesta in-app |
| **Engagement** | nivel de involucramiento | sesiones/usuario, acciones clave/semana |
| **Adoption** | usuarios nuevos del feature | % que activa la feature en 30 días |
| **Retention** | usuarios que permanecen | retención por cohorte |
| **Task success** | eficacia/eficiencia | tasa de éxito de tarea, tiempo, errores |

No hay que medir las 5 dimensiones siempre; el PO elige las relevantes al outcome.

### 4.3 Métricas nucleares (definiciones que el PO debe dominar)
- **Activación / aha moment:** el punto donde el usuario percibe el valor central
  (ej. "7 amigos en 10 días"). Se define como un evento medible y temprano.
- **Retención por cohortes:** % de usuarios de una cohorte (mes de alta) que siguen
  activos en periodos sucesivos; la **curva de retención que se aplana** indica
  product-market fit. Distingue *new / current / resurrected / churned*.
- **Engagement / stickiness:** **DAU/MAU** (o WAU/MAU) como proxy de hábito; un 20%+
  ya es señal fuerte según el tipo de producto.
- **NPS** (lealtad): "¿recomendarías…?" 0-10 → %Promotores − %Detractores. Mide
  lealtad/relación, es lento y direccional, **no** sustituye métricas de uso.
- **CSAT** (satisfacción puntual de una interacción) y **CES** (esfuerzo del cliente).

> Vanity vs. accionable: "1M de descargas" (vanity) → "retención D30 del 22% en la
> cohorte de mayo" (accionable). El PO siempre pide la **tasa y la cohorte**.

### 4.4 Product-Market Fit como **señal de decisión** del PO

PMF no es un archivo aparte ni una técnica que el PO ejecute: es la **lectura del
riesgo de valor** (¿el producto entrega valor real y sostenido?) que alimenta la
decisión más importante del PO en fase temprana: **pivotar / perseverar / escalar**.
El PO **interpreta** dos señales convergentes y actúa sobre el backlog en consecuencia:

- **Cuantitativa:** la **curva de retención que se aplana** en una meseta > 0 (§4.3) —
  la evidencia más fiable de PMF; sin meseta, aún no hay fit.
- **Cualitativa/encuesta:** el **test de Sean Ellis** — "¿qué tan decepcionado
  estarías si no pudieras seguir usando el producto?"; **≥ 40%** de "muy decepcionado"
  es el umbral heurístico de PMF (complementa, no sustituye, a la retención).

**Frontera (importante):** el PO **decide y prioriza** con esta señal (perseverar,
duplicar en el segmento que sí tiene fit, o pivotar); **no ejecuta** el instrumento:
el diseño/campo de la encuesta y la investigación cualitativa son de **uxuifull**, y
el análisis estadístico de cohortes/segmentación es de **prisma/brujula**.
tompo consume el resultado, no monta el estudio. Antes de PMF, las métricas de escala
(A/B, DAU/MAU) son prematuras → se prioriza **discovery** (ver
[descubrimiento.md](descubrimiento.md)).

---

## 5. Analítica de producto

Disciplina de instrumentar **eventos** del comportamiento real para responder
preguntas de negocio. El PO **no implementa el tracking** (eso es andulfo/caudal +
ingeniería), pero **especifica qué se mide y por qué**.

- **Event tracking + tracking plan:** lista de eventos (verbo en pasado: *lesson_completed*),
  con propiedades, owner y la **pregunta** que cada uno responde. El plan lo **gobierna
  brujula**; tompo aporta el significado de negocio. Una métrica, una definición.
- **Funnel analysis:** secuencia de pasos hacia una conversión; identifica el paso
  con mayor caída para priorizar.
- **Cohort analysis:** agrupa por característica común (mes de alta, canal, plan) y
  compara su evolución; base de la retención.
- **Churn analysis:** quién se va, cuándo y por qué; modela *leading indicators*
  (caída de uso antes de cancelar) para intervenir a tiempo.
- **Segmentación:** por persona, plan, geografía, comportamiento — el promedio miente
  (Simpson); el PO mira segmentos.

Checklist del PO al pedir analítica: pregunta → evento(s) necesarios → definición
acordada con brujula → segmento/cohorte → umbral de decisión. Nunca "midamos todo".

---

## 6. A/B testing y experimentación (decidir con causalidad)

El A/B test (experimento controlado aleatorizado) es el estándar de oro para
**atribuir causa**: divide usuarios al azar entre control y variante y mide el efecto
sobre una **métrica de éxito** predefinida. El PO **define la hipótesis, la OEC
(Overall Evaluation Criterion) y los guardrails**; ingeniería y datos **construyen y
analizan** el experimento. *(Kohavi, Tang & Xu, *Trustworthy Online Controlled
Experiments*; https://www.optimizely.com/insights/blog/how-to-choose-the-right-stats-engine/)*

### 6.1 Plantilla de hipótesis de experimento
```
Hipótesis:  Creemos que [cambio] para [segmento]
            logrará [efecto esperado en la métrica de éxito]
            porque [razón basada en evidencia/insight de discovery].
Métrica de éxito (OEC): ...........  (la que decide go/no-go)
Guardrails (no empeorar): ........., ........., .........
Tamaño de efecto mínimo relevante (MDE): ...  (decidido ANTES)
Tamaño de muestra / duración: ...  ciclos de negocio
Decisión si gana / si pierde / si plano: ...........
```

### 6.2 Estadística que el PO debe entender (para no engañarse)
- **p-value:** probabilidad de observar un efecto **al menos tan extremo** si la
  hipótesis nula (no hay diferencia) fuera cierta. **NO** es "la probabilidad de que
  la variante sea mejor" ni "de que B gane". Un p<0.05 no garantiza relevancia de
  negocio.
- **Error tipo I (α, falso positivo):** declarar un ganador que no lo es (típico 5%).
  **Error tipo II (β, falso negativo):** no detectar un efecto real.
- **Poder estadístico (1−β, típico 80%):** capacidad de detectar el efecto si existe.
  Bajo poder = experimentos que "no concluyen" por falta de muestra.
- **Fijar el tamaño de muestra ANTES** (a partir de MDE, α y poder). No se "mira
  hasta que dé significativo".
- **PEEKING problem:** revisar el test repetidamente y parar al primer p<0.05 **infla
  drásticamente el falso positivo**. Soluciones: **sequential testing** / métodos
  **bayesianos** / *always-valid p-values*, o fijar la duración y no parar antes.
- **Correr ≥1 ciclo de negocio completo** (incluir fines de semana, ciclos de pago):
  capturar estacionalidad y el *novelty/primacy effect*.
- **Significancia estadística ≠ significancia práctica:** un efecto real pero
  diminuto puede no valer el coste; por eso el MDE se fija desde negocio.
- **Cuidado con:** SRM (sample ratio mismatch → asignación rota), múltiples
  comparaciones (corrección), y segmentar *post-hoc* hasta encontrar un "ganador".

> Frontera: tompo **lee e interpreta** resultados para decidir valor; **prisma**
> es A del rigor estadístico y **brujula** de la métrica. Si el dato dice
> que la apuesta del PO no funcionó, gana el dato (decisiones data-informed).

---

## 7. Feature flags y progressive delivery

Los **feature toggles** desacoplan *deploy* de *release*: el código está en producción
pero su exposición se controla por configuración. *(Pete Hodgson / Martin Fowler,
https://martinfowler.com/articles/feature-toggles.html)*

| Tipo de toggle | Propósito | Vida / dueño |
|---|---|---|
| **Release toggle** | ocultar trabajo en progreso / trunk-based | corta; equipo de entrega |
| **Experiment toggle** | dividir tráfico para A/B test | dura el experimento; PO + datos |
| **Ops toggle** | kill switch operativo, degradación | larga; operación/SRE |
| **Permission toggle** | features por plan/usuario (entitlements) | larga; producto/negocio |

Reglas que el PO respeta:
- **Carrying cost / expiración:** cada flag añade complejidad y rutas de prueba;
  los release/experiment toggles **se retiran** tras cumplir su fin (deuda si no).
- **Progressive delivery:** **canary** (1%→5%→25%…), **% rollout gradual**,
  **ring deployment** y **kill switch** para revertir sin redeploy.
- **Frontera:** tompo decide **a quién y cuándo** exponer (valor, riesgo de negocio,
  segmento); **motor/farola/SRE** construyen y operan el mecanismo; el flag de
  experimento sirve a la **hipótesis y métrica** del §6.

---

## 8. Forecasting probabilístico (pronosticar entrega y valor)

El PO necesita pronosticar "¿para cuándo?" sin prometer fechas falsas. Tendencia
moderna: **forecasting por datos sobre estimación puntual**.

### 8.1 Flow metrics ágiles (Daniel Vacanti)
Métricas de flujo, válidas en Scrum, Kanban o híbrido. *(Vacanti / Scrum.org,
https://www.scrum.org/resources/blog/4-key-flow-metrics-and-how-use-them-scrums-events)*

| Métrica | Definición | Para qué |
|---|---|---|
| **WIP** | ítems empezados y no terminados | exceso de WIP = todo tarda más |
| **Cycle Time** | tiempo de "en progreso" a "hecho" | predictibilidad de entrega |
| **Throughput** | ítems terminados por unidad de tiempo | capacidad real (base del forecast) |
| **Work Item Age** | tiempo que un ítem activo lleva abierto | detectar ítems estancados HOY |

**Ley de Little (forma de flujo):** `Cycle Time medio = WIP / Throughput`. Implicación
para el PO: **bajar el WIP** reduce el cycle time y mejora la predictibilidad sin
trabajar más rápido. Limitar WIP es una palanca de valor, no solo de proceso.

### 8.2 Estimación vs. #NoEstimates
- **Story points / Planning Poker (Mike Cohn):** estimación relativa por complejidad
  (no horas), por consenso; útil para conversación de alcance, frágil como promesa.
- **#NoEstimates (Woody Zuill, Vasco Duarte):** en vez de estimar, **contar ítems**
  y usar el **throughput histórico** para pronosticar; rebanar historias a tamaño
  similar y pequeño hace innecesario el *pointing*.
- Postura del PO: la estimación es **del equipo** (no la impone tompo); sirve para
  priorizar (coste vs. valor), no para comprometer fechas exactas.

### 8.3 Monte Carlo (forecast probabilístico)
Simula cientos/miles de futuros muestreando el **throughput histórico** y devuelve
**percentiles**, no una fecha única. *(Vacanti; Troy Magennis)*

```
Pregunta: "¿cuándo estarán los 45 ítems restantes?"
Resultado Monte Carlo (ejemplo):
   P50  → 6 semanas   (50% de probabilidad de terminar antes)
   P85  → 8 semanas   (compromiso razonable)
   P95  → 10 semanas  (conservador, para stakeholders sensibles al riesgo)
```

El PO comunica en **rangos con probabilidad** ("85% de confianza para la semana 8"),
no en fechas-promesa. Esto convierte la conversación con stakeholders de "¿llegas?"
a "¿qué nivel de riesgo aceptamos?" (ver [stakeholders-liderazgo.md](stakeholders-liderazgo.md)).

---

## 9. Nota de frontera — "Una métrica, una definición"

| Aspecto | Dueño (A) | Qué decide |
|---|---|---|
| **Significado de negocio** de la métrica | **tompo** | qué problema/valor representa, por qué importa, umbral de decisión |
| **Implementación técnica** (definición única, SQL/evento) | **brujula** | cómo se calcula, qué evento, qué ventana, capa semántica |
| **Plataforma, pipelines y disponibilidad del dato** | **andulfo (+caudal)** | de dónde sale, calidad, latencia, gobierno |
| **Modelado/estadística/experimentos** | **prisma** | rigor del análisis, inferencia causal |
| **Construcción de A/B y feature flags** | **motor/farola + andulfo** | el motor; tompo da hipótesis y métrica de éxito |

Si el PO y brujula difieren en "qué es una métrica", **el significado lo fija
tompo y la implementación brujula**; se registra una sola definición compartida y
se evita que dos dashboards muestren "activación" con cálculos distintos. Detalle de
RACI y escalamiento en [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md).

---

## 10. Cierre del modo E

```
Outcome buscado: ...........  (resultado de negocio/usuario, no feature)
Métrica(s) y definición acordada (con brujula): ...........
Guardrails: ...........
Cómo se medirá: instrumentación / experimento / cohorte / forecast
Aprendizaje y re-priorización: qué cambia en el backlog
Próximo paso: ...........
```

> Regla de oro (alineada con SKILL.md): cada entregable de métricas cierra con
> **"Outcome buscado", "Cómo se medirá" y "Próximo paso"**, y nunca declara "valor"
> sin evidencia. Las métricas alimentan el loop **medir → aprender → re-priorizar**
> (vuelta a los modos A/E).
