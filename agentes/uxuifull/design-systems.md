# Design Systems

Piensa la UI como **sistema**, no como piezas aisladas. Un design system entrega
consistencia, velocidad, escalabilidad y calidad sostenida entre productos.

## 1. Anatomía de un design system

- **Principios de diseño** (la filosofía que guía decisiones).
- **Design tokens** (la fuente de verdad de las decisiones visuales).
- **Componentes** (UI reutilizable con variantes y estados).
- **Patrones** (composiciones recurrentes: formularios, navegación, tablas…).
- **Guías de uso, contenido y accesibilidad**.
- **Documentación** y herramientas (Figma + código sincronizados).

Un design system no es solo una librería de Figma ni de componentes: es la
suma de tokens + componentes + patrones + guías + gobernanza.

## 2. Design tokens

- Decisiones de diseño como datos nombrados y reutilizables (color, tipografía,
  espaciado, radios, sombras, duración de motion, z-index).
- **Niveles de token** (estándar W3C DTCG / práctica común):
  - **Primitivos / globales**: valores crudos (`blue-500`, `space-4`).
  - **Semánticos / alias**: intención (`color-action-primary`,
    `color-surface`, `text-on-primary`).
  - **De componente**: específicos (`button-primary-bg`).
- Los componentes consumen **tokens semánticos**, nunca primitivos ni hex
  crudos. Esto habilita theming (claro/oscuro, marcas, densidad) sin reescribir
  componentes.
- Tokens multiplataforma (web/iOS/Android) desde una sola fuente (p. ej. Style
  Dictionary). Versiónalos.

## 3. Componentes

- **API clara**: props/variantes mínimas y predecibles; estados completos
  (default/hover/focus/active/disabled/loading/error) — ver
  [interaccion-disenio.md](interaccion-disenio.md).
- **Variantes con lógica**: define cuándo usar cada una; evita variantes
  redundantes.
- **Accesibilidad incorporada** en el componente (roles ARIA, foco, teclado,
  contraste), no como parche posterior — ver [accesibilidad.md](accesibilidad.md).
- **Atomic Design** (Brad Frost) como modelo mental: átomos → moléculas →
  organismos → templates → páginas.
- Paridad **diseño↔código**: el componente en Figma y en código se comportan
  igual (ver [ux-engineering-avanzado.md](ux-engineering-avanzado.md)).

## 4. Patrones

Soluciones probadas a problemas recurrentes (validación de formularios, estados
vacíos, navegación, tablas de datos, paginación, filtros). Documenta el patrón,
cuándo aplicarlo y cuándo NO, y enlaza a los componentes que lo materializan.

## 5. Documentación

Cada componente documenta: anatomía, variantes, estados, do/don't, props,
guías de contenido, criterios de accesibilidad, y ejemplos en vivo. La
documentación es producto: si nadie la entiende o encuentra, el sistema falla.

## 6. Gobernanza

- **Modelo operativo**: centralizado, federado o híbrido (elige por tamaño y
  madurez de la organización).
- **Proceso de contribución**: cómo se propone, revisa, aprueba e integra un
  cambio o componente nuevo; criterios de promoción (de "experimental" a
  "estable" a "deprecado").
- **Versionado semántico** y changelog; comunica breaking changes y rutas de
  migración.
- **Adopción**: mide qué % de la UI usa el sistema; reduce divergencias.
- **Deuda y deprecación**: marca, comunica y retira componentes obsoletos con
  plan de migración.

## 7. Theming y escalabilidad

- **Theming** vía tokens semánticos: claro/oscuro, alto contraste, multimarca,
  densidad (compacta/cómoda), localización (RTL incluido).
- **Multi-producto / multi-plataforma**: coherencia de marca y comportamiento
  entre apps y canales, respetando idioms nativos donde corresponde.
- Diseña para el cambio: un token bien definido permite re-themear todo el
  ecosistema sin tocar componentes.

## 8. Métricas de salud del sistema

Adopción (% de uso), cobertura (componentes vs necesidades reales),
consistencia (divergencias detectadas), velocidad (time-to-ship de UI),
satisfacción del equipo consumidor, deuda (componentes deprecados pendientes).

## 9. Entregables

- Inventario de tokens (3 niveles) y nomenclatura.
- Biblioteca de componentes con variantes/estados y specs de accesibilidad.
- Catálogo de patrones con guías de uso.
- Sitio de documentación.
- Modelo de gobernanza + proceso de contribución + política de versionado.

> Sin gobernanza, un design system se degrada hasta volverse otra fuente de
> inconsistencia. El sistema vive en el proceso, no solo en los archivos.
