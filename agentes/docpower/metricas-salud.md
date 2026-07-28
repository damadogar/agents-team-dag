# metricas-salud.md — Métricas de salud documental y madurez

> Cómo docpower **sabe si la documentación funciona** (modo D/E) y cómo evalúa la
> madurez de un sistema documental. Sin métricas, "mejorar la documentación" es una
> opinión. Mide para priorizar deuda y demostrar valor.

---

## 1. Principio

La documentación es un **activo operativo**: se mide por su efecto en el lector
(¿logró su tarea?, ¿encontró la respuesta?, ¿confió en ella?), no por cantidad de
páginas. Combina métricas de **contenido** (estado del sistema) con métricas de
**comportamiento** (qué hace el lector).

---

## 2. Métricas de contenido (estado del sistema)

| Métrica | Qué mide | Señal de alarma |
|---|---|---|
| **Cobertura** | % de features/APIs/procesos con doc | Áreas críticas sin documentar |
| **Frescura (freshness)** | Antigüedad desde la última revisión válida | Docs vencidas vs su cadencia |
| **Broken links** | Enlaces rotos internos/externos | Cualquier enlace roto en doc publicada |
| **Huérfanos** | Documentos sin hub/enlace que los alcance | Islas invisibles |
| **Duplicación** | Contenido repetido en varias fuentes | Múltiples "verdades" divergentes |
| **Accesibilidad** | Imágenes sin alt, jerarquía de headings, contraste | Fallos WCAG en docs |
| **Cobertura de traducción** | % traducido y desfase vs origen | Idiomas rezagados |
| **Ejemplos que fallan** | Code samples que no pasan docs-as-tests | Cualquier ejemplo roto |

---

## 3. Métricas de comportamiento (qué hace el lector)

| Métrica | Qué mide | Uso |
|---|---|---|
| **Search success rate** | % de búsquedas que llevan a un click útil | Detecta gaps de contenido y de naming |
| **Búsquedas sin resultado** | Términos buscados sin match | Lista priorizada de qué falta o cómo lo llaman |
| **Time-to-answer** | Cuánto tarda el lector en encontrar la respuesta | Findability y arquitectura |
| **Task completion support** | ¿La doc permitió completar la tarea? (feedback, encuesta) | Utilidad real |
| **Support deflection** | Tickets evitados porque la doc resolvió | Valor de negocio de la doc |
| **Páginas más/menos vistas** | Demanda real | Dónde invertir; qué archivar |
| **Feedback "¿te sirvió?"** | Señal cualitativa por página | Triage de mejoras |
| **Contribution velocity** | Frecuencia de aportes/actualizaciones | Salud del proceso docs-as-code |

> No caigas en *vanity metrics*: "número de páginas" o "visitas totales" no dicen si
> la documentación **sirve**. Prioriza señales de que el lector **logró su tarea**.

---

## 4. Deflection y valor de negocio

- **Deflection de soporte** = tickets/consultas que la documentación evita. Es la
  traducción más directa de documentación → ahorro.
- Correlaciona **gaps de contenido** con **volumen de tickets por tema**: documenta
  primero lo que más se pregunta.
- Onboarding: **time-to-first-contribution / time-to-productive** como métrica de
  impacto de la documentación de enablement.

---

## 5. Modelo de madurez documental

Para auditar **dónde está** una organización y trazar el camino:

| Nivel | Nombre | Características |
|---|---|---|
| **0** | Ausente / tribal | Sin docs; el conocimiento vive en cabezas y chats |
| **1** | Ad hoc | Docs sueltas, sin estándar, sin dueño, se desactualizan |
| **2** | Estructurado | Estándar editorial, taxonomía, ownership básico, hub de entrada |
| **3** | Docs-as-code | Versionado, review en PR, CI (lint/links), DoD documental |
| **4** | Gobernado y medido | Lifecycle, métricas de salud, deuda gestionada, i18n/a11y |
| **5** | Optimizado / estratégico | Docs-as-tests, deflection medida, mejora continua, listo para IA/RAG |

Diagnóstico = ubicar el nivel actual por dimensión (contenido, proceso, gobernanza,
findability, accesibilidad/i18n) y recomendar el **siguiente salto**, no saltar a 5.

---

## 6. Auditoría de documentación (cómo se hace)

1. **Content inventory**: lista todo (URL, tipo, dueño, estado, última revisión,
   tráfico).
2. **Evalúa cada ítem**: veraz, vigente, encontrable, accesible, del tipo correcto.
3. **Cruza con demanda** (tráfico, búsquedas, tickets) para priorizar.
4. **Clasifica acción**: mantener / actualizar / fusionar / reescribir / deprecar.
5. **Plan de remediación** priorizado por **riesgo × uso**, con dueño y fecha.

Plantilla de auditoría e inventario en [plantillas.md](plantillas.md); checklist en
[checklists.md](checklists.md); caso resuelto en [ejemplos.md](ejemplos.md).

---

## 7. Dashboard de salud (qué mostrar)

- Semáforo de **frescura** (verde/ámbar/rojo por cadencia de revisión).
- **Cobertura** por área/producto y gaps priorizados.
- **Broken links / huérfanos / ejemplos fallidos** (deben tender a cero).
- **Search success** y top de búsquedas sin resultado (backlog de contenido).
- **Deflection** y correlación con tickets.
- Nivel de **madurez** por dimensión y objetivo del próximo trimestre.

> **Frontera de datos:** la **implementación técnica** de la analítica (instrumentar
> el sitio, pipelines, dashboards) es de **andulfo/brujula**; docpower define
> **qué métricas importan y cómo se leen** para la salud documental, y consume los
> datos. Una métrica, una definición (ver [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)).

---

## 8. Antipatrones de medición (prohibidos)

- Medir cantidad (páginas, palabras, visitas) en vez de utilidad y logro de tarea.
- Auditar sin cruzar con **demanda real** (mejoras la doc que nadie lee).
- "Mejorar docs" sin línea base ni objetivo medible.
- Ignorar las **búsquedas sin resultado** (son el mapa de lo que falta).
- Dashboards que nadie usa para priorizar: la métrica existe para **decidir**.
