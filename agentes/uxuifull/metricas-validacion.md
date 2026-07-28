# Métricas y Validación de Experiencia

Diseñar sin medir es opinar. Define cómo probar, medir e iterar antes de dar por
buena una solución. Toda apuesta lleva una hipótesis verificable.

## 1. Evaluación heurística (escala de severidad)

Las **10 heurísticas de Nielsen**: visibilidad del estado · correspondencia con
el mundo real · control y libertad · consistencia y estándares · prevención de
errores · reconocer mejor que recordar · flexibilidad y eficiencia · estética y
diseño minimalista · ayudar a reconocer/diagnosticar/recuperarse de errores ·
ayuda y documentación.

Severidad (0–4): 0 no es problema · 1 cosmético · 2 menor · 3 mayor · 4
catastrófico. Prioriza por **severidad × frecuencia × impacto en el negocio**.

## 2. Métricas de usabilidad por tarea (conductuales)

- **Tasa de éxito** (effectiveness): % de usuarios que completan la tarea.
- **Tiempo en tarea** (efficiency).
- **Tasa y tipo de error**; recuperación.
- **Esfuerzo**: clics/pasos vs ruta óptima; tasa de abandono.
- **Aprendibilidad**: mejora entre intentos.

Norma base: ISO 9241-11 define usabilidad como **eficacia + eficiencia +
satisfacción** en un contexto de uso.

## 3. Métricas actitudinales (cuestionarios validados)

- **SUS** (System Usability Scale): 10 ítems, 0–100; >68 = por encima del
  promedio; ~80+ excelente. Estándar de la industria.
- **UMUX-Lite**: 2 ítems, correlaciona con SUS, más corto.
- **SEQ** (Single Ease Question, 1–7): facilidad percibida por tarea, justo tras
  realizarla.
- **NPS**: lealtad, no usabilidad; úsalo con cautela y nunca como única métrica
  de experiencia.
- **CSAT / CES** (Customer Effort Score): satisfacción y esfuerzo percibido.

## 4. Framework HEART (Google) para métricas de producto

| Categoría | Mide | Ejemplo de señal/métrica |
|-----------|------|--------------------------|
| **Happiness** | satisfacción/actitud | SUS, CSAT, encuestas |
| **Engagement** | nivel de uso | frecuencia, profundidad de sesión |
| **Adoption** | nuevos usuarios/feature | % activación, uso de feature nueva |
| **Retention** | usuarios que vuelven | retención D1/D7/D30, churn |
| **Task success** | eficacia/eficiencia | éxito, tiempo, error |

Aplica **Goals → Signals → Metrics**: por cada objetivo define la señal
observable y la métrica concreta. No midas todo: elige lo que informa decisiones.

## 5. Métodos de validación

- **Usability testing** (5 usuarios/iteración descubren ~85% de problemas;
  itera). Moderado para profundidad, no moderado para escala.
- **A/B testing**: hipótesis + métrica primaria + tamaño de muestra +
  significancia antes de lanzar; evita conclusiones con muestra insuficiente.
- **First-click / tree testing** para IA (ver
  [arquitectura-informacion.md](arquitectura-informacion.md)).
- **Analítica + grabaciones + heatmaps**: el cuantitativo dice *dónde*, el
  cualitativo *por qué* (ver [research-ux.md](research-ux.md)).
- **Auditoría de accesibilidad**: automática + manual + lector de pantalla (ver
  [accesibilidad.md](accesibilidad.md)).

## 6. Hipótesis de mejora (formato)

```
Creemos que [cambio de diseño]
para [usuario/segmento]
logrará [resultado esperado].
Lo sabremos cuando veamos [métrica + umbral] en [plazo].
```

Toda recomendación de alto impacto se expresa como hipótesis medible, no como
certeza.

## 7. Definición de éxito y criterios de aceptación de UX

- Define **antes** de diseñar: métrica objetivo, baseline, meta y método.
- Criterios de aceptación de experiencia: tasa de éxito mínima, SEQ mínimo,
  cumplimiento WCAG AA, estados completos definidos.
- Vincula a estrategia (North Star/HEART) en [estrategia-ux.md](estrategia-ux.md).

## 8. Mejora continua

- **Benchmark periódico** (SUS/HEART) para ver tendencia, no solo foto.
- **Auditorías recurrentes** (heurística, accesibilidad, consistencia del design
  system).
- **Cierre del loop**: cada test produce hallazgos priorizados → backlog →
  rediseño → re-test. Documenta aprendizajes en el repositorio de insights.

## 9. Entregables

- Reporte de evaluación heurística con severidad.
- Plan y reporte de usability test (tareas, métricas, hallazgos, recomendaciones).
- Cuadro de mando UX (HEART + métricas de tarea) con baseline y meta.
- Backlog de mejoras priorizado.
- Hipótesis de experimentos con criterio de éxito.

> Mide lo que importa para decidir. Una métrica que no cambia una decisión es
> ruido.
