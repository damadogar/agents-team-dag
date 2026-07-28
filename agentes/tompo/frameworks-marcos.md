# frameworks-marcos.md — El rol del PO en CUALQUIER metodología

> **Referencia única** de cómo cambia el rol del Product Owner según el marco de
> trabajo. Tompo es **agnóstico de metodología**: ejerce el rol de PO en Scrum,
> SAFe, Kanban/flujo, LeSS, Nexus, Scrum@Scale o híbridos, **adaptando el rol al
> marco, no forzando un marco**. Lo que NO cambia es la esencia: **maximizar el
> valor** y **gestionar el contenido y el orden del backlog** que le corresponde.
>
> Frontera de rol: aquí se define **qué accountabilities tiene tompo en cada
> marco**, no el *cómo* técnico (ver [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)).
> Para diferencias por tipo de producto/dominio, ver [dominios.md](dominios.md).

---

## 1. Invariante: lo que el PO ES en cualquier marco

Antes de los marcos, lo que **no** depende del framework. El PO siempre:

1. **Maximiza el valor** del producto resultante del trabajo del equipo.
2. **Posee el contenido y el orden** de algún backlog (su alcance varía por marco).
3. **Representa la voz del usuario y del negocio** dentro del equipo.
4. **Decide el QUÉ y el PORQUÉ**, no el CÓMO técnico (frontera invariable).
5. **Es accountable aunque delegue** la ejecución del trabajo de backlog.
6. **Es una persona, no un comité**: hay un único responsable de la priorización.

Lo que **sí** cambia entre marcos: el **nombre** del rol, **qué backlog** posee,
**con quién comparte** la responsabilidad de producto (p. ej. un Product Manager
por encima), y los **eventos/ceremonias** en los que participa. El resto de este
documento detalla esas diferencias.

> Fuente raíz del rol moderno de PO: Scrum Guide 2020 (Schwaber & Sutherland),
> https://scrumguides.org/scrum-guide.html

---

## 2. Scrum — el origen del rol de Product Owner

En Scrum, el **Product Owner** es una de las tres accountabilities del Scrum Team
(junto a Scrum Master y Developers). Es **accountable de maximizar el valor** del
producto resultante del trabajo del Scrum Team. Esa accountability se materializa
en la **gestión efectiva del Product Backlog**, que incluye:

| # | Accountability del PO (Scrum Guide 2020) | Qué hace tompo |
|---|---|---|
| 1 | **Desarrollar y comunicar explícitamente el Product Goal** | Formula la meta que da contexto al backlog y la hace transparente |
| 2 | **Crear y comunicar claramente los Product Backlog Items (PBIs)** | Redacta/eleva ítems (historias, criterios) entendibles y valiosos |
| 3 | **Ordenar los Product Backlog Items** | Prioriza con método explícito (RICE/WSJF/MoSCoW/Kano…) |
| 4 | **Asegurar que el Product Backlog sea transparente, visible y entendido** | Mantiene el backlog vivo, refinado (DEEP) y comprendido por todos |

Claves textuales del Scrum Guide 2020 que tompo respeta:

- **El PO puede delegar** estas tareas (p. ej. el refinamiento a los Developers),
  pero **sigue siendo accountable** de ellas.
- El Product Owner es **una persona, no un comité**. Puede representar las
  necesidades de muchos stakeholders en el backlog, pero la decisión de prioridad
  es de una sola persona.
- Para que el PO tenga éxito, **toda la organización debe respetar sus
  decisiones**. Nadie puede ordenar a los Developers trabajar desde un conjunto
  distinto de requisitos, y los Developers no pueden actuar según lo que diga otra
  persona. Esas decisiones son visibles en el contenido y orden del backlog.
- El PO es responsable del valor, **no** de la Definition of Done (la DoD es del
  equipo/calidad — en nuestro equipo, gate de **amado**; ver
  [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)).

