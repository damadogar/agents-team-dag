# runbooks.md — Runbooks de incidentes de Data Science

Procedimientos paso a paso para incidentes de **data science**. Cierre común:
**contener → diagnosticar → remediar → validar → documentar + prevenir la
recurrencia**. Método reproducible en [ejecucion.md](ejecucion.md).

> Regla transversal: ante un modelo que **decide sobre personas** o alimenta una
> decisión crítica, contén primero (pausa/marca como no confiable) antes de
> remediar.

---

## 1. Sospecha de *data leakage*

1. CONTENER: no publiques/no productivices el modelo "demasiado bueno".
2. DIAGNOSTICAR: audita cada *feature* ("¿existiría antes de predecir?");
   revisa escalado/encoding fuera de CV y fugas temporales/de grupo.
3. REMEDIAR: reconstruye *features*/validación sin fuga (pipeline ajustado en
   train, GroupKFold/temporal, encoding *out-of-fold*).
4. VALIDAR: el desempeño cae a niveles realistas; estable en holdout honesto.
5. CERRAR: documenta la fuga y añade un *check* que la detecte a futuro.

## 2. Modelo que no generaliza (overfitting)

1. DIAGNOSTICAR: *gap* train↔validation; curvas de aprendizaje.
2. REMEDIAR: regulariza, simplifica, más datos, *early stopping*, menos features.
3. VALIDAR: desempeño consistente train/validation/test.
4. CERRAR: registra la configuración robusta.

## 3. A/B no concluyente o con *peeking*

1. DIAGNOSTICAR: ¿se calculó MDE/potencia?, ¿hubo *peeking*?, ¿SRM?, ¿duración
   suficiente?
2. REMEDIAR: si hay SRM o sesgo de asignación → experimento inválido, reejecuta.
   Si faltó potencia → no concluyas "no efecto"; recalcula n o extiende.
3. VALIDAR: análisis con corrección adecuada; reporta efecto + intervalo.
4. CERRAR: documenta decisión (lanzar/iterar/descartar) con incertidumbre.

## 4. Target mal definido / label leakage

1. CONTENER: detén conclusiones basadas en ese target.
2. DIAGNOSTICAR: ¿la etiqueta usa información del futuro o del propio resultado?
3. REMEDIAR: redefine el target con PO/BA y `brujula`; recalcula.
4. VALIDAR: reentrena y revalida con el target correcto.
5. CERRAR: documenta la definición correcta del evento.

## 5. *Drift* detectado por el AI Engineer (re-análisis)

1. RECIBIR: el AI Engineer reporta degradación/*drift* en producción.
2. DIAGNOSTICAR: ¿cambió la distribución de entrada, la relación o el target?
   (revisa con datos recientes).
3. REMEDIAR: re-feature/reentrena o ajusta; propone criterios de *retraining*.
4. VALIDAR: el modelo recuperado supera al *baseline* actual.
5. CERRAR: entrega actualización al AI Engineer (la operación es suya).

## 6. Sesgo / *fairness* detectado

1. CONTENER: si el modelo decide sobre personas, marca el riesgo y escala.
2. DIAGNOSTICAR: mide disparidades por grupo protegido (métricas de *fairness*).
3. REMEDIAR: re-muestreo, *reweighing*, *constraints*, o cambio de enfoque;
   coordina con destroyer y negocio sobre el criterio aceptable.
4. VALIDAR: disparidad dentro del umbral acordado; documenta trade-offs.
5. CERRAR: actualiza la *model card* con el análisis de sesgo.

## 7. No reproducibilidad de un resultado

1. DIAGNOSTICAR: falta de semilla, versión de datos/código o estado oculto.
2. REMEDIAR: fija semillas, congela versión de datos, entorno (lockfile),
   registra en *tracking*.
3. VALIDAR: un tercero reproduce el resultado.
4. CERRAR: incorpora reproducibilidad al estándar del proyecto.

## 8. Handoff de modelo a producción

1. PREPARAR: artefacto del modelo + pipeline de *features* + *model card*.
2. ESPECIFICAR: contrato de *features* (point-in-time), latencia, criterios de
   monitoreo y *drift*, plan de *retraining*.
3. ENTREGAR al **AI Engineer** (dueño de la operación).
4. VALIDAR: paridad de predicciones *offline*↔*online* (sin *train/serving skew*).
5. CERRAR: si no hay AI Engineer, asume operación inicial como **[COBERTURA
   ADJUNTA]** con handoff documentado.
