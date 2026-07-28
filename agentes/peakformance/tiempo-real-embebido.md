# Tiempo real y sistemas embebidos: cuando la métrica rectora es el peor caso, no el percentil

peakformance es dueño integral del **determinismo temporal** del ecosistema, también donde el rendimiento se mide en microsegundos y ciclos de reloj, y donde fallar un plazo puede costar una misión, una máquina o una vida. Este satélite fija la disciplina de performance/determinismo para sistemas de **tiempo real** (hard/soft) y **embebidos** en cualquier dominio (p. ej. IoT, automotriz, aeroespacial, industrial, médico, trading de baja latencia), con neutralidad total: bare-metal, RTOS varios o Linux con parche RT son "p. ej.", se eligen por contexto y evidencia, nunca por moda.

> **Frontera de ownership.** peakformance aporta la disciplina de rendimiento y determinismo (presupuestos de deadline, análisis de planificabilidad, control de jitter, instrumentación de bajo overhead). El **diseño funcional del firmware / lógica de dominio** es del dueño del código (motor y el especialista de dominio, bajo arquitectura de **eneida**). No se invade la funcionalidad: se garantiza que cumpla su tiempo.

---

## 1. La métrica rectora cambia: peor caso garantizado, no p99

En el resto del ecosistema el mantra es "percentiles, no promedios" (ver [medicion-observabilidad.md](medicion-observabilidad.md), sección de sistemas no-online). Aquí ese mantra se **matiza**: en tiempo real lo que se garantiza es un **máximo acotado y determinista**, no una cola estadística.

| Clase | Definición | Métrica rectora | Consecuencia de fallo |
|---|---|---|---|
| **Hard real-time** | Todo deadline DEBE cumplirse | **WCET ≤ deadline**, siempre | Fallo del sistema (catastrófico) |
| **Firm real-time** | Fallo ocasional tolerable pero resultado tardío es inútil | Tasa de deadlines perdidos acotada | Resultado descartado |
| **Soft real-time** | Fallar degrada calidad, no corrige | p99/p999 + máximo observado | Degradación (jitter perceptible) |

- En **hard/firm**, un p99 excelente con un solo outlier por encima del deadline = **sistema no válido**. Importa el **supremo acotado**, demostrable, no la distribución.
- En **soft** (p. ej. streaming, trading), sí se razona en colas (p99, p999) **pero** con foco en acotar el máximo y minimizar la varianza (determinismo), no solo la mediana.
- Regla: **peakformance nunca reporta solo promedios/percentiles en un camino de tiempo real**; reporta WCET (analítico y/o medido), margen al deadline, y jitter (pico-a-pico).

```
holgura (slack) = deadline − WCET
veredicto: HARD  → exige slack ≥ margen_seguridad Y prueba de planificabilidad
          SOFT  → exige p999 ≤ deadline Y max_observado con margen
```

---

## 2. WCET (Worst-Case Execution Time)

El WCET es el tiempo máximo que un fragmento puede tardar bajo cualquier entrada y estado del hardware. Es el insumo de todo análisis de planificabilidad.

| Método | Cómo | Fortaleza | Riesgo |
|---|---|---|---|
| **Estático** (análisis del binario + modelo de HW) | Grafo de flujo + bounds de bucles + modelo de caché/pipeline | Cota **segura** (sobre-estima) | Pesimismo alto; requiere modelo fiel del HW |
| **Por medición** (measurement-based) | Ejecutar muchos casos, tomar el máximo + margen | Realista, barato | **Puede sub-estimar**: quizá nunca se ejecutó el peor camino |
| **Híbrido** | Medir bloques básicos, combinar por análisis estático | Balance | Complejidad de tooling |

- **Por qué p99 no basta para WCET:** el peor camino (peor patrón de caché, peor rama, peor latencia de bus) puede tener probabilidad ínfima y no aparecer en un muestreo. Un WCET fiable exige **cobertura del peor camino** o cota estática, no confianza estadística.
- **Márgenes de seguridad:** aplicar factor de seguridad sobre el WCET medido (p. ej. reservar holgura), acotado por evidencia y criticidad del dominio; documentar el supuesto de HW (frecuencia fija, caché en estado conocido).
- Requiere **bounds de bucles conocidos** y prohibir recursión no acotada en caminos críticos.

---

## 3. Scheduling de tiempo real

### Prioridades fijas vs dinámicas

