# Metodología de ingeniería inversa — nivel élite

## 1. Mental model

Un artefacto es un **sistema de hechos parciales**. Tu trabajo es:

1. Fijar identidad (bytes, formato, arch).
2. Plantear preguntas falsables.
3. Recoger la evidencia mínima suficiente.
4. Separar lo demostrado de lo plausible.
5. Cerrar o declarar residuales.

## 2. Ciclo de hipótesis

```
Pregunta → Predicción observable → Recoger evidencia →
  Confirma / Refuta / Insuficiente → Actualizar ledger → Siguiente gap
```

Anti-patrón: “explorar el binario entero” sin pregunta. Eso satura contexto y
produce narrativa débil.

## 3. Capas de análisis (de barato a caro)

1. **Identidad / packaging** — magic, digests, firma, packer overlays
2. **Inventario** — exports, imports, sections, resources, modules
3. **Strings / API surface** — con locus; strings sin xref son pistas, no prueba
4. **Grafo / entry points** — quién llama a quién
5. **Decompilación focal** — solo funciones del camino crítico
6. **Runtime** — último recurso cuando el estático no puede responder

## 4. Calidad de una conclusión

Una conclusión **publicable** tiene:

- Pregunta que responde
- Tipo: observación | inferencia | desconocido
- Locus (VA/RVA, archivo:offset, Evidence ID, stack frame…)
- Cobertura (qué se miró / qué no)
- Confianza calibrada (alta solo con evidencia directa)

## 5. Anti-patrones (prohibidos en tu trabajo)

| Anti-patrón | Por qué falla |
|---|---|
| Narrativa sin locus | Irreproducible |
| Confundir packing con “está cifrado todo” | Pierde superficie útil |
| Tratar decompilación como fuente | Errores de Hex-Rays/Ghidra son reales |
| Runtime sin autoridad | Línea roja |
| Repetir el mismo call MCP | Ruido; cambia input o repara bloqueo |
| Elegir target de ejemplo por el usuario | Contamina la investigación |
| Declara “API ausente” sin cobertura completa | Falso negativo |

## 6. Comparaciones

Para afirmar equivalencia o “ya no está”:

- Mismos tipos de evidencia a ambos lados
- Digests y versiones explícitos
- Ausencia solo dentro de un **search boundary** declarado

## 7. Reconstrucción limpia (cuando la piden)

1. Extrae **comportamiento observable** (I/O, estados, invariantes).
2. Descarta detalles cosméticos / marcas / assets protegidos.
3. Propón **diseño propio** que cumpla el comportamiento.
4. Etiqueta qué parte es observación vs decisión de diseño.
5. Implementa con herramientas normales de código — no pegues IP ajena.

## 8. Degradación con gracia (sin MCP)

Orden de fallback:

1. CLI `rea-agents` / `rea` si existe
2. Export manual del motor (Ghidra script, IDA txt, Hopper)
3. `file` / `die` / `pefile` / `readelf` / `otool` / `strings` / `objdump`
4. Hexdump + parsing de headers documentados
5. Declarar qué preguntas **no** se pueden cerrar sin motor profundo
