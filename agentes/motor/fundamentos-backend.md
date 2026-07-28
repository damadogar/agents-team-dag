# fundamentos-backend.md — Fundamentos de ingeniería backend

> Base que el desarrollador maestro domina para **estructurar bien su código** y
> implementar correctamente el estilo que recibe. La **elección del estilo
> arquitectónico (monolito modular, microservicios, EDA, CQRS, etc.) es del
> arquitecto**; aquí los reconoces para implementarlos con fidelidad y aplicas
> SOLID/clean/hexagonal/DDD táctico **dentro** de tu código.

## 1. Principios de diseño

- **SOLID**:
  - *SRP*: una unidad, una razón de cambio. Detecta clases/servicios "dios".
  - *OCP*: extiende sin modificar (estrategias, polimorfismo, plugins).
  - *LSP*: subtipos sustituibles sin romper invariantes.
  - *ISP*: interfaces específicas; evita interfaces gordas.
  - *DIP*: depende de abstracciones; la infraestructura depende del dominio.
- **Cohesión alta / acoplamiento bajo**: medida real de mantenibilidad. Acopla
  por contratos estables, no por detalles internos.
- **KISS / YAGNI / DRY (con criterio)**: DRY aplica a conocimiento, no a líneas;
  la duplicación incidental es preferible al acoplamiento erróneo.
- **Separación de responsabilidades por capas/puertos**: dominio puro, casos de
  uso, adaptadores de entrada/salida.
- **Ley de Conway**: la arquitectura tiende a copiar la estructura organizativa;
  diséñala a propósito (inverse Conway maneuver).

## 2. Estilos arquitectónicos (reconócelos para implementarlos)

> La elección la hace el arquitecto; tú identificas el estilo recibido, lo
> implementas con fidelidad y conoces su costo para construir bien y advertir
> riesgos. La columna "Úsalo cuando" es para que entiendas la intención del diseño.

| Estilo | Intención (cuándo se elige) | Costo / riesgo al implementar |
|--------|--------------|----------------|
| **Monolito modular** (default) | La mayoría de productos; equipo único o pocos equipos; quieres simplicidad operativa con límites internos claros | Disciplina para no romper módulos; despliegue acoplado |
| **Layered (n-capas)** | CRUD, dominios simples, equipos junior | Tiende a anémico; lógica fugada a controllers/DB |
| **Hexagonal / Ports & Adapters** | Dominio rico, múltiples integraciones, alta testabilidad | Más boilerplate; sobra en CRUD trivial |
| **Clean / Onion** | Igual que hexagonal con regla de dependencias estricta | Curva de aprendizaje; sobreingeniería si se aplica dogmática |
| **DDD táctico+estratégico** | Dominio complejo, lenguaje ubicuo, varios bounded contexts | Caro sin experto de dominio; no para CRUD |
| **Event-Driven (EDA)** | Desacople real, picos, integración asíncrona, auditoría | Consistencia eventual, debugging y orden de eventos |
| **CQRS** | Lectura/escritura con cargas y modelos muy distintos | Doble modelo, sincronización, complejidad |
| **Event Sourcing** | Auditoría total, time-travel, reconstrucción de estado | Versionado de eventos, snapshots, proyecciones, difícil |
| **Microservicios** | Escala/despliegue independiente real + equipos estables + límites = bounded contexts | Operación distribuida, latencia, consistencia, observabilidad |
| **Modular monolith → extracción** | Camino evolutivo recomendado: empieza modular, extrae cuando duela | Requiere límites bien dibujados desde el día 1 |

**Si el arquitecto no especificó el estilo** y necesitas uno para empezar,
**escala la duda**; si debes asumir, asume el más simple razonable (monolito
modular con límites de dominio claros) y **decláralo como supuesto**. No decidas
arquitectura de forma silenciosa.

## 3. Patrones de diseño relevantes en backend

- **GoF útiles**: Strategy, Factory, Builder, Adapter, Decorator, Observer,
  Template Method, Command, State, Chain of Responsibility, Repository (no GoF),
  Unit of Work, Specification.
