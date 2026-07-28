# documentacion-producto-fisico.md — Producto físico, hardware y no-software

> La documentación no siempre describe software. Hardware, maquinaria, dispositivos,
> productos de consumo, instalaciones y procesos industriales tienen su **propia
> craft** documental, con estándares y riesgos distintos (a menudo de **seguridad
> física**). Este archivo cierra el sesgo "solo dev-docs" y hace a docpower **global
> de verdad**.
>
> **Frontera:** la **verdad de ingeniería** (cómo funciona/se ensambla/se mantiene el
> producto físico) es del **SME** (ingeniería de hardware/mecánica/eléctrica —en el
> equipo, cercano a **eneida** o al especialista del dominio). La **obligación de
> seguridad y etiquetado normado** la valida **sello**/legal. docpower es
> dueño de la **forma, estructura, estándar y usabilidad** del documento, no del
> diseño del producto ni del veredicto de seguridad.

---

## 1. Qué cambia respecto a la documentación de software

| Dimensión | Software | Producto físico |
|---|---|---|
| Fuente de verdad | Código, spec, API | Planos, BOM, diseño mecánico/eléctrico, el objeto real |
| Actualización | Continua (docs-as-code) | Por revisión de ingeniería / cambio de parte (ECO) |
| Entregable | Web/Markdown | Manual (PDF/print), etiqueta, panel, tarjeta, embebido en firmware |
| Riesgo si falla | Error, incidente | **Daño físico, lesión, muerte** → seguridad normada |
| Visual | Opcional | **Esencial** (despieces, diagramas de montaje, símbolos) |
| Estándar | Diátaxis, style guides | IEC 82079-1, ANSI Z535, ISO 3864/7010, S1000D, IPC |

La disciplina de fondo (plain language, minimalismo, orientación a tareas, Diátaxis)
**sigue aplicando**; cambian el medio, los estándares y el peso de lo visual y de la
seguridad.

---

## 2. Tipos de documento de producto físico

- **IOM (Installation, Operation, Maintenance)** — manual de instalación, operación y
  mantenimiento. El caballo de batalla del producto físico/industrial.
- **Instrucciones de uso (IFU)** — cómo usar el producto de forma segura y efectiva;
  obligatorias y normadas en muchos sectores (ver §5).
- **Guía de montaje / ensamblaje** — visual, paso a paso, estilo "IKEA": mínimo texto,
  máxima claridad de diagrama, independiente del idioma cuando se puede.
- **Catálogo de partes ilustrado (IPC / despiece)** — vistas explosionadas con
  números de parte para pedido y servicio.
- **Manual de servicio / reparación** — para técnicos: diagnóstico, procedimientos,
  torques, tolerancias, herramientas.
- **Manual de mantenimiento preventivo** — tareas, frecuencias, checklists.
- **Quick start / guía rápida** — tarjeta o plegable de primer uso.
- **Etiquetas y paneles** — de seguridad, de datos técnicos, de conformidad.
- **Documentación de campo** — para field service/técnicos en sitio.

---

## 3. Comunicación visual (aquí es núcleo, no adorno)

- **El diagrama a menudo vence a la prosa**: un despiece o una secuencia de montaje
  comunica mejor que un párrafo. Diseña el visual como contenido primario.
- **Vistas explosionadas, cortes, callouts numerados** ligados a la lista de partes.
- **Instrucciones visuales language-independent** cuando sea posible (reduce coste de
  localización y de error).
- **Consistencia de convenciones**: mismos símbolos, colores y numeración en todo el
  set. Ver también comunicación visual general en [technical-writing.md](technical-writing.md).
- Los diagramas técnicos deben mantenerse **versionados y regenerables** (fuente CAD/
  vector), no capturas sueltas que caducan.

---

## 4. Etiquetado y warnings de seguridad (crítico y normado)

