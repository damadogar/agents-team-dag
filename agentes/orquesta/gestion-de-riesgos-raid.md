# Gestión de riesgos (RAID)

orquesta posee el **riesgo de ENTREGA y FLUJO** (cronograma, capacidad, dependencia, coordinación) y **consolida** el registro RAID para todo el programa. NO decide la respuesta técnica, de valor, de seguridad ni de calidad: **rutea** cada riesgo de dominio a su dueño y sostiene la disciplina del registro. Este satélite es neutral de metodología (PMBOK, PRINCE2, ISO 31000, ágil o híbrido) y sirve para greenfield, in-flight y brownfield.

## Qué es un RAID log

RAID es un registro único que unifica cuatro cosas que suelen dispersarse. Al mantenerlas juntas se evita que un supuesto olvidado se convierta en issue sorpresa o que una dependencia sin dueño detenga el flujo.

| Sigla | Qué captura | Estado vivo |
|---|---|---|
| **R — Risks** | Incertidumbres futuras (amenazas u oportunidades) que *podrían* afectar objetivos | Probabilidad > 0, aún no ocurre |
| **A — Assumptions** | Supuestos que se dan por ciertos sin confirmar; si fallan, generan riesgo | Por validar / validado / refutado |
| **I — Issues** | Riesgos ya **materializados** o problemas activos que exigen acción hoy | Abierto / en curso / cerrado |
| **D — Dependencies** | Entregas o insumos que un flujo espera de otro (interno/externo) | Pendiente / comprometida / cumplida |

Un supuesto que se refuta suele **promoverse a riesgo o issue**; un riesgo que ocurre **pasa a issue**. orquesta mantiene esa trazabilidad. Estructura mínima por entrada: ID, descripción, categoría, dueño, fecha, estado, y (para riesgos) probabilidad, impacto, respuesta y disparador.

## Registro de riesgos: identificación

Combinar técnicas para no depender de una sola mirada:

- **Pre-mortem (Klein):** imaginar el proyecto ya fracasado y preguntar "¿por qué falló?". Aflora riesgos que el optimismo oculta. Ideal al inicio de cada fase o gran hito.
- **Checklists y taxonomías:** listas de categorías (cronograma, alcance, técnico, dependencia externa, capacidad, proveedor, regulatorio) para barrido sistemático.
- **Lecciones aprendidas:** revisar retros y post-mortems previos (enlaza a cadencia-y-ceremonias.md y a incidentes-y-coordinacion-de-crisis.md).
- **Entrevistas y talleres** con los dueños de dominio; el riesgo técnico lo nombra eneida, el de valor tompo, etc.

## Análisis: cualitativo y cuantitativo

**Cualitativo** — priorización rápida por Probabilidad × Impacto sobre una **matriz de calor**:

| Prob \ Impacto | Bajo | Medio | Alto |
|---|---|---|---|
| **Alta** | Medio | Alto | Crítico |
| **Media** | Bajo | Medio | Alto |
| **Baja** | Bajo | Bajo | Medio |

**Cuantitativo** — cuando el riesgo justifica números:

- **EMV (Valor Monetario Esperado)** = Probabilidad × Impacto ($ o días). Suma de EMV negativos → base de la reserva de contingencia.
- **Análisis de sensibilidad** (diagrama de tornado): qué variables mueven más el resultado.
- **Simulación Monte Carlo** sobre el cronograma para rangos de fecha con confianza (P50/P80). Ver planificacion-y-cronograma.md para la mecánica de estimación y buffers.

## Estrategias de respuesta

Cada riesgo priorizado recibe **una estrategia, un dueño y un disparador** (condición observable que activa el plan).

| Amenazas | Oportunidades |
|---|---|
| **Evitar** — eliminar la causa (cambiar alcance/enfoque) | **Explotar** — asegurar que ocurra |
| **Mitigar** — reducir probabilidad o impacto | **Mejorar** — aumentar probabilidad o impacto |
| **Transferir** — pasar a un tercero (seguro, contrato, proveedor) | **Compartir** — aliarse con quien mejor la capture |
| **Aceptar** — activa (plan de contingencia + reserva) o pasiva (monitorear) | **Aceptar** — tomarla si aparece |

El **dueño del riesgo** es quien mejor puede actuar sobre él: casi nunca orquesta. orquesta es dueña del *proceso* (que exista respuesta, dueño y seguimiento), no de la *decisión* de respuesta técnica.

## Reservas

| Tipo | Cubre | Quién la gestiona |
|---|---|---|
| **Reserva de contingencia** | Conocidos-desconocidos: riesgos identificados con respuesta | Dentro de la línea base; orquesta la dimensiona con EMV/Monte Carlo sobre impactos aportados por los dueños de dominio |
| **Reserva de gestión** | Desconocidos-desconocidos: lo no anticipado | Fuera de la línea base; la libera el patrocinador/gobierno |

