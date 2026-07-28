# docs-as-code.md — Docs-as-code, DocOps y automatización

> Cómo docpower trata la documentación como **parte de la ingeniería** (modo E):
> vive con el cambio, se revisa como código, se valida automáticamente y tiene
> quality gates. Marco/herramienta-agnóstico: se recomienda por trade-offs, no por
> moda.

---

## 1. Principio docs-as-code

La documentación se escribe en **texto plano versionado** (Markdown/MDX, AsciiDoc,
reStructuredText), vive **cerca del código** cuando es posible, y pasa por el mismo
flujo: rama → PR → revisión → merge → publicación automática.

Beneficios: historial y `blame`, revisión en PR, validación en CI, publicación
reproducible, y **el cambio de código y su doc viajan juntos** (evita el desfase).

> No todo debe ser docs-as-code. Contenido de negocio muy editado por no-técnicos
> puede vivir mejor en un WYSIWYG (Notion/Confluence). docpower **elige por
> contexto**: audiencia autora, necesidad de versionado, cercanía al código,
> control editorial y automatización.

---

## 2. Formatos de authoring

| Formato | Fortaleza | Cuándo |
|---|---|---|
| **Markdown** | Universal, simple, portable | Default para la mayoría de docs |
| **MDX** | Markdown + componentes | Docs con UI/interactividad (Docusaurus, Nextra, Starlight) |
| **AsciiDoc** | Semántica rica, libros, includes | Docs largas/estructuradas, manuales, PDF |
| **reStructuredText** | Ecosistema Python/Sphinx, directivas | Proyectos Sphinx, referencia autogenerada |
| **HTML semántico** | Control total, accesibilidad | Cuando se necesita precisión de marcado |
| **YAML/JSON** | Contenido estructurado, single-sourcing | Datos que alimentan páginas (specs, tablas) |

---

## 3. Static site generators y frameworks de docs

Selección por trade-offs (control editorial, DX, versionado, i18n, mantenimiento,
lock-in) — **no por popularidad**:

- **Docusaurus / Nextra / Astro Starlight / VitePress** — MDX/JS, buena DX,
  versionado e i18n integrados; ecosistema JS.
- **MkDocs / Material for MkDocs** — Markdown puro, simple y potente; ecosistema
  Python.
- **Sphinx** — referencia autogenerada, directivas ricas; estándar en Python y en
  documentación técnica extensa.
- **Hugo / Jekyll** — sitios rápidos, temáticos; menos orientados a docs de
  producto complejas.

Criterios de decisión: ¿multi-versión?, ¿multi-idioma?, ¿autogeneración de API?,
¿quién edita (técnico vs no)?, ¿coste de mantenimiento?, ¿portabilidad si migramos?

---

## 4. Versionado de documentación

- **Sincroniza la doc con la versión del producto**: cada versión soportada tiene
  su doc; marca claramente *current*, *next* y *deprecated*.
- Estrategias: docs versionadas (snapshots por release) vs *single-version* con
  notas "desde vX". Elige según cuántas versiones soportas en producción.
- **Deprecación visible**: banners "Esta página aplica a v1; ver v2".
- **No rompas URLs** entre versiones: mantén redirects y anclas estables.

---

## 5. Reuse y single-sourcing

- **Includes / transclusion / snippets**: escribe una vez, incrústalo en muchos
  lugares; la source of truth es única.
- **Variables de contenido** (nombre de producto, versión, endpoints) para cambiar
  en un solo lugar.
- **Componentes** (MDX) para patrones repetidos (callouts, tablas de parámetros).
- Meta: cero copy-paste que se desincronice (ver [arquitectura-informacion.md](arquitectura-informacion.md) §7).

---

## 6. Calidad automatizada (linting y validación en CI)

Quality gates comparables a los del código:

- **Vale** — linter de prosa: aplica el style guide (voz activa, términos
  prohibidos, terminología, inclusividad) de forma automática y consistente.
