# Performance en CI/CD — Que la Mejora No se Erosione

**peakformance** es dueño integral del performance del ecosistema. En CI/CD su trabajo es que cada optimización quede **protegida**: lo que costó ganar no se pierde en el siguiente commit. La performance deja de ser un evento heroico y pasa a ser una **propiedad continua, medida y con guardarraíles**. Herramientas concretas de CI/benchmark aparecen solo como *p. ej.*; se eligen por contexto (stack, madurez, presupuesto, criticidad), nunca por moda. Universal: greenfield (gates desde el día 1) y brownfield (baseline del estado real, luego cinturón anti-regresión). Siempre **percentiles, no promedios**; **entornos estables**; comparación **antes/después**.

Ver también: [estrategia-performance.md](estrategia-performance.md) · [metodologia-diagnostico.md](metodologia-diagnostico.md) · [medicion-observabilidad.md](medicion-observabilidad.md) · [pruebas-de-carga.md](pruebas-de-carga.md) · [interoperabilidad-y-aliadas.md](interoperabilidad-y-aliadas.md).

## Modelo de responsabilidad (TIERED)

| Tier | Qué hace peakformance | Quién actúa |
|------|----------------------|-------------|
| **T1 — Poseer** | Diseña e implementa los **perf gates**, los **budgets-as-code**, la **detección de regresiones** y el arnés de medición estable en CI. Es dueño del mecanismo. | peakformance |
| **T2 — Integrar** | Un gate se dispara → el **fix** del dominio afectado se integra vía su **dueño**: frontend→`farola`, backend→`motor`, datos→`andulfo`. peakformance especifica el objetivo y valida el antes/después. | dueño de dominio |
| **T3 — Fallback** | Si no hay dueño disponible o el gate es transversal, peakformance sostiene temporalmente la corrección (declarada) hasta el handoff. | peakformance (cobertura) |

> Principio de ownership: **el gate informa/bloquea; el dueño de dominio corrige.** peakformance no monopoliza el arreglo; garantiza la señal, el umbral y la evidencia. Detalle del enrutado en [interoperabilidad-y-aliadas.md](interoperabilidad-y-aliadas.md).

## Marcos de referencia

- **DORA**: los gates no deben degradar lead time ni deploy frequency (performance ≠ fricción ciega).
- **Google SRE / error budgets**: el presupuesto de latencia/regresión es finito; consumirlo dispara política, no pánico.
- **Budgets-as-code**: los umbrales viven versionados junto al código, con dueño y revisión.
- **Control estadístico**: toda decisión de bloqueo se apoya en significancia, no en un dato suelto.

## Budgets-as-code y perf gates

El budget es un **contrato versionado**: métrica, umbral, percentil, dueño, y acción (bloquea / avisa). Config **ilustrativa y agnóstica**:

```yaml
# perf-budget.(ejemplo) — neutral respecto a herramienta/CI
budgets:
  - id: api_checkout_latency
    metrica: latencia_servidor
    percentil: p95           # nunca promedio
    umbral: 220ms
    ventana: pre-prod
    dueño: motor
    accion: bloquea          # regresión dura = no se mergea/deploya
  - id: transferencia_inicial
    metrica: peso_transferido_total   # total inicial; distinto de initial_js_gzip (solo JS) en frontend-performance.md §4
    umbral: 180KB
    dueño: farola
    accion: bloquea
  - id: query_reporte_p99
    metrica: latencia_consulta
    percentil: p99
    umbral: 900ms
    dueño: andulfo
    accion: avisa            # tendencia bajo vigilancia, aún no bloqueante
```

### Qué bloquea vs. qué solo avisa

| Bloquea el merge/deploy | Solo avisa (warning + tendencia) |
|--------------------------|----------------------------------|
| Regresión estadísticamente significativa sobre métrica crítica del *hot path* | Regresión pequeña dentro del ruido / no significativa |
| Cruce de un budget duro (SLO-linked) | Métrica secundaria o aún sin baseline consolidada |
| Caída de throughput > umbral en carga | Nuevo benchmark en periodo de calibración |
| Presupuesto de error/latencia agotado | Mejora esperada que no se materializó (informativo) |

Regla de oro: **un gate que bloquea debe ser confiable**; un gate flaky que bloquea entrena al equipo a saltárselo. Preferir *avisar* hasta demostrar baja tasa de falsos positivos, luego *promover a bloqueante*.

## Detección de regresiones

### Líneas base y comparación

- **Baseline** = distribución de referencia (no un número), reconstruida por rama principal y refrescada de forma controlada.
- Comparación **A/B de commits**: mismo arnés, mismo entorno, `base` vs `candidato`, N repeticiones cada uno, comparar **distribuciones** (p50/p95/p99), no medias.

```
regresion?(base, cand):
  bootstrap/mann-whitney sobre muestras (N repeticiones c/u)
  delta = p95(cand) - p95(base)
  si p_valor < alfa  y  delta > umbral_minimo_efecto:
        REGRESION -> enrutar al dueño (T2)
  si p_valor < alfa  y  delta <= umbral_minimo_efecto:
        RUIDO SIGNIFICATIVO PERO IRRELEVANTE -> avisar
  sino: OK
```

Nota: exigir **significancia estadística** *y* **tamaño de efecto mínimo** (MDE). Solo significancia detecta cambios triviales; solo efecto ignora el ruido.

### Control de varianza y ruido

- **Repeticiones** por medición; descartar warm-up; reportar dispersión (IQR/CV).
- Fijar el **coeficiente de variación** máximo aceptable del arnés: si el CI es más ruidoso que eso, **no se puede medir ahí** → estabilizar antes de gatear.
- Semillas fijas, datos deterministas, aislar orden de tests.

### Domar tests de performance flaky

