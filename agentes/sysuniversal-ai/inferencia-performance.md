# inferencia-performance.md — Performance, costo y operación de inferencia

Optimización de **latencia, throughput y costo** de la inferencia: *batching*,
*caching*, cuantización, escalado, colas y GPU/TPU. La arquitectura está en
[arquitectura-ia.md](arquitectura-ia.md); el monitoreo en [mlops.md](mlops.md).

> Frontera: los **recursos de cómputo/plataforma** los provee `andulfo`;
> SysUniversal-AI **optimiza el uso** y define requisitos.

---

## 1. SLOs de inferencia (define primero)

| SLI | Métrica | Ejemplo de SLO |
|---|---|---|
| **Latencia** | p50/p95/p99, TTFT (LLM) | p95 < X ms; TTFT < Y ms |
| **Throughput** | req/s, tokens/s | ≥ Z bajo carga pico |
| **Disponibilidad** | % éxito | ≥ 99.x% |
| **Costo** | por petición / por 1k tokens | ≤ presupuesto |
| **Calidad** | eval online | ≥ umbral (ver mlops/llm) |

Optimiza contra SLOs; **no** optimices a ciegas.

## 2. Palancas de latencia

- **Batching dinámico:** agrupa peticiones para mejor uso de GPU (sube throughput;
  cuida la latencia de cola).
- **KV cache** (LLM): reutiliza atención entre tokens.
- **Streaming de tokens:** mejora *latencia percibida* (TTFT) aunque el total sea
  igual.
- **Speculative decoding / draft models** cuando aplica.
- **Modelo más pequeño/destilado/cuantizado** si cumple calidad.
- **Recorte de contexto** (RAG): menos tokens = menos latencia y costo.
- **Cercanía/red:** ubicación del serving cerca del consumidor.

## 3. Palancas de costo (FinOps de IA)

- **Caching:** de respuestas (idénticas/similares) y de *embeddings*.
- **Routing por costo/calidad:** modelo barato para casos fáciles, caro solo
  cuando hace falta (cascada).
- **Cuantización** (int8/int4) y *batching* para amortizar GPU.
- **Context/token budget:** *prompts* concisos, RAG selectivo, límites de salida.
- **Autoscaling a cero** en cargas intermitentes; *spot*/preemptible donde tolere.
- **Medir costo por petición/token** como SLI de primera clase y por caso de uso.

## 4. Throughput y escalado

- **Escalado horizontal** de réplicas detrás de balanceador; *autoscaling* por
  métrica (QPS, *queue depth*, utilización GPU).
- **Colas + backpressure:** absorbe picos sin caídas; define política de descarte/
  *timeout*.
- **GPU sharing / multi-instancia** (MIG) para modelos pequeños; *fractional GPU*.
- **Batch vs online:** mueve a *batch* lo que no necesita tiempo real.
- **Cold start:** *pre-warming*, *keep-alive*, modelos en memoria.

## 5. GPU/TPU

- Elegir aceleradores por **memoria del modelo** y **throughput** requerido.
- **Cuantización/optimización** (TensorRT, vLLM *paged attention*) para densidad.
- Vigilar **utilización** (no pagar GPU ociosa) y **OOM** (memoria del modelo +
  *KV cache* + *batch*).

## 6. Patrones de serving y su perfil

| Patrón | Latencia | Costo | Notas |
|---|---|---|---|
| Online + autoscale | Baja | Medio/Alto | SLO estricto; cuidar *cold start* |
| Batch | Alta (no urgente) | Bajo | Maximiza throughput/GPU |
| Cache-first | Muy baja (hit) | Muy bajo (hit) | Ideal para repetición |
| Cascada (router) | Variable | Optimizado | Barato primero, caro si falla |
| Edge/embedded | Mínima | Bajo runtime | Modelo pequeño/cuantizado |

## 7. Observabilidad de performance/costo

- Métricas: latencia p50/p95/p99, TTFT, tokens/s, req/s, *queue depth*,
  utilización GPU, **costo por petición/token**, *cache hit ratio*, errores/timeouts.
- *Tracing* de la cadena (RAG/agente) para ubicar el cuello de botella.
- Alertas por SLO (latencia/costo) y por saturación (cola/GPU).

## 8. Checklist de performance

- [ ] SLOs de latencia/throughput/costo definidos
- [ ] Batching/caching evaluados (con su impacto en calidad)
- [ ] Autoscaling y colas con *backpressure*
- [ ] Cuantización/optimización si cumple calidad
- [ ] Routing por costo/calidad donde aplica
- [ ] Costo por petición/token monitoreado y presupuestado
- [ ] *Cold start* mitigado
- [ ] Observabilidad de performance/costo activa

## 9. Anti-patrones

- Optimizar latencia **sacrificando calidad/seguridad** sin medirlo.
- *Batching* agresivo que dispara la **latencia de cola**.
- GPU **siempre encendida** para tráfico intermitente.
- Enviar **todo el contexto** posible "por si acaso" (costo/latencia).
- No medir **costo por token**; sorpresa en la factura.
- Un solo modelo caro para **todos** los casos (sin cascada/routing).
