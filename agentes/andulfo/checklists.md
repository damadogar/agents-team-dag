# checklists.md — Checklists operativos, de seguridad, rendimiento y cambios

Checklists accionables de Andulfo. Copia el bloque que aplique y verifícalo punto
por punto. Marca **N/A** lo que no aplique al motor/entorno y justifica.

---

## 1. Operativo diario / salud

```
- [ ] Backups del periodo completados sin error
- [ ] Restore verificado recientemente (no solo el backup)
- [ ] Replicación activa; lag dentro de umbral por sistema
- [ ] Espacio en disco/tablespace con headroom (alerta < 20% libre)
- [ ] CPU / memoria / IOPS dentro de rango; sin saturación sostenida
- [ ] Conexiones activas vs límite; pool sano (sin agotamiento)
- [ ] Sin transacciones de larga duración ni locks bloqueantes anómalos
- [ ] Estadísticas actualizadas; autovacuum/compaction al día; bloat bajo control
- [ ] Jobs programados (mantenimiento, purga, ETL) ejecutados OK
- [ ] Alertas activas, sin flapping ni silenciadas críticas
- [ ] Errores recientes en logs revisados (corrupción, OOM, auth fallida)
- [ ] Parches/seguridad al día; sin versión EOL no planificada
```

## 2. Onboarding de una base nueva (descubrimiento)

```
- [ ] Motor, versión, edición y parámetros clave documentados
- [ ] Criticidad/Tier y clasificación de datos (PII/PCI/PHI) definidas
- [ ] RPO/RTO comprometidos y validados contra la estrategia actual
- [ ] Topología HA/DR mapeada (réplicas, AZ/regiones, failover)
- [ ] Backups: tipo, frecuencia, retención, ubicación, cifrado, inmutabilidad
- [ ] Observabilidad: métricas, logs, alertas y dashboards conectados
- [ ] Accesos/roles inventariados; secretos en gestor; mínimo privilegio
- [ ] Esquema y volúmenes; crecimiento histórico y proyectado
- [ ] Dependencias (apps, ETL, CDC, reporting) identificadas
- [ ] Owner técnico y de negocio asignados
```

## 3. Seguridad (hardening y cumplimiento)

```
Acceso e identidad
- [ ] Autenticación fuerte (IAM/SSO/MFA); sin usuarios compartidos
- [ ] RBAC/ABAC con mínimo privilegio; revisión periódica de permisos
- [ ] Segregación de funciones (SoD); cuentas de servicio acotadas
- [ ] Sin cuentas por defecto/huérfanas; contraseñas/llaves rotadas
- [ ] Acceso administrativo auditado y con justificación (JIT si es posible)

Cifrado y secretos
- [ ] TLS forzado en tránsito (sin conexiones en claro)
- [ ] Cifrado en reposo (TDE/volumen) activo; llaves en KMS/HSM con rotación
- [ ] Cifrado a nivel de campo/columna para PII sensible
- [ ] Secretos fuera de código/repos; gestor de secretos en uso

Datos sensibles
- [ ] Datos clasificados; inventario de PII/PCI/PHI
- [ ] RLS / Column-Level Security donde corresponde
- [ ] Enmascaramiento dinámico / tokenización / anonimización en no-prod
- [ ] Retención y borrado seguro según política y regulación

Red y superficie
- [ ] Base en red privada; sin exposición pública injustificada
- [ ] Firewall/Security Groups restringidos por origen
- [ ] Features inseguras deshabilitadas; puertos mínimos; línea base CIS

Auditoría y cumplimiento
- [ ] Auditoría de accesos y DDL/DML sensibles habilitada e inmutable
- [ ] Detección de actividad anómala / alertas de seguridad
- [ ] Controles mapeados a GDPR/PCI-DSS/HIPAA/SOX/ISO 27001/Habeas Data
- [ ] Backups cifrados y con copia inmutable (anti-ransomware)
```

## 4. Rendimiento y tuning

```
Consultas
- [ ] Top consultas por tiempo total y por nº de llamadas identificadas
- [ ] Planes de ejecución revisados (EXPLAIN/ANALYZE/Query Store)
- [ ] Sin full scans injustificados; predicados *sargable*
- [ ] N+1 / consultas repetidas del ORM eliminadas
- [ ] Paginación eficiente (keyset en vez de OFFSET grande)

Índices
- [ ] Índices que cubren los predicados/orden frecuentes
- [ ] Sin índices faltantes (según missing index/recomendaciones)
- [ ] Sin índices duplicados, redundantes o no usados
- [ ] Índices compuestos en el orden correcto; parciales/cubrientes si aplica

Configuración y recursos
- [ ] Memoria (buffer pool/shared_buffers/work_mem) dimensionada
- [ ] Connection pooling configurado (PgBouncer/ProxySQL/RDS Proxy)
- [ ] Paralelismo e I/O ajustados al hardware
- [ ] Autovacuum/compaction y estadísticas con frecuencia adecuada

Concurrencia y escala
- [ ] Nivel de aislamiento correcto para el caso de uso
- [ ] Sin deadlocks recurrentes ni lock contention crítica
- [ ] Lecturas escaladas (réplicas/caché/materialized views) si aplica
- [ ] Particionamiento/sharding evaluado para tablas muy grandes
- [ ] Latencias p95/p99 y cache hit ratio dentro de SLO
```

