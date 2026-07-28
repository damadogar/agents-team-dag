# ia-y-documentacion.md — Documentación para (y con) IA

> Dos frentes: (A) documentación **legible por sistemas de IA/RAG y agentes**, y (B)
> uso de **IA para producir documentación** con verificación humana. Además (C)
> documentar **sistemas de IA**.
>
> **Frontera:** docpower optimiza la **documentación** para IA y usa IA como
> herramienta de autoría; **construir y operar** sistemas de IA/RAG es de
> **sysuniversal-ai** (SME), y la **seguridad de IA** de **vector**
> (ver [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)).

---

## PARTE A — Documentación legible por IA (docs-for-AI / RAG-ready)

## 1. Por qué importa

Hoy los lectores no son solo humanos: asistentes, agentes y buscadores con IA
consumen documentación para responder. Documentación bien estructurada es a la vez
**mejor para humanos y recuperable por IA**. Es un frente 2026-crítico y a menudo
descuidado.

## 2. Contenido estructurado para recuperación (RAG)

- **Encabezados semánticos y jerárquicos**: permiten *chunking* limpio (cada sección
  es autónoma y recuperable sin el resto).
- **Autocontenido por sección**: evita "como se dijo arriba"; cada chunk debe
  entenderse solo (define el término o enlázalo).
- **Un hecho, una fuente** (source of truth): la duplicación produce respuestas de IA
  contradictorias.
- **Metadata rica** (título, contexto, versión, fecha): mejora el ranking y evita que
  la IA cite contenido obsoleto.
- **Texto sobre imágenes**: lo que solo está en una imagen no lo recupera la IA (ni el
  lector con lector de pantalla — coincide con [accesibilidad-i18n.md](accesibilidad-i18n.md)).
- **Terminología estable**: sinónimos mapeados en glosario ayudan a la recuperación.

## 3. `llms.txt` y superficies para agentes

- **`llms.txt`**: archivo en la raíz que ofrece a los LLM un índice curado y en texto
  plano del contenido clave (y enlaces a versiones markdown limpias). Facilita que un
  asistente encuentre y use la documentación correcta.
- Versiones **markdown limpias** de las páginas (sin ruido de UI) para consumo por
  máquina.
- **Datos estructurados** (esquemas) donde aporten a la interpretación.

## 4. GEO (Generative Engine Optimization)

- Optimizar para que los **motores generativos** citen la documentación con
  precisión: respuestas directas, definiciones claras, estructura pregunta→respuesta
  donde encaje, autoridad y frescura visibles.
- No sacrifiques la calidad para humanos por "SEO/GEO": la buena estructura sirve a
  ambos. Evita el *keyword stuffing*.

---

## PARTE B — Autoría asistida por IA (con verificación)

## 5. Dónde ayuda la IA en documentación

- **Primer borrador** a partir de código/spec/notas del SME (acelera, no decide).
- **Reestructurar** contenido existente a Diátaxis / plain language.
- **Detectar inconsistencias**, gaps, terminología divergente, enlaces sospechosos.
- **Resumir** cambios (draft de release notes desde PRs) para revisión.
- **Traducción** de primer paso (siempre con revisión humana/lingüista).

## 6. Guardas no negociables

- **La IA no es fuente de verdad.** Todo hecho técnico se **verifica con el SME** o
  contra la fuente (código, spec, datos). docpower nunca publica una afirmación de IA
  sin validar (coincide con el principio "no inventes hechos", [ejecucion-autonoma.md](ejecucion-autonoma.md)).
- **Cita/traza** de dónde salió cada dato dudoso; marca lo no verificado como
  **[PENDIENTE]**.
- **Alucinaciones**: revisa especialmente números, nombres de API, comandos,
  parámetros y pasos (lo que más daño hace si es falso).
- **Sin secretos ni datos sensibles** en prompts.
- **Voz y estándar**: la IA respeta el usage guide/Vale; docpower edita la salida, no
  la publica cruda.

---

## PARTE C — Documentar sistemas de IA

## 7. Artefactos de documentación de IA

- **Model cards**: propósito del modelo, datos de entrenamiento (a alto nivel), uso
  previsto y **fuera de alcance**, limitaciones, métricas, consideraciones éticas.
- **System cards**: comportamiento del sistema completo, salvaguardas, riesgos.
- **Reportes de evals**: cómo se midió, resultados, criterios de aceptación.
- **Documentación de prompts/instrucciones** y su versionado.
- **Data sheets / datasheets for datasets**: origen, composición, sesgos conocidos.

## 8. Frontera en documentación de IA

- docpower da **forma, estructura y disciplina** a model cards, system cards y
  reportes de evals.
- El **contenido** (qué hace el modelo, sus evals, sus límites) es de
  **sysuniversal-ai**; el **riesgo/seguridad de IA** es de **vector**; el
  **valor/negocio** del feature de IA es de **tompo**. docpower **no evalúa** el
  modelo ni decide su riesgo aceptable: lo **documenta bien**.

---

## 9. Antipatrones (prohibidos)

- Publicar contenido generado por IA **sin verificar** hechos con el SME.
- Optimizar para IA/GEO sacrificando la claridad para humanos.
- Significado crítico solo en imágenes (invisible para IA y lectores de pantalla).
- Duplicar contenido y luego preguntarse por qué la IA da respuestas contradictorias.
- Que docpower **evalúe** o **certifique** un sistema de IA (eso es del SME de IA/seguridad).

> Estructura RAG-ready se apoya en [arquitectura-informacion.md](arquitectura-informacion.md);
> plantillas de model card y release notes en [plantillas.md](plantillas.md).
