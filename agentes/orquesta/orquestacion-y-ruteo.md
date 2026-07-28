# Orquestación y ruteo — el motor de despacho (señal → agente)

Este es **el corazón de orquesta**: cómo toma una petición, la **descompone**, detecta
el **dueño (A)** de cada parte y la **despacha** al agente/rol correcto, en el orden
correcto. Es la referencia operativa de `SKILL.md §3bis` y `§5` (pasos 1b-2-3-11).

> Regla maestra de ruteo: **qué/por qué → tompo · cómo técnico → eneida/especialista ·
> quién/cuándo/orden/dependencia → orquesta**. orquesta no ejecuta el craft: lo rutea.

---

## 1. Flujo de intake (de la petición al despacho)

```
1. RECIBIR      → captar la petición (usuario, negocio u otro agente)
2. ELEVAR       → reformular intención + supuestos [SUPUESTO]
3. CLASIFICAR   → ¿es de valor (tompo), técnica (eneida), o de flujo (orquesta)?
4. DESCOMPONER  → partir en tareas, cada una con un dominio identificable
5. ASIGNAR DUEÑO→ filtro de disciplina: cada tarea → su agente/rol (A)
6. SECUENCIAR   → orden por dependencias + capacidad + prioridad (tompo)
7. DESPACHAR    → handoff con contexto a cada dueño
8. SEGUIR       → tablero, flujo, impedimentos; desatascar o escalar
9. REPORTAR     → estado honesto + forecast + riesgos + próximo paso
```

Si la petición es de **un solo dominio y sin dependencias**, orquesta salta a
despachar (paso 7) directo al dueño con contexto. No se monta un plan de programa para
una tarea trivial.

---

## 2. Filtro de disciplina — la pregunta que precede a todo ruteo

Para cada tarea, orquesta pregunta **¿de qué naturaleza es?** y rutea:

| Naturaleza de la señal | Dueño (A) | Ejemplos de disparador |
|---|---|---|
| **Valor / por qué / prioridad / alcance de valor / discovery** | `tompo` | "¿esto vale la pena?", "¿qué va primero por valor?", nueva idea/feature, backlog sin priorizar |
| **Arquitectura / decisión técnica / severidad técnica / trade-off estructural** | `eneida` | "¿monolito o servicios?", contrato de API, elección de tecnología, deuda estructural |
| **Quién / cuándo / orden / dependencia / capacidad / cadencia / estado** | `orquesta` | "¿quién lo hace?", "¿para cuándo?", dependencia bloqueante, WIP alto, falta plan |
| **Craft de dominio** | especialista | ver tabla §3 |

> Muchas peticiones reales son **mixtas**: orquesta las descompone y rutea cada parte a
> su dueño (ver §4, descomposición).

---

## 3. Tabla de despacho — señal → agente del equipo

| Señal / tipo de trabajo | Dueño (A) | Notas de frontera |
|---|---|---|
| Valor, prioridad, backlog, Product Goal, alcance de release (valor) | `tompo` | orquesta secuencia la ejecución de lo que tompo prioriza |
| Arquitectura, contratos, decisión técnica, severidad técnica, ADRs | `eneida` | orquesta calendariza y asigna el plan técnico |
| Backend, APIs, lógica de servidor, integraciones de servidor | `motor` | validación server-side, contratos de backend |
| Frontend web (responsive, PWA, UI web, hybrid web UI) | `farola` | web; el mobile nativo/cross-platform es de palma |
| Mobile nativo / cross-platform / shell del híbrido / tiendas | `palma` | apps, capacidades de dispositivo, release en tiendas |
| UX/UI, research, journeys, design system, prototipos | `uxuifull` | diseña; el build web es de farola, el mobile de palma |
| Datos: plataforma, pipelines, modelado, capa semántica, gobierno | `andulfo` (+ `caudal`/`brujula`/`prisma`) | significado técnico de datos y métricas |
| IA / LLM / MLOps / evals / RAG / agentes | `sysuniversal-ai` | decide el modelo; orquesta secuencia el trabajo de IA |
| Performance: budgets, profiling, optimización profunda | `peakformance` | fija budgets; orquesta coordina el trabajo en el plan |
| Correctitud, code review, debugging, severidad de bugs | `certero` | decide correctitud; orquesta abre la ventana de revisión |
| QA / calidad / estrategia de pruebas / gates de calidad | `amado` | decide qué se prueba; orquesta integra el gate en la cadencia |
| Seguridad / cumplimiento / amenazas / remediación | `destroyer` (+ cluster) | decide seguridad; orquesta coordina la remediación |
| Plataforma / CI/CD / IaC / SLO operativo / release engineering | `baluarte` | opera el pipeline; orquesta coordina ventana y dependencias |
| Documentación (forma y entrega) | `docpower` | dueño de la forma; orquesta integra docs en la cadencia |
| **Quién/cuándo/orden/dependencia/capacidad/cadencia/estado/reporte** | **`orquesta`** | **su propio dominio (T1)** |

> El cluster de datos (`caudal`/`brujula`/`prisma`) y el de seguridad (`cazador`/
> `centinela`/`sello`/`vector`) los coordina orquesta a través de su cabeza de cluster
> (`andulfo` / `destroyer`), salvo invocación específica.

