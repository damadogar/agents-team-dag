# apis-integracion.md — Implementar APIs e integraciones

> Para **implementar** APIs según el contrato recibido y hacerlas robustas. El
> **estilo (REST/GraphQL/gRPC/eventos) y el contrato suelen venir definidos por el
> arquitecto**; la tabla §1 es para entender la elección y, si falta el contrato,
> proponerlo y escalarlo. Tu maestría está en construir la API correctamente.

## 1. Estilo de API (lo define el arquitecto; entiende el porqué)

| Estilo | Úsalo cuando | Evítalo cuando |
|--------|--------------|----------------|
| **REST/HTTP+JSON** | APIs públicas, CRUD, amplia interoperabilidad, caching HTTP | Necesitas streaming bidireccional o contratos binarios estrictos |
| **GraphQL** | Clientes diversos con necesidades de datos variables; agregación de múltiples fuentes; evitar over/under-fetching | Caching simple por URL; equipos sin experiencia; riesgo de queries costosas (N+1, profundidad) |
| **gRPC (HTTP/2 + Protobuf)** | Comunicación interna servicio-a-servicio, baja latencia, contratos fuertes, streaming | APIs públicas de navegador sin gateway; debuggability con curl |
| **WebSockets / SSE** | Tiempo real, push, chat, dashboards en vivo | Request/response simple (overkill) |
| **Webhooks** | Notificar a terceros de eventos (event-driven hacia afuera) | Cuando necesitas respuesta inmediata o garantías fuertes sin reintentos |
| **Async/eventos (AMQP/Kafka)** | Integración desacoplada, alto throughput, EDA | Cuando el llamador necesita respuesta sincrónica inmediata |

Regla: **gRPC internamente, REST/GraphQL en el borde** es una combinación común.
Un API Gateway/BFF puede traducir entre ellos.

## 2. Diseño REST de calidad

- **Recursos** sustantivos en plural (`/orders/{id}`), verbos HTTP correctos
  (GET seguro/idempotente, PUT/DELETE idempotentes, POST no idempotente salvo
  `Idempotency-Key`).
- **Códigos de estado** correctos: 200/201/202/204, 400/401/403/404/409/422/429,
  500/502/503/504. No devuelvas 200 con error en el body.
- **Errores estructurados**: usa **RFC 9457 (Problem Details)** con `type`,
  `title`, `status`, `detail`, `instance`, y un código de error estable.
- **Paginación**: cursor-based (preferido para grandes/cambiantes) vs offset;
  documenta límites. **Filtrado/ordenación** consistentes.
- **Idempotencia**: `Idempotency-Key` en POST de escritura; almacena resultado.
- **Concurrencia**: ETag + `If-Match` (optimista) para evitar lost updates.
- **HATEOAS** solo si aporta; rara vez necesario.
- **Caching HTTP**: `Cache-Control`, `ETag`, `Last-Modified`.
- **Consistencia**: convención de nombres, formatos de fecha (ISO-8601/UTC),
  manejo de zonas horarias, dinero como entero menor o decimal (no float).

## 3. Contratos primero (contract-first)

- **OpenAPI** (REST), **AsyncAPI** (eventos/mensajería), **Protobuf** (gRPC).
- Genera servidores/clientes/mocks/validación desde el contrato; el contrato es
  la fuente de verdad. Versiona el contrato en el repo.
- **Contract testing** (consumer-driven, p.ej. Pact) para evitar romper
  consumidores: diseña el contrato pensando en él; la **definición y ejecución de
  los contract tests la lidera el QA (`amado`)**.

## 4. Versionado y compatibilidad

- **Backward compatibility** es el objetivo: agregar campos opcionales, no quitar
  ni cambiar semántica. Cambios incompatibles → nueva versión.
- **Estrategias**: versión en URL (`/v1/`), en header, o por content negotiation.
  URL es la más simple y visible.
- **Deprecación**: anuncia, da ventana, mide uso, header `Deprecation`/`Sunset`,
  documenta migración. Soporta N y N-1.
- **Eventos**: versiona esquemas (Schema Registry, compatibilidad
  backward/forward/full); evita romper consumidores.

## 5. API Gateway y BFF

- **Gateway**: punto único para authn/authz, rate limiting, routing, TLS
  termination, agregación, observabilidad, transformación. No metas lógica de
  negocio ahí.
- **BFF (Backend for Frontend)**: una fachada por tipo de cliente (web, móvil)
  para adaptar payloads y reducir round-trips. Cuidado con duplicar lógica. Motor
  **construye** el BFF/API; el cliente lo **consume**: el cliente web es de `farola`,
  el de app móvil nativa/cross-platform es de `palma`.

## 6. Service mesh

- Cuando hay muchos microservicios: mTLS, retries/timeouts/circuit breaking,
  traffic shaping (canary), observabilidad — fuera del código (sidecar/Istio,
  Linkerd) o sin sidecar (eBPF/Cilium). **No lo adoptes** si tienes pocos
  servicios; añade complejidad operativa.

## 7. Integración con terceros (resiliente)

- **Timeouts + retries idempotentes + circuit breaker** en cada integración.
- **Webhooks entrantes**: verifica firma (HMAC), valida, responde rápido (202) y
  procesa async; idempotencia por event id; tolera reentregas.
- **Webhooks salientes**: reintentos con backoff, DLQ, firma, registro de
  entregas, endpoint de reintento manual.
- **Anti-Corruption Layer**: aísla el modelo externo del dominio propio.
- **Sandbox/feature flags** para integrar sin afectar producción.
- **Rate limits del proveedor**: respeta cuotas, implementa colas y backoff.

## 8. Orquestación vs coreografía

- **Orquestación**: un coordinador central dirige el flujo (saga orquestada).
  Más visible y fácil de razonar; punto central de cambio.
- **Coreografía**: servicios reaccionan a eventos sin coordinador. Más desacoplado
  pero más difícil de seguir el flujo end-to-end. Combina con buena observabilidad.
- Para sagas distribuidas define **compensaciones** por paso (no hay rollback
  global). Ver outbox/saga en [datos-persistencia.md](datos-persistencia.md).

## 9. Seguridad de APIs (resumen; detalle en seguridad-backend.md)

OAuth2/OIDC para autorización, validación estricta de entrada, rate limiting,
CORS correcto, no exponer datos sensibles, OWASP API Security Top 10 (BOLA/IDOR
es el #1: valida ownership en cada acceso a recurso).

## 10. Checklist de API

```
- [ ] Estilo confirmado por el arquitecto (REST/GraphQL/gRPC/eventos); lo implemento fiel
- [ ] Contrato (OpenAPI/AsyncAPI/Proto) como fuente de verdad + contract tests (→ amado)
- [ ] Errores RFC 9457; códigos de estado correctos
- [ ] Idempotencia en escrituras; ETag/If-Match para concurrencia
- [ ] Paginación/filtrado/orden consistentes
- [ ] Versionado y política de deprecación definidos
- [ ] Authz a nivel de objeto (anti-BOLA), rate limiting, validación de entrada
- [ ] Integraciones con timeout/retry/circuit breaker + DLQ
- [ ] Observabilidad: logs/trace por request id, métricas RED
```
