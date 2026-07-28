# Hacking ético y seguridad ofensiva — Cazador

**Piensa, prueba y demuestra como atacante — bajo autorización y para corregir.**
Destroyer es un **hacker ético de espectro completo**: hace recon, enumeración,
análisis de explotabilidad, *chaining* y PoC controlada para **encontrar y
demostrar** vulnerabilidades reales, y luego las **corrige** (ver
remediacion -> skill **destroyer**). Toda actividad ofensiva real se ejecuta **solo
con autorización, alcance y reglas de enfrentamiento** sobre sistemas propios o
permitidos (marco ético-legal en §0 de [SKILL.md](SKILL.md)). Lo que queda fuera es
el daño, la ilegalidad y el malware armado para uso ilícito — no la profundidad
técnica.

> Sin autorización, Destroyer trabaja en modo **diseño/defensa** (threat model,
> revisión, controles) y **gestiona la autorización** como primer paso para
> cualquier prueba activa.

---

## 1. Threat modeling

### 1.1 Proceso (4 preguntas de Shostack)
1. ¿Qué estamos construyendo? → diagrama de flujo de datos (DFD), límites de confianza.
2. ¿Qué puede salir mal? → STRIDE por elemento / árboles de ataque.
3. ¿Qué vamos a hacer? → controles/mitigaciones priorizadas.
4. ¿Lo hicimos bien? → validación, pruebas, revisión continua.

### 1.2 STRIDE (por elemento del DFD)
| Amenaza | Propiedad violada | Ejemplos | Mitigación típica |
|---|---|---|---|
| **S**poofing | Autenticación | Robo de credenciales, suplantación de servicio | MFA, mTLS, identidad fuerte |
| **T**ampering | Integridad | Modificar datos/binarios en tránsito o reposo | Firmas, hashing, WORM, control de acceso |
| **R**epudiation | No repudio | Negar una acción realizada | Logging firmado, trazabilidad |
| **I**nformation disclosure | Confidencialidad | Fuga de datos/PII/secretos | Cifrado, mínimo privilegio, DLP |
| **D**enial of service | Disponibilidad | Agotamiento de recursos | Rate limiting, quotas, autoscale, anti-DDoS |
| **E**levation of privilege | Autorización | Escalar a admin/root | Authz robusta, sandboxing, hardening |

### 1.3 Otros métodos
- **PASTA** (risk-centric, 7 etapas) para alinear amenaza con impacto de negocio.
- **Attack trees** para descomponer un objetivo del atacante en rutas.
- **LINDDUN** para amenazas de **privacidad**.
- **MITRE ATT&CK** para razonar TTPs por fase (ver §3).
- **OWASP Threat Modeling** y *abuser stories* en backlog.

---

## 2. Mapeo de superficie de ataque

Enumera (conceptualmente) y clasifica por confianza:
- **Entradas:** endpoints web/API, formularios, uploads, webhooks, colas,
  parámetros, headers, cookies, deep links, GraphQL, gRPC.
- **Identidades:** humanas (empleados, clientes, terceros) y de máquina (service
  accounts, tokens, llaves, workloads).
- **Dependencias y supply chain:** librerías, imágenes base, acciones de CI,
  paquetes, modelos de IA, proveedores SaaS.
- **Infra y red:** hosts expuestos, puertos, paneles de admin, buckets, metadata
  service, DNS, VPN/ZTNA.
- **Datos:** dónde viven, cómo se acceden, dónde se replican/exportan.
- **IA/LLM:** prompts, herramientas del agente, fuentes RAG, salidas que llegan a
  sistemas con permisos (ver seguridad de IA/LLM -> skill **vector**).

Para cada superficie: ¿quién confía en qué?, ¿qué pasa si esa confianza se rompe?

---

## 3. MITRE ATT&CK + Cyber Kill Chain (razonamiento defensivo)

Usa las fases para razonar **dónde detectar y romper** la cadena, no para atacar:

| Kill Chain | Táctica ATT&CK (ej.) | Defensa / detección a diseñar |
|---|---|---|
| Reconnaissance | Recon | Reducir exposición, monitorear OSINT/escaneos |
| Weaponization/Delivery | Initial Access | Email security, MFA, hardening de exposición |
| Exploitation | Execution | Parcheo, EDR, allowlisting, WAF |
| Installation | Persistence | Monitoreo de autostart/cron/servicios, integridad |
| C2 | Command & Control | Egress filtering, detección de C2/beaconing, DNS |
| Actions on objectives | Exfiltration / Impact | DLP, detección de exfil, backups inmutables, IR |

Mapea tus controles a ATT&CK para encontrar **gaps de cobertura** (qué TTPs no
detectarías hoy) y priorizar detection engineering.

---

## 4. Clases de vulnerabilidad (evaluación conceptual — OWASP)

Razona presencia y mitigación; **no** se entregan exploits.

- **Inyección** (SQL/NoSQL/OS/LDAP): consultas parametrizadas, ORM seguro,
  validación, mínimo privilegio de DB.
- **XSS** (reflejado/almacenado/DOM): output encoding contextual, CSP,
  frameworks que escapan por defecto, sanitización de HTML.
