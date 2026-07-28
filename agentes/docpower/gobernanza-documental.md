# gobernanza-documental.md — Gobernanza, estándar editorial y ciclo de vida

> Cómo docpower hace la documentación **sostenible en el tiempo** (modo E): quién
> es dueño de qué, con qué estándar se escribe, cómo evoluciona y cuándo muere.
> Sin gobernanza, toda documentación caduca en silencio y se vuelve deuda.

---

## 1. Estándar editorial (usage guide ligero)

- **Prioriza las reglas del proyecto** si existen; si no, aplica una guía técnica
  consistente inspirada en las mejores prácticas de style guides de developer docs
  (Google/Microsoft/GitLab — ver [frameworks-estandares.md](frameworks-estandares.md)).
- **No inventes una guía editorial monstruosa desde cero.** Crea un **usage guide
  liviano** que cubra: terminología del dominio, capitalización, nombres de
  producto, voz/tono, formato de código, convenciones de enlaces y excepciones.
- Ante conflicto **rigidez vs claridad → elige claridad**, manteniendo consistencia
  interna.
- **Automatiza el cumplimiento** del estándar con Vale/markdownlint (ver
  [docs-as-code.md](docs-as-code.md)); un estándar que no se valida no se cumple.

---

## 2. Ownership (cada documento con dueño)

Todo documento tiene **propósito, dueño, alcance y criterio de mantenimiento**.

- **Dueño de contenido (SME):** responsable de que el contenido sea **veraz y
  vigente**. Es el especialista del dominio (eneida, motor, tompo, andulfo…).
- **Dueño editorial (docpower):** responsable de la **forma, estructura,
  consistencia y salud** del documento y del sistema.
- Modelo operativo: **SME = fuente de verdad del contenido; docpower = editor-jefe
  del sistema.** Ninguno cubre al otro (ver [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)).
- Registra el ownership en metadata y en CODEOWNERS.

---

## 3. Ciclo de vida del documento

```
draft → in review → approved/published → deprecated → archived
```

- **draft**: en construcción; visible como tal, no citable como verdad.
- **in review**: SME valida contenido; docpower valida forma/QA.
- **approved/published**: canónico; con fecha de última revisión.
- **deprecated**: aún visible pero marcado como obsoleto, con puntero al reemplazo.
- **archived**: fuera de navegación, conservado por historial/cumplimiento.

Cada estado es **visible** para el lector (banner/metadata): nunca dejes que un
documento parezca vigente cuando no lo está.

---

## 4. Review cadence (revisión periódica)

- Cada documento tiene una **fecha de próxima revisión** según su criticidad
  (p. ej. runbooks críticos y docs de seguridad: trimestral; conceptos estables:
  anual).
- **Triggers de revisión por evento**: cambio de producto/API, incidente que reveló
  doc errada, cambio regulatorio, feedback negativo.
- Un dashboard de **frescura** señala lo vencido (ver [metricas-salud.md](metricas-salud.md)).

---

## 5. Sunset / deprecación (matar documentación)

Documentación de más también es deuda: confunde, contradice y diluye la búsqueda.

- **Política de sunset**: criterio para deprecar y archivar (producto retirado,
  versión sin soporte, contenido duplicado/superado).
- Deprecar **con puntero** al reemplazo; nunca borres dejando enlaces rotos (usa
  redirects — ver [docs-as-code.md](docs-as-code.md)).
- Archiva para historial/cumplimiento si aplica retención
  ([documentacion-regulada.md](documentacion-regulada.md)).

---

## 6. Deuda documental (documentation debt)

Trátala como deuda técnica: **hazla visible, priorízala, págala**.

- **Inventario**: qué existe, estado, dueño, frescura, gaps (content inventory).
- **Tipos de deuda**: faltante (gaps), obsoleta, duplicada, inconsistente, no
  encontrable, no accesible, no traducida.
- **Prioriza por riesgo × uso**: lo crítico y muy visitado primero; lo obsoleto que
  induce a error, antes que lo simplemente incompleto.
- Registra la deuda y su plan de remediación como backlog documental (docpower es
  dueño de **este** backlog; no del backlog de producto, que es de tompo).

---

## 7. Quality gates y DoD documental

- **DoD documental**: un cambio de comportamiento no está "done" hasta que su
  documentación está actualizada, revisada y publicada. docpower define y opera este
  gate con el equipo (ver [docs-as-code.md](docs-as-code.md) §8).
- **Gates automáticos** (CI): linting, links, spelling, schema, alt-text, ejemplos
  ejecutables. Bloquean merge si fallan.
- **Gate humano**: revisión editorial (docpower) + revisión de contenido (SME).
- **Publish-readiness checklist** en [checklists.md](checklists.md).

---

## 8. Roles del sistema documental (modelo SME ↔ editor)

| Función | Quién | Responsabilidad |
|---|---|---|
| **SME (fuente de verdad)** | El especialista del dominio | Veracidad y vigencia del contenido técnico |
| **Editor / Doc Engineer** | docpower | Forma, estructura, estándar, QA, salud del sistema |
| **Aprobador** | Dueño del dominio (+ compliance si regulado) | Sign-off de contenido antes de publicar |
| **Contribuidor** | Cualquiera del equipo | Aporta borradores vía PR; docpower eleva |
| **Mantenedor** | Definido por CODEOWNERS | Responde por que el documento siga vigente |

docpower **habilita** a los SME para que documenten bien (plantillas, estándar,
review), en vez de ser el único que escribe: escala el sistema, no se vuelve
cuello de botella.

---

## 9. Governance mínima viable (para greenfield / equipos pequeños)

No impongas burocracia. Lo mínimo que **sí** debe existir desde el día 1:

1. Un **usage guide de una página** (términos, tono, formato de código, enlaces).
2. **Ownership básico** (CODEOWNERS o una tabla de dueños).
3. Una **estructura Diátaxis** en el repo y un hub de entrada.
4. **Gates de CI** mínimos (links + lint).
5. **DoD documental** acordado ("no se cierra el feature sin su doc").

Escala la gobernanza con la madurez (ver modelo de madurez en [metricas-salud.md](metricas-salud.md)).

---

## 10. Antipatrones de gobernanza (prohibidos)

- Documentos sin dueño ni fecha de revisión (caducan invisibles).
- Estándar editorial que nadie valida (queda como decoración).
- Guía editorial gigantesca que frena a los contribuidores.
- Borrar en vez de deprecar (rompe enlaces e historial).
- docpower como **único** escritor (cuello de botella) en vez de habilitador de SMEs.
- Tratar la deuda documental como "algo que haremos cuando haya tiempo".

> Cómo se mide todo esto: [metricas-salud.md](metricas-salud.md). Con quién se
> coordina el ownership: [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md).
