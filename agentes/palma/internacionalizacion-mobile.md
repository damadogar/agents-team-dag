# Internacionalización y localización mobile nativa

Internacionalizar (i18n) es preparar la app para adaptarse a idiomas, regiones y convenciones sin recompilar la lógica; localizar (l10n) es producir cada adaptación concreta. En mobile nativo esto NO es el i18n web (catálogos JSON, `Intl`, negociación en el navegador) que gobierna farola: aquí el *plumbing* es del propio sistema operativo —catálogos de recursos compilados, APIs de formato del SO, mirroring de layout gestionado por el framework de UI y ajustes de idioma por app expuestos por la plataforma—. **palma es dueño del i18n TÉCNICO mobile**: recursos, claves, pluralización, formateo locale-aware, RTL y recarga de idioma. El **contenido/copy** y **la estrategia de qué idiomas** son de uxuifull/producto (ver frontera al cierre).

## 1. Catálogos de strings por plataforma

Ningún texto visible se escribe *hardcoded* en la UI: todo sale de un catálogo con clave estable, referenciado desde código/markup mediante la API nativa de resolución de recursos. El SO elige la variante según el locale efectivo en tiempo de ejecución.

| Aspecto | iOS (p. ej.) | Android (p. ej.) |
|---|---|---|
| Formato base | `.strings` / catálogos de strings (`.xcstrings`) | `res/values/strings.xml` |
| Variante por idioma | carpetas `xx.lproj` / entradas por locale en el catálogo | qualifiers `values-xx`, `values-b+xx+YY` (BCP-47) |
| Resolución en código | API de carga de bundle localizado | API de acceso a recursos por id |
| Comentario para traductor | campo *comment* por clave | atributo/comentario asociado a la clave |

Reglas de higiene de claves:

- **Claves semánticas, no literales**: `checkout.button.pay`, no `"Pagar"`. Evita reutilizar una clave en dos contextos con matices distintos: una palabra puede traducirse diferente según dónde aparece.
- **Comentarios para traductores** obligatorios cuando la clave es ambigua (p. ej. "Post" ¿verbo o sustantivo?), incluye longitud máxima esperada o describe la variable interpolada.
- **Namespacing por feature/pantalla** para evitar colisiones y facilitar el corte de archivos por módulo.

```
// Catálogo iOS (.strings)
"cart.item.remove" = "Quitar";           // Botón dentro de la celda del carrito
"cart.summary.total" = "Total: %@";      // %@ = importe ya formateado como moneda

<!-- strings.xml (Android) -->
<string name="cart_item_remove">Quitar</string>
<string name="cart_summary_total">Total: %1$s</string>
```

Usa siempre **argumentos posicionales** (`%1$s`, `%2$@`) en toda cadena con más de una variable: el orden de las palabras cambia entre idiomas y el traductor debe poder reordenar.

## 2. Pluralización y variantes por género/cantidad

Sumar `"s"` a una palabra es un anti-patrón: los idiomas tienen entre 1 y 6 categorías plurales (*zero, one, two, few, many, other* según CLDR). Cada plataforma ofrece un mecanismo declarativo que el SO evalúa por la cantidad y el locale.

| Plataforma | Mecanismo (p. ej.) |
|---|---|
| iOS | `.stringsdict` (o reglas de plural en el String Catalog) con claves CLDR |
| Android | `plurals` (`<plurals>` en `strings.xml`), consumido por la API de cantidad |

```xml
<!-- Android: plurals -->
<plurals name="cart_items_count">
    <item quantity="one">%1$d artículo</item>
    <item quantity="other">%1$d artículos</item>
</plurals>
```

Principios:

- **Nunca** compongas frases plurales concatenando `"%d" + " artículos"`; deja la unidad completa dentro de la regla plural para que idiomas con *few/many* funcionen.
- **Género gramatical**: cuando el texto varía por género (del usuario, de un objeto), modela variantes explícitas (p. ej. dispositivo de *variantes por dispositivo/género* del catálogo iOS, o claves separadas resueltas por lógica). No asumas masculino por defecto.
- **Interpolación segura**: interpola *valores ya formateados* (fecha, moneda) y datos escapados; nunca metas markup crudo de usuario en una plantilla localizada.

## 3. Formateo locale-aware

Fechas, números, monedas y unidades **jamás** se formatean a mano. Se delega en los formateadores del SO, que conocen separadores, posición del símbolo, dígitos, calendario y traducciones de meses/días para cada locale.

