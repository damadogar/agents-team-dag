# ejecucion.md — Método universal de ejecución (cualquier motor, cualquier versión)

Andulfo **no depende de scripts fijos por motor**. Aplica este **método** para
producir y ejecutar el procedimiento correcto sobre **cualquier** base de datos
conocida o de vanguardia. Lo global no es el comando: es el método de generar el
comando correcto, seguro y verificable para lo que tengas delante.

> Principio rector: **detectar antes de actuar; leer antes de escribir; probar
> antes de aplicar; poder revertir antes de tocar producción.**

---

## 1. Flujo universal (DETECT → PLAN → DRY-RUN → SAFEGUARD → EXECUTE → VERIFY → ROLLBACK)

```
1. DETECT  : motor, versión/edición, entorno (prod/no-prod), criticidad del dato
2. PLAN    : generar el comando/script EXACTO para ese motor+versión
3. DRY-RUN : ejecutar solo lectura/EXPLAIN/--dry-run; estimar impacto y bloqueos
4. SAFEGUARD: backup/snapshot verificado + plan de rollback listo (si hay escritura)
5. EXECUTE : aplicar el cambio mínimo y reversible (con aprobación si es prod)
6. VERIFY  : confirmar resultado con evidencia (conteos, SLIs, integridad)
7. ROLLBACK: revertir si la verificación falla o se cruza el criterio de aborto
```

Regla de oro: **si no puedes completar el paso 4 (safeguard + rollback), no
ejecutas escritura.** Solo se permite lectura.

---

## 2. Paso DETECT — descubrir antes de generar nada

Nunca asumas el motor. Detéctalo con la señal disponible (cadena de conexión,
herramienta MCP, salida de versión, archivos del repo). Comandos típicos de
identificación de versión (elige el del motor real):

| Familia | Cómo identificar versión |
|---|---|
| PostgreSQL | `SELECT version();` · `SHOW server_version;` |
| MySQL/MariaDB | `SELECT VERSION();` |
| SQL Server | `SELECT @@VERSION;` |
| Oracle | `SELECT * FROM v$version;` |
| MongoDB | `db.version()` |
| Redis | `INFO server` |
| Cassandra/Scylla | `SELECT release_version FROM system.local;` |
| Elasticsearch/OpenSearch | `GET /` |
| Snowflake/BigQuery/Redshift | función/UI de versión del proveedor |

Con motor **y** versión exactos, genera sintaxis válida para *esa* versión
(features y flags cambian entre versiones). Si no puedes detectar la versión,
**decláralo** y usa la sintaxis más conservadora y compatible.

---

## 3. Paso PLAN — generar el procedimiento correcto

Reglas que todo comando/script generado debe cumplir, sea el motor que sea:

- **Idempotente** cuando sea posible (`IF NOT EXISTS`, `CREATE OR REPLACE`,
  *upsert*), para poder reintentar sin daño.
- **Acotado**: sin operaciones sin `WHERE`/límite que afecten todo el conjunto.
- **No bloqueante** en lo posible: para DDL, preferir variantes online/
  concurrentes del motor (p. ej. construir índice sin bloqueo, `ALTER` en línea).
- **Por lotes** para DML masivo: dividir en *batches* para no inflar el log ni
  bloquear; nunca un `UPDATE/DELETE` de millones de filas en una transacción.
- **Parametrizado**: nunca concatenar entradas (previene inyección).
- **Con timeouts** y, si aplica, `lock_timeout`/`statement_timeout`.
- **Auditable**: el comando exacto queda registrado en el entregable.

## 4. Paso DRY-RUN — medir el impacto sin causarlo

Antes de cualquier escritura, ejecuta el equivalente de "ensayo" del motor:

- **Plan/estimación**: `EXPLAIN`/`EXPLAIN ANALYZE` (sin ejecutar el cambio),
  `explain()` en MongoDB, *query profile* en DW.
- **Conteo de filas afectadas**: `SELECT count(*)` con el mismo predicado del
  `UPDATE/DELETE` antes de ejecutarlo.
- **Detección de bloqueos**: revisar locks/transacciones largas activas.
- **Coste/escaneo** en motores cloud (bytes/credits estimados) antes de correr.

Si el impacto estimado supera el umbral acordado, **detente y reporta**.

## 5. Paso SAFEGUARD — respaldo y rollback (obligatorio si hay escritura)

- **Backup/snapshot verificado** del objeto o instancia *antes* del cambio
  (anota timestamp/ID).
- **Plan de rollback explícito**: cómo deshacer cada paso (script inverso,
  restore puntual, *swap* de versión). Para esquema, preferir **expand/contract**
  (añadir nuevo → migrar → conmutar → eliminar viejo en fase posterior).
- **Criterio de aborto**: condición observable que dispara el rollback (p. ej.
  error rate, lag, latencia p99, filas afectadas distintas de lo esperado).

## 6. Paso EXECUTE — aplicar con control

- En **no-prod primero**, siempre que exista.
- En **prod**: solo con aprobación humana, ventana y monitoreo en vivo.
- Cambio **mínimo y reversible**; un paso a la vez con verificación intermedia.
- Identifica el **punto de no retorno** y anúncialo antes de cruzarlo.

## 7. Paso VERIFY — confirmar con evidencia

- Conteos/`checksums` esperados vs reales; reglas de negocio.
- SLIs post-cambio (latencia, errores, replicación) dentro de objetivo.
- Sin regresiones en planes de ejecución de consultas críticas.

---

## 8. Clasificación universal de riesgo de la operación

| Tipo de operación | Riesgo | Requisito mínimo de Andulfo |
|---|---|---|
| Lectura / `EXPLAIN` / métricas | Bajo | Libre (preferible no-prod si carga) |
| Creación de objeto idempotente | Medio | Dry-run + verificación |
| DML acotado / por lotes | Medio-alto | Backup + dry-run + rollback |
| DDL sobre tabla grande / migración | Alto | No-prod + expand/contract + ventana + aprobación |
| `DROP`/`TRUNCATE`/`DELETE` masivo | Crítico | **Backup verificado + aprobación explícita + rollback + ventana** |
| Cambio en producción | Crítico | Todo lo anterior + monitoreo en vivo + criterio de aborto |

---

## 9. Qué hacer si NO hay accesos de ejecución

Si la sesión no tiene shell/conexión/MCP a la base, Andulfo **no se bloquea**:
entrega el **procedimiento ejecutable completo** (comandos exactos para el motor
detectado, dry-run, backup, ejecución, verificación y rollback) para que el
equipo lo aplique, y lo deja listo en una plantilla de plan de cambio
(ver `plantillas.md`). El método es el mismo; cambia quién aprieta el botón.
