# Plantillas de producto (listas para usar)

Plantillas reutilizables de **tompo** (Product Owner). Copia, completa y adapta.
Cada bloque dice **cuándo usarla** y enlaza al satélite que la explica. Recuerda la
**frontera de rol**: tompo define el **qué/porqué**; el **cómo** es del especialista
(ver [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)).

> Regla de oro (todas las plantillas): cierra con **Outcome buscado**, **Cómo se
> medirá** y **Próximo paso**.

---

## 0. Captura de entradas (brief de PO)

*Cuándo:* al arrancar cualquier petición; si falta algo crítico, márcalo **[SUPUESTO]**
y no te bloquees. Detalle en [descubrimiento.md](descubrimiento.md).

```
Producto / módulo / feature / idea:
Problema y usuario objetivo (job-to-be-done):
Outcome de negocio y métrica de éxito:
Tipo de producto y dominio (B2B/B2C, SaaS, marketplace, fintech…):
Marco / metodología (Scrum/SAFe/Kanban/LeSS/Nexus/híbrido):
Estado: greenfield (0→1) / in-flight / en mercado:
Criticidad / regulación / privacidad (GDPR, Habeas Data, HIPAA, PCI, PSD2…):
Restricciones (tiempo, presupuesto, equipo, dependencias):
Datos disponibles (analítica, investigación, feedback, soporte):
Stakeholders y su poder/interés:
Supuestos asumidos [SUPUESTO]:
```

---

## 1. Product Vision Board (Pichler)

*Cuándo:* al definir o revisar la visión de producto antes del Product Goal.
Detalle en [estrategia-vision.md](estrategia-vision.md).

```
VISIÓN (la razón de ser, el cambio que buscamos): ...

| Grupo objetivo | Necesidades (problema/JTBD) | Producto (qué es) | Objetivos de negocio |
|----------------|-----------------------------|-------------------|----------------------|
| ¿Quién compra/usa? | ¿Qué problema resolvemos y por qué importa? | 3-5 features clave; ¿por qué es viable/factible? | ¿Cómo nos beneficia? (ingreso, retención, coste) |

Outcome buscado: ...
Cómo se medirá: ...
Próximo paso: ...
```

### Product Goal (Scrum Guide 2020)

*Cuándo:* para anclar el backlog a un objetivo medible de mediano plazo.

```
Product Goal: Lograr <outcome medible> para <usuario/segmento> antes de <horizonte>,
de modo que <impacto de negocio>.
Métrica de avance: <métrica + línea base → objetivo>.
Se considera cumplido cuando: <condición observable>.
```

---

## 2. Opportunity Solution Tree (Teresa Torres)

*Cuándo:* en discovery continua, para conectar el outcome con oportunidades,
soluciones y experimentos. Detalle en [descubrimiento.md](descubrimiento.md).

```
                 [OUTCOME deseado: métrica + objetivo]
                              │
        ┌─────────────────────┼─────────────────────┐
   [Oportunidad A]      [Oportunidad B]        [Oportunidad C]   (necesidades/pains reales con evidencia)
        │                     │
   ┌────┴────┐           ┌────┴────┐
[Solución A1] [A2]   [Solución B1] [B2]                          (ideas que atacan la oportunidad)
     │
[Experimento]  ← prueba el supuesto más riesgoso de la solución (ver §11)
```

Regla: cada oportunidad nace de **evidencia de usuario** (entrevista/dato), no de opinión.

---

## 3. Story Map (Jeff Patton)

*Cuándo:* para visualizar el flujo del usuario y cortar releases por outcome (no por
capas técnicas). Detalle en [backlog-requisitos.md](backlog-requisitos.md).

```
BACKBONE →  [Actividad 1]      [Actividad 2]      [Actividad 3]      (lo que el usuario hace, en orden)
            [Paso 1.1 1.2]     [Paso 2.1 2.2]     [Paso 3.1]         (tareas del usuario)
----------------------------------------------------------------- 
Release 1   ( historia )       ( historia )       ( historia )       ← MVP: el caminito más delgado que entrega valor
(MVP)
-----------------------------------------------------------------
Release 2   ( historia )       ( historia )                          ← mejora del outcome
-----------------------------------------------------------------
Later       ( historia )                          ( historia )
```

---

## 4. Historia de usuario + Criterios de aceptación (Gherkin)

*Cuándo:* al definir un ítem de backlog "Ready". INVEST y 3C en
[backlog-requisitos.md](backlog-requisitos.md); testabilidad la afina **amado**.

```
Título:
Como <rol/usuario>
quiero <capacidad/acción>
para <beneficio/outcome>.

Contexto / por qué (link al outcome y a la oportunidad del OST):
Valor / prioridad (método y score, ver §6):
Notas de diseño (handoff a uxuifull) | técnicas (handoff a eneida/motor/farola):
Fuera de alcance:
Dependencias de equipo:
```

```gherkin
Funcionalidad: <nombre>

  Escenario: <camino feliz>
    Dado <precondición>
    Cuando <acción del usuario>
    Entonces <resultado observable y verificable>

  Escenario: <caso de error / borde>
    Dado <precondición>
    Cuando <acción inválida>
    Entonces <mensaje/resultado esperado>
```