## Gestión de issues (riesgos materializados)

Cuando un riesgo ocurre, se registra como **issue** con severidad, dueño, acción y fecha objetivo. orquesta coordina el escalamiento por **niveles** (equipo → dueño de dominio → gobierno de programa) según impacto en cronograma/alcance. Si el issue es una **crisis operativa o incidente en producción**, se activa el protocolo de incidentes-y-coordinacion-de-crisis.md; el RAID conserva el registro y el seguimiento post-crisis.

## Supuestos y dependencias en el RAID

- **Supuestos:** cada uno con dueño y fecha de validación; un supuesto refutado dispara un riesgo o issue.
- **Dependencias:** el RAID las lista, pero su mapeo, secuenciación y desatasco viven en gestion-de-dependencias.md. Una dependencia externa sin fecha comprometida es, por defecto, un riesgo de flujo.

## Frontera clave: quién evalúa qué riesgo

orquesta **consolida el RAID y rutea**; no absorbe el juicio de dominio.

| Tipo de riesgo | Dueño de la evaluación | Rol de orquesta |
|---|---|---|
| **Entrega / flujo** (cronograma, capacidad, dependencia, coordinación) | **orquesta** | Evalúa y responde |
| **Valor / negocio / producto** | **tompo** | Registra, rutea, refleja impacto en flujo |
| **Técnico / arquitectura / severidad técnica** | **eneida** | Registra, rutea; no decide la respuesta técnica |
| **Plataforma / entrega / confiabilidad (pipeline, SRE)** | **baluarte** | Registra, rutea; coordina impacto de despliegue |
| **Seguridad** | **destroyer** | Registra, rutea; no decide el control |
| **Calidad / defectos** | **amado** | Registra, rutea; refleja riesgo de regresión en flujo |
| **Datos** | **andulfo** | Registra, rutea |

orquesta puede señalar que un riesgo *afecta el flujo* y exigir que tenga dueño y respuesta, pero la **decisión de respuesta** de cada dominio es de su maestro. Ver orquestacion-y-ruteo.md e interoperabilidad-y-aliados.md.

## Cómo cambia por contexto

| Contexto | Perfil de riesgo dominante | Énfasis de orquesta |
|---|---|---|
| **Greenfield** | Alta incertidumbre, muchos supuestos sin validar, estimaciones frágiles | Vigilar supuestos, spikes para reducir incertidumbre, buffers amplios, revisión frecuente |
| **In-flight** | Riesgos emergentes, drift de alcance, dependencias que se mueven | Cadencia de re-evaluación, disparadores activos, escalamiento ágil de issues |
| **Brownfield** | Riesgos heredados: deuda técnica, sistemas legados, conocimiento tribal, dependencias no documentadas | Descubrimiento (arqueología con eneida/certero), registrar deuda como riesgo, validar supuestos ocultos |

## Cadencia del RAID

Revisar el RAID en la cadencia del programa (ver cadencia-y-ceremonias.md): cada entrada activa con dueño, estado y próxima acción. Un RAID sin revisión es un cementerio, no un registro. Los indicadores de exposición agregada alimentan comunicacion-y-reporte.md y gestion-de-programa.md.

## Checklist rápido

```
[ ] ¿Existe un RAID vivo, con dueño de proceso (orquesta) y revisión en cadencia?
[ ] ¿Cada riesgo tiene probabilidad, impacto, estrategia, dueño y disparador?
[ ] ¿Se corrió al menos un pre-mortem al inicio de fase/hito?
[ ] ¿Los riesgos de dominio están ruteados a su maestro (tompo/eneida/baluarte/destroyer/amado/andulfo)?
[ ] ¿Los supuestos tienen dueño y fecha de validación?
[ ] ¿Las dependencias del RAID están sincronizadas con gestion-de-dependencias.md?
[ ] ¿Hay reserva de contingencia dimensionada (EMV) y reserva de gestión definida?
[ ] ¿Los issues tienen severidad, acción y ruta de escalamiento?
[ ] ¿Las crisis/incidentes se derivan a incidentes-y-coordinacion-de-crisis.md?
[ ] ¿La exposición agregada se reporta a gobierno (comunicacion-y-reporte.md)?
[ ] ¿Se ajustó el perfil según greenfield / in-flight / brownfield?
```

## Referencias

- PMI — *PMBOK Guide* y *Practice Standard for Project Risk Management* (identificación, cualitativo/cuantitativo, EMV, reservas, respuestas).
- AXELOS — *PRINCE2*, tema de Riesgo (procedimiento de gestión de riesgo y presupuesto de riesgo).
- ISO 31000 — *Gestión del riesgo. Directrices* (principios, marco y proceso).
- Gary Klein — *Performing a Project Premortem* (Harvard Business Review, 2007).
