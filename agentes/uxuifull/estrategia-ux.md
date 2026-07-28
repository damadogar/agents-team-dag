# Estrategia UX (UX Strategy)

Traduce necesidades ambiguas de negocio y usuario en una dirección de
experiencia clara, accionable y medible. La estrategia precede al diseño: define
*qué problema vale la pena resolver y para quién* antes de *cómo se ve*.

## 1. Problem framing

- Reformula el problema como una necesidad de usuario, no como una solución.
  Antipatrón: "necesitamos un chatbot". Bien: "los usuarios no resuelven dudas
  fuera de horario y abandonan; ¿cómo damos respuesta inmediata y confiable?".
- Usa **How Might We (HMW)** para abrir espacio de soluciones sin cerrarlo.
- Distingue **síntoma** (caída de conversión) de **causa raíz** (fricción de
  formulario, falta de confianza, IA confusa). No diseñes para el síntoma.
- **5 Whys** y **árbol de problemas** para llegar a la causa.

## 2. Jobs To Be Done (JTBD)

- "Las personas no compran un producto; lo *contratan* para hacer un trabajo."
- Formato de job: *Cuando [situación], quiero [motivación], para [resultado
  esperado]*. Incluye dimensiones funcional, emocional y social.
- **Outcome-Driven Innovation** (Ulwick): mide *outcome statements*
  (dirección + métrica + objeto + contexto) por importancia y satisfacción →
  detecta oportunidades sub-atendidas (alta importancia, baja satisfacción).
- JTBD evita el sesgo de demografía: dos personas distintas pueden contratar lo
  mismo para el mismo job.

## 3. Visión y principios de experiencia

- **Experience vision**: enunciado aspiracional de cómo se sentirá usar el
  producto cuando esté maduro (north star cualitativo).
- **Principios de experiencia**: 3–7 reglas que guían decisiones de diseño y
  resuelven conflictos (p. ej. "claridad sobre densidad", "confianza primero",
  "rápido por defecto, profundo bajo demanda"). Deben ser *decidibles*: si dos
  opciones no se distinguen al aplicarlos, no sirven.
- **Value proposition alignment**: la experiencia debe materializar la
  propuesta de valor; mapea cada promesa a un momento concreto del journey.

## 4. Oportunidad y priorización

- **Opportunity Solution Tree** (Teresa Torres): outcome → oportunidades
  (necesidades/dolores) → soluciones → experimentos.
- Priorización (elige según contexto, declara el criterio):
  - **RICE** (Reach × Impact × Confidence / Effort).
  - **Impacto × Esfuerzo** (matriz 2×2) para quick wins.
  - **Kano** (básico, lineal, deleite) para balancear must-haves y delighters.
  - **MoSCoW** para alcance de release.
  - **Weighted Scoring** cuando hay múltiples criterios ponderados.
- Prioriza por **impacto en el usuario y en la métrica de éxito**, no por
  facilidad de implementación ni por preferencia interna (evita HiPPO).

## 5. Criterios de éxito y métricas

- Define métrica de éxito **antes** de diseñar. Vincula a un marco:
  - **North Star Metric** + métricas de entrada (input metrics).
  - **HEART** (Happiness, Engagement, Adoption, Retention, Task success) con
    Goals→Signals→Metrics (ver [metricas-validacion.md](metricas-validacion.md)).
  - **AARRR** (pirata) para producto de crecimiento.
- Toda iniciativa declara: métrica objetivo, baseline, meta, y cómo se medirá.

## 6. Madurez y gobierno de UX

- **Modelos de madurez** (NN/g 6 niveles; Design Maturity): ubica a la
  organización (ausente → limitada → emergente → estructurada → integrada →
  centrada en el usuario) y propón el siguiente paso realista.
- **UX governance**: quién decide, cómo se mantiene la consistencia, cómo se
  prioriza el research, cómo se gobierna el design system (ver
  [design-systems.md](design-systems.md)).
- **DesignOps**: estandariza procesos, herramientas, handoff y rituales para
  escalar la práctica sin perder calidad (ver **§6 bis** para el detalle).

## 6 bis. DesignOps en profundidad

Para operar al nivel de los mejores equipos, DesignOps convierte el diseño en una
práctica **escalable, medible y de baja fricción**:

- **Topología del equipo de diseño**: embebido (por squad), centralizado
  (agencia interna) o híbrido/federado (centro de excelencia + embebidos); elige
  según madurez y tamaño, y define cómo se mantiene la consistencia entre modos.
- **Intake y triage**: una puerta de entrada clara para las solicitudes de
  diseño, con criterios de priorización (enlaza §4) y expectativas de tiempo; evita
  el trabajo "por pasillo".
- **Workflow diseño→desarrollo**: definición de "listo para diseñar" (DoR) y
  "listo para construir" (handoff §2.1 de
  [interoperabilidad-y-aliadas.md](interoperabilidad-y-aliadas.md)); dueño de la
  fidelidad diseño↔código con `farola`/`palma`.
- **Tooling y fuentes de verdad**: un único sistema de archivos/tokens/librería;
  evita divergencia entre herramienta de diseño y código (gobierno en
  [design-systems.md](design-systems.md)).
- **Deuda de diseño**: hazla visible y priorizable como la deuda técnica
  (inconsistencias, patrones huérfanos, componentes duplicados); asigna dueño y
  cadencia de pago.
- **Rituales y métricas de la práctica**: critiques, design reviews, oficina de
  horas; mide throughput, tiempo de ciclo y satisfacción del **equipo de diseño**
  — sin invadir la gestión de entrega, que es de `orquesta` (flujo), ni la
  priorización de valor/producto, que es de `tompo`.

## 7. Estrategia según estado del producto

- **Greenfield**: invierte en framing, JTBD, IA y principios; previene deuda de
  UX; define el sistema desde el inicio.
- **En construcción**: alinea lo ya decidido con la visión; corrige rumbo barato
  mientras el costo del cambio es bajo.
- **Brownfield**: empieza por diagnóstico y benchmark; prioriza quick wins de
  bajo riesgo; planifica mejora por fases respetando modelos mentales actuales.

## 8. Entregables de estrategia

- Problem statement + HMW.
- Mapa de JTBD / outcomes priorizados.
- Experience vision + principios de experiencia.
- Opportunity Solution Tree.
- Matriz de priorización con criterio explícito.
- Definición de métricas de éxito (HEART/North Star) con baseline y meta.

> Cierre obligatorio: cada estrategia termina con próximos pasos y criterios de
> éxito medibles.