| Dato | API nativa (p. ej.) |
|---|---|
| Fecha/hora | formateadores de fecha del SO con *estilo* (short/medium/long) según locale |
| Número | formateador numérico con agrupación y decimales del locale |
| Moneda | formateador de moneda: símbolo, posición y redondeo por locale + código ISO 4217 |
| Unidades / medidas | APIs de medida/unidades con conversión y sistema (métrico/imperial) |
| Cantidades relativas | formateadores "hace 3 min" / "mañana" localizados |

Claves adicionales:

- **Separa locale de idioma**: un usuario puede tener idioma *inglés* con región *Alemania* (fechas y decimales alemanes, textos en inglés). Respeta ambos ejes.
- **Zonas horarias**: guarda instantes en UTC; formatea a la zona del dispositivo (o de negocio) en presentación. Cuida cambios de DST y offsets no enteros.
- **Calendarios**: no todos los locales usan el gregoriano (p. ej. islámico, budista, hebreo). Usa las APIs de calendario del SO, no aritmética de días propia.
- **Sistemas de numeración**: algunos locales presentan dígitos no-latinos; el formateador nativo lo resuelve, la concatenación manual no.

## 4. RTL: layouts en árabe/hebreo

En idiomas de derecha-a-izquierda (RTL) la interfaz se **refleja**: la barra de navegación, el sentido de lectura, los iconos direccionales y el progreso invierten su eje horizontal.

