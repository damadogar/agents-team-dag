# Tipos de Intervención: Modernización, Migración y Auditorías

Eneida adapta su método al **tipo de encargo**. Identifícalo en el Paso 0.

---

## 1. Greenfield (desde cero)
- Riesgo de sobre-ingeniería. Empieza simple (monolito modular), evolutiva.
- Define atributos de calidad y límites de dominio temprano; no congeles
  decisiones reversibles.

## 2. Brownfield (sistema existente)
- Primero **entender**: lee código, datos, despliegue, métricas e incidentes
  antes de proponer. No reescribas por gusto.
- Cambios incrementales y seguros; cobertura de pruebas como red de seguridad.

## 3. Modernización por fases
Marco de decisión **6 R** (Gartner/AWS) por componente:
- **Retain** (mantener), **Retire** (eliminar), **Rehost** (lift-and-shift),
  **Replatform** (ajustes), **Refactor/Re-architect** (rediseñar),
  **Repurchase** (SaaS).
Secuencia: inventario → clasificar por valor/riesgo → quick wins → **Strangler
Fig** para reemplazo incremental → desmantelar legacy.

## 4. Migración on-prem → cloud (o entre nubes)
- Evalúa por carga: dependencia, datos, latencia, cumplimiento, costo (TCO).
- Estrategia de datos: replicación, **CDC**, doble escritura controlada, ventana
  de corte (cutover) y plan de rollback.
- Evita lock-in innecesario; usa servicios gestionados con criterio.

## 5. Reingeniería / reescritura
- La reescritura total es de **alto riesgo**: prefiérela solo si el sistema es
  irrecuperable. Por defecto, **Strangler Fig** incremental.
- Mantén paridad funcional verificable (tests de caracterización).

## 6. Rescate técnico (sistema en crisis)
- Estabiliza primero: detén el sangrado (incidentes, seguridad, datos),
  observabilidad mínima, congelar cambios riesgosos.
- Luego diagnostica deuda y riesgos; plan de recuperación por fases con quick
  wins que devuelvan confianza.

## 7. Auditoría técnica / Due diligence
Entregable: informe estructurado con evidencia. Dimensiones a evaluar:
- **Arquitectura** (idoneidad, acoplamiento, escalabilidad).
- **Calidad de código** (mantenibilidad, pruebas, complejidad).
- **Seguridad** (OWASP, secretos, dependencias, cumplimiento).
- **Confiabilidad/operación** (SLO, observabilidad, incidentes, DR).
- **Datos** (modelo, integridad, privacidad).
- **Equipo y proceso** (DORA, prácticas, bus factor, documentación).
- **Costos/TCO** y **deuda técnica** cuantificada.
- **IA/LLM** (si aplica): gobernanza, guardrails, evals.
Salida: hallazgos priorizados (impacto×esfuerzo), riesgos, recomendaciones y
roadmap. Para inversión: semáforo de riesgo y deal-breakers.

---

## Plantilla de plan de modernización por fases
```markdown
## Fase 0 — Estabilización (si aplica)
[Observabilidad, seguridad, detener sangrado]
## Fase 1 — Quick wins (0-3 meses)
[Bajo riesgo, alto valor]
## Fase 2 — Estructural (3-9 meses)
[Strangler Fig, extracción de módulos/servicios justificados]
## Fase 3 — Optimización (9+ meses)
[Escala, costo, automatización]
Cada fase: objetivo, alcance, riesgos, rollback, métricas de éxito (DORA/SLO).
```

## Referencias
- AWS/Azure cloud adoption & migration frameworks (6 R).
- Working Effectively with Legacy Code (Feathers); Strangler Fig (Fowler).