- **Patrones de aplicación**: Service Layer, DTO/Mapper, Anti-Corruption Layer,
  Domain Events, Aggregate, Value Object.
- **Patrones distribuidos**: ver [escalabilidad-resiliencia.md](escalabilidad-resiliencia.md) y la
  tabla de consistencia abajo: Saga, Outbox, Inbox, CDC, Idempotent Receiver,
  Transactional Outbox, Sidecar, Ambassador, BFF, API Gateway, Circuit Breaker,
  Bulkhead, Retry, Leader Election, Sharding, Materialized View.

## 4. Fundamentos de sistemas distribuidos

- **Falacias de la computación distribuida**: la red NO es confiable, ni con
  latencia cero, ni ancho de banda infinito, ni segura, ni topología fija.
  Diseña asumiendo fallos parciales.
- **CAP**: bajo partición (P) eliges Consistencia o Disponibilidad. En la
  práctica usa **PACELC** (si Partición → A/C; Else → Latencia/Consistencia).
- **Modelos de consistencia**: fuerte, lineal, secuencial, causal, *read-your-
  writes*, monotónica, eventual. Elige el más débil que cumpla el requisito.
- **Tiempo y orden**: relojes lógicos (Lamport), vector clocks; no confíes en
  relojes de pared para ordenar eventos distribuidos.
- **Consenso**: Raft/Paxos para liderazgo y estado replicado (lo usa etcd,
  Kafka KRaft, etc.). No lo implementes a mano; usa primitivas probadas.
- **Quórum**: R + W > N para lecturas/escrituras consistentes en sistemas de
  réplica.

## 5. Idempotencia, exactly-once y entrega

- **At-most-once / at-least-once / exactly-once**: exactly-once de extremo a
  extremo no existe gratis; se logra con **at-least-once + idempotencia** o
  **deduplicación** (claves de idempotencia, secuencias, dedupe store).
- **Idempotencia**: operaciones repetibles sin efecto adicional. Usa
  `Idempotency-Key` en APIs de escritura, upserts deterministas, y
  `processed_message_id` en consumidores.
- **Outbox + relay**: escribe el evento en la misma transacción que el cambio de
  estado; un relay/CDC lo publica. Evita doble escritura DB+broker inconsistente.

## 6. Concurrencia y transacciones (resumen; detalle en datos-persistencia.md)

- **Optimista** (versión/ETag) vs **pesimista** (locks). Optimista escala mejor
  con baja contención.
- **Niveles de aislamiento**: Read Committed (default sensato), Repeatable Read,
  Serializable. Conoce anomalías: dirty/non-repeatable/phantom, write skew.
- **Idempotencia + transacciones locales + saga** para coordinar across-service
  (evita 2PC salvo casos muy acotados).

## 7. Tolerancia a fallos (resumen; detalle en escalabilidad-resiliencia.md)

Diseña para el fallo: timeouts en TODA llamada remota, retries con backoff
exponencial + jitter (solo en operaciones idempotentes), circuit breakers,
bulkheads, fallbacks y *graceful degradation*. Un fallo de dependencia no debe
tumbar el sistema entero.

## 8. Olores y anti-patrones backend

- Modelo de dominio anémico con lógica en servicios/controllers.
- Base de datos compartida entre servicios (acoplamiento oculto).
- "Distributed monolith": microservicios que despliegan/cambian juntos.
- Llamadas síncronas en cadena profunda (latencia y fallos acumulados).
- Falta de idempotencia en consumidores/reintentos.
- God service / God table. Lógica en triggers ocultos. N+1 queries.
- Reintentos sin backoff (tormentas de reintentos / retry storms).

## 9. Cómo aplicarlo al implementar (heurística rápida)

1. Entiende el **dominio e invariantes** del encargo y respétalos en el código.
2. Ubica tu cambio dentro del **bounded context / módulo** definido; no cruces
   límites que el diseño separó.
3. Implementa el **estilo recibido** con fidelidad (capas/puertos/adaptadores).
4. Respeta los **contratos** (API/eventos) y los **límites de transacción** dados.
5. Implementa la **consistencia por operación** que se especificó (no global).
6. Codifica para **fallo e idempotencia** desde el primer endpoint.
