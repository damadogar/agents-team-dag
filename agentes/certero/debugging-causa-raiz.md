# Debugging Científico y Análisis de Causa Raíz

Depurar no es "cambiar cosas hasta que funcione": es **ciencia empírica bajo restricciones de tiempo**. Un bug es un fenómeno observable cuya causa desconocemos; el trabajo consiste en pasar de la ignorancia a una explicación **falsable, verificada y minimal**, y de ahí a un fix que ataque la causa raíz —no el síntoma— sin introducir regresiones. Este documento define el método, las técnicas de reproducción y aislamiento, la bisección, el análisis formal de causa raíz y los antipatrones a evitar. Es el corazón operativo de `certero`: la disciplina que convierte un reporte vago en un diagnóstico defendible.

Frontera de ownership: `certero` es dueño de la **correctitud** —el defecto, su causa y su corrección—. Cuando el diagnóstico revela que la causa raíz pertenece a otra disciplina, `certero` produce la evidencia y hace el handoff, pero **no absorbe** el arreglo: performance→`peakformance`, seguridad→`destroyer`, arquitectura/diseño→`eneida`, datos/persistencia→`andulfo`. La suite de pruebas es de `amado`; `certero` solo escribe el test que **reproduce** el bug y **prueba su propio fix** (ver `pruebas-de-regresion.md`).

---

## 1. El método científico aplicado a bugs

El ciclo es idéntico al de cualquier investigación empírica. La diferencia es la brevedad de las iteraciones y la disponibilidad de instrumentación perfecta: el sistema es observable si sabemos dónde mirar.

| Fase | Pregunta que responde | Salida verificable | Error típico |
|------|----------------------|--------------------|--------------|
| **Observación** | ¿Qué se ve exactamente? | Síntoma preciso: entrada, salida esperada, salida obtenida, contexto | Confundir el reporte del usuario con el hecho |
| **Reproducción** | ¿Puedo provocarlo a voluntad? | Caso mínimo determinista que falla el 100% (o con probabilidad medida) | Asumir reproducción sin confirmarla |
| **Hipótesis** | ¿Qué causa lo explicaría? | Afirmación **falsable** sobre el mecanismo ("X ocurre porque Y") | Hipótesis no comprobables o vagas |
| **Predicción** | Si la hipótesis es cierta, ¿qué más debería observar? | Predicción concreta y discriminante | Predicción que no distingue entre hipótesis |
| **Experimento** | ¿La observación confirma o refuta? | Cambio mínimo y controlado; una variable a la vez | Cambiar varias cosas; no poder atribuir el resultado |
| **Conclusión** | ¿La hipótesis sobrevive? | Causa raíz confirmada, o hipótesis descartada y refinada | Detenerse en la primera coincidencia |
| **Verificación** | ¿El fix elimina el síntoma sin efectos colaterales? | Test que fallaba ahora pasa; suite verde | Declarar victoria sin re-ejecutar el caso original |

Principio rector: **cada acción de debugging debe estar precedida por una hipótesis y una predicción**. Si no puedes decir "espero ver X porque creo Y", no estás depurando; estás adivinando. Una hipótesis solo vale si es **falsable**: debe existir un experimento cuyo resultado pueda refutarla.

---

## 2. Reproducción fiable

Sin reproducción no hay ciencia: no puedes experimentar sobre lo que no puedes provocar. La reproducción es el **primer entregable** de toda investigación seria.

**Minimizar el caso.** Reduce la entrada y el contexto hasta el mínimo que aún dispara el fallo. Cada elemento que puedes eliminar sin que el bug desaparezca es ruido descartado; cada elemento imprescindible es una pista sobre la causa. El caso mínimo es simultáneamente diagnóstico y futuro test de regresión.

**Determinismo.** Fija todo lo que introduce variabilidad: semillas de aleatoriedad, reloj (inyecta el tiempo, no lo leas del sistema), orden de iteración de colecciones no ordenadas, zona horaria y locale, versiones de dependencias, estado inicial de datos. Un bug determinista es un bug que puedes acorralar.

**Control de entorno.** Aísla variables de entorno, configuración, red y sistema de archivos. Un contenedor/entorno reproducible (p. ej. imagen fijada, lockfile de dependencias) elimina el "en mi máquina funciona". Documenta versión exacta de runtime, SO, arquitectura y flags de compilación.

