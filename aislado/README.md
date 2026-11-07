# Aislado — par adversarial `rea` ↔ `protector`

Carpeta **fuera del catálogo global** del DAG TEAM. Aquí viven dos skills elite
que **no se conocen entre sí** y **no deben** sincronizarse a
`~\.cursor\skills`, `~\.claude\skills`, etc.

| Skill | Rol |
|---|---|
| [`rea/`](rea/) | Maestro Universal de Ingeniería Inversa (análisis con evidencia; puente a Ghidra/IDA/Hopper vía MCP/CLI tipo REA) |
| [`protector/`](protector/) | Maestro Universal de Protección ante Ingeniería Inversa + árbitro adversarial de hallazgos |

## Por qué aislados

Si viven en global, sesgan cualquier chat del equipo. Si comparten sesión,
contaminan el estudio adversarial (el mentor lo pidió explícito: *no se
conozcan*, *no en global*).

## Cómo invocarlos (Cursor / Claude / cualquier LLM)

### Sesión A — solo `rea`

1. Abre como workspace: `C:\DAG\Agents Team - DAG\aislado\rea`
2. O adjunta / pega `rea\SKILL.md` en un chat vacío.
3. (Opcional) MCP REA en esa máquina: `npx rea-agents setup` — lo aprueba el humano.
4. Analiza el target autorizado. Exporta informe.

### Sesión B — solo `protector`

1. Abre workspace: `C:\DAG\Agents Team - DAG\aislado\protector` (otra ventana).
2. Pega el **informe** de la sesión A (hallazgos), **nunca** el `SKILL.md` de `rea`.
3. Protector rebate claims y propone protecciones sobre assets propios.

Tú eres el puente. Ellos no se invocan mutuamente.

## Prohibido

- `sincronizar.ps1` hacia skills globales
- Cargar ambos skills en el mismo system prompt
- Meterlos en `agentes/` del DAG TEAM como si fueran el agente nº 23/24

## Nivel

Diseñados al estándar (o superior) de skills enterprise del repo: identidad,
línea roja, modos, plantillas, checklists, epistemología de evidencia /
adversarial review. Portables a cualquier LLM que cargue `SKILL.md`.
