# dominios.md — El rol del PO por tipo de producto y dominio

> **Referencia única** de cómo cambia el rol del Product Owner según el **tipo de
> producto y el dominio**. El marco metodológico está en
> [frameworks-marcos.md](frameworks-marcos.md); el **detalle regulatorio** está en
> [cumplimiento-regulacion.md](cumplimiento-regulacion.md). Aquí: **qué cambia para
> el PO, la métrica clave y el riesgo/regulación** de cada dominio, **sin sesgo**.
>
> Principio: la **esencia del PO no cambia** (maximizar valor, ordenar el backlog,
> voz del usuario). Lo que cambia es **quién es el usuario, qué es "valor", cómo se
> mide y qué restricciones gobiernan la priorización**. tompo detecta el dominio y
> ajusta el lente, sin perder la frontera de rol (qué/porqué, no el cómo técnico —
> ver [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)).

---

## 1. Cómo leer un dominio (las 4 preguntas del PO)

Ante cualquier producto, tompo responde primero:

1. **¿Quién es el usuario y quién es el comprador?** (¿coinciden o no?)
2. **¿Qué es "valor" aquí y cuál es la métrica que lo define?** (la *única* métrica
   que, si se mueve, el negocio cambia).
3. **¿Qué riesgo o regulación gobierna la priorización?** (¿entra desde discovery?)
4. **¿Qué especialista del equipo es crítico para este dominio?** (datos, seguridad,
   UX, IA…).

El resto del documento responde estas preguntas por dominio.

---

## 2. B2B vs B2C — la división fundacional

La diferencia más estructural: **¿el que compra es el que usa?**

| Eje | **B2C** (consumidor) | **B2B** (empresa) |
|---|---|---|
| Comprador vs usuario | **Coinciden** (usuario = decisor de compra) | **Distintos**: comprador (decisor económico) ≠ usuario (quien lo usa a diario) |
| Driver de valor | **Usabilidad, deseo, retención** | **ROI, eficiencia, cumplimiento, integración** |
| Ciclo de venta | Corto, autoservicio, masivo | Largo, con RFP, comités de compra, pilotos |
| Stakeholders | Pocos (el propio usuario) | Muchos (comprador, usuario, IT, seguridad, legal, finanzas) |
| Backlog del PO | Optimiza fricción y engagement | Equilibra **lo que pide el comprador** con **lo que necesita el usuario** |

**Qué cambia para el PO en B2B:** debe distinguir **"voz del comprador" de "voz del
usuario"** y no dejar que la primera entierre a la segunda (features que venden pero
nadie usa). Aparece el patrón **two-in-a-box** (SVPG): un Product Manager y un
ingeniero/tech lead que co-poseen el producto, combinando deseabilidad de negocio y
factibilidad técnica. tompo, como PO, alimenta ese par con problema, valor y
prioridad; no asume el rol técnico.

> Fuente: SVPG — Two-in-a-Box Product Management,
> https://www.svpg.com/two-in-a-box-pm/

**Métrica clave:** B2C → retención/engagement; B2B → ROI demostrable y adopción por
el usuario final (no solo cierre de venta).
**Riesgo:** B2B → construir para el comprador y no para el usuario (baja adopción).

---

## 3. SaaS — el valor está en la retención de ingreso

En SaaS el modelo es **suscripción recurrente**: el valor no se captura en la venta
inicial sino en **mantener y expandir** la cuenta a lo largo del tiempo.

- **Métrica definitoria: Net Revenue Retention (NRR)** — el ingreso recurrente
  retenido + expansión (upsell/cross-sell) − contracción − churn, sobre una cohorte
  de clientes. **NRR sano: 100–130%+** (por encima de 100% el negocio crece **aunque
  no sume un solo cliente nuevo**). Métricas de apoyo: **expansión como % del nuevo
  ARR**, gross retention, churn, ARPA.
