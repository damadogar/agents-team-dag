# Metodología de diagnóstico de performance

El corazón del método peakformance: **investigar performance como ciencia, no como adivinanza**. Un problema de performance es una hipótesis a falsar con datos, no una intuición a "optimizar". Este documento define cómo pasar del síntoma a la causa raíz de forma repetible, en cualquier dominio (fintech, salud, logística, gaming, IoT, IA), cualquier sistema (web, móvil, batch, streaming, embebido, distribuido) y cualquier estado (greenfield o brownfield). La obtención de los datos vive en [medición y observabilidad](medicion-observabilidad.md); aquí decidimos **qué medir, cómo interpretarlo y dónde atacar**.

> Principio rector: **Mide, no adivines.** Percentiles (p50/p95/p99/p99.9), nunca promedios. Carga representativa, no sintética arbitraria. Siempre antes/después con la misma metodología.

## 1. Método científico aplicado a performance

El ciclo es explícito y auditable. Nunca se cambia código "a ver si mejora".

| Fase | Qué se hace | Salida verificable |
|------|-------------|--------------------|
| Síntoma | Enunciar el dolor en términos medibles y de negocio | "p99 de checkout = 2.4 s; SLO = 800 ms" |
| Baseline | Medir el estado actual con carga representativa | Distribución de latencia + utilización de recursos |
| Hipótesis | Afirmación falsable sobre la causa | "El bottleneck es I/O de BD en el paso X" |
| Predicción | Qué debería observarse si la hipótesis es cierta | "Debería ver saturación de disco y off-CPU alto" |
| Medición | Instrumentar y obtener evidencia dirigida | Flame graph, USE del recurso, traza distribuida |
| Conclusión | Confirmar/refutar; una sola variable a la vez | Causa raíz o siguiente hipótesis |
| Verificación | Aplicar fix y remedir en las mismas condiciones | Delta antes/después con intervalo de confianza |

Reglas: **una variable por experimento**; entorno estable y aislado; carga reproducible; guardar el baseline crudo. Greenfield: define SLI/SLO y budgets desde el diseño (ver [estrategia](estrategia-performance.md)). Brownfield: primero baseline honesto del sistema vivo antes de tocar nada.

### 1.1 Greenfield: performance-by-design (modelar antes de medir)

Cuando el sistema **aún no existe**, no hay baseline que medir: se **modela**. El método greenfield es **predictivo**, no diagnóstico.

- **Budgets top-down**: derívalos de la meta de negocio (SLO objetivo por capa), no bottom-up desde lo que ya corre → [estrategia-performance.md](estrategia-performance.md).
- **Dimensionar con teoría**: **Little's Law** (L = λ·W) predice concurrencia/pools/instancias desde la carga objetivo (§5); la **teoría de colas** advierte de la no-linealidad cerca de la saturación; la **USL** predice el techo de escalado y obliga a decidir contra el estado compartido desde el diseño (§6).
- **De-riesgar por evidencia**: micro-benchmarks y pruebas de carga de **PoCs/componentes candidatos** con datos a escala simulada, para elegir tecnología por medición y no por moda → [pruebas-de-carga.md](pruebas-de-carga.md).
- **Instrumentar desde el día 0**: monta el esqueleto de observabilidad y los perf gates **antes del primer deploy**, de modo que la primera medición real **valide o refute el modelo** → [medicion-observabilidad.md](medicion-observabilidad.md), [performance-cicd.md](performance-cicd.md).

Regla greenfield: **el primer objetivo es un modelo falsable**; en cuanto hay un PoC, se mide y se corrige el modelo. Caso resuelto: Ejemplo 0 en [ejemplos.md](ejemplos.md).

## 2. Del síntoma a la causa raíz: drill-down por capas

El tiempo total es una **cadena**; la causa raíz suele estar una o dos capas por debajo de donde duele. Se desciende siguiendo el tiempo, no la sospecha.

```
Experiencia (UX percibido, Core Web Vitals) ── uxuifull
   → Cliente/Frontend (render, JS, red del navegador) ── farola
      → Red / Edge / CDN / gateway
         → Servicio/Backend (CPU app, GC, serialización, locks) ── motor
            → Dependencias (otros servicios, colas, terceros) ── eneida
               → Datos (query plan, índices, contención, I/O) ── andulfo
                  → Infra/plataforma (host, kernel, disco, red física) ── eneida/plataforma
```