**Bugs intermitentes y heisenbugs.** Cuando el acto de observar altera el fenómeno (un *heisenbug*: cambia al añadir logging, un debugger o al compilar en modo debug), la causa suele ser dependiente del **timing** o del **layout de memoria**: condiciones de carrera, uso de memoria no inicializada, dependencia de orden no garantizado. Estrategia:
- Mide la **tasa de fallo** (p. ej. 3/1000 ejecuciones) para convertir "a veces" en un número y detectar cuándo mejora.
- Usa instrumentación de bajo impacto (logging en anillo/buffer, tracing con muestreo) que perturbe menos el timing.
- Ejecuta en bucle con estrés (carga, contención de CPU, límites de memoria) para **aumentar** la probabilidad del fallo.
- Considera herramientas de detección específicas del ecosistema (p. ej. detectores de data races, sanitizers de memoria, ejecución determinista).
- Si la reproducción sugiere concurrencia, cruza con `concurrencia-y-estado.md`.

**Flakiness.** Un test intermitente es en sí un bug (del test o del sistema). No lo silencies ni lo reintentes ciegamente: eso oculta correctitud real. Clasifica la causa —orden de tests, estado compartido, esperas por tiempo en vez de por condición, dependencia de recursos externos— y arréglala en la raíz.

---

## 3. Bisección: encontrar el punto de cambio

Cuando algo funcionaba y dejó de funcionar (una **regresión**), la pregunta no es "¿qué está mal?" sino "**¿qué cambió?**". La bisección binaria localiza el cambio culpable en tiempo logarítmico.

**Bisección sobre historial.** Con un predicado automático "bueno/malo" y un rango de versiones, la búsqueda binaria sobre el historial (p. ej. `git bisect`, o su equivalente en cualquier VCS) encuentra el commit exacto que introdujo el fallo en ~log₂(N) pasos. Claves:
- Automatiza el predicado (`bisect run` con un script que devuelve éxito/fallo) para eliminar sesgo y error humano.
- Asegura que cada revisión sea **construible y testeable**; marca como "saltar" las que no compilan.
- El resultado no es la causa raíz, sino el cambio que la **reveló**: a veces el commit culpable solo destapó un defecto latente.

**Bisección de causa (no de historial).** El mismo principio aplica a cualquier espacio bisecable: activa/desactiva feature flags por mitades, reduce un dataset de entrada por mitades, elimina la mitad de la configuración. Divide el espacio de posibles causas en dos y determina en cuál vive el fallo.

**Delta debugging (Zeller).** Algoritmo para **minimizar automáticamente** una entrada que falla: dada una entrada grande que produce el bug, elimina fragmentos sistemáticamente (por mitades, luego por complementos) conservando solo lo que sigue provocando el fallo. Converge a una entrada mínima "1-minimal" donde quitar cualquier elemento hace desaparecer el bug. También aplica a bisecar **entre dos configuraciones/entradas** (una que funciona y otra que no) para aislar la diferencia relevante. Pseudocódigo neutral:

```
minimizar(entrada, falla?):
    n = 2
    mientras |entrada| >= 2:
        fragmentos = dividir(entrada, n)
        # ¿algún fragmento por sí solo reproduce?
        si existe f en fragmentos con falla?(f):
            entrada = f; n = 2; continuar
        # ¿algún complemento (todo menos un fragmento) reproduce?
        si existe f con falla?(entrada - f):
            entrada = entrada - f; n = max(n-1, 2); continuar
        si n >= |entrada|: terminar
        n = min(2n, |entrada|)   # aumentar granularidad
    devolver entrada   # 1-minimal
```

---

## 4. Técnicas de aislamiento

**Differential / comparative debugging.** Compara un estado que funciona con uno que falla y minimiza la diferencia. Dos ejes:
- *Temporal*: versión buena vs. mala (→ bisección de historial).
- *Configuracional*: entrada/entorno bueno vs. malo (→ delta debugging entre configuraciones).
Ejecuta ambos en paralelo con la misma instrumentación y compara trazas: el punto donde **divergen** acota la causa.

**Divide y vencerás.** Parte el sistema por sus costuras (capas, módulos, límites de proceso) y determina en qué mitad vive el fallo verificando el estado en la frontera. Repite. Reduce el espacio de búsqueda a la mitad en cada paso.

**Instrumentación selectiva.** Elige la herramienta por su relación señal/perturbación:

| Técnica | Cuándo | Ventaja | Riesgo |
|---------|--------|---------|--------|
| Logs / prints | Flujo y valores en puntos clave; entornos sin debugger | Simple, persistente, apto para intermitentes | Ruido; puede alterar timing |
| Breakpoints interactivos | Estado complejo, exploración local reproducible | Inspección rica, paso a paso | Inútil en heisenbugs/prod; sesga a "mirar sin pensar" |
| Watchpoints / data breakpoints | "¿Quién modifica esta variable/memoria?" | Detecta el escritor culpable de corrupción de estado | Soporte variable según runtime |
| Tracing distribuido | Fallos cruzando servicios/procesos | Correlación causal end-to-end | Requiere instrumentación previa |
| Assertions / invariantes | Detectar estado inválido en el instante en que aparece | Falla cerca de la causa, no del síntoma | Hay que anticipar el invariante |

