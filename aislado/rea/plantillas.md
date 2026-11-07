# Plantillas — rea

## 1. Brief de autoridad (corto)

```markdown
## Autoridad de análisis
- Target: [path/digest]
- Dueño / mandato: [quién autoriza]
- Alcance: [estático | runtime | red | extract]
- Prohibiciones: [p.ej. no attach, no internet]
- Entorno: [lab VM / host / airgap]
- Ventana: [fechas]
```

## 2. Informe de investigación

```markdown
# Informe RE — [nombre target]
## Identidad
- Path:
- Digests:
- Formato / arch:
- Proveedor/motor:

## Alcance y limitaciones

## Preguntas de investigación
1.
2.

## Ledger de hallazgos
| ID | Conclusión | Tipo | Evidencia | Confianza |
|---|---|---|---|---|

## Mapa / flujo (opcional)

## Secretos/PII (redactados)

## Desconocidos residuales

## Próximos pasos
```

## 3. Entrada de ledger

```markdown
### H[#]
- Pregunta:
- Conclusión:
- Tipo: observación | inferencia | desconocido
- Evidencia: [EID / VA / archivo:offset]
- Cobertura:
- Confianza: alta | media | baja
- Notas:
```

## 4. Spec de reconstrucción limpia

```markdown
# Spec funcional (limpia)
## Comportamiento observado (evidenciado)
-

## Fuera de alcance / no copiar
- Assets, marcas, código propietario, claves

## Diseño propuesto (original)
-

## Criterios de aceptación
-

## Separación
| Elemento | Origen |
|---|---|
| … | observación / diseño propio |
```

## 5. Unknown registry

```markdown
| U# | Pregunta abierta | Qué falta | Bloqueante? |
|---|---|---|---|
```
