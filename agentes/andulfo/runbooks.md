# runbooks.md — Runbooks críticos de Andulfo

Procedimientos paso a paso para incidentes de plataformas de datos. Son
**agnósticos de motor**: adapta comandos al motor específico. Regla suprema en
todo incidente: **no causar más daño**. Ante cualquier acción destructiva,
**toma o verifica un backup primero** y exige confirmación humana.

Estructura común de cada runbook: **Detección → Diagnóstico → Mitigación →
Resolución → Verificación → Postmortem.**

---

## 0. Protocolo general de incidente (comandante de incidente de datos)

```
1. DECLARAR: severidad (ver matriz §25 SKILL), abrir canal, asignar roles
2. ESTABILIZAR: detener el sangrado (no buscar causa raíz aún)
3. PROTEGER DATOS: snapshot/backup del estado actual antes de tocar nada
4. COMUNICAR: estado a stakeholders en intervalos fijos
5. DIAGNOSTICAR: evidencia (métricas, logs, planes), causa raíz
6. REMEDIAR: cambio mínimo y reversible; validar
7. VERIFICAR: SLIs, integridad, ausencia de regresión
8. CERRAR: postmortem sin culpa, acciones y dueños
```

---

## 1. Failover (caída del primario)

- **Detección:** primario no responde, alertas de salud, apps con errores de
  conexión.
- **Diagnóstico:** ¿es el nodo, la red o el almacenamiento? ¿réplica al día
  (lag)? ¿automático o manual?
- **Mitigación/Resolución:**
  1. Confirmar que el primario está realmente caído (evitar split-brain).
  2. Verificar lag de la réplica candidata; elegir la más actualizada.
  3. Promover réplica (failover gestionado o manual según motor).
  4. Redirigir tráfico (DNS/endpoint/proxy/connection string).
  5. Aislar (fence) el primario viejo para que no acepte escrituras.
- **Verificación:** escrituras OK, lag de nuevas réplicas, integridad, SLIs.
- **Failback (posterior):** reconstruir el nodo caído como réplica, re-sincronizar,
  planificar retorno controlado si aplica.

## 2. Restauración Point-in-Time (PITR)

- **Detección:** corrupción lógica, borrado accidental, cambio erróneo.
- **Diagnóstico:** identificar **timestamp/LSN/posición** justo anterior al daño;
  decidir restore completo vs parcial; impacto en datos posteriores.
- **Resolución:**
  1. **Snapshot del estado actual antes de restaurar** (preservar evidencia).
  2. Restaurar último backup base válido en instancia nueva/aislada.
  3. Aplicar WAL/binlog/redo hasta el punto objetivo.
  4. Validar integridad y datos críticos en la instancia restaurada.
  5. Cortar tráfico, promover/intercambiar o re-importar el subconjunto afectado.
- **Verificación:** conteos, *checksums*, reglas de negocio, reanudar replicación.

## 3. Corrupción de datos

- **Detección:** errores de checksum/página, lecturas fallidas, datos inválidos.
- **Diagnóstico:** ¿corrupción física (disco/IO) o lógica (bug/aplicación)?
  Revisar logs, *checksums*, salud de almacenamiento.
- **Mitigación:** aislar el objeto/tabla afectada; evitar más escrituras sobre él.
- **Resolución:** restaurar desde backup/réplica sana el objeto afectado (PITR si
  es lógico). Si es física, mover a almacenamiento sano. Reparar índices.
- **Verificación:** *consistency check* del motor, validación de integridad,
  causa raíz del hardware/aplicación corregida.

## 4. Replication lag crítico

- **Detección:** lag creciente, réplicas obsoletas, lecturas inconsistentes.
- **Diagnóstico:** ¿carga de escritura alta? ¿transacción larga? ¿I/O/red de la
  réplica? ¿DDL pesado? ¿*single-threaded apply*?
- **Mitigación:** reducir carga de escritura, pausar ETL/batch, redirigir lecturas
  críticas al primario temporalmente.
