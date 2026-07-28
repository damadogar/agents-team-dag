# technical-writing.md — Escritura técnica y estructura de contenido

> Cómo docpower **redacta y estructura** (modo C). El objetivo no es texto bonito:
> es que el lector logre su tarea con **mínima fricción**. Todo aquí es
> marco-agnóstico y aplicable a cualquier dominio o audiencia.

---

## 1. Diátaxis — el marco de organización por intención del lector

Diátaxis clasifica la documentación por lo que el lector **necesita en ese
momento**. Es la referencia canónica moderna; no las mezcles en un mismo documento.

| Tipo | Cuándo lo busca el lector | Orientación | Ejemplo |
|---|---|---|---|
| **Tutorial** | "Soy nuevo, enséñame haciendo" | Aprendizaje, guiado, pasos que **funcionan sí o sí** | "Tu primer despliegue en 10 min" |
| **How-to (guía de tarea)** | "Sé lo básico, ayúdame a lograr X" | Resolver un problema real, orientado a objetivo | "Cómo rotar una clave de API" |
| **Referencia** | "Necesito el dato exacto" | Información, seca, exhaustiva, consistente | Tabla de endpoints, flags, parámetros |
| **Explicación (concepto)** | "Quiero entender el porqué" | Comprensión, contexto, trade-offs | "Cómo funciona nuestro modelo de permisos" |

Regla de oro Diátaxis: **una página, una intención.** Si un tutorial empieza a
explicar arquitectura, extrae la explicación y enlázala. Mezclar los cuatro tipos
es la causa #1 de documentación confusa.

> Modelo equivalente clásico (DITA/topic-based): **concepto / tarea / referencia**
> + **troubleshooting**. Diátaxis y este modelo son compatibles: úsalos como la
> misma disciplina de separar por intención.

---

## 2. Plain language (lenguaje claro)

- **Voz activa** por defecto: "El sistema envía el correo", no "El correo es
  enviado por el sistema". La pasiva oculta al responsable de la acción.
- **Frases cortas**, una idea por frase. Divide párrafos largos (>4-5 líneas).
- **Palabras simples**: "usar" no "utilizar", "antes" no "con anterioridad".
- **Segunda persona** para instrucciones: "Haz clic en Guardar" (tú), no "el
  usuario debe hacer clic".
- **Presente** para describir comportamiento; **imperativo** para pasos.
- **Expande acrónimos al primer uso**: "Single Sign-On (SSO)"; luego "SSO".
- Elimina relleno: "con el fin de" → "para"; "en el caso de que" → "si".

---

## 3. Escritura orientada a tareas (task-oriented)

El lector no quiere leer: quiere **hacer algo**. Estructura por la tarea del
usuario, no por la estructura del sistema.

- Título = la tarea, en verbo: "**Configurar** webhooks", no "Configuración".
- Empieza por el **objetivo y el resultado**: qué logrará y cómo sabrá que
  funcionó.
- **Prerequisitos explícitos** antes de los pasos (permisos, versiones, datos).
- Pasos **numerados**, uno por acción, cada uno empezando por el verbo.
- Indica el **resultado esperado** de los pasos clave ("Verás un 200 OK").
- Cierra con **verificación** ("Cómo confirmar que quedó bien") y siguiente paso.

> **Evita FAQs como estructura por defecto.** Una FAQ suele ser síntoma de
> contenido mal organizado: conviértela en tareas, conceptos o referencia. Usa FAQ
> solo para preguntas genuinamente transversales y recurrentes.

---

## 4. Minimalismo (John Carroll)

Menos es más cuando cada palabra ayuda a actuar:

- **Corta todo lo que no ayude a la tarea.** El contexto irrelevante es ruido.
- Confía en que el lector es competente: no expliques lo obvio de su rol.
- Apoya la **acción inmediata**; deja la teoría profunda para la explicación
  enlazada.
- Soporta el **error y la recuperación**: anticipa el fallo común y su salida.
- No documentes lo que la interfaz ya dice con claridad.

---

## 5. Progressive disclosure (revelación progresiva)

Muestra primero lo esencial; revela el detalle bajo demanda.

- Lo más frecuente y crítico **arriba**; los casos avanzados/edge, después o
  colapsados.
- Quickstart primero, referencia exhaustiva después.
- Usa secciones, *tabs*, *callouts* y enlaces "Ver detalle" para no abrumar.
- Una página larga y bien jerarquizada suele vencer a diez fragmentadas: equilibra
  con la arquitectura de información ([arquitectura-informacion.md](arquitectura-informacion.md)).

---

## 6. Escaneabilidad (la gente no lee, escanea)

- **Títulos descriptivos y precisos** (el lector navega por ellos, no por el
  cuerpo). "Manejo de errores 4xx", no "Más información".
- Listas para pasos y para conjuntos; **tablas** para comparaciones y referencia.
- **Negrita** para el término o acción clave de la frase, no para decorar.
- Bloques de código con lenguaje declarado y, si aplica, resaltado.
- **Callouts** con jerarquía clara de severidad:
  - `Nota`: información útil, sin riesgo.
  - `Importante`: fácil de pasar por alto y con impacto.
  - `Advertencia`: riesgo de pérdida de datos, seguridad o irreversibilidad.