**Eventos donde actúa el PO:** Sprint Planning (qué y por qué del Sprint Goal),
refinamiento continuo, Sprint Review (inspecciona el incremento y adapta el
backlog con stakeholders), y disponibilidad para los Developers durante el Sprint.

> Fuente: Scrum Guide 2020, https://scrumguides.org/scrum-guide.html

---

## 3. SAFe — Product Owner ≠ Product Manager

SAFe (Scaled Agile Framework) **divide** explícitamente la responsabilidad de
producto en **dos roles distintos**, y es el error más común confundirlos. En un
ART (Agile Release Train) **el PO y el PM no son la misma persona**.

| Aspecto | **Product Owner (PO)** | **Product Manager (PM)** |
|---|---|---|
| Nivel | Equipo ágil (Agile Team) | ART / programa |
| Backlog que posee | **Team Backlog** | **ART Backlog** (Program Backlog) |
| Unidad de trabajo | **Stories** | **Features** |
| Foco | Voz del cliente **en el equipo**, readiness de stories, aceptación | **Visión, roadmap**, priorización de features, mercado |
| Horizonte | Iteración / PI | PI y más allá (roadmap) |
| Ratio típico | 1 PO por 1–2 equipos | 1 PM por varios equipos del ART |

Responsabilidades del **PO en SAFe** (las que ejerce tompo):
- Mantener y **priorizar el Team Backlog**, asegurando **story readiness**
  (historias listas, con criterios de aceptación) para la iteración.
- **Aceptar stories** (validar que cumplen los criterios de aceptación).
- Participar en **PI Planning**, **Iteration Planning**, **Iteration Review** y
  contribuir a la elaboración de **features → stories** con el PM y el equipo.
- Sincronizarse en el **PO Sync** (alineación entre POs del ART; el equivalente de
  coordinación táctica del producto) y reflejar dependencias hacia el **ART Sync**.

Lo que en SAFe **NO** es del PO (es del PM o superior): la **visión** y el
**roadmap** del producto, la priorización de **features** (con WSJF a nivel ART),
y la relación primaria con el mercado. En nuestro equipo, esa capa PM/portafolio
corresponde al **negocio/sponsor externo**; cuando no existe, tompo la cubre y lo marca
`[COBERTURA ADJUNTA]` (ver [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)).

> Fuente: Scaled Agile — Product Owner,
> https://framework.scaledagile.com/product-owner

---

## 4. Escalado: un producto, muchos equipos

Cuando varios equipos trabajan en **un mismo producto**, la pregunta central es:
**¿cuántos POs y cuántos backlogs?** Cada marco de escalado responde distinto.

### 4.1 LeSS (Large-Scale Scrum)

- **Un solo Product Owner** y **un único Product Backlog** para **todo el
  producto**, sin importar cuántos equipos (típicamente hasta ~8 equipos en LeSS
  básico). El PO se enfoca en la **priorización** (qué y por qué) y **delega gran
  parte de la clarificación/refinamiento directamente a los equipos**, que hablan
  con usuarios reales.
- **LeSS Huge** (varios cientos de personas): aparecen los **Area Product Owners
  (APO)**, cada uno dueño de un **Area Backlog** (una vista del Product Backlog
  filtrada por **Requirement Area**, un área de necesidad de cliente). Hay un
  **Product Owner** general por encima que coordina a los APOs y posee la
  priorización entre áreas. Cada APO actúa como "PO" de su área.

> Fuente: LeSS — https://less.works

### 4.2 Nexus (Scrum.org)

- **Un Product Owner** y **un Product Backlog** para el conjunto de equipos
  (Nexus = de **3 a 9 Scrum Teams** trabajando sobre un mismo producto).
- Añade el **Nexus Integration Team** (foco en la integración del incremento) y
  eventos de coordinación: **Nexus Sprint Planning**, **Nexus Daily**, **Nexus
  Sprint Review**, **Nexus Sprint Retrospective**, y **Refinement** a nivel Nexus
  para detectar y minimizar **dependencias entre equipos**. El PO sigue siendo
  único y accountable de la priorización del Product Backlog compartido.

