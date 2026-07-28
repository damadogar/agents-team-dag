# exploracion.md — Análisis exploratorio de datos (EDA)

Cómo Prisma explora datos **antes** de modelar: entender el dato, su
calidad y estructura, e identificar patrones, anomalías, *drivers* y segmentos.
La EDA precede al modelado y formula hipótesis explícitas.

Ver [SKILL.md](SKILL.md) §3, §11. Consume datasets preparados por
`caudal`/`brujula` (no reingiere fuentes crudas).

---

## 1. Objetivos de la EDA

1. **Entender** la unidad de análisis (grain), el periodo y el universo de datos.
2. **Evaluar calidad:** nulos, duplicados, rangos imposibles, consistencia.
3. **Caracterizar distribuciones:** centralidad, dispersión, asimetría, colas.
4. **Detectar relaciones:** correlaciones, interacciones, no linealidades.
5. **Identificar anomalías, *drivers* y segmentos** relevantes para el problema.
6. **Formular hipótesis** explícitas a confirmar.

## 2. Calidad de datos (antes de confiar en ellos)

- **Completitud:** % de nulos por variable; ¿el nulo significa algo?
- **Duplicados:** a nivel de la clave de la unidad de análisis.
- **Validez/rango:** valores imposibles (edades negativas, fechas futuras).
- **Consistencia temporal:** cambios de definición o de fuente en el tiempo.
- **Representatividad:** ¿la muestra refleja la población objetivo?
- Si la calidad falla en origen → **retroalimenta a `caudal`/
  `brujula`**; no parchees en silencio.

## 3. Análisis univariado y bivariado

- **Univariado:** histogramas, *boxplots*, percentiles; transformaciones (log)
  para colas largas.
- **Bivariado:** relación *feature* ↔ target; *correlación* (Pearson/Spearman),
  tablas de contingencia, *lift* por categoría.
- **Outliers:** detéctalos (IQR, z-score, modelos); decide tratarlos vs
  conservarlos **según el problema** (un fraude es un *outlier* que importa).

## 4. Drivers y segmentación

- **Drivers:** variables más asociadas al objetivo (correlación, *mutual
  information*, *importance* de un modelo rápido como diagnóstico).
- **Segmentos:** subpoblaciones con comportamiento distinto (por clustering o por
  reglas de negocio); cuida que el segmento no sea *spurio*.
- **Cuidado con la fuga:** una variable "demasiado buena" puede ser *leakage*
  (información del futuro o del propio target). Marca sospechas (ver
  [feature-engineering.md](feature-engineering.md)).

## 5. Confirmatorio vs exploratorio

- **Exploratorio:** genera hipótesis; alto riesgo de hallazgos espurios por
  múltiples comparaciones.
- **Confirmatorio:** prueba una hipótesis pre-registrada con una métrica y un test
  definidos *a priori*.
- Regla: **no presentes un hallazgo exploratorio como confirmado**; si importa,
  confírmalo en datos/holdout independientes.

## 6. Datos no estructurados (texto/imágenes/logs)

- **Texto:** longitud, idioma, vocabulario, duplicados, PII; *embeddings* para
  explorar similitud (coordina con AI Engineer/andulfo si hay *vector store*).
- **Imágenes:** distribución de clases, calidad, sesgos de captura.
- **Logs/eventos:** volumen por tiempo, secuencias, sesiones.

## 7. Checklist de EDA

- [ ] Grain, periodo y universo definidos
- [ ] Calidad evaluada (nulos, duplicados, rangos, consistencia)
- [ ] Distribuciones y *outliers* caracterizados
- [ ] Relaciones con el target exploradas (sin asumir causalidad)
- [ ] *Drivers* y segmentos candidatos identificados
- [ ] Señales de posible *data leakage* marcadas
- [ ] Hipótesis explícitas formuladas para modelado/experimento
- [ ] Problemas de calidad retroalimentados a caudal/brujula

## 8. Reglas de oro de EDA

1. **Entiende antes de modelar:** un modelo sobre datos no entendidos es ruido.
2. **Correlación ≠ causalidad** (ver [experimentacion.md](experimentacion.md)).
3. **Cuida múltiples comparaciones:** muchos cruces → hallazgos falsos.
4. **Sospecha de lo "demasiado bueno":** posible *leakage*.
5. **Documenta supuestos y decisiones** de limpieza/tratamiento.