| Síntoma | Causa típica | Contramedida |
|---------|--------------|--------------|
| Varianza alta entre corridas | Ruido de hardware/vecinos | Aislamiento, hardware dedicado/consistente, más repeticiones |
| Falsos positivos de regresión | Umbral sobre promedio o N=1 | Percentiles + N repeticiones + significancia |
| Deriva lenta de baseline | Refresco no controlado | Baseline versionada, refresco explícito y revisado |
| Resultados irrepetibles | Estado/caché/red variable | Determinismo, warm-up descartado, dependencias mockeadas donde aplique |

Un benchmark flaky se **cuarentena** (pasa a *avisa*), se estabiliza, y solo entonces vuelve a *bloquea*.

## Benchmarking continuo — dónde en el pipeline

| Etapa | Tipo | Qué mide | Acción |
|-------|------|----------|--------|
| **Check de PR** | Micro-benchmarks / smoke rápido | Regresión local en funciones/hot paths y budgets baratos (bundle, p95 unidad) | Bloquea si regresión dura; feedback en minutos |
| **Nightly** | Macro / carga media | Escenarios end-to-end, tendencias, budgets amplios | Avisa/tickets; alimenta baseline |
| **Pre-prod** | Carga / estrés | SLOs bajo carga realista (ver [pruebas-de-carga.md](pruebas-de-carga.md)) | Bloquea deploy si viola SLO |
| **Canary / prod** | Métricas reales (RUM/APM) | Percentiles con tráfico real, comparación canary vs baseline | Auto-rollback / freeze si degrada |

**Micro** (rápido, aislado, señal temprana, ruido bajo) complementa a **macro/carga** (realista, caro, señal integral). No sustituyen; se ubican donde su costo/valor encaja. Diseño de escenarios y percentiles reales en [medicion-observabilidad.md](medicion-observabilidad.md).

## Estabilidad del entorno de CI para medir

Medir en un CI ruidoso es medir el ruido. Requisitos del **arnés estable**:

- **Aislamiento**: runner dedicado o sin vecinos ruidosos para las corridas que gatean; CPU/gobernador fijo; sin sobresuscripción.
- **Hardware consistente**: misma clase de máquina base vs candidato; nunca comparar corridas de hardware distinto.
- **Repeticiones + warm-up descartado**; recolectar distribución completa.
- **Aislar del ruido de red/IO**: dependencias controladas, datasets fijos.
- **Separar señal cara de la barata**: micro-benchmarks en el runner común; carga/estrés en entorno pre-prod calibrado.

> Si el entorno no alcanza el CV objetivo, el gate se **degrada a informativo** hasta estabilizarlo. Nunca bloquear con un instrumento que no mide.

## Alertas de regresión y enrutado al dueño

```
on_regresion:
  clasificar dominio (frontend|backend|datos|infra|distribuido)
  adjuntar evidencia: base vs cand, percentiles, p_valor, delta, gráfico antes/después
  enrutar:
     frontend -> farola   |  backend -> motor   |  datos -> andulfo
     infra/costo/capacidad, distribuido, IA -> dueño correspondiente
  si sin dueño disponible: T3 peakformance (cobertura declarada)
  registrar consumo de error budget (SRE)
```

La alerta **siempre** lleva evidencia reproducible (comando, entorno, N, distribución) para que el dueño no re-diagnostique desde cero. Contrato de handoff en [interoperabilidad-y-aliadas.md](interoperabilidad-y-aliadas.md).

## Performance en la Definition of Done

Una unidad de trabajo no está "hecha" si erosiona el performance:

- Budgets del dominio tocado **verdes** (o regresión justificada y aprobada con nuevo baseline).
- Sin regresión estadísticamente significativa en hot paths.
- Evidencia antes/después adjunta cuando hubo cambio de riesgo.
- Presupuesto de latencia/error no agotado por el cambio.

Esta cláusula se ancla en la estrategia global; ver DoD y política de budgets en [estrategia-performance.md](estrategia-performance.md).

## Checklist — pipeline con performance protegido

- [ ] Budgets **versionados como código**, con dueño (T2) y percentil declarado por cada uno.
- [ ] Cada gate define explícitamente si **bloquea** o **avisa**, y por qué.
- [ ] Arnés de CI **aislado y consistente**; CV del entorno bajo el umbral objetivo.
- [ ] Mediciones con **repeticiones + warm-up descartado**; se reporta distribución, no promedio.
- [ ] Baseline **versionada** y con política de refresco explícita.
- [ ] Regresión = **significancia + tamaño de efecto mínimo** (no una sola métrica).
- [ ] Micro-benchmarks en check de PR; macro/carga en nightly/pre-prod; métricas reales en canary/prod.
- [ ] Tests flaky en **cuarentena** (avisa) hasta estabilizar; promoción a bloqueante solo con baja tasa de falsos positivos.
- [ ] Alertas con **evidencia reproducible** y **enrutado automático** al dueño de dominio.
- [ ] Consumo de **error budget** registrado (SRE); DORA no degradado por la fricción de los gates.
- [ ] Performance incluida en la **Definition of Done**.
- [ ] Auto-rollback/freeze definido cuando canary/prod degrada.

Hermanos: [frontend-performance.md](frontend-performance.md) · [backend-performance.md](backend-performance.md) · [datos-performance.md](datos-performance.md) · [distribuidos-escalabilidad.md](distribuidos-escalabilidad.md) · [infra-capacidad-costo.md](infra-capacidad-costo.md) · [ia-ml-performance.md](ia-ml-performance.md) · [sistemas-hardware.md](sistemas-hardware.md) · [tiempo-real-embebido.md](tiempo-real-embebido.md) · [plantillas.md](plantillas.md) · [ejemplos.md](ejemplos.md).
