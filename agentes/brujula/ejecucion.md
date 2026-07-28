# ejecucion.md — Método universal de ejecución segura de cambios de modelos

Método **agnóstico de herramienta/warehouse** para cambiar cualquier objeto de la
capa semántica (modelo, métrica, materialización, snapshot) **sin romper a los
consumidores**. Cambiar una definición publicada es un **cambio en producción**.

Secuencia obligatoria: **DETECT → PLAN → DRY-RUN → SAFEGUARD → EXECUTE → VERIFY →
ROLLBACK**.

> Regla 0: **nunca rompas un dashboard en silencio.** Si un cambio afecta a
> consumidores, exige versionado, *deprecation* anunciada y rollback.

---

## 1. DETECT — descubrir el impacto antes de tocar

- Identifica **qué consumidores** dependen del modelo/métrica (linaje +
  *exposures*).
- Clasifica el cambio: **aditivo/compatible** (nueva columna/métrica) vs
  **incompatible** (renombrar/eliminar/redefinir fórmula).
- Confirma datos disponibles en core con `caudal` si requieres campos
  nuevos.
- Detecta si hay **PII** involucrada y la política de exposición.

## 2. PLAN — diseñar el cambio y su reverso

- Define el cambio en pasos; si es incompatible, planifica **expand/contract**:
  1. *expand*: añade lo nuevo en paralelo (compatible),
  2. migra consumidores con *deprecation* anunciada,
  3. *contract*: elimina lo viejo tras confirmar no-uso (linaje).
- Para métricas: documenta el **delta esperado** entre definición vieja y nueva.
- Escribe el **rollback** ANTES de ejecutar (volver al modelo/métrica previa).

## 3. DRY-RUN — compilar y simular

- **Compila** el grafo (sin materializar) para detectar referencias rotas.
- Ejecuta en **dev/no-prod** con datos representativos.
- Corre **tests de datos** sobre la salida.
- **Compara resultados** vieja vs nueva definición (regresión de métrica) y valida
  el delta con PO/BA si cambia el significado.

## 4. SAFEGUARD — redes de seguridad

- Despliega en entorno **dev/stg** aislado; usa *deferral*/*state* para construir
  solo lo cambiado sin tocar prod.
- Verifica que existe forma de **reconstruir desde core** (reproducibilidad).
- Define **ventana, comunicación y aprobación** para cambios incompatibles.
- Asegura **idempotencia** de los modelos afectados.

## 5. EXECUTE — desplegar con control

- Despliega por dominio/modelo, no todo de golpe.
- Mantén el modelo/métrica anterior disponible durante la *deprecation*.
- Monitorea *freshness*, errores de *build* y costo.
- Si una métrica clave se desvía fuera del delta esperado, **detente**.

## 6. VERIFY — comprobar consistencia y consumo

- **Tests verdes** y **reconciliación** del modelo contra core/detalle.
- **Métricas consistentes** (mismo resultado donde no debía cambiar).
- **Dashboards clave** siguen funcionando y con números correctos.
- **Documentación/diccionario** actualizados y publicados.

## 7. ROLLBACK / deprecación

- Si falla: revierte al modelo/métrica anterior (estaba disponible en paralelo).
- Si es *deprecation* planificada: retira lo viejo solo tras confirmar no-uso por
  linaje y tras el periodo de transición.
- Documenta causa raíz y añade un **test** que prevenga la recurrencia.

---

## 8. Guardas para cambios de alto riesgo

| Cambio | Guarda mínima |
|---|---|
| **Redefinir fórmula de métrica** | Versión nueva, delta esperado validado con PO/BA, comunicación |
| **Renombrar/eliminar columna o modelo** | Expand/contract, *deprecation*, verificación de no-uso por linaje |
| **Cambiar el *grain*** de un hecho | Tratar como modelo nuevo; migración de consumidores |
| **Cambiar materialización a incremental** | Clave única, *full-refresh* inicial, reconciliación |
| **Exponer un campo PII en consumo** | Aprobación de destroyer/andulfo, enmascaramiento |

> Nunca elimines/renombres un objeto consumido **sin** *deprecation* anunciada y
> rollback disponible.
