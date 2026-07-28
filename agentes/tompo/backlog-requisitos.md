# backlog-requisitos.md — Backlog, refinamiento, historias y criterios de aceptación (tompo)

> Referencia de tompo (Product Owner) para el **modo C — Backlog y Definición**.
> Cómo construir, refinar y ordenar el **Product Backlog**, descomponer el trabajo
> (story mapping, jerarquía), escribir **historias de usuario INVEST** y redactar
> **criterios de aceptación testeables** (Gherkin/BDD).
>
> Frontera de rol (no negociable): tompo es **A** de **qué** debe cumplir el
> producto (criterios de aceptación) y de **DoR** (precondiciones de entrada).
> **No** es dueño de la **Definition of Done** ni de la estrategia/ejecución de
> pruebas: eso es **amado** (QA). Tompo da el criterio; amado lo vuelve testeable y
> posee la DoD. Detalle en [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md).

---

## 1. El Product Backlog y su refinamiento

El **Product Backlog** es la única fuente ordenada de lo que podría necesitar el
producto; es **emergente** (nunca "terminado") y tompo es accountable de su
contenido, orden y transparencia (Scrum Guide 2020).

**Refinamiento del Product Backlog** (término oficial; *grooming* está **obsoleto**
y desaconsejado): actividad **continua** de añadir detalle, estimación y orden a los
ítems, y de descomponer los grandes en pequeños hasta dejarlos **"Ready"**. No es un
evento único; se recomienda dedicar **~10% de la capacidad** del equipo de forma
sostenida (Scrum.org, *Product Backlog Refinement*,
https://www.scrum.org/resources/product-backlog-refinement).

| Anti-patrón | Práctica correcta |
|---|---|
| "Grooming" trimestral en una reunión maratónica | Refinamiento **continuo**, en pequeñas dosis (~10% capacidad) |
| Tompo refina solo y "entrega" historias cerradas | Refinamiento **colaborativo**: equipo de entrega + amado + uxuifull |
| Detallar **todo** el backlog al mismo nivel | Detalle **proporcional a la cercanía** (lo de arriba fino, lo de abajo grueso) |
| Estimar para "comprometer fechas" | Estimar para **ordenar y dimensionar**, no para prometer |

### 1.1 DEEP — propiedades de un backlog sano

Heurística de Roman Pichler y Mike Cohn
(https://www.romanpichler.com/blog/make-the-product-backlog-deep/):

| Letra | Propiedad | Qué significa para tompo |
|---|---|---|
| **D** | *Detailed appropriately* | Ítems de arriba (próximos) muy detallados; los de abajo, gruesos |
| **E** | *Estimated* | Cada ítem tiene un tamaño relativo (lo aporta el **equipo**, no tompo) |
| **E** | *Emergent* | El backlog cambia: se añade, refina, reordena y elimina de forma continua |
| **P** | *Prioritized* | Está **ordenado** por valor/riesgo, con método explícito (ver [priorizacion-valor.md](priorizacion-valor.md)) |

---

## 2. Story Mapping — del producto a las historias

El **User Story Mapping** (Jeff Patton) resuelve el problema de un backlog plano: da
una **vista 2D** del producto que conserva el contexto del flujo de usuario
(https://jpattonassociates.com/wp-content/uploads/2015/03/story_mapping.pdf).

```
  ◄───────────── BACKBONE: actividades del usuario (narrative flow) ─────────────►
  [ Buscar ]   [ Elegir ]   [ Pagar ]   [ Recibir ]   [ Reseñar ]      ← columnas
  ─────────────────────────────────────────────────────────────────────────────
  buscar texto  ver ficha    tarjeta     tracking      puntuar    ┐  walking
  filtrar       comparar     guardar     notificación  comentar   ┘  skeleton / MVP
  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
  ordenar       wishlist     PayPal      reembolso     foto       ┐  release 2
  recomendados  3D view      cuotas      cambio        helpful    ┘  release 3
            ▲ PRIORIDAD: arriba = imprescindible; abajo = posterior ▲
```

- **Backbone (horizontal):** la espina dorsal son las **actividades** y tareas del
  usuario en el orden en que ocurren; cuenta la **historia** de uso de extremo a
  extremo.
- **Historias (vertical):** bajo cada actividad cuelgan las historias, ordenadas por
  prioridad de arriba hacia abajo.
- **Walking skeleton / MVP:** el **primer corte horizontal** que atraviesa todo el
  flujo con lo mínimo para entregar valor de punta a punta (no una sola columna
  completa). Cada corte siguiente = un release que profundiza.

Úsalo para: visión compartida, detectar huecos del flujo, planificar releases por
**slices verticales de valor** y evitar entregar "media funcionalidad".

---

## 3. Jerarquía del backlog (y dónde encaja "Feature")

| Nivel | Horizonte típico | Qué es | Ejemplo |
|---|---|---|---|
| **Iniciativa / Tema** | Meses–trimestres | Agrupación estratégica hacia un outcome | "Reducir fricción de checkout" |
| **Épica** | Varios sprints | Cuerpo grande de trabajo que se descompone | "Pago con un clic" |
| **Historia** | **≤ 1 sprint** | Incremento pequeño con valor para el usuario | "Guardar tarjeta para próximas compras" |
| **(Feature)** | — | Nivel **formal solo en escalado** | Ver nota |

> **Nota sobre "Feature":** en **Scrum** la jerarquía típica es **Épica → Historia**
> (así lo modela, por ejemplo, **Jira**); no hay nivel "Feature" formal. "Feature"
> aparece como nivel **oficial solo en
> marcos escalados**, p. ej. **SAFe: Epic → Feature → Story**. No mezcles ambos
> vocabularios en el mismo backlog. (Atlassian, *Epics, Stories, Themes*,
> https://www.atlassian.com/agile/project-management/epics-stories-themes).

Regla práctica de descomposición: si un ítem **no cabe en un sprint** o agrupa varias
necesidades, es **épica**; pártelo en historias verticales (cada una entrega valor),
no en capas técnicas horizontales ("el backend", "el front") — esas son tareas del
equipo, no historias de producto.

---

## 4. Historias de usuario

### 4.1 Plantilla y las 3 C

Formato canónico (Mike Cohn / Connextra,
https://www.mountaingoatsoftware.com/agile/user-stories):

```
Como  <rol / tipo de usuario>
quiero <acción / capacidad>
para  <valor / beneficio / porqué>
```

El "para…" es lo que protege el **outcome**: si no sabes el valor, no es una historia,
es una orden de trabajo. Una historia **no es un documento**, es un **recordatorio de
una conversación**. Las **3 C** (Ron Jeffries):

| C | Significado | Dueño |
|---|---|---|
| **Card** (tarjeta) | El enunciado breve; cabe en una ficha | tompo |
| **Conversation** (conversación) | El detalle se acuerda **hablando** con el equipo | tompo + equipo |
| **Confirmation** (confirmación) | Los **criterios de aceptación** que confirman que está hecha | tompo define el *qué*; **amado** lo vuelve testeable |

### 4.2 INVEST — calidad de una historia

Heurística de Bill Wake (2003,
https://xp123.com/invest-in-good-stories-and-smart-tasks/):

| Letra | Criterio | Pregunta de control |
|---|---|---|
| **I** | *Independent* | ¿Se puede priorizar y entregar sin depender de otra? |
| **N** | *Negotiable* | ¿Es un punto de partida para conversar, no un contrato cerrado? |
| **V** | *Valuable* | ¿Entrega valor visible al **usuario o cliente** (no "valor técnico")? |
| **E** | *Estimable* | ¿El equipo puede dimensionarla? (si no, falta refinamiento) |
| **S** | *Small* | ¿Cabe holgada en un sprint? |
| **T** | *Testable* | ¿Tiene criterios de aceptación que permiten verificarla? |

> Si una historia falla en **V** o **T**, es responsabilidad de tompo arreglarla
> antes de que entre a desarrollo (RACI #7, anti-patrón #6 en gobernanza).

### 4.3 Técnicas de partición (splitting)

Cuando una historia es demasiado grande, pártela por **valor**, no por capa técnica:
por **pasos del flujo**, por **reglas de negocio**, por **variaciones de datos**, por
**interfaz** (camino feliz primero), por **operaciones CRUD**, por **esfuerzo**
(spike de investigación aparte), o por **criterios de calidad** (primero funcional,
luego performance). El patrón SPIDR (Cohn) resume estas vías.

---

## 5. Criterios de aceptación

Los **criterios de aceptación** describen **el "qué" debe cumplir** una historia para
considerarse correcta desde la perspectiva de negocio/usuario — **nunca el "cómo"**
técnico. Son la **Confirmation** de las 3 C y la base de las pruebas de amado.

**Buenos criterios:** claros, verificables objetivamente (sí/no), centrados en
comportamiento observable, sin detalle de implementación, e incluyen caminos
**alternos y de error**, no solo el feliz.

### 5.1 Gherkin (Given-When-Then)

Lenguaje estructurado para criterios ejecutables, de la familia **BDD/Cucumber**
(https://cucumber.io/docs/gherkin/reference/):

```
Dado    <contexto / precondición>      (Given)
Cuando  <acción / evento>              (When)
Entonces <resultado verificable>       (Then)
  Y / Pero <condiciones adicionales>   (And / But)
```

### 5.2 Plantilla de historia con criterios en Gherkin

```
─────────────────────────────────────────────────────────────────────
HISTORIA  US-142 — Guardar tarjeta para futuras compras
─────────────────────────────────────────────────────────────────────
Como     comprador recurrente
quiero   guardar mi tarjeta de forma segura tras un pago
para     no volver a teclear los datos en cada compra (checkout más rápido)

Outcome buscado : ↑ conversión de checkout recurrente; ↓ abandono en pago
Métrica          : % de compras de clientes recurrentes pagadas en < 30 s
Prioridad/Método : Must (MoSCoW) · WSJF alto (ver priorizacion-valor.md)
Tamaño (equipo)  : [lo estima el equipo de entrega — no tompo]

CRITERIOS DE ACEPTACIÓN (Gherkin)

Escenario: Guardar tarjeta con consentimiento explícito
  Dado que completé un pago correctamente
  Y     marqué la casilla "guardar esta tarjeta"
  Cuando confirmo el pago
  Entonces la tarjeta queda disponible (enmascarada, **** 4242) para próximas compras
  Y     se registra el consentimiento con fecha y hora

Escenario: No guardar sin consentimiento
  Dado que completé un pago correctamente
  Y     NO marqué "guardar esta tarjeta"
  Cuando confirmo el pago
  Entonces no se almacena ningún dato de la tarjeta para uso futuro

Escenario: Pagar con tarjeta guardada
  Dado que tengo una tarjeta guardada y válida
  Cuando elijo pagar con ella
  Entonces solo se me solicita el factor adicional requerido (p. ej. CVV/3DS)
  Y     el pago se procesa sin reintroducir el número completo

Escenario (error): Tarjeta guardada expirada
  Dado que mi tarjeta guardada está vencida
  Cuando intento pagar con ella
  Entonces el sistema me informa que está vencida
  Y     me ofrece introducir otra

NOTAS DE FRONTERA / CUMPLIMIENTO
- Almacenamiento/tokenización seguro y **PCI-DSS** → criterio de aceptación de
  negocio; el control técnico lo definen destroyer/sello y el equipo, no tompo.
- Estos criterios son el "qué"; **amado** deriva los casos de prueba y posee la DoD.
─────────────────────────────────────────────────────────────────────
```

---

## 6. DoR vs DoD — la frontera con amado

| | **Definition of Ready (DoR)** | **Definition of Done (DoD)** |
|---|---|---|
| Pregunta | ¿Está **lista para entrar** a desarrollo? | ¿Está **terminada y liberable**? |
| Aplica a | Un ítem **antes** de tomarlo | El **Incremento** producido |
| Estatus | **No oficial** en Scrum (acuerdo de equipo) | **Compromiso oficial** del Scrum Guide |
| Accountable | **tompo** (precondiciones de entrada) | **amado** / equipo (calidad liberable) |
| Contenido típico | Outcome claro, criterios de aceptación, INVEST, dependencias resueltas, estimable | Código revisado, probado, integrado, sin defectos bloqueantes, cumple no-funcionales, desplegable |

> **Distinción clave** (Scrum.org, *DoD vs DoR*,
> https://www.scrum.org/resources/blog/what-difference-between-definition-done-dod-and-definition-ready-dor):
> la **DoD es el compromiso oficial de calidad** sobre el Incremento y su
> accountability es del **equipo/QA = amado**. tompo **no la define ni la negocia**;
> la **respeta como gate**. La **DoR** es un acuerdo de entrada que sí gestiona
> tompo, sin convertirlo en una burocracia que frene el flujo.

**Regla de oro de la frontera (criterios vs DoD vs pruebas):**
- **Criterios de aceptación** = *qué* debe cumplir esta historia → **tompo (A)**.
- **Casos de prueba** = *cómo se verifica* cada criterio → **amado (R)**.
- **Definition of Done** = *barra de calidad* del Incremento → **amado (A)**.

Si tompo empieza a escribir pasos de prueba, datos de prueba o a decidir cobertura,
**invadió a amado**. Si amado decide qué comportamiento es valioso, invadió a tompo.
Handoff en [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md) (Handoff 3 y RACI #7/#8).

---

## 7. BDD y Specification by Example

- **BDD (Behavior-Driven Development)** — Dan North
  (https://dannorth.net/blog/introducing-bdd/): nace de TDD para centrar la
  conversación en el **comportamiento** y un **lenguaje ubicuo** entre negocio y
  equipo. Gherkin es su gramática; el valor está en la **conversación de las 3
  amigos** (PO/negocio + dev + QA), no en la herramienta.
- **Specification by Example** — Gojko Adzic
  (https://gojko.net/books/specification-by-example/): los **ejemplos concretos**
  son la mejor forma de especificar; al automatizarse se convierten en
  **documentación viva** (living documentation) siempre alineada con el sistema.

Para tompo esto significa: especifica con **ejemplos concretos** (no prosa
ambigua), constrúyelos **con el equipo y amado**, y deja que se vuelvan la
confirmación ejecutable de la historia.

---

## 8. Checklist de cierre del modo C

```
- [ ] ¿El backlog es DEEP (detalle proporcional, estimado por el equipo, emergente, ordenado)?
- [ ] ¿Hay refinamiento continuo (~10% capacidad), no "grooming" puntual?
- [ ] ¿Las épicas grandes están mapeadas (story map) y partidas en slices verticales de valor?
- [ ] ¿Cada historia es INVEST y tiene el formato Como/quiero/para con outcome claro?
- [ ] ¿Los criterios de aceptación describen el QUÉ (no el cómo) e incluyen alternos y errores?
- [ ] ¿Los criterios están en Gherkin/ejemplos y son testeables por amado?
- [ ] ¿Respeté la frontera: yo doy criterios + DoR; amado posee pruebas + DoD?
- [ ] ¿Cumplimiento/privacidad/accesibilidad entran como criterios desde ya?
- [ ] ¿La historia cierra con Outcome buscado, Cómo se medirá y Próximo paso?
```

---

## 9. Fuentes

- Scrum.org — *Product Backlog Refinement*: https://www.scrum.org/resources/product-backlog-refinement
- Roman Pichler / Mike Cohn — *Make the Product Backlog DEEP*: https://www.romanpichler.com/blog/make-the-product-backlog-deep/
- Jeff Patton — *User Story Mapping*: https://jpattonassociates.com/wp-content/uploads/2015/03/story_mapping.pdf
- Atlassian — *Epics, Stories, Themes (y SAFe Epic→Feature→Story)*: https://www.atlassian.com/agile/project-management/epics-stories-themes
- Mike Cohn / Mountain Goat — *User Stories y las 3 C*: https://www.mountaingoatsoftware.com/agile/user-stories
- Bill Wake — *INVEST in Good Stories*: https://xp123.com/invest-in-good-stories-and-smart-tasks/
- Cucumber — *Gherkin Reference*: https://cucumber.io/docs/gherkin/reference/
- Scrum.org — *DoD vs DoR*: https://www.scrum.org/resources/blog/what-difference-between-definition-done-dod-and-definition-ready-dor
- Dan North — *Introducing BDD*: https://dannorth.net/blog/introducing-bdd/
- Gojko Adzic — *Specification by Example*: https://gojko.net/books/specification-by-example/

> Relacionados: [priorizacion-valor.md](priorizacion-valor.md) ·
> [descubrimiento.md](descubrimiento.md) · [plantillas.md](plantillas.md) ·
> [checklists.md](checklists.md) · [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)