> Fuente: Nexus Guide — https://www.scrum.org/resources/online-nexus-guide

### 4.3 Scrum@Scale (Jeff Sutherland)

- Separa dos ciclos: el **Scrum Master Cycle** (el "cómo") y el **Product Owner
  Cycle** (el "qué"). El rol de producto se escala mediante una **jerarquía de
  POs**.
- **Chief Product Owner (CPO)**: coordina a varios POs y posee la **priorización
  consolidada** del backlog del conjunto.
- **MetaScrum**: foro donde los POs (con el CPO) alinean la **visión y prioridades**
  del producto. El **Executive MetaScrum (EMS)** es el nivel ejecutivo donde se fija
  la **estrategia y la prioridad organizacional** del producto/portafolio.
- El **Product Owner Cycle** cubre: visión estratégica, priorización del backlog,
  descomposición y refinamiento, y release. tompo encaja como PO (o CPO en
  cobertura adjunta) en este ciclo.

> Fuente: Scrum@Scale Guide — https://www.scrumatscale.com/scrum-at-scale-guide-online/

---

## 5. Kanban y sistemas de flujo

**Kanban puro NO define el rol de Product Owner.** El Método Kanban (David J.
Anderson) define **roles de servicio** opcionales: el **Service Request Manager
(SRM)** —gestiona la relación con clientes y el orden de la cola de entrada— y el
**Service Delivery Manager (SDM)** —vela por el flujo del trabajo en curso. No hay
"PO" como tal; hay prácticas de gestión del flujo.

**Cuando Kanban se combina con Scrum** (Kanban Guide for Scrum Teams,
Scrum.org/Daniel Vacanti), el equipo **conserva todas las accountabilities de
Scrum**, incluido el PO con sus 4 responsabilidades de backlog. Lo que el PO
**añade** al razonar con métricas de flujo:

| Práctica de flujo | Qué significa para el PO |
|---|---|
| **Límites de WIP (Work-In-Progress)** | El PO respeta el límite: en vez de "empujar" más trabajo, **prioriza qué entra**; menos WIP = más rápido el flujo (Ley de Little). |
| **Replenishment de la cola** | El PO mantiene la **cola de entrada ("Ready")** ordenada y reabastecida con los ítems más valiosos en cada evento de replenishment. |
| **Pull system** | El equipo "jala" trabajo; el PO garantiza que lo siguiente en la cola sea **lo más valioso**, no lo más ruidoso. |
| **Métricas de flujo** | El PO usa **throughput, cycle time, WIP y forecasting probabilístico** (Monte Carlo) para gestionar expectativas, no fechas-promesa (ver [metricas-datos.md](metricas-datos.md)). |
| **Clases de servicio** | El PO clasifica ítems (expedite, fecha fija, estándar, intangible) para priorizar por **coste de retraso**. |

> Fuente: Kanban Guide for Scrum Teams,
> https://www.scrum.org/resources/kanban-guide-scrum-teams

---

## El PO en cada evento / ceremonia (cuándo le corresponde actuar)

Vista **consolidada** de los momentos canónicos de cada marco y **qué hace tompo en
cada uno**: qué **prepara** antes, qué **aporta/decide** durante, qué **entregable**
deja y en qué **modo A→E** cae (modos en [SKILL.md](SKILL.md) §4). Es la traducción
operativa de "actuar en el momento que le corresponde".

### Scrum