Cuando un mal entendido puede causar **lesión física**, el warning deja de ser estilo
y pasa a ser **cumplimiento**:

- **ANSI Z535 / ISO 3864 / ISO 7010** — sistema de señales de seguridad: palabra-señal
  (PELIGRO / ADVERTENCIA / PRECAUCIÓN / AVISO), color, pictograma, y estructura
  *tipo-de-peligro → consecuencia → cómo evitarlo*.
- **Jerarquía de severidad** aplicada con rigor (no "todo es PELIGRO").
- **Colocación**: el warning va **donde y cuando** ocurre el riesgo (en el producto,
  en el paso, antes de la acción), no enterrado al final.
- **Símbolos estandarizados** por encima del texto (funcionan sin idioma y para baja
  alfabetización).
- **Frontera:** *qué* warning es legalmente obligatorio y su redacción normada la
  valida el SME de seguridad/cumplimiento (**sello**/legal); docpower asegura
  que estén **presentes, bien estructurados, visibles y consistentes**. docpower **no
  declara** conformidad de seguridad.

---

## 5. Estándares e instrucciones de uso normadas

- **IEC/IEEE 82079-1** — principio rector de "preparación de instrucciones de uso"
  para cualquier producto: qué información, para quién, cómo estructurarla y evaluarla.
- **S1000D** — documentación técnica modular en aeroespacial/defensa/transporte
  (data modules reutilizables, publicación multi-canal).
- **DITA / topic-based** — reuse a gran escala y publicación multi-salida
  (ver [frameworks-estandares.md](frameworks-estandares.md)).
- **Instrucciones reguladas por sector** (p. ej. dispositivos, maquinaria, consumo):
  el marco lo fija el regulador del dominio; docpower aplica el mecanismo y el SME de
  cumplimiento aporta la obligación (ver [documentacion-regulada.md](documentacion-regulada.md)).

---

## 6. Producción, versionado y traducción de producto físico

- **Print + PDF accesible (PDF/UA)** además de digital; el mismo contenido puede tener
  que salir a varios medios (single-sourcing, DITA/S1000D ayudan).
- **Versionado atado a la revisión de ingeniería / número de parte**, no a un release
  de software: un cambio de parte (ECO) puede invalidar un manual.
- **Localización crítica y a menudo obligatoria** (un manual de seguridad mal traducido
  es un riesgo legal): aplica todo [accesibilidad-i18n.md](accesibilidad-i18n.md), con
  peso extra en símbolos language-independent y en la fidelidad de los warnings.
- **Trazabilidad**: qué versión del manual acompañó a qué lote/serie del producto
  (empalma con evidencia/registro en [documentacion-regulada.md](documentacion-regulada.md)).

---

## 7. Software embebido / firmware / IoT (el puente)

Productos con hardware **y** software (IoT, dispositivos con firmware) necesitan
**ambas** disciplinas: docs de la API/config (ver [api-developer-docs.md](api-developer-docs.md),
[docs-as-code.md](docs-as-code.md)) **y** manuales físicos (este archivo). docpower
integra los dos mundos en un solo sistema documental coherente, sin duplicar la verdad.

---

## 8. Antipatrones (prohibidos)

- Tratar un manual de seguridad como "documentación bonita" y no como control de riesgo.
- Warnings genéricos, mal ubicados o sin jerarquía de severidad.
- Despieces desligados de la lista de partes; capturas/diagramas no versionados.
- Depender del texto donde un símbolo estandarizado comunica mejor y sin idioma.
- Versionar el manual por fecha en vez de por revisión de ingeniería / parte.
- Que docpower **declare** conformidad de seguridad (eso es del SME de cumplimiento).
- Asumir docs-as-code/Markdown donde el entregable real es print/PDF normado.

> Para el andamiaje común (Diátaxis, gobernanza, métricas, i18n, regulado) este
> archivo se apoya en el resto del skill; aquí solo está **lo específico de lo físico**.
