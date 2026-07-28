# stacks-tecnologias.md — Dominio de tecnologías backend (para implementarlas)

> **La elección del stack la hace el arquitecto/orquestador.** Tu trabajo es
> **dominar la herramienta elegida y usarla como un experto**: conocer sus
> fortalezas, trampas, idiomática y riesgos para implementar bien. Conoce el resto
> del panorama para **cuestionar con datos** una elección inadecuada (la decisión
> sigue siendo del arquitecto). Verifica versiones/APIs actuales con búsqueda web
> antes de afirmar detalles que cambian. Mantente **neutral**.
>
> Las **herramientas de pruebas** (UI/API/carga/seguridad-DAST) las elige y
> ejecuta `amado`.

## 1. Criterios para evaluar/cuestionar una tecnología

Cuando debas justificar idoneidad o cuestionar una elección, pondera: ajuste al
problema · escala/latencia objetivo · madurez del equipo (lo que opera bien) ·
ecosistema/librerías · rendimiento real · costo (TCO) · operabilidad y
observabilidad · seguridad · comunidad y soporte · lock-in · time-to-market. **El
stack que el equipo opera con excelencia suele ganar al "técnicamente superior"
que no domina.** Entrega esta evaluación al arquitecto; no decidas tú el cambio.

## 2. Lenguajes backend (perfil, no ranking)

| Lenguaje | Fuerte en | Considera con cuidado |
|----------|-----------|------------------------|
| **Java / Kotlin** (JVM) | Empresa, alto throughput, ecosistema enorme, concurrencia (virtual threads) | Verbosidad (Java), arranque/memoria (mejora con GraalVM) |
| **C# / .NET** | Empresa, rendimiento alto, gran tooling, multiplataforma | Percepción de lock-in (ya no real); ecosistema MS |
| **Go** | Servicios concurrentes, binarios simples, cloud-native, baja latencia | Menos abstracción/genéricos tardíos; ergonomía de errores |
| **Node.js / TypeScript** | IO-bound, real-time, full-stack TS, velocidad de desarrollo | CPU-bound; disciplina de tipos/async; fatiga de ecosistema |
| **Python** | Productividad, data/ML/IA, scripting, prototipos | CPU-bound y concurrencia (GIL; mejora en 3.13+); rendimiento puro |
| **Rust** | Rendimiento extremo, seguridad de memoria sin GC, sistemas | Curva alta, velocidad de desarrollo; úsalo donde el perf importa |
| **Elixir/Erlang (BEAM)** | Concurrencia masiva, fault-tolerance, real-time | Nicho de talento; ecosistema más pequeño |

Heurística: para la mayoría de servicios de negocio, **Java/Kotlin, C#/.NET, Go o
Node/TS** son elecciones sólidas; elige por equipo y ecosistema. Reserva Rust para
hot paths; Python brilla en IA/data.

## 3. Frameworks (por lenguaje, ejemplos)

- JVM: Spring Boot (completo, estándar de facto), Quarkus/Micronaut (cloud-native,
  arranque rápido), Ktor (Kotlin).
- .NET: ASP.NET Core (minimal APIs o MVC).
- Go: net/http + chi, Echo, Fiber, Gin; gRPC.
- Node/TS: NestJS (estructurado, DI), Fastify (rápido), Express (minimal).
- Python: FastAPI (async, tipado, OpenAPI), Django (batteries-included), Flask.
- Regla: framework "completo" para equipos que valoran convención; "minimal" para
  control/rendimiento. No mezcles sin razón.

## 4. Bases de datos

Ver decisión detallada en [datos-persistencia.md](datos-persistencia.md). Resumen:
- **Relacional por defecto**: PostgreSQL (versátil, extensible: JSONB, pgvector,
  PostGIS), MySQL, SQL Server, Oracle.
- **Documental**: MongoDB. **KV/cache**: Redis. **Wide-column**: Cassandra/Scylla.
- **Search**: Elasticsearch/OpenSearch. **Time-series**: Timescale/Influx.
- **OLAP**: ClickHouse/BigQuery/Snowflake. **NewSQL**: CockroachDB/Spanner/Yugabyte.
- **Grafo**: Neo4j. Usa **polyglot persistence** con criterio (una fuente de verdad
  + complementos), no por colección de juguetes.

## 5. Mensajería / streaming