- **Resolución:** resolver cuello (recursos de réplica, paralelizar apply, dividir
  transacción grande); si la réplica quedó muy atrás, reconstruirla.
- **Verificación:** lag dentro de umbral y estable.

## 5. Disco / almacenamiento lleno

- **Detección:** alerta de espacio, errores de escritura, base en solo-lectura.
- **Diagnóstico:** qué consume (datos, WAL/redo, logs, temp, bloat, backups mal
  ubicados); ¿WAL acumulado por réplica caída o slot de replicación?
- **Mitigación inmediata:** liberar espacio seguro (rotar/comprimir logs, limpiar
  temp, archivar/expirar WAL ya respaldado, soltar *replication slot* huérfano);
  ampliar volumen si es posible.
- **Resolución:** atacar la causa (bloat→vacuum/reorg, crecimiento→capacidad,
  retención de logs/backups). **Nunca** borrar datos para liberar espacio sin
  backup y certeza.
- **Verificación:** escrituras restauradas, headroom recuperado, alertas limpias.

## 6. Connection storm / pool agotado

- **Detección:** errores "too many connections", latencia alta, apps colgadas.
- **Diagnóstico:** ¿fuga de conexiones de la app? ¿falta de pooler? ¿pico de
  tráfico? ¿transacciones largas reteniendo conexiones?
- **Mitigación:** matar conexiones *idle in transaction* antiguas, subir límite
  temporalmente si el host aguanta, activar/ajustar pooler.
- **Resolución:** introducir/ajustar connection pooling, corregir fuga en la app,
  límites por usuario/servicio, *circuit breakers*.
- **Verificación:** conexiones estables bajo carga, latencia normal.

## 7. Deadlocks / lock contention / long transactions

- **Detección:** errores de deadlock, *timeouts*, latencia, *blocking chains*.
- **Diagnóstico:** identificar transacciones bloqueantes y orden de adquisición
  de locks; transacciones que no hacen *commit*.
- **Mitigación:** terminar la transacción bloqueante (con criterio), tras evaluar
  impacto.
- **Resolución:** ordenar acceso a recursos consistentemente, acortar
  transacciones, índices para reducir locks de rango, nivel de aislamiento
  adecuado, *retry* con backoff en la app.
- **Verificación:** sin deadlocks recurrentes, latencia y locks normales.

## 8. Bloat / vacuum de emergencia (MVCC)

- **Detección:** tablas/índices inflados, lentitud, espacio creciente, *wraparound*
  inminente (Postgres).
- **Diagnóstico:** medir bloat, *dead tuples*, edad de transacción, autovacuum
  rezagado o bloqueado por transacción larga.
- **Mitigación:** eliminar la transacción larga/slot que bloquea vacuum; lanzar
  vacuum manual sobre lo crítico.
- **Resolución:** ajustar autovacuum (más agresivo en tablas calientes), reorg/
  reindex en ventana, particionar tablas enormes.
- **Verificación:** bloat reducido, edad de transacción segura, rendimiento OK.

## 9. Respuesta a ransomware / brecha de datos

- **Detección:** archivos cifrados, accesos anómalos, exfiltración, alerta de
  seguridad.
- **Diagnóstico:** alcance, vector, datos afectados (PII/PCI/PHI), línea temporal.
- **Mitigación:** **aislar** sistemas afectados (red), preservar evidencia
  forense, **no pagar** sin proceso, activar plan de respuesta a incidentes.
- **Resolución:** restaurar desde **copia inmutable/offline limpia** verificada,
  rotar todas las credenciales/llaves, cerrar el vector.
- **Verificación + obligaciones:** integridad de datos restaurados, y
  **notificación regulatoria** según ley (GDPR/Habeas Data/etc.) y a afectados.
- **Postmortem:** controles que fallaron, refuerzo de inmutabilidad y accesos.

## 10. Upgrade mayor de motor

- **Preparación:** leer breaking changes, probar en clon de producción, validar
  drivers/extensiones, backup + plan de rollback (downgrade/restore).
