# runbooks.md — Runbooks de incidentes de la capa semántica

Procedimientos paso a paso para incidentes de **analytics engineering**. Cierre
común: **contener → diagnosticar → remediar → verificar consistencia → comunicar +
test que prevenga la recurrencia**. Método de ejecución segura en
[ejecucion.md](ejecucion.md).

> Regla transversal: ante una **métrica dudosa que alimenta decisiones**, contén
> primero (marca como no confiable / pausa el dashboard) antes de remediar.

---

## 1. Métrica con definiciones divergentes ("revenue" no cuadra)

1. CONTENER: marca la métrica como **no certificada**; avisa a consumidores.
2. DIAGNOSTICAR: inventaria las variantes y dónde se usan (linaje/exposures).
3. REMEDIAR: con **PO/BA**, acuerda la definición canónica; impleméntala en la
   capa; mapea/depreca las variantes.
4. VERIFICAR: reconciliación; dashboards migrados a la métrica única.
5. CERRAR: certifícala, documenta, y prohíbe el cálculo ad-hoc en BI.

## 2. Cambio de *grain* / modelo que rompe dashboards

1. CONTENER: si ya rompió, revierte al modelo anterior (rollback).
2. DIAGNOSTICAR: identifica consumidores afectados (exposures).
3. REMEDIAR: trata el nuevo grain como **modelo nuevo**; aplica expand/contract y
   migra consumidores con *deprecation*.
4. VERIFICAR: dashboards funcionando; números correctos.
5. CERRAR: documenta el cambio de grain y comunica.

## 3. Dato incorrecto en un mart de consumo

1. CONTENER: pausa/marca el mart; avisa a quienes deciden con él.
2. DIAGNOSTICAR: ¿error de transformación, de definición o dato malo en core?
   (linaje). Si es de core → escala a `caudal`.
3. REMEDIAR: corrige la transformación/definición; reconstruye desde core.
4. VERIFICAR: tests verdes, reconciliación contra detalle.
5. CERRAR: añade test/regla que lo detecte; comunica corrección.

## 4. *Deprecation* de métrica/modelo

1. PLAN: identifica usos (exposures); define reemplazo y periodo de transición.
2. ANUNCIAR: comunica a consumidores con fecha y guía de migración.
3. PARALELO: mantén viejo y nuevo conviviendo durante la transición.
4. VERIFICAR no-uso del viejo por linaje.
5. RETIRAR: elimina el viejo; documenta en el *changelog*.

## 5. *Late-arriving data* en modelo incremental

1. DIAGNOSTICAR: filas con fecha de evento anterior a la última corrida no
   capturadas por el filtro incremental.
2. REMEDIAR: amplía la ventana de *lookback* o ejecuta *full-refresh* del rango.
3. VERIFICAR: reconciliación del periodo afectado; sin duplicados (clave única).
4. CERRAR: ajusta el margen de *lookback* del modelo.

## 6. Explosión de costo de materializaciones

1. CONTENER: identifica el/los modelos `table`/incremental más caros.
2. DIAGNOSTICAR: recálculo completo innecesario, *full scans*, falta de
   particionado, vistas pesadas en dashboards de alto tráfico.
3. REMEDIAR: incremental, agregados pre-calculados, particiones/clustering
   (coordina con andulfo), materializa lo caliente.
4. VERIFICAR: costo por corrida/consulta dentro de presupuesto.
5. CERRAR: alerta de costo; documenta la decisión.

## 7. Onboarding / refactor de capa semántica heredada

1. INVENTARIO: modelos, métricas, dashboards y su linaje; detecta duplicados y
   modelos sin tests/docs.
2. PRIORIZA: matriz de hallazgos (métricas críticas divergentes primero).
3. REMEDIA por dominio: consolida métricas, añade tests/docs, refactoriza a capas.
4. VERIFICA: reconciliación y paridad con lo anterior antes de retirar lo viejo.
5. CIERRA: capa certificada, documentada y con *owners*.
