# priorizacion-valor.md — Priorización y valor de negocio (tompo)

> Referencia de tompo (Product Owner) para el **modo C — Priorización y valor**.
> Cómo **ordenar el Product Backlog** con métodos explícitos, justificar la
> prioridad con **valor de negocio** (canvas, unit economics, pricing) y construir
> un **business case** defendible. El orden del backlog es accountability de tompo
> (RACI #2); aquí están las herramientas para no ordenarlo "por opinión".
>
> Frontera de rol (no negociable): tompo **prioriza**, pero la **estimación de
> esfuerzo** (Effort, Job Duration, tamaño, story points) la aporta el **equipo de
> entrega**; tompo la usa, **no la impone** (RACI: estimación técnica = equipo).
> Detalle en [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md).

---

## 1. Frameworks de priorización — cuándo usar cada uno

No existe un método único; cada uno responde a una pregunta distinta y tiene
limitaciones. Elige por **contexto** (velocidad vs rigor, deadline, datos de
cliente), no por moda.

### 1.1 RICE — rigor con cuatro factores

`Score = (Reach × Impact × Confidence) / Effort`
(Intercom, https://www.intercom.com/blog/rice-simple-prioritization-for-product-managers/)

| Factor | Qué mide | Escala típica |
|---|---|---|
| **Reach** | Cuántos usuarios/eventos afecta por periodo | nº real (p. ej. 1.200/trimestre) |
| **Impact** | Cuánto mueve la aguja por usuario | 3=masivo, 2=alto, 1=medio, 0.5=bajo, 0.25=mínimo |
| **Confidence** | Cuánta evidencia respalda Reach/Impact/Effort | 100% / 80% / 50% (descuenta el humo) |
| **Effort** | Persona-mes del **equipo** | nº (lo aporta el equipo, **no tompo**) |

- **Úsalo cuando:** hay varias iniciativas comparables y quieres rigor; *Confidence*
  castiga las apuestas sin datos.
- **Limitación:** falsa precisión; sensible a cómo se estima Reach/Impact; no captura
  coste de retraso ni dependencias.

### 1.2 WSJF — coste de retraso (SAFe)

`WSJF = Cost of Delay / Job Duration` y
`Cost of Delay = Valor de negocio + Criticidad temporal + Reducción de riesgo / Oportunidad (RR&OE)`
(SAFe, https://framework.scaledagile.com/wsjf)

- Se puntúa cada componente en escala **Fibonacci relativa** (1,2,3,5,8,13,20).
- Maximiza el valor entregado por unidad de tiempo: prioriza lo de **mayor CoD y
  menor duración** primero (job más corto y urgente gana).
- **Úsalo cuando:** escalas (SAFe/ART), hay urgencia temporal y dependencias; quieres
  decidir secuencia, no solo "sí/no".
- **Limitación:** estimar CoD es subjetivo; **Job Duration la da el equipo**, no
  tompo.

### 1.3 MoSCoW — para alcance con deadline (DSDM)

**Must / Should / Could / Won't (this time)**
(Agile Business / DSDM, https://www.agilebusiness.org/dsdm-project-framework/moscow-prioritisation.html)

| Categoría | Significado |
|---|---|
| **Must** | Sin esto el entregable **fracasa** / no es legal/viable |
| **Should** | Importante, pero hay alternativa o se puede diferir con dolor |
| **Could** | Deseable; entra si sobra capacidad |
| **Won't** | Acordado **fuera** de este ciclo (explícito, no olvidado) |

- **Regla DSDM:** los **Must** deben ser **≤ ~60% del esfuerzo**, dejando ~40% entre
  Should/Could como **contingencia** para proteger la fecha.
- **Úsalo cuando:** hay **fecha fija** y alcance negociable (lanzamientos, eventos).
- **Limitación:** no ordena dentro de cada categoría; tiende a inflar "Must".

### 1.4 Kano — satisfacción del cliente

Clasifica features por su efecto en la satisfacción
(ProductPlan, https://www.productplan.com/glossary/kano-model):

| Categoría | Efecto | Ejemplo |
|---|---|---|
| **Must-be (básico)** | Si falta, frustra; si está, no encanta | que el login funcione |
| **Performance (lineal)** | A más, más satisfacción | velocidad de carga |
| **Attractive (delighter)** | Encanta si está; no molesta si falta | un detalle sorpresa |
| **Indifferent** | No mueve nada | quitar |
| **Reverse** | Algunos lo **odian** | forzar registro |

- **Úsalo cuando:** tienes **datos de cliente** (encuesta funcional/disfuncional) y
  decides el mix básicos/diferenciadores.
- **Limitación:** requiere encuesta; las categorías **migran con el tiempo** (un
  delighter se vuelve básico).

### 1.5 Métodos rápidos y de oportunidad

- **Value vs Effort (2×2):** matriz Valor (alto/bajo) × Esfuerzo (alto/bajo). Cuadrante
  alto-valor/bajo-esfuerzo = *quick wins*. Rápido y visual; **Effort = equipo**.
  Limitación: dos ejes solo, ignora confianza y urgencia.
- **ICE (Sean Ellis):** `Impact × Confidence × Ease`, cada uno 1–10
  (https://www.productplan.com/glossary/ice-scoring-model). Más rápido que RICE pero
  más subjetivo; ideal para **experimentos de growth**.
- **Opportunity Scoring (Ulwick / ODI):**
  `Oportunidad = Importancia + max(Importancia − Satisfacción, 0)`
  (https://www.productplan.com/glossary/opportunity-scoring). Encuentra resultados
  **importantes y mal atendidos** (under-served). Requiere encuesta a clientes
  (importancia/satisfacción por *outcome*, no por feature).

### 1.6 Tabla comparativa y regla práctica

| Método | Pregunta que responde | Necesita | Velocidad | Rigor |
|---|---|---|---|---|
| **ICE** | ¿Qué experimento corro ya? | Juicio | ★★★ | ★ |
| **Value vs Effort** | ¿Dónde están los quick wins? | Juicio + Effort (equipo) | ★★★ | ★ |
| **RICE** | ¿Qué iniciativa rinde más con evidencia? | Datos de alcance/impacto + Effort | ★★ | ★★★ |
| **WSJF** | ¿En qué **orden/secuencia** a escala? | CoD + Job Duration (equipo) | ★★ | ★★★ |
| **MoSCoW** | ¿Qué entra con fecha fija? | Acuerdo de stakeholders | ★★ | ★★ |
| **Kano** | ¿Básico o diferenciador? | Encuesta a clientes | ★ | ★★★ |
| **Opportunity** | ¿Qué necesidad está mal atendida? | Encuesta importancia/satisfacción | ★ | ★★★ |

> **Regla práctica de tompo:**
> - **ICE / Value-Effort** → cuando necesitas **velocidad** (growth, descubrimiento, equipo pequeño).
> - **RICE / WSJF** → cuando necesitas **rigor y escala** (portafolio, ART, defender inversión).
> - **MoSCoW** → cuando manda una **fecha** (lanzamiento, evento, regulación).
> - **Kano / Opportunity Scoring** → cuando tienes **datos de cliente** y decides mix de valor.
>
> Ningún método decide por ti: son **ayudas a la conversación**. La prioridad final
> es de tompo (A), trazable al outcome (ver [backlog-requisitos.md](backlog-requisitos.md) §1.1).

---

## 2. Plantillas de scoring

### 2.1 RICE

```
─────────────────────────────────────────────────────────────────────
Iniciativa            | Reach | Impact | Conf. | Effort | RICE
                      | (/trim)| (.25-3)| (%)   | (p-mes)| =(R×I×C)/E
─────────────────────────────────────────────────────────────────────
Pago con un clic      | 1200  | 2.0    | 0.80  | 3      | 640
Reseñas con foto      |  800  | 1.0    | 0.50  | 2      | 200
Recomendador IA       |  500  | 3.0    | 0.50  | 8      |  94
─────────────────────────────────────────────────────────────────────
Effort lo aporta el EQUIPO de entrega. Confidence descuenta el optimismo.
Ordenar de mayor a menor RICE → secuencia propuesta (no contrato).
─────────────────────────────────────────────────────────────────────
```

### 2.2 WSJF

```
─────────────────────────────────────────────────────────────────────
                 |  Valor  | Crit.   | RR&OE   | CoD   | Job   | WSJF
Feature          | negocio | temporal| (riesgo)| =suma | Durat.| =CoD/JD
                 | (Fib)   | (Fib)   | (Fib)   |       | (Fib) |
─────────────────────────────────────────────────────────────────────
Cumplir PSD2     |   8     |   13    |   8     |  29   |   3   | 9.7
Checkout 1-clic  |  13     |    5    |   3     |  21   |   5   | 4.2
Dark mode        |   3     |    1    |   1     |   5   |   3   | 1.7
─────────────────────────────────────────────────────────────────────
Job Duration ≈ tamaño/duración → la aporta el EQUIPO. WSJF alto = primero.
─────────────────────────────────────────────────────────────────────
```

> **Nota de frontera (recurrente):** en RICE el **Effort** y en WSJF la **Job
> Duration** son **estimaciones del equipo de entrega** (motor/farola/eneida, etc.).
> Tompo **no las inventa ni las negocia a la baja**: las recibe y prioriza con ellas.
> Si faltan, se piden en refinamiento; no se prioriza con números fabricados.

---

## Capacidad para deuda de producto

tompo reserva **explícitamente** un % de capacidad por periodo a **deuda de
producto / calidad / tech-debt** frente a features nuevas, y la **prioriza con el
mismo método** (RICE/WSJF) que el resto del backlog. La decisión de **cuánto**
reservar es de tompo (valor); el **detalle técnico** de la deuda —qué pagar y cómo—
lo aporta el equipo (eneida/motor/farola). Sin reserva explícita, la deuda no
compite y nunca se prioriza.

## Secuenciación de dependencias

tompo **mapea y secuencia** las dependencias entre **ítems de su backlog** y las
**comunica** (no las implementa). WSJF ayuda a ordenar por coste de retraso, pero
**no basta** para resolver dependencias. A escala **multi-equipo/programa**, la
**coordinación** de dependencias entre equipos es del **orquestador de entrega**
(`orquesta`; o RTE/Nexus según el marco): tompo las **mapea y expone** hacia orquesta, **no las secuencia a nivel de
programa**. Si la escala lo exige, remite a la gestión de dependencias de
[frameworks-marcos.md](frameworks-marcos.md) (Nexus).

---

## 3. Valor de negocio — del modelo al producto

### 3.1 Business Model Canvas (9 bloques)

Mapa de cómo el producto **crea, entrega y captura valor**
(Osterwalder / Strategyzer):

```
┌─────────────┬─────────────┬───────────────┬──────────────┬─────────────┐
│ 8 Socios    │ 7 Activi-   │   2 Propuesta │ 4 Relación   │ 1 Segmentos │
│   clave     │   dades     │   de valor    │   con cliente│   de cliente│
│             ├─────────────┤               ├──────────────┤             │
│             │ 6 Recursos  │               │ 3 Canales    │             │
│             │   clave     │               │              │             │
├─────────────┴─────────────┴───────────────┴──────────────┴─────────────┤
│ 9 Estructura de costes          │ 5 Fuentes de ingreso                  │
└─────────────────────────────────┴───────────────────────────────────────┘
```

Para tompo: ubica dónde una iniciativa mueve el modelo (¿reduce costes? ¿abre canal?
¿mejora relación/retención? ¿nueva fuente de ingreso?). Conecta backlog ↔ negocio.

### 3.2 Value Proposition Canvas

Zoom a dos bloques (Propuesta de valor ↔ Segmento), para **encaje problema-solución**
(https://www.strategyzer.com/library/the-value-proposition-canvas):

| Customer Profile (círculo) | ↔ | Value Map (cuadrado) |
|---|---|---|
| **Jobs** (lo que el cliente intenta lograr) | ↔ | **Products & services** |
| **Pains** (frustraciones, riesgos, obstáculos) | ↔ | **Pain relievers** (cómo los alivia) |
| **Gains** (resultados y beneficios deseados) | ↔ | **Gain creators** (cómo los produce) |

**Fit:** existe cuando los *pain relievers* y *gain creators* atacan los *pains/gains*
que el cliente realmente **prioriza**. Une discovery (JTBD, ver
[descubrimiento.md](descubrimiento.md)) con priorización.

---

## 4. Unit economics — ¿el valor es rentable?

Métricas para justificar prioridad con dinero (a16z, *16 Startup Metrics*,
https://a16z.com/16-startup-metrics/):

| Métrica | Fórmula | Lectura |
|---|---|---|
| **CAC** | Coste total de ventas+marketing / nº clientes nuevos | Cuánto cuesta adquirir |
| **LTV** | **Margen de contribución × vida del cliente**, con `vida = 1/churn` | Valor que deja un cliente |
| **LTV:CAC** | LTV / CAC | Sano si **≥ 3:1** (por debajo, no escala) |
| **CAC payback** | CAC / (ingreso mensual × margen) | Meses para recuperar el CAC (mejor < 12) |

> Cuidado (a16z): LTV usa **margen de contribución**, no ingreso bruto; y `1/churn`
> sobreestima si el churn no es estable. Tompo usa estas métricas para **priorizar
> iniciativas que mejoran retención (↑LTV) o eficiencia de adquisición (↓CAC)** y
> para defender el business case, no como vanity metrics.

---

## 5. Pricing basado en valor

Principios de Madhavan Ramanujam (*Monetizing Innovation*):

- **"Price before product":** valida la **disposición a pagar (willingness to pay)**
  **temprano**, durante discovery — no después de construir. Una conversación de
  precio es también una validación de **valor**.
- **Value metric:** cobra por la **unidad que escala con el valor** que recibe el
  cliente (p. ej. por asiento, por transacción, por GB, por envío). Si el value
  metric está bien elegido, el precio crece cuando crece el valor entregado.
- **Segmentación + empaquetado:** distinta disposición a pagar → planes/bundles
  alineados a segmentos (conecta con Kano: básicos vs diferenciadores que justifican
  upgrade).

Para tompo: el pricing **prioriza** (lo que la gente pagaría revela valor real) y a
veces **es** la feature (un nuevo plan o value metric). La implementación de billing
y la decisión técnica de cobro las ejecuta el equipo; el **modelo de valor** es de
tompo + negocio.

---

## 5 bis. Ética de producto — el filtro de "qué NO construir" (lente del PO)

La priorización no es solo qué construir primero, sino **qué no merece construirse**.
El PO es accountable del **valor honesto**: valor real para el usuario **y** para el
negocio, no valor extraído engañando al usuario o falseando la métrica. Es una **lente
de decisión** que se aplica al priorizar y al definir criterios de aceptación, no una
disciplina nueva ni una auditoría (eso es de otros).

**Preguntas que tompo se hace antes de priorizar/aceptar un ítem:**
- **¿El valor es mutuo?** ¿beneficia al usuario, o solo extrae del usuario para el
  negocio (fricción intencional, coacción o *lock-in* abusivo)?
- **¿Hay *dark patterns*?** — confirmshaming, suscripción fácil / cancelación difícil,
  costes ocultos, casillas premarcadas, *nagging*, forzar continuidad. **Se rechazan
  como criterio de aceptación**, aunque suban una métrica de corto plazo.
- **¿La métrica se está *gameando*?** un ítem que mueve el número sin mover el valor
  real (o a costa de la confianza) es deuda, no logro → exige **guardrail metrics**
  (ver [metricas-datos.md](metricas-datos.md) §3).
- **¿Diseño para el hábito o para la adicción?** perseguir engagement sano (el usuario
  gana) vs. patrones compulsivos que dañan el bienestar del usuario.
- **¿Sesgo, exclusión o daño?** ¿el ítem excluye o perjudica a un grupo (accesibilidad,
  equidad, poblaciones vulnerables)?

**Frontera (qué es del PO y qué NO):** tompo **decide** con esta lente qué entra al
backlog y qué se rechaza, y lo deja explícito en los criterios de aceptación. **No le
corresponde:** el **diseño** de la experiencia no manipulativa lo ejecuta **uxuifull**;
el **cumplimiento legal/privacidad** (GDPR, Habeas Data, consentimiento, CCPA) es de
**sello** (ver [cumplimiento-regulacion.md](cumplimiento-regulacion.md)); la
**ética específica de IA** (sesgo de modelo, transparencia, human-in-the-loop) está en
[ia-producto.md](ia-producto.md). El PO fija el **qué/porqué ético**; cada especialista
ejecuta el **cómo** en su dominio.

---

## 6. Business case, ROI y NPV

Cómo tompo **defiende** una prioridad con números:

| Concepto | Qué es | Uso del PO |
|---|---|---|
| **Business case** | Problema, opciones, beneficio esperado, coste, riesgos, recomendación | Justificar invertir aquí y no allá |
| **ROI** | (Beneficio − Coste) / Coste | Comparación simple de retorno |
| **NPV** | Valor presente de flujos futuros descontados | Decisiones plurianuales / grandes apuestas |
| **Cost of Delay** | Valor que se pierde **por cada semana** de retraso | Argumento de **secuencia** (alimenta WSJF) |

```
BUSINESS CASE (one-pager)
- Problema / oportunidad (outcome buscado): ...
- Opciones consideradas (incl. "no hacer nada"): ...
- Beneficio esperado (métrica + magnitud + confianza): ...
- Coste y esfuerzo (estimado por el EQUIPO): ...
- Riesgos y supuestos [SUPUESTO]: ...
- Recomendación + cómo se medirá el valor: ...
```

> El business case cierra el círculo de trazabilidad: **outcome → oportunidad →
> iniciativa priorizada → métrica de valor** (principio 9 del SKILL).

---

## 7. Checklist de cierre (priorización y valor)

```
- [ ] ¿Elegí el método de priorización adecuado al contexto (velocidad/rigor/deadline/datos)?
- [ ] ¿El orden del backlog es explícito, trazable al outcome y no "por opinión"?
- [ ] ¿Usé el Effort/Job Duration que aportó el EQUIPO (no estimaciones fabricadas por mí)?
- [ ] ¿Conecté la iniciativa con el modelo de negocio (BMC) y el encaje de valor (VPC)?
- [ ] ¿Comprobé que el valor es rentable (LTV:CAC ≥ 3:1, payback razonable) donde aplica?
- [ ] ¿Consideré pricing/willingness to pay si la iniciativa toca monetización?
- [ ] ¿Tengo un business case con beneficio, coste, riesgo y cómo se medirá?
- [ ] ¿El entregable cierra con Outcome buscado, Cómo se medirá y Próximo paso?
```

---

## 8. Fuentes

- Intercom — *RICE*: https://www.intercom.com/blog/rice-simple-prioritization-for-product-managers/
- Scaled Agile — *WSJF*: https://framework.scaledagile.com/wsjf
- Agile Business / DSDM — *MoSCoW*: https://www.agilebusiness.org/dsdm-project-framework/moscow-prioritisation.html
- ProductPlan — *Kano Model*: https://www.productplan.com/glossary/kano-model
- ProductPlan — *Opportunity Scoring (Ulwick/ODI)*: https://www.productplan.com/glossary/opportunity-scoring
- ProductPlan — *ICE Scoring (Sean Ellis)*: https://www.productplan.com/glossary/ice-scoring-model
- Strategyzer (Osterwalder) — *Value Proposition Canvas* (y Business Model Canvas): https://www.strategyzer.com/library/the-value-proposition-canvas
- a16z — *16 Startup Metrics*: https://a16z.com/16-startup-metrics/
- Madhavan Ramanujam — *Monetizing Innovation* (price before product, value metric).

> Relacionados: [backlog-requisitos.md](backlog-requisitos.md) ·
> [descubrimiento.md](descubrimiento.md) · [metricas-datos.md](metricas-datos.md) ·
> [estrategia-vision.md](estrategia-vision.md) · [plantillas.md](plantillas.md) ·
> [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)
