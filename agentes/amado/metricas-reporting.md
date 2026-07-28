# Métricas y reporting de calidad

Referencia de Amado para el modo **E (Reporting y Mejora)**.

---

## 1. Métricas de producto / calidad

| Métrica | Fórmula / definición | Para qué sirve |
|---|---|---|
| **Defect density** | Defectos / tamaño (KLOC, story points, módulo) | Comparar calidad entre módulos/releases |
| **Defect leakage** | Defectos en prod / (prod + pre-prod) | Eficacia del proceso de QA |
| **Defect removal efficiency (DRE)** | Defectos pre-release / total × 100 | % de bugs atrapados antes de prod |
| **Test coverage** | Requisitos/AC con prueba / total | Cobertura funcional demostrable |
| **Code coverage** | Líneas/ramas ejecutadas por tests | Salud de la suite unitaria (no es calidad por sí sola) |
| **Test case effectiveness** | Defectos hallados por casos / total | Calidad del diseño de pruebas |
| **MTTR (defectos)** | Tiempo medio de resolución | Velocidad de respuesta |
| **Tiempo de ciclo de bug** | Apertura → cierre | Eficiencia del flujo de defectos |
| **Estabilidad de release** | Fallos/incidentes post-release | Confiabilidad de la entrega |

---

## 2. Métricas de proceso / automatización

| Métrica | Definición |
|---|---|
| **% automatización efectiva** | Casos automatizados estables / automatizables |
| **Lead time de pruebas** | Tiempo desde build hasta resultado de pruebas |
| **Tasa de fallos en prod por release** | Incidentes atribuibles por entrega |
| **Flaky test rate** | % de tests con resultados no deterministas |
| **Tasa de éxito del pipeline** | Builds en verde / total |
| **Pass rate** | Casos en pass / ejecutados |

> Cuidado con métricas vanidosas: code coverage alto no implica calidad; pass
> rate alto con pocos casos no implica cobertura. Interpreta en conjunto.

---

## 3. Métricas de entrega (DORA, contexto)

Deployment frequency · Lead time for changes · Change failure rate · MTTR.
Útiles para subir la conversación de QA a nivel de organización y conectar
calidad con velocidad de entrega.

---

## 4. Dashboards por audiencia

| Audiencia | Qué mostrar |
|---|---|
| **C-level / negocio** | Estado de calidad (semáforo), riesgos top, fuga a prod, tendencia de incidentes |
| **PO / PM** | Cobertura de AC, defectos abiertos por severidad, readiness de release |
| **Dev / QA** | Pass rate, flaky tests, cobertura, MTTR, defectos por módulo |
| **DevOps / SRE** | Estabilidad de release, smoke en prod, SLI/SLO, change failure rate |

Principios: una historia clara, tendencias (no solo foto), accionables, sin ruido.

---

## 5. Informe ejecutivo (estructura)

```
1. Veredicto de calidad: 🟢 Listo / 🟡 Listo con riesgos / 🔴 No listo
2. Resumen (3-5 líneas): qué se probó, resultado, decisión recomendada
3. Riesgos principales y su mitigación
4. Métricas clave (cobertura, defectos por severidad, fuga)
5. Recomendación y próximos pasos
```

## 6. Informe técnico (estructura)

```
1. Alcance y ambiente/build
2. Casos ejecutados / pass / fail / bloqueados
3. Defectos detectados (con enlace y severidad)
4. Evidencias (logs, métricas, capturas)
5. Hallazgos no funcionales (performance/seguridad/accesibilidad)
6. Cobertura y trazabilidad
7. Riesgos residuales y recomendaciones de mejora
```

Regla de oro: **todo informe cierra con "Próximos pasos" y "Criterios de salida
medibles".**

---

## 7. Mejora continua

- Retro de calidad por release: qué se escapó, por qué, cómo prevenirlo.
- Análisis de causa raíz (5 porqués) de los bugs que llegaron a prod.
- Ajuste de la matriz de riesgo y de la selección de regresión con lo aprendido.
- Revisión periódica de herramientas, marcos y prácticas vigentes (web).
