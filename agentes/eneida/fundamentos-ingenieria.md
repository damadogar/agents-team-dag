# Fundamentos de Ingeniería de Software

Bases sólidas que Eneida aplica por debajo de cualquier arquitectura. El diseño
correcto de datos y la elección algorítmica suelen pesar más que el código.

---

## 1. Estructuras de datos y complejidad

- Razona **Big-O** en tiempo y espacio; evita complejidad oculta (bucles
  anidados, N+1, serialización repetida, copias innecesarias).
- Estructuras base y cuándo usarlas: array/lista, **hash map/set** (acceso O(1)
  amortizado), árbol balanceado/**B-Tree** (rango/orden, índices), **heap/
  priority queue**, **grafo** (relaciones/rutas), **trie** (prefijos), **LRU/
  LFU cache**, **bloom filter** (pertenencia probabilística), **skip list**.
- Elige por patrón de acceso, no por costumbre. Mide antes de optimizar; evita
  optimización prematura pero también la pereza algorítmica.

## 2. Concurrencia, paralelismo y estado

- Distingue **concurrencia** (estructura) de **paralelismo** (ejecución).
- Modelos: threads + locks, async/await (I/O-bound), actores/CSP (mensajes),
  paralelismo de datos (CPU-bound).
- Peligros: condiciones de carrera, deadlock/livelock, contención, falsa
  compartición. Prefiere **inmutabilidad** y estado compartido mínimo.
- **Idempotencia** en operaciones reintetables; claves de idempotencia en APIs.
- Backpressure y límites (timeouts, bulkheads, colas acotadas).

## 3. Datos, transacciones y consistencia

- **ACID** vs **BASE**; entiende **CAP/PACELC** para sistemas distribuidos.
- Niveles de aislamiento y anomalías (dirty/non-repeatable/phantom reads).
- Consistencia: fuerte, eventual, causal, read-your-writes. Elige por requisito,
  no por defecto.
- Patrones distribuidos de datos: **Saga** (transacciones largas),
  **Outbox/Inbox** (mensajería confiable), **CDC**, **event sourcing**,
  **CQRS**, **idempotent consumer**, **2PC** (evítalo salvo necesidad real).
- Particionamiento/**sharding**, replicación, índices, desnormalización con
  criterio. Modela por **consultas**, no solo por entidades.

## 4. Tolerancia a fallos y resiliencia

- Asume que todo falla. Patrones: **retry con backoff + jitter**, **circuit
  breaker**, **timeout**, **bulkhead**, **fallback/degradación controlada**,
  **rate limiting**, **graceful shutdown**, **health checks**.
- Diseña para recuperación (RTO/RPO), no solo para evitar el fallo.

## 5. Patrones de diseño

- **GoF**: creacionales (Factory, Builder, Singleton con cautela), estructurales
  (Adapter, Facade, Decorator, Proxy, Composite), de comportamiento (Strategy,
  Observer, Command, State, Template Method, Chain of Responsibility).
- **Distribuidos/integración**: API Gateway, BFF, Sidecar, Ambassador,
  Anti-Corruption Layer, Strangler Fig, Saga, Outbox, Competing Consumers,
  Publish/Subscribe, Materialized View.
- Aplica el patrón por la fuerza que resuelve, no por exhibirlo.

## 6. Principios y arquitectura limpia

- **SOLID** (SRP, OCP, LSP, ISP, DIP) como guía, no como religión.
- **Clean / Hexagonal (Ports & Adapters) / Onion**: dominio en el centro,
  dependencias hacia adentro; infraestructura intercambiable.
- Cohesión alta, **acoplamiento bajo**, módulos con límites claros (alineados a
  bounded contexts cuando aplique).
- DRY con criterio (evita abstracción prematura); composición sobre herencia.

## 7. Estrategia de pruebas (testing)

- **Pirámide**: muchas unitarias, menos de integración, pocas E2E. Evita el
  "cono de helado" (demasiadas E2E frágiles).
- **Contract testing** entre servicios; **property-based** para lógica compleja;
  pruebas de carga/caos para resiliencia.
- Tests como **contrato y documentación**; AC verificables; datos de prueba
  deterministas; CI que bloquea ante fallos.
- Cobertura como señal, no como meta: prioriza rutas críticas y casos borde.

## 8. Refactorización y deuda técnica

- Refactor **estratégico y continuo**, en pasos pequeños y verdes (tests).
- Haz la **deuda técnica visible** (registro), clasifícala (deliberada/
  inadvertida, prudente/imprudente) y **presupuéstala** (% de capacidad).
- Prioriza por interés compuesto: lo que frena la entrega o eleva el riesgo
  primero. Acompaña cambios grandes con **Strangler Fig**.

---

## Referencias
- Designing Data-Intensive Applications (Kleppmann).
- Patterns of Enterprise Application Architecture (Fowler); refactoring.com.
- Release It! (Nygard) — patrones de estabilidad/resiliencia.
- Clean Architecture (Martin); Domain-Driven Design (Evans).
