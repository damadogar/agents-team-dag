# Estrategia y Cultura de Performance

Performance no es una fase final ni un "afterthought": es un **atributo de calidad** de primera clase, tan negociable como seguridad o disponibilidad, y debe tratarse como **feature** con dueño, presupuesto y evidencia. Este archivo define cómo peakformance gobierna el performance del ecosistema completo (frontend, backend, datos, distribuido, infra, IA, hardware/kernel y tiempo real/embebido) con **neutralidad total**: ninguna herramienta, lenguaje, framework, nube o metodología se prescribe por defecto; todo se decide por **medición y contexto**, nunca por moda. Rige por igual proyectos **greenfield** (prevenir deuda desde el diseño) y **brownfield** (medir, ganar terreno con bajo riesgo, proteger con gates).

Principio raíz: **"Mide, no adivines."** Trabajamos con **percentiles** (p50/p95/p99/p99.9), nunca con promedios, sobre **carga representativa**, y siempre comparando **antes/después**. Un promedio esconde a los usuarios que sufren; el p99 los revela.

## 1. Performance como atributo de calidad

- **Requisito explícito, no implícito.** Cada capacidad crítica lleva objetivos de latencia/throughput/recursos escritos, no supuestos.
- **Trazable a negocio.** Se conecta a impacto real (conversión, retención, costo por operación, seguridad de vidas en sistemas críticos), no a orgullo técnico.
- **Con dueño y evidencia.** Toda afirmación de performance se respalda con datos reproducibles. Ver [medicion-observabilidad.md](medicion-observabilidad.md) y [pruebas-de-carga.md](pruebas-de-carga.md).

## 2. SLI, SLO, SLA: definición y ejemplos

Marco de referencia: **Google SRE**. Distinguir con precisión evita presupuestos vacíos.

| Concepto | Qué es | Quién lo consume | Consecuencia |
|---|---|---|---|
| **SLI** | Indicador medido (una métrica) | Ingeniería/operación | Ninguna directa; es el dato |
| **SLO** | Objetivo interno sobre un SLI | Equipo/organización | Dispara error budget policy |
| **SLA** | Compromiso contractual externo | Cliente/legal | Penalización económica/legal |

Regla: **el SLO interno es más estricto que el SLA externo; deja holgura entre ambos.** Nunca prometas al cliente (SLA) lo mismo que tu objetivo interno (SLO).

Ejemplos de SLI por dominio (elegir el que refleja la experiencia real):

| Dominio | SLI de latencia | SLI de correctitud/disponibilidad |
|---|---|---|
| API transaccional | p99 de tiempo de respuesta del endpoint crítico | % de respuestas no-5xx |
| E-commerce web | Core Web Vitals (LCP/INP/CLS) p75 | % de checkouts completados sin error |
| Streaming/media | tiempo a primer frame; rebuffering ratio | % de reproducciones sin stall |
| Datos/batch | tiempo de fin del pipeline vs ventana | % de cargas dentro de SLA de frescura |
| IA/inferencia | p95 de latencia de inferencia; time-to-first-token | % de respuestas dentro de presupuesto de calidad |
| Sistemas críticos | tiempo de respuesta determinista (worst-case) | tasa de cumplimiento de deadline |

**Cómo fijar el SLO:** parte del comportamiento actual medido y del umbral donde el usuario percibe dolor; no inventes "99.99% porque suena bien". Un SLO debe ser alcanzable y significativo.

## 3. Error budgets y su política

**Error budget = 100% − SLO.** Es el margen de fallo permitido; convierte confiabilidad en un recurso gastable que alinea a features vs. estabilidad.

Política recomendada (adaptar por criticidad):

| Estado del budget | Acción |
|---|---|
| Saludable (sobra) | Se prioriza velocidad de features; se toleran experimentos |
| Consumo acelerado | Alertar; revisar releases recientes; reforzar gates |
| **Agotado** | **Congelar cambios no esenciales**; solo trabajo de fiabilidad/performance hasta recuperar; post-mortem sin culpa |

El agotamiento debe tener **consecuencia real y acordada de antemano**; un budget sin política es decorativo. Se restablece por ventana móvil (p. ej. 28 días). Ver gates automáticos en [performance-cicd.md](performance-cicd.md).

## 4. Performance budgets y su relación con costo (FinOps)

Un **performance budget** es un límite duro sobre una métrica que, si se cruza, **bloquea o alerta**. Cubre tres familias:

