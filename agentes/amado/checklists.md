# Checklists de calidad

Checklists operativos de Amado. Adapta a la criticidad del sistema.

---

## 1. Entrada a pruebas (entry criteria)

- [ ] Requisitos/AC revisados, claros y **testeables**.
- [ ] Build desplegada en ambiente estable y correcto.
- [ ] Casos de prueba diseñados y revisados.
- [ ] Datos de prueba disponibles, representativos y anonimizados.
- [ ] Accesos, credenciales y configuración listos.
- [ ] **Smoke test** del build en verde.

## 2. Salida de pruebas (exit criteria)

- [ ] 100% de casos críticos/altos ejecutados.
- [ ] Sin defectos abiertos 🔴 Crítico / 🟠 Alto (o aceptados por owner).
- [ ] Cobertura de requisitos acordada alcanzada.
- [ ] Regresión automatizada en verde.
- [ ] No funcional (performance/seguridad/accesibilidad) dentro de umbral.
- [ ] Riesgos residuales documentados y aceptados.
- [ ] Informe de pruebas emitido.

---

## 3. Smoke test (post-deploy)

- [ ] La aplicación carga / responde (health check).
- [ ] Login / autenticación funciona.
- [ ] Flujos vitales accesibles (los 3-5 más críticos).
- [ ] Integraciones clave responden (BD, APIs externas, colas).
- [ ] Sin errores 5xx en el arranque.

## 4. Sanity (post-fix)

- [ ] El defecto corregido ya no se reproduce (re-test).
- [ ] Área directamente afectada sigue funcionando.
- [ ] Sin regresión obvia en flujos vecinos.

## 5. Regresión (selección por riesgo)

- [ ] Áreas tocadas por el cambio.
- [ ] Dependencias e integraciones del área.
- [ ] Flujos críticos de negocio.
- [ ] Zonas con historial de bugs.
- [ ] Subset documentado y justificado.

---

## 6. Readiness de release

- [ ] Criterios de salida cumplidos.
- [ ] Smoke en staging/preprod en verde.
- [ ] Plan de rollback / feature flag definido.
- [ ] Observabilidad y alertas listas para el release.
- [ ] Smoke/synthetic en prod planificado post-deploy.
- [ ] Go/No-Go acordado con stakeholders; riesgos comunicados.

---

## 7. API testing

- [ ] Status codes correctos (2xx/4xx/5xx).
- [ ] Validación de esquema/contrato (OpenAPI).
- [ ] Auth/authz (incluye IDOR/BOLA, roles).
- [ ] Manejo de errores y mensajes.
- [ ] Paginación, filtros, ordenamiento, límites.
- [ ] Idempotencia y concurrencia.
- [ ] Rate limiting / throttling.
- [ ] Tiempos de respuesta dentro de SLO.

---

## 8. Seguridad (verificación funcional QA)

- [ ] Autenticación robusta; sesiones y logout correctos.
- [ ] Autorización por rol; sin escalada de privilegios.
- [ ] Validación/saneamiento de entrada (XSS, inyección).
- [ ] Sin secretos/PII en logs, URLs ni respuestas.
- [ ] Transporte cifrado (TLS); headers de seguridad.
- [ ] SAST/SCA/secretos integrados en pipeline sin hallazgos críticos.

---

## 9. Accesibilidad (WCAG AA)

- [ ] Contraste de color suficiente.
- [ ] Navegación completa por teclado; foco visible.
- [ ] Roles/labels ARIA correctos; lectores de pantalla.
- [ ] Texto alternativo en imágenes.
- [ ] Formularios con labels y mensajes de error accesibles.
- [ ] Escaneo automatizado (axe/Lighthouse) sin violaciones graves.

---

## 10. Performance

- [ ] SLOs definidos (latencia p95/p99, throughput, error rate).
- [ ] Carga modelada de forma realista.
- [ ] Ambiente representativo de producción.
- [ ] Pruebas de carga, estrés y soak ejecutadas.
- [ ] Cuellos de botella identificados y reportados.
- [ ] Sin fugas de memoria/recursos en soak.
