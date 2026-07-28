# plantillas.md — Plantillas reusables de documentación

> Plantillas listas para producir a estándar. Adáptalas a la audiencia, al tipo
> Diátaxis y al usage guide del proyecto. Cada documento debe declarar **audiencia**,
> **source of truth / dueño** y **cómo se mantiene**.

---

## 0. Brief de intake (modo A — antes de escribir nada)

```
DOCUMENTO A PRODUCIR: ...
Objetivo real (qué logrará el lector con menos fricción): ...
Audiencia primaria / secundaria: ...
Tipo (tutorial / how-to / referencia / explicación / runbook / ADR / …): ...
Criticidad y riesgo si falla o está errada: ...
SME / fuente de verdad: ...
Estado del sistema: greenfield / in-flight / brownfield
Dónde vivirá (repo, sitio, wiki) y source of truth: ...
Idiomas / accesibilidad / regulación aplicable: ...
[SUPUESTOS] / [PENDIENTES]: ...
Definición de "listo" para este documento: ...
```

---

## 1. README

```markdown
# <Nombre> — <una frase de qué es y para quién>

<Problema que resuelve / valor, 1-2 frases.>

## Requisitos
- <prerequisito>, <versión>, <permiso>

## Quickstart
```<lang>
<comandos mínimos para correrlo>
```
Deberías ver: <resultado verificable>.

## Uso básico
<ejemplo real con petición y resultado>

## Documentación
- [Guía de uso](#) · [Referencia](#) · [Contribuir](CONTRIBUTING.md)

## Soporte y licencia
<cómo pedir ayuda> · <licencia>
```

---

## 2. ADR (Architecture Decision Record)

```markdown
# ADR-<NNN>: <título de la decisión>
- Estado: propuesta | aceptada | reemplazada por ADR-<NNN> | deprecada
- Fecha: <YYYY-MM-DD>  ·  Decisor(es): <SME, p. ej. eneida>

## Contexto
<Qué problema/fuerzas motivan la decisión.>

## Decisión
<Qué se decidió, en voz activa.>

## Alternativas consideradas
- <A> — por qué no.  · <B> — por qué no.

## Consecuencias
- Positivas: <...>
- Negativas / costos: <...>
- Impacto en <seguridad / operación / migración>: <...>
```
> El **contenido** de la decisión es del SME (eneida); docpower asegura estructura y calidad.

---

## 3. RFC

```markdown
# RFC-<NNN>: <título>  ·  Estado: draft | en revisión (hasta <fecha>) | decidido (→ ADR-<NNN>)
## Problema  ·  ## Propuesta  ·  ## Alternativas  ·  ## Impacto y riesgos
## Plan / fases  ·  ## Preguntas abiertas  ·  ## Interesados (revisores)
```

---

## 4. Runbook

```markdown
# Runbook: <tarea / incidente>
- Cuándo usar: <síntoma / disparador>  ·  Dueño: <equipo/SME>  ·  Criticidad: <...>

## Prerequisitos y permisos
## Prechecks (verifica antes de tocar nada)
## Procedimiento
1. <paso atómico verificable> → resultado esperado: <...>
> ⚠️ Advertencia antes de un paso destructivo/irreversible.
2. ...
## Punto de rollback
## Verificación (cómo confirmar éxito)
## Si falla → Escalamiento
```

---

## 5. SOP (procedimiento estándar / regulado)

```markdown
# SOP-<ID>: <título>  ·  Versión: <x> · Estado: <vigente> · Aprobó: <rol> (<fecha>)
## Propósito  ·  ## Alcance  ·  ## Roles y responsables
## Procedimiento (pasos numerados)
## Registros que genera (evidencia)  ·  ## Referencias normativas
## Control de cambios (versión | fecha | cambio | autor | aprobador)
```
> Substancia/validez normativa: sello/legal. Forma/control: docpower.

---

## 6. Referencia de endpoint de API

```markdown
### <METHOD> /<ruta>
<Una línea: qué hace.>
**Auth:** <método/scope>  ·  **Rate limit:** <...>  ·  **Idempotente:** sí/no

**Parámetros**
| Nombre | En | Tipo | Requerido | Default | Descripción |
|---|---|---|---|---|---|

**Petición**
```bash
curl ...
```
**Respuesta 200**
```json
{ ... }
```
**Errores**
| Código | Significado | Cómo resolver |
|---|---|---|
```

---

## 7. Quickstart / Tutorial (esqueleto)

```markdown
# <Lograr X> en <N> minutos
Al terminar, <resultado tangible>.
## Antes de empezar (prerequisitos)
## Pasos
1. <verbo + acción> → <resultado esperado>
## Verifica que funcionó
## Siguiente paso  →  [Referencia](#) · [Conceptos](#)
```

---

## 8. Release notes / changelog

```markdown
## [<versión>] - <YYYY-MM-DD>
### Added / Changed / Deprecated / Removed / Fixed / Security
- <cambio> (#PR)
### ⚠️ Breaking changes
- <qué rompe> → **Guía de migración:** <pasos>
```

---

## 9. Troubleshooting

```markdown
## Síntoma: <lo que ve el usuario, p. ej. "Error 403 al llamar X">
- Causa probable: <...>
- Verifica: <cómo confirmar la causa>
- Solución: <pasos>
- Prevenir: <...>
```

---

## 10. Usage guide (estándar editorial ligero — 1 página)

```markdown
# Usage guide de documentación
- Voz: activa, segunda persona, presente/imperativo.
- Términos: <preferido> (no <deprecado>); acrónimos expandidos al primer uso.
- Nombres de producto: <capitalización oficial>.
- Código: <formato>, ejemplos verificables, sin secretos reales.
- Enlaces: texto significativo (nunca "aquí").
- Callouts: Nota / Importante / Advertencia (jerarquía de riesgo).
- Accesibilidad: alt text obligatorio; sin significado solo-en-imagen.
- Automatización: reglas en .vale.ini / .markdownlint.json.
```

---

## 11. Content inventory / auditoría

```markdown
| URL/Doc | Tipo | Dueño (SME) | Estado | Últ. revisión | Tráfico | Veraz? | Encontrable? | Accesible? | Acción |
|---|---|---|---|---|---|---|---|---|---|
```
Acción ∈ {mantener, actualizar, fusionar, reescribir, deprecar}. Prioriza por **riesgo × uso**.

---

## 12. Model card (documentar un sistema de IA)

```markdown
# Model card: <nombre>
## Propósito y uso previsto  ·  ## Fuera de alcance (no usar para…)
## Datos (origen, a alto nivel)  ·  ## Limitaciones y sesgos conocidos
## Métricas y evaluación  ·  ## Consideraciones éticas / de seguridad
## Versión y contacto (SME)
```
> Contenido/evals: sysuniversal-ai. Seguridad IA: vector. Forma: docpower.

---

## 13. Plan de auditoría / remediación documental

```markdown
# Auditoría documental — <área> (<fecha>)
## Alcance y método  ·  ## Nivel de madurez actual (por dimensión)
## Hallazgos priorizados (riesgo × uso)
| # | Hallazgo | Impacto | Acción | Dueño | Fecha |
## Roadmap de remediación (quick wins → estructural)
```

> Checklists de calidad para usar con estas plantillas: [checklists.md](checklists.md).
