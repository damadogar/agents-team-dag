# arquitectura-informacion.md — Arquitectura de información documental

> Cómo docpower **organiza** el conocimiento para que se **encuentre** (modo B).
> Un documento que no se descubre no existe. La descubribilidad importa tanto como
> el contenido.
>
> Frontera: docpower diseña la **arquitectura de información de la documentación**.
> La arquitectura de información del **producto** (navegación de la app, jerarquía de
> pantallas) es de **uxuifull**; son surfaces distintas y no se pisan (ver
> [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)).
>
> Nota terminológica: en este skill, "**IA**" **nunca** abrevia "arquitectura de
> información" (siempre se escribe en extenso); "IA" = **inteligencia artificial**
> (ver [ia-y-documentacion.md](ia-y-documentacion.md)).

---

## 1. Principios

1. **Organiza por la intención del lector**, no por el organigrama ni por la
   estructura interna del sistema.
2. **Source of truth única** por hecho: un lugar canónico; el resto **enlaza**.
3. **Descubrible por tres vías:** navegación (estructura), búsqueda (metadata/palabras
   clave) y enlaces (cross-linking contextual).
4. **Nombres predecibles**: si el lector puede adivinar el nombre/URL, lo encuentra.
5. **Profundidad controlada**: jerarquías poco profundas y anchas ganan a las
   profundas y estrechas; evita más de 3-4 niveles.

---

## 2. Taxonomía y jerarquía

- Define **categorías de nivel superior** por intención o por dominio de la
  audiencia (p. ej. *Empezar / Guías / Referencia / Conceptos / Operación*), no por
  el equipo que lo escribió.
- Alinea la taxonomía con **Diátaxis** cuando aplique (tutoriales, how-to,
  referencia, explicación) — ver [technical-writing.md](technical-writing.md).
- Cada nodo tiene un **propósito claro**; nada de cajones "Varios/Otros" que se
  vuelven vertederos.
- Distingue **taxonomía de navegación** (cómo se recorre) de **taxonomía de
  etiquetas/metadata** (cómo se filtra y busca): pueden diferir.

---

## 3. Hubs documentales (landing pages)

Un **hub** es una página de entrada que orienta a una audiencia o tema:

- Explica **qué hay aquí y para quién**, y enruta a los documentos clave.
- Ordena por la **tarea más frecuente primero** (no alfabético por defecto).
- Es el antídoto contra "tengo 200 páginas y nadie sabe por dónde empezar".
- Tipos: hub de producto, hub por rol (dev/ops/soporte), hub por journey
  (onboarding → operación → troubleshooting).

---

## 4. Naming systems (convenciones de nombres)

- **Consistencia > ingenio.** Un patrón de nombres predecible para archivos,
  títulos, URLs y anclas.
