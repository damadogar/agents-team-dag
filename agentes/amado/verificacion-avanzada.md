# Verificación avanzada y resiliencia (grado NASA / AWS / sistemas críticos)

Módulo de élite de Amado para **garantizar correctitud y resiliencia más allá del
testing por ejemplos**. Aquí vive lo que hace a AWS y la NASA superiores: métodos
formales, simulación determinista, fuzzing, *property-based*, *mutation testing*,
ingeniería del caos e ingeniería de seguridad/confiabilidad.

> Principio rector: **el testing por ejemplos demuestra la presencia de bugs, no
> su ausencia (Dijkstra).** Para sistemas críticos y distribuidos se combinan
> verificación (formal/propiedades), exploración masiva (fuzz/simulación) y
> análisis de fallos (FMEA/FTA).

---

## 1. Métodos formales (lightweight formal methods)

- **TLA+ / PlusCal:** especificar y *model-check* (TLC) algoritmos concurrentes y
  distribuidos; AWS lo usa en S3, DynamoDB, EBS para hallar bugs de diseño
  imposibles de encontrar por testing.
- **P language** (AWS): modelado de sistemas distribuidos dirigido por eventos.
- **Alloy** (análisis de modelos/estructuras), **SPIN/Promela**, **Coq/Isabelle**
  (prueba de teoremas) en lo más crítico.
- **Cuándo:** protocolos de consenso, concurrencia, *state machines*,
  invariantes de seguridad/consistencia, antes de escribir código.
- **Entregable:** especificación + invariantes + propiedades de *liveness/safety*
  verificadas por *model checker*.

---

## 2. Deterministic Simulation Testing (DST) — diferenciador clave

Estrategia de FoundationDB, TigerBeetle y **Antithesis** (usada por AWS y DBs de
élite). Reemplaza pruebas no deterministas frágiles por **mundos simulados
reproducibles**.

- Todo el I/O (red, disco, reloj, hilos, RNG) es **inyectado y determinista**,
  controlado por una **semilla**.
- El simulador inyecta fallos: particiones de red, latencia, caídas de proceso,
  *clock skew*, disco lleno, mensajes reordenados/duplicados.
- Ejecuta **millones de horas simuladas** comprimidas; al hallar un fallo, la
  **semilla reproduce el bug exactamente** (debugging determinista).
- Verifica **invariantes globales** (consistencia, durabilidad) en cada paso.
- **Por qué es superior:** encuentra *heisenbugs* de concurrencia/distribución que
  jamás aparecen en E2E tradicional, y los hace 100% reproducibles.

---

## 3. Property-based testing (PBT)

- En lugar de ejemplos, define **propiedades/invariantes** y deja que el framework
  genere miles de entradas y **reduzca (*shrink*)** el contra-ejemplo mínimo.
- **Stateful/model-based PBT:** modela el sistema como máquina de estados y
  compara contra un modelo de referencia.
- Propiedades típicas: *round-trip* (encode∘decode=id), idempotencia,
  conmutatividad, monotonicidad, equivalencia con implementación de referencia.
- Herramientas: **Hypothesis** (Python), **QuickCheck** (Haskell), **fast-check**
  (JS/TS), **jqwik** (Java), **PropEr** (Erlang), **proptest** (Rust).

---

## 4. Fuzzing

- **Coverage-guided:** AFL++, **libFuzzer**, go-fuzz/native fuzzing, Jazzer (JVM),
  cargo-fuzz. Mutan entradas guiados por cobertura para hallar *crashes*/UB.
- **Structure-aware / grammar-based:** para parsers y protocolos.
- **Differential fuzzing:** dos implementaciones, misma entrada, salidas distintas
  = bug.
- **Continuous fuzzing:** **OSS-Fuzz** / ClusterFuzz (Google) — fuzzing 24/7.
- **Sanitizers:** ASan, UBSan, **TSan** (data races), MSan, LeakSanitizer.
- Objetivo: *crashes*, *memory safety*, *undefined behavior*, *hangs*, *overflows*.

---

## 5. Mutation testing (mide la calidad de tu suite)

- Introduce mutantes (bugs sintéticos) en el código; un buen test debe "matarlos".
- **Mutation score** = mutantes detectados / total. Revela tests que pasan pero no
  verifican nada (cobertura alta, eficacia baja).
