# runbooks.md — Runbooks de incidentes de pipelines y datos

Procedimientos paso a paso para incidentes de **data engineering**. Todos siguen
el mismo cierre: **contener → diagnosticar → remediar → verificar el dato →
postmortem sin culpa + test que prevenga la recurrencia**. Método de ejecución
segura en [ejecucion.md](ejecucion.md).

> Regla transversal: ante dato potencialmente incorrecto en consumo crítico,
> **contén primero** (pausa/aísla downstream) antes de remediar.

---

## 1. Pipeline fallido / *late data*

1. CONTENER: marca el dataset como *stale*; evita que consumidores usen dato viejo.
2. DIAGNOSTICAR: revisa logs del orquestador, fuente caída, credenciales, cuota.
3. REMEDIAR: corrige causa; reejecuta de forma **idempotente** el rango afectado.
4. VERIFICAR: reconciliación y tests de datos; *freshness* recuperada.
5. CERRAR: postmortem; alerta de *freshness* afinada.

## 2. *Schema drift* en la fuente

1. CONTENER: el pipeline debe **fallar/cuarentenar**, no propagar el cambio.
2. DIAGNOSTICAR: compara esquema actual vs contrato; clasifica compatible/incompat.
3. REMEDIAR: si compatible, evoluciona (campo opcional); si no, versión nueva y
   *deprecation* gradual (*expand/contract*), coordinando con consumidores.
4. VERIFICAR: contrato actualizado, tests de esquema en CI.
5. CERRAR: añade *schema test* que detecte el drift antes de producción.

## 3. Dato incorrecto en consumo (*bad data*)

1. CONTENER: aísla downstream (pausa BI/modelos que dependen del dataset).
2. DIAGNOSTICAR: linaje para acotar origen e impacto; identifica el rango/particiones
   afectadas.
3. REMEDIAR: corrige la transformación/fuente; **reprocesa desde la zona cruda** el
   rango afectado (idempotente).
4. VERIFICAR: reconciliación, tests, y confirmación con consumidores.
5. CERRAR: test de DQ que lo prevenga; comunica a afectados.

## 4. *Backfill* / *replay* seguro

1. PLAN: rango acotado por partición; estima volumen (dry-run); plan de rollback.
2. SAFEGUARD: respaldo/snapshot del destino; idempotencia garantizada.
3. EXECUTE: por lotes/particiones, monitoreando costo y presión sobre fuente.
4. VERIFY: reconciliación por partición; sin duplicados.
5. CERRAR: documenta rango reprocesado y resultado.

## 5. *Consumer lag* / *backpressure* (streaming)

1. CONTENER: evalúa escalar consumidores/particiones; activa DLQ si hay *poison*.
2. DIAGNOSTICAR: causa del lag (pico de tráfico, consumidor lento, *rebalance*).
3. REMEDIAR: escala, ajusta *batch*/paralelismo, corrige consumidor; usa *replay*
   si se perdió procesamiento.
4. VERIFICAR: lag dentro de umbral; sin pérdida ni duplicación (idempotencia).
5. CERRAR: ajusta autoscaling/alertas de lag.

## 6. *Slot* de CDC huérfano / disco lleno

1. CONTENER (con **andulfo**): el *slot* sin consumir llena disco de la base
   origen → riesgo para OLTP.
2. DIAGNOSTICAR: identifica *slot*/replica inactiva y su retención.
3. REMEDIAR: reactiva el consumidor o elimina el *slot* huérfano (coordinado con
   andulfo); reanuda CDC desde *watermark* válido.
4. VERIFICAR: disco liberado, CDC al día, sin pérdida de *deletes*.
5. CERRAR: alerta de *slot lag*/retención.

## 7. Explosión de costo

1. CONTENER: pausa el pipeline/consulta que dispara costo.
2. DIAGNOSTICAR: *full scans*, falta de *partition pruning*, *small files*,
   *backfill* accidental, cluster sobredimensionado.
3. REMEDIAR: *pruning*, materialización incremental, *compaction*, *right-sizing*.
4. VERIFICAR: costo por corrida dentro de presupuesto.
5. CERRAR: alerta de costo y *guardrail* (policy-as-code).

## 8. Incidente de calidad de datos (cuarentena masiva)

1. CONTENER: detén el avance a *gold*/consumo; revisa tabla de rechazos.
2. DIAGNOSTICAR: regla violada vs cambio real en la fuente.
3. REMEDIAR: corrige en origen o ajusta regla (con justificación); reprocesa.
4. VERIFICAR: tasa de rechazo normal; datos correctos en consumo.
5. CERRAR: postmortem; ajusta umbral/test.

## 9. *Cutover* de migración de pipeline

1. PLAN: ejecuta viejo y nuevo en **paralelo**; compara salidas (reconciliación).
2. SAFEGUARD: criterio de éxito y *rollback* al pipeline viejo.
3. EXECUTE: cambia consumidores al nuevo solo tras paridad verificada.
4. VERIFY: *freshness*, DQ y contratos estables N días.
5. CERRAR: retira el viejo; documenta.