- Enlaces con **texto significativo**: "consulta la [guía de auth](#)", nunca
  "haz clic [aquí](#)". El texto de enlace debe decir a dónde lleva.

---

## 7. Consistencia terminológica

- **Un término, un significado.** Elige "usuario" o "cliente", no ambos para lo
  mismo. Registra las decisiones en el glosario ([arquitectura-informacion.md](arquitectura-informacion.md)).
- Mismo nombre para el mismo objeto en UI, API y docs; si difieren, es un bug de
  producto que docpower **señala** (no lo resuelve solo si es decisión de otro).
- Mantén un **usage guide** ligero para términos, capitalización, nombres de
  producto y excepciones del dominio — no una guía editorial monstruosa desde
  cero (ver [gobernanza-documental.md](gobernanza-documental.md)).

---

## 8. Ejemplos, código y advertencias

- **Ejemplos que aclaran**, no que decoran; deben ser correctos y copiables.
- Code samples: **verificables** (que realmente corran; ver docs-as-tests en
  [docs-as-code.md](docs-as-code.md)), con valores realistas pero seguros (nunca
  secretos reales). Muestra petición **y** respuesta cuando aporte.
- **Warnings antes del riesgo**, no después: si un comando borra datos, adviértelo
  encima del comando.
- **Supuestos explícitos** y prerequisitos: no asumas versión, permisos ni estado
  previo sin decirlo.

---

## 9. Criterio de audiencia (tono, densidad, profundidad)

| Audiencia | Qué prioriza | Densidad |
|---|---|---|
| **Ejecutivos / stakeholders** | Impacto, decisión, riesgo, síntesis | Alta síntesis, sin jerga |
| **Producto (PO/PM)** | Alcance, comportamiento, flujos, reglas | Media, orientada a decisión |
| **Developers** | Precisión, ejemplos, edge cases, setup, comportamiento de API | Alta técnica |
| **QA** | Criterios verificables, resultados esperados, cobertura, supuestos | Alta precisión |
| **Ops / SRE / DevOps** | Runbooks, observabilidad, rollback, manejo de incidentes | Accionable, paso a paso |
| **Seguridad** | Controles, amenazas, hardening, evidencia de cumplimiento | Precisa, trazable |
| **Equipos de datos** | Linaje, definiciones, supuestos, reglas de calidad, ownership | Precisa, referencial |
| **Soporte L1/L2/L3** | Troubleshooting, fallos comunes, rutas de escalamiento | Directa, diagnóstica |
| **Usuarios finales** | Cómo lograr su objetivo, sin jerga técnica | Simple, guiada |

Cuando un documento sirve a varias audiencias, **separa por secciones o por
documentos** en vez de promediar el tono (el promedio no sirve a nadie).

---

## 9 bis. Comunicación visual (cuándo el diagrama vence a la prosa)

Lo visual no es adorno: a veces **comunica mejor y más rápido** que el texto. Úsalo con
la misma disciplina que la prosa.

- **Cuándo un diagrama gana:** relaciones, flujos, arquitecturas, secuencias,
  jerarquías, máquinas de estado. Un diagrama de secuencia vence a tres párrafos.
- **Cuándo NO:** procedimientos lineales (mejor pasos numerados) o datos exactos (mejor
  tabla). No metas en una imagen lo que debe ser texto buscable/traducible.
- **Diagrams-as-code**: prefiere **Mermaid / PlantUML / C4 / diagramas vectoriales**
  versionados en el repo (se revisan en PR, se regeneran, no caducan como una captura).
- **Screenshots con criterio**: úsalas solo cuando la UI es el punto; son el activo que
  **más rápido se desactualiza**. Minimiza su número, recórtalas al detalle relevante y
  planifica su **frescura** (ver frescura/regresión visual en [docs-as-code.md](docs-as-code.md)).
- **Accesibilidad y traducción**: todo diagrama con significado lleva **alt text**;
  **nunca** metas significado crítico solo en la imagen (rompe a11y, búsqueda, IA y
  localización — ver [accesibilidad-i18n.md](accesibilidad-i18n.md)).
- **Consistencia**: mismos símbolos, colores y notación en todo el set; una leyenda si
  hace falta.

> En producto físico, lo visual sube a **núcleo** (despieces, montaje, símbolos de
> seguridad): ver [documentacion-producto-fisico.md](documentacion-producto-fisico.md).

---

## 10. Antipatrones de redacción (prohibidos)

- Títulos vagos ("Información", "Detalles", "Más").
- Muros de texto sin jerarquía; pasos incompletos o sin verbo.
- Voz pasiva excesiva; jerga innecesaria; relleno ("cabe destacar que…").
- Duplicar contenido en vez de enlazar la source of truth.
- Depender de una imagen para transmitir significado crítico (rompe accesibilidad
  y traducción; ver [accesibilidad-i18n.md](accesibilidad-i18n.md)).
- Documentar para lucir conocimiento del autor en vez de servir al lector.
- Mezclar tutorial + referencia + explicación en la misma página (rompe Diátaxis).

> Checklist de QA editorial en [checklists.md](checklists.md). Estándares formales
> (ISO/IEC, style guides de la industria) en [frameworks-estandares.md](frameworks-estandares.md).
