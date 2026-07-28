# accesibilidad-i18n.md — Accesibilidad y localización (i18n/l10n)

> Documentación **para todos los lectores y en todos los idiomas**. Accesibilidad y
> localización comparten una raíz: el conocimiento debe llegar sin barreras. Es lo
> que hace a docpower verdaderamente **global**.

---

## PARTE A — Accesibilidad (WCAG en documentación)

## 1. Por qué es obligatoria

La accesibilidad no es opcional ni un "extra": es un requisito de calidad (y en
muchos contextos, legal). Documentación accesible es además **más clara para todos**
y **mejor para búsqueda e IA**.

## 2. Prácticas WCAG aplicadas a docs

- **Estructura semántica**: un solo `H1`, jerarquía de headings sin saltos, listas y
  tablas reales (no simuladas con texto). Los lectores de pantalla navegan por ella.
- **Alt text** en toda imagen que aporte significado; texto vacío (`alt=""`) para
  decorativas. **Nunca** metas significado crítico solo en una imagen.
- **Texto de enlace significativo**: "consulta la guía de auth", no "haz clic aquí";
  el enlace debe entenderse fuera de contexto.
- **Contraste** suficiente en diagramas y capturas; no transmitas información **solo
  por color** ("el campo rojo" → añade etiqueta/ícono/texto).
- **Tablas** con encabezados correctos; evita tablas para maquetar.
- **Código** como texto seleccionable, no como imagen.
- **Legibilidad**: frases cortas, plain language, expandir acrónimos (beneficia a
  lectores con discapacidad cognitiva y a no nativos).
- **Media**: transcripción para audio, subtítulos y descripción para video.

## 3. Lenguaje inclusivo

- Términos neutrales y respetuosos; evita metáforas excluyentes o jerga cultural.
- Sustituye terminología técnica con carga (usa las alternativas neutrales
  establecidas: allowlist/blocklist, primary/replica, etc.).
- Consistencia vía usage guide + linter (Vale tiene reglas de inclusividad —
  [docs-as-code.md](docs-as-code.md)).

## 4. Frontera de accesibilidad

- La accesibilidad de la **documentación** (estructura, alt, contraste del contenido
  doc) es de **docpower**.
- La accesibilidad del **producto/UI** (componentes, navegación in-app, WCAG del
  software) es de **uxuifull**; la **obligación legal** la confirma
  **sello/legal**. docpower colabora, no dictamina cumplimiento legal
  (ver [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)).

---

## PARTE B — Localización e internacionalización (i18n / l10n)

## 5. i18n vs l10n

- **Internacionalización (i18n)**: preparar el contenido y el sistema **para poder**
  traducirse (estructura, formato, separación de texto).
- **Localización (l10n)**: adaptar a un **locale** concreto (idioma, región,
  convenciones). Incluye traducir y ajustar ejemplos, unidades, fechas, moneda.

## 6. Escritura "source-for-translation" (el origen bien hecho)

El mayor ahorro de localización se logra en el **texto origen**:

- Frases cortas, una idea por frase, voz activa (más fácil de traducir y con menos
  ambigüedad).
- **Terminología consistente** (la memoria de traducción reutiliza; la
  inconsistencia multiplica costo).
- **Evita** modismos, humor cultural, juegos de palabras y referencias locales.
- **No incrustes texto en imágenes** (no se traduce ni se busca; usa texto + alt).
- Evita concatenar cadenas y asumir orden de palabras; deja espacio para la
  **expansión** (traducciones suelen ser más largas).
- Formatos **neutrales o localizables**: fechas (ISO o con locale), números, unidades,
  moneda; no los hardcodees en el texto.

## 7. Pipeline de localización

- **TMS (Translation Management System)** para gestionar el flujo origen → traducción
  → revisión → publicación.
- **Translation Memory (TM)**: reutiliza traducciones previas; baja costo y sube
  consistencia. Depende de un origen consistente.
- **Glosario/termbase** bilingüe: términos que **no** se traducen o que tienen una
  traducción fija.
- **Pseudo-localización**: prueba con texto expandido/acentuado para detectar
  truncados, cadenas hardcodeadas y layouts que se rompen **antes** de traducir.
- **Sincronización de versiones**: marca el desfase entre el origen y cada idioma;
  un dashboard de **cobertura de traducción** ([metricas-salud.md](metricas-salud.md)).

## 8. Estructura multi-idioma (docs-as-code)

- Carpetas o ramas por locale (`/es`, `/en`, `/pt-BR`), URLs con prefijo de idioma
  estables.
- **RTL** (árabe, hebreo): estructura y estilos que soporten derecha-a-izquierda.
- Selector de idioma claro; fallback explícito cuando una página no está traducida
  (no muestres una página vacía ni mezcles idiomas en silencio).
- Automatiza la detección de páginas **desactualizadas respecto al origen**.

## 9. Frontera de localización

- docpower define la **estrategia, la estructura i18n y la calidad** del contenido
  origen y del proceso.
- La **traducción profesional** (lingüistas/vendor/TMS) es un servicio externo;
  docpower lo integra y controla la calidad, no traduce como fuente de verdad
  lingüística.
- Localización del **producto/UI** (strings de la app) colinda con **uxuifull**
  (microcopy in-app) — docpower cubre la **documentación**, no los strings del
  producto.

---

## 10. Antipatrones (prohibidos)

- Significado crítico atrapado en imágenes (rompe accesibilidad, búsqueda y
  traducción a la vez).
- Texto de enlace "aquí"; headings desordenados; color como único portador de
  información.
- Modismos y referencias culturales en contenido que se traducirá.
- Traducir sobre un origen inconsistente (multiplica costo y errores).
- Publicar idiomas que quedan desincronizados sin marcar el desfase.

> Checklist de accesibilidad y de localización-readiness en [checklists.md](checklists.md).
