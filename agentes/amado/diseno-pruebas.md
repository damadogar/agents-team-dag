# Diseño de pruebas

Referencia de Amado para el modo **C (Diseño)**. Técnicas formales según
ISO/IEC/IEEE 29119-4, diseño E2E, API y no funcional, y trazabilidad.

---

## 1. Técnicas de diseño basadas en especificación (black-box)

| Técnica | Cuándo usarla | Qué genera |
|---|---|---|
| **Partición de equivalencia** | Entradas con clases que se comportan igual | 1 caso por clase válida/ inválida |
| **Valores límite (BVA)** | Rangos numéricos/fechas/longitudes | min-1, min, min+1, max-1, max, max+1 |
| **Tablas de decisión** | Reglas de negocio con múltiples condiciones | 1 caso por combinación relevante |
| **Transición de estados** | Workflows, máquinas de estado | Transiciones válidas e inválidas |
| **Casos de uso / escenarios** | Flujos de usuario de punta a punta | Camino feliz + alternos + excepción |
| **Pairwise / combinatoria** | Muchos parámetros y combinaciones | Subset que cubre todos los pares |
| **Pruebas de error / negativas** | Robustez ante entradas inválidas | Validaciones, errores controlados |

### Técnicas basadas en estructura (white-box)
Cobertura de sentencias, ramas, condiciones, caminos (MC/DC en sistemas
críticos). Aplica con el equipo de desarrollo sobre la suite unitaria.

### Basadas en experiencia
Exploratoria (con charter y time-box), error guessing, checklists. Complementan,
no sustituyen, el diseño formal.

---

## 2. Anatomía de un caso de prueba

```
ID | Título | Prioridad/Severidad asociada | Precondiciones
Datos de prueba | Pasos (acción → resultado esperado por paso)
Resultado esperado final | Postcondiciones/limpieza
Trazabilidad: Requisito/AC ↔ Riesgo ↔ Caso
Tipo: funcional/no funcional | Nivel | Automatizable: sí/no
```

Buenas prácticas: atómico, determinista, independiente, con datos explícitos,
verificable objetivamente, sin pasos redundantes.

### Gherkin (BDD) para AC testeables
```
Escenario: <nombre>
  Dado <contexto/precondición>
  Cuando <acción del usuario/sistema>
  Entonces <resultado verificable>
```

---

## 3. Diseño de escenarios End-to-End

- Cubre **flujos críticos de negocio** completos (no solo pantallas).
- Camino feliz + caminos alternos + manejo de errores + recuperación.
- Datos y estado realistas; valida efectos secundarios (correos, eventos, BD).
- Prioriza por riesgo: empieza por los flujos que más duelen si fallan.

---

## 4. Diseño de pruebas de API / microservicios

- **Funcional por endpoint:** métodos, status codes, payloads, headers, auth.
- **Validación y errores:** 4xx/5xx, mensajes, idempotencia, paginación, límites.
- **Contract testing:** consumidor/proveedor (p. ej. Pact) para evitar romper
  integraciones; valida contra el esquema OpenAPI/AsyncAPI.
- **Resiliencia:** timeouts, reintentos, circuit breaker, degradación, fallback;
  pruebas de caos donde aplique.
- **Seguridad de API:** authn/authz, IDOR/BOLA, rate limiting, inyección
  (alineado con OWASP API Top 10 — ver `frameworks.md`).
- **Datos y estado:** consistencia, transacciones, eventual consistency.

---

## 5. Pruebas no funcionales

### 5.1 Performance
- **Tipos:** carga (esperada), estrés (hasta romper), pico/spike, soak/estabilidad
  (largo plazo, fugas de memoria), escalabilidad, volumen.
- **Métricas:** latencia p50/p95/p99, throughput, error rate, uso de recursos.
- **Proceso:** definir SLOs → modelar carga realista → ambiente representativo →
  ejecutar → analizar cuellos de botella → recomendar.
- **Herramientas:** k6, JMeter, Gatling, Locust.

### 5.2 Seguridad (DevSecOps)
- SAST/DAST/SCA en pipeline, gestión de secretos, pruebas OWASP Top 10 / ASVS.
- Pruebas de authn/authz, manejo de sesiones, validación de entrada, exposición
  de datos. Ver `frameworks.md`.

### 5.3 Accesibilidad
- WCAG 2.1/2.2 AA: contraste, navegación por teclado, roles ARIA, lectores de
  pantalla, foco visible. Herramientas: axe-core, Lighthouse, pruebas manuales.

### 5.4 Compatibilidad y usabilidad
- Cross-browser/dispositivo/OS, resoluciones, modo oscuro.
- Usabilidad: heurísticas de Nielsen, flujos intuitivos, mensajes claros.

---

## 6. Matriz de cobertura y trazabilidad

Tabla viva que enlaza **Requisito/AC ↔ Riesgo ↔ Caso de prueba ↔ Estado ↔
Defecto**. Permite demostrar cobertura, detectar requisitos sin pruebas y
priorizar. Plantilla en `plantillas.md`.

| Req/AC | Riesgo | Caso(s) | Tipo | Auto | Estado | Defecto |
|---|---|---|---|---|---|---|
| AC-01 | Alto | TC-01, TC-02 | Funcional | Sí | Pass | — |
| AC-02 | Medio | TC-03 | API | Sí | Fail | BUG-12 |
