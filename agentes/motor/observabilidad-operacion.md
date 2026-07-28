# observabilidad-operacion.md — Observabilidad y operación

> Para **instrumentar** tu código, **participar** en incidentes (mitigar/corregir),
> **perfilar/optimizar** y **controlar costo** a nivel de implementación.
>
> **Frontera de rol:** los **objetivos de SLO/SLA**, el **proceso de on-call/
> incidentes** y el **capacity planning** los definen el arquitecto/SRE/operación;
> Motor **implementa la instrumentación** que los hace medibles, **aporta la causa
> raíz técnica** y **ejecuta los fixes**, e **informa** límites/costos. Los
> **GameDays/chaos** los lidera `amado`.

## 1. Los tres pilares + correlación

- **Logs**: eventos discretos, estructurados (JSON), con nivel, `trace_id`,
  contexto. No loguees secretos/PII. Sampling en alto volumen.
- **Métricas**: series temporales agregables (contadores, gauges, histogramas).
  Baratas y baratas de consultar; base de alertas y dashboards.
- **Trazas**: recorrido de una request a través de servicios (spans). Esencial
  en sistemas distribuidos para latencia y dependencias.
- **Correlación**: propaga `trace_id`/`span_id` (W3C Trace Context) por todas las
  llamadas; enlaza logs↔trazas↔métricas. **Exemplars** unen métricas con trazas.

## 2. OpenTelemetry como estándar

- Instrumenta con **OpenTelemetry** (vendor-neutral): SDKs + auto-instrumentación
  + **Collector** para exportar a cualquier backend (Prometheus, Grafana/Tempo/
  Loki, Jaeger, Datadog, New Relic, Honeycomb, etc.). Evita lock-in de agente.

## 3. Qué medir

- **RED** (servicios request-driven): **R**ate, **E**rrors, **D**uration (p50/
  p95/p99). 
- **USE** (recursos): **U**tilization, **S**aturation, **E**rrors (CPU, memoria,
  disco, red, pools).
- **Cuatro señales doradas** (Google SRE): latencia, tráfico, errores, saturación.
- **De negocio**: pedidos/seg, conversiones, colas pendientes, lag de consumidor.
- Latencia: usa **percentiles** (p95/p99), nunca solo promedio.

## 4. SLI / SLO / SLA y error budget

- **SLI**: métrica medible de la experiencia (ej. % de requests <300ms y 2xx).
- **SLO**: objetivo sobre el SLI (ej. 99.9% en 30 días). Realista, por servicio.
- **SLA**: contrato externo con consecuencias; siempre más laxo que el SLO.
- **Error budget**: 100% − SLO. Si se agota, se congela feature work y se prioriza
  fiabilidad. Alinea velocidad y estabilidad con datos.
- **Burn-rate alerts** (multiventana) en vez de alertas por umbral estático.

## 5. Alerting

- Alerta sobre **síntomas** (SLO/usuario afectado), no sobre cada causa.
- **Accionables**: cada alerta tiene runbook y dueño; evita fatiga de alertas
  (silencios, agrupación, severidades).
- Páginas (urgente) vs tickets (no urgente). Revisa y poda alertas ruidosas.

## 6. Gestión de incidentes

- **On-call** con rotación humana sostenible; roles (IC, comms, ops).
- **Severidades** definidas; canal de incidente; comunicación a stakeholders.
- **Mitiga primero** (rollback, feature flag, failover), diagnostica después.
- **Postmortem sin culpa (blameless)**: timeline, impacto, causa raíz (5 whys /
  causa contribuyente), acciones correctivas con dueño y fecha. Aprende del fallo.
- **MTTR/MTTD** como métricas de mejora.

## 7. Runbooks y operación

- **Runbooks** por alerta/servicio: síntomas, diagnóstico, mitigación, escalado.
- **Automatiza** lo repetible (auto-remediation con cuidado).
- **GameDays / chaos** para probar la respuesta: su **diseño y ejecución los
  lidera el QA (`amado`)**; Motor instrumenta el sistema y aplica las mejoras de
  resiliencia que surjan.

## 8. Capacity planning

- Proyecta crecimiento (tráfico, datos), modela headroom (no operes al 100%),
  prueba de carga para conocer límites, define autoscaling con márgenes.
- Vigila saturación (USE) como leading indicator de problemas.

## 9. Performance tuning y profiling

- **Mide antes de optimizar** (perfila: CPU, memoria, alloc, IO, locks). Evita
  optimización prematura.
- Cuellos comunes backend: N+1 y queries lentas (índices), serialización,
  contención de locks, GC, conexiones agotadas, llamadas remotas sincrónicas en
  cadena, falta de cache, payloads grandes.
- **Continuous profiling** (Pyroscope/Parca) en producción para hot paths.
- Optimiza el **camino crítico** y lo que el usuario percibe (p99), no microbench
  irrelevantes.

## 10. FinOps / conciencia de costo

- **Visibilidad**: tagging/etiquetado por equipo/servicio/entorno; dashboards de
  costo; *unit economics* (costo por request/tenant/feature).
- **Optimización**: right-sizing, autoscaling, apagar entornos no-prod, spot/
  reserved/savings plans, niveles de almacenamiento, revisar egress y datos
  huérfanos, cache para reducir cómputo/DB.
- **TCO**: incluye licencias, operación, personas, no solo factura cloud.
- Costo es un atributo de calidad: mídelo a nivel de código (unit economics) e
  **infórmaselo al arquitecto** para sus decisiones; tú optimizas tu código.

## 11. Checklist de observabilidad/operación

```
- [ ] Logs estructurados con trace_id; sin secretos/PII
- [ ] Métricas RED/USE + señales doradas; latencia por percentiles
- [ ] Trazas distribuidas con OpenTelemetry y contexto propagado
- [ ] SLIs/SLOs por servicio + error budget + burn-rate alerts
- [ ] Alertas accionables sobre síntomas, con runbook y dueño
- [ ] Proceso de incidentes + postmortem blameless + acciones con dueño
- [ ] Capacity planning con headroom y autoscaling probado
- [ ] Profiling disponible; cuellos de botella medidos antes de optimizar
- [ ] FinOps: costos etiquetados, unit economics, right-sizing
```