> tompo escribe el **qué debe cumplir**; **amado** lo vuelve casos de prueba y deriva
> los escenarios negativos/borde (RACI #7). La estimación es del equipo, no de tompo.

---

## 5. Definition of Ready (DoR)

*Cuándo:* gate de entrada de una historia a sprint/flujo. La **DoD** (calidad
liberable) **es de amado**, no de tompo (RACI #8). Detalle en
[backlog-requisitos.md](backlog-requisitos.md).

```
La historia está READY cuando:
- [ ] Tiene outcome/valor claro y trazado (outcome→oportunidad→solución→historia).
- [ ] Cumple INVEST (independiente, negociable, valiosa, estimable, pequeña, testeable).
- [ ] Criterios de aceptación testeables (Gherkin) acordados con amado.
- [ ] Diseño/UX necesario disponible (handoff de uxuifull) si aplica.
- [ ] Dependencias técnicas identificadas (eneida/motor/farola) y sin bloqueos.
- [ ] Requisitos de cumplimiento/seguridad marcados (sello) si aplica.
- [ ] Cabe en un sprint / es "pull-able" en flujo; el equipo la entiende.
```

---

## 6. Scoring de priorización: RICE y WSJF

*Cuándo:* para ordenar el backlog con un método explícito y trazable. Detalle y
elección de método en [priorizacion-valor.md](priorizacion-valor.md).

### RICE (Reach · Impact · Confidence · Effort)

```
| Ítem | Reach (alcance/periodo) | Impact (3/2/1/0.5/0.25) | Confidence (100/80/50%) | Effort (persona-mes) | RICE = R×I×C/E | Orden |
|------|-------------------------|--------------------------|--------------------------|--------------------|----------------|-------|
|      |                         |                          |                          |                    |                |       |
```

### WSJF (Weighted Shortest Job First — SAFe)

```
Cost of Delay (CoD) = Valor de negocio + Urgencia (time criticality) + Reducción de riesgo/oportunidad
WSJF = CoD / Tamaño del job (job size)

| Ítem | Valor negocio | Urgencia | Riesgo/oport. | CoD | Job size | WSJF | Orden |
|------|---------------|----------|---------------|-----|----------|------|-------|
|      |               |          |               |     |          |      |       |
```

> Usa escala relativa (Fibonacci modificada `1, 2, 3, 5, 8, 13, 20`). El **job size** lo aporta
> el equipo; tompo prioriza con esa información, no la impone.

---

## 7. Roadmap now-next-later (orientado a outcomes)

*Cuándo:* para comunicar dirección sin convertir el roadmap en una lista de fechas-promesa.
Detalle en [estrategia-vision.md](estrategia-vision.md).

```
| NOW (en curso) | NEXT (próximo) | LATER (explorando) |
|----------------|----------------|--------------------|
| Outcome: ...   | Outcome: ...   | Outcome: ...       |
| Métrica: ...   | Métrica: ...   | Apuesta/hipótesis  |
| Confianza: alta| Confianza: media| Confianza: baja   |
```

Regla: cada columna lista **outcomes/problemas**, no features comprometidas con fecha.

---

## 8. OKR y árbol North Star

*Cuándo:* para fijar objetivos medibles del periodo y conectar el trabajo diario con la
métrica clave. Detalle en [metricas-datos.md](metricas-datos.md) (significado de negocio
= tompo; implementación técnica de la métrica = **brujula**, RACI #9/#10).

```
OBJETIVO (cualitativo, inspirador): ...
  KR1 (medible): de <línea base> a <objetivo> antes de <fecha>.
  KR2 (medible): ...
  KR3 (medible): ...
  (KR = resultado, no tarea; 3-5 por objetivo)
```

```
NORTH STAR METRIC: ...........................   (valor que el usuario recibe)
   ├─ Input 1 (palanca accionable): ...
   ├─ Input 2: ...
   └─ Input 3: ...
GUARDRAILS (no romper): retención, latencia, churn, coste, calidad, NPS, fraude...
```

---

## 9. Business case / one-pager de producto

*Cuándo:* para justificar una inversión ante negocio/stakeholders en una página.
Detalle en [priorizacion-valor.md](priorizacion-valor.md) y
[stakeholders-liderazgo.md](stakeholders-liderazgo.md).

```
Título / iniciativa:
Problema (para quién y por qué importa ahora):
Outcome buscado (resultado de negocio/usuario + métrica objetivo):
Evidencia (datos, research, soporte — no opinión):
Alcance (in / out) y MVP propuesto:
Riesgos (valor/usabilidad/factibilidad/viabilidad) y mitigación:
Coste/esfuerzo estimado (input del equipo) y dependencias:
Métrica de éxito y cómo se medirá:
Decisión solicitada (go / no-go / explorar):
```

---

## 10. PRD ligero / spec de feature

*Cuándo:* para alinear al equipo en una feature antes de construir, sin sobre-documentar.
Detalle en [backlog-requisitos.md](backlog-requisitos.md).

```
Feature:
Problema y outcome (link al Product Goal y al OST):
Usuarios y JTBD:
Solución propuesta (qué, no cómo) y alcance / fuera de alcance:
Historias y criterios de aceptación (ver §4):
Métricas de éxito + guardrails (cómo sabremos que funcionó):
Requisitos de cumplimiento/seguridad (privacidad, WCAG, IA responsable) — con sello:
Dependencias de equipo:
   - uxuifull (research/diseño/usabilidad):
   - eneida (arquitectura/factibilidad):
   - motor / farola (back/front):
   - amado (criterios testeables, DoD, gates):
   - andulfo/caudal/brujula/prisma (datos/métricas técnicas):
   - sysuniversal-ai (IA) / destroyer/cazador/centinela/sello/vector (seguridad/cumplimiento):
Riesgos y supuestos abiertos:
Plan de medición y de release:
```

---

## 11. Experiment card / assumption test

*Cuándo:* para derribar el supuesto más riesgoso **antes** de construir (uno de los 4
riesgos). Detalle en [descubrimiento.md](descubrimiento.md).

```
Supuesto más riesgoso (¿qué creemos y qué pasa si es falso?):
Tipo de riesgo: valor / usabilidad / factibilidad / viabilidad
Hipótesis: Creemos que <acción/cambio> para <usuario> producirá <resultado medible>.
Prueba mínima (la más barata/rápida que da señal): ...
Métrica observada: ...
Criterio de éxito (umbral pre-acordado): si <métrica> ≥/≤ <valor>, validamos; si no, pivotamos.
Duración / tamaño de muestra:
Resultado y decisión (persevera / pivota / mata):
```

---

## 12. Mapa de stakeholders + plan de comunicación

*Cuándo:* para gestionar expectativas e influir sin autoridad. Detalle en
[stakeholders-liderazgo.md](stakeholders-liderazgo.md).

```
| Stakeholder | Poder (A/B) | Interés (A/B) | Postura | Estrategia | Qué necesita saber | Canal/frecuencia | Owner |
|-------------|-------------|---------------|---------|------------|--------------------|------------------|-------|
|             |             |               |         |            |                    |                  |       |

Cuadrante poder/interés:
  Alto poder + alto interés  → GESTIONAR DE CERCA (co-decidir, 1:1)
  Alto poder + bajo interés  → MANTENER SATISFECHO (resumen ejecutivo)
  Bajo poder + alto interés  → MANTENER INFORMADO (demos, release notes)
  Bajo poder + bajo interés  → MONITOREAR (mínimo esfuerzo)
```

---

## 13. Plantilla de release

*Cuándo:* para decidir el go/no-go de valor de un release. tompo es A del **valor**;
el **gate de calidad es de amado** y el **gate de seguridad/cumplimiento de destroyer/sello**
(RACI #12). Checklist en [checklists.md](checklists.md).

```
Release / versión:
Outcome buscado y métricas de éxito (+ guardrails):
Alcance (historias incluidas / excluidas):
Estrategia de entrega (feature flag, canary, % rollout):
Gates obligatorios:
   - [ ] Calidad (DoD, regresión, no funcional) — veredicto de amado:
   - [ ] Seguridad — sign-off de destroyer:
   - [ ] Cumplimiento/privacidad — sign-off de sello (si aplica):
   - [ ] IA (evals/safety) — sysuniversal-ai + vector (si aplica):
Plan de medición post-release (qué métrica, cuándo se lee):
Plan de rollback / kill-switch (definido por el equipo; tompo decide el trigger de negocio):
Comunicación a stakeholders (ver §12):
Decisión go/no-go de valor (tompo) + fecha:
```

---

## 14. Sprint Goal (objetivo de sprint)

*Cuándo:* al planificar el sprint, para dar un **único** foco al incremento —un
resultado medible y alineado al Product Goal—, no una lista de tareas. Detalle en
[estrategia-vision.md](estrategia-vision.md) y [frameworks-marcos.md](frameworks-marcos.md).

```
Sprint Goal: Lograr <resultado único y medible> que acerca al <Product Goal>,
de modo que <valor para usuario/negocio>.
Cómo se medirá: <métrica / condición observable al cierre del sprint>.
Próximo paso: ...
```

---

## 15. Mapa de dependencias

*Cuándo:* para **mapear y secuenciar** dependencias entre ítems/equipos y comunicar
bloqueos (tompo mapea y comunica; el equipo implementa). Detalle en
[frameworks-marcos.md](frameworks-marcos.md).

```
| Ítem | Depende de | Tipo (técnica/datos/equipo/externa) | Impacto si no se resuelve | Owner del bloqueo |
|------|------------|-------------------------------------|---------------------------|-------------------|
|      |            |                                     |                           |                   |
```

---

> Más casos aplicados en [ejemplos.md](ejemplos.md); checklists accionables en
> [checklists.md](checklists.md); el rol del PO por marco en
> [frameworks-marcos.md](frameworks-marcos.md) y por dominio en [dominios.md](dominios.md).
