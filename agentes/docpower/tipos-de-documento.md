# tipos-de-documento.md — Catálogo experto de tipos de documento

> Qué produce docpower y **cómo debe verse cada tipo bien hecho** (modo C). Cada
> tipo tiene un propósito, una audiencia y una estructura mínima. Plantillas
> concretas en [plantillas.md](plantillas.md).

---

## 1. README (de repositorio o proyecto)

Puerta de entrada; en < 30 segundos el lector sabe **qué es, si le sirve y cómo
empezar**. Estructura mínima:

1. **Qué es** (una frase) y **para quién**.
2. **Por qué / valor** (problema que resuelve).
3. **Quickstart** (instalar/correr en los mínimos pasos).
4. **Uso básico** con un ejemplo real.
5. **Enlaces**: docs completas, contribución, licencia, soporte.
6. **Estado**: build/versión/mantenimiento.

Antipatrones: README que explica la arquitectura interna antes del quickstart; sin
ejemplo ejecutable; sin decir qué hace.

---

## 2. Guía de contribución (CONTRIBUTING)

Cómo aportar sin fricción: setup del entorno, estándar de estilo (enlaza el usage
guide / Vale), flujo de PR, cómo correr tests y docs-as-tests, code of conduct,
cómo se revisa y quién aprueba (CODEOWNERS).

---

## 3. Quickstart

El camino **más corto** de cero a un primer éxito. Diferente del tutorial: menos
explicación, más "haz esto y funciona".

- **Un solo camino feliz**, sin ramas ni opciones.
- Prerequisitos mínimos y explícitos.
- Termina en un **resultado verificable** ("deberías ver 200 OK").
- Enlaza al tutorial y a la referencia para profundizar.

---

## 4. Tutorial

Aprendizaje guiado para principiantes (Diátaxis). Debe **funcionar sí o sí** de
principio a fin; el lector aprende haciendo, no decidiendo.

- Objetivo claro y motivador; resultado tangible al final.
- Pasos que no fallan; sin decisiones que el novato no puede tomar.
- Explica lo justo; enlaza los conceptos, no los desarrolles aquí.

---

## 5. How-to (guía de tarea)

Resuelve **un problema real** a alguien que ya conoce lo básico.

- Título = la tarea en verbo ("Cómo configurar reintentos").
- Prerequisitos, pasos numerados, resultado esperado, verificación.
- Cubre el camino feliz y los **errores comunes** con su salida.

---

## 6. Referencia

Información exacta y exhaustiva para consulta puntual. Seca y consistente.

- Estructura predecible y repetida (misma plantilla por endpoint/comando/flag).
- Completa: todos los parámetros, tipos, defaults, límites, errores.
- Sin narrativa: el lector viene por el dato, no por la historia.
- Autogenerada desde la fuente cuando sea posible (spec, código) para no desviarse.

API en profundidad: [api-developer-docs.md](api-developer-docs.md).

---

## 7. Explicación / concepto

Da **comprensión y contexto**: cómo funciona algo y **por qué** es así.

- Modelo mental, diagramas (Mermaid/PlantUML/C4), trade-offs y alternativas
  descartadas.
- No es un how-to: no lleva pasos; ilumina el porqué.
- Ideal para "cómo funciona el modelo de permisos", "por qué elegimos eventos".

---

## 8. ADR (Architecture Decision Record)

Registra **una decisión** de arquitectura/técnica y su porqué, de forma inmutable
en el tiempo.

- Estructura: **Contexto → Decisión → Estado (propuesta/aceptada/reemplazada) →
  Consecuencias** (positivas y negativas) → alternativas consideradas.
- Corto, fechado, versionado junto al código; se **supersede**, no se reescribe.
- **Frontera:** la **decisión** de arquitectura es de **eneida** (SME); docpower
  aporta la **disciplina, la estructura y la calidad** del ADR, no decide la
  arquitectura (ver [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)).

---

## 9. RFC (Request for Comments)

Propuesta **antes** de decidir, para recabar feedback.

- Problema, propuesta, alternativas, impacto, riesgos, plan, preguntas abiertas.
- Estado y período de comentarios; deriva en un ADR cuando se decide.
- docpower estructura y modera el formato; el **contenido técnico** es del proponente.

---

## 10. Runbook / Playbook

Procedimiento **operativo repetible**, ejecutable bajo presión (incidentes, tareas
de Ops/SRE).

- Escrito para **ejecutar sin pensar de más**: pasos atómicos, verificables,
  idempotentes cuando se pueda.
