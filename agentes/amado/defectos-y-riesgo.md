# Gestión de defectos y risk-based testing

Referencia de Amado para los modos **A**, **C** y **D**.

---

## 1. Ciclo de vida del defecto

```
Nuevo → Triage → Asignado → En progreso → Resuelto → En verificación (re-test)
      → Cerrado
                 ↘ Rechazado / Duplicado / No reproducible
                 ↘ Reabierto (si el re-test falla)
                 ↘ Diferido (aceptado como riesgo residual)
```

Reglas:
- Un defecto **Resuelto** solo se cierra tras **re-test exitoso** por QA.
- Si el re-test falla → **Reabierto** (no se crea uno nuevo).
- "Diferido/aceptado" requiere **owner explícito** que acepta el riesgo.

---

## 2. Severidad vs Prioridad (no son lo mismo)

- **Severidad** = impacto técnico/funcional del defecto.
- **Prioridad** = urgencia de negocio para resolverlo.

| Severidad | Definición |
|---|---|
| 🔴 Crítica | Caída total, pérdida/corrupción de datos, brecha de seguridad, bloqueo de flujo core sin workaround |
| 🟠 Alta | Funcionalidad principal degradada, sin workaround razonable |
| 🟡 Media | Funcionalidad secundaria afectada, con workaround |
| 🟢 Baja | Cosmético, texto, mejora menor |

| Prioridad | SLA de referencia |
|---|---|
| P1 | Inmediato / hotfix |
| P2 | Antes del release actual |
| P3 | Próximo sprint |
| P4 | Backlog |

Un defecto puede ser **Severidad baja / Prioridad alta** (ej. typo en el logo del
home) o **Severidad alta / Prioridad baja** (crash en función casi sin uso).

---

## 3. Reglas de triage

- Frecuencia: diaria en sprint activo / por release.
- Participan: QA + Dev lead + PO (cuando hay decisión de negocio).
- Por cada defecto: confirmar reproducibilidad, severidad, prioridad, owner,
  duplicado/relación, decisión (resolver/diferir/rechazar).
- **No** se cierra por antigüedad sin análisis.

---

## 4. Anatomía de un buen reporte de defecto

```
ID | Título claro (qué falla, dónde)
Severidad | Prioridad | Estado | Owner | Ambiente/Build
Precondiciones
Pasos para reproducir (numerados, deterministas)
Resultado actual vs Resultado esperado
Evidencia: screenshots / video / logs / request-response / stack trace
Datos de prueba usados
Trazabilidad: Requisito/AC ↔ Caso de prueba que lo detectó
Impacto / frecuencia | Workaround (si existe)
```

Sin pasos reproducibles + evidencia, el defecto **no está listo** para asignarse.
Nunca incluyas PII/secretos reales en la evidencia.

---

## 5. Risk-based testing

Prioriza **qué probar y con qué profundidad** según el riesgo.

**Riesgo = Impacto × Probabilidad**, ajustado por **criticidad del flujo** y
**exposición** (frecuencia de uso, nº de usuarios, datos sensibles, cambios
recientes).

### Matriz de riesgo
```
Impacto ↑
  Alto  | 🟡 Medio | 🟠 Alto  | 🔴 Crítico
  Medio | 🟢 Bajo  | 🟡 Medio | 🟠 Alto
  Bajo  | 🟢 Bajo  | 🟢 Bajo  | 🟡 Medio
        +----------+----------+-----------→ Probabilidad
          Baja       Media      Alta
```

### Asignación de esfuerzo
| Nivel de riesgo | Profundidad de prueba |
|---|---|
| 🔴 Crítico | Exhaustiva: técnicas formales + E2E + no funcional + automatización |
| 🟠 Alto | Amplia: casos positivos/negativos/borde + automatización de regresión |
| 🟡 Medio | Casos principales + algunos bordes |
| 🟢 Bajo | Smoke / verificación básica |

Mantén la matriz **viva**: se actualiza con cada cambio, incidente y aprendizaje.

---

## 6. Estrategias de regresión / smoke / sanity

- **Smoke:** ¿el build es testeable? Flujos vitales, tras cada deploy. Rápido.
- **Sanity:** verificación rápida y focalizada tras un fix puntual.
- **Regresión:** asegurar que lo nuevo no rompió lo existente. Selección por
  riesgo e impacto del cambio (no siempre "todo"); automatizar lo estable.
- **Selección de regresión:** áreas tocadas + dependencias + flujos críticos +
  históricos de bugs. Documenta el subset y su justificación.

---

## 7. Reducción de deuda de calidad

- Visibiliza la deuda (defectos diferidos, cobertura faltante, tests flaky).
- Presupuéstala por interés/riesgo; no la dejes crecer en silencio.
- Métricas de fuga (defect leakage) para atacar la causa raíz, no el síntoma.