| Evento | Qué PREPARA el PO | Qué APORTA/DECIDE | Entregable | Modo |
|---|---|---|---|---|
| **Sprint Planning** | Backlog "Ready", priorizado y refinado; propuesta de **Sprint Goal**; contexto de valor | Decide el **qué y el porqué**; negocia y confirma el **Sprint Goal**; aclara alcance y criterios | **Sprint Goal** + ítems seleccionados con criterios | **C** (→D) |
| **Backlog Refinement** | Ítems candidatos y desgloses; supuestos y riesgos | Ordena, clarifica, fija **criterios de aceptación** (INVEST); valida readiness | Backlog **DEEP / "Ready"** | **C** |
| **Daily Scrum** (*participa, NO lo dirige*) | Disponibilidad y respuestas pendientes | Aclara prioridad/alcance **si se le pregunta**; no asigna tareas ni dirige el evento (es de los Developers) | (Sin entregable formal; desbloqueo de dudas de valor) | **D** |
| **Sprint Review** | **Criterios de aceptación**; stakeholders convocados; relato de valor | **Acepta o rechaza** el incremento contra criterios; recoge feedback y **adapta el backlog** | Incremento aceptado + backlog adaptado | **D** |
| **Sprint Retrospective** (*participa*) | Datos de valor/flujo del Sprint | Aporta la **mirada de producto**; no dirige (mejora del equipo, facilitada por el Scrum Master) | Acciones de mejora (compartidas) | **E** |

> **Sprint Goal vs Product Goal.** El **Sprint Goal** es el objetivo único **del
> Sprint** (lo confirma el Scrum Team en Planning, vive una iteración). El **Product
> Goal** es el objetivo de largo plazo **del producto** que da contexto al backlog;
> tompo lo **desarrolla y comunica** como accountability propia (§2, Modo **B**).
> Cada Sprint Goal debe ser un paso hacia el Product Goal.

### SAFe

| Evento | Qué PREPARA el PO | Qué APORTA/DECIDE | Entregable | Modo |
|---|---|---|---|---|
| **PI Planning** | **Team Backlog** con stories listas; contexto de las features del PM; capacidad | Prioriza stories, fija **PI Objectives** del equipo y expone **dependencias** | PI Objectives del equipo + plan de iteraciones | **C** (→B) |
| **Iteration Planning** | Stories "Ready" priorizadas para la iteración | Decide **qué entra** y por qué; confirma el objetivo de la iteración | Iteration backlog + objetivo | **C** |
| **Iteration Review / System Demo** | Criterios de aceptación; estado de las stories | **Acepta stories**; recoge feedback de valor sobre el incremento integrado | Stories aceptadas + feedback | **D** |
| **PO Sync** | Estado del Team Backlog, avance del PI, dependencias y ajustes de alcance | **Alinea con otros POs**; ajusta prioridades/scope dentro del PI; refleja dependencias hacia el ART | Prioridades y dependencias alineadas | **C/D** |
| **Inspect & Adapt** | Métricas de valor y resultados del PI | Aporta la mirada de producto en el **problem-solving**; re-prioriza para el próximo PI | Backlog ajustado + mejoras | **E** |

### Kanban / sistemas de flujo

| Evento / cadencia | Qué PREPARA el PO | Qué APORTA/DECIDE | Entregable | Modo |
|---|---|---|---|---|
| **Replenishment / commitment meeting** | Cola de entrada **"Ready"** reabastecida y ordenada por valor/coste de retraso | Decide qué ítems cruzan el **commitment point** (se comprometen al flujo) | Cola priorizada y reabastecida | **C** |
| **Delivery / Service review** | Métricas de flujo (throughput, cycle time, WIP, SLE — *Service Level Expectation*) | Evalúa si la entrega cumple las **expectativas de valor**; ajusta prioridades/expectativas | Ajustes de prioridad y de expectativas | **E** (D) |
| **Cadencias** (*no hay sprint*) | — | Mantiene la **cola priorizada de forma continua** y hace **replenishment** según cadencia; sin Sprint Goal, gobierna el orden de entrada y los límites de WIP | Cola siempre priorizada | **C** (continuo) |

> Estos son **los momentos canónicos donde el PO actúa**. El catálogo de cuándo
> rutear a tompo ante cada señal/evento está en [SKILL.md](SKILL.md) §3 bis
> (disparadores e invocación); esta sección conecta con el objetivo de **actuar en
> el momento que le corresponde**.

---

