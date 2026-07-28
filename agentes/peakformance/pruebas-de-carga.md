# Pruebas de carga

Pruebas de carga bien hechas: **reproducir demanda representativa, medir con fidelidad y descubrir el punto donde el sistema deja de cumplir su SLO** — no producir un número grande de RPS para una diapositiva. peakformance **posee** los harnesses, los escenarios y el modelo de workload (Tier 1); las correcciones que emergen se entregan al dueño del componente (Tier 2) y la ejecución de QA se coordina con **amado**. El motor de carga (p. ej. k6, Gatling, JMeter, Locust, wrk, Vegeta, Artillery) se elige por contexto — protocolo, escala, cierre de coordinated omission, ergonomía del equipo — nunca por moda. Evidencia, no anécdota.

Encadena con [estrategia-performance.md](estrategia-performance.md) (qué SLO/budget defiende cada prueba), [metodologia-diagnostico.md](metodologia-diagnostico.md) (hipótesis → experimento) y [medicion-observabilidad.md](medicion-observabilidad.md) (cómo se miden latencias sin engañarse).

## Principio rector

- **Percentiles, no promedios.** Un p50 sano oculta un p99 letal. Se aceptan/rechazan pruebas contra p95/p99/p99.9 y su varianza, más error rate y throughput sostenido.
- **Carga representativa.** La mezcla de operaciones, el think time y la distribución de datos deben parecerse a producción, no a un bucle uniforme sobre un endpoint barato.
- **Antes/después.** Toda prueba es comparativa: baseline versionado vs candidato, mismo entorno, mismo generador, misma semilla de datos. Sin baseline no hay veredicto.
- **Marcos:** Little's Law (concurrencia = throughput × latencia) para dimensionar; Universal Scalability Law (USL) para modelar contención (σ) y coherencia (κ); Google SRE para SLO/error budget; Gil Tene para coordinated omission.

## Tipos de prueba y cuándo usarlos

| Tipo | Pregunta que responde | Duración típica | Señal clave |
|------|----------------------|-----------------|-------------|
| **Load / carga nominal** | ¿Cumple SLO en la carga esperada (y su pico esperado)? | 15–60 min | p95/p99 y error rate en régimen estable |
| **Stress** | ¿Cómo y dónde se rompe al exceder la capacidad? | Rampa hasta fallo | Punto de saturación, modo de fallo, si degrada limpio |
| **Soak / endurance** | ¿Se degrada o fuga con el tiempo? | 2–24 h+ | Deriva de latencia, memoria, conexiones, disco, GC |
| **Spike** | ¿Sobrevive a un salto brusco de tráfico? | Segundos–minutos | Recuperación, colas, rechazo elegante, cold caches |
| **Breakpoint / capacity** | ¿Cuál es la capacidad máxima que cumple SLO? | Rampa gradual | Máx. throughput con SLO verde antes del quiebre |
| **Scalability** | ¿Escala linealmente al añadir recursos/nodos? | Serie de corridas | Coeficientes σ/κ de la USL; retorno decreciente |

Regla: nunca una sola corrida. La capacidad se descubre con una **serie** (breakpoint), la salud se confirma con **soak**, la resiliencia con **spike/stress**.

## Greenfield: probar el modelo antes de construir

En greenfield la prueba de carga no valida un sistema terminado: **de-riesga decisiones**. Antes de comprometer arquitectura se cargan **PoCs o componentes candidatos** (un almacén, una cola, un runtime) con **datos a escala simulada** y **modelo abierto** para:

