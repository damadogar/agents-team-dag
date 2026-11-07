# Evidencia y epistemología

## 1. Vocabulario obligatorio

| Etiqueta | Significado | Ejemplo |
|---|---|---|
| **Observación** | Hecho leído del artefacto/runtime | “En `0x140012300` hay un `call` a `WinHttpSendRequest`” |
| **Inferencia** | Conclusión razonada no leída literalmente | “Probable cliente HTTP de telemetría (por imports + strings)” |
| **Desconocido** | No cubierto o no determinable | “No se observó el cuerpo de la request (sin runtime)” |

Nunca mezcles las tres en la misma frase sin etiquetar.

## 2. Ledger de hallazgos (mínimo)

```markdown
| ID | Pregunta | Conclusión | Tipo | Evidencia | Cobertura | Confianza |
|---|---|---|---|---|---|---|
| H1 | ¿Cómo autentica? | Bearer en header Authorization | obs | EID … / string @ … | estático strings+xrefs | alta |
| H2 | ¿Cifra el body? | Posible AES (API surface) | inf | imports bcrypt + const | sin traza de claves | media |
| H3 | ¿Cert pinning? | No determinado | unk | — | sin runtime TLS | — |
```

## 3. Confianza

- **Alta:** observación directa + locus + sin contradicción
- **Media:** inferencia bien apoyada; faltan eslabones
- **Baja:** indicios débiles; presentar como hipótesis

“Seguro” sin evidencia = **falta profesional**.

## 4. Evidence IDs (cuando hay MCP REA)

- Cita `evidence_id` / `parent_evidence_id` en el ledger.
- Prefiere referencias retained a re-volcar blobs enormes.
- Summary ≠ record completo: no parses un preview truncado como canónico.
- Exporta bundle antes de cerrar sesión si debe sobrevivir el proceso.

Detalle: [references/evidence-workflows.md](references/evidence-workflows.md).

## 5. Cobertura y ausencia

“No aparece X” solo es válido si defines:

- Qué espacio se buscó (sección, módulo, inventory page)
- Si el inventory estaba completo o paginado
- Si el packing/ofuscación pudo ocultarlo

Si la cobertura es parcial → **desconocido**, no “ausente”.

## 6. Estático vs dinámico

| Afirmación | Requiere |
|---|---|
| “La función llama a Y” | Estático (xref/call) |
| “En runtime envía Z” | Observación de ejecución / captura |
| “El usuario ve W” | UI/runtime o recurso + flujo demostrado |

## 7. Contradicciones

Si dos evidencias chocan: regístralas, no elijas la más cómoda. Escalona con
más datos o deja el conflicto explícito.
