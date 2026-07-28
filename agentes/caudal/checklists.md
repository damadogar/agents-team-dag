# checklists.md — Checklists operativos de Data Engineering

Checklists accionables de Caudal. Úsalos como *gates* antes de diseñar,
desplegar u operar pipelines. Resumen en [SKILL.md](SKILL.md) §23.

---

## 1. Diseño de arquitectura / pipeline (antes de construir)

- [ ] Casos de uso y consumidores identificados (BI, producto, modelos, APIs)
- [ ] Fuentes catalogadas: volúmenes, *freshness* de origen, formato, acceso
- [ ] *Freshness*/SLA requerido definido por caso de uso
- [ ] Patrón elegido (batch/micro-batch/streaming/lambda/kappa/CDC) justificado
- [ ] Almacenamiento elegido (lake/warehouse/lakehouse) y formato/table format
- [ ] Constraints de plataforma confirmados con **andulfo**
- [ ] Contratos de datos con consumidores acordados y versionados
- [ ] 2–3 alternativas evaluadas con matriz ponderada → ADR de datos

## 2. Onboarding de pipelines existentes (brownfield)

- [ ] Inventario de pipelines, fuentes y destinos (linaje)
- [ ] *Freshness*/éxito de cargas actuales medido
- [ ] Idempotencia y reprocesabilidad verificadas (o deuda documentada)
- [ ] Tests de datos existentes (o ausencia documentada)
- [ ] Costo actual por pipeline/dataset
- [ ] Riesgos y deuda priorizados (matriz de hallazgos)

## 3. Calidad de datos

- [ ] Tests de completitud, unicidad, validez y *freshness* en datasets críticos
- [ ] Reconciliación origen↔destino activa (conteos/checksums)
- [ ] Cuarentena de rechazos con motivo (sin descartes silenciosos)
- [ ] Detección de *drift* (volumen/distribución/esquema)
- [ ] Alertas de *data downtime* configuradas (MTTD/MTTR)

## 4. Seguridad de pipelines

- [ ] Secretos en gestor (no en código/DAGs/logs)
- [ ] Mínimo privilegio por cuenta de pipeline; *scopes* por dataset
- [ ] PII enmascarada/tokenizada antes de zonas de menor control
- [ ] Cifrado en tránsito y reposo en cada *hop*
- [ ] Linaje de PII registrado (dónde está y a dónde fluye)
- [ ] Cumplimiento mapeado con destroyer/andulfo (GDPR/PCI/Habeas Data…)

## 5. Despliegue / cambio (DataOps)

- [ ] Cambio probado en entorno equivalente; tests de datos en CI
- [ ] Dry-run de volumen ejecutado
- [ ] Respaldo/*replay* del rango disponible
- [ ] Esquema compatible (*expand/contract*) si afecta consumidores
- [ ] Plan de **rollback/reproceso** explícito y probado
- [ ] Ventana, monitoreo y aprobación definidos (cambios críticos)
- [ ] Verificación post-cambio (reconciliación, *freshness*, costo) y comunicación

## 6. Operación continua

- [ ] *Freshness* dentro de SLA; alertas sin *flapping*
- [ ] Idempotencia confirmada (reejecución no duplica/corrompe)
- [ ] *Consumer lag* / *backpressure* (streaming) dentro de umbral
- [ ] *Small files*/*compaction* bajo control; costo en presupuesto
- [ ] *Slots* de CDC sanos (sin huérfanos llenando disco)
- [ ] Backfills recientes documentados y verificados
