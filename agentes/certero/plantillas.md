# Plantillas de entregables

Plantillas reutilizables para que cada entregable de certero sea **reproducible,
verificable y accionable**. Adáptalas al contexto; no inventes campos que no
aplican, pero **nunca omitas la causa raíz ni la prueba** cuando afirmes que
corregiste un defecto. Ejemplos resueltos con estas plantillas en
[ejemplos.md](ejemplos.md).

Convención de severidad (de [gobernanza y ética](gobernanza-y-etica.md)):
**Bloqueante** (rompe correctitud) · **Importante** (deuda/fragilidad) · **Menor/
nit** (opcional) · **Elogio**.

---

## 1. Informe de code review (de un PR/diff/módulo)

```
# Review — <objeto> (<rama/PR/módulo>)
Revisor: certero · Fecha: <fecha> · Veredicto: Aprobar / Aprobar-con-cambios / Bloquear

## Encuadre
- Qué hace el cambio y por qué (intención): ...
- Alcance revisado: <archivos/áreas>
- Radio de impacto: <llamadores/contratos afectados>
- Supuestos: [SUPUESTO] ...

## Hallazgos por severidad
### 🔴 Bloqueantes (correctitud)
- [B1] `archivo:línea` — <defecto>. Escenario disparador: <entrada/estado/orden>.
  Por qué: <causa>. Fix propuesto: <resumen>. Verificación: <test que falla→pasa>.

### 🟠 Importantes
- [I1] `archivo:línea` — <deuda/fragilidad/edge case>. Riesgo: <qué inducirá>.

### 🟡 Menores / nits (opcionales)
- [N1] `archivo:línea` — <sugerencia>. (nit)

### 🟢 Elogios
- <buena decisión reconocida>

## Enrutado por disciplina (lo que NO es de certero)
- Performance → `peakformance`: ...
- Seguridad → `destroyer`: ...
- Arquitectura → `eneida`: ...
- Datos/esquema → `andulfo`: ...
- Suite/estrategia de pruebas → `amado`: ...

## Veredicto y próximos pasos
- Decisión: <aprobar/bloquear> porque <razón>.
- Acciones requeridas antes de merge: [B1], ...
- Handoffs abiertos: ...
```

---

## 2. Reporte de defecto + análisis de causa raíz (RCA)

```
# Defecto — <título corto>
Severidad: <Bloqueante/Importante/Menor> · Estado: <abierto/en corrección/cerrado>

## Síntoma
- Observado: <qué se ve mal> en `archivo:línea` / <entorno>.
- Evidencia: <traza/log/entrada/test rojo>.

## Reproducción (determinista)
- Pasos / entrada mínima: ...
- Frecuencia: <siempre / intermitente + condición>.

## Causa raíz (no el síntoma)
- Por qué ocurre: ...
- Evidencia del diagnóstico: <bisección/comparación/perfil de estado>.
- Causa próxima vs causa raíz: ...

## Radio de impacto
- Llamadores/contratos/invariantes afectados: ...
- ¿Hay datos ya corrompidos por el bug? <sí/no> → coordinación con `andulfo` si aplica.

## Disciplina
- ¿Es correctitud? <sí → certero> / <no → enrutar a peakformance/destroyer/eneida/andulfo>.

## Prevención
- Cómo evitar toda la clase: <regla de linter / tipo / test de caracterización / cambio de API>.
```

---

## 3. Handoff de fix (contrato Tier 2 / Tier 3)

Estructura fija para entregar una corrección al dueño de dominio o dejarla
"LISTA PARA EJECUCIÓN". Espejo del contrato de
[interoperabilidad](interoperabilidad-y-aliados.md) §4.

```
# Handoff de fix — <defecto> → <destinatario: motor/farola/andulfo/sysuniversal-ai/eneida>
Tier: <T2 co-implementa / T3 fallback "pendiente de revisión del dueño">

| Campo | Contenido |
|---|---|
| Defecto | <qué está mal, `archivo:línea`, severidad> |
| Escenario disparador | <entrada/estado/orden exacto> |
| Reproducción | <pasos deterministas o test rojo> |
| Causa raíz | <por qué, con evidencia — no el síntoma> |
| Fix propuesto | <diff/PoC mínimo y correcto> |
| Prueba que falla→pasa | <el test que fallaba antes y pasa después> |
| Radio de impacto | <llamadores/contratos/invariantes/edge cases> |
| Destinatario | <agente> — qué debe revisar/mergear |
| Marca (si T3) | "pendiente de revisión del dueño" · reversible · con su prueba |

## Verificación tras integrar
- [ ] Re-ejecutar la prueba que falla→pasa sobre el fix integrado.
- [ ] Correr la suite afectada (propiedad de `amado`) — sin regresión.
- [ ] Proteger la clase con gate/caracterización.
```

---

## 4. Comentario de review (unidad atómica, respetuosa)

```
[<severidad: Bloqueante/Importante/nit>] `archivo:línea`
Qué: <el defecto o la sugerencia, sobre el código — no la persona>.
Por qué: <el escenario que lo dispara / el riesgo>.
Propuesta: <la alternativa concreta o pregunta abierta>.
```

Ejemplos:
- `[Bloqueante] facturacion:42 — Qué: la condición usa >= donde debe ser >, así el
  último elemento se procesa dos veces. Por qué: con lista de tamaño N el índice N
  entra al bucle. Propuesta: cambiar a > (test que lo cubre abajo).`
- `[nit] utilidades:10 — Qué: el nombre tmp no revela intención. Propuesta:
  saldoPendiente. (opcional)`

---

## 5. Corrección aplicada directamente (T1 o T3)

```
# Corrección aplicada — <defecto>
Tier: <T1 cross-cutting propio / T3 fallback — pendiente de revisión de <dueño>>

## Causa raíz
...

## Cambio (mínimo)
- Diff / resumen del fix: ...
- Qué NO cambié (para no mezclar refactor cosmético): ...

## Prueba
- Test que falla ANTES / pasa DESPUÉS: <ubicación/nombre>.

## No-regresión
- Suite afectada: <verde>. Edge cases/invariantes revisados: ...

## Prevención
- Gate/estándar/caracterización dejado: ...

## Marca de propiedad (si T3)
- "Pendiente de revisión del dueño <agente>". Reversible: <cómo>.
```

---

## 6. Informe de auditoría de correctitud (sistema/módulo, modo solo-lectura)

Para encargos de *auditar* (no "corrige"): certero **reporta y espera autorización**
antes de tocar (separar diagnosticar de corregir).

```
# Auditoría de correctitud — <sistema/módulo>
Modo: SOLO-LECTURA (hallazgos para autorización; sin cambios aplicados)

## Resumen ejecutivo
- Estado de correctitud: <sano / con riesgos / crítico>.
- Nº de hallazgos: Bloqueantes <n> · Importantes <n> · Menores <n>.

## Hallazgos priorizados (tabla)
| # | Severidad | archivo:línea | Defecto | Escenario | Disciplina/dueño |
|---|-----------|---------------|---------|-----------|------------------|

## Plan de corrección propuesto (a la espera de tu autorización)
- Lote 1 (bloqueantes): ... — tier/dueño ...
- Lote 2 (importantes): ...
- Enrutados a otras disciplinas: performance→`peakformance`, seguridad→`destroyer`, ...

> No se aplica ninguna corrección hasta autorización explícita.
```

---

**Relacionados:** [ejemplos resueltos](ejemplos.md) ·
[interoperabilidad y contrato de handoff](interoperabilidad-y-aliados.md) ·
[gobernanza y severidad](gobernanza-y-etica.md) · [checklists](checklists.md).