Regla: **instrumenta según una hipótesis**, no "por si acaso". Añade la mínima observación que discrimine entre las hipótesis vivas.

**Inspección de estado y razonamiento hacia atrás.** Dos direcciones de análisis:
- *Hacia adelante (forward)*: desde la entrada, sigue la ejecución hasta que el estado se vuelve incorrecto. Útil cuando el flujo es corto y conocido.
- *Hacia atrás (backward)*: parte del **fallo observable** (excepción, valor corrupto, aserción rota) y razona en reversa —¿qué pudo producir este estado? ¿de dónde vino este valor?—. Suele ser más eficiente: el fallo es un hecho, la entrada es un espacio. Herramientas de *time-travel/reverse debugging*, cuando existen, materializan este razonamiento.

**Rubber-duck y lectura crítica.** Explicar el código y el fallo en voz alta —a una persona, a un objeto, por escrito— fuerza a verbalizar supuestos, y el error frecuentemente aparece al pronunciar la suposición falsa. Complementa con lectura crítica del código sospechoso **sin ejecutarlo**: muchos bugs se ven antes de reproducirse. Ver `metodologia-revision.md` para la lectura sistemática.

---

## 5. Análisis de causa raíz formal

Reproducir y localizar el punto de fallo da la **causa próxima**. La **causa raíz** es la condición cuya eliminación previene la reincidencia de esta clase de bug. Distínguelas siempre:

- **Síntoma**: lo que se observa (pantalla en blanco, valor erróneo, caída).
- **Causa próxima**: la línea/operación inmediata que produjo el síntoma (desreferencia nula, índice fuera de rango).
- **Causa raíz**: por qué esa condición fue posible (contrato no validado, invariante no garantizado, supuesto de diseño roto).

Arreglar solo la causa próxima (p. ej. añadir un guard nulo) suele ser **enmascarar el síntoma**: el defecto reaparecerá con otra forma.

**5 Whys.** Pregunta "¿por qué?" iterativamente (típicamente ~5 veces) hasta llegar a una causa accionable. Ejemplo:
1. El cálculo dio un resultado erróneo. ¿Por qué? → Se usó un valor nulo como cero.
2. ¿Por qué había un nulo? → El campo no vino en la respuesta.
3. ¿Por qué no vino? → El contrato lo declara opcional pero el consumidor lo asume presente.
4. ¿Por qué se asumió presente? → No hay validación en el borde de entrada.
5. ¿Por qué no hay validación? → No existe un patrón/guard obligatorio para datos externos. ← **causa raíz** (posible handoff a `eneida` si es de diseño de contratos).

Limitación: los "5 Whys" son lineales y sensibles al sesgo del investigador. Para fallos con múltiples factores, usa un modelo ramificado.

**Diagrama de Ishikawa (espina de pescado).** Organiza causas potenciales en categorías (p. ej. entrada/datos, lógica, entorno, dependencias, concurrencia, configuración, contrato de interfaz). Fuerza a considerar familias de causas que un análisis lineal omitiría. Útil en sesiones colaborativas y en bugs sistémicos.

**Fault Tree Analysis (FTA).** Análisis **top-down**: parte del evento no deseado (la raíz del árbol) y descompón las combinaciones de condiciones que pudieron producirlo mediante puertas lógicas (Y/O). Revela cuándo el fallo requiere la **conjunción** de varias condiciones (frecuente en bugs intermitentes y de concurrencia) y ayuda a razonar sobre probabilidad y puntos únicos de fallo. Complementario a los enfoques de `amado` (FMEA/FTA para prevención).

**Causalidad, no correlación.** Una hipótesis solo es causa raíz si **manipularla cambia el resultado**: elimina la causa candidata y el bug desaparece; reintrodúcela y reaparece. La coincidencia temporal ("empezó tras el deploy X") es una pista, no una prueba.

---

## 6. Post-mortem sin culpa (blameless)

Para bugs de impacto (producción, pérdida de datos, incidente), el análisis se documenta en un **post-mortem sin culpa** (estilo Google SRE): el objetivo es el aprendizaje del sistema, no señalar a una persona. Un humano competente actuó con la información y los incentivos que tenía; si el sistema permitió el error, el sistema es lo que se corrige.

Estructura mínima:

| Sección | Contenido |
|---------|-----------|
| **Resumen** | Qué pasó, impacto (alcance, duración, usuarios/datos afectados) en 3-5 líneas |
| **Timeline** | Cronología factual con marcas de tiempo: detección, diagnóstico, mitigación, resolución |
| **Causa raíz** | La condición cuya eliminación previene la reincidencia (no "quién") |
| **Factores contribuyentes** | Condiciones que amplificaron o retrasaron (gaps de observabilidad, alertas ausentes, supuestos) |
| **Detección** | Cómo se detectó y cuánto tardó; ¿pudo detectarse antes? |
| **Acciones de prevención** | Correctivas y preventivas, con dueño y plazo; incluir el **test de regresión** que fallaría hoy |
| **Lecciones** | Qué funcionó, qué no, qué nos sorprendió |