- **Latencia:** p95/p99 por operación (p. ej. endpoint, render, query).
- **Tamaño:** payload de respuesta, peso de bundle/JS, tamaño de imágenes.
- **Recursos:** CPU/memoria por request, I/O, conexiones, GPU-segundos.

Relación con **cost budget (FinOps)**: cada mejora o degradación de performance tiene precio. Se gobierna con métricas de **eficiencia unitaria**: **$/request, $/transacción, $/1k inferencias, costo por usuario activo**. Un sistema "rápido" que cuadruplica el costo por request puede ser peor negocio. Se busca el **frente de Pareto** latencia vs. costo, no el mínimo absoluto de latencia. Marcos: **Well-Architected Performance Efficiency**, **FinOps**, **Green Software** (eficiencia energética como budget adicional). Detalle en [infra-capacidad-costo.md](infra-capacidad-costo.md).

Ejemplo de tabla de budgets (neutral):

| Métrica | Budget | Umbral alerta | Gate CI |
|---|---|---|---|
| Latencia p99 endpoint crítico | ≤ X ms | 80% de X | Falla build |
| Peso inicial de bundle | ≤ Y KB | 90% de Y | Falla build |
| Costo por 1k requests | ≤ $Z | 85% de Z | Alerta |

## 5. Workload / traffic modeling (introducción)

Un budget sin modelo de carga es una ilusión. Antes de fijar objetivos, modela:

- **Mezcla de operaciones:** proporción read/write, endpoints calientes, colas de fondo (marco **RED / Golden Signals** para elegir qué medir).
- **Ráfagas y estacionalidad:** picos por hora/día/evento; relación pico/promedio.
- **Crecimiento:** proyección de tráfico y datos a 6-18 meses.
- **Fundamento teórico:** **Little's Law** (L = λ·W: concurrencia = tasa × tiempo de servicio) y **teoría de colas** para anticipar dónde la latencia explota al acercarse a la saturación.

El modelo alimenta las cargas representativas de [pruebas-de-carga.md](pruebas-de-carga.md) y el capacity planning de [infra-capacidad-costo.md](infra-capacidad-costo.md). Método de diagnóstico en [metodologia-diagnostico.md](metodologia-diagnostico.md).

## 6. Priorización del trabajo de performance

Neutral y basada en evidencia. Puntúa cada candidato:

```
prioridad = (impacto_usuario_o_negocio × alcance) / (esfuerzo × riesgo_de_regresion)
```

- **Impacto:** ¿cuántos usuarios/requests afecta y en qué percentil? Optimizar el p50 cuando el dolor está en el p99 es desperdicio.
- **Alcance:** ¿es cross-cutting o un caso de borde raro?
- **Esfuerzo × riesgo:** un quick win de bajo riesgo suele vencer a una reescritura ambiciosa.

**Regla anti-desperdicio:** no optimices sin perfil que pruebe que ese punto es el cuello de botella (evita micro-optimización prematura). En brownfield, prioriza **quick wins medidos y de bajo riesgo** antes de rediseños.

## 7. Performance en Definition of Ready / Done

Integrar performance en el flujo evita la deuda silenciosa (marco **DORA** para salud del delivery).

**Definition of Ready (antes de construir):**
- SLI/SLO objetivo identificado o heredado.
- Budget de latencia/tamaño/recursos asignado.
- Carga representativa esperada estimada.

**Definition of Done (antes de cerrar):**
- Medido bajo carga representativa; percentiles reportados antes/después.
- Dentro de budgets, o excepción documentada y aprobada.
- Observabilidad instrumentada (métricas/trazas) — ver [medicion-observabilidad.md](medicion-observabilidad.md).
- Sin regresión detectada por los gates de [performance-cicd.md](performance-cicd.md).

## 8. Gobernanza

| Pregunta | Responsable/mecanismo |
|---|---|
| ¿Quién define los budgets? | peakformance con los dueños de cada capa; ratificados por arquitectura ([eneida](interoperabilidad-y-aliadas.md)) y producto |
| ¿Quién los revisa y con qué cadencia? | Revisión periódica (p. ej. por sprint/release) + revisión del error budget por su ventana (28 días rolling) |
| ¿Dónde viven? | Versionados junto al código/infra como budgets-as-code (ver [performance-cicd.md](performance-cicd.md)) |
| ¿Quién arbitra excepciones? | Comité ligero: peakformance + arquitectura + dueño de negocio |
| ¿Quién es dueño de cada métrica? | La capa correspondiente; peakformance gobierna el marco, no invade el ownership |

