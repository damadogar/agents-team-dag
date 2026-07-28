# Liderazgo, Producto y Gestión de Equipos

Base de Eneida (Primer Maestro) para el **Modo D (Liderazgo/Gobernanza)**. Lidera
con criterio técnico + visión de producto + cuidado de las personas.

> Para el **alcance estricto de Eneida** (qué decide vs qué delega), el **RACI de
> arquitectura**, el **protocolo de handoff** y los **foros de gobernanza**, ver
> [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md). Este archivo cubre
> el modelo de roles, producto y cadencia; aquel cubre cómo el arquitecto colabora
> sin invadir ownership.

---

## 1. Roles y responsabilidades (quién decide qué)

| Rol | Pregunta que responde | Es dueño de | No es dueño de |
|-----|----------------------|-------------|----------------|
| **Product Owner (PO)** | ¿Qué y por qué? | Visión de producto, backlog, prioridad, valor, aceptación | Cómo técnico, estimaciones del equipo |
| **Business Analyst (BA)** | ¿Cuál es el problema/requisito? | Discovery funcional, requisitos, reglas de negocio, AC | Decisiones técnicas/arquitectura |
| **Product Manager (PM)** | ¿Para quién y qué mercado? | Estrategia, discovery, métricas de producto, roadmap | Implementación |
| **Delivery Manager / Orquestador** (en este equipo `orquesta`) | ¿Cuándo, con qué capacidad y riesgo? | Cronograma, capacidad, seguimiento operativo, coordinación de delivery | Decisiones técnicas/diseño |
| **Project Manager** | ¿Cuándo y con qué riesgo? | Alcance, cronograma, riesgos, stakeholders, presupuesto | Decisiones técnicas/diseño |
| **Tech Lead / Arquitecto (Eneida)** | ¿Cómo técnico? | Arquitectura, estándares, contratos, deuda técnica, calidad | Prioridad de negocio, alcance/fecha, operación diaria |
| **Engineering Manager (EM)** | ¿Quién y cómo crece? | Personas, carrera, desempeño, salud del equipo | Detalle de implementación diaria |
| **QA / Quality** | ¿Cumple calidad? | Estrategia de pruebas, automatización, criterios de calidad | Decisión de release de negocio |
| **DevOps / Platform** | ¿Cómo se entrega y opera? | CI/CD, plataforma interna, IaC, fiabilidad operativa | Lógica de dominio |
| **Security** | ¿Es seguro y conforme? | AppSec, cumplimiento, gestión de riesgo, respuesta a incidentes | Decisiones de producto |
| **Data / AI** | ¿Cómo usamos datos/IA? | Modelos de datos, pipelines, gobernanza y evals de IA/LLM | Infraestructura de red |

> En equipos pequeños un rol puede combinar varios. Lo importante es que cada
> **decisión tenga un único dueño claro** y un mecanismo de desempate. Para
> repartir responsabilidades en decisiones concretas, usa una matriz **RACI**
> (Responsable, Aprobador, Consultado, Informado).

### Modelo operativo (cómo encajan los roles)
- **Flujo de valor** → equipos stream-aligned (PO + devs + QA embebido) sobre
  bounded contexts; **Platform/DevOps** y **Security** como equipos habilitadores
  que reducen carga cognitiva (ver Team Topologies, §4).
- **Data/AI** como capacidad transversal con gobernanza (ver
  `genai-arquitectura.md`).
- Define un **modelo de gobernanza** ligero: foros de arquitectura (ADRs),
  estándares compartidos y autonomía con barandas (paved paths).

---

## 2. Marco de producto (discovery → delivery)

- **Discovery**: problema antes que solución. Entrevistas, datos, hipótesis.
- **Priorización**: usa un marco explícito — **RICE** (Reach, Impact,
  Confidence, Effort), **WSJF** (Weighted Shortest Job First) o **MoSCoW**.
- **Outcome > Output**: mide resultados (métricas de negocio/usuario), no solo
  features entregadas.
- **North Star Metric** + métricas de soporte (AARRR: Adquisición, Activación,
  Retención, Revenue, Referral).

---

## 3. Definition of Ready / Definition of Done

**Definition of Ready (una historia puede empezar si):**
- Valor y objetivo claros · Criterios de aceptación (Gherkin) ·
  Dependencias identificadas · Estimada · Sin bloqueos abiertos.

**Definition of Done (una historia está terminada si):**
- Código revisado y mergeado · Pruebas (unit/integración) verdes ·
  AC verificados · Observabilidad añadida · Documentación/ADR si aplica ·
  Desplegable y desplegado en el entorno objetivo · Sin deuda crítica nueva.

---

## 4. Diseño de equipos (Team Topologies aplicado)

- Forma equipos **stream-aligned** alrededor de flujos de valor / bounded
  contexts, no de capas técnicas.
- Crea **platform teams** para reducir carga cognitiva de los demás.
- Usa **enabling teams** para subir capacidades (coaching temporal).
- Minimiza dependencias inter-equipo; haz explícitos los **modos de
  interacción**.
- Aplica el **maniobra inversa de Conway**: organiza equipos para producir la
  arquitectura deseada.

---

## 5. Liderazgo técnico (cómo lidero)

- **Liderazgo servicial**: quita obstáculos, da contexto, no microgestiones.
- **Seguridad psicológica**: que el equipo pueda discrepar, preguntar y fallar
  sin castigo (postmortems blameless).
- **Decide con datos**: DORA para entrega; métricas de producto para valor;
  encuestas de salud para el equipo.
- **Mentoría**: explica el *porqué* de cada decisión; eleva el nivel del equipo
  (eres el "primer maestro").
- **Gestión de deuda técnica**: hazla visible, presupuéstala (p. ej. % de
  capacidad por sprint), prioriza por interés compuesto.
- **Comunicación**: una sola fuente de verdad; decisiones en ADR; estado en
  tableros, no en la memoria.

---

## 6. Ritmo operativo (cadencia)

| Ritual | Frecuencia | Propósito |
|--------|-----------|-----------|
| Planning | Por sprint | Comprometer alcance realista |
| Daily / sync | Diario | Desbloquear, no reportar estado |
| Review/Demo | Por sprint | Mostrar valor a stakeholders |
| Retrospectiva | Por sprint | Mejorar el proceso (1-2 acciones) |
| Refinamiento | Continuo | Mantener backlog "Ready" |
| Revisión de arquitectura | Mensual/trimestral | Deuda, riesgos, evolución |

---

## 7. Gestión de riesgos

Matriz **Impacto × Probabilidad**. Para cada riesgo: descripción, dueño,
mitigación, plan de contingencia y disparador. Revisa riesgos en cada hito.
Prioriza riesgos irreversibles y de seguridad.

---

## 8. Referencias

- Team Topologies: https://teamtopologies.com/
- Accelerate / DORA (Forsgren, Humble, Kim): https://dora.dev/
- Inspired / Empowered (Marty Cagan, SVPG): https://www.svpg.com/
- Google re:Work (seguridad psicológica, equipos): https://rework.withgoogle.com/
- The Manager's Path (Camille Fournier).
