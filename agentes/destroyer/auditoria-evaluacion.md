# Metodología universal de auditoría y evaluación — Destroyer

Cómo auditar y evaluar **cualquier sistema, en cualquier fase, sin sesgo**. Esta
es la columna vertebral del Modo F. Principio rector: **la lente es riesgo +
evidencia, nunca un marco, una nube ni una arquitectura preferida.**

---

## 1. Reglas de neutralidad del auditor

1. **Evidencia sobre suposición.** Un hallazgo se sostiene en algo observado
   (config, log, código, artefacto, entrevista), no en "suele pasar".
2. **Madurez medida, no asumida.** Si no hay evidencia de un control, el veredicto
   es **"no verificado"**, no "inexistente" ni "presente". Distingue siempre
   *ausente* de *no observado*.
3. **Cero marco impuesto.** Mapea al estándar que la organización usa (o a
   ninguno). Si traduces entre marcos, dilo (crosswalk).
4. **Proporcionalidad.** El rigor del control esperado se ajusta a la criticidad
   calibrada del sistema, no a un ideal absoluto.
5. **Independencia y trazabilidad.** Separa hecho (evidencia) de juicio
   (interpretación) de recomendación. Cada hallazgo es rastreable a su evidencia.
6. **Sin sesgo de novedad ni de antigüedad.** Un mainframe COBOL bien controlado
   puede ser más seguro que un stack cloud-native mal operado. Evalúa el control
   real, no la etiqueta tecnológica.
7. **Falsabilidad.** Declara qué evidencia cambiaría tu conclusión y qué quedó
   fuera de alcance.

---

## 2. El método adapta su forma a la FASE (no al revés)

| Fase | Pregunta central | Fuentes de evidencia | Entregable |
|---|---|---|---|
| **ANTES** (concepción/diseño) | ¿El diseño puede ser seguro? ¿qué amenazas y qué controles faltan *by design*? | Idea, propuesta, requisitos, diagramas, ADRs | Threat model + requisitos de seguridad + decisiones |
| **DURANTE** (construcción) | ¿Se está construyendo conforme al diseño seguro? ¿hay deuda entrando? | Código, PRs, IaC, pipeline, dependencias, artefactos | Revisión + gates + hallazgos pre-release |
| **DESPUÉS** (operación) | ¿El control **realmente** funciona en producción? ¿hay deriva? | Config en vivo, logs, telemetría, métricas, accesos reales | Evaluación de postura + brechas operativas |
| **POST-HOC** (auditoría) | ¿Cuál es el estado objetivo e independiente? ¿madurez y brechas vs. riesgo? | Todo lo anterior + entrevistas + muestreo | Informe de auditoría + madurez + plan |

El **mismo riesgo** se evalúa distinto según la fase: en diseño es una amenaza a
mitigar; en construcción, un control a verificar; en operación, una detección a
comprobar; en auditoría, una evidencia a muestrear.

---

## 3. Proceso de auditoría (agnóstico de sistema y fase)

```
1. ALCANCE Y FASE
   - Qué sistema, qué límites, qué fase, qué NO entra en alcance.
   - Tipo de sistema (ver dominios-sistemas.md) → ajusta el "qué mirar".
2. CALIBRACIÓN (sin sesgo)
   - Criticidad real, datos, exposición, escala, impacto si falla, regulación.
   - Marco de referencia de la organización (si existe) → mapear a él.
3. RECOLECCIÓN DE EVIDENCIA
   - Documentación, diagramas, código, IaC, config, logs, métricas, entrevistas.
   - Marca cada dato como: observado / declarado-por-tercero / inferido.
4. ANÁLISIS POR DOMINIO
   - Recorre los dominios aplicables (humano, físico, identidad, red, app/API,
     datos, cripto, supply chain, detección/respuesta, IA/LLM, gobierno).
   - Para cada uno: ¿control presente? ¿eficaz? ¿evidencia? ¿gap?
5. EVALUACIÓN DE RIESGO
   - Riesgo = Probabilidad × Impacto, ajustado por exposición y atacante plausible.
   - Cada hallazgo: evidencia → impacto → severidad → recomendación → owner.
6. MADUREZ (medida)
   - Nivel por dominio con evidencia; distingue ausente / no verificado / presente.
7. PRIORIZACIÓN Y ROADMAP
   - Por riesgo, no por conteo. Quick wins + estructural. Trade-offs explícitos.
8. INFORME
   - Hechos, juicios y recomendaciones separados. Riesgo residual. Alcance y límites.
```

---

## 4. Escala de madurez (genérica, mapeable a cualquier modelo)

Úsala solo como lenguaje común; mapea al modelo del cliente (CMMI, SAMM, CSF
Tiers, IG de CIS) si lo tiene.

| Nivel | Descripción | Evidencia esperada |
|---|---|---|
| 0 — Inexistente | El control no existe (verificado) | Ausencia confirmada |
| 1 — Inicial/ad-hoc | Existe informalmente, sin consistencia | Casos sueltos, sin proceso |
| 2 — Repetible | Definido y aplicado de forma inconsistente | Procedimiento, aplicación parcial |
| 3 — Definido | Estandarizado y documentado | Política + evidencia de uso |
| 4 — Gestionado | Medido con métricas y revisado | KPIs, revisiones, mejora |
| 5 — Optimizado | Mejora continua y automatización | Tendencias, automatización, retro |

Y por separado, el estado de cada control: **Presente / Parcial / Ausente / No
verificado / No aplica** (con justificación de los dos últimos).

---

## 5. Clasificación de hallazgos (sin etiqueta tecnológica)

Cada hallazgo:
```
ID · Dominio · Título
Estado del control: Presente/Parcial/Ausente/No verificado/No aplica
Evidencia: <qué se observó y dónde> (sin exponer secretos/PII)
Riesgo: probabilidad × impacto + atacante plausible
Severidad: 🔴/🟠/🟡/🟢 (calibrada al sistema, no a un default)
Recomendación: accionable, mapeada al marco del cliente si lo hay
Control compensatorio (si no se puede remediar ya)
Owner · Esfuerzo · Riesgo residual tras remediación
Confianza del hallazgo: alta/media/baja (según calidad de la evidencia)
```

---

## 6. Sesgos del auditor a evitar (autocontrol)

- **Confirmación:** buscar solo lo que confirma una hipótesis previa.
- **Novedad/antigüedad:** asumir que lo moderno es seguro o lo legacy inseguro.
- **Marco:** evaluar contra el marco que el auditor prefiere, no el del sistema.
- **Disponibilidad:** sobreponderar el último incidente sonado.
- **Anclaje:** fijarse en la primera cifra/criticidad mencionada.
- **Escala:** aplicar exigencias de gran empresa a un sistema pequeño (o viceversa).
- **Vendor/nube:** penalizar o premiar por proveedor en vez de por control real.

Si una conclusión depende de una preferencia, **reformúlala como elección
contextual con trade-offs** o decláralo como limitación.

---

## 7. Cierre del informe de auditoría

```
- [ ] Alcance, fase y límites declarados (qué se evaluó y qué no)
- [ ] Criticidad calibrada con criterio explícito (no asumida)
- [ ] Hallazgos con evidencia, separando hecho/juicio/recomendación
- [ ] Estado de control: presente/parcial/ausente/no verificado/no aplica
- [ ] Madurez medida y mapeada al marco del cliente (si lo hay)
- [ ] Priorización por riesgo (no por conteo) + roadmap + quick wins
- [ ] Riesgo residual y confianza de cada hallazgo
- [ ] Cero sesgo de marco/nube/arquitectura/escala/región declarado y respetado
```
