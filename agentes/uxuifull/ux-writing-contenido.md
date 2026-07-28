# UX Writing y Content Design

El lenguaje es interfaz. Buen contenido orienta, da confianza, reduce fricción y
convierte. Se **diseña**, no se rellena al final.

## 1. UX Writing vs Content Design

- **UX Writing**: el microcopy concreto (botones, labels, errores, tooltips,
  estados vacíos, onboarding).
- **Content Design** (más amplio): qué contenido necesita el usuario, en qué
  formato, orden y momento, en todo el journey y canales. Empieza por la
  necesidad de información, no por el texto.

## 2. Principios

- **Claridad > ingenio**: el usuario debe entender a la primera. La gracia nunca
  va antes que la comprensión.
- **Conciso**: cada palabra trabaja; elimina relleno ("por favor", "haz clic
  aquí", redundancias).
- **Útil**: dice qué hacer, qué pasó o qué pasará.
- **Centrado en el usuario**: su lenguaje y contexto, no la jerga interna.
- **Consistente**: mismo término para el mismo concepto en todo el producto
  (glosario / terminología controlada).

## 3. Voz y tono

- **Voz**: la personalidad constante de la marca (p. ej. cercana, experta,
  sobria).
- **Tono**: varía según el contexto emocional del momento (un error de pago es
  serio; una felicitación es cálida). Define una matriz contexto→tono.
- Documenta voz y tono en el design system con ejemplos do/don't.

## 4. Microcopy por componente

- **Botones/CTA**: verbo + objeto claro ("Guardar cambios", no "OK");
  específicos, accionables; una acción primaria por vista.
- **Labels de formulario**: visibles (no placeholder como label); claras;
  marca campos requeridos/opcionales.
- **Placeholder**: ejemplo o formato, nunca instrucción crítica ni label.
- **Helper text**: persistente para guiar entradas complejas.
- **Mensajes de error**: causa + cómo resolver, sin culpar, ubicados junto al
  campo. Antipatrón: "Error 400 / entrada inválida". Bien: "El correo necesita
  un @, p. ej. nombre@dominio.com".
- **Estados vacíos**: explican qué es, por qué está vacío y la acción para
  llenarlo (oportunidad de onboarding, no pantalla muerta).
- **Confirmaciones**: claras sobre consecuencias, especialmente en acciones
  destructivas; ofrece deshacer cuando sea posible.
- **Tooltips/ayuda contextual**: breves, oportunos, no críticos para la tarea.
- **Notificaciones/toasts**: relevantes, accionables, no intrusivas.

## 5. Jerarquía y legibilidad del contenido

- **Pirámide invertida**: lo más importante primero.
- **Escaneabilidad**: títulos descriptivos, listas, negritas con criterio,
  párrafos cortos, "front-loading" de la información clave.
- **Plain language**: oraciones cortas, voz activa, evita nominalizaciones y
  tecnicismos; nivel de lectura adecuado a la audiencia.
- **Números y formatos** localizados (fechas, moneda, separadores).

## 6. Internacionalización y localización (i18n/l10n)

- Diseña para **expansión de texto** (alemán +30%, etc.) y para **RTL** (árabe,
  hebreo): layouts que no rompen.
- Evita texto incrustado en imágenes; separa contenido del código.
- No concatenes strings (rompe gramática en otros idiomas); usa variables con
  contexto para traductores.
- Considera diferencias culturales de iconos, colores, formatos y ejemplos.

## 7. Contenido inclusivo y accesible

- Lenguaje claro reduce carga cognitiva (ver [accesibilidad.md](accesibilidad.md)).
- Texto alternativo y enlaces descriptivos ("Ver factura de marzo", no "clic
  aquí").
- Lenguaje inclusivo y respetuoso; evita sesgos y suposiciones.

## 8. Contenido conversacional y con IA

- Para chat/voz/asistentes: define personalidad, manejo de errores
  ("no entendí" con salida), expectativas claras de capacidad, transparencia de
  que es IA, y rutas de escalamiento a humano (ver
  [ux-engineering-avanzado.md](ux-engineering-avanzado.md)).

## 9. Entregables

- Guía de voz y tono (con matriz contexto→tono).
- Glosario / terminología controlada.
- Patrones de microcopy por componente (do/don't) en el design system.
- Modelo de contenido por tipo de página/flujo.
- Guía de i18n/l10n.

> Prueba el copy como pruebas el diseño: con usuarios reales y en contexto. El
> texto que tú entiendes no siempre es el que ellos entienden.
