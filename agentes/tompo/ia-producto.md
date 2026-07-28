# ia-producto.md — Product ownership de features de IA/LLM

> **Para qué sirve.** Cómo ejerce tompo (Product Owner) el ownership de **valor**
> de un feature de IA/LLM: definir el valor y el **riesgo aceptable**, usar
> **evals como criterios de aceptación**, exigir **human-in-the-loop** en acciones
> de alto riesgo, y colaborar con el equipo de IA. La IA cambia el rol del PO: la
> **evaluación** pasa a ser una competencia central.
>
> **Frontera de rol (CRÍTICA).** tompo decide **qué** feature de IA aporta valor,
> **por qué** y el **riesgo de negocio aceptable**, e incorpora evals, seguridad y
> gobernanza como **criterios**. tompo **NO construye ni opera la IA**:
> **sysuniversal-ai CONSTRUYE/opera** (modelos, prompts, RAG, serving, evals
> técnicas), **vector ASEGURA** (prompt injection, excessive agency,
> red-teaming), **sello GOBIERNA** (ISO 42001, privacidad, riesgo). tompo
> **firma el go/no-go de valor**. RACI completa en
> [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md).

---

## 0. Por qué la IA cambia el rol del PO

El software clásico es **determinista**: misma entrada → misma salida; se prueba con
asserts exactos. Un LLM produce una **distribución de outputs**: la misma entrada
puede dar respuestas distintas, y un **prompt afinado para un modelo se degrada al
cambiar de modelo o versión**. Esto rompe el modelo mental tradicional de "criterio
de aceptación = condición exacta".

Consecuencias para tompo:

1. **El reto central es el NO-DETERMINISMO.** No se acepta "funciona" con un par de
   ejemplos (*vibe check*); se acepta contra una **distribución medida** de calidad.
2. **La EVALUACIÓN es competencia central del PO.** Definir **cómo se mide que el
   output es bueno** (la rúbrica de calidad de negocio) es trabajo del PO, igual que
   antes lo eran los criterios de aceptación. El "AI Product Owner" es dueño de la
   definición de calidad, no de la implementación del eval.
3. **El criterio de aceptación se vuelve estadístico:** "≥ X% de los casos de la
   suite de eval pasan la rúbrica", no "este caso pasa".

Fuente: Reforge, "How AI changes product management",
https://www.reforge.com/blog/how-ai-changes-product-management .

---

## 1. Evals de producto — el nuevo criterio de aceptación

Las **evals** son el equivalente a las **pruebas de regresión** para features de IA:
detectan cuándo un cambio de prompt, modelo o dato **empeora** la calidad. tompo es
**A del significado de negocio** de la rúbrica; **sysuniversal-ai/amado** son A de su
**implementación técnica**.

### 1.1 Empezar por ERROR ANALYSIS (Hamel Husain)
El punto de partida **no** es elegir métricas genéricas, sino **mirar datos reales**:
recolectar outputs, leerlos, etiquetar los fallos y **descubrir los modos de error
que importan al negocio**. De ahí salen las métricas que valen.

### 1.2 Tres niveles de eval

| Nivel | Qué evalúa | Cuándo lo usa el PO |
|---|---|---|
| **Code / unit (deterministas)** | Aserciones programáticas: formato JSON válido, longitud, ausencia de PII, *no* contiene términos prohibidos | Barato y rápido; primer filtro de la suite |
| **LLM-as-judge** | Un modelo evalúa la calidad según una rúbrica; **Critique Shadowing** alinea al juez con el criterio humano usando **100+ ejemplos etiquetados** por un experto de dominio | Calidad subjetiva (tono, relevancia, fidelidad); el PO **define la rúbrica** |
| **A/B online** | Métricas reales de negocio en producción (conversión, resolución, satisfacción) | Validación final del **outcome**, no solo de la salida |

> Regla del PO: una eval LLM-as-judge **no es confiable sin alinear el juez** contra
> juicio humano (Critique Shadowing, 100+ ejemplos). Sin eso, es otro vibe check.

Fuentes: Hamel Husain, "Your AI Product Needs Evals",
https://hamel.dev/blog/posts/evals/ ; Lenny's Newsletter, "Beyond vibe checks: a
PM's complete guide to evals",
https://www.lennysnewsletter.com/p/beyond-vibe-checks-a-pms-complete .

### 1.3 Las evals como gate de regresión
Toda la suite corre **antes de cada cambio** de prompt/modelo/RAG. Si la calidad cae
bajo el umbral, **no se libera**. tompo exige este gate como parte de la DoD del
feature de IA (lo opera sysuniversal-ai/amado en CI).

---

## 2. Riesgos de IA que el PO debe conocer — OWASP LLM Top 10 (2025)

tompo **no diseña los controles** (eso es vector), pero **conoce los riesgos**
para exigirlos como criterio y priorizarlos.