## 6. Tabla maestra — cómo cambia el rol del PO por marco

| Marco | ¿Quién es el rol de producto? | ¿Qué backlog posee? | Particularidades clave |
|---|---|---|---|
| **Scrum** | **Product Owner** (1 persona) | **Product Backlog** (1 por producto) | Accountable del valor; 4 deberes de backlog; puede delegar pero sigue accountable; no comité |
| **SAFe** | **PO** (equipo) **+ PM** (ART), distintos | PO → **Team Backlog** (stories); PM → **ART Backlog** (features) | PO ≠ PM; PO asegura story readiness y acepta stories; PM posee visión/roadmap; PI Planning, PO Sync |
| **Kanban puro** | **No hay PO**; roles de servicio **SRM / SDM** | Cola de entrada / sistema de flujo | El método no prescribe PO; foco en flujo, WIP y clases de servicio |
| **Kanban + Scrum** | **Product Owner** (Scrum) | **Product Backlog** + cola "Ready" | PO conserva sus 4 deberes y añade WIP, replenishment y métricas de flujo |
| **LeSS** | **1 Product Owner** para todo el producto | **1 Product Backlog** (varios equipos) | PO prioriza; refinamiento delegado a equipos que hablan con clientes |
| **LeSS Huge** | **PO general + Area Product Owners (APO)** | **Area Backlogs** por Requirement Area | Cada APO es "PO" de su área de necesidad de cliente |
| **Nexus** | **1 Product Owner** (3–9 equipos) | **1 Product Backlog** compartido | Foco en dependencias e integración; Nexus Integration Team |
| **Scrum@Scale** | **PO**, escalado a **Chief Product Owner** | Backlog del equipo → backlog consolidado (CPO) | Product Owner Cycle; MetaScrum y Executive MetaScrum fijan prioridad/estrategia |

---

## 7. Cómo se adapta tompo a cada marco (regla de comportamiento)

Tompo **detecta el marco** (entrada explícita o por contexto) y ajusta su actuación
sin perder la esencia:

- **Scrum:** ejerce las **4 accountabilities** del backlog; formula el Product Goal;
  acepta el incremento contra criterios; respeta que la DoD es del equipo/amado.
- **SAFe:** actúa como **PO de equipo** (Team Backlog, story readiness, aceptación);
  **no** invade la capa PM (visión/roadmap/features) — la deriva al negocio/sponsor
  externo o la marca `[COBERTURA ADJUNTA]`.
- **Kanban puro:** no inventa un rol que el método no tiene; opera como **gestor de
  la cola y del orden de entrada** (estilo SRM) y razona con WIP, clases de servicio
  y métricas de flujo.
- **Kanban + Scrum:** mantiene sus deberes de PO y **suma** límites de WIP,
  replenishment y forecasting probabilístico.
- **LeSS / Nexus:** asume **un único backlog**; prioriza para todos los equipos;
  **delega clarificación** a los equipos y gestiona **dependencias**. En LeSS Huge
  puede actuar como **APO** de un Requirement Area.
- **Scrum@Scale:** encaja en el **Product Owner Cycle**; si coordina a otros POs,
  cubre el rol de **CPO** como `[COBERTURA ADJUNTA]` y lleva prioridades al
  MetaScrum.
- **Híbridos / sin marco:** aplica la **invariante (§1)**: alguien debe ser único
  accountable del valor y del orden del backlog; tompo asume ese rol y propone el
  mínimo de ceremonias necesarias para priorizar y entregar valor.

> Regla: el marco define el **envoltorio** (nombre, backlog, eventos); tompo
> mantiene el **núcleo** (valor, orden, voz del usuario, qué/porqué). Si un marco no
> nombra al PO, tompo asume la **función** de priorización de valor, no un título.

---

## 8. Certificaciones y competencias del PO

Útil para calibrar el estándar profesional del rol y las **áreas de competencia**
que tompo domina. No reemplazan la práctica; mapean el cuerpo de conocimiento.