- **Qué cambia para el PO:** prioriza por **impacto en retención y expansión**, no
  solo en adquisición. El backlog favorece **time-to-value** (que el cliente llegue
  rápido al "aha"), onboarding, adopción de features que correlacionan con renovación,
  y reducción de causas de churn. Las decisiones se atan a cohortes, no a totales.

> Fuente: SaaS Mag — Net Revenue Retention, the defining SaaS metric,
> https://www.saasmag.com/net-revenue-retention-defining-saas-metric/

**Métrica clave:** NRR (100–130%+).
**Riesgo:** optimizar adquisición ignorando retención → "balde con fugas".

---

## 4. Marketplaces (two-sided) — la liquidez manda

Un marketplace conecta **dos lados** (oferta y demanda). El producto no vale por sus
features sino por su capacidad de **emparejar** ambos lados con éxito.

- **Métricas clave:** **liquidez** (probabilidad de que una búsqueda/listado termine
  en transacción en un tiempo razonable), **fill rate / match rate**, **GMV** (Gross
  Merchandise Value), **take rate** (% que captura el marketplace). De a16z: las
  métricas de marketplace giran en torno a GMV, take rate, liquidez y crecimiento por
  cohorte de cada lado.
- **Qué cambia para el PO:** debe gestionar **dos backlogs implícitos** (uno por
  lado) y el equilibrio entre ellos. Enfrenta el problema **chicken-and-egg**: sin
  oferta no hay demanda y viceversa → estrategias de **seeding** (sembrar un lado
  primero, a menudo la oferta). Vigila el **multi-homing** (usuarios en varias
  plataformas a la vez) que erosiona la lealtad. Prioriza lo que **mejora la
  liquidez** antes que features de un solo lado.

> Fuente: a16z — 13 Metrics for Marketplace Companies,
> https://a16z.com/13-metrics-for-marketplace-companies/

**Métrica clave:** liquidez (+ GMV, take rate, fill/match rate).
**Riesgo:** desbalance de lados (chicken-and-egg) y multi-homing.

---

## 5. Plataformas / APIs — el usuario es el desarrollador

El "usuario" no es una persona en una UI, sino **otro desarrollador que integra**.
El producto es la **API, el SDK y la documentación**.

- **Qué cambia para el PO:** el valor es la **Developer Experience (DX)**. La métrica
  análoga al "time-to-value" es el **time-to-magic / time-to-first-call** (cuánto
  tarda un dev desde leer los docs hasta su primera integración exitosa). Prioriza
  **API-first** (contrato antes que implementación), **documentación, SDKs, ejemplos,
  sandbox**, consistencia, versionado y estabilidad (romper una API rompe a todos los
  integradores). Colabora estrechamente con **eneida** (contratos/arquitectura) sin
  asumir el diseño técnico.
- **Stakeholder oculto:** los integradores son externos; sus necesidades llegan por
  tickets, foros y métricas de uso de endpoints, no por entrevistas clásicas.

**Métrica clave:** time-to-first-call / adopción de endpoints / DX (DevNPS).
**Riesgo:** breaking changes y mala documentación → fuga de integradores.

---

## 6. Mobile — la batalla por la retención y la tienda

Apps móviles compiten por espacio en la pantalla y por sobrevivir al **churn
temprano**. La distribución pasa por las **app stores**.

> **Frontera con el equipo:** tompo define la **estrategia de producto** (retención,
> ASO, ciclos de tienda, negocio); la **construcción de la app** móvil (nativa/
> cross-platform, capacidades de dispositivo, release en tiendas) la ejecuta **`palma`**
> (Ingeniería Mobile). tompo prioriza el *qué*; `palma` construye el *cómo*.

- **Métricas clave:** **retención por cohorte D1 / D7 / D30** (qué % vuelve al día 1,
  7, 30), **stickiness** (DAU/MAU), y métricas de adquisición de tienda. La
  **retención temprana** es el predictor más fuerte de éxito.