| Política | Tipo | Asignación | Óptima para |
|---|---|---|---|
| **Rate-Monotonic (RMS)** | Prioridad fija | Mayor prioridad = menor periodo | Tareas periódicas, prioridad estática |
| **Deadline-Monotonic (DMS)** | Prioridad fija | Mayor prioridad = menor deadline relativo | Deadline < periodo |
| **EDF** (Earliest Deadline First) | Prioridad dinámica | Prioridad = deadline absoluto más próximo | Máxima utilización |

### Análisis de planificabilidad (schedulability)

Prueba **a priori** de que el conjunto de tareas cumple sus deadlines.

- **Bound de utilización (Liu & Layland, RMS):** para _n_ tareas, si la utilización total
  `U = Σ (Cᵢ / Tᵢ) ≤ n·(2^{1/n} − 1)` → **planificable** (condición suficiente; el bound → ln 2 ≈ **0.693** cuando n→∞).
- **EDF:** planificable **si y solo si** `U ≤ 1` (deadlines = periodos) → aprovecha el 100% de CPU, pero degrada de forma menos predecible en sobrecarga (efecto dominó).
- **Response-Time Analysis (RTA):** cálculo iterativo del peor tiempo de respuesta `Rᵢ = Cᵢ + Σ_{j∈hp(i)} ⌈Rᵢ/Tⱼ⌉·Cⱼ` → verificar `Rᵢ ≤ Dᵢ`. Prueba exacta para prioridad fija.

```
para cada tarea i (de mayor a menor prioridad):
  R = C[i]
  repetir:
    interferencia = Σ_{j de mayor prioridad} ceil(R / T[j]) * C[j]
    R_nuevo = C[i] + interferencia
  hasta que R_nuevo == R   # punto fijo
  si R > D[i]: NO_PLANIFICABLE
```

### Priority inversion

Tarea de alta prioridad bloqueada por una de baja que retiene un recurso, mientras una de prioridad media se cuela y **prolonga el bloqueo sin cota** (caso célebre: Mars Pathfinder, resets por reinicio del watchdog).

| Protocolo | Mecanismo | Efecto |
|---|---|---|
| **Priority Inheritance** | La tarea que retiene el recurso hereda temporalmente la prioridad del bloqueado más alto | Acota el bloqueo; no previene deadlock |
| **Priority Ceiling** | Cada mutex tiene un "techo" = prioridad máxima que lo usará; se eleva al tomarlo | Acota bloqueo a **una** sección crítica; previene deadlock e inversión encadenada |

---

## 4. Determinismo y jitter

**Jitter** = variabilidad de la latencia/tiempo de respuesta. El enemigo del tiempo real no es la lentitud media, es la **cola larga no acotada**.

| Fuente de no-determinismo | Efecto | Cómo acotarla |
|---|---|---|
| **Garbage collection** | Pausas impredecibles | Evitar GC en caminos críticos (ver §5); regiones/allocación estática; RT-GC solo si acotado |
| **Cachés / branch prediction** | Variación de ciclos por hit/miss | Cache locking, deshabilitar en camino crítico, pre-warm, análisis con modelo de caché |
| **DVFS / turbo boost** | Frecuencia variable → tiempos variables | **Fijar frecuencia**, deshabilitar estados C profundos / turbo |
| **Interrupciones (IRQ)** | Preempción no planificada | Afinidad de IRQ fuera de CPU críticas; umbral de rate; threaded IRQs |
| **Contención (locks, bus, memoria)** | Bloqueo variable | Protocolos de techo; lock-free acotado; particionar bancos de memoria |
| **TLB / paginación / swap** | Page faults | **Bloquear páginas en RAM** (mlock), sin swap, prealojar |
| **SMI / firmware (x86)** | Interrupción invisible al SO | Auditar con detectores de latencia HW; plataformas sin SMM en RT duro |

- **Latencia de interrupción** = tiempo desde que se asierta la IRQ hasta que corre la primera instrucción del handler. Se descompone en: latencia de HW + secciones con IRQ deshabilitadas + despacho. Se **mide y se acota**; es entrada directa del análisis de respuesta.
- El detalle de plataforma HW (afinidad, IRQ steering, cache locking, aislamiento de núcleos) se coordina con [sistemas-hardware.md](sistemas-hardware.md) y **eneida** (plataforma).

---

## 5. Restricciones de memoria y energía en dispositivo