Técnica: **atribución de latencia por span**. Con trazas distribuidas se descompone la latencia end-to-end por tramo y se ataca el que domina (§7). Regla: se baja de capa solo cuando la evidencia lo justifica; se sube de capa cuando el tramo local ya está limpio. Enlaces de profundización: [backend](backend-performance.md), [datos](datos-performance.md), [distribuidos](distribuidos-escalabilidad.md), [frontend](frontend-performance.md).

## 3. Método USE (recursos): Utilización, Saturación, Errores

De Brendan Gregg. Es el barrido **de recursos** (mirada bottom-up del sistema): para cada recurso, revisa las tres métricas. Ideal para "el sistema/host está lento" y para descartar cuellos de infra rápido.

| Recurso | Utilización | Saturación | Errores |
|---------|-------------|------------|---------|
| CPU | % ocupado por core | longitud de run-queue, presión de scheduler | throttling, fallos de contexto |
| Memoria | % usada / RSS | paginación, swap, presión OOM, pausas de GC | OOM kills, alloc fallidos |
| I/O disco | % busy, IOPS | profundidad de cola, latencia de espera | errores de dispositivo/FS |
| Red | ancho de banda usado | descartes, buffers, retransmisiones | paquetes con error, resets |
| Locks/concurrencia | % tiempo en sección crítica | hilos esperando lock, contención | deadlocks, timeouts de lock |
| Conexiones/pools | conexiones activas/límite | esperas por conexión libre | rechazos, agotamiento de pool |

Herramientas por ecosistema **(se eligen por contexto, no por moda)**: p. ej. observabilidad de host (utilidades de kernel/eBPF, agentes de métricas cloud-nativos, o suites APM comerciales); para pools, las métricas del propio runtime/driver. Señal clave: **saturación alta con utilización moderada** ya indica cuello — no esperes al 100%.

## 4. RED y Golden Signals (servicios y flujos)

Mirada top-down, **orientada a servicio/petición**, complementaria a USE.

- **RED** (por servicio, ideal microservicios/APIs): **R**ate (peticiones/s), **E**rrors (tasa de fallo), **D**uration (distribución de latencia por percentiles).
- **Golden Signals** (Google SRE): **Latencia** (separando exitosas de fallidas), **Tráfico**, **Errores**, **Saturación** (qué tan lleno está el sistema respecto a su límite).

| Marco | Punto de vista | Úsalo cuando |
|-------|----------------|--------------|
| USE | Recurso (bottom-up) | "El host/sistema está lento", descartar infra |
| RED | Petición/servicio (top-down) | Servicios/APIs, saber qué endpoint duele |
| Golden Signals | SLO/experiencia | Definir salud global y alertar por síntoma |

Práctica: **RED/Golden para detectar y localizar el servicio; USE para diagnosticar el recurso** dentro de ese servicio. Nunca alertes solo por utilización de un recurso: alerta por síntoma (latencia/errores del SLO) y usa recursos para diagnóstico. Detalle de instrumentación: [medición y observabilidad](medicion-observabilidad.md).

## 5. Teoría de colas y Little's Law

Casi todo sistema es una red de colas (CPU, pool de conexiones, hilos, disco). Little's Law:

```
L = λ · W        L = elementos en el sistema
                 λ = tasa de llegada (throughput)
                 W = tiempo medio en el sistema (latencia)
```

Intuición práctica: si conoces dos, deduces el tercero. Ej.: si λ = 500 req/s y W = 0.2 s ⇒ L = 100 peticiones concurrentes en vuelo → así dimensionas hilos/conexiones/workers.

**Por qué la latencia explota cerca de la saturación (no lineal):** para una cola simple, el tiempo de espera crece como `1/(1−ρ)`, con ρ = utilización. A ρ=0.5 el sistema "engorda" x2; a ρ=0.8, x5; a ρ=0.9, x10; a ρ=0.95, x20. **La latencia se dispara mucho antes del 100% de uso.** Consecuencias de diagnóstico: (1) el p99 se degrada por colas, no por "código lento"; (2) un pico de λ o un W que sube por una dependencia lenta llena colas aguas arriba (efecto dominó); (3) nunca planifiques capacidad al 90-95% de utilización. Variabilidad importa: a mayor variabilidad de llegadas o de servicio, peor la cola para la misma ρ.

## 6. Leyes de escalabilidad

### Universal Scalability Law (Gunther)

Modela por qué añadir nodos/hilos deja de ayudar e incluso empeora:

