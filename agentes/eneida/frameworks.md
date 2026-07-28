# Marcos de referencia — Arquitectura, Datos y Algoritmos

Base de conocimiento de Eneida (Primer Maestro). Aplica el marco adecuado al problema;
no apliques todos a la fuerza.

---

## 1. AWS Well-Architected Framework (6 pilares)

Estándar de facto para evaluar y mejorar cargas de trabajo en la nube. Usa el
patrón de "preguntas por pilar" para auditar un diseño.

1. **Excelencia operativa** — operar, observar y mejorar de forma continua;
   automatizar cambios y respuesta a eventos.
2. **Seguridad** — proteger datos, sistemas y activos; identidad, menor
   privilegio, detección y respuesta.
3. **Fiabilidad** — la carga cumple su función correctamente y se recupera de
   fallos; diseño distribuido, recuperación, adaptación a la demanda.
4. **Eficiencia del rendimiento** — usar recursos de forma eficiente y mantener
   la eficiencia al evolucionar demanda y tecnología.
5. **Optimización de costos** — entregar valor al menor precio; eliminar gasto
   innecesario.
6. **Sostenibilidad** — minimizar el impacto ambiental y maximizar el uso de
   recursos provisionados.

> Trade-offs: en dev puedes sacrificar fiabilidad por costo; en misión crítica
> priorizas fiabilidad aceptando más costo. **Seguridad y excelencia operativa
> no se sacrifican** frente a los demás pilares.

---

## 2. Azure Well-Architected Framework (5 pilares + madurez)

Pilares: **Fiabilidad, Seguridad, Optimización de Costos, Excelencia Operativa,
Eficiencia del Rendimiento**. Cada pilar incluye: principios de diseño,
checklists, trade-offs y patrones, además de un **modelo de madurez de 5
niveles** para evaluar el estado y trazar mejoras incrementales.

Úsalo en ecosistema Microsoft o como segunda lente de revisión.

---

## 2.b GCP Architecture Framework / Well-Architected (6 pilares)

Lente de Google Cloud para evaluar cargas de trabajo. Pilares: **Excelencia
operativa, Seguridad y privacidad/cumplimiento, Fiabilidad, Optimización de
costos, Optimización del rendimiento y, transversalmente, Diseño centrado en
IA/ML**. Mismo uso que AWS/Azure: preguntas por pilar para auditar un diseño.

> Las tres nubes convergen en los mismos pilares (fiabilidad, seguridad, costo,
> rendimiento, operación). **Elige la lente del proveedor del cliente** o usa una
> como segunda revisión cruzada; no asumas un proveedor por defecto
> (neutralidad tecnológica).

---

## 2.c ATAM — Architecture Tradeoff Analysis Method (SEI)

Método para **evaluar arquitecturas frente a atributos de calidad** y exponer
trade-offs antes de comprometer la decisión. Pasos esenciales:

1. Presentar **drivers de negocio** y la arquitectura propuesta.
2. Construir un **árbol de utilidad** (utility tree): atributos de calidad →
   escenarios concretos, priorizados por (importancia × dificultad).
3. Analizar cada escenario contra los enfoques arquitectónicos e identificar:
   - **Puntos de sensibilidad**: decisiones que afectan mucho a un atributo.
   - **Puntos de trade-off**: decisiones que afectan a varios atributos en
     direcciones opuestas (p. ej. caché mejora latencia pero complica
     consistencia).
   - **Riesgos** y **no-riesgos**.
4. Entregar: riesgos priorizados, trade-offs explícitos y temas a vigilar.

> Usa ATAM para **fundamentar la matriz de trade-offs** (`plantillas.md §2`):
> los criterios y pesos salen del árbol de utilidad, no de la intuición.

---

## 3. Google SRE + DORA (fiabilidad y entrega)

**SRE (Site Reliability Engineering):**
- **SLI** (indicador), **SLO** (objetivo) y **error budget** (presupuesto de
  error): si gastas el presupuesto, congelas features y priorizas fiabilidad.
- **Eliminar toil** (trabajo manual repetitivo) con automatización.
- **Blameless postmortems**: aprender del fallo sin culpar.

**DORA — 5 métricas (throughput + estabilidad):**

Throughput:
1. **Frecuencia de despliegue** — cuán seguido se despliega a producción.
2. **Lead time for changes** — de commit a producción.
3. **Failed deployment recovery time** — tiempo de recuperación tras fallo.

Estabilidad:
4. **Change failure rate** — % de despliegues que provocan fallo/rollback.
5. **Deployment rework rate** — % de despliegues no planificados por incidentes.

> Alta performance no intercambia velocidad por estabilidad: las buenas
> prácticas mejoran ambas. La IA amplifica fortalezas y debilidades existentes;
> exige plataformas internas sólidas.

---

## 4. NASA/JPL — The Power of 10 (código crítico)

Reglas de Gerard Holzmann para código fiable y verificable estáticamente.
Aplícalas literalmente en sistemas de misión crítica; como guía general en el
resto:

1. Flujo de control simple: sin `goto`, `setjmp/longjmp` ni recursión.
2. Todo bucle con cota superior fija demostrable estáticamente.
3. Sin asignación dinámica de memoria tras la inicialización.
4. Funciones cortas (≈ ≤60 líneas; una pantalla).
5. ≥2 aserciones por función en promedio (sin efectos secundarios).
6. Declarar datos en el menor ámbito posible.
7. Verificar todos los valores de retorno no-void y validar todos los parámetros.
8. Preprocesador limitado a includes y macros simples.
9. Limitar punteros a una indirección; evitar punteros a función.
10. Compilar con todos los warnings al máximo y pasar análisis estático diario
    con cero advertencias.

---

## 5. Domain-Driven Design (DDD)