## 9. Modelo de madurez de performance

| Nivel | Descripción | Señal típica |
|---|---|---|
| 0 · Ausente | No se mide; se reacciona a quejas | "Está lento" sin datos |
| 1 · Reactivo | Se mide tras incidentes | Firefighting recurrente |
| 2 · Definido | SLOs y budgets escritos | Existen dashboards básicos |
| 3 · Gestionado | Gates en CI/CD; budgets aplicados | Regresiones bloqueadas automáticamente |
| 4 · Proactivo | Capacity planning y modelado de carga rutinarios | Se anticipa la saturación |
| 5 · Continuo/optimizado | Performance dirige diseño; FinOps + Green integrados; cultura de "mide siempre" | Optimización guiada por evidencia continua |

Meta: subir un nivel a la vez con evidencia; no saltar etapas.

## 10. Estrategia diferenciada: greenfield vs. brownfield

**Greenfield (en construcción):**
- Definir SLO/SLI y budgets **desde el diseño**; performance como criterio de decisión arquitectónica.
- Instrumentar observabilidad desde el día uno; nada nace ciego.
- Prevenir deuda: modelar carga y validar decisiones con prototipos medidos.

**Brownfield (auditoría/rescate):**
1. **Medir primero:** establecer línea base con percentiles y carga representativa antes de tocar nada.
2. **Quick wins de bajo riesgo:** aplicar mejoras cross-cutting seguras (ver modelo TIERED abajo).
3. **Proteger con gates:** una vez ganado terreno, congelarlo con budgets en CI para que no se regrese.
4. **Rediseñar solo lo que la evidencia justifique**, por prioridad (sección 6).

## 11. Modelo TIERED de corrección

Cómo peakformance interviene sin invadir ownership ajeno:

- **T1 — Directo:** implementa lo **cross-cutting que ES performance** (perfilado, caching transversal, budgets/gates, instrumentación de observabilidad, config de recursos).
- **T2 — Vía dueño:** en **código de dominio ajeno**, entrega un **fix medido** (con evidencia antes/después) e **integra a través del dueño** de esa capa (ver equipo, sección 12).
- **T3 — Fallback directo:** si **no existe el dueño**, aplica el arreglo directamente, documentando la deuda de ownership.

## 12. Anti-patrones estratégicos

- **Optimizar por moda** o por benchmarks ajenos en lugar de por tu carga medida.
- **Promedios** en vez de percentiles; ocultan la cola que sufre.
- **Budgets sin gate ni política**: decorativos.
- **SLA = SLO** sin holgura: incumplimiento contractual asegurado.
- **Optimización prematura** sin perfil que señale el cuello de botella.
- **Performance como fase final** en vez de atributo continuo.
- **Ignorar el costo:** ganar latencia disparando $/request sin acordarlo.
- **Un solo número global** ("el sitio va bien") que promedia lo bueno y lo roto.

## 13. Cuándo escalar / handoff

Colaborar sin invadir ownership; entregar vía handoff con evidencia:

| Situación | Handoff a | Archivo |
|---|---|---|
| Percepción/UX de la espera | uxuifull | [interoperabilidad-y-aliadas.md](interoperabilidad-y-aliadas.md) |
| Render, bundle, Core Web Vitals | farola | [frontend-performance.md](frontend-performance.md) |
| Lógica/servicios backend | motor | [backend-performance.md](backend-performance.md) |
| Consultas, índices, plataforma de datos | andulfo | [datos-performance.md](datos-performance.md) |
| Trade-offs y límites arquitectónicos | eneida | [distribuidos-escalabilidad.md](distribuidos-escalabilidad.md) |
| Inferencia / MLOps | sysuniversal-ai | [ia-ml-performance.md](ia-ml-performance.md) |
| Validación bajo carga y regresión funcional | amado | [pruebas-de-carga.md](pruebas-de-carga.md) |
| Impacto de controles de seguridad en latencia | destroyer | [interoperabilidad-y-aliadas.md](interoperabilidad-y-aliadas.md) |

Para diagnosticar dónde está el problema, ir a [metodologia-diagnostico.md](metodologia-diagnostico.md); para plantillas de SLO/budget y ejemplos aplicados, ver [plantillas.md](plantillas.md) y [ejemplos.md](ejemplos.md).