- **Sin heap dinámico / sin GC en caminos críticos:** `malloc`/`new` tienen tiempo no acotado y fragmentan. Regla en hard-RT: **allocación estática** o en fase de init; **pools de tamaño fijo** (free-list O(1)) para objetos de vida corta.
- **Presupuestos de memoria:** stack por tarea dimensionado por peor anidamiento (watermark + margen); sin recursión no acotada; verificar overflow con guard pages / patrones centinela.
- **Presupuestos de energía:** en dispositivos alimentados por batería/energy-harvesting, el "performance" incluye **julios por operación**. Trade-off directo entre latencia (frecuencia alta, sin sleep) y consumo (race-to-idle vs. slow-and-steady). Modelar energía como recurso planificable.

| Plataforma | Determinismo | Ecosistema/features | Coste de ingeniería | Encaje típico (p. ej.) |
|---|---|---|---|---|
| **Bare-metal** | Máximo (control total del timing) | Nulo (todo a mano) | Muy alto | MCU, lazos de control críticos |
| **RTOS** (varios) | Alto (scheduler determinista, latencias acotadas) | Medio (drivers, stacks) | Medio | Automotriz, industrial, médico |
| **Linux + PREEMPT_RT** | Bueno para **soft/firm** (latencias acotadas ~decenas µs, no hard duro) | Muy rico (red, FS, tooling) | Bajo-medio | Gateways IoT, robótica, trading |

Elección **por contexto**: criticidad, latencia objetivo, riqueza de stack, certificación. No hay default.

---

## 6. Medición on-device sin observer effect

En el resto del ecosistema instrumentar barato es aceptable; aquí **el instrumento no debe alterar el timing** que mide (Heisenberg del rendimiento).

| Técnica | Overhead | Resolución | Uso |
|---|---|---|---|
| **Contador de ciclos** (p. ej. CYCCNT/PMU/DWT) | ~nulo | 1 ciclo | Medir tramos de código in situ |
| **GPIO toggle + osciloscopio / analizador lógico** | 1-2 instrucciones | ns, externo | Medir latencia real sin tocar el SW bajo prueba |
| **Tracepoints de bajo overhead** (buffer en RAM, ring) | Bajo, acotado | µs | Trazas de scheduling/IRQ (post-mortem) |
| **JTAG / SWD / trace port (ETM)** | Nulo (HW dedicado) | Ciclo | Trazado no intrusivo del flujo real |
| **Timestamping por HW timer** | Nulo | Tick del timer | Sellar eventos sin CPU |

- Preferir siempre lo **externo o pasivo** (GPIO+osciloscopio, trace HW) en camino crítico; nunca `printf`/logging con I/O bloqueante en un handler de tiempo real.
- Un tracepoint que añade jitter propio **invalida** la medición del peor caso: medir el overhead del propio instrumento y restarlo/acotarlo.

---

## 7. Dominios (p. ej.)

| Dominio | Clase típica | Métrica clave | Notas de estándares (alto nivel) |
|---|---|---|---|
| **IoT / edge** | Soft/firm | Latencia + energía/op + duty cycle | Restricción severa de memoria/energía |
| **Automotriz** | Hard (control), soft (infotainment) | WCET, jitter de bus | ISO 26262 (ASIL), AUTOSAR, MISRA C |
| **Aeroespacial / defensa** | Hard, seguridad-crítico | WCET demostrable, particionado temporal/espacial | DO-178C (DAL), ARINC 653, MISRA — a alto nivel |
| **Industrial / control** | Hard (lazos), firm | Periodo de ciclo, jitter | IEC 61508; fieldbuses deterministas |
| **Médico (dispositivos)** | Hard/firm, seguridad-crítico | WCET, respuesta acotada | IEC 62304 — a alto nivel |
| **Trading / baja latencia** | **Soft-RT determinista** | p999 **y** máximo, jitter tick-to-trade | No certificado, pero determinismo extremo |

**Trading / baja latencia** es soft real-time pero obsesionado con el determinismo: **kernel bypass** (NIC a espacio de usuario), **busy-poll** (sin dormir el CPU, sin latencia de wakeup), aislamiento de núcleos, NUMA pinning, sin interrupciones en el hot path. El detalle de HW/red se coordina con [sistemas-hardware.md](sistemas-hardware.md).

> Nota de estándares: peakformance trata DO-178C / ISO 26262 / IEC 62304 / MISRA **a alto nivel** como marco de disciplina y trazabilidad de evidencia temporal (WCET, planificabilidad). La certificación funcional y el proceso de safety son del dueño de dominio y de **amado** (QA/verificación); ver también **destroyer** para safety/seguridad.

