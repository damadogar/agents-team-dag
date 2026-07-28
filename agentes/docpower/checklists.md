# checklists.md — Checklists de calidad documental

> Listas de verificación accionables para cada fase. Úsalas en el modo D (QA) y
> antes de publicar. Complementan el checklist de cierre del `SKILL.md` §12.

---

## 1. QA editorial (antes de dar por hecho un documento)

```
- [ ] ¿Parte de la necesidad del lector y de una audiencia específica?
- [ ] ¿Es del tipo correcto (concepto/tarea/referencia/troubleshooting — Diátaxis)?
- [ ] ¿Los títulos son descriptivos y precisos (no "Información", "Detalles")?
- [ ] ¿Voz activa, frases cortas, plain language, sin relleno?
- [ ] ¿Terminología consistente (un término, un significado)?
- [ ] ¿Acrónimos expandidos al primer uso?
- [ ] ¿Escaneable (headings, listas, tablas, negrita con criterio)?
- [ ] ¿Los pasos están completos, numerados y empiezan por verbo?
- [ ] ¿Hay resultado esperado y verificación donde hay procedimiento?
- [ ] ¿Warnings antes del riesgo; prerequisitos y supuestos explícitos?
- [ ] ¿Ejemplos correctos y copiables (idealmente verificados)?
- [ ] ¿Enlaces con texto significativo y sin romper?
- [ ] ¿Sin duplicación (enlaza la source of truth)?
```

---

## 2. Verificación de contenido (no inventar hechos)

```
- [ ] ¿Cada hecho técnico está verificado con el SME o la fuente?
- [ ] ¿Lo no verificado está marcado [PENDIENTE], no inventado?
- [ ] ¿Separé hecho de inferencia ([SUPUESTO] donde asumo)?
- [ ] ¿Devolví al dueño lo que es decisión suya (repara-y-devuelve)?
- [ ] ¿Salida de IA verificada por humano antes de publicar?
```

---

## 3. Accesibilidad (WCAG en docs)

```
- [ ] ¿Un solo H1 y jerarquía de headings sin saltos?
- [ ] ¿Toda imagen con significado tiene alt text; decorativas con alt vacío?
- [ ] ¿Ningún significado crítico vive solo en una imagen?
- [ ] ¿Texto de enlace significativo (no "aquí")?
- [ ] ¿Información no transmitida solo por color?
- [ ] ¿Tablas con encabezados reales; código como texto, no imagen?
- [ ] ¿Lenguaje claro e inclusivo; media con transcripción/subtítulos?
```

---

## 4. Localización-readiness (source-for-translation)

```
- [ ] ¿Frases cortas, voz activa, sin modismos ni referencias culturales?
- [ ] ¿Terminología consistente (favorece translation memory)?
- [ ] ¿Sin texto incrustado en imágenes?
- [ ] ¿Formatos de fecha/número/moneda localizables, no hardcodeados?
- [ ] ¿Glosario/termbase con términos que no se traducen?
- [ ] ¿Estructura preparada para expansión de texto y RTL si aplica?
- [ ] ¿Se marca el desfase entre origen y cada idioma?
```

---

## 5. Publish-readiness / DoD documental

```
- [ ] ¿Pasa QA editorial (checklist 1) y accesibilidad (checklist 3)?
- [ ] ¿Contenido verificado por el SME (sign-off)?
- [ ] ¿Tiene dueño, estado de lifecycle y fecha de próxima revisión?
- [ ] ¿Vive en la source of truth y es descubrible (hub/enlaces/metadata)?
- [ ] ¿Pasa los gates de CI (lint, links, spelling, schema, ejemplos)?
- [ ] Si es regulado: ¿versión, aprobador y control de cambios? ¿sign-off grc?
- [ ] ¿El cambio de producto/API asociado no cierra sin esta doc?
```

---

## 6. Auditoría de documentación (brownfield)

```
- [ ] ¿Inventario completo (URL, tipo, dueño, estado, últ. revisión, tráfico)?
- [ ] ¿Cada ítem evaluado: veraz, vigente, encontrable, accesible, tipo correcto?
- [ ] ¿Cruzado con demanda real (tráfico, búsquedas sin resultado, tickets)?
- [ ] ¿Clasificada la acción (mantener/actualizar/fusionar/reescribir/deprecar)?
- [ ] ¿Deuda priorizada por riesgo × uso, con dueño y fecha?
- [ ] ¿Nivel de madurez ubicado por dimensión y próximo salto definido?
```

---

## 7. Migración / normalización documental

```
- [ ] ¿Content inventory antes de migrar (no migres basura)?
- [ ] ¿Mapeo origen→destino de URLs con redirects (no romper enlaces)?
- [ ] ¿Taxonomía y naming del destino definidos antes de mover?
- [ ] ¿Single-sourcing para lo duplicado; fusión de "verdades" divergentes?
- [ ] ¿Estándar editorial y gates de CI aplicados en el destino?
- [ ] ¿Plan de deprecación/archivo del origen (con retención si regulado)?
- [ ] ¿Validación post-migración (links, búsqueda, i18n) y comunicación?
```

---

## 8. Arquitectura de información (nuevo sistema de docs)

```
- [ ] ¿Estructura por intención del lector (Diátaxis), no por organigrama?
- [ ] ¿Hub de entrada por audiencia/tema con tareas frecuentes primero?
- [ ] ¿Naming/URLs predecibles y estables?
- [ ] ¿Source of truth única por tema; duplicación por enlace?
- [ ] ¿Glosario y metadata definidos; diseñado para búsqueda humana e IA?
- [ ] ¿Sin huérfanos; profundidad ≤ 3-4 niveles?
```

> Para casos completos aplicando estos checklists, ver [ejemplos.md](ejemplos.md).