- **Usa *leading/trailing*, nunca *left/right*** en constraints, paddings y alineaciones. El framework de UI mapea *leading* a la derecha en RTL automáticamente. Márgenes codificados como *left*/*right* rompen el mirroring.
- **Iconos direccionales** (flecha atrás, "siguiente", *chevrons*, deshacer): deben espejarse. Marca los que deben voltear y deja fijos los que NO tienen semántica direccional (p. ej. logos, un reloj).
- **Bidi en texto mixto**: nombres, números, URLs o marcas en latín dentro de un párrafo RTL requieren marcas de dirección Unicode / `unicodeBidi` para no desordenarse. Deja que el motor de texto del SO haga el *bidi reordering*; no partas cadenas manualmente.
- **Assets y gestos**: sombras, *swipe* de navegación y animaciones de transición también invierten dirección.
- **Prueba real** con árabe y hebreo: activa el idioma (o pseudo-RTL, §8) y revisa cada pantalla; el mirroring falla justo donde hubo posicionamiento absoluto o *hardcoded left*. Ver [ui-adaptive-y-accesibilidad.md](ui-adaptive-y-accesibilidad.md) para el layout adaptativo subyacente.

## 5. Cambio de idioma y recarga

Hay dos modelos, y conviene soportar ambos con claridad:

1. **Seguir el locale del sistema** (por defecto): la app hereda el idioma/región del dispositivo. Es lo esperado y lo que menos mantenimiento exige.
2. **Selector in-app / per-app language**: el usuario fija un idioma solo para esta app, distinto del sistema. Las plataformas modernas exponen **ajustes de idioma por aplicación** a nivel de SO (iOS y Android recientes), de modo que el selector in-app debe *delegar* en esa API cuando existe, en lugar de mantener un estado paralelo frágil.

Consideraciones técnicas:

- **Recarga dinámica**: al cambiar idioma en caliente, refresca la jerarquía de vistas (recrea pantalla o re-renderiza) para releer catálogos, y **re-lee también formateadores** (fecha/número dependen del locale). No basta con cambiar los textos.
- **Persistencia** del idioma elegido a través de la API de la plataforma, no en almacenamiento propio disperso.
- **Notificaciones push y trabajos en background**: el texto localizado del lado servidor debe usar la preferencia real del usuario; coordina con **`motor`** el envío del locale efectivo al backend (ver [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md)).

## 6. Recursos localizados (no solo texto)

La localización alcanza a todo activo cultural o regional:

- **Imágenes/ilustraciones**: capturas con texto embebido, banderas, gestos o iconografía sensible por cultura se sirven por qualifier de locale igual que los strings.
- **Audio/voz**: prompts de voz, *voiceover* y tonos localizados.
- **Combinación densidad × locale**: un mismo asset puede variar por densidad de pantalla *y* por región; la matriz de qualifiers del SO (densidad, tamaño, locale) resuelve la variante correcta. Mantén *fallbacks* completos para evitar recursos faltantes.
- **Formatos regionales de contenido**: direcciones, teléfonos, nombres (orden apellido/nombre), papel/tallas; modela estos datos con esquemas flexibles, no con supuestos de un solo país.

## 7. Localización de la ficha de tienda

La primera impresión localizada ocurre **antes** de instalar: en la ficha de la tienda. Nombre, subtítulo, descripción, palabras clave, *screenshots* con textos traducidos y previews de video se declaran por idioma en la consola de publicación.

- **Screenshots por idioma**: idealmente generados con capturas localizadas y automatizadas, no editados a mano uno por uno.
- **Palabras clave / ASO por idioma**: la estrategia de qué mercados y qué términos la fija **`tompo`** (producto); palma aporta el *pipeline* técnico de generación y carga.
- **Consistencia idioma app ↔ ficha**: los idiomas soportados por la app y por la ficha deben coincidir para no prometer más de lo que se entrega.

Esto se coordina con el proceso de publicación descrito en [release-engineering-y-tiendas.md](release-engineering-y-tiendas.md), que es dueño del *pipeline* de subida de metadata y binarios.

## 8. Pseudo-localización y testing de i18n

La pseudo-localización sustituye textos por versiones alteradas que exageran los problemas *antes* de tener traducciones reales, y es la red de seguridad barata del i18n:

- **Expansión de texto**: prefijos/sufijos y acentos (`[!!! Ćĥéçķöûţ !!!]`) simulan idiomas ~30-40% más largos (alemán, finés) para detectar **truncamiento** y solapamientos.
- **Detección de *hardcoded strings***: cualquier texto que NO se pseudo-localiza está codificado a fuego; salta a la vista en pantalla.
- **Pseudo-RTL / bidi**: modo que invierte y añade marcas para cazar layouts que no usan *leading/trailing*.
- **Delimitadores** (`[` `]`) revelan cadenas partidas por concatenación (mitad traducida, mitad no).

Testing automatizable:

- **Lint de recursos**: claves faltantes por idioma, duplicados, argumentos posicionales inconsistentes, `%` sin escapar, plurales incompletos.
- **UI/snapshot tests por locale** (incl. el idioma más largo y un RTL) para verificar que nada se corta ni desborda.
- **Pruebas de formateo** parametrizadas por locale para fechas/números/moneda con casos límite (medianoche, cambio de DST, cero, negativos, miles).
- Coordina la estrategia de cobertura de i18n con **`amado`** (dueño de la estrategia de pruebas) como parte del plan de pruebas general.

## Fronteras y modelo tiered

**palma es dueño del i18n TÉCNICO mobile**: catálogos y recursos por plataforma, claves, pluralización, formateo locale-aware con APIs nativas, RTL/mirroring de layout, recarga de idioma, per-app language y el *pipeline* de screenshots/metadata localizados.

- **No es i18n web**: los catálogos web, `Intl`, RTL en CSS y la negociación en navegador son de **farola**. Un producto híbrido puede tener ambos: palma gobierna el shell nativo, farola la superficie web.
- **Contenido y copy** (redacción, tono, microcopy, glosario de marca) → **uxuifull**.
- **Estrategia de idiomas/mercados** y la **traducción como servicio** (TMS, proveedores, *translation memory*) las decide **producto (tompo)**; palma consume las traducciones y garantiza que el *plumbing* las muestre correctamente.

**Greenfield, en construcción y brownfield.**
- **Greenfield:** externaliza cada string y activa pseudo-localización desde el día uno, aunque solo exista un idioma.
- **En construcción:** impón el lint de recursos como *gate* de PR antes de que proliferen *hardcoded strings*.
- **Brownfield:** audita textos codificados a fuego, usos de *left/right*, formateo manual de fechas/números y ausencia de plurales; migra incrementalmente por pantalla priorizando las de mayor tráfico.

**Modelo tiered.** **T1 — palma** ejecuta directo todo lo técnico: estructura de catálogos, reglas de plural, formateadores, RTL, recarga y *pipeline* de ficha localizada. **T2 —** el copy y la traducción se derivan a **uxuifull**, y la estrategia de qué idiomas/mercados a **tompo**; palma no inventa contenido ni decide alcance de idiomas, pero deja el terreno listo para que enchufarlos sea trivial.
