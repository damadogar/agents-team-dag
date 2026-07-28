# UX Research

Toda recomendación se apoya en evidencia, en patrones de comportamiento o en una
hipótesis explícita. El research reduce el riesgo de diseñar para suposiciones.

## 1. Marco de decisión de métodos

Cruza dos ejes (NN/g):

- **Actitudinal** (lo que dicen) vs **conductual** (lo que hacen).
- **Cualitativo** (por qué/cómo, n pequeño) vs **cuantitativo** (cuánto/cuántos,
  n grande).

| Pregunta | Método recomendado |
|----------|--------------------|
| ¿Por qué ocurre esta fricción? | Entrevistas, usability testing, contextual inquiry |
| ¿Cuántos se ven afectados? | Analítica, encuestas, A/B testing |
| ¿Cómo organizan la información? | Card sorting, tree testing |
| ¿La interfaz cumple heurísticas? | Evaluación heurística, cognitive walkthrough |
| ¿Qué hacen en su contexto real? | Diary studies, field/contextual inquiry |
| ¿Qué prefieren entre opciones? | Preference testing, desirability (Microsoft reaction cards) |

Triangula: combina ≥2 métodos cuando la decisión es de alto impacto.

## 2. Métodos cualitativos

- **Entrevistas en profundidad**: preguntas abiertas, no inductivas; explora el
  "por qué"; evita preguntar por soluciones, pregunta por experiencias y
  problemas pasados.
- **Contextual inquiry / field studies**: observa al usuario en su entorno real;
  revela workarounds y restricciones invisibles en lab.
- **Diary studies**: captura experiencias longitudinales (días/semanas) en
  contexto; útil para hábitos y journeys largos.
- **Usability testing** (moderado o no moderado): tareas reales; mide éxito,
  tiempo, errores y observa comportamiento. 5 usuarios detectan ~85% de
  problemas de usabilidad por iteración (regla de Nielsen para descubrimiento).
- **Think-aloud**: el usuario verbaliza su razonamiento mientras realiza tareas.

## 3. Métodos cuantitativos

- **Encuestas**: muestreo y redacción sin sesgo; escalas validadas (SUS, UMUX-Lite,
  SEQ, NPS con cautela). Evita preguntas dobles y de respuesta inducida.
- **Analítica de comportamiento**: embudos, retención, mapas de calor,
  grabaciones de sesión; identifica *dónde* falla, el cualitativo explica *por
  qué*.
- **A/B y multivariante**: valida cambios con significancia estadística; define
  hipótesis, métrica primaria y tamaño de muestra antes de lanzar.
- **Análisis de tareas a escala**: tiempo en tarea, tasa de éxito, tasa de error.

## 4. Arquitectura de información: validación

- **Card sorting** (abierto/cerrado/híbrido): descubre cómo agrupan y nombran
  los usuarios → insumo para taxonomía.
- **Tree testing**: valida si la estructura permite encontrar contenido (sin UI),
  mide éxito, directness y tiempo.
- **First-click testing**: el primer clic predice fuertemente el éxito de la tarea.

## 5. Evaluación experta (sin usuarios)

- **Evaluación heurística** (10 de Nielsen) con escala de severidad 0–4 (ver
  [metricas-validacion.md](metricas-validacion.md)).
- **Cognitive walkthrough**: recorre tareas con foco en aprendibilidad ("¿el
  usuario sabrá qué hacer y notará que funcionó?").
- **Benchmarking competitivo**: compara patrones, flujos y métricas contra
  referentes; evita copiar sin entender el porqué.

## 5 bis. Prototipado para aprender (fidelidad según la pregunta)

El prototipo es un **instrumento de aprendizaje**, no un entregable bonito: elige
la mínima fidelidad que responda la pregunta de research abierta.

| Pregunta a responder | Fidelidad / técnica |
|----------------------|---------------------|
| ¿La estructura/flujo tiene sentido? | Papel, lo-fi, wireflow clicable |
| ¿El concepto tiene demanda? | **Fake-door** / smoke test (mide intención real) |
| ¿La interacción se siente bien? | Hi-fi interactivo (Figma/prototipo de código), motion real |
| ¿Funciona algo que aún no existe? | **Wizard of Oz** (humano simula el sistema) |
| ¿El contenido comunica? | **Prototipo de contenido** (textos reales, sin estética final) |

- **Regla de fidelidad**: sube fidelidad solo cuando la pregunta lo exige; la
  alta fidelidad prematura sesga el feedback hacia lo estético y encarece el
  cambio.
- **Datos realistas**: prototipa con contenido y casos límite reales (0, 1,
  muchos, textos largos), no "lorem ipsum" feliz.
- **Prototipo desechable vs. evolutivo**: declara cuál es; no dejes que un
  throwaway se convierta en la base de producción por inercia.

## 6. Síntesis e insights

- **Affinity mapping**: agrupa observaciones en temas; del dato al patrón.
- **Insight accionable** = observación + interpretación + implicación de diseño.
  No es un dato suelto ni una opinión.
- **Artefactos de síntesis**: personas (basadas en datos, no demográficas a
  secas), empathy maps, journey maps (ver
  [service-design-mapping.md](service-design-mapping.md)), JTBD.
- Conecta cada hallazgo con una recomendación priorizada por severidad e impacto.

## 7. Rigor y sesgos

- Evita sesgos: confirmación, preguntas inductivas, deseabilidad social, selección,
  efecto del moderador, sesgo de supervivencia.
- Distingue **señal** de **ruido**; declara tamaño de muestra y límites de
  validez. El research cualitativo informa, no "prueba" estadísticamente.
- Consentimiento, privacidad y manejo ético de datos (PII) son obligatorios.

## 8. ResearchOps

- Repositorio de insights buscable (no informes que mueren en un drive).
- Reclutamiento, incentivos, plantillas, calendario y gobernanza de research.
- **Continuous discovery**: cadencia regular de contacto con usuarios (Torres),
  no solo research de proyecto.

## 9. Entregables de research

- Plan de research (objetivo, preguntas, método, muestra, métrica).
- Guion de entrevista / protocolo de test.
- Reporte de hallazgos con severidad, evidencia y recomendaciones.
- Personas / journey / empathy map basados en evidencia.
- Repositorio de insights actualizado.

> Si no hay datos disponibles, declara **[HIPÓTESIS]** explícita y propón cómo
> validarla; nunca presentes una suposición como hecho.