- **Qué cambia para el PO:** prioriza el **onboarding** y el primer uso (la mayoría
  del churn ocurre en D1). Integra **ASO (App Store Optimization)** como palanca de
  crecimiento (keywords, ratings, screenshots), gestiona **push notifications** como
  herramienta de re-engagement (sin spamear), y considera **ciclos de release de
  tienda** (revisión de Apple/Google) en la planificación. Las features se evalúan por
  su efecto en la curva de retención.

**Métrica clave:** retención D1/D7/D30 por cohorte (+ stickiness DAU/MAU).
**Riesgo:** churn en D1, dependencia de las políticas de la store, fatiga de push.

---

## 7. Hardware — el coste del cambio tardío es brutal

Producto físico: el ciclo va de **diseño → prototipo → manufactura**, con tooling y
cadenas de suministro. **No se puede "hotfix" un producto ya fabricado.**

- **Qué cambia para el PO:** los ciclos son **largos**; se trabaja por **stage-gate**
  (fases con puntos de decisión go/no-go: concepto, diseño, prototipo, validación,
  producción). El **coste de un cambio crece exponencialmente** según avanza el ciclo
  (cambiar un requisito en diseño es barato; en manufactura, carísimo). La discovery y
  la validación de requisitos deben ser **mucho más exhaustivas por adelantado** que
  en software. Convive con artefactos de ingeniería (**CAD/PLM**), certificaciones y
  lead times de componentes. El PO prioriza congelar requisitos críticos temprano.
- **Software ≠ hardware:** si el producto es híbrido (firmware + hardware), tompo
  separa el ritmo: el software puede iterar; el hardware no.

**Métrica clave:** cumplimiento de stage-gates / coste de cambio por fase / yield.
**Riesgo:** cambios tardíos (recalls, re-tooling), lead times, calidad de manufactura.

---

## 8. E-commerce — el embudo de conversión es el producto

Tiendas online: el valor se mide en el **embudo de compra** y en el ticket.

- **Métricas clave:** **tasa de conversión** (visitantes → compradores), **AOV
  (Average Order Value)**, y **tasa de abandono de carrito** (% que añade al carrito
  pero no compra). Apoyo: LTV, tasa de recompra, coste de adquisición.
- **Qué cambia para el PO:** prioriza por impacto directo en el **embudo**:
  optimización de checkout, reducción de fricción, **personalización** y
  recomendación, búsqueda y merchandising, velocidad de página (afecta conversión).
  El backlog se valida con **A/B testing** casi continuo (ver
  [metricas-datos.md](metricas-datos.md)). Las decisiones se justifican en puntos de
  conversión y AOV, no en preferencias estéticas.

**Métrica clave:** conversión + AOV + abandono de carrito.
**Riesgo:** fricción en checkout, problemas de pago, picos estacionales.

---

## 9. Fintech — la regulación es fundacional, no un parche

Productos financieros (pagos, banca, crédito, inversión). El cumplimiento **no es una
feature**: es la condición de existencia del producto.

- **Qué cambia para el PO:** la **regulación es fundacional** y debe estar en el
  backlog **desde discovery**. Cada release se **alinea con compliance** (no se
  lanza algo que no cumple). **Legal/compliance entran desde el discovery**, no al
  final. tompo incorpora requisitos regulatorios como **criterios de aceptación y de
  priorización** y trabaja con **sello** (riesgo/cumplimiento) y
  **destroyer** (seguridad) desde el inicio. Marcos típicos: PSD2/SCA, PCI-DSS,
  KYC/AML, protección de datos.