| Tecnología | Úsala cuando | Riesgos |
|------------|--------------|---------|
| **Kafka / Pulsar / Kinesis** | Alto throughput, event streaming, replay, CDC, event sourcing | Complejidad operativa; overkill para colas simples |
| **RabbitMQ** | Colas de tareas, routing flexible, prioridad, RPC | Throughput menor que Kafka para streaming masivo |
| **SQS / Pub-Sub / Service Bus** | Colas gestionadas sin operar infra | Lock-in; límites del servicio |
| **NATS / NATS JetStream** | Mensajería ligera, baja latencia, edge | Ecosistema menor |
| **Redis Streams** | Casos simples cuando ya usas Redis | No reemplaza un broker dedicado a escala |

Regla: **cola de tareas** (RabbitMQ/SQS) vs **log de eventos** (Kafka) son cosas
distintas; úsalas según la semántica que el arquitecto definió (ver
[escalabilidad-resiliencia.md](escalabilidad-resiliencia.md)).

## 6. Caches

- **Redis** (estructuras ricas, pub/sub, persistencia opcional, Lua, cluster) vs
  **Memcached** (cache puro, multihilo, simple). Redis es el default versátil.
- Cache local (Caffeine/in-proc) como L1 + Redis como L2. Define invalidación.

## 7. Búsqueda

- Elasticsearch/OpenSearch (full-text, agregaciones, kNN), Meilisearch/Typesense
  (simples, rápidos para casos medianos), pgvector/Postgres FTS si la escala es
  moderada y quieres una sola pieza. Mantén la DB como fuente de verdad y
  sincroniza por CDC.

## 8. Observabilidad (stack)

- **OpenTelemetry** para instrumentar (neutral). Backends: Prometheus + Grafana +
  Loki + Tempo (open source), o Datadog/New Relic/Honeycomb/Dynatrace (gestionado).
  Elige por costo, operación y necesidades. Ver
  [observabilidad-operacion.md](observabilidad-operacion.md).

## 9. CI/CD y contenedores

- CI/CD: GitHub Actions, GitLab CI, Jenkins, Argo CD/Flux (GitOps), CircleCI,
  Azure DevOps. Elige por dónde vive el código y capacidad operativa.
- Contenedores/orquestación: Docker/OCI + Kubernetes (EKS/AKS/GKE) cuando se
  justifique; Cloud Run/Fargate/PaaS para menos operación. Ver
  [cloud-plataforma.md](cloud-plataforma.md).
- IaC: Terraform/OpenTofu (multi-nube), Pulumi, Bicep/CDK (nativo).

## 10. Seguridad (herramientas)

- SAST: Semgrep, CodeQL, SonarQube. SCA: Snyk, Dependabot, `npm/pip/maven audit`.
- Secretos: gitleaks, trufflehog (detección); Vault/Secrets Manager (gestión).
- Contenedores: Trivy/Grype (escaneo), cosign (firma), Syft (SBOM).
- Policy: OPA/Conftest. Ver [seguridad-backend.md](seguridad-backend.md).
- *DAST, fuzzing y pentest* (OWASP ZAP, restler, etc.) son **herramientas de
  pruebas que ejecuta el QA (`amado`)**; Motor cablea SAST/SCA/escaneo de
  secretos/imágenes en el pipeline y corrige los hallazgos.

## 11. Antipatrones de selección

- Elegir por hype/CV-driven development.
- Adoptar microservicios/K8s/Kafka sin necesidad ni capacidad operativa.
- "Polyglot" sin gobierno (cada equipo su stack) → costo de operación insostenible.
- Ignorar TCO y curva de aprendizaje. Reescrituras totales sin estrangulamiento.
- Lock-in inconsciente (no necesariamente malo, pero decídelo a propósito).

## 12. Marco para evaluar (y entregar al arquitecto)

```
1. ¿Qué problema y qué atributos de calidad priorizo? (top 3)
2. ¿Qué escala/latencia hoy y a 12 meses?
3. ¿Qué opera bien el equipo? ¿Qué soporte/comunidad hay?
4. 2-3 opciones → matriz de trade-offs (ajuste, perf, costo, riesgo, TTM)
5. **Recomienda** al arquitecto la más simple que cumpla (con la matriz); la decisión y el ADR son suyos. Evita lock-in duro al implementar.
```
