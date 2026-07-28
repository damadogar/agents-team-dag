# descubrimiento.md — Product discovery y validación (Modo A)

> **Referencia del Modo A (Descubrimiento / Contexto).** Cubre cómo tompo (Product
> Owner) **descubre oportunidades y valida supuestos ANTES de comprometer ingeniería**:
> los **4 grandes riesgos**, **dual-track agile**, **continuous discovery** y
> **Opportunity Solution Trees**, **JTBD**, **Lean Startup / MVP**, **assumption
> mapping** y **Design Sprint**.
>
> **Principio rector:** *outcome over output*. La discovery es **continua, no un
> evento**; el objetivo es **reducir riesgo con el mínimo esfuerzo** antes de
> construir. Frontera: tompo lidera el riesgo de **valor**; el resto de riesgos los
> **derriban los especialistas** (ver §1 y
> [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)).

---

## 1. Discovery vs delivery y los 4 grandes riesgos (Cagan/SVPG)

Marty Cagan (Silicon Valley Product Group) distingue dos trabajos paralelos:
**discovery** (descubrir **qué** construir: lo correcto y valioso) y **delivery**
(construirlo bien). En discovery, el equipo debe **derribar los 4 grandes riesgos**
**antes** de invertir en construir (Cagan, SVPG, *The Four Big Risks*,
https://www.svpg.com/four-big-risks/):

| Riesgo | Pregunta que responde | ¿Quién lo derriba en el equipo? |
|---|---|---|
| **Valor (value)** | ¿La gente lo querrá / lo comprará / lo usará? ¿Resuelve un problema real? | **tompo (A)** — es el riesgo nuclear del PO |
| **Usabilidad (usability)** | ¿Los usuarios saben usarlo? ¿La experiencia funciona? | **uxuifull** (research, diseño, validación de usabilidad) |
| **Factibilidad (feasibility)** | ¿Podemos construirlo con el tiempo, skills y tecnología que tenemos? | **eneida** (arquitectura), **motor**/**farola** (back/front), **sysuniversal-ai** (IA) |
| **Viabilidad de negocio (business viability)** | ¿Funciona para nuestro negocio? (legal, ventas, finanzas, marketing, seguridad, cumplimiento) | **tompo** (negocio) + **sello** (privacidad/cumplimiento/legal técnico) + PM (mercado) |

> **Frontera:** tompo es **A del riesgo de valor** y co-A de **viabilidad de negocio**,
> pero **NO** decide usabilidad (uxuifull), factibilidad técnica (eneida/motor/farola/
> sysuniversal-ai) ni los controles de cumplimiento (sello). El PO **coordina/facilita**
> que los 4 riesgos se aborden, cada quien en su dominio. Handoffs en
> [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md).

**Anti-patrón:** llegar a sprint planning con una solución ya decidida y solo entonces
descubrir que nadie la quería (valor) o que no se puede construir (factibilidad). Eso
es la **feature factory**: producir output sin validar valor.

---

## 2. Equipos empoderados y dual-track agile

Cagan defiende **equipos de producto empoderados (empowered product teams)**: equipos
a los que se les da **problemas a resolver** (outcomes), no listas de features a
construir (output), y que tienen la autonomía y el contexto para descubrir la mejor
solución (SVPG, *Empowered Product Teams*,
https://www.svpg.com/empowered-product-teams/).

El **dual-track agile** modela discovery y delivery como **dos pistas en paralelo**,
no en cascada (SVPG, *Dual-Track Agile*, https://www.svpg.com/dual-track-agile/):

```
DISCOVERY TRACK ──► oportunidades ──► experimentos ──► soluciones validadas ──┐
   (rápido, barato, descartable; valida valor/usabilidad/factibilidad/viab.)  │
                                                                              ▼
DELIVERY TRACK  ─────────────────────► historias listas ──► incremento liberable
   (robusto, escalable, mantenible; lo que sobrevivió a discovery)
```

- Es **un solo equipo, dos actividades continuas**, no dos equipos.
- La discovery **alimenta** al backlog: solo entra a delivery lo que **redujo riesgo**.
- El **product trio** (ver §3) corre la pista de discovery de forma colaborativa.

> Frontera: el dual-track **no convierte a tompo en diseñador ni ingeniero**. El PO
> aporta el problema/outcome y la decisión de valor; uxuifull e ingeniería aportan su
> expertise en la misma pista de discovery.

---

## 3. Continuous Discovery y Opportunity Solution Tree (Teresa Torres)

Teresa Torres define **continuous discovery** como el hábito de **entrevistar usuarios
cada semana** y tomar decisiones de producto con ese contacto continuo, estructurando
el pensamiento con un **Opportunity Solution Tree (OST)** (Torres, Product Talk,
*Opportunity Solution Trees*, https://www.producttalk.org/opportunity-solution-trees/).

El OST conecta visualmente el **outcome** con las **oportunidades** (necesidades,
*pain points*, deseos descubiertos en entrevistas), las **soluciones** candidatas y los
**experimentos/assumption tests** que las validan:

```
                      ┌──────────────────────────┐
                      │  OUTCOME (de negocio)    │   ej.: subir activación 7d 22%→40%
                      └────────────┬─────────────┘
            ┌──────────────────────┼──────────────────────┐
       OPORTUNIDAD A          OPORTUNIDAD B           OPORTUNIDAD C
   "no entiendo cómo       "configurar el ahorro    "no confío en dar
    empezar a ahorrar"      me toma demasiado"        acceso a mi banco"
        │                        │                        │
   ┌────┴────┐              ┌────┴────┐              ┌────┴────┐
 SOL A1    SOL A2         SOL B1    SOL B2         SOL C1    SOL C2
 (wizard)  (plantillas)  (1 tap)   (reglas)       (badges)  (modo demo)
   │
 ASSUMPTION TESTS (experimentos que validan la solución más prometedora)
```

**Cómo lo usa tompo:**
1. **Un único outcome** en la raíz (deriva del Product Goal, ver
   [estrategia-vision.md](estrategia-vision.md)).
2. **Oportunidades = necesidades/problemas del usuario**, extraídas de **entrevistas
   continuas basadas en historias** (qué pasó la última vez que…), no de opiniones.
3. **Comparar oportunidades** y elegir dónde apostar (tamaño, frecuencia, encaje con el
   outcome).
4. **Generar varias soluciones por oportunidad** (no enamorarse de la primera idea).
5. **Probar supuestos** con experimentos pequeños antes de construir.

> El OST hace **explícito y trazable** el razonamiento: outcome → oportunidad →
> solución → test. Es el insumo directo de la trazabilidad
> *outcome→oportunidad→solución→historia→métrica* del SKILL.

---

## 4. Jobs To Be Done (Christensen + Ulwick/ODI)

La teoría **Jobs To Be Done (JTBD)** sostiene que los clientes **"contratan" (hire)** un
producto para hacer **un "trabajo" (job)** que surge en una situación; cuando el
producto hace mal el trabajo, lo **"despiden" (fire)** y contratan otro
(Clayton Christensen). Tony Ulwick formaliza la variante **Outcome-Driven Innovation
(ODI)** en Strategyn (Strategyn, *Jobs To Be Done*,
https://strategyn.com/jobs-to-be-done/).

**Principio clave:** los **jobs son estables en el tiempo; los productos y tecnologías
no.** La gente no quería un taladro: quería **un agujero** (y, más al fondo, **colgar un
cuadro**). Diseñar para el *job* protege de la obsolescencia de la solución.

**Plantilla de job statement:**
```
Cuando <situación/contexto>,
quiero <motivación / lo que intento lograr>,
para poder <resultado esperado / job hecho>.
```
**Ejemplo:** *"Cuando recibo mi sueldo, quiero apartar dinero sin pensarlo, para poder
ahorrar sin sentir que me privo."*

**Para tompo:**
- Empieza la discovery por el **job**, no por la feature; así descubres oportunidades
  reales y compites contra **alternativas no obvias** (incluido "no hacer nada").
- Los **desired outcomes** de ODI (mediante métricas de "importancia × satisfacción")
  ayudan a **priorizar oportunidades** (enlaza con
  [priorizacion-valor.md](priorizacion-valor.md), Opportunity Scoring).
- JTBD alimenta el **OST** (las oportunidades son *jobs* y *needs* mal resueltos) y el
  **Product Vision Board** (sección Needs, ver
  [estrategia-vision.md](estrategia-vision.md)).

---

## 5. Lean Startup (Eric Ries): Build–Measure–Learn y MVP

Eric Ries propone gestionar la incertidumbre con el ciclo **Build–Measure–Learn** y el
concepto de **validated learning**: el progreso no es código entregado, sino
**aprendizaje validado con evidencia** sobre qué crea valor (Ries, *The Lean Startup
Principles*, https://theleanstartup.com/principles).

```
        IDEAS
          │ BUILD (lo mínimo para aprender)
          ▼
       PRODUCT (MVP / experimento)
          │ MEASURE (datos reales)
          ▼
        DATA
          │ LEARN (validar/invalidar la hipótesis → perseverar o pivotar)
          ▼
        IDEAS  (vuelta al ciclo)
```

**MVP (Minimum Viable Product):** la **versión mínima** que permite recorrer el ciclo y
**aprender con el mínimo esfuerzo**. No es "el producto pequeño y feo": es el
**experimento más barato que reduce el riesgo**. Tipos útiles:

| Tipo de MVP | Qué prueba | Cuándo usarlo |
|---|---|---|
| **Landing page / smoke test** | Demanda/interés (riesgo de valor) | Antes de construir nada; medir clics, registros |
| **Wizard of Oz** | Valor de la experiencia con backend **manual** simulado | La promesa es validable pero construir el motor es caro |
| **Concierge** | Valor entregando el servicio **a mano**, 1 a 1 | Aprender el job a fondo con pocos usuarios |
| **Prototipo / fake door** | Apetito por una feature antes de construirla | Priorizar entre soluciones del OST |

**Perseverar o pivotar:** tras medir, el equipo decide si la estrategia funciona
(perseverar) o necesita un **pivote** (cambio estructurado de hipótesis manteniendo lo
aprendido).

> Frontera: el MVP **valida valor/viabilidad** (tompo) pero su **construcción** —aunque
> sea desechable— la hacen motor/farola/uxuifull; un Wizard of Oz con datos reales
> puede tocar **privacidad** → consultar sello.

---

## 6. Assumption mapping (Bland & Osterwalder, *Testing Business Ideas*)

David J. Bland y Alex Osterwalder proponen, en *Testing Business Ideas*, **mapear los
supuestos** de una idea en dos ejes —**importancia** (¿qué pasa si es falso?) y
**evidencia** (¿cuánta tenemos?)— para **priorizar el supuesto más riesgoso** (el
*leap of faith*) y probarlo primero. Los supuestos se clasifican en tres familias,
alineadas con los riesgos de Cagan:

- **Deseabilidad (desirability):** ¿lo quieren? (≈ valor + usabilidad)
- **Factibilidad (feasibility):** ¿podemos construir/operar? (≈ factibilidad técnica)
- **Viabilidad (viability):** ¿funciona para el negocio? (≈ business viability)

```
ASSUMPTION MAP
        importante
            ▲
   PROBAR   │   PROBAR
   YA (test │   pronto
   primero) │
  ──────────┼──────────►  evidencia
   ignorar  │   dar por
   por ahora│   válido
            │
        sin importancia
```

**Cómo lo usa tompo:**
1. Lista todos los supuestos detrás de la solución elegida en el OST.
2. Ubícalos en el mapa (importancia × evidencia).
3. **Empieza por el cuadrante "importante + poca evidencia"**: ese es el experimento
   que más reduce riesgo.
4. Elige el **test más barato y rápido** que genere evidencia suficiente (no el más
   sofisticado).

> Esto responde a **"¿qué experimento hacer?"**: no se prueba todo, se prueba **el
> supuesto que, de ser falso, hunde la idea** y del que **menos evidencia** tenemos.

---

## 7. Design Sprint (Jake Knapp / GV)

El **Design Sprint** de Jake Knapp (Google Ventures) es un proceso de **5 fases en ~5
días** para pasar de problema a **prototipo testeado con usuarios reales** sin construir
el producto (GV, *The Design Sprint*, https://www.gv.com/sprint/):

| Día | Fase | Qué pasa |
|---|---|---|
| 1 | **Understand / Map** | Alinear el reto, mapear el problema, elegir un objetivo |
| 2 | **Sketch** | Generar soluciones en detalle, individualmente |
| 3 | **Decide** | Elegir la mejor solución y crear un storyboard |
| 4 | **Prototype** | Construir un **prototipo realista** (fachada, no producto) |
| 5 | **Test** | Entrevistar a 5 usuarios y aprender |

**Cuándo usarlo:** apuesta grande, mucha incertidumbre, stakeholders desalineados, o
para **arrancar** una oportunidad del OST sin comprometer semanas de ingeniería.

> Frontera: el Design Sprint es **colaborativo y facilitado**; **uxuifull** lidera el
> diseño/prototipo y el research de usabilidad, **tompo** aporta el problema, el outcome
> y la decisión de valor, e ingeniería valida factibilidad. tompo **no** diseña la UI.

---

## 8. Cómo el PO corre discovery con el "product trio"

El **product trio** (Torres) = **Product Owner/Manager + diseño + ingeniería**
decidiendo **juntos**. En este equipo:

| Miembro | Aporta en discovery | Riesgo que ayuda a derribar |
|---|---|---|
| **tompo (PO)** | Outcome, voz de negocio/usuario, priorización, decisión de valor | **Valor** + viabilidad de negocio |
| **uxuifull (diseño/UX/research)** | Entrevistas, prototipos, validación de experiencia | **Usabilidad** |
| **eneida / motor / farola / sysuniversal-ai (ingeniería)** | Opciones técnicas, coste, lo posible/lo barato | **Factibilidad** |

Co-participan según el caso **sello** (privacidad/cumplimiento → viabilidad) y
**andulfo/caudal/brujula/prisma** (disponibilidad/calidad de datos para medir el outcome).

**Ritmo recomendado:**
- **Entrevistas continuas** (semanales) con usuarios reales → alimentan el OST.
- **Síntesis colaborativa**: el trío actualiza oportunidades y supuestos juntos.
- **Experimentos pequeños** semanales sobre el supuesto más riesgoso.
- **Decisión de pasar a delivery** solo cuando los 4 riesgos están en nivel aceptable.

---

## 9. Cómo decidir qué experimento hacer (árbol de decisión)

```
¿Cuál es el supuesto MÁS RIESGOSO ahora? (importante + poca evidencia, §6)
   │
   ├─ ¿Es de VALOR/deseabilidad?
   │     • ¿La gente lo quiere?  → landing/smoke test, fake door, encuesta de demanda
   │     • ¿Resuelve el job?     → entrevistas JTBD, concierge, Wizard of Oz
   │     • ¿Pagarían?            → preventa, pricing test
   │
   ├─ ¿Es de USABILIDAD? → prototipo + test con 5 usuarios (handoff uxuifull)
   │
   ├─ ¿Es de FACTIBILIDAD? → spike técnico / PoC (handoff eneida/motor/farola/IA)
   │
   └─ ¿Es de VIABILIDAD de negocio? → análisis de modelo, legal/cumplimiento
                                      (handoff sello + PM/negocio)
```

**Criterio de selección del experimento:** elige el que maximice
**evidencia ganada ÷ coste/tiempo**. Define **antes** la hipótesis, la métrica y el
**umbral de éxito** ("consideraremos validado si ≥ X% de Y hace Z"); si no, el
experimento no es concluyente. Distingue **señal débil** (interés) de **señal fuerte**
(comportamiento real, dinero, uso repetido).

---

## 10. Ejemplo end-to-end de OST (app de finanzas personales)

**Outcome (del Product Goal):** subir la **activación a 7 días** del **22% al 40%**.

```
OUTCOME: activación 7d 22% → 40%
│
├─ OPORTUNIDAD 1: "no sé por dónde empezar a ahorrar" (alta frecuencia en entrevistas)
│     ├─ Solución 1.1: wizard de 3 pasos al onboarding
│     │     └─ Supuesto crítico: "un wizard reduce el abandono inicial"
│     │         → Experimento: fake door + prototipo testeado con 5 usuarios
│     │           Umbral: ≥70% completa el flujo en prototipo
│     └─ Solución 1.2: plantillas de metas predefinidas
│
├─ OPORTUNIDAD 2: "configurar el ahorro me toma demasiado" (pain de esfuerzo)
│     ├─ Solución 2.1: ahorro automático "1 tap"
│     │     └─ Supuesto crítico (riesgo de valor): "la gente confía en la automatización"
│     │         → Experimento: Wizard of Oz (regla aplicada manualmente) con 20 usuarios
│     │           Umbral: ≥40% activa y mantiene la regla 2 semanas
│     └─ Solución 2.2: reglas configurables
│
└─ OPORTUNIDAD 3: "no confío en dar acceso a mi banco" (riesgo de viabilidad/valor)
      ├─ Solución 3.1: modo demo sin conexión bancaria
      └─ Solución 3.2: sellos de confianza/seguridad
            └─ Handoff sello: validar privacidad y mensajes de cumplimiento
```

**Decisión de tompo:** la **Oportunidad 2 / Solución 2.1** ataca el supuesto de valor
más riesgoso y con menos evidencia → se prueba **primero con un Wizard of Oz** (barato,
sin construir el motor de automatización). Si supera el umbral, pasa a **delivery** como
historias INVEST con criterios de aceptación
([backlog-requisitos.md](backlog-requisitos.md)); si no, se descarta o se itera, sin
haber gastado ingeniería.

---

## 11. Cierre del documento

- **Outcome buscado:** entrar a delivery **solo** con soluciones que **redujeron los 4
  riesgos**, evitando construir lo que nadie necesita.
- **Cómo se medirá:** cada oportunidad/solución del OST tiene un supuesto, un
  experimento, una métrica y un umbral; el aprendizaje validado alimenta el backlog.
- **Próximo paso:** convertir las soluciones validadas en **historias INVEST con
  criterios de aceptación testeables** ([backlog-requisitos.md](backlog-requisitos.md))
  y priorizarlas ([priorizacion-valor.md](priorizacion-valor.md)); medir el outcome en
  [metricas-datos.md](metricas-datos.md). Handoffs y fronteras en
  [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md).