- Herramientas: **Stryker** (JS/.NET/Scala), **PIT** (Java), **mutmut/cosmic-ray**
  (Python), **mull** (LLVM).

---

## 6. Testing de concurrencia y consistencia distribuida

- **Race detection:** TSan, Go race detector, *deterministic schedulers*.
- **Jepsen:** prueba de **linealizabilidad/consistencia** bajo particiones para
  bases de datos y sistemas distribuidos (el estándar de la industria).
- **Lincheck** (JVM) para estructuras concurrentes.
- Verifica garantías declaradas: linearizable, *serializable*, *snapshot
  isolation*, *causal*; detecta violaciones bajo fallo.

---

## 7. Ingeniería del caos / resiliencia

- **Método científico:** define *steady-state hypothesis* (métrica de salud) →
  introduce fallo en *blast radius* acotado → observa → aprende → automatiza.
- **Fallos a inyectar:** caída de instancia/AZ/región, latencia, *packet loss*,
  saturación de CPU/IO, dependencia caída, *clock skew*, *throttling*.
- **Herramientas:** AWS **FIS**, Gremlin, Chaos Mesh, Litmus, Chaos Monkey
  (Simian Army), Toxiproxy.
- **GameDays / DiRT:** simulacros planificados de desastre con el equipo.
- Valida: *circuit breakers*, *retries* con backoff+jitter, *bulkheads*,
  *timeouts*, degradación elegante, *failover*, RTO/RPO reales.

---

## 8. Ingeniería de seguridad y confiabilidad (NASA-grade)

- **FMEA / FMECA:** análisis sistemático de modos de fallo, efectos y criticidad
  (RPN = Severidad × Ocurrencia × Detección) → prioriza pruebas y mitigaciones.
- **FTA (Fault Tree Analysis):** razonamiento *top-down* desde un fallo
  catastrófico hacia causas raíz; identifica *cut sets* mínimos.
- **HAZOP / STPA** (System-Theoretic Process Analysis) para sistemas complejos.
- **Requirements-based testing + trazabilidad total:** cada requisito ↔ prueba ↔
  evidencia (auditable).
- **Cobertura estructural exigente:** **MC/DC** (Modified Condition/Decision
  Coverage) en software crítico de vuelo.
- **Estándares:** DO-178C/DO-330 (aeroespacial), IEC 61508 (funcional), ISO 26262
  (automotriz), NASA-STD-8739 / NPR 7150.2, NASA/JPL **Power of 10**.
- **IV&V (Independent Verification & Validation):** verificación por un equipo
  independiente; *safety case* documentado.

---

## 9. Técnicas para el "problema del oráculo"

- **Metamorphic testing:** relaciones que deben cumplirse entre entradas/salidas
  (ej. ordenar dos veces = ordenar una vez) cuando no hay resultado esperado claro.
- **Differential testing:** comparar contra una implementación de referencia o una
  versión previa.
- **A-B / shadow** contra el sistema en producción.

---

## 10. Combinatorial testing a escala

- **t-way coverage** (NIST): la mayoría de fallos se disparan por interacción de
  ≤6 parámetros. Genera el set mínimo que cubre todas las combinaciones t-way.
- Herramienta: **NIST ACTS**, PICT (Microsoft), Hypothesis estrategias.

---

## 11. Performance/capacidad con base teórica

- **Ley de Little** (L = λW), **Universal Scalability Law** (USL) para modelar y
  predecir saturación; teoría de colas para capacity planning.
- *Soak/endurance* para fugas; *spike* para autoscaling; análisis de *golden
  signals* y *tail latency* (p99/p999).

---

## 12. Checklist de verificación avanzada

```
- [ ] ¿Hay invariantes críticos modelados formalmente (TLA+/P) donde el riesgo lo exige?
- [ ] ¿Sistema distribuido cubierto por DST y/o Jepsen (consistencia bajo fallo)?
- [ ] ¿Property-based testing sobre lógica con invariantes claras?
- [ ] ¿Fuzzing continuo con sanitizers en parsers/entradas no confiables?
- [ ] ¿Mutation score medido para validar la eficacia de la suite?
- [ ] ¿Chaos/GameDays validan resiliencia, failover y RTO/RPO reales?
- [ ] ¿FMEA/FTA hechos para fallos catastróficos; mitigaciones priorizadas (RPN)?
- [ ] ¿Trazabilidad requisito↔prueba↔evidencia y MC/DC en lo crítico?
```