```
C(N) = N / (1 + σ·(N−1) + κ·N·(N−1))
   σ = contención  (recursos/secciones serializadas → aplana la curva)
   κ = coherencia  (sincronizar estado entre nodos → curva con retroceso)
```

Sin κ (κ=0), el throughput se satura como en Amdahl. Con κ>0 existe un **N óptimo**: pasado ese punto, más nodos = menos throughput (el coste de coordinación supera la ganancia). Uso diagnóstico: si escalar horizontalmente no rinde, sospecha **coherencia** (locks distribuidos, invalidación de caché, coordinación, chatty state) antes que "faltan máquinas". Ajusta σ y κ a datos reales de escalado para predecir el techo. Ver [distribuidos y escalabilidad](distribuidos-escalabilidad.md).

### Amdahl vs Gustafson

- **Amdahl** (problema de tamaño fijo): speedup ≤ `1/(s + (1−s)/N)`, con s = fracción serial. Si el 10% es serial, el máximo speedup es 10x aunque tengas infinitos cores. **Optimizar lo paralelo tiene techo duro; reduce la parte serial.**
- **Gustafson** (problema que crece con los recursos): a mayor escala se procesa más trabajo en el mismo tiempo; el speedup escala mejor si el trabajo crece.

Diagnóstico: pregunta si el caso es *fixed-size* (batch de tamaño dado → Amdahl manda, ataca lo serial) o *scale-out de carga creciente* (Gustafson → paraleliza y crece). Paralelizar lo que no domina no ayuda (§7).

## 7. Identificar el cuello de botella dominante

Regla de oro: **optimiza lo que domina el tiempo, no lo que es fácil de tocar.** Corolario de Amdahl: mejorar un tramo que es el 5% del tiempo total da como máximo 5% — aunque lo hagas 10x más rápido.

Procedimiento: (1) descompón el tiempo end-to-end por tramo/función; (2) ordena por contribución al p95/p99 (no al promedio — la cola es donde vive el dolor); (3) ataca el mayor contribuyente; (4) remide: el cuello **se mueve**, así que reitera. Un solo recurso saturado limita todo el sistema (ley del eslabón más débil): añadir capacidad en otro lado no mueve la aguja.

### 7.1 Latencia vs throughput vs saturación

| Concepto | Qué mide | Relación |
|----------|----------|----------|
| Latencia | tiempo por operación (percentiles) | sube no linealmente al acercarse a saturación (§5) |
| Throughput | operaciones por unidad de tiempo | tope por el recurso dominante (§6) |
| Saturación | cuán lleno está respecto al límite | alta saturación ⇒ colas ⇒ latencia dispara |

No se optimizan a la vez sin trade-off: bajar latencia p99 puede requerir sacrificar throughput máximo (headroom), y exprimir throughput suele empeorar la cola. Decide según SLO y contexto, con evidencia.

### 7.2 Complejidad algorítmica y estructuras de datos

Corolario práctico del §7: **el fix más barato suele ser el algoritmo, no el hardware.** Antes de escalar máquinas, mide la **clase de complejidad** del hot path.

