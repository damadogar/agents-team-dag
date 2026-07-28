# ejecucion.md — Método universal de ejecución segura de cambios de datos

Método **agnóstico de herramienta/nube** para ejecutar cualquier cambio sobre
datos en movimiento (nuevo pipeline, modificación, *backfill*, *replay*, cambio de
esquema, migración de pipeline). Todo pipeline es **un cambio de datos en
producción**: se aplica el mismo rigor que a una migración de base.

Secuencia obligatoria: **DETECT → PLAN → DRY-RUN → SAFEGUARD → EXECUTE → VERIFY →
ROLLBACK**.

> Regla 0: **entorno desconocido se trata como producción.** Sin respaldo/*replay*
> disponible y plan de rollback, **no se ejecuta** un cambio crítico.

---

## 1. DETECT — descubrir antes de tocar

- Identifica **stack** (orquestador, motor de procesamiento, almacenamiento,
  formatos) y **versiones**.
- Mapea **fuentes, volúmenes, particiones, *freshness* actual** y consumidores
  afectados (linaje).
- Confirma **constraints de plataforma** con andulfo (motor, ventana, capacidad).
- Detecta clasificación de datos (PII/PCI/PHI) y cumplimiento aplicable.

## 2. PLAN — diseñar el cambio y su reverso

- Define el cambio en pasos atómicos e **idempotentes**.
- Estrategia de esquema: **expand/contract** si afecta consumidores.
- Define **clave de dedupe/merge** y particiones afectadas.
- Escribe el **plan de rollback/reproceso** ANTES de ejecutar: cómo revertir o
  reprocesar el rango.
- Clasifica el cambio: **reversible** (dos vías) vs **irreversible** (una vía →
  más rigor y aprobación).

## 3. DRY-RUN — simular sin efectos

- **Dry-run de volumen:** estima filas/bytes/particiones a procesar; detecta
  *full scans* o *backfills* gigantes accidentales.
- Ejecuta sobre **muestra** o entorno no productivo equivalente con datos
  representativos.
- Valida el **plan de ejecución** del motor (lectura de plan/cost) y el costo
  estimado.
- Corre los **tests de datos** sobre la salida simulada.

## 4. SAFEGUARD — redes de seguridad

- Verifica que existe **respaldo o capacidad de *replay*** del rango afectado
  (zona cruda inmutable disponible).
- **Snapshot** de las tablas destino si el motor lo permite (Delta/Iceberg *time
  travel*).
- Define **ventana**, **monitoreo** y **aprobación humana** para cambios críticos
  (backfill masivo, borrado, cambio incompatible).
- Asegura **idempotencia**: reejecutar el paso no duplica ni corrompe.

## 5. EXECUTE — ejecutar con control

- Ejecuta por **rangos/particiones acotadas**, no todo de golpe.
- Monitorea en vivo: progreso, errores, *lag*, costo, presión sobre la fuente.
- Mantén el **rollback a mano**; si una métrica se sale de banda, **detente**.
- Registra qué se ejecutó (auditable): *batch id*, rango, versión de código.

## 6. VERIFY — comprobar el dato, no solo el job

- **Reconciliación** origen↔destino (conteos/checksums).
- **Tests de datos** (completitud, unicidad, validez, *freshness*).
- **Linaje** actualizado y contratos respetados (consumidores no rotos).
- **Costo y rendimiento** dentro de lo esperado; sin *small files* nuevos sin
  *compaction*.

## 7. ROLLBACK — revertir o reprocesar

- Si la verificación falla: ejecuta el **rollback/reproceso** planificado
  (restaurar partición previa, *time travel*, re-`merge` desde crudo).
- Documenta causa raíz; crea un **test que prevenga la recurrencia**.
- Postmortem sin culpa para incidentes relevantes (ver [runbooks.md](runbooks.md)).

---

## 8. Guardas para operaciones de alto riesgo

| Operación | Guarda mínima |
|---|---|
| **Backfill masivo** | Rango acotado, dry-run de volumen, idempotente, aprobación |
| **Borrado / purga** | Backup/replay disponible, ventana, confirmación humana explícita |
| **Cambio de esquema incompatible** | Expand/contract, *deprecation* gradual, contrato versionado |
| **Replay de stream** | Verificar retención del log, idempotencia de consumidores, DLQ |
| **CDC sobre OLTP** | Coordinar con andulfo (slot/replica), vigilar disco y lag |
| **Cambio de plataforma** | andulfo A/R; este cambio es C para caudal |

> Nunca DDL/borrado/backfill destructivo **autónomo**: requiere validación
> humana, respaldo y plan de rollback.