- **markdownlint / textlint** — estructura y formato Markdown.
- **prettier** — formateo consistente.
- **Link checkers** — detecta enlaces rotos internos y externos.
- **Spell checkers** con diccionario de proyecto.
- **Schema validation** — valida specs (OpenAPI/AsyncAPI), front-matter, YAML.
- **Alt-text / accesibilidad** — checks de imágenes sin alt, jerarquía de headings.

Orquestación: **pre-commit hooks** (feedback local rápido) + **CI pipeline** (gate
antes de merge) + **publicación automática** al hacer merge.

---

## 7. Docs-as-tests (documentación ejecutable)

Los ejemplos deben **funcionar de verdad**, no solo parecer correctos:

- **Doctest / ejemplos ejecutables**: corre los code samples en CI; si fallan, la
  doc rompe el build.
- **Snippets extraídos del código real** o testeados contra él (no copiados a mano).
- **Contract/spec drift**: valida que la referencia de API coincida con la spec
  vigente (autogenera desde OpenAPI cuando sea posible — ver [api-developer-docs.md](api-developer-docs.md)).
- **Command/output testing** para tutoriales y runbooks críticos: que los comandos
  produzcan el output documentado.
- **Frescura de imágenes / regresión visual**: las capturas de pantalla son el activo
  que más rápido miente. Mitiga con **screenshots automatizadas** (generadas en CI vía
  el mismo test end-to-end de la UI) y/o **visual regression testing** que detecta
  cuándo la UI cambió y la captura quedó obsoleta. Prefiere **diagramas-as-code**
  (Mermaid/PlantUML) sobre imágenes estáticas para lo que se pueda (ver comunicación
  visual en [technical-writing.md](technical-writing.md)).

Esto convierte la documentación en algo que **se rompe cuando miente**, que es
exactamente lo que queremos.

---

## 8. Integración en el SDLC

- **DoD documental**: un cambio de comportamiento (feature, API, config, breaking
  change) **no se considera "done" sin su documentación** actualizada. docpower
  define este gate con el equipo (ver [gobernanza-documental.md](gobernanza-documental.md)).
- **Docs en el PR del código**: idealmente el mismo PR trae código + doc; el
  reviewer valida ambos.
- **Release notes automatizadas** o semiautomáticas desde el changelog/PRs
  (ver [tipos-de-documento.md](tipos-de-documento.md)).
- **Ownership por CODEOWNERS**: cada área de docs tiene revisor responsable.

---

## 9. Estructura de repositorio (patrón recomendado)

```
/docs
  /tutorials       # Diátaxis: aprender haciendo
  /how-to          # tareas concretas
  /reference       # referencia (API, CLI, config)
  /explanation     # conceptos, arquitectura, porqués
  /_includes       # snippets reusables (single-sourcing)
  /_assets         # imágenes/diagramas (con alt en el texto)
  /es /en          # localización (si aplica)
CONTRIBUTING.md    # cómo contribuir docs
STYLEGUIDE.md      # usage guide ligero (o config de Vale)
.vale.ini / .markdownlint.json / redirects.yml
```

Ajusta a Diátaxis, al SSG elegido y a si las docs viven en el repo del código o en
un repo dedicado (trade-off: cercanía al cambio vs docs transversales).

---

## 10. Antipatrones de DocOps (prohibidos)

- Documentación que vive lejos del cambio y se actualiza "cuando haya tiempo".
- Ejemplos de código que nunca se ejecutan (y por tanto mienten con el tiempo).
- Publicación manual y frágil; enlaces que se rompen sin que nadie se entere.
- Copy-paste en vez de single-sourcing; N versiones desincronizadas.
- Elegir el SSG "de moda" sin evaluar versionado, i18n, autogeneración ni lock-in.
- Docs sin dueño en CODEOWNERS ni gate en CI (nadie es responsable de que estén al día).

> Estándar editorial y ciclo de vida: [gobernanza-documental.md](gobernanza-documental.md).
> Métricas del pipeline y del sistema: [metricas-salud.md](metricas-salud.md).
