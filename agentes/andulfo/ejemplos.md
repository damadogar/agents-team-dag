# ejemplos.md — Casos modelo (multi-motor)

Estos ejemplos enseñan el **nivel de rigor** de Andulfo, no una tecnología.
Cubren familias distintas a propósito (relacional, NoSQL, analítico) para
reforzar que el método es **universal**. Imita la profundidad, no copies el
motor: aplica el mismo rigor al motor que tengas delante.

Cada caso sigue el flujo: contexto → análisis con evidencia → opciones con
trade-offs → decisión (ADR) → ejecución con rollback → verificación.

---

## Caso 1 — Selección de motor (relacional + búsqueda)

**Contexto.** Catálogo de e-commerce, 8M productos, búsqueda por texto con
errores tipográficos y filtros por atributos; 3k QPS lectura, 50 QPS escritura;
latencia objetivo p99 < 150 ms; equipo pequeño; nube.

**Análisis (patrón de acceso primero).** Dos patrones distintos: (a)
transaccional/consistente (precio, stock, pedidos) → necesita ACID; (b) búsqueda
con relevancia y tolerancia a errores → necesita motor de búsqueda. Un solo
motor sirve mal a ambos.

**Opciones (matriz ponderada, pesos por contexto).**

| Atributo (peso) | Solo PostgreSQL (FTS) | PostgreSQL + Elasticsearch | Solo MongoDB |
|---|---|---|---|
| Ajuste patrón búsqueda (×3) | 3 | 5 | 3 |
| Consistencia transaccional (×3) | 5 | 5 | 3 |
| Complejidad operativa (×2) | 5 | 3 | 4 |
| Costo/TCO (×2) | 5 | 3 | 4 |
| Escalabilidad lectura (×2) | 3 | 5 | 4 |
| **Total** | **40** | **44** | **35** |

**Decisión (resumen ADR).** PostgreSQL como **fuente de verdad** transaccional +
Elasticsearch/OpenSearch para búsqueda, sincronizados por **CDC** (no doble
escritura desde la app). Alternativa de arranque simple: empezar solo con
PostgreSQL FTS y añadir el motor de búsqueda cuando la relevancia/escala lo
exijan (decisión reversible). Trade-off aceptado: mayor complejidad operativa a
cambio de relevancia y escala de lectura.

**Ejecución / rollback.** Fase 1 índices FTS en Postgres (reversible). Fase 2
*pipeline* CDC → índice de búsqueda con *reindex* idempotente; rollback =
apagar el consumidor de búsqueda y servir desde Postgres FTS.

**Verificación.** p99 de búsqueda < 150 ms, *recall* de relevancia validado con
consultas reales, consistencia fuente↔índice < N segundos de lag.

---

## Caso 2 — Tuning de consulta lenta (relacional, agnóstico)

**Contexto.** Endpoint de "pedidos del cliente" tarda 4–8 s; tabla `orders` con
120M filas. Motor RDBMS (el método aplica a cualquiera).

**Análisis con evidencia.** `EXPLAIN ANALYZE` muestra **Seq Scan** sobre
`orders` filtrando por `customer_id` y ordenando por `created_at DESC` con
`LIMIT 20`. No hay índice que sirva al predicado + orden. Además la app pagina
con `OFFSET 10000` (lento por diseño).

```sql
-- Antes (full scan + sort + offset grande)
SELECT * FROM orders
WHERE customer_id = $1
ORDER BY created_at DESC
OFFSET 10000 LIMIT 20;
```

**Solución (genera el comando correcto para el motor/versión, no bloqueante).**

```sql
-- Índice compuesto que cubre filtro + orden (crear sin bloqueo donde aplique)
CREATE INDEX CONCURRENTLY ix_orders_customer_created
  ON orders (customer_id, created_at DESC);
```

```sql
-- Después: paginación por keyset en vez de OFFSET
SELECT * FROM orders
WHERE customer_id = $1 AND created_at < $cursor
ORDER BY created_at DESC
LIMIT 20;
```

**Dry-run / rollback.** Validar plan nuevo con `EXPLAIN` (Index Scan, sin sort).
El índice es **aditivo y reversible**: rollback = `DROP INDEX CONCURRENTLY`.
Sin backup obligatorio (operación no destructiva), pero sí verificación de que
no degrada escrituras.

**Verificación.** p99 del endpoint de ~6 s → <50 ms; plan usa el índice; sin
aumento relevante de latencia de `INSERT`.

---

## Caso 3 — Migración de esquema zero-downtime (expand/contract)

**Contexto.** Renombrar/normalizar columna `user.fullname` → `first_name` +
`last_name` en una tabla con tráfico 24/7. Aplica a cualquier RDBMS.

**Por qué expand/contract.** Un `ALTER` directo + *backfill* en una transacción
bloquearía y no es reversible en caliente. Se hace en fases reversibles.

**Plan (cada fase es desplegable y reversible).**

```
EXPAND
1. Añadir columnas nuevas nullable: ADD first_name, last_name (no bloqueante)
2. App escribe en AMBOS (viejo y nuevos) — código compatible hacia atrás
3. Backfill por lotes: UPDATE ... WHERE id BETWEEN :a AND :b (batches, con pausa)
   - dry-run: SELECT count(*) del rango antes de cada lote
MIGRATE/SWITCH
4. App lee de las columnas nuevas; valida paridad de datos
CONTRACT (despliegue posterior, tras verificación)
5. App deja de escribir en fullname
6. Eliminar columna vieja: DROP COLUMN fullname
```

**Safeguard / rollback.** Backup verificado antes del contract. Rollback por
fase: en EXPAND, basta con que la app vuelva a leer `fullname` (las nuevas
columnas son inertes). El `DROP` (paso 6) es el **punto de no retorno** → solo
tras confirmar paridad 100% y ventana de observación.

**Verificación.** Conteo de filas con `first_name/last_name` poblados = total;
sin errores de la app; latencia y locks normales durante el backfill por lotes.

---

## Caso 4 — Continuidad: definir y probar RPO/RTO (cualquier motor)

**Contexto.** Base Tier-1; negocio exige "no perder más de 5 min y volver en <30
min". Hay backups diarios... pero **nunca se ha probado un restore**.

**Hallazgo (severidad 🔴).** RPO real ≈ 24 h (solo backup diario), no 5 min; RTO
real **desconocido** porque el restore no está probado. Un backup no verificado
no cuenta como protección.

**Decisión.** Activar **PITR** (WAL/binlog/redo continuo) para RPO ≤ 5 min;
añadir **réplica** para failover rápido; implementar **3-2-1-1-0** con copia
inmutable; **probar restore** de forma cronometrada.

**Ejecución / verificación (game day).** Restaurar en instancia aislada a un
punto arbitrario; medir RPO y RTO **reales** y compararlos con el objetivo;
documentar runbook (ver `runbooks.md`). Criterio de éxito: RPO ≤ 5 min y RTO ≤
30 min **demostrados con cronómetro**, no asumidos.

---

> Nota: los motores citados son ilustrativos. Andulfo aplica el **mismo método y
> rigor** a PostgreSQL, MySQL, SQL Server, Oracle, MongoDB, Cassandra, Redis,
> Snowflake, BigQuery, motores vectoriales o cualquier otro — detectando primero
> el motor y su versión (ver `ejecucion.md`).