Para dominios complejos:
- **Lenguaje ubicuo** compartido por negocio y desarrollo.
- **Bounded Contexts** y **Context Map** (límites explícitos del modelo).
- Táctico: **Entidades, Value Objects, Agregados (raíz), Repositorios,
  Domain Services, Domain Events**.
- **Event Storming** para descubrir el dominio y los eventos.
- Alinea bounded contexts ↔ microservicios ↔ equipos (Conway).

---

## 6. Team Topologies (organización ↔ arquitectura)

4 tipos de equipo: **Stream-aligned, Platform, Enabling, Complicated-subsystem**.
3 modos de interacción: **Collaboration, X-as-a-Service, Facilitating**.
Objetivo: **minimizar la carga cognitiva** del equipo y alinear límites de
software con límites de equipos (Ley de Conway / "Inverse Conway Maneuver").

---

## 7. 12-Factor App (cloud-native)

Codebase única ⋅ dependencias declaradas ⋅ config en el entorno ⋅ backing
services como recursos adjuntos ⋅ build/release/run separados ⋅ procesos
stateless ⋅ port binding ⋅ concurrencia por procesos ⋅ desechabilidad ⋅
dev/prod paridad ⋅ logs como flujo de eventos ⋅ admin como procesos puntuales.

---

## 8. Documentación: C4 Model + arc42 + ADR

- **C4**: cuatro niveles de zoom — **Contexto → Contenedores → Componentes →
  Código**. Comunica a distintas audiencias con el nivel adecuado.
- **arc42**: plantilla de 12 secciones para documentar arquitectura completa.
- **ADR**: un registro por decisión relevante (ver `plantillas.md`).

---

## 9. Patrones de arquitectura (catálogo de decisión)

| Patrón | Úsalo cuando | Cuidado con |
|--------|--------------|-------------|
| Monolito modular | Equipo pequeño, dominio en exploración, time-to-market | Acoplamiento si no hay módulos claros |
| Microservicios | Escala independiente, equipos múltiples, límites claros | Complejidad operativa, datos distribuidos |
| Event-driven / EDA | Desacople, picos, integración asíncrona | Consistencia eventual, depuración |
| CQRS + Event Sourcing | Lecturas/escrituras muy distintas, auditoría | Sobre-ingeniería en dominios simples |
| Serverless | Cargas variables, ops mínima | Cold start, límites, lock-in |
| Hexagonal / Clean | Aislar dominio de infraestructura | Boilerplate si el dominio es trivial |
| Strangler Fig | Migrar legacy incrementalmente | Doble mantenimiento temporal |

Regla: **empieza por el monolito modular bien diseñado** y extrae servicios
cuando el dolor (escala/equipo/despliegue) lo justifique.

---

## 10. Estructuras de datos, algoritmos y persistencia

El diseño correcto de datos suele importar más que el de código. El detalle vive
en **`fundamentos-ingenieria.md`** (§1 estructuras/Big-O, §3 transacciones/
consistencia/CAP-PACELC); resumen de selección de almacén persistente:

| Tipo de almacén | Úsalo para | Cuidado con |
|-----------------|-----------|-------------|
| Relacional (ACID) | Integridad, joins, transacciones | Escala de escritura, esquema rígido |
| Documental | Agregados flexibles, evolución rápida | Consultas cruzadas, duplicación |
| Clave-valor | Latencia, caché, sesiones | Consultas complejas |
| Columnar | Analítica/OLAP | Escritura fila a fila |
| Grafo | Relaciones/rutas | Volumen masivo plano |
| Serie temporal | Métricas/IoT | Actualizaciones arbitrarias |
| Búsqueda (full-text) | Texto/relevancia | Como fuente de verdad |

Regla: diseña por **patrones de consulta**, no solo por entidades. Para
plataforma de datos analítica (warehouse/lakehouse, ETL/ELT, streaming,
gobernanza) ver **`dominios-transversales.md §2`**.

---

## 11. Cómo auditar una arquitectura (mini-procedimiento)

> Para el alcance completo de **auditoría / due diligence** por dimensiones y su
> entregable, ver `modernizacion-y-auditorias.md §7`. Procedimiento corto:

1. Define los **atributos de calidad** prioritarios del sistema.
2. Recorre los **pilares WAF** (AWS o Azure) con preguntas por pilar.
3. Mide **DORA + SLO**: ¿hay datos? ¿cumplen objetivos?
4. Revisa **límites** (DDD/Team Topologies): ¿coinciden con equipos?
5. Identifica **riesgos** y **deuda técnica**; prioriza por impacto × probabilidad.
6. Entrega hallazgos como informe + ADRs de cambios propuestos.

---

## 12. Referencias (fuentes primarias)

- AWS Well-Architected: https://aws.amazon.com/architecture/well-architected/
- Azure Well-Architected: https://learn.microsoft.com/azure/well-architected/
- GCP Architecture Framework: https://cloud.google.com/architecture/framework
- ATAM (SEI): https://www.sei.cmu.edu/library/architecture-tradeoff-analysis-method-collection/
- Zero Trust (NIST SP 800-207): https://csrc.nist.gov/pubs/sp/800/207/final (detalle en `seguridad-confiabilidad.md §1.b`)
- Google SRE Books: https://sre.google/books/
- DORA / State of DevOps: https://dora.dev/
- NASA/JPL Power of 10 (Holzmann): https://spinroot.com/gerard/pdf/P10.pdf
- DDD (Evans) y patrones: https://martinfowler.com/tags/domain%20driven%20design.html
- Team Topologies: https://teamtopologies.com/
- 12-Factor App: https://12factor.net/
- C4 Model: https://c4model.com/
- arc42: https://arc42.org/
- ADR (Nygard): https://adr.github.io/
