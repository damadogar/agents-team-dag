# Remediación y corrección — Destroyer

El cierre del trabajo. Destroyer **no reporta y se va**: entrega el **fix
concreto**, ataca la **causa raíz** y **verifica el cierre con retest**. Un
hallazgo sin remediación validada está **abierto**.

---

## 1. Principios de remediación
1. **Causa raíz, no síntoma.** Pregunta los 5 *por qué*; corrige la falla
   subyacente y, cuando aplique, **toda la clase** del bug (variant analysis).
2. **Fix correcto > fix rápido.** El parche no debe introducir nueva debilidad ni
   romper funcionalidad; valida ambos.
3. **Defensa en profundidad.** Si el fix primario falla, que haya una segunda capa.
4. **Control compensatorio** cuando no se puede remediar ya (con dueño, alcance y
   **vencimiento**); nunca dejar el riesgo "aceptado" en silencio.
5. **Verificación obligatoria (retest).** Reproduce el ataque tras el fix: si ya no
   funciona y no hay regresión, **recién entonces** se cierra.
6. **Sin regresión de seguridad:** añade prueba automatizada que impida que el bug
   vuelva (test de seguridad como contrato).

---

## 2. Flujo de cierre de un hallazgo
```
1. Confirmar y reproducir (con evidencia y alcance)
2. Causa raíz (5 porqués) + ¿hay más instancias de la misma clase?
3. Diseñar el fix (código/config/control/parche/refactor) + alternativas/trade-offs
4. Mitigación temporal si el fix definitivo tarda (compensatorio con vencimiento)
5. Implementar (o entregar diff/PR/IaC/regla listos para aplicar)
6. RETEST: reproducir el ataque → debe fallar; verificar no-regresión funcional
7. Añadir prueba automatizada anti-regresión + detección si aplica
8. Cerrar con evidencia del retest + riesgo residual declarado
```

---

## 3. Remediación por clase de hallazgo (fix de raíz)

| Clase | Fix de raíz (no parche superficial) | Verificación |
|---|---|---|
| **Inyección (SQL/NoSQL/OS/LDAP)** | Consultas parametrizadas/ORM seguro, *allowlist* de entrada, mínimo privilegio de la cuenta de BD | Reintentar payloads; revisar que no haya concatenación dinámica |
| **XSS** | Output encoding contextual + CSP + framework que escapa por defecto; sanitizar HTML con librería robusta | Probar vectores reflejado/almacenado/DOM; validar CSP |
| **Broken Access Control / IDOR / BOLA** | Authz **server-side por objeto y por tenant**; no confiar en IDs del cliente; *deny by default* | Pruebas de acceso cruzado horizontal/vertical/cross-tenant |
| **Auth / sesión** | MFA, política de credenciales, invalidación/rotación de sesión, anti fuerza bruta/stuffing | Reintentar bypass, fijación, fuerza bruta |
| **SSRF** | Allowlist de destinos, bloqueo de metadata (IMDSv2), sin seguir redirects internos, egress filtering | Probar acceso a metadata/internos |
| **Deserialización / RCE** | No deserializar datos no confiables; *allowlist* de tipos; sandboxing; parchear runtime | Reintentar payload; revisar superficie de deser. |
| **Fallos criptográficos** | Algoritmo vigente + uso correcto (AEAD, IV únicos), llaves en KMS/HSM, rotación (ver [criptografia.md](criptografia.md)) | Revisar config TLS/cifrado, gestión de llaves |
| **Secretos expuestos** | **Rotar** el secreto (no solo borrarlo del repo), mover a gestor, identidades efímeras | Confirmar revocación del secreto viejo |
| **Misconfiguration** | Secure defaults, IaC con política, hardening a línea base, cerrar exposición | Re-escaneo de config/IaC |
| **Dependencia vulnerable (SCA)** | Actualizar/parchear; si no hay fix, mitigar uso o reemplazar; pin por hash | Re-escaneo SCA; verificar versión |
| **Container/K8s** | Non-root, read-only FS, drop caps, PSS restricted, NetworkPolicy deny, secretos en gestor | Re-escaneo + admission control |
| **Cloud IAM amplio** | Mínimo privilegio, eliminar llaves de larga vida, guardrails (SCP/Policy) | Análisis de acceso; reintentar acción indebida |
| **LLM/agente (excessive agency, prompt injection)** | Mínimo privilegio de herramientas, HITL, validación E/S, aislamiento RAG (ver seguridad de IA/LLM -> skill **vector**) | Reintentar inyección directa/indirecta |
| **Base de datos** | Cifrado, RLS/CLS, cuentas mínimas, sin credenciales por defecto, auditoría, parcheo, superficie de red mínima | Revisar privilegios, cifrado, exposición |

---

## 4. Secure code review y refactor seguro
- Lee el código buscando **patrones inseguros** y **ausencia de control**, no solo
  el síntoma reportado.
- Propón el **diff exacto** (o PR) con el fix; explica *por qué* es seguro.
- Refactoriza hacia **APIs seguras por defecto** para que el error no se repita.
- Añade pruebas (unitarias/integración/seguridad) que fijen el comportamiento seguro.

---

## 5. Priorización de la remediación
Por **riesgo real** (CVSS + EPSS + KEV + contexto; ver GRC -> skill **sello**), no por
volumen. Orden típico: explotable + expuesto + activo crítico → primero. Quick wins
de alto impacto antes que el largo plazo estructural, sin perder de vista la causa
raíz sistémica.

---

## 6. Cuando no se puede remediar (aún)
- **Control compensatorio** (WAF virtual patch, segmentación, monitoreo reforzado,
  reducción de exposición) **con vencimiento y dueño**.
- **Excepción de riesgo** documentada y aceptada por el dueño correcto, con fecha
  de revisión. Nunca excepción perpetua silenciosa.
- Declara el **riesgo residual** explícito mientras el fix definitivo llega.

---

## 7. Checklist de cierre de remediación
```
- [ ] Causa raíz identificada (5 porqués) y clase del bug revisada (variants)
- [ ] Fix definitivo implementado o entregado (diff/PR/IaC/regla)
- [ ] El fix no introduce nueva debilidad ni rompe funcionalidad
- [ ] RETEST: el ataque ya NO funciona (evidencia adjunta)
- [ ] Prueba automatizada anti-regresión añadida
- [ ] Detección añadida/ajustada si aplica
- [ ] Compensatorio + vencimiento si el fix definitivo no está aún
- [ ] Riesgo residual declarado; hallazgo cerrado con evidencia
```