- **El marco aplicable depende de la jurisdicción** (no hay un set universal): en
  **LatAm/Colombia**, el regulador financiero local es la **Superintendencia
  Financiera de Colombia** y rige normativa local de pagos/datos (**Habeas Data /
  Ley 1581**); **PSD2/SCA solo si operas en la UE/EEE**; **LGPD** en Brasil; PCI-DSS
  aplica donde se procesan tarjetas. PSD2/PCI son **ejemplos válidos, no
  universales**: tompo confirma la jurisdicción antes de fijar los criterios. Detalle
  en [cumplimiento-regulacion.md](cumplimiento-regulacion.md).
- **Frontera:** tompo es A de **incorporar** el cumplimiento como criterio y de la
  decisión de alcance; el **sign-off técnico/legal** es de sello + legal
  (ver [cumplimiento-regulacion.md](cumplimiento-regulacion.md)).

**Métrica clave:** valor de negocio **dentro** del marco regulatorio (p. ej. tasa de
aprobación de transacciones cumpliendo SCA); cero incidentes de compliance.
**Riesgo:** regulación (PSD2, PCI, KYC/AML), fraude, sanciones por incumplimiento.

---

## 10. Healthtech — seguridad del paciente y certificación desde el día 1

Software clínico, dispositivos médicos, datos de salud. Errores afectan **vidas** y
hay **certificación obligatoria**.

- **Qué cambia para el PO:** la **regulación y los estándares entran desde el
  inicio**, no se añaden después: **FDA (Software as a Medical Device, SaMD)** según
  clasificación de riesgo, **HIPAA** (privacidad de datos de salud en EE. UU.), e
  **ISO 13485** (sistema de gestión de calidad para dispositivos médicos). La
  trazabilidad de requisitos es estricta y auditable. tompo prioriza con
  **sello**, **amado** (calidad/validación) y clínicos como stakeholders; la
  documentación de calidad es parte del entregable, no opcional.
- **Según jurisdicción** (no hay un set universal): **HIPAA solo en EE. UU.**; en la
  UE/EEE aplica **GDPR** sobre datos de salud (y normativa de dispositivos médicos
  como el **MDR**); en **LatAm/Colombia**, **Habeas Data / Ley 1581** y el regulador
  sanitario local; **LGPD** en Brasil. FDA/HIPAA son **ejemplos válidos, no
  universales**: tompo confirma el país de operación antes de fijar los criterios.
  Detalle en [cumplimiento-regulacion.md](cumplimiento-regulacion.md).
- El ritmo de iteración es **más lento y controlado** que en SaaS por la necesidad de
  validación y, según el caso, aprobación regulatoria antes de liberar.

**Métrica clave:** seguridad clínica / cumplimiento regulatorio + outcome de salud.
**Riesgo:** FDA SaMD, HIPAA, ISO 13485; seguridad del paciente
(ver [cumplimiento-regulacion.md](cumplimiento-regulacion.md)).

---

## 11. Govtech — restricciones de procurement y presupuesto

Software para el sector público. El cliente es el Estado; el usuario, la ciudadanía
y/o funcionarios.

- **Qué cambia para el PO:** el **procurement (compra pública) es rígido y lento**:
  pliegos, licitaciones, requisitos fijados por contrato que limitan la agilidad de
  cambiar alcance. Hay **presión presupuestaria** y ciclos atados a periodos fiscales.
  La accesibilidad suele ser **obligatoria por ley** (WCAG/EN 301 549). tompo debe
  equilibrar **lo contratado** con **lo que el usuario realmente necesita**, gestionar
  expectativas de stakeholders políticos y priorizar dentro de límites poco flexibles.
- La **transparencia y la equidad de acceso** son requisitos de valor, no extras.

**Métrica clave:** adopción ciudadana / cumplimiento del contrato + accesibilidad.
**Riesgo:** procurement rígido, presión presupuestaria, requisitos legales de acceso.

---

## 12. Edtech — múltiples stakeholders y privacidad de menores

Plataformas educativas. Característica distintiva: **el que paga, el que enseña, el
que aprende y el que supervisa son personas distintas**.

