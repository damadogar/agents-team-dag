# escalabilidad-resiliencia.md — Implementar escalabilidad y resiliencia

> El **arquitecto decide** la estrategia (réplicas vs sharding, qué cola, qué
> cache, modelo de consistencia, objetivos de escala). Este archivo es para
> **implementarla con maestría** en código. Si la estrategia recibida tiene un
> defecto, **escálalo al arquitecto/orquestador** con datos; no la cambies por tu
> cuenta.

## 1. Aterrizar el diseño recibido

Antes de codificar, confirma del diseño: objetivos de carga (RPS, latencia p99,
SLA), modelo de consistencia esperado por operación, y los componentes que debes
implementar (réplicas/sharding/cache/colas). Si falta un dato crítico,
márcalo **[SUPUESTO]** o escálalo.

> Números útiles para razonar tu implementación: memoria ~ns, SSD ~µs-100µs, red
> intra-DC ~0.5ms, inter-región ~decenas-cientos ms. Un nodo bien usado sirve
> miles de RPS simples. Mide, no adivines.

## 2. Implementar para escalar

- **Stateless**: no guardes estado de sesión en memoria del proceso; externalízalo
  (cache/DB) para permitir el autoscaling que el diseño asume.
- **Sharding/particionamiento**: implementa la **clave de partición** que se
  definió; si no se definió y la necesitas, propónla (estable, alta cardinalidad)
  y escala la duda. Cuida hot partitions.
- **Read scaling**: implementa correctamente lectura desde réplicas (cuida
  *read-your-writes* y lag), materialized views o el lado de lectura de CQRS.
- **Write scaling**: batching, colas para absorber picos, escritura por partición.
- **Connection pooling** dimensionado y con límites; nunca abras conexiones sin
  control.

## 3. Caching (implementación correcta)

- **Patrón**: implementa el indicado (cache-aside es el más común; read-through,
  write-through, write-behind, refresh-ahead).
- **Niveles**: cliente, CDN/edge, gateway, app (local/L1), distribuido (Redis/
  Memcached, L2), buffer pool de la DB.
- **Invalidación (lo difícil)**: implementa TTL, versionado de claves o
  invalidación por evento según la consistencia esperada. Documenta qué garantiza.
- **Protege contra**: *stampede/thundering herd* (lock/single-flight, TTL con
  jitter, recompute temprano), *cache penetration* (cachear negativos), *hot key*.
  Expón el **hit ratio** como métrica.

## 4. Resiliencia (patrones de estabilidad — impleméntalos siempre)

- **Timeouts** en TODA llamada remota (DB, HTTP, broker). Sin timeout = fuga de
  recursos. Respeta el presupuesto de latencia por capa.
- **Retries** solo en operaciones idempotentes; backoff exponencial + **jitter**;
  límite de intentos; respeta `Retry-After`. Evita retry storms (token bucket).
- **Circuit breaker**: abre tras N fallos, prueba en half-open; evita cascadas.
- **Bulkhead**: aísla pools por dependencia/tenant.
- **Backpressure**: colas acotadas, 429 controlado, load shedding; no colapses.
- **Rate limiting**: token/leaky bucket o sliding window, por usuario/API key/IP.
- **Fallback / degradación elegante**: respuesta parcial, datos cacheados, flags.
- **Idempotencia + DLQ** para reintentos seguros.

## 5. Alta disponibilidad y recuperación (lo que implementas)

- **Health checks**: liveness vs readiness correctos; **graceful shutdown** (drena
  conexiones, termina trabajos en curso ante SIGTERM).
- **Failover**: implementa reconexión, reintentos y tolerancia a promoción de
  réplica; evita asumir un único primario fijo.
- **Migraciones/restores**: aplica RPO/RTO definidos; escribe migraciones
  reversibles y verifica que el restore funcione (ver
  [datos-persistencia.md](datos-persistencia.md)).
- (La topología HA —multi-AZ/multi-región, activo-pasivo/activo-activo— la define
  el arquitecto; tú implementas el código compatible con ella.)

## 6. Balanceo y enrutamiento (a nivel de cliente/servicio)

- **Connection pooling**, reintentos a través de varios endpoints, y **hashing
  consistente** cuando tu código distribuye trabajo/cache para minimizar remapeo
  al escalar. El LB de infraestructura lo define la plataforma.

## 7. Procesamiento asíncrono, colas y streaming (implementación)

- Implementa **consumidores idempotentes** (at-least-once es lo normal); dedupe
  por id; respeta que el orden solo existe dentro de partición/clave.
- **Cola de tareas** (RabbitMQ/SQS): reintentos, DLQ, prioridad para jobs/comandos.
- **Log de eventos** (Kafka/Kinesis/Pulsar): particiones, grupos de consumidores,
  manejo de offset, retención/replay para streaming/CDC/event sourcing.
- **Patrones**: competing consumers, pub/sub, fan-out, scatter-gather, saga,
  **outbox** (publica eventos en la misma transacción), claim-check para payloads
  grandes.
- Expón **consumer lag** y errores de DLQ como métricas.

## 8. Antipatrones de implementación (evítalos)

- Estado en memoria del proceso que impide scale-out.
- Hot key/partición por mala implementación de la clave.
- Cache sin invalidación clara → datos rancios silenciosos.
- Llamadas síncronas en abanico profundo (latencia y fallos acumulados).
- Reintentos sin idempotencia ni backoff (retry storms).
- Olvidar timeouts, graceful shutdown o límites de pool.

## 9. Checklist de implementación

```
- [ ] Confirmé objetivos de carga/consistencia del diseño recibido
- [ ] Servicios stateless; estado externalizado
- [ ] Implementé réplicas/sharding/cache según lo especificado, con su clave/TTL
- [ ] Consumidores asíncronos idempotentes + DLQ; manejo de offset correcto
- [ ] Timeouts, retries con jitter, circuit breaker, bulkhead, rate limit
- [ ] Health checks (liveness/readiness) + graceful shutdown
- [ ] Backpressure y degradación elegante ante sobrecarga
- [ ] Métricas de saturación (USE/RED), hit ratio de cache y consumer lag
- [ ] Migraciones reversibles; restore verificado
- [ ] Escalé al arquitecto cualquier defecto del diseño detectado al implementar
```
