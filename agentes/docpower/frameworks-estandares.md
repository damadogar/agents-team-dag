# frameworks-estandares.md — Marcos, estándares y guías de la disciplina

> La **base disciplinar** de docpower. No inventa criterios: se apoya en los marcos
> y estándares reconocidos del rubro y elige según contexto. Referencia
> vendor-agnóstica; ninguna fuente por defecto, se aplica la que encaja.

---

## 1. Diátaxis

Marco canónico de organización por **intención del lector**: tutorial, how-to,
referencia, explicación. Regla: una página, una intención. Es el eje de la
arquitectura de contenido de docpower — desarrollo en
[technical-writing.md](technical-writing.md) §1 y [arquitectura-informacion.md](arquitectura-informacion.md).

---

## 2. Topic-based authoring y DITA

- **Topic-based**: escribir en unidades autónomas (topics) de tipo **concepto /
  tarea / referencia**, reutilizables y ensamblables. Base del single-sourcing.
- **DITA (Darwin Information Typing Architecture)**: estándar XML para autoría
  estructurada, tipado de topics, reuse (conref) y publicación multi-canal. Propio
  de operaciones documentales grandes/industriales y de tooling especializado.
- **Cuándo DITA**: alto volumen, múltiples salidas (web/PDF/print), fuerte reuse,
  equipos de writing dedicados. **Cuándo no**: equipos ágiles de software suelen
  estar mejor con Markdown/docs-as-code que con la complejidad de DITA.

---

## 3. Minimalismo (John Carroll)

Principio de diseño instruccional: documentación que **soporta la acción inmediata**
del lector, corta lo superfluo, respeta su competencia y facilita la recuperación
del error. Guía la densidad y el recorte — ver [technical-writing.md](technical-writing.md) §4.

---

## 4. Estándares ISO/IEC de documentación técnica

Referencia formal (útil en entornos regulados o de alta exigencia; se aplican con
criterio, no como burocracia):

- **ISO/IEC/IEEE 26514** — diseño y desarrollo de documentación de usuario
  (proceso, estructura, calidad).
- **ISO/IEC/IEEE 26515** — documentación en desarrollo ágil.
- **ISO/IEC/IEEE 26511 / 26512** — gestión de la documentación de usuario y de su
  adquisición (procesos de gobierno documental).
- **IEC/IEEE 82079-1** — preparación de **instrucciones de uso** (información para
  usar productos), transversal a hardware/software/industria.
- **ISO 9001 / sistemas de gestión** — control de documentos y registros
  (versionado, aprobación, retención) — colinda con documentación-registro
  ([documentacion-regulada.md](documentacion-regulada.md)).

> No exijas cumplimiento ISO donde no aporta. Úsalos como **checklist de completitud
> y control** cuando la criticidad o el regulador lo justifican.

---

## 5. Estándares de industrias específicas (cuando aplican)

- **S1000D** — documentación técnica en aeroespacial/defensa (mantenimiento,
  data modules). 
- **DocBook** — estándar XML para documentación técnica extensa y libros.
- **Instrucciones de uso reguladas** (dispositivos médicos, maquinaria) — combinan
  82079-1 con el marco regulatorio del sector.

docpower reconoce estos estándares y colabora con el SME del dominio; no los
sustituye por criterio propio cuando hay obligación normativa.

---

## 6. Style guides editoriales (prosa y mecánica)

Fuentes de referencia para voz, mecánica y terminología (se elige una como base y se
adapta en un usage guide ligero — ver [gobernanza-documental.md](gobernanza-documental.md) §1):

- **Google developer documentation style guide** — clara, moderna, orientada a dev.
- **Microsoft Writing Style Guide** — amplia, inclusiva, buena para producto.
- **GitLab / Red Hat / Kubernetes style guides** — docs-as-code, open source.
- **The Chicago Manual of Style / AP** — mecánica editorial general (no técnica).
- **Guías de lenguaje claro** (plain language) y de **lenguaje inclusivo**.

Para localización, la fuente elegida debe ser **traducible** (ver source-for-
translation en [accesibilidad-i18n.md](accesibilidad-i18n.md)).

---

## 7. Accesibilidad como estándar

- **WCAG** (Web Content Accessibility Guidelines) aplicado a documentación:
  estructura semántica, alt text, contraste, texto de enlace, navegación por
  teclado/lector de pantalla.
- Marco legal donde aplica (p. ej. **EN 301 549 / EAA** en Europa) — el SME de
  cumplimiento/UX confirma la obligación; docpower asegura la **forma accesible**.

Desarrollo en [accesibilidad-i18n.md](accesibilidad-i18n.md).

---

## 8. DocOps / Docs-as-code como práctica

Conjunto de prácticas que llevan la cultura de ingeniería a la documentación:
versionado, review, CI/CD, automatización, métricas. No es un estándar formal sino
una **disciplina operativa** — desarrollo en [docs-as-code.md](docs-as-code.md).

---

## 9. Cómo elige docpower entre marcos

1. **Empieza por la necesidad y la audiencia**, no por el marco.
2. **Diátaxis + minimalismo + plain language** son el default para casi todo.
3. **Docs-as-code** por defecto en contextos de software; WYSIWYG cuando el autor es
   no-técnico y no se necesita versionado fuerte.
4. **ISO/IEC / estándares de industria / DITA** entran cuando la **criticidad, el
   volumen o el regulador** lo justifican.
5. Siempre **adapta, no impone**: el marco sirve a la claridad, no al revés.

> Regla: el estándar existe para **reducir fricción y errores**; si un estándar los
> aumenta sin beneficio proporcional, docpower lo dice y propone la alternativa.