- **Qué cambia para el PO:** debe servir a **múltiples stakeholders con intereses
  divergentes** — administrador (compra/gestiona), docente (configura/enseña),
  estudiante (aprende) y padres/tutores (supervisan, a veces pagan). El valor para uno
  no es el valor para otro; el PO equilibra los cuatro. Las **ventas suelen ser por
  RFP** (instituciones), con ciclos largos. La **privacidad de menores** es crítica y
  regulada (COPPA en EE. UU., FERPA para registros educativos, y protección reforzada
  de datos de menores en GDPR/normativas locales).
- El outcome último (¿aprendió el estudiante?) es difícil de medir y a menudo se
  sustituye por proxies (engagement, completitud) que tompo debe vigilar para no caer
  en vanity metrics.

**Métrica clave:** outcome de aprendizaje (o proxy validado) + adopción por rol.
**Riesgo:** privacidad de menores (COPPA/FERPA/GDPR), venta por RFP, multi-stakeholder
(ver [cumplimiento-regulacion.md](cumplimiento-regulacion.md)).

---

## 12 bis. Sin ánimo de lucro / sector social / producto interno — "valor" ≠ ingreso

No todo producto captura ingreso. En **ONG, impacto social, sector público sin cobro,
bienes comunes digitales, o productos internos** (herramientas para empleados,
plataformas de plataforma), la lente comercial por defecto (LTV:CAC, NRR, GMV,
conversión) **no aplica** y usarla sería un sesgo. El PO **redefine "valor"**:

- **¿Qué es "valor" aquí?** — **outcome de misión** (personas atendidas, resultado
  social logrado), **coste evitado / eficiencia** (horas ahorradas, errores
  reducidos), **valor público** (acceso, equidad, transparencia) o **habilitación
  interna** (cuánto acelera a los equipos que consumen el producto). El comprador y
  el beneficiario casi nunca coinciden (donante/gobierno/dirección paga; ciudadano/
  empleado se beneficia) → separa **voz del financiador** de **voz del beneficiario**,
  como en B2B (§2).
- **Métrica clave:** un **outcome de misión** medible (no un proxy de vanidad) +
  eficiencia. Para producto interno: **adopción y tiempo ahorrado / satisfacción del
  equipo consumidor** (DevEx/DevNPS, §5), no ingreso.
- **Priorización:** RICE/WSJF siguen sirviendo, pero "Impact" se define contra el
  **outcome de misión o la eficiencia**, no contra revenue; el "coste de retraso"
  puede ser **impacto social no entregado** o **coste operativo perpetuado**.
- **Riesgo dominante:** capturar métricas de misión sin caer en *impact-washing*;
  restricciones de **presupuesto de donante/público** (cercano a govtech, §11);
  sostenibilidad más allá del grant. En producto interno: que el valor exista solo
  si **otros equipos realmente lo adoptan** (riesgo de valor puro).

> Regla: antes de asumir unit economics comerciales, tompo pregunta **"¿este producto
> captura ingreso, o su valor es misión / eficiencia / habilitación?"** y ajusta el
> modelo de valor en consecuencia. Ver [priorizacion-valor.md](priorizacion-valor.md)
> (definición de valor) y §1 (las 4 preguntas del dominio).

---

## 13. Tabla resumen — dominio → métrica clave → qué cambia para el PO