## 5. Diseño de esquema / modelado (revisión)

```
- [ ] Modelo guiado por patrones de acceso reales
- [ ] Normalización adecuada; desnormalización justificada y controlada
- [ ] Claves primarias/únicas y de negocio bien definidas
- [ ] Integridad referencial y constraints (NOT NULL, CHECK, FK) presentes
- [ ] Tipos de dato correctos y eficientes; sin "todo varchar"
- [ ] Convenciones de nombres consistentes
- [ ] Estrategia de versionado de esquema (migraciones) definida
- [ ] PII identificada y aislada para cifrado/RLS/retención
- [ ] Multi-tenancy: modelo de aislamiento elegido (silo/pool/bridge) y su
      impacto en seguridad, *noisy neighbor*, costo y operación justificado
```

## 6. Cambios y despliegues (change management)

```
Antes
- [ ] Cambio descrito, con impacto y riesgo evaluados
- [ ] Probado en entorno equivalente; revisado en CI/PR
- [ ] Migración compatible (expand/contract, idempotente, sin lock largo)
- [ ] Zero-downtime evaluado; ventana definida si se requiere
- [ ] Backup verificado inmediatamente antes
- [ ] Plan de ROLLBACK explícito y probado
- [ ] Aprobación obtenida; comunicación a stakeholders

Durante
- [ ] Ejecución monitoreada (locks, lag, errores, latencia)
- [ ] Punto de no retorno identificado; criterio de abortar definido

Después
- [ ] Verificación de integridad y conteos esperados
- [ ] SLIs post-cambio dentro de objetivo
- [ ] Limpieza (columnas/objetos legacy) en fase "contract" posterior
- [ ] Documentación/ADR actualizada; lecciones registradas
```

## 7. HA / DR (continuidad)

```
- [ ] RPO/RTO definidos por criticidad y validados con prueba real
- [ ] Estrategia de backup 3-2-1-1-0 implementada y verificada
- [ ] PITR disponible (WAL/binlog) y probado
- [ ] Réplicas y failover automático probados (game day)
- [ ] Prevención de split-brain / quórum configurado
- [ ] Runbooks de failover y failback documentados y accesibles
- [ ] Copia inmutable/offline contra ransomware
- [ ] Simulacro de DR ejecutado y cronometrado en el periodo
```

## 8. Upgrade / parcheo de motor

```
- [ ] Notas de versión y breaking changes revisados
- [ ] Compatibilidad de apps/drivers/extensiones verificada
- [ ] Ensayo del upgrade en clon de producción
- [ ] Backup verificado y plan de rollback (incl. downgrade/restore)
- [ ] Ventana, monitoreo y comunicación definidos
- [ ] Validación post-upgrade (funcional, rendimiento, replicación)
```

## 9. Pipelines, ingesta y calidad de datos (data engineering)

```
Diseño e ingesta
- [ ] Patrón de ingesta elegido (batch/micro-batch/streaming/CDC) y justificado
- [ ] Ingesta idempotente (dedupe por clave) y reanudable (watermarks)
- [ ] Zona cruda (landing/staging) inmutable; transformación derivada y reentrante
- [ ] CDC: slot/posición monitoreado; sin acumulación de WAL/binlog por slot huérfano
- [ ] PII minimizada/enmascarada antes de aterrizar en zonas de menor control

Orquestación y backfill
- [ ] DAG con dependencias explícitas, retries con backoff y timeouts
- [ ] SLA de freshness definido por dataset; alerta si no se actualiza a tiempo
- [ ] Backfill acotado por partición, con dry-run de volumen y rollback
- [ ] Re-ejecución idempotente (merge/upsert/partición reemplazable)

Streaming (si aplica)
- [ ] Garantía de entrega declarada (at-least-once+dedupe / exactly-once)
- [ ] Partition key sin hot partitions; orden preservado donde importa
- [ ] Consumer lag, backpressure y DLQ monitoreados; replay disponible

Esquemas y contratos
- [ ] Schema registry con compatibilidad controlada (backward/forward)
- [ ] Data contract productor↔consumidor versionado y comunicado
- [ ] Cambios incompatibles gestionados con versión nueva + deprecation

Calidad y observabilidad del dato
- [ ] Pruebas DQ (not_null/unique/rangos/FK lógicas/row count/freshness)
- [ ] Reconciliación origen↔destino (conteos/checksums) tras cada carga
- [ ] Filas inválidas en cuarentena con motivo (no descartadas en silencio)
- [ ] Alertas de drift (volumen, distribución, nulos, cardinalidad, esquema)
- [ ] Linaje y catálogo actualizados (owner, clasificación, SLA)

Ciclo de vida
- [ ] Retención/purga por política y regulación; borrado seguro verificable
- [ ] Tiering hot→cold→archive según acceso y costo
- [ ] Zona cruda conservada lo necesario para reprocesar capas derivadas
```
