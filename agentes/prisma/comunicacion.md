# comunicacion.md — Comunicación de insights y recomendaciones

El entregable de Prisma **no es el modelo**: es la **decisión informada**.
Este módulo cubre cómo traducir análisis complejos en **narrativas claras,
visualizaciones honestas y recomendaciones accionables** para producto, negocio y
operaciones.

Ver [SKILL.md](SKILL.md) §15.

---

## 1. De insight a decisión (estructura)

1. **Pregunta** que se buscaba responder (la de PO/BA).
2. **Respuesta/recomendación** al frente (no la entierres tras la metodología).
3. **Evidencia** que la sustenta (resultado + incertidumbre).
4. **Impacto esperado** en la métrica de negocio.
5. **Limitaciones y supuestos** (qué no sabemos).
6. **Próximos pasos** y decisión solicitada.

> Lidera con la conclusión y la recomendación; el método va de soporte (apéndice
> para la audiencia técnica).

## 2. Adaptar el mensaje a la audiencia

| Audiencia | Qué le importa | Cómo comunicar |
|---|---|---|
| **Ejecutivos / negocio** | Decisión, impacto, riesgo, costo | 1 página, conclusión primero, sin jerga |
| **Producto** | Qué cambia para el usuario, trade-offs | Escenarios, ejemplos, recomendación |
| **Técnico (DS/AI Eng)** | Método, validación, supuestos | Detalle reproducible, *notebooks*, métricas |
| **Operaciones** | Cómo se aplica, *guardrails* | Procedimiento, umbrales, monitoreo |

## 3. Comunicar incertidumbre (sin overclaiming)

- Reporta **rangos/intervalos**, no solo el punto.
- Distingue **correlación** de **causalidad** explícitamente.
- Declara **supuestos** y condiciones de validez.
- Evita el *overclaiming*: "el modelo sugiere…", no "el modelo prueba…".
- Si un hallazgo es exploratorio, dilo (no lo presentes como confirmado).

## 4. Visualización honesta

- **El gráfico correcto para el mensaje:** tendencia → línea; comparación →
  barras; distribución → histograma/box; relación → dispersión.
- **No engañes:** ejes desde cero cuando corresponde, escalas consistentes, sin
  *cherry-picking* de rangos.
- **Anota** lo importante (qué mirar) y mantén el *data-ink* alto (sin adornos).
- Muestra **incertidumbre** (bandas, barras de error) cuando exista.

## 5. Errores de comunicación que prisma evita

- Enterrar la recomendación bajo la metodología.
- Mostrar métricas sin **baseline** ni contexto de negocio.
- Gráficos engañosos (ejes truncados, escalas inconsistentes).
- Presentar correlación como causalidad.
- Omitir limitaciones e incertidumbre.
- Jerga técnica con audiencia de negocio.

## 6. Reglas de oro de comunicación

1. **El entregable es la decisión,** no el modelo.
2. **Conclusión primero;** método de soporte.
3. **Comunica incertidumbre y limitaciones** siempre.
4. **Visualiza con honestidad** (sin distorsión).
5. **Habla el idioma de la audiencia.**
6. **Toda recomendación es accionable** y trae su impacto esperado.
