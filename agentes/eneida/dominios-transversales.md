# Dominios transversales (cobertura integral)

Áreas que un arquitecto **integral** debe dominar además de la arquitectura de
sistemas, datos y seguridad. Aplica la que el problema requiera; no fuerces todas.

---

## 1. Diseño de APIs e integración

- **Estilo por necesidad**: **REST** (recursos, CRUD, caché HTTP), **GraphQL**
  (clientes con necesidades de datos variables, evita over/under-fetching),
  **gRPC** (baja latencia, contratos fuertes, interno servicio-a-servicio),
  **WebSocket/SSE** (tiempo real), **webhooks/eventos** (asíncrono). Elige por
  consumidor y patrón de tráfico, no por moda.
- **Contrato primero**: OpenAPI/AsyncAPI/Protobuf como fuente de verdad;
  genera SDKs y valida con contract tests (ver `fundamentos-ingenieria.md §7`).
- **Versionado y evolución**: versiona (URI/headers), cambios retro-compatibles
  por defecto, deprecación con calendario y telemetría de uso.
- **Robustez**: paginación (cursor > offset), filtrado/orden, idempotencia
  (claves), rate limiting y cuotas, errores consistentes (RFC 7807 problem+json).
- **Seguridad de API**: authN/authZ por endpoint, validación de entrada, menor
  exposición; revisa **OWASP API Security Top 10** (ver `seguridad-confiabilidad.md`).

---

## 2. Ingeniería y plataforma de datos

- **OLTP vs OLAP**: separa carga transaccional de analítica; no analices sobre
  la BD operativa de producción.
- **Almacenes**: **warehouse** (esquema estructurado, BI), **lakehouse**
  (datos crudos + tablas ACID: Delta/Iceberg/Hudi), **lake** (crudo barato).
- **Movimiento de datos**: **ETL vs ELT**, **batch vs streaming**
  (Kafka/Flink/Spark), **CDC** para replicar sin acoplar (ver
  `modernizacion-y-auditorias.md §4`).
- **Modelado analítico**: estrella/copo de nieve, **dimensional (Kimball)** vs
  **Data Vault**; tablas de hechos y dimensiones; SCD para historia.
- **Gobernanza**: catálogo, **linaje**, calidad de datos (contratos de datos,
  tests tipo Great Expectations), PII/retención/anonimización, **data mesh**
  (dominios dueños de sus datos) cuando la organización lo justifica.
- **MLOps/AIOps**: feature store, versionado de datasets y modelos, despliegue y
  monitoreo de drift (enlaza con `genai-arquitectura.md`).

---

## 3. Arquitectura frontend, UX y multiplataforma

- **Renderizado**: CSR, **SSR**, **SSG**, ISR, edge rendering — elige por SEO,
  TTFB, interactividad y costo. No SPA pesada si una página estática basta.
- **Estructura**: component-driven, design system/tokens, gestión de estado
  proporcional (evita Redux para todo), **micro-frontends** solo con varios
  equipos y dominios claros (mismo criterio que microservicios).
- **Rendimiento percibido**: **Core Web Vitals** (LCP, INP, CLS), code-splitting,
  lazy loading, presupuesto de performance, imágenes/fuentes optimizadas.
- **Calidad de experiencia**: **accesibilidad WCAG 2.2 AA** (no opcional),
  **i18n/l10n**, estados de UI (vacío/cargando/error/lleno), diseño responsive.
- **Móvil/edge**: nativo vs híbrido (React Native/Flutter) vs PWA por
  requisitos de hardware, offline-first, sincronización y consumo de batería.
- **BFF (Backend for Frontend)** para adaptar APIs a cada canal (ver §1).

---

## 4. Rendimiento, escalabilidad y capacidad

- **Mide antes de optimizar**: perfila (CPU, memoria, I/O, locks), encuentra el
  cuello de botella real; cuidado con la optimización prematura.
- **Latencia vs throughput**: define objetivos (p50/p95/p99), presupuestos de
  latencia por salto, ataca la cola (tail latency), no solo el promedio.
- **Escalado**: vertical primero si alcanza; horizontal con estado externalizado;
  **caché** por niveles (cliente/CDN/app/datos) con invalidación pensada.
- **Capacidad**: modela carga (Little's Law), pruebas de carga/estrés/soak,
  autoscaling con señales correctas, **degradación controlada** ante saturación
  (ver `fundamentos-ingenieria.md §4`).
- **Eficiencia algorítmica y de datos**: revisa Big-O, N+1, índices y planes de
  consulta antes de añadir hardware.

---

## 5. FinOps y economía del sistema (TCO)

- **TCO real**: cómputo + almacenamiento + red/egress + licencias + operación +
  personas. El egress y los datos suelen ser el costo oculto.
- **Visibilidad**: etiquetado/tagging, atribución por equipo/feature, alertas de
  presupuesto, **costo por transacción/usuario** como métrica de producto.
- **Optimización**: right-sizing, autoscaling, spot/reservas/savings plans,
  apagar entornos no productivos, tiering de almacenamiento, revisar lock-in.
- **Decisión económica**: build vs buy, gestionado vs self-host, considera el
  costo de oportunidad del equipo, no solo la factura de nube.
- FinOps es una preocupación de diseño, no un ajuste posterior (cruza con AWS/
  Azure WAF "optimización de costos" en `frameworks.md`).

---

## Checklist transversal rápido
```
- [ ] API: contrato primero, versionado, errores consistentes, OWASP API Top 10
- [ ] Datos: OLTP/OLAP separados, gobernanza/linaje, PII y retención
- [ ] Frontend: estrategia de render justificada, Core Web Vitals, WCAG AA, i18n
- [ ] Performance: objetivos p95/p99, perfilado, caché con invalidación, capacidad
- [ ] FinOps: TCO completo, costo por unidad de negocio, right-sizing, sin lock-in ciego
```

## Referencias
- OWASP API Security Top 10: https://owasp.org/API-Security/
- The Data Warehouse Toolkit (Kimball); Designing Data-Intensive Applications (Kleppmann).
- web.dev / Core Web Vitals: https://web.dev/vitals/ ; WCAG 2.2: https://www.w3.org/TR/WCAG22/
- FinOps Foundation: https://www.finops.org/