| Riesgo OWASP LLM | Qué es | Qué exige tompo como criterio |
|---|---|---|
| **LLM01 — Prompt Injection (#1)** | Entradas (directas o vía contenido externo/RAG) que secuestran el comportamiento del modelo | Validación de entrada/salida y límites de acción; el feature **no confía solo en el prompt** |
| **LLM06 — Excessive Agency** | El agente tiene más permisos/herramientas de los necesarios y actúa de más | **Mínimo privilegio** + **human-in-the-loop** para acciones de alto impacto |
| **LLM09 — Misinformation / alucinaciones** | El modelo inventa hechos con confianza | Umbral de fidelidad en evals; *grounding*/citas; aviso de incertidumbre al usuario |
| **Fuga de datos / system prompt leakage** | Exposición de datos sensibles o del prompt de sistema en la salida | Criterio: la salida **no** revela PII/secretos/instrucciones internas |

*Postura PO:* estos riesgos entran como **criterios de aceptación de negocio y de
seguridad** desde discovery; el aseguramiento técnico es de **vector**.

Fuente: OWASP GenAI / LLM Top 10 (2025), https://genai.owasp.org/llm-top-10/ .

---

## 3. Gobernanza de IA — NIST AI RMF y EU AI Act

### 3.1 NIST AI Risk Management Framework + GenAI Profile
Marco **voluntario** y agnóstico para gestionar el riesgo de IA, en cuatro funciones
que el PO puede usar como lente de discovery:

| Función NIST | Pregunta que se hace el PO |
|---|---|
| **GOVERN** | ¿Quién es accountable del riesgo? ¿Hay políticas y roles (grc)? |
| **MAP** | ¿En qué contexto se usa? ¿Quiénes son los afectados y qué puede salir mal? |
| **MEASURE** | ¿Cómo mido la calidad, el sesgo y el riesgo (evals, métricas)? |
| **MANAGE** | ¿Cómo priorizo, mitigo y monitoreo los riesgos en el tiempo? |

Fuente: NIST AI RMF, https://www.nist.gov/itl/ai-risk-management-framework .

### 3.2 EU AI Act — calendario y obligaciones (parcialmente [NO FINAL])
Regulación de IA basada en **riesgo**. Hitos relevantes para el PO:

- **Desde 2-feb-2025:** **prohibiciones** de prácticas inaceptables (p. ej. *social
  scoring*, manipulación) + obligación de **alfabetización en IA** (AI literacy) del
  personal que la usa/despliega.
- **Desde 2-ago-2025:** obligaciones para modelos de **propósito general (GPAI)**.
- **Sistemas de alto riesgo (Anexo III):** gestión de riesgos, **supervisión
  humana**, calidad de datos, **transparencia**. Para el PO, dos obligaciones de
  producto muy concretas (Art. 50):
  - **Avisar al usuario que interactúa con una IA** (no hacerla pasar por humano).
  - **Etiquetar el contenido sintético** (texto/imagen/audio/video generado).
- **[NO FINAL]:** se discute un **posible aplazamiento** de partes del Anexo III
  (alto riesgo). Tratar fechas de alto riesgo como **dirección sujeta a cambio**.

*Criterio PO:* si el feature es alto riesgo, "supervisión humana", "aviso de
interacción con IA" y "etiquetado de contenido sintético" son **criterios de
aceptación**. El cumplimiento legal lo gobierna **sello + legal**.

Fuente: artificialintelligenceact.eu, "High-level summary",
https://artificialintelligenceact.eu/high-level-summary/ .

---

## 4. IA responsable — principios que el PO incorpora

No son ley, pero son el **estándar de la industria** y reducen riesgo de marca y de
negocio. tompo los traduce a criterios:

- **Microsoft — 6 principios:** equidad, fiabilidad y seguridad, privacidad y
  seguridad, **inclusión**, **transparencia**, **responsabilidad (accountability)**.
- **Google — Responsible AI / Secure AI Framework (SAIF).**
- **Anthropic — Responsible Scaling Policy (RSP):** evaluar capacidades y riesgos y
  escalar salvaguardas según el nivel de riesgo del modelo.

*Uso PO:* elegir 2-3 principios aplicables al feature y volverlos **guardrails
medibles** (p. ej. "tasa de paridad de calidad entre segmentos" para equidad).

Fuentes: Microsoft Responsible AI,
https://www.microsoft.com/ai/responsible-ai ; Google,
https://ai.google/responsibility/ ; Anthropic RSP,
https://www.anthropic.com/rsp .

---

## 5. Cómo el PO define VALOR y RIESGO ACEPTABLE de un feature de IA

1. **Empieza por el JTBD, no por "metamos IA".** La IA es un medio; el outcome es el
   trabajo del usuario resuelto mejor/más barato/más rápido. Rechaza la "IA por
   moda" sin outcome medible.
2. **Define el peor caso tolerable.** ¿Qué pasa si el modelo se equivoca? Clasifica:
   - *Bajo riesgo* (sugerir, borrador, el humano revisa) → más autonomía del modelo.
   - *Alto riesgo* (decide, ejecuta, irreversible, afecta dinero/salud/derechos) →
     **human-in-the-loop obligatorio** y umbral de eval más exigente.
3. **Fija el umbral de calidad de negocio** (p. ej. "≥ 90% de fidelidad en la suite,
   0 fugas de PII") como criterio de aceptación, basado en error analysis real.
4. **Declara el riesgo de negocio aceptado** y firma el **go/no-go de valor**; el
   sign-off de seguridad (vector) y gobernanza (sello) son gates separados.

### 5.1 Human-in-the-loop por nivel de riesgo de la acción

| Riesgo de la acción del agente | Patrón exigido por tompo |
|---|---|
| Informativa / sugerencia (reversible) | El humano puede ignorar; revisión opcional; *autonomía* del modelo |
| Modifica datos / envía comunicación | **Revisión/confirmación humana** antes de ejecutar |
| Irreversible / financiera / legal / salud | **Human-in-the-loop obligatorio**, doble control, *kill switch*, trazabilidad |

Alineado con OWASP **LLM06 (Excessive Agency)** y la **supervisión humana** del EU AI
Act.

---

## 6. Colaboración — quién hace qué en un feature de IA

| Rol | Responsabilidad | Relación con tompo |
|---|---|---|
| **tompo (PO)** | **Decide valor y riesgo de negocio**; define rúbrica de calidad y criterios; go/no-go de valor | **A** del valor; **C** en lo técnico |
| **sysuniversal-ai** | **Construye y opera** el modelo/prompt/RAG/serving; implementa y corre las **evals técnicas**; monitorea drift/retraining | A del lifecycle técnico de la IA |
| **vector** | **Asegura**: prompt injection, excessive agency, fuga de datos, red-teaming, guardrails, evals de **seguridad** | A/C — **gate obligatorio** |
| **sello** | **Gobierna**: ISO/IEC 42001, privacidad, riesgo, EU AI Act/NIST, alfabetización | A/C de cumplimiento/riesgo |
| **andulfo/caudal/brujula/prisma** | Datos de entrenamiento/RAG, calidad, linaje, privacidad técnica de datos | C — factibilidad de datos |
| **amado** | Integra las evals como **gate de regresión** en CI; calidad liberable (DoD) | A de calidad |
| **eneida** | Arquitectura del sistema de IA (orquestación, aislamiento de herramientas) | A de arquitectura |

> Frontera: **sysuniversal-ai CONSTRUYE/opera, vector ASEGURA, sello
> GOBIERNA, tompo decide VALOR/NEGOCIO.** tompo no implementa prompts, guardrails ni
> pipelines. Detalle y RACI en
> [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md). Privacidad y
> cumplimiento general en [cumplimiento-regulacion.md](cumplimiento-regulacion.md).

---

## 7. Checklist — "feature de IA listo para producción" (óptica del PO)

```
VALOR Y RIESGO
- [ ] ¿Hay un JTBD/outcome medible? ¿La IA es el mejor medio (no IA por moda)?
- [ ] ¿Definí el peor caso tolerable y clasifiqué el riesgo de cada acción?
- [ ] ¿Declaré el riesgo de negocio aceptado y el go/no-go de valor?

EVALS (criterio de aceptación)
- [ ] ¿Hice error analysis sobre outputs reales para descubrir los modos de fallo?
- [ ] ¿Definí la rúbrica de calidad de negocio (yo soy A del significado)?
- [ ] ¿Hay evals en tres niveles (code/unit, LLM-as-judge alineado, A/B online)?
- [ ] ¿El juez LLM está alineado a juicio humano (Critique Shadowing, 100+ ejemplos)?
- [ ] ¿Las evals corren como gate de regresión antes de cada cambio de prompt/modelo?
- [ ] ¿Fijé umbrales (% que pasa, 0 fugas de PII) como criterio testeable?

SEGURIDAD Y GOBERNANZA (gates de otros, exigidos por mí)
- [ ] ¿Cubrí OWASP LLM01 (prompt injection) y LLM06 (excessive agency) como criterio?
- [ ] ¿Hay human-in-the-loop en acciones de alto riesgo/irreversibles?
- [ ] ¿Tengo sign-off de vector (seguridad) y sello (gobernanza/42001)?
- [ ] ¿Cumplo EU AI Act donde aplica (aviso de IA, etiquetar contenido sintético, supervisión humana)?
- [ ] ¿Marqué como NO FINAL lo no vigente (posible aplazamiento Anexo III)?

OPERACIÓN Y APRENDIZAJE
- [ ] ¿Hay plan de monitoreo en producción (drift, calidad, costo, incidentes) con sysuniversal-ai?
- [ ] ¿Definí métricas de outcome y guardrails (no solo métricas de modelo)?
```

---

## 8. Recordatorio de frontera de rol

tompo es **A del valor y del riesgo de negocio** de la IA y **A del significado de
negocio** de la rúbrica de calidad. Es **C** en todo lo técnico: no construye
prompts, no opera modelos, no diseña guardrails, no certifica cumplimiento.
**sysuniversal-ai construye/opera, vector asegura, sello gobierna,
amado da el gate de calidad, eneida la arquitectura.** tompo incorpora evals,
seguridad y gobernanza como **criterios de aceptación y de priorización** desde la
discovery, y firma el **go/no-go de valor**. Ver
[gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md) y
[cumplimiento-regulacion.md](cumplimiento-regulacion.md).
