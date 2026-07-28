# Plantillas de entregables (uxuifull)

Plantillas reutilizables. Adáptalas al contexto; nunca entregues una plantilla
vacía como si fuera análisis. Toda salida cierra con próximos pasos y criterios
de éxito medibles.

## 1. Informe UX/UID (estructura base de respuesta)

```
### 1. Reformulación estratégica
[Problema real de experiencia + supuestos]
### 2. Diagnóstico UX/UI
[Fricciones por dimensión + severidad + impacto]
### 3. Estructura de experiencia recomendada
### 4. Arquitectura de información
### 5. Interacción e interfaz
### 6. Accesibilidad y claridad
### 7. Validación y mejora
### 8. Entregables accionables
[Prioridades + próximos pasos + criterios de éxito]
```

## 2. Diagnóstico / hallazgo

```
Hallazgo: [descripción]
Dimensión: [IA / IxD / UI / A11y / Contenido / Flujo]
Evidencia: [research / heurística / dato / HIPÓTESIS]
Severidad: [0–4]   Frecuencia: [baja/media/alta]
Impacto: [tarea / percepción / confianza / conversión]
Recomendación: [acción concreta]
Por qué mejora: [...]   Riesgo que evita: [...]
Validación: [cómo se mide]
Prioridad: [P0/P1/P2]
```

## 3. Persona (basada en evidencia)

```
Nombre/segmento · Contexto y objetivos (JTBD)
Comportamientos clave · Dolores y frustraciones · Necesidades
Nivel de experticia · Contexto de uso (dispositivo, entorno)
Cita representativa · Implicaciones de diseño
Fuente de evidencia: [entrevistas n=, analítica, ...]
```

## 4. Journey map (as-is / to-be)

```
Persona + escenario + objetivo
| Fase | Acción | Pensamiento | Emoción (curva) | Touchpoint/Canal | Dolor | Oportunidad | Métrica |
Momentos de verdad: [...]   Pico y final (peak-end): [...]
Backlog de oportunidades priorizado.
```

## 5. Especificación de arquitectura de información

```
Inventario/auditoría de contenido (mantener/fusionar/reescribir/eliminar)
Sitemap (diagrama) · Taxonomía (categorías, etiquetas, relaciones)
Esquema de navegación por nivel · Modelo de contenido
Lógica de búsqueda y filtros · Validación: card sort / tree test (resultados)
```

## 6. Especificación de flujo

```
Objetivo del flujo + entrada/salida
Diagrama (Mermaid) con ramas y errores
Estados por pantalla (vacío/carga/error/lleno/éxito/sin permiso)
Reglas de validación y recuperación · Edge cases (0/1/muchos/extremo)
Criterios de accesibilidad del flujo
```

## 7. Evaluación heurística

```
| # | Heurística | Problema | Ubicación | Severidad (0-4) | Recomendación |
Resumen ejecutivo + top problemas P0/P1 + plan de remediación
```

## 8. Auditoría de accesibilidad

```
| Criterio WCAG | Nivel | Estado (Pass/Fail/NA) | Evidencia | Severidad | Remediación |
Método: automático (axe/Lighthouse) + manual (teclado) + lector de pantalla
Resumen de cumplimiento AA + bloqueantes
```

## 9. Especificación de design system / componente

```
Tokens: primitivos → semánticos → componente
Componente: anatomía · variantes · estados · props/API
Do / Don't · Guía de contenido · Criterios de accesibilidad
Reglas de uso (cuándo SÍ / cuándo NO) · Versionado
```

## 10. Plan de research / validación

```
Objetivo + preguntas de investigación
Método(s) + muestra + reclutamiento
Tareas/guion · Métricas (éxito, SEQ, SUS, tiempo)
Plan de análisis · Entregable y plazo
```

## 11. Hipótesis de experimento

```
Creemos que [cambio] para [usuario] logrará [resultado].
Lo sabremos cuando [métrica + umbral] en [plazo].
Métrica primaria · Riesgo · Esfuerzo · Criterio de éxito/abandono
```

## 12. Roadmap UX por fases

```
Fase 0 quick wins (bajo riesgo): [...]
Fase 1 estructura/IA: [...]
Fase 2 sistema/consistencia: [...]
Fase 3 deleite/avanzado: [...]
Cada fase: objetivo, alcance, métrica de éxito, dependencias.
```