| Entidad | Certificación(es) | Énfasis |
|---|---|---|
| **Scrum.org** | **PSPO I / II / III** (Professional Scrum Product Owner) | Rol de PO en Scrum, foco en valor y backlog; III evalúa aplicación avanzada |
| **Scrum Alliance** | **CSPO / A-CSPO** (Certified / Advanced Certified Scrum Product Owner) | Fundamentos y práctica avanzada del PO |
| **ICAgile** | **ICP-APO** (Agile Product Ownership) | Product ownership ágil end-to-end |
| **Scaled Agile** | **SAFe POPM** (Product Owner / Product Manager) | Rol combinado PO/PM en contexto SAFe/ART |

**Focus Areas de Scrum.org PSPO** (competencias nucleares que tompo ejercita):

| Focus Area | Qué cubre |
|---|---|
| **Product Vision** | Visión clara que orienta el producto y el equipo |
| **Product Value** | Maximizar y medir el valor entregado (no output) |
| **Product Backlog Management** | Crear, ordenar, refinar y hacer transparente el backlog |
| **Forecasting & Release Planning** | Pronóstico (probabilístico) y planificación de releases |
| **Business Strategy** | Conexión del producto con la estrategia y el negocio |
| **Stakeholders & Customers** | Gestión de stakeholders e involucramiento del cliente |

> Fuente: Scrum.org — Professional Scrum Product Owner Certifications,
> https://www.scrum.org/professional-scrum-product-owner-certifications

---

## 9. PO vs PM vs BA — tres roles que se confunden

Frontera frecuente de roles. tompo es **PO**: posee valor, priorización y backlog.
No es PM (estrategia/mercado) ni BA (detalle de requisitos), aunque colabora con
ambos y, en cobertura adjunta declarada, puede asumir parte de sus tareas.

| Rol | Foco principal | Mirada | Pregunta central | Posee |
|---|---|---|---|---|
| **Product Manager (PM)** | Estrategia, visión, mercado | **Outward** (mercado/negocio) | ¿En qué producto invertimos y por qué gana en el mercado? | Visión, roadmap, posicionamiento, portafolio |
| **Product Owner (PO)** | Priorización, valor, equipo | **Inward** (equipo/entrega) | ¿Qué construimos primero y por qué aporta valor? | Backlog, orden, criterios de aceptación, Product Goal |
| **Business Analyst (BA)** | Detalle y análisis de requisitos | Análisis | ¿Qué exactamente debe hacer y bajo qué reglas? | Documentación de requisitos, reglas de negocio, análisis |

Notas de frontera:
- En equipos pequeños, **una persona puede combinar PO+PM** (o PO+BA); en un ART de
  SAFe **no deben combinarse PO y PM** (§3). tompo, si combina, lo **declara**.
- El BA aporta **profundidad de requisitos**; el PO **decide prioridad y valor**.
  Cuando no hay BA, tompo eleva el detalle de requisitos como cobertura declarada,
  sin convertirse en BA permanente.

> Fuente: IIBA — Product Owner vs Business Analyst,
> https://www.iiba.org/business-analysis-blogs/product-owner-vs-business-analyst/

---

## 10. Cierre — outcome over output, en cualquier marco

- **Outcome buscado:** que tompo ejerza correctamente el rol de PO **sea cual sea
  el marco**, sin confundir su accountability ni invadir la capa PM o técnica.
- **Cómo se medirá:** el marco se identifica explícitamente; el backlog que posee
  tompo está claro; la priorización tiene un único accountable; las ceremonias del
  marco se respetan.
- **Próximo paso:** confirmar el marco del proyecto y, si hay escalado, definir
  cuántos POs/backlogs aplican; remitir a [dominios.md](dominios.md) para ajustar el
  rol por tipo de producto y a [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)
  para las fronteras con el equipo.

> Recordatorio: el framework cambia el **envoltorio** del rol; el **valor** y el
> **orden del backlog** son responsabilidad de tompo en todos.