- **Prerequisitos, permisos y prechecks**; punto de **rollback** claro.
- Criterios de decisión explícitos ("si X → haz Y; si no → escala a Z").
- **Verificación** al final y ruta de **escalamiento**.
- Playbook = varios runbooks + criterio de cuándo usar cada uno (p. ej. respuesta a
  incidentes). Coordina con el SME de Ops/seguridad para la substancia.

---

## 11. SOP (Standard Operating Procedure)

Procedimiento estándar de negocio/proceso, a menudo con requisitos de cumplimiento.

- Propósito, alcance, roles/responsables, pasos, registros que genera, control de
  versiones y aprobación.
- Cuando es documentación-registro (regulada): ver [documentacion-regulada.md](documentacion-regulada.md).

---

## 12. Release notes y changelog

Comunican **qué cambió** — con dos audiencias distintas:

- **Changelog** (técnico): `Added / Changed / Deprecated / Removed / Fixed /
  Security` por versión (estilo *Keep a Changelog*), semver, enlazado a PRs/issues.
- **Release notes** (usuario/negocio): qué gano yo, cómo lo uso, qué debo hacer si
  hay breaking change o migración.
- **Breaking changes**: destacados, con guía de migración y fechas de deprecación.

---

## 13. Troubleshooting

Diagnóstico y salida de fallos.

- Organizado por **síntoma** ("Recibo 403 al llamar X"), no por causa interna.
- Síntoma → causa probable → verificación → solución → cómo prevenir.
- Enlaza a la referencia de errores; alimenta la **deflection** de soporte
  (ver [metricas-salud.md](metricas-salud.md)).

---

## 14. Onboarding técnico

Lleva a una persona nueva de cero a productiva.

- Ruta secuencial (día 1 / semana 1 / mes 1) con hitos verificables.
- Setup del entorno, conceptos base, primer cambio real, a quién preguntar.
- Reduce el time-to-first-contribution; se mide y se mejora.

---

## 15. Knowledge base / handbook interno

Repositorio vivo de conocimiento operativo y organizacional.

- Organizado por hubs y taxonomía ([arquitectura-informacion.md](arquitectura-informacion.md)).
- Cada artículo con dueño, estado y fecha de revisión (gobernanza).
- Combate el conocimiento tribal; captura de SME por entrevista cuando hace falta.

---

## 16. Glosario y taxonomía

Términos del dominio definidos una sola vez, con sinónimos y deprecados; es la base
de la consistencia terminológica y de la búsqueda. Detalle en
[arquitectura-informacion.md](arquitectura-informacion.md) §8.

---

## 17. Postmortem (sin culpa)

Retrospectiva **de un incidente ya ocurrido**: qué pasó, por qué, qué impacto tuvo
y qué se cambia para que no vuelva a suceder. Es aprendizaje organizacional, no
procedimiento operativo (contrasta con el Runbook §10: el runbook es el
**procedimiento operativo repetible** para actuar durante el incidente; el
postmortem es la **retrospectiva** posterior a él).

- **Sin culpa (blameless):** analiza el sistema y las condiciones, no señala
  personas; el objetivo es entender causas, no repartir responsabilidad.
- **Estructura:** resumen ejecutivo, impacto (usuarios, negocio, SLO/error budget),
  **línea de tiempo** de detección→respuesta→resolución, **causa raíz** (5-whys /
  árbol de fallos), qué funcionó y qué no, y **acciones correctivas** con dueño y
  fecha (seguibles hasta el cierre).
- **Buenas prácticas:** hechos verificables antes que narrativa; distinguir
  detonante de causa raíz; una acción por hallazgo, medible y con responsable;
  enlazar a métricas/alertas, al runbook aplicable y al registro del incidente;
  publicarlo donde el equipo lo encuentre y lo reutilice.
- **Ownership:** el **contenido técnico del postmortem es de `baluarte`** (SME de
  la retrospectiva de incidente sin culpa: causa raíz operativa, impacto en
  confiabilidad, acciones correctivas); **docpower da la FORMA** —estructura,
  claridad, trazabilidad de acciones y consistencia con las demás docs operativas.

---

> Para cada tipo: elige **concepto/tarea/referencia/troubleshooting** según la
> intención del lector (Diátaxis, [technical-writing.md](technical-writing.md)),
> declara audiencia y source of truth, y define cómo se mantiene
> ([gobernanza-documental.md](gobernanza-documental.md)). Plantillas listas en
> [plantillas.md](plantillas.md).
