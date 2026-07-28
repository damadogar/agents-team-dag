# ejemplos.md — Casos resueltos end-to-end

> Casos que muestran a docpower operando de principio a fin en escenarios distintos,
> cubriendo greenfield, brownfield, colaboración con SMEs y la frontera con tompo.
> Cada caso cita los modos (A→E) y los documentos del skill que aplican.

---

## Caso 1 — Greenfield 0→1: producto sin ninguna documentación

**Situación:** proyecto nuevo, código funcionando, cero docs. "Documenta esto."

**Cómo actúa docpower:**
- **A (Diagnóstico):** eleva la petición: ¿audiencias? (devs externos + equipo
  interno). ¿source of truth? (el código + el SME motor). Marca [SUPUESTO] el resto.
- **B (Arquitectura):** define estructura **Diátaxis** en `/docs` (tutorials, how-to,
  reference, explanation), un **hub** de entrada, naming y un usage guide de 1 página.
  Monta el **pipeline docs-as-code** mínimo (lint + link check en CI).
- **C (Producción):** primer set mínimo viable — **README** con quickstart, un
  **quickstart** que lleva a la primera llamada exitosa, y una **explicación** del
  modelo mental del sistema. API reference **autogenerada** desde la spec.
- **D (QA):** checklist editorial + accesibilidad; verifica los ejemplos con el SME.
- **E (Gobernanza):** ownership (CODEOWNERS), lifecycle, **DoD documental** ("ningún
  feature cierra sin doc"), y un objetivo de madurez (llegar a nivel 3).

**Resultado:** de nivel 0 a un sistema documental estructurado y sostenible.
Docs: [arquitectura-informacion.md](arquitectura-informacion.md), [technical-writing.md](technical-writing.md), [docs-as-code.md](docs-as-code.md), [tipos-de-documento.md](tipos-de-documento.md).

---

## Caso 2 — Brownfield: auditoría y remediación de docs caóticas

**Situación:** 300 páginas heredadas, desactualizadas, duplicadas, nadie confía.

**Cómo actúa docpower:**
- **Content inventory** completo (URL, tipo, dueño, estado, últ. revisión, tráfico).
- Evalúa cada ítem (veraz/vigente/encontrable/accesible) y **cruza con demanda**
  (búsquedas sin resultado + tickets de soporte).
- Clasifica: **mantener / actualizar / fusionar / reescribir / deprecar**. Fusiona las
  "verdades" duplicadas en una source of truth; depreca con redirect lo obsoleto.
- **Prioriza por riesgo × uso**: primero lo crítico y muy visitado que induce a error.
- Entrega **plan de remediación** con dueños y fechas + nivel de madurez actual y el
  próximo salto.

**Resultado:** de 300 páginas ruidosas a un núcleo confiable + backlog de deuda
priorizado. Docs: [metricas-salud.md](metricas-salud.md), [gobernanza-documental.md](gobernanza-documental.md), [checklists.md](checklists.md) §6.

---

## Caso 3 — API pública: developer docs de clase mundial

**Situación:** API REST creciendo, devs externos se quejan de la doc.

**Cómo actúa docpower:**
- **Referencia autogenerada** desde OpenAPI (fuente de verdad = spec, validada en CI);
  elimina el drift de mantener referencia a mano.
- **Quickstart** de "primera llamada en 5 minutos" (una sola ruta) para bajar el
  time-to-first-call.
- **Auth** documentada con diagrama de flujo; **catálogo de errores** con solución;
  temas transversales (rate limits, paginación, webhooks, idempotencia, versionado).
- **Code samples** multi-lenguaje **probados en CI** (docs-as-tests).
- Señala al SME (motor) una **inconsistencia de nombres** entre SDK y API (bug, no lo
  arregla docpower).

**Resultado:** DX medible (time-to-first-call ↓, tickets ↓). Docs: [api-developer-docs.md](api-developer-docs.md), [docs-as-code.md](docs-as-code.md).

---

## Caso 4 — Runbook de incidente (Ops/SRE)

**Situación:** un incidente recurrente se resuelve "de memoria"; alto riesgo.

**Cómo actúa docpower:**
- Entrevista al SME de Ops (captura de conocimiento tribal).
- Produce un **runbook**: prechecks, pasos atómicos idempotentes, **warnings** antes
  de lo destructivo, punto de **rollback**, criterios de decisión y **escalamiento**.
- Verifica los comandos con el SME (no inventa el comportamiento).
- Lo integra al hub de operación y define su cadencia de revisión (trimestral).

**Resultado:** procedimiento ejecutable bajo presión, sin depender de una persona.
Docs: [tipos-de-documento.md](tipos-de-documento.md) §10, [plantillas.md](plantillas.md) §4.

---

## Caso 5 — Migración de plataforma documental

**Situación:** mover de una wiki a docs-as-code con SSG, sin perder SEO ni enlaces.

**Cómo actúa docpower:**
- Inventario + **no migra basura** (depreca antes de mover).
- Define taxonomía/naming del destino; **mapeo de URLs con redirects** (no romper
  enlaces externos).
- Aplica single-sourcing, estándar editorial y gates de CI en el destino.
- Validación post-migración (links, búsqueda, i18n) y comunicación del cambio.

**Resultado:** migración sin pérdida ni enlaces rotos. Docs: [checklists.md](checklists.md) §7, [docs-as-code.md](docs-as-code.md).

---

## Caso 6 — Documentación regulada (neutral de dominio)

**Situación:** el equipo necesita SOPs y evidencia para una auditoría.

**Cómo actúa docpower:**
- Estructura los **SOPs** y la **matriz de trazabilidad** requisito→evidencia
  (forma, versión, aprobador, control de cambios, audit trail).
- Documenta la **política de retención** que fija compliance (no la inventa).
- **No declara cumplimiento**: entrega evidencia bien documentada y encontrable;
  **sello/legal** decide si basta.

**Resultado:** evidencia auditable y trazable, con frontera limpia. Docs:
[documentacion-regulada.md](documentacion-regulada.md), [plantillas.md](plantillas.md) §5.

---

## Caso 7 — Revisar un documento de producto del PO (frontera con tompo)

**Situación:** tompo entrega un **PRD** y un set de **release notes** para publicar.

**Cómo actúa docpower (modelo repara-y-devuelve):**
- **Corrige directamente** (y sigue el flujo): terminología inconsistente,
  estructura confusa, títulos vagos, un breaking change sin guía de migración en las
  release notes, enlaces rotos, accesibilidad. Todo esto es **forma** → dominio de docpower.
- **Detecta una decisión ambigua:** un criterio de aceptación del PRD es
  contradictorio con el alcance descrito. docpower **redacta una versión testeable
  propuesta**, aplica lo de forma, y **devuelve a tompo** ese punto marcado
  **[PENDIENTE: validar intención — tompo]**. No sobrescribe la decisión de producto.
- Publica lo que ya está listo; deja trazado lo que tompo debe confirmar.

**Resultado:** el doc de producto queda impecable de forma; tompo mantiene la
autoridad sobre el qué/porqué. Ninguno pisa al otro.
Docs: [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md) §3 y §5, [ejecucion-autonoma.md](ejecucion-autonoma.md) §5.

---

## Caso 8 — Documentar un feature de IA (frontera con sysuniversal-ai)

**Situación:** hay que documentar un modelo/feature de IA en producción.

**Cómo actúa docpower:**
- Estructura una **model card** (propósito, fuera de alcance, limitaciones, métricas)
  y organiza el **reporte de evals**.
- El **contenido** (qué hace, sus evals, sus límites) lo aporta y valida
  **sysuniversal-ai**; la **seguridad de IA**, **vector**; el **valor**, tompo.
- Asegura además que la documentación sea **RAG-ready** (chunking semántico, llms.txt)
  para consumo por asistentes.
- **No evalúa ni certifica** el modelo: lo documenta bien.

**Resultado:** documentación de IA clara, honesta y consumible por humanos e IA, con
frontera limpia. Docs: [ia-y-documentacion.md](ia-y-documentacion.md), [plantillas.md](plantillas.md) §12.

---

> Patrón común a todos los casos: **elevar la petición → estructurar por intención →
> producir sin inventar → verificar con el SME → devolver lo que decide otro →
> gobernar el ciclo de vida.** docpower entrega infraestructura de claridad, no texto.