- **CSRF:** tokens anti-CSRF, SameSite cookies, verificación de origen.
- **SSRF:** allowlist de destinos, bloqueo de metadata (IMDSv2), egress
  filtering, sin seguir redirects a internos.
- **IDOR / Broken Access Control:** authz server-side por objeto, no IDs
  predecibles confiables, pruebas de acceso cruzado (incl. cross-tenant).
- **RCE / deserialización insegura:** evitar deserializar datos no confiables,
  *allowlists*, sandboxing, parcheo.
- **Fallos criptográficos:** algoritmos vigentes, gestión de llaves, sin
  *roll-your-own crypto*, TLS correcto, no datos sensibles en claro.
- **Errores de configuración:** secure defaults, hardening, sin credenciales por
  defecto, superficie mínima, headers de seguridad.
- **Autenticación/sesión rotas:** MFA, política de credenciales, rotación/
  invalidación de sesión, protección contra fuerza bruta/credential stuffing.
- **SSRF/secrets/supply chain:** ver DevSecOps -> skill **destroyer**.

Referencia completa: OWASP Top 10, OWASP ASVS (niveles 1-3) y OWASP API Security
Top 10 → [frameworks.md](frameworks.md).

---

## 5. Análisis de rutas de ataque (attack path analysis)

Razona cadenas realistas extremo a extremo, p. ej. (a nivel conceptual):
*phishing → robo de token → acceso a SaaS → pivot a cloud vía federación →
asunción de rol con permisos excesivos → acceso a datos → exfiltración por egreso
abierto.* Por cada eslabón, identifica el **control que lo rompe** y la
**detección** que lo evidencia. El objetivo es **cortar la cadena en varios
puntos** (defensa en profundidad).

---

## 6. Metodología de pentest / hacking ético (ciclo completo, autorizado)

Bajo autorización y RoE, Destroyer ejecuta el ciclo completo y lo deja
reproducible y trazable:

```
1. PRE-ENGAGEMENT: autorización + alcance + RoE + ventanas + exclusiones + contactos
2. RECONOCIMIENTO: OSINT, descubrimiento de activos, superficie (pasivo→activo)
3. ENUMERACIÓN: servicios, versiones, endpoints, usuarios, configuración
4. ANÁLISIS DE VULNERABILIDADES: identificar y PRIORIZAR por explotabilidad real
5. EXPLOTACIÓN (controlada): validar con PoC mínima necesaria para demostrar impacto
6. POST-EXPLOTACIÓN: alcance del impacto (qué se logra), movimiento lateral, datos
   alcanzables — sin causar daño ni tocar lo fuera de alcance
7. CHAINING: combinar fallos en cadenas de impacto realista
8. EVIDENCIA Y REPORTE: hallazgos con prueba, severidad, ruta, impacto de negocio
9. REMEDIACIÓN: fix por hallazgo (ver remediacion.md)
10. RETEST: re-explotar tras el fix → debe fallar; cerrar con evidencia
```

**PoC controlada:** la prueba de concepto usa el **mínimo necesario** para
demostrar el riesgo, sin exfiltrar datos reales, sin degradar el servicio y sin
salir del alcance. No se entrega malware ni exploits armados para uso ilícito; sí
la evidencia y el entendimiento técnico que permiten **corregir**.

## 6 bis. Red Team / Adversary Simulation
Ejercicio dirigido por objetivos que emula un adversario real (no solo busca
vulns):
- **Autorización y scope** firmados (*get-out-of-jail letter*), RoE, *kill switch*.
- **Emulación de adversario** mapeada a ATT&CK; *assume breach* opcional; marcos
  como TIBER-EU/CBEST para sectores regulados.
- **Purple teaming:** colaboración con Blue Team para validar detección y respuesta
  en tiempo real y cerrar gaps (ver §7).
- **Reporte:** narrativa de la operación, rutas, evidencia, detecciones que
  fallaron/funcionaron, recomendaciones y **retest**.

En ejercicios de gran escala o que excedan su alcance autorizado, Destroyer
coordina y dirige; la ejecución sobre producción sensible respeta aprobación y
ventanas (niveles de autonomía en [ejecucion-autonoma.md](ejecucion-autonoma.md)).

---

## 7. Purple teaming

Colaboración ofensiva/defensiva continua: el equipo ofensivo emula TTPs, el
defensivo valida detección y respuesta, y juntos cierran gaps. Entregable:
matriz **TTP → ¿detectado? → ¿respondido? → mejora**. Herramientas conceptuales:
emulación de adversario, atomic tests, validación de controles (BAS). Mide
**cobertura de ATT&CK** y *MTTD/MTTR*.

---

## 8. Entregable de threat model (resumen)

```
Sistema y alcance: ...
DFD + límites de confianza: ...
Activos y su valor: ...
Actores de amenaza (motivación/capacidad): externo oportunista, crimen
  organizado, insider, APT, hacktivista, competidor...
Amenazas por elemento (STRIDE) y rutas (attack trees / ATT&CK): ...
Vectores priorizados (probabilidad × impacto): ...
Mitigaciones por vector (preventivo/detectivo/correctivo): ...
Gaps de detección (ATT&CK) y riesgo residual: ...
```
Plantilla extendida en [plantillas.md](plantillas.md).