- Títulos = la **tarea o el tema en las palabras del lector**; usa verbos para
  tareas ("Configurar SSO"), sustantivos para referencia ("Referencia de la API
  de pagos").
- URLs/slugs: minúsculas, con guiones, estables y semánticas; **no rompas URLs**
  (usa redirects si migras — ver [docs-as-code.md](docs-as-code.md)).
- Nombres de archivo en repos: kebab-case, descriptivos; evita `doc1`, `final_v2`.
- Reserva un patrón para versiones/idiomas (p. ej. `/es/`, `/en/`, `/v2/`).

---

## 5. Cross-linking (enlazado inteligente)

- Enlaza **en el punto de necesidad**: donde el lector podría atascarse, ofrece el
  enlace al concepto o la tarea relacionada.
- Texto de enlace **significativo** (dice a dónde lleva), nunca "aquí".
- **No dupliques**: si otro documento ya explica algo bien, enlázalo; la
  duplicación se desincroniza y miente.
- Enlaces bidireccionales cuando ayuden ("Ver también"), pero sin saturar.
- Verifica enlaces automáticamente (link checking en CI) para evitar rot.

---

## 6. Metadata y findability

- **Front-matter/metadata** por documento: título, descripción, dueño, audiencia,
  estado del ciclo de vida, última revisión, tags. Alimenta búsqueda, navegación y
  gobernanza.
- Escribe **descripciones/summaries** útiles: son lo que ve el buscador y el lector
  al decidir si entra.
- Palabras clave y sinónimos: incluye los términos que el lector **realmente
  busca**, no solo los oficiales (mapea sinónimos en el glosario).
- Diseña también para **búsqueda por IA/RAG** (chunking, encabezados semánticos) —
  ver [ia-y-documentacion.md](ia-y-documentacion.md).

---

## 7. Source of truth y control de duplicación

- Declara, por cada tema, **cuál documento es canónico**.
- Estrategias de reuse para no duplicar: **includes/transclusion**, snippets
  compartidos, variables de contenido, componentes MDX (ver [docs-as-code.md](docs-as-code.md)).
- Si dos documentos dicen lo mismo, **fusiona y redirige**; no dejes dos "verdades".
- La duplicación tolerada solo cuando el costo de enlazar supera el de repetir (raro)
  y siempre con nota de origen.

---

## 8. Glosario y taxonomía terminológica

- Un **glosario único** define cada término del dominio una sola vez; el resto
  enlaza.
- Registra el **término preferido** y los **sinónimos/deprecados** (para búsqueda y
  consistencia).
- El glosario es la fuente de la consistencia terminológica de
  [technical-writing.md](technical-writing.md).
- En entornos de datos, el glosario de negocio colinda con el **data catalog** de
  andulfo: docpower da la **forma y publicación**; la **definición técnica** es del
  SME de datos (ver [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)).

---

## 9. Diseño para humanos y para máquinas

Toda la arquitectura de información documental debe servir a dos lectores:

- **Humanos:** navegación clara, hubs, escaneabilidad.
- **Buscadores y sistemas de IA/RAG:** encabezados semánticos, contenido
  chunk-eable, metadata, `llms.txt`, evitar significado atrapado solo en imágenes.

Detalle de optimización para IA en [ia-y-documentacion.md](ia-y-documentacion.md).

---

## 9 bis. Validación de la arquitectura (no la adivines: pruébala)

Una taxonomía diseñada "por criterio" es una hipótesis. Los equipos de clase mundial la
**validan con usuarios reales** antes de comprometerla, no la publican y esperan:

- **Card sorting** (abierto o cerrado): das a los usuarios los "temas" y les pides
  agruparlos/nombrarlos. Revela **cómo piensan ellos** las categorías (no cómo las
  piensa el autor). El abierto descubre categorías; el cerrado valida unas propuestas.
- **Tree testing** (reverse card sorting): das la **estructura de navegación** (sin UI)
  y pides "¿dónde buscarías X?". Mide si la gente **encuentra** las cosas donde las
  pusiste. Es la prueba directa de findability de una taxonomía.
- **First-click / usability testing de la doc**: observa a un usuario intentando una
  tarea real; el primer clic predice fuertemente el éxito.
- **Análisis de búsquedas reales y de rutas**: los términos que la gente busca y los
  caminos que toma validan (o refutan) la arquitectura ya publicada.

Ciclo: **hipótesis de IA → card/tree test → ajusta → publica → mide** (search success,
first-click, time-to-answer en [metricas-salud.md](metricas-salud.md)). La validación
*antes* de publicar evita reorganizaciones caras después.

> Frontera: si la arquitectura a validar es la del **producto** (no la de la doc), el
> método (card sorting/tree testing/tests de usabilidad) lo conduce **uxuifull**;
> docpower valida la **arquitectura de la documentación**. Comparten método, distinta
> superficie.

---

## 10. Antipatrones de arquitectura (prohibidos)

- Estructura pensada para el **autor/organigrama**, no para el lector.
- Cajones "Varios/Otros" y jerarquías de 6 niveles.
- Duplicar en vez de enlazar; múltiples "fuentes de verdad" contradictorias.
- URLs inestables que se rompen en cada reorganización.
- Documentos huérfanos sin hub que los enlace (islas invisibles).
- Naming inconsistente que obliga a adivinar y a buscar dos veces.

> Cómo se versiona y publica esta arquitectura: [docs-as-code.md](docs-as-code.md).
> Cómo se mide su salud (findability, huérfanos, search success): [metricas-salud.md](metricas-salud.md).
