# documentacion-regulada.md — Documentación como registro y evidencia

> Cuando la documentación no solo **informa** sino que **prueba** que algo se hizo
> conforme a una norma, cambia de naturaleza: pasa a ser un **registro controlado**.
> Este archivo es **neutral de dominio**: el **mecanismo** (documento controlado,
> audit trail, retención, trazabilidad) es **universal** y aplica a **cualquier
> sector con obligación normativa** —finanzas, salud, gobierno, aeroespacial, pharma,
> energía, legal, telecom, alimentos, medio ambiente, seguros, educación, seguridad
> de la información, transporte, y **cualquier otro**—. La lista es **ilustrativa, no
> cerrada**; ningún dominio es el "por defecto".
>
> **Frontera dura:** docpower es dueño de la **forma, estructura, trazabilidad y
> control documental** (que el documento exista, esté versionado, sea auditable y
> completo). La **substancia del control**, su **validez legal** y el **veredicto de
> cumplimiento** son del SME de cumplimiento (**sello** + legal). docpower
> **no dictamina** si algo cumple; asegura que la **evidencia esté bien documentada**
> (ver [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)).

---

## 1. Documento vs registro (records)

- **Documento**: informa/instruye (una guía, un manual). Se actualiza.
- **Registro (record)**: evidencia de que algo ocurrió (un log de aprobación, un
  resultado de prueba firmado, un SOP ejecutado). **No se altera**: se versiona y se
  retiene.
- La documentación regulada suele combinar ambos: SOPs (documento) que generan
  registros (evidencia de ejecución).

---

## 2. Controlled documents (documentos controlados)

Requisitos típicos de un documento controlado (marco-agnóstico, estilo ISO 9001 /
sistemas de gestión de calidad):

- **Identificación única y versión** visibles (ID, versión, fecha, estado).
- **Autor, revisor y aprobador** registrados (quién hizo qué).
- **Control de cambios**: historial de qué cambió, cuándo, por qué y quién lo aprobó.
- **Aprobación antes de vigencia**: no entra en efecto sin sign-off del responsable.
- **Distribución controlada**: quién tiene acceso y a qué versión.
- **Retirada de versiones obsoletas**: nadie debe operar con una versión vencida.

docpower estructura y opera este control (metadata, versionado, workflow de
aprobación en docs-as-code); el **contenido y la aprobación** son del dueño del
proceso/compliance.

---

## 3. Audit trail (rastro de auditoría)

- **Trazabilidad completa**: cada versión, cambio y aprobación queda registrada y es
  recuperable.
- **Inmutabilidad de registros**: los registros no se editan; se corrigen con una
  nueva entrada que referencia la anterior.
- **Reconstruible**: un auditor debe poder responder "qué decía este procedimiento en
  tal fecha y quién lo aprobó". El versionado (Git u otro) habilita esto de forma
  natural — docpower lo aprovecha y documenta la política.

---

## 4. Retención y disposición

- **Política de retención**: cuánto tiempo se conserva cada tipo de registro (lo fija
  la norma/legal, **no** docpower). docpower **documenta y estructura** la política y
  asegura que el archivado la respete.
- **Disposición controlada**: cómo y cuándo se elimina/archiva al vencer la retención,
  con registro de la disposición.
- Conecta con el **sunset/archivado** del ciclo de vida ([gobernanza-documental.md](gobernanza-documental.md) §5),
  pero aquí archivar puede ser **obligatorio**, no opcional.

---

## 5. Trazabilidad hacia requisitos (compliance mapping)

- **Matriz de trazabilidad**: mapea cada requisito normativo/control → el documento o
  evidencia que lo satisface. Muestra cobertura y gaps.
- Útil para auditorías: demuestra que cada obligación tiene su documentación.
- docpower construye y mantiene la **matriz y su forma**; **qué** requisitos aplican y
  si la evidencia es **suficiente** lo determina compliance/legal (SME).

---

## 6. Tipos de documento regulado frecuentes

- **SOPs** (procedimientos operativos estándar) y sus registros de ejecución.
- **Políticas** (seguridad, privacidad, calidad) con versión y aprobación.
- **Runbooks/planes** de respuesta a incidentes con evidencia de ejecución.
- **Reportes de auditoría/control** y sus hallazgos.
- **Instrucciones de uso** reguladas (82079-1) en producto físico/médico.
- **Evidencia de cumplimiento**: mapeos de control, resultados de pruebas, aprobaciones.

Estructura y plantillas (SOP, política, matriz de trazabilidad) en
[plantillas.md](plantillas.md).

---

## 7. Ejemplos de marcos por dominio (sin priorizar ninguno)

docpower reconoce que **cada dominio tiene su norma** y que el **mecanismo documental
es el mismo para todos**; solo cambia *qué* norma aplica —eso lo aporta el SME de
cumplimiento—. Los siguientes son **ejemplos ilustrativos con igual peso, no una
lista cerrada**:

- **Finanzas**: SOX, PCI DSS, normas del regulador financiero local.
- **Salud**: HIPAA, GxP/validación, dispositivos médicos.
- **Privacidad (transversal)**: GDPR, y equivalentes locales de protección de datos.
- **Gobierno/sector público**: normas de gestión documental y de archivo oficiales.
- **Aeroespacial/defensa**: S1000D, DO-178C.
- **Calidad (transversal)**: ISO 9001 (control de documentos y registros).
- **Seguridad de la información (transversal)**: ISO 27001, marcos de controles.
- **Energía/industria/transporte/alimentos/medio ambiente/seguros/educación…**:
  normas sectoriales de seguridad, operación y registro propias de cada uno.
- **Cualquier otro sector con obligación normativa**: mismo mecanismo (documento
  controlado, audit trail, retención, trazabilidad); la norma la define el regulador
  del dominio, no docpower.

> docpower **no asume** un dominio ni un marco por defecto ni trata la lista anterior
> como exhaustiva: pregunta o lo recibe del contexto, aplica el mecanismo universal, y
> colabora con **sello**/legal para la substancia normativa.

---

## 8. Frontera de rol (crítica)

| Aspecto | docpower (forma) | sello + legal (substancia) |
|---|---|---|
| Que el documento **exista, versione y sea auditable** | **A** | I |
| Estructura, trazabilidad, matriz, plantillas de evidencia | **A** | C |
| **Qué** norma aplica y **qué** exige | C | **A** |
| Si la evidencia es **suficiente** para cumplir | I | **A** |
| **Validez legal** / firma / veredicto de auditoría | I | **A** |
| Política de **retención** (el plazo) | C (la documenta) | **A** (la fija) |

Regla: docpower hace que la evidencia esté **bien documentada y sea encontrable**;
**nunca** declara cumplimiento ni sustituye el juicio legal/regulatorio.

---

## 9. Antipatrones (prohibidos)

- Editar un **registro** en vez de corregirlo con nueva entrada trazable.
- Documentos regulados sin versión, aprobador ni control de cambios.
- Operar con versiones obsoletas por no retirar las vencidas.
- Que docpower **declare** que algo "cumple" (eso es de compliance/legal).
- Asumir un marco regulatorio por el nombre del proyecto o del cliente.
- Retención "por si acaso" sin política, o borrado que viola retención obligatoria.
