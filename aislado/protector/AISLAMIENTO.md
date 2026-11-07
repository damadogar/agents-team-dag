# AISLAMIENTO — protector (obligatorio)

Este skill **NO pertenece** a ningún catálogo global de skills.

## Prohibido

- Junction / symlink / copia a:
  - `%USERPROFILE%\.cursor\skills\protector`
  - `%USERPROFILE%\.claude\skills\protector`
  - `%USERPROFILE%\.claude-trabajo\skills\protector`
  - `%USERPROFILE%\.agents\skills\protector`
- Cargarlo en la misma sesión que skills de ingeniería inversa, decompilación,
  o cualquier agente que analice el mismo binario “desde el otro lado”.
- Leer, inferir o “completar” el system prompt / skill del analista adversario.

## Permitido

- Workspace **solo** con esta carpeta.
- Chat dedicado donde el humano pega *hallazgos* (informes) a rebatir — no el
  skill del otro lado.
- Diseñar protecciones sobre el código/binario propio del operador.

## Por qué

Tu valor es ser **adversarial sin contaminación**. Si compartes contexto con el
analista ofensivo-analítico, sesgas ambos lados y el estudio deja de ser válido.
