# stakeholders-liderazgo.md — Stakeholders, liderazgo e influencia (tompo, Product Owner)

> Referencia del **Modo D (Entrega y Decisión)** de tompo. Cómo el PO **alinea
> stakeholders, gestiona expectativas, negocia alcance, dice "no" con fundamento e
> influye sin autoridad formal** para maximizar el valor del producto.
>
> **Frontera de rol:** tompo decide **qué y por qué** (valor, prioridad, alcance) y es
> la voz del usuario/negocio en el backlog. **No** posee la **estrategia GTM completa
> ni el portafolio** (eso es del **PM de negocio / product marketing / sponsor (rol externo)**); aporta
> **contexto de producto** al GTM. Detalle de RACI y handoffs en
> [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md).

---

## 1. Engage, no "manage": la postura del PO

El PO **no "gestiona" stakeholders como recursos**; los **involucra** (engage) para
co-crear valor y tomar mejores decisiones. La diferencia es de mentalidad:
"management" trata a la gente como obstáculos a controlar; "engagement" los trata como
socios cuyo conocimiento y poder se integran. *(Scrum.org,
https://www.scrum.org/resources/creating-stakeholder-engagement-approach)*

Quién es stakeholder: cualquiera que **afecta o es afectado** por el producto —
usuarios, clientes, negocio (ventas, marketing, finanzas, legal), soporte, operación,
ejecutivos, partners, reguladores y el propio equipo de entrega. El PO los identifica
explícitamente; los invisibles (legal, seguridad, soporte) suelen aparecer tarde y
costar caro.

---

## 2. Stakeholder mapping

### 2.1 Matriz Poder / Interés (Mendelow, popularizada por Pichler)
Clasifica stakeholders por su **poder** (capacidad de influir/bloquear) y su
**interés** (cuánto les afecta), con una estrategia por cuadrante. *(Roman Pichler,
https://www.romanpichler.com/blog/stakeholder-engagement-analysis-power-interest-grid/)*

```
        ALTO  │  KEEP SATISFIED            │  MANAGE CLOSELY / PLAYERS
              │  (Context setters)         │  (Players)
   P          │  poder alto, interés bajo  │  poder alto, interés alto
   O          │  → mantener satisfechos,   │  → colaborar de cerca,
   D          │    consultar en lo clave   │    co-decidir, involucrar mucho
   E   ───────┼────────────────────────────┼───────────────────────────────
   R          │  MONITOR                    │  KEEP INFORMED
              │  (Crowd)                    │  (Subjects)
        BAJO  │  poder bajo, interés bajo   │  poder bajo, interés alto
              │  → esfuerzo mínimo, vigilar │  → informar, escuchar, usar
              │                             │    como aliados/defensores
              └─────────────────────────────────────────────────────────────
                 BAJO          INTERÉS                ALTO
```

| Cuadrante | Estrategia del PO |
|---|---|
| **Players** (poder+interés alto) | involucrar a fondo: co-roadmap, demos, decisiones de trade-off |
| **Context setters** (poder alto, interés bajo) | mantener satisfechos; consultas puntuales de alto nivel; riesgo si se aburren o sienten ignorados |
| **Subjects** (interés alto, poder bajo) | informar y escuchar; aliados naturales y fuente de evidencia de usuario |
| **Crowd** (ambos bajos) | monitoreo mínimo; informar por canales generales |

### 2.2 Salience Model (Mitchell, Agle & Wood)
Prioriza stakeholders por la combinación de tres atributos: **poder + legitimidad +
urgencia**. Quien reúne los tres es **"definitive"** (máxima prioridad); con dos,
"expectant"; con uno, "latent". Útil cuando poder/interés no basta para decidir a
quién atender primero (p. ej. un regulador: alta legitimidad y urgencia).

### 2.3 Stakeholder Engagement Assessment Matrix (PMBOK)
Mapea la actitud **actual (C)** vs. **deseada (D)** de cada stakeholder en una escala,
y el PO planifica acciones para cerrar la brecha:

```
Unaware → Resistant → Neutral → Supportive → Leading
   C..............................D     (mover de Resistant a Supportive, etc.)
```

### 2.4 RACI de decisiones de producto
Para cada decisión clave, define **R**esponsible, **A**ccountable, **C**onsulted,
**I**nformed. Evita el "todos deciden / nadie decide". La RACI de producto del equipo
real (tompo como A del qué/porqué) está en
[gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md).

### 2.5 Plantilla — mapa de stakeholders
```
| Stakeholder | Rol/área | Poder | Interés | Cuadrante | Actitud C→D | Qué necesita / teme | Estrategia y cadencia | RACI |
|-------------|----------|-------|---------|-----------|-------------|---------------------|-----------------------|------|
| VP Ventas   | Negocio  | Alto  | Alto    | Player    | Neutral→Supp| cerrar deals grandes| co-roadmap quincenal  | C    |
| Legal/DPO   | Compliance| Alto | Bajo    | Context   | Resist→Neut | evitar riesgo GDPR  | consulta en discovery | A/C* |
| Soporte     | Operación| Bajo  | Alto    | Subject   | Support→Lead| reducir tickets     | demo + feedback loop  | C    |
| Usuario fin | Cliente  | Bajo  | Alto    | Subject   | —           | resolver su JTBD    | research / beta       | C    |
```
*Compliance: ver frontera con sello en gobernanza.

---

## 3. Evidence-Based Management (EBM)

Marco de Scrum.org para conversar con stakeholders y management **sobre evidencia de
valor**, no sobre output o sensaciones. Cuatro áreas de valor (KVAs). *(Scrum.org,
https://www.scrum.org/resources/engaging-stakeholders-and-management-evidence-based-management-ebm)*

| Área (KVA) | Pregunta | Ejemplos de métrica |
|---|---|---|
| **Current Value (CV)** | ¿qué valor entrega HOY el producto? | satisfacción, uso, ingreso/usuario, retención |
| **Unrealized Value (UV)** | ¿qué valor potencial queda por capturar? | tamaño de mercado, gaps de satisfacción, segmentos sin atender |
| **Time-to-Market (T2M)** | ¿qué tan rápido aprendemos/entregamos? | lead/cycle time, frecuencia de release, tiempo a feedback |
| **Ability to Innovate (A2I)** | ¿qué capacidad de innovar tenemos? | % esfuerzo en valor nuevo vs. mantenimiento, deuda, fricción |

El PO usa EBM para **subir la conversación**: de "¿entregaste las features?" a "¿qué
valor movimos y qué aprendimos?". Conecta directamente con OKR/NSM
([metricas-datos.md](metricas-datos.md)).

---

## 4. Gestión de expectativas y negociación

### 4.1 Partir de una visión sólida para poder decir "no"
La capacidad de decir "no" no nace de la terquedad sino de una **visión y un Product
Goal claros**: cuando todos entienden hacia dónde va el producto y por qué, un "no"
es "esto no nos acerca a la meta", no un capricho. Sin visión, cada petición compite
en igualdad y gana la más ruidosa (la *feature factory*).

### 4.2 Modelo ABC para responder peticiones (Acknowledge–Bridge–Convey)
*(Mind the Product, https://www.mindtheproduct.com/top-tips-negotiating-stakeholders/)*
- **Acknowledge** — reconoce la petición y la persona: "Entiendo que cerrar esa
  cuenta enterprise depende de este módulo, y eso importa."
- **Bridge** — conecta con el contexto/objetivo compartido: "Nuestro Product Goal
  este trimestre es activación; ese módulo sirve a expansión, otro outcome."
- **Convey** — comunica la decisión y el trade-off explícito: "Lo pongo en evaluación
  para el próximo ciclo; meterlo ahora retrasaría onboarding 3 semanas. ¿Hacemos ese
  cambio conscientemente?"

### 4.3 Trade-offs explícitos
El PO **nunca dice solo "no"**: dice "sí a esto **significa no a aquello**". Hace
visible el coste de oportunidad ("si priorizo X, pospongo Y, que afecta al outcome
Z"). Negociar es buscar el interés detrás de la posición ("quiero la feature" → "quiero
no perder el deal"): a veces hay una solución más barata al verdadero problema.

### 4.4 Guion para decir "no" con fundamento
```
1. ESCUCHA y reformula:   "Déjame confirmar qué necesitas y por qué…"
2. RECONOCE el valor:     "Veo el valor para [stakeholder/cliente]: [...]."
3. ANCLA en la meta:      "Nuestro outcome priorizado es [Product Goal/OKR];
                           la evidencia que tenemos es [dato/discovery]."
4. HAZ VISIBLE el trade-off: "Hacerlo ahora implica posponer [X] y retrasar
                           [outcome] en [tiempo]. El coste de oportunidad es [...]."
5. OFRECE camino, no portazo:
      a) "No ahora, pero entra a evaluación con [método: RICE/WSJF] para [ciclo]."
      b) "Validemos primero con [experimento/entrevista]: si los datos lo apoyan, sube."
      c) "Hay una alternativa más barata que resuelve el problema de fondo: [...]."
5b. Si insisten con poder: "Puedo repriorizar si decides cambiar el outcome del
      trimestre; hagámoslo explícito y consciente, no por la puerta de atrás."
6. CIERRA con transparencia: registra la decisión y el porqué (backlog/ADR);
      el "no" queda trazable, no personal.
```
Un "no" del PO es **a la petición, no a la persona**, y siempre **fundamentado en
outcome, evidencia y trade-off**, no en opinión.

---

## 5. Influencia sin autoridad

El PO rara vez tiene autoridad jerárquica sobre quienes necesita movilizar; lidera por
**influencia**. Las dos monedas base son **confianza + competencia**: la gente sigue a
un PO que demuestra criterio de producto y cumple su palabra. *(Marty Cagan / SVPG,
https://www.svpg.com/stakeholder-management/)*

Palancas de influencia sin autoridad:
- **Competencia visible:** conocimiento profundo del usuario, del negocio y del
  producto; el PO es la persona mejor informada sobre el problema en la sala.
- **Confianza y reciprocidad:** cumplir compromisos, dar crédito, ayudar a los
  objetivos de otros primero. *(HBS Online,
  https://online.hbs.edu/blog/post/influence-without-authority)*
- **Redes internas:** construir relaciones **antes** de necesitarlas; mapear quién
  influye en quién; encontrar aliados y *champions*.
- **Datos y evidencia:** un argumento respaldado por datos de usuario o experimentos
  vence a la opinión de quien grita más fuerte (decisiones data-informed).
- **Storytelling:** narrar el problema del usuario y el valor de forma memorable
  (relato + dato + cara del usuario) mueve más que un backlog en bruto.
- **Liderazgo de producto:** Roman Pichler, *How to Lead in Product Management* —
  liderar desde la visión, la empatía y la negociación, no desde el cargo.

> Regla del PO: gana influencia siendo **predecible y útil** para los demás, no
> exigiendo obediencia. La autoridad del PO sobre el orden del backlog solo funciona
> si la organización **respeta sus decisiones** (Scrum Guide); esa legitimidad se
> construye con confianza y resultados.

---

## 6. Colaboración: product trio y equipos empoderados

El descubrimiento y la entrega de valor funcionan mejor con un **product trio** —
producto (tompo/PM), diseño (uxuifull) e ingeniería (eneida/motor/farola) —
colaborando de forma continua, no en *handoffs* secuenciales. *(SVPG, equipos
empoderados.)* El equipo recibe **problemas a resolver, no funciones a construir**.

El PO actúa como **traductor bidireccional**:
- **Hacia el negocio:** traduce el trabajo en términos de **ROI, riesgo y outcome**
  ("esto reduce churn, vale X, el riesgo regulatorio es Y").
- **Hacia el equipo:** traduce la estrategia en **contexto y dolor real del usuario**
  ("este usuario pierde 20 min al día en esto; por eso importa"), no en órdenes.

Respeta las fronteras: el *cómo* (diseño, arquitectura, implementación, calidad,
datos, seguridad) pertenece a los especialistas; tompo aporta el *qué/porqué* y la
prioridad (ver [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)).

---

## 7. Go-to-market y ciclo de vida (lo que toca al PO)

> **Aclaración de frontera:** la **estrategia GTM completa, el posicionamiento de
> mercado, el pricing de portafolio y el plan de lanzamiento comercial** son del
> **PM de negocio / product marketing / sponsor (rol externo)**. El PO **aporta contexto de
> producto** (qué hace, para qué JTBD, qué criterios de éxito, qué está listo) y
> alinea el backlog con el lanzamiento. No lidera el GTM; lo nutre y lo ejecuta en la
> parte de producto.

- **Go-to-Market (Reforge):** plan de **cómo el producto llega al mercado y crece**:
  segmento objetivo, canal, modelo de adquisición, mensaje, motion de ventas. El PO
  asegura que el producto **cumple lo que el GTM promete** y prioriza lo que el
  lanzamiento necesita.
- **Posicionamiento (April Dunford, *Obviously Awesome*):** ubicar el producto en un
  **marco de referencia** que hace su **valor obvio** para el cliente — competidores
  alternativos, atributos únicos, valor que habilitan, segmento que más lo valora. El
  PO contribuye con el conocimiento de las capacidades y diferenciadores reales del
  producto.
- **Product Life Cycle:** introducción → crecimiento → madurez → declive; el foco del
  PO cambia por etapa (activación y PMF al inicio; retención y expansión en madurez;
  *sunset* responsable al final).
- **Product-Led Growth (PLG):** el producto mismo impulsa adquisición, activación y
  expansión (free trial/freemium, self-serve, time-to-value corto, viralidad). El PO
  prioriza la **activación y el "aha moment"** ([metricas-datos.md](metricas-datos.md))
  como motor de crecimiento.

El PO conecta el lanzamiento con **DoR/DoD de release readiness**, comunicación a
stakeholders y métricas de éxito post-lanzamiento (ver
[metricas-datos.md](metricas-datos.md) para NSM/AARRR/guardrails).

---

## 8. Cierre del modo D

```
Stakeholders mapeados (poder/interés, salience, actitud C→D): ...........
Decisiones de alcance/trade-off tomadas y comunicadas: ...........
"No" fundamentados y registrados (con trade-off explícito): ...........
Plan de engagement y cadencia de comunicación: ...........
Outcome buscado: ...........
Cómo se medirá (valor/EBM/satisfacción de stakeholders): ...........
Próximo paso: ...........
```

> Regla de oro (alineada con SKILL.md): cada entregable cierra con **"Outcome
> buscado", "Cómo se medirá" y "Próximo paso"**. El PO **involucra** (no "gestiona"),
> dice **"no" con fundamento** a lo desalineado, e **influye con confianza, datos y
> relato**, respetando las fronteras de rol del equipo.