- **Big-O como lente diagnóstica**: identifica la complejidad del tramo dominante y busca el trabajo cuadrático escondido — un bucle anidado sobre la entrada, un N+1 (una consulta por elemento en vez de una por lote), un re-cómputo dentro de un bucle que podía memoizarse, o una operación lineal repetida dentro de otra lineal. A escala real un **mejor algoritmo bate cualquier constante de hardware**: con n = 1e6, O(n²) ≈ 1e12 operaciones frente a O(n log n) ≈ 2e7 (factor ~50.000×); ninguna CPU más rápida ni más núcleos cierran esa brecha, porque la pendiente —no la constante— es la que domina al crecer n.
- **Coste amortizado y estructura según el patrón de acceso**: elige la estructura por la **operación dominante**, no por costumbre. Búsqueda/pertenencia y dedup por clave → tabla hash (O(1) amortizado); consultas por rango u orden mantenido → árbol balanceado / índice ordenado (O(log n)); acceso secuencial denso e iteración → array contiguo (localidad de caché). El **coste oculto de la estructura equivocada** es una clase de complejidad peor camuflada (p. ej. buscar en lista → O(n) por operación, o rehash/reasignaciones no amortizadas que degradan la cola p99).
- **Cómo detectarlo**: en el perfil, el síntoma crece con el **tamaño de la entrada**, no con la carga concurrente — la curva latencia-vs-n es supralineal aunque ρ sea baja (distíngelo de la explosión de colas del §5, que crece con la utilización). Confírmalo midiendo a dos o tres tamaños de n y ajustando la pendiente; una meseta ancha en el flame graph (§8) sobre una función de recorrido lo delata.
- **Fronteras de dominio (modelo TIERED)**: si el algoritmo es **código de dominio** (lógica de negocio, serialización, transformación en memoria) es un fix T2 del dueño de la capa → **motor**/**andulfo** vía [backend-performance.md](backend-performance.md); si el problema es el **patrón de acceso a datos** (índices, plan de consulta, N+1 contra la BD), es materia de [datos-performance.md](datos-performance.md).
- **Regla**: **mide la complejidad antes de escalar hardware.** Paralelizar (§6, Amdahl) u optimizar constantes sobre un algoritmo malo es tirar dinero: reduces la constante mientras la pendiente sigue mandando. Primero baja la clase de complejidad; recién entonces afina constantes y techo físico (roofline en [sistemas-hardware.md](sistemas-hardware.md)) sobre una base sana.

## 8. Flame graphs y profiling

- **On-CPU** (dónde se gasta CPU): flame graph de muestreo. Anchura = tiempo/coste; busca las mesetas anchas, no las torres altas. Detecta hot paths, serialización, funciones caras.
- **Off-CPU** (dónde se **espera**): I/O, locks, red, sleeps, GC. Muchos problemas de latencia son off-CPU e **invisibles** en un profiler on-CPU. Si la CPU está baja pero la latencia alta ⇒ perfila off-CPU.
- **Wall time vs CPU time**: wall = reloj de pared (incluye esperas); cpu = trabajo real. Wall ≫ cpu ⇒ el tiempo se va esperando (dependencias, I/O, contención), no computando. Es la pista más rápida para elegir entre §3 (recurso) y §2 (dependencia/capa).

Herramientas neutrales por ecosistema (p. ej. profilers de runtime nativos, perfiladores basados en eBPF, o APM con profiling continuo) — se eligen por lenguaje, entorno y overhead aceptable, nunca por preferencia. Perfila bajo **carga representativa**; un profile en reposo miente. Detalle en [medición y observabilidad](medicion-observabilidad.md).

## 9. Errores comunes de diagnóstico

- **Promedios**: ocultan la cola; el usuario vive el p99. Usa siempre percentiles.
- **Optimizar lo fácil / lo visible** en vez del dominante (§7).
- **Adivinar y parchear** sin baseline ni hipótesis falsable.
- **Micro-benchmark sin representatividad**: sin caché fría/caliente, sin concurrencia real, sin datos de tamaño real.
- **Confundir correlación con causa**: dos métricas suben juntas ≠ una causa la otra.
- **Ignorar off-CPU**: perfilar solo CPU cuando el dolor es espera.
- **Planificar al límite** (>90% util) ignorando la explosión de colas (§5).
- **Cambiar varias cosas a la vez**: pierdes la atribución del efecto.
- **Medir en un entorno y concluir para otro** (dev ≠ prod: datos, latencias, escala).
- **Descartar variabilidad**: el jitter y la varianza degradan colas y SLO tanto como la media.
- **Detenerse en el primer bottleneck**: se mueve; reitera hasta cumplir el SLO o alcanzar el límite físico/teórico.

## 10. Modelo de corrección (TIERED) al concluir el diagnóstico

- **T1 — directo**: peakformance implementa lo cross-cutting/transversal (budgets, señales, config de pools, headroom, quick wins medidos).
- **T2 — fix medido e integrado vía el dueño**: se entrega el cambio con evidencia antes/después al dueño de la capa (motor/andulfo/farola/eneida) para que lo integre.
- **T3 — fallback directo**: si el dueño no está disponible y hay riesgo activo de SLO, peakformance aplica el fix directo, medido y documentado, y notifica.

Todo fix cierra el ciclo del §1: **remedir en las mismas condiciones**. Sin delta verificado, el trabajo no está terminado.

---

Siguiente paso natural: obtén los datos con [medición y observabilidad](medicion-observabilidad.md) y baja a la capa que domina — [backend](backend-performance.md), [datos](datos-performance.md), [distribuidos](distribuidos-escalabilidad.md), [frontend](frontend-performance.md). Marco general en [estrategia](estrategia-performance.md); ejecución con [pruebas de carga](pruebas-de-carga.md); artefactos en [plantillas](plantillas.md) y [ejemplos](ejemplos.md).