- validar el **modelo de carga** teórico (¿se cumplen la concurrencia y el *knee* que predicen Little's Law/USL?);
- **elegir tecnología por evidencia**, comparando candidatos bajo la misma carga (no por moda);
- fijar **budgets realistas** por capa antes de que exista el producto.

El PoC se descarta; lo que sobrevive es el **modelo validado** y los budgets. Método predictivo en [metodologia-diagnostico.md](metodologia-diagnostico.md) §1.1; caso en [ejemplos.md](ejemplos.md) (Ejemplo 0).

## Modelado del workload (workload modeling)

El realismo del modelo determina la validez del resultado. Componentes:

- **Mezcla de operaciones.** Proporción real de lecturas/escrituras y de endpoints (extraída de logs/APM de producción). Un 95% lecturas cacheadas + 5% escrituras se comporta radicalmente distinto a 50/50.
- **Think time.** Pausa entre acciones de un usuario. Sin think time se sobrecarga artificialmente y se mide otro sistema.
- **Ramp-up.** Subida gradual para observar cómo entra en saturación, no un choque instantáneo (salvo que el spike sea justamente el objeto de prueba).
- **Distribución de datos.** IDs, tamaños de payload y cardinalidad realistas (Zipf/long-tail, no uniforme). Un dataset uniforme falsea hit-ratio de cache e índices → ver [datos-performance.md](datos-performance.md).

### Modelo abierto vs cerrado (por qué importa)

- **Modelo cerrado:** N usuarios virtuales fijos; cada uno espera la respuesta antes de disparar la siguiente. La tasa de llegada se **autolimita** con la latencia → cuando el sistema se degrada, el generador *reduce* la carga y **oculta** el problema. Modela sesiones acotadas (p. ej. VUs de UI).
- **Modelo abierto:** llegadas a una **tasa objetivo** independiente de las respuestas (arrival-rate). Cuando el sistema se degrada, la carga **no** cede → aparecen colas y backlog reales. Modela tráfico de internet/APIs públicas y es el correcto para descubrir capacidad honesta.

```
cerrado:  next_request = después_de(respuesta_anterior + think_time)   # feedback → esconde saturación
abierto:  next_request = programado_a(tasa λ)                          # sin feedback → expone saturación
Poca gente sabe: casi todo veredicto de capacidad debe correrse en modelo ABIERTO.
```

## Coordinated omission (la trampa que subestima la latencia)

Muchos generadores, al esperar la respuesta antes de enviar la siguiente petición (modelo cerrado o timers relativos), **omiten** las peticiones que *deberían* haberse enviado durante una pausa larga. Resultado: durante una degradación se registran pocas mediciones malas y muchas buenas → el p99 sale optimista por órdenes de magnitud.

Contramedidas:
- Programar peticiones a una **tasa fija** (schedule absoluto), no relativo a la respuesta anterior.
- Usar generadores/modos con corrección de coordinated omission (p. ej. `constant-arrival-rate` en k6, throughput fijo en Gatling, HdrHistogram con expected-interval).
- Reportar latencia con **histogramas de alta dinámica** (HdrHistogram) y latencia de *servicio* vs latencia de *respuesta* (que incluye espera en cola).

Detalle completo de instrumentación y por qué el promedio miente en [medicion-observabilidad.md](medicion-observabilidad.md).

## Fidelidad de entorno y datos de prueba

Una prueba solo es válida si el entorno bajo carga se parece al que se quiere defender:

- **Datos a escala.** Tablas/índices/particiones con volumen y cardinalidad de producción; no 1.000 filas cuando producción tiene 10⁸. El plan de consultas cambia con el tamaño → coordinar con **andulfo**.
- **Estado caliente vs frío.** Correr con caches frías (peor caso, cold start) *y* calientes (régimen). Reportar ambos; nunca promediar el arranque con el estado estable.
- **Dependencias.** Decidir explícitamente qué es real y qué es mock/stub. Mockear un downstream lento **borra** el cuello de botella real; dejarlo real puede contaminar sistemas compartidos. Usar service virtualization con latencias representativas.
- **Aislamiento del generador.** El load generator no debe competir por CPU/red con el sistema bajo prueba, ni ser él mismo el cuello de botella (verificar saturación del propio generador).

## Dónde ejecutar

- **Staging fiel** (mismo shape de infra, datos a escala): entorno por defecto para breakpoint/stress destructivos.
- **Testing in production** cuando staging no puede replicar escala/topología: con salvaguardas — **canary** (fracción de tráfico), **shadow/mirror traffic** (copia de tráfico real sin efectos secundarios), límites de blast radius, feature flags, kill-switch, y observabilidad en vivo. Prohibido sin plan de aborto. Coordinado con **amado** (QA) y con el dueño del entorno (**motor/andulfo/sysuniversal-ai**).
- Considerar costo e infra del propio ejercicio de carga → [infra-capacidad-costo.md](infra-capacidad-costo.md).

## Criterios de aceptación (contra SLO/budgets)

La prueba pasa/falla contra umbrales definidos **antes** de correr, derivados de los SLO y el error budget de [estrategia-performance.md](estrategia-performance.md):

```
PASS si, en carga objetivo sostenida T minutos:
  p95_latencia   <= SLO_p95
  p99_latencia   <= SLO_p99
  error_rate     <= budget_errores
  throughput     >= objetivo_rps  (sin backlog creciente)
  recursos       sin deriva monótona (soak)   # memoria/conexiones/colas estables
FAIL en caso contrario  → hallazgo con evidencia → Tier 2
```

Los thresholds viven **en el harness** (fallan la corrida en CI) → ver [performance-cicd.md](performance-cicd.md).

## Interpretación de resultados

- **Saturación (knee):** throughput deja de crecer mientras la latencia sube; concurrencia útil se agota (Little's Law). Identificar el recurso limitante (CPU, IO, locks, pool de conexiones, GC).
- **Punto de quiebre:** RPS a partir del cual el error rate rompe el budget o la latencia diverge. Es la **capacidad**.
- **Modo de degradación:** ¿degrada limpio (throttling, colas acotadas, rechazo con 429) o colapsa (timeouts en cascada, retry storms, thundering herd)? Un colapso es un hallazgo de resiliencia → [distribuidos-escalabilidad.md](distribuidos-escalabilidad.md).
- **USL:** ajustar throughput vs concurrencia; σ alto = contención (serialización), κ>0 = penalización por coherencia (retorno negativo al escalar). Distingue "añadir nodos ayuda" de "añadir nodos empeora".

## Descubrimiento de capacidad

1. Baseline con carga nominal (verificar SLO verde).
2. Breakpoint: rampa en modelo abierto hasta romper SLO; registrar RPS y recurso limitante.
3. Confirmar con soak a ~70–80% de la capacidad hallada (headroom).
4. Modelar con Little's Law/USL para proyectar necesidad de recursos vs demanda futura.
5. Traducir a plan de capacidad y costo → [infra-capacidad-costo.md](infra-capacidad-costo.md).

## Ingeniería del caos (resiliencia proactiva)

Más allá de reproducir carga, la **ingeniería del caos** inyecta fallos y latencia de forma controlada para descubrir cómo degrada el performance ante lo inesperado, con **blast radius acotado** e hipótesis previa (steady-state).

- **Inyección (p. ej.):** latencia añadida en dependencias, pérdida/partición de red, caída de instancias/zonas, agotamiento de recursos (CPU/mem/disco/file descriptors), reloj sesgado.
- **Método:** hipótesis de estado estable (un SLI) → inyectar en una fracción → medir la desviación → **abortar si excede el budget**. GameDays regulares, no experimentos ad hoc.
- **Qué revela en performance:** retry storms, timeouts mal calibrados, ausencia de backpressure y cold caches tras failover → [distribuidos-escalabilidad.md](distribuidos-escalabilidad.md).

Coordinado con **eneida** (resiliencia arquitectónica) y **amado** (QA); en producción, con las mismas salvaguardas que el testing in production (canary/shadow, kill-switch).

## Reparto de responsabilidades (TIERED) y colaboración con amado

- **Tier 1 — peakformance:** diseña el modelo de workload, implementa y posee los harnesses y escenarios, define thresholds, ejecuta las corridas de descubrimiento y emite el veredicto con evidencia (percentiles, histogramas, antes/después).
- **Tier 2 — dueños:** los arreglos que surjan (índice, pool, cache, algoritmo, config de runtime, autoscaling) se **entregan/co-implementan** con el owner: **motor** (backend/código), **farola** (frontend/entrega), **andulfo** (datos/motor de BD), **sysuniversal-ai** (inferencia IA/ML → [ia-ml-performance.md](ia-ml-performance.md)), **uxuifull** (percepción/UX de carga). Resiliencia bajo fallo se valida con **destroyer** y **eneida** (arquitectura).
- **QA — amado:** peakformance **coordina la ejecución de QA con amado**: integración de escenarios de carga en el ciclo de calidad, gates no funcionales, gestión de defectos de performance y trazabilidad. amado ejecuta/regresiona bajo el harness que peakformance posee.
- **Tier 3 — fallback:** si no hay owner disponible, peakformance implementa el fix mínimo, lo aísla y lo documenta para traspaso.

Handoffs y contratos con cada aliada en [interoperabilidad-y-aliadas.md](interoperabilidad-y-aliadas.md). Plantillas de plan/reporte de carga en [plantillas.md](plantillas.md); corridas resueltas en [ejemplos.md](ejemplos.md). Presupuesto de frontend bajo carga en [frontend-performance.md](frontend-performance.md) y de servicios en [backend-performance.md](backend-performance.md).

## Checklist — una prueba de carga bien hecha

- [ ] Objetivo explícito y ligado a un SLO/budget concreto.
- [ ] Workload modelado desde datos reales: mezcla, think time, ramp-up, distribución.
- [ ] **Modelo abierto** (arrival-rate) para veredictos de capacidad; cerrado solo cuando modela sesiones acotadas.
- [ ] **Coordinated omission** neutralizado (tasa fija + HdrHistogram); se reporta latencia de respuesta, no solo de servicio.
- [ ] Entorno y datos a escala; estado frío y caliente ejecutados por separado.
- [ ] Dependencias: real vs mock decidido y documentado; generador no saturado.
- [ ] Baseline versionado; corrida candidata comparable (mismo motor, misma semilla).
- [ ] Métricas en **percentiles** (p95/p99/p99.9) + error rate + throughput sostenido + recursos.
- [ ] Thresholds pass/fail definidos antes de correr y embebidos en el harness.
- [ ] Soak para fugas/deriva; spike/stress para modo de fallo y recuperación.
- [ ] Capacidad y knee identificados; recurso limitante nombrado.
- [ ] Salvaguardas verificadas si es testing in production (canary/shadow, kill-switch).
- [ ] Hallazgos con evidencia enrutados por Tier al owner; QA coordinado con **amado**.
- [ ] Resultado reproducible: escenario, datos, entorno y versión registrados.
