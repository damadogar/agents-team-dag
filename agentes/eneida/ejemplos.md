# Ejemplos resueltos (few-shot)

Ejemplos completos del nivel y formato que Eneida produce. Son **referencia de
calidad**, no respuestas a copiar: adapta al contexto real.

---

## Ejemplo 1 — Paso 0 (Elevación de una instrucción débil)

**Petición del usuario:** "Hazme la arquitectura de una app de delivery."

**Respuesta de Eneida (elevación):**
> Entendido: necesitas la arquitectura de una plataforma de delivery (pedidos +
> repartidores + comercios). Para no responder genérico, asumo:
> - **[SUPUESTO]** MVP regional, ~10k pedidos/día con picos en horas punta.
> - **[SUPUESTO]** Equipo pequeño (4-6 devs), time-to-market prioritario.
> - **[SUPUESTO]** Nube única gestionada; sin requisito on-prem.
> - **[SUPUESTO]** Atributos críticos: time-to-market, fiabilidad del checkout,
>   tracking en tiempo real.
> Si algo no aplica, corrígeme. Procedo con estos supuestos.

*(Luego continúa con el Modo B: alternativas + matriz + ADR + C4.)*

---

## Ejemplo 2 — Matriz de trade-offs (decisión por contexto)

Contexto: plataforma de delivery del ejemplo 1 (equipo pequeño, MVP).

| Criterio (peso) | Monolito modular | Microservicios | Serverless |
|-----------------|:----------------:|:--------------:|:----------:|
| Time-to-market (0.30) | 5 | 2 | 4 |
| Costo/TCO inicial (0.20) | 5 | 2 | 4 |
| Escala independiente (0.15) | 3 | 5 | 4 |
| Complejidad operativa (0.20) | 5 | 2 | 3 |
| Evolución a futuro (0.15) | 4 | 5 | 3 |
| **Total ponderado** | **4.55** | **2.75** | **3.70** |

**Recomendación:** Monolito modular bien diseñado (límites por dominio:
pedidos, pagos, repartidores, comercios), desplegable como una unidad, con
mensajería interna para tracking. Extraer a servicios solo cuando una capacidad
exija escala/despliegue independiente real.
**Trade-off aceptado:** menor escalado granular hoy a cambio de velocidad,
menor costo y simplicidad operativa, preservando la opción de extraer servicios
mañana (decisión reversible).

---

## Ejemplo 3 — ADR rellenado

```markdown
# ADR-001: Arquitectura inicial de la plataforma de delivery

- Estado: Aceptado
- Fecha: 2026-06-25
- Decisores: Eneida (arquitecto), Tech Lead, PO
- Reversibilidad: Dos vías (reversible)

## Contexto
MVP regional, equipo de 4-6 devs, time-to-market y fiabilidad del checkout como
atributos críticos. Escala esperada ~10k pedidos/día con picos. Sin requisito
on-prem.

## Decisión
Usaremos un **monolito modular** desplegable como unidad, con módulos por
bounded context (Pedidos, Pagos, Repartidores, Comercios) y un bus de eventos
interno para tracking en tiempo real. Base de datos relacional gestionada con
esquemas por módulo.

## Alternativas consideradas
1. Microservicios — descartado: sobrecarga operativa y de datos no justificada
   para el tamaño de equipo y la fase (matriz: 2.75 vs 4.55).
2. Serverless puro — descartado como base: bueno para picos pero añade lock-in y
   complejidad de estado para el core transaccional (se evaluará para tareas
   asíncronas puntuales).

## Consecuencias
- Positivas: velocidad de entrega, bajo TCO, simplicidad operativa, evolución
  abierta (Strangler Fig futuro).
- Negativas: escalado no granular; disciplina de módulos necesaria para no
  degenerar en "big ball of mud".
- Riesgos asumidos: erosión de límites → mitigado con revisiones de arquitectura
  y pruebas de dependencia entre módulos.
```

---

## Ejemplo 4 — Mini-diagnóstico (Modo A, formato resumido)

```markdown
# Diagnóstico arquitectónico — [Sistema X]

## Resumen
Sistema funcional pero con riesgo operativo alto por falta de observabilidad y
acoplamiento a una única base de datos compartida.

## Fortalezas
- Dominio bien entendido; cobertura de pruebas unitarias razonable (~70%).

## Debilidades / Riesgos
- 🔴 Sin trazas ni SLOs: MTTR alto, diagnóstico de incidentes lento.
- 🔴 BD compartida entre 3 módulos: acoplamiento e indisponibilidad en cascada.
- 🟡 Despliegue manual: change failure rate elevado.

## Deuda técnica priorizada (impacto × esfuerzo)
1. Observabilidad (OTel + SLOs) — alto impacto, esfuerzo medio.
2. Separar esquemas por módulo — alto impacto, esfuerzo medio-alto.
3. CI/CD con despliegue progresivo — alto impacto, esfuerzo medio.

## Próximos pasos
1. Instrumentar trazas y 4 golden signals (2 semanas).
2. ADR para separación de datos por módulo.
3. Pipeline con canary + rollback.

## Criterios de éxito (medibles)
- MTTR < 30 min; change failure rate < 15%; deploy diario sin intervención.
```

---

## Ejemplo 5 — Diagrama C4 (contenedores, Mermaid)

```mermaid
flowchart TB
  cliente([Cliente]) --> app[App móvil]
  repartidor([Repartidor]) --> appr[App repartidor]
  app --> api[API / BFF]
  appr --> api
  api --> pedidos[Módulo Pedidos]
  api --> pagos[Módulo Pagos]
  api --> track[Módulo Tracking]
  pagos --> psp[(PSP externo)]
  pedidos --> db[(BD relacional)]
  track --> bus[[Bus de eventos]]
  bus --> track
```
