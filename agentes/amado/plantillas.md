# Plantillas de entregables

Plantillas reutilizables de Amado. Copia, completa y adapta.

---

## 1. Captura de entradas

```
Producto / módulo / feature:
Objetivo de negocio y criterios de éxito:
Arquitectura y stack (si disponible):
Metodología (agile/waterfall/híbrido):
Criticidad / regulaciones / SLAs / privacidad:
Restricciones (tiempo, presupuesto, equipo, ambientes):
Estado actual de QA (inexistente/manual/parcial/maduro):
Accesos disponibles (ambientes, datos, CI/CD, herramientas, MCP):
Supuestos asumidos [SUPUESTO]:
```

---

## 2. Estrategia de QA (resumen)

```
1. Visión y objetivos de calidad
2. Atributos de calidad prioritarios (top 3)
3. Alcance (in / out)
4. Niveles y tipos de prueba
5. Enfoque de riesgo
6. Estrategia de automatización (pirámide objetivo)
7. Ambientes y datos de prueba
8. Roles y responsabilidades
9. Herramientas
10. Métricas y criterios de éxito
11. Riesgos y mitigaciones
12. Próximos pasos
```

---

## 3. Test Plan (IEEE 829 / ISO 29119-3)

```
ID y alcance:
Referencias (requisitos/AC/arquitectura/riesgos):
Objetivos de prueba:
Enfoque/estrategia (niveles, tipos, técnicas):
Criterios de entrada:
Criterios de salida:
Criterios de suspensión/reanudación:
Entregables de prueba:
Ambientes y datos:
Cronograma e hitos:
Recursos y responsabilidades:
Riesgos y mitigaciones:
Herramientas:
Métricas y reporting:
```

---

## 4. Caso de prueba

```
ID:
Título:
Prioridad / Severidad asociada:
Tipo (funcional/no funcional) | Nivel | Automatizable (sí/no):
Trazabilidad (Requisito/AC ↔ Riesgo):
Precondiciones:
Datos de prueba:
Pasos:
  1. <acción>  → <resultado esperado>
  2. <acción>  → <resultado esperado>
Resultado esperado final:
Postcondiciones / limpieza:
```

### Caso en Gherkin (BDD)
```
Funcionalidad: <nombre>
  Escenario: <nombre>
    Dado <precondición>
    Cuando <acción>
    Entonces <resultado verificable>
```

---

## 5. Reporte de defecto

```
ID:
Título (qué falla, dónde):
Severidad (🔴/🟠/🟡/🟢) | Prioridad (P1-P4) | Estado | Owner:
Ambiente / Build:
Precondiciones:
Pasos para reproducir:
  1.
  2.
Resultado actual:
Resultado esperado:
Evidencia (capturas/video/logs/request-response):  [sin PII/secretos reales]
Datos de prueba:
Trazabilidad (AC ↔ caso que lo detectó):
Impacto / frecuencia | Workaround:
```

---

## 6. Matriz de riesgo

```
| Área/Feature | Impacto | Probabilidad | Nivel | Profundidad de prueba | Owner |
|--------------|---------|--------------|-------|-----------------------|-------|
|              |         |              |       |                       |       |
```

---

## 7. Matriz de trazabilidad

```
| Req/AC | Riesgo | Caso(s) | Tipo | Auto | Estado | Defecto |
|--------|--------|---------|------|------|--------|---------|
|        |        |         |      |      |        |         |
```

---

## 8. Informe ejecutivo

```
Veredicto: 🟢 Listo / 🟡 Listo con riesgos / 🔴 No listo
Resumen (3-5 líneas):
Riesgos principales y mitigación:
Métricas clave (cobertura, defectos por severidad, fuga):
Recomendación y próximos pasos:
```

---

## 9. Informe técnico

```
Alcance y ambiente/build:
Casos: ejecutados / pass / fail / bloqueados:
Defectos (enlace + severidad):
Evidencias:
Hallazgos no funcionales (performance/seguridad/accesibilidad):
Cobertura y trazabilidad:
Riesgos residuales y recomendaciones:
Próximos pasos | Criterios de salida:
```

---

## 10. Plan de automatización

```
Objetivo y alcance:
Qué automatizar (por valor/estabilidad) y qué no:
Pirámide objetivo (% por nivel):
Herramientas seleccionadas + justificación:
Patrón de arquitectura (POM/Screenplay/API layers/data-driven):
Integración en CI/CD y gates de calidad:
Reportes y evidencias:
Orden de implementación (fases):
Criterios de éxito (métricas):
```