Toda causa raíz de un incidente debe generar al menos una acción que impida su **clase** de fallo, no solo su instancia.

---

## 7. Antipatrones de debugging

| Antipatrón | Síntoma | Corrección |
|------------|---------|------------|
| **Cambiar sin hipótesis** | Tocar código "a ver si arregla" | Formula hipótesis falsable + predicción antes de tocar nada |
| **Shotgun debugging** | Múltiples cambios simultáneos | Una variable a la vez; cambio mínimo aislado |
| **Arreglar el síntoma** | Guard/try-catch que oculta el fallo | Llega a la causa raíz (5 Whys); el guard puede ser válido pero no es el fin |
| **Confiar ciegamente en el debugger** | Pasar horas en breakpoints sin teoría | Alterna con lectura crítica y razonamiento hacia atrás |
| **Programación por coincidencia** | "Funciona y no sé por qué" | No cierres hasta **explicar** por qué el fix funciona |
| **Ignorar lo improbable** | Descartar causas "imposibles" a priori | Sherlock: eliminado lo imposible, lo que queda —por improbable— es la verdad |
| **Fix sin test** | Cerrar sin prueba que reproduzca | Escribe primero el test que falla; ver `pruebas-de-regresion.md` |
| **Reintentar el flaky** | Silenciar intermitencia con reintentos | Trátalo como bug real; diagnostica el timing/estado |
| **Anclaje en la primera pista** | Fijarse en la hipótesis inicial | Mantén hipótesis alternativas vivas hasta refutarlas |

---

## 8. Cuándo parar

- **Éxito verificable**: el caso mínimo que fallaba ahora pasa, sabes **por qué**, la suite completa sigue verde, y existe un test que reproduce el bug y protege el fix.
- **Frontera cruzada**: el diagnóstico prueba que la causa raíz es de otra disciplina (performance, seguridad, arquitectura, datos). Entrega evidencia y haz el handoff; no absorbas el arreglo.
- **Rendimientos decrecientes**: si tras N iteraciones no hay progreso, **cambia de técnica** (de forward a backward, de debugger a bisección, de solo a rubber-duck) o reduce aún más el caso. El estancamiento suele significar un supuesto falso no examinado: lista y verifica cada supuesto ("estoy seguro de que…").
- **Sin reproducción sostenida**: si no puedes reproducir tras esfuerzo serio, documenta lo observado, añade instrumentación dirigida a producción y define el criterio de detección para la próxima aparición. No cierres como "no reproducible" sin dejar rastro.

---

## 9. Técnicas por tipo de bug

| Tipo de bug | Firma | Técnicas prioritarias | Frontera / cruce |
|-------------|-------|------------------------|------------------|
| **Determinista** | Falla el 100% con la misma entrada | Caso mínimo, divide y vencerás, backward reasoning, breakpoints | Núcleo de `certero` |
| **Intermitente / heisenbug** | Falla a veces; cambia al observar | Medir tasa de fallo, estrés en bucle, instrumentación de bajo impacto, sanitizers/detectores de carrera, FTA | Si es carrera/orden → `concurrencia-y-estado.md`; si es contención bajo carga → evidencia a `peakformance` |
| **Regresión** | Antes funcionaba, ahora no | Bisección de historial automatizada, differential debugging | Reproducir el commit culpable; ver `correccion-y-refactor.md` |
| **Corrupción de estado** | Valor válido se vuelve inválido "solo" | Watchpoints/data breakpoints ("quién escribe"), invariantes/assertions, backward reasoning | Si el estado es persistente/BD → evidencia a `andulfo` |
| **Específico de entorno** | Falla en un entorno y no en otro | Control y diff de entorno, lockfiles, differential debugging configuracional, delta debugging entre configs | Si es infra/despliegue → `eneida`/plataforma; documentar versión exacta |
| **De frontera / integración** | Falla al cruzar módulos o servicios | Verificar contrato en la costura, tracing distribuido, divide y vencerás por proceso | Si es diseño de contratos → `eneida` |
| **De datos / entrada** | Falla con ciertos valores | Delta debugging para minimizar la entrada culpable, property-based para hallar el mínimo | Suite exhaustiva es de `amado`; `certero` escribe el test de su fix |

---

Del diagnóstico al arreglo sin dañar lo que funciona: `correccion-y-refactor.md`. De la reproducción al test que blinda el fix: `pruebas-de-regresion.md`. Método general de lectura y revisión que alimenta la formación de hipótesis: `metodologia-revision.md`.
