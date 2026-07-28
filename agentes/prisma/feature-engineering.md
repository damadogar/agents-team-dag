# feature-engineering.md — Ingeniería de features (sin leakage, consistente)

Cómo Prisma construye *features* a partir del **dato ya preparado** por
`caudal` (staging/core) y `brujula` (capa semántica/métricas),
con dos obsesiones: **cero *data leakage*** y **consistencia train/serving**.

Ver [SKILL.md](SKILL.md) §14. Frontera: la **materialización** de *features* a
escala y el *feature store* son de `caudal`/AI Engineer; aquí se define la
**lógica analítica**.

---

## 1. De dónde salen las features

- **Capa semántica (`brujula`):** reutiliza **métricas certificadas** y
  dimensiones conformadas — no reinventes definiciones de negocio.
- **Staging/core (`caudal`):** atributos y eventos ya limpios y modelados.
- **No reingieras** desde fuentes crudas; si falta un dato, **levanta el
  requerimiento** al rol dueño (ver [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)).

## 2. Tipos de features

- **Numéricas:** escalado/normalización, *binning*, transformaciones (log, Box-Cox).
- **Categóricas:** *one-hot*, *ordinal*, *target/CatBoost encoding* (con CV para
  evitar fuga), *embeddings* para alta cardinalidad.
- **Temporales:** *lags*, ventanas móviles, tendencias, estacionalidad, *time since
  last event* — calculadas **solo con información pasada**.
- **Texto/no estructurado:** TF-IDF, *embeddings*; coordina infra con AI Engineer.
- **Agregados:** por entidad/ventana (gasto últimos 30 días); cuida el horizonte.
- **Interacciones/ratios:** cuando hay fundamento de negocio.

## 3. Data leakage — el enemigo #1

Tipos y cómo evitarlos:

| Tipo de fuga | Ejemplo | Prevención |
|---|---|---|
| **Target leakage** | Feature que incluye el resultado (o derivado) | Audita cada feature: ¿estaría disponible **antes** de predecir? |
| **Train-test contamination** | Escalado/imputación/encoding ajustados sobre todo el dataset | Ajusta **solo en train** (pipeline con `fit` en train) |
| **Temporal leakage** | Usar datos posteriores al momento de predicción | *Point-in-time correctness*: features con corte temporal |
| **Group leakage** | Mismo sujeto en train y test | GroupKFold por entidad |
| **Encoding leakage** | *Target encoding* sin CV | *Encoding* dentro de CV / *out-of-fold* |

> Regla: para cada *feature*, pregunta **"¿este valor existiría, tal cual, en el
> momento real de la predicción?"** Si no, es fuga.

## 4. Point-in-time correctness

- Cada *feature* debe reflejar el estado del mundo **en el instante de la
  predicción**, no después.
- En entornos con *feature store*: usa *point-in-time joins*; coordina con
  `caudal`/AI Engineer.
- En series de tiempo: ventanas y *lags* estrictamente pasados.

## 5. Consistencia train/serving (training-serving skew)

- Las transformaciones de entrenamiento deben **reproducirse idénticas** en
  inferencia.
- **Empaqueta** el preprocesamiento junto al modelo (pipeline) o especifícalo sin
  ambigüedad en el *handoff* al AI Engineer.
- Evita lógica de *feature* en *notebooks* que luego no exista en producción.

## 6. Selección de features

- **Filtros:** varianza, correlación con target, *mutual information*.
- **Embebidos:** regularización (Lasso), *importance* de árboles.
- **Wrapper:** *recursive feature elimination* (con CV).
- **Estabilidad:** prioriza *features* estables y explicables; menos es más
  (parsimonia, menos riesgo de fuga y de *drift*).

## 7. Documentación de features

- Cada *feature*: definición, fuente, ventana temporal, transformación, *owner*.
- Marca las que dependen de **métricas certificadas** de `brujula`.
- Útil para el *handoff* al AI Engineer y para auditoría/reproducibilidad.

## 8. Reglas de oro de feature engineering

1. **Cero leakage:** ¿la feature existiría antes de predecir?
2. **Point-in-time:** estado del mundo en el momento de la predicción.
3. **Ajusta transformaciones solo en train** (nada de tocar test).
4. **Consistencia train/serving:** misma transformación en producción.
5. **Reutiliza la capa semántica;** no reinventes métricas.
6. **Parsimonia:** *features* estables y explicables sobre cantidad.
7. **Documenta** cada feature para handoff y reproducibilidad.