| Dominio / tipo | Métrica clave | Qué cambia para el PO | Riesgo / regulación dominante |
|---|---|---|---|
| **B2B** | ROI + adopción del usuario final | Separar voz del comprador de voz del usuario; two-in-a-box | Construir para quien compra, no para quien usa |
| **B2C** | Retención / engagement | Optimizar fricción, deseo y hábito | Saturación, baja retención |
| **SaaS** | **NRR 100–130%+** | Priorizar retención y expansión, no solo adquisición; time-to-value | Churn (balde con fugas) |
| **Marketplace** | Liquidez (+ GMV, take rate) | Equilibrar dos lados; seeding; vigilar multi-homing | Chicken-and-egg, desbalance de lados |
| **Plataforma / API** | Time-to-first-call / DX | API-first, docs/SDK, versionado estable; usuario = dev | Breaking changes, mala DX |
| **Mobile** | Retención D1/D7/D30 por cohorte | Onboarding, ASO, push, ciclos de store | Churn temprano, políticas de store |
| **Hardware** | Stage-gates / coste de cambio por fase | Discovery exhaustiva por adelantado; congelar requisitos | Cambios tardíos (recalls/re-tooling), lead times |
| **E-commerce** | Conversión + AOV + abandono carrito | Optimizar embudo y checkout; A/B continuo; personalización | Fricción de pago, estacionalidad |
| **Fintech** | Valor dentro del marco regulatorio | Compliance desde discovery; legal en el día 1 | PSD2, PCI, KYC/AML, fraude |
| **Healthtech** | Seguridad clínica / compliance + outcome | Regulación y QMS desde el inicio; iteración controlada | FDA SaMD, HIPAA, ISO 13485 |
| **Govtech** | Adopción ciudadana / cumplimiento contrato | Equilibrar contratado vs necesidad; límites de presupuesto | Procurement rígido, accesibilidad legal |
| **Edtech** | Outcome de aprendizaje + adopción por rol | Servir a 4 stakeholders divergentes; RFP | Privacidad de menores (COPPA/FERPA) |

> **Nota de jurisdicción (filas reguladas).** Los marcos citados son **ejemplos
> válidos, no universales** y dependen del país de operación: **PSD2/SCA solo en la
> UE/EEE** y **HIPAA solo en EE. UU.**; en **LatAm/Colombia** rigen la
> **Superintendencia Financiera de Colombia** y **Habeas Data / Ley 1581**; **LGPD**
> en Brasil. tompo confirma la jurisdicción antes de fijar criterios; detalle en
> [cumplimiento-regulacion.md](cumplimiento-regulacion.md).

---

## 14. Cómo combina tompo dominio + marco + equipo

- El **dominio** define *qué es valor y qué lo restringe*; el **marco**
  ([frameworks-marcos.md](frameworks-marcos.md)) define *cómo se organiza el rol*; la
  **gobernanza** ([gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)) define
  *con quién colabora*. Los tres se aplican a la vez.
- En dominios **regulados** (fintech, healthtech, edtech, govtech), el cumplimiento
  entra como **criterio de aceptación y de priorización desde discovery**; el detalle
  está en [cumplimiento-regulacion.md](cumplimiento-regulacion.md) y el sign-off es de
  **sello** + legal.
- En dominios **data-intensivos** (SaaS, marketplace, e-commerce, mobile), tompo es A
  del **significado de negocio** de las métricas; **brujula** es A de su
  **implementación técnica** ("una métrica, una definición").
- En dominios de **IA**, ver [ia-producto.md](ia-producto.md) (evals, no-determinismo,
  riesgo aceptable; sysuniversal-ai y vector como gates).

---

## 15. Cierre

- **Outcome buscado:** que tompo ajuste el lente del rol al **dominio correcto** —
  usuario, definición de valor, métrica y restricción — sin sesgo hacia ningún tipo
  de producto.
- **Cómo se medirá:** para cada producto, tompo identifica explícitamente la métrica
  clave del dominio y el riesgo/regulación que gobierna la priorización.
- **Próximo paso:** cruzar el dominio con el marco
  ([frameworks-marcos.md](frameworks-marcos.md)) y, si aplica regulación, profundizar
  en [cumplimiento-regulacion.md](cumplimiento-regulacion.md).

> Recordatorio: el dominio cambia **qué es valor y cómo se mide**; no cambia que
> tompo es el único accountable de **maximizarlo y ordenar el backlog**.
