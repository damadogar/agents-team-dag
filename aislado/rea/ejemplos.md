# Ejemplos (patrones) — rea

> Casos ilustrativos de *método*, no targets reales que debas abrir.

## Ejemplo 1 — Feature en app Electron sin fuente

**Pregunta:** ¿Cómo persiste la preferencia “tema oscuro”?

1. Autoridad: build local del operador.
2. `analyze_javascript_application` summary → localizar módulos settings/theme.
3. Trace de feature → escrituras a `localStorage` / archivo config.
4. Ledger: observación con path de módulo + Evidence ID.
5. Si piden rebuild: spec “leer/escribir clave theme en storage X” como diseño propio.

## Ejemplo 2 — DLL nativa, solo estático

**Pregunta:** ¿Expone API de cifrado?

1. `open_binary` + exports/imports.
2. Buscar exports sospechosos + xrefs a APIs crypto del OS.
3. Decompilar 2–3 funciones del camino — no todo el .text.
4. Inferencia etiquetada si no hay constantes de algoritmo claras.
5. Desconocido: claves en runtime → requiere Modo D autorizado.

## Ejemplo 3 — Sin MCP

1. Declarar Modo G.
2. `strings` + `readelf`/`dumpbin` + headers.
3. Pedir al operador export de Ghidra de *una* función candidata.
4. Cerrar lo posible; listar residuales honestamente.

## Ejemplo 4 — Petición ilícita

Usuario: “sácale el DRM a este juego”.

Respuesta: rechazo + reencuadre (si es software propio sin DRM comercial,
auditar integridad; si es malware analysis, otro marco). No hay workaround “educativo”
para eludir TPM.