---

## Reparto TIERED

| Tier | Qué | Quién |
|---|---|---|
| **T1 — cross-cutting (implementa peakformance)** | Config de scheduler RT (políticas, prioridades), aislamiento/afinidad de CPU e IRQ, tuning de jitter (fijar frecuencia, mlock, cache), presupuestos de deadline y análisis de planificabilidad, instrumentación on-device de bajo overhead, harness de medición de WCET/latencia | **peakformance** |
| **T2 — código de dominio (co-implementa / entrega el fix)** | Firmware y lógica funcional que debe caber en su presupuesto temporal; peakformance entrega el fix medido y lo integra **con o vía** su dueño | motor + especialista de dominio; arquitectura y plataforma de **eneida** |
| **T3 — fallback** | Si el dueño de dominio no está disponible, peakformance implementa el cambio de rendimiento de forma acotada y declarada, y lo devuelve para revisión funcional | **peakformance** (temporal, documentado) |

Coordinación: **eneida** (arquitectura, límites y plataforma: HW/kernel/aprovisionamiento), **motor** (backend/firmware), **andulfo** (datos si aplica en gateways), **sysuniversal-ai** (inferencia on-device/TinyML), **farola**/**uxuifull** (si hay HMI con tiempo real percibido), **amado** (verificación temporal), **destroyer** (safety/seguridad). Ver [interoperabilidad-y-aliadas.md](interoperabilidad-y-aliadas.md).

---

## Greenfield vs Brownfield

**Greenfield — diseñar para determinismo desde el inicio:**
1. Clasificar cada tarea: hard / firm / soft; asignar deadline y periodo.
2. Estimar WCET temprano; elegir política de scheduling (RMS/DMS/EDF) por el perfil.
3. Probar planificabilidad **antes** de codificar; reservar holgura.
4. Prohibir por diseño heap dinámico y bloqueo no acotado en caminos críticos.
5. Elegir plataforma (bare-metal/RTOS/Linux-RT) por evidencia, no por costumbre.

**Brownfield — auditar jitter/deadlines en lo existente:**
1. Instrumentar sin observer effect (GPIO/trace HW) y capturar distribución **con máximo**.
2. Detectar deadlines incumplidos y sus **outliers**; localizar la fuente de jitter (§4).
3. Medir WCET real de tramos críticos; comparar con presupuesto.
4. Detectar priority inversion (trazas de bloqueo) y aplicar herencia/techo.
5. Acotar no-determinismo (fijar frecuencia, aislar IRQ, mlock) y re-verificar planificabilidad.

Ver [metodologia-diagnostico.md](metodologia-diagnostico.md), [estrategia-performance.md](estrategia-performance.md) y [backend-performance.md](backend-performance.md).

---

## Checklist de tiempo real / embebido

- [ ] Cada tarea clasificada (hard/firm/soft) con **deadline y periodo** explícitos.
- [ ] WCET estimado (estático y/o medido con cobertura del peor camino) + margen de seguridad.
- [ ] Prueba de **planificabilidad** superada (bound de utilización o RTA), con holgura documentada.
- [ ] Política de scheduling justificada por contexto (RMS/DMS/EDF), no por defecto.
- [ ] Protocolo contra **priority inversion** (herencia o techo) en todo mutex compartido.
- [ ] Fuentes de jitter identificadas y **acotadas** (frecuencia fija, IRQ aisladas, sin swap, caché controlada).
- [ ] **Latencia de interrupción** medida y dentro del presupuesto.
- [ ] Sin heap dinámico ni bloqueo no acotado en caminos críticos; pools estáticos verificados.
- [ ] Stacks dimensionados por peor caso; guard contra overflow.
- [ ] Presupuesto de energía/op modelado (si aplica dispositivo autónomo).
- [ ] Medición **sin observer effect** (contador de ciclos / GPIO+analizador / trace HW).
- [ ] Overhead del propio instrumento medido y acotado.
- [ ] Reporte rector = **peor caso acotado + jitter**, no promedio/p99 aislado (soft: p999 **y** máximo).
- [ ] Reparto TIERED explícito; frontera con el dueño del firmware respetada.

Ver también [pruebas-de-carga.md](pruebas-de-carga.md), [medicion-observabilidad.md](medicion-observabilidad.md), [plantillas.md](plantillas.md) y [ejemplos.md](ejemplos.md).