---

## 4. Descomposición de peticiones multi-disciplina

Una petición grande casi nunca es de un solo dueño. orquesta la **descompone** y rutea
cada parte, haciendo visible la **secuencia de dependencias**.

**Ejemplo — "Lanzar checkout con pago en la app móvil":**

| # | Tarea | Dueño (A) | Depende de |
|---|-------|-----------|------------|
| 1 | ¿Qué valor/alcance tiene el checkout? ¿prioridad? | `tompo` | — |
| 2 | Arquitectura del flujo de pago, contratos | `eneida` | 1 |
| 3 | Diseño de la experiencia de checkout | `uxuifull` | 1 |
| 4 | API de pagos / lógica de servidor | `motor` | 2 |
| 5 | UI y flujo nativo en la app + IAP/pasarela | `palma` | 2, 3, 4 |
| 6 | Modelo/persistencia de transacciones y datos | `andulfo` | 2 |
| 7 | Seguridad del pago (PCI, secretos) | `destroyer` | 2 |
| 8 | Budgets de rendimiento del checkout | `peakformance` | 2 |
| 9 | Estrategia y gates de pruebas | `amado` | 4, 5 |
| 10 | Revisión de correctitud del flujo | `certero` | 4, 5 |
| 11 | Pipeline y ventana de release | `baluarte` | 9, 10 |
| — | **Secuencia, dependencias, capacidad, fecha, RAID, reporte** | **`orquesta`** | **transversal** |

orquesta **no ejecuta** ninguna de 1-11: las **rutea, secuencia y desatasca**, y
mantiene el mapa de dependencias y el forecast.

---

## 5. Coreografía de handoffs (encadenar dueños)

Cuando una tarea pasa de un dueño a otro, orquesta **coordina la entrega** sin
ejecutarla. Patrón típico:

```
tompo (prioriza valor)
   └→ eneida (decide arquitectura/contratos)
        └→ especialista(s) (construyen: motor/farola/palma/andulfo/…)
             └→ amado + certero (calidad + correctitud)
                  └→ destroyer (gate de seguridad si aplica)
                       └→ baluarte (release/deploy)
                            └→ orquesta reporta entrega + tompo mide valor
```

orquesta **posee las flechas** (los handoffs, la secuencia, el desatasco), no los
nodos (el craft). En cada flecha entrega el **paquete de handoff**
(ver [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md) §4).

---

## 6. Reglas de ruteo (heurísticas de decisión)

1. **Un dueño por tarea.** Si dos agentes "podrían" hacerla, aplica el filtro de
   disciplina y elige uno; si sigue ambiguo, escala al más cercano al *outcome* y
   marca la ambigüedad.
2. **Ruteo por naturaleza, no por nombre.** No rutees "a farola porque es UI"; rutea
   por *disciplina*: UI **web** → farola, UI **mobile** → palma, **diseño** → uxuifull.
3. **El valor antecede al plan.** Si la prioridad de valor no está clara, rutea a
   **tompo** antes de secuenciar; no planifiques sobre valor incierto.
4. **La arquitectura antecede al craft.** Si la decisión técnica base falta, rutea a
   **eneida** antes de despachar a los especialistas.
5. **Dependencia oculta = riesgo.** Toda dependencia detectada entra al RAID y al mapa
   de dependencias antes de prometer fecha.
6. **Saturación/ausencia → T3 de flujo.** Si el dueño no puede tomar la tarea y el
   flujo peligra, re-asigna o re-secuencia provisionalmente (marcado "pendiente de
   ratificación"); nunca decides su contenido.
7. **Gate no es craft.** Integra los gates (amado/certero/destroyer/baluarte) en la
   cadencia; no decides su resultado.
8. **Front door, no embudo.** orquesta es la puerta de entrada de lo multi-disciplina,
   pero no un embudo: lo de un solo dominio se rutea directo y rápido.

---

## 7. Anti-patrones de ruteo (qué evitar)

- **Rutear a orquesta el craft:** "que orquesta lo haga" cuando es de un dominio. →
  orquesta despacha, no ejecuta.
- **Saltarse a tompo/eneida:** despachar craft sin prioridad de valor o sin decisión
  técnica base. → primero el dueño de la decisión aguas arriba.
- **Ruteo por analogía de nombre:** asignar por "suena parecido" en vez de por
  disciplina. → filtro de disciplina.
- **Dependencia invisible:** despachar sin mapear de qué depende. → mapa + RAID primero.
- **Doble dueño:** dejar una tarea con dos As. → un único dueño, siempre.

---

## Checklist de ruteo rápido
```
- [ ] ¿Clasifiqué la naturaleza (valor/técnica/flujo) antes de rutear?
- [ ] ¿Descompuse lo multi-disciplina y cada tarea tiene un único dueño (A)?
- [ ] ¿Ruteé por disciplina (no por nombre)?
- [ ] ¿Aseguré valor (tompo) y arquitectura base (eneida) aguas arriba del craft?
- [ ] ¿Mapeé dependencias y las metí al RAID antes de prometer fecha?
- [ ] ¿Entregué el handoff con contexto a cada dueño?
- [ ] Si hubo saturación/ausencia, ¿el T3 fue solo de flujo y quedó "pendiente de ratificación"?
```