- **Ejecución:** ventana, método (in-place vs blue-green/réplica nueva),
  monitoreo en vivo, punto de no retorno definido.
- **Verificación:** funcional, rendimiento (comparar planes), replicación,
  estadísticas regeneradas.
- **Rollback:** criterio claro de abortar y procedimiento ensayado.

## 11. Game day de DR (simulacro)

- **Objetivo:** validar RPO/RTO reales, runbooks y preparación del equipo.
- **Pasos:** definir escenario, congelar/copiar estado, ejecutar failover/restore
  cronometrando, medir RPO/RTO obtenidos vs objetivo, registrar brechas.
- **Salida:** informe con resultados, acciones de mejora y dueños; runbooks
  actualizados.

## 12. Migración heterogénea / replatforming (cambio de motor o de plataforma)

Aplica al mover datos entre motores distintos (p. ej. Oracle→PostgreSQL,
SQL Server→Aurora) o de on-prem a cloud. Objetivo: **cero pérdida y rollback
posible** hasta el último momento.

- **Preparación:** inventario de esquema/objetos (tipos, vistas, *stored procs*,
  *triggers*, secuencias), matriz de equivalencia de features, conversión de
  esquema y tipos, plan de reescritura de lo no portable (PL/SQL→PL/pgSQL, etc.).
- **Carga inicial:** *backfill* masivo en ventana o en paralelo; validar conteos
  y *checksums* por tabla.
- **Sincronización:** **CDC** desde el origen al destino para mantener el delta
  al día mientras el origen sigue vivo (minimiza el downtime de *cutover*).
- **Convivencia:** fase de doble lectura/validación (y doble escritura si se
  requiere) comparando paridad de datos origen↔destino.
- **Cutover:** congelar escrituras en origen, drenar el CDC, conmutar la app al
  destino; **punto de no retorno** explícito y anunciado.
- **Verificación:** integridad, conteos, reglas de negocio, rendimiento de
  consultas críticas (comparar planes), replicación/HA del nuevo destino.
- **Rollback:** mientras no se cruce el cutover, volver al origen; mantener el
  origen en solo-lectura un periodo de observación antes de desmantelarlo.

## 13. Incidente de pipeline / calidad de datos / backfill

Aplica cuando un *pipeline* falla, llega tarde, o produce **datos incorrectos**
(el job pudo terminar "en verde" y aun así el dato estar mal). Regla: **detén la
propagación antes de corregir** para no contaminar capas/consumidores aguas abajo.

- **Detección:** fallo del DAG, *SLA de freshness* incumplido, alerta de DQ
  (volumen/nulos/drift), reconciliación origen↔destino que no cuadra, o reporte
  de un consumidor.
- **Contención (primero):** pausar el *pipeline* y los consumidores aguas abajo;
  marcar el dataset afectado como *stale*/no confiable para no propagar el error.
- **Diagnóstico:** ¿fuente cambió de esquema (*schema drift*)?, ¿datos tardíos/
  fuera de orden?, ¿*deploy* de transformación con bug?, ¿duplicados por reintento
  no idempotente?, ¿*partition*/rango equivocado? Usa el **linaje** para acotar
  alcance e impacto.
- **Mitigación:** aislar el rango/partición afectado; enviar filas inválidas a
  **cuarentena**; revertir el cambio de transformación si fue la causa.
- **Resolución (backfill seguro):** corregir la causa, luego **reprocesar solo el
  rango afectado** por partición — *dry-run* de volumen, *merge/upsert*
  idempotente, sin pisar datos correctos. En streaming, **replay** desde el
  *offset* seguro.
- **Verificación:** reconciliación origen↔destino OK, pruebas DQ en verde,
  *freshness* recuperado, conteos esperados; reactivar consumidores.
- **Postmortem:** añadir/ajustar la prueba DQ que lo habría detectado antes,
  reforzar idempotencia/contrato de esquema, registrar lecciones.
