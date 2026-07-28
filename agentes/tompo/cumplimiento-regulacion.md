# cumplimiento-regulacion.md — El PO ante el producto regulado (qué saber, qué exigir, con quién)

> **Para qué sirve este documento.** tompo (Product Owner) trabaja en dominios
> regulados (fintech, salud, e-commerce, govtech, datos personales). Aquí está
> **lo que el PO debe saber** de cada marco, **qué exige como criterio de
> aceptación y de priorización**, y **con quién** lo construye. El cumplimiento
> entra **by design** desde la discovery, no como un parche final.
>
> **Frontera de rol (CRÍTICA).** tompo **NO es el experto legal ni técnico**:
> decide **qué** problema regulado se resuelve, **por qué** y el **riesgo de
> negocio aceptable**, e **incorpora** el cumplimiento como criterio. El
> cumplimiento **técnico/legal** es de **sello + legal**; la **seguridad**
> del cluster **destroyer (núcleo; satélites cazador/centinela/sello/vector)**; la **accesibilidad** la
> implementa **uxuifull/farola**; la **arquitectura** es de **eneida** y los
> **datos** de **andulfo/caudal/brujula/prisma**. tompo **firma el go/no-go de valor**, **no** implementa
> controles. Detalle de RACI y handoffs en
> [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md).

---

## 0. Doctrina del PO en producto regulado

1. **Cumplimiento = restricción de valor, no obstáculo.** Una multa, una brecha o
   un producto inaccesible **destruyen valor**: el riesgo regulatorio es un input
   de priorización (coste de retraso, coste de incumplir), no un trámite.
2. **Privacy/Security/Accessibility by design (Art. 25 GDPR).** Los requisitos no
   funcionales regulados son **criterios de aceptación de la historia**, no épicas
   "para después". Una historia que toca datos personales **no está Ready** sin su
   criterio de privacidad.
3. **El PO no interpreta la ley.** Reformula el requisito de negocio, declara el
   **[SUPUESTO]** regulatorio y lo **valida con sello + legal** antes de
   comprometer alcance. Marca regulación **no final** como tal.
4. **Trazabilidad regulatoria.** Cada obligación se enlaza a una historia, un
   criterio testeable y una evidencia (igual que outcome→historia→métrica).
5. **Gate de release.** Ningún release con superficie de datos personales, pagos,
   salud o accesibilidad sale sin el **sign-off de sello** (cumplimiento) y
   **amado** (calidad). tompo da el go/no-go de **valor**; no el de cumplimiento.
6. **Jurisdicción primero (sin sesgo EU/US).** tompo **identifica la jurisdicción
   aplicable ANTES de fijar criterios de cumplimiento; no asume marcos EU/US por
   defecto** (p. ej., quien opera en Colombia se rige por **Ley 1581/Habeas Data**
   y, en fintech, por la **Superintendencia Financiera de Colombia**, no por
   GDPR/HIPAA). **El detalle legal lo valida sello + legal.**

---

## 1. GDPR — Reglamento General de Protección de Datos (UE 2016/679)

Aplica si tratas datos de personas en la UE (extraterritorial). Lo que el PO debe
conocer y exigir como criterio:

- **Art. 25 — Privacy by design & by default.** Minimización de datos y la opción
  **más protectora por defecto** (no recolectar de más, *opt-in* no *opt-out*).
  *Criterio PO:* "por defecto solo se recolecta el dato estrictamente necesario
  para el JTBD".
- **Art. 6 — Base legal.** Todo tratamiento necesita base (consentimiento, contrato,
  interés legítimo, obligación legal…). *Criterio PO:* cada dato del feature tiene
  base legal **declarada y documentada** antes de construir.
- **Art. 30 — RoPA (Registro de Actividades de Tratamiento).** *Criterio PO:* el
  feature actualiza el RoPA (qué dato, para qué, cuánto tiempo, con quién se
  comparte) — lo mantiene el DPO/sello, tompo lo dispara.
- **Art. 33 — Notificación de brechas en 72 h.** *Criterio PO:* existe un camino de
  detección/escalado; la respuesta a incidentes es de centinela/sello, pero el
  producto **no debe impedirla**.
- **Art. 35 — DPIA (Evaluación de Impacto) para tratamientos de alto riesgo.**
  *Criterio PO:* si el feature es perfilado masivo, datos sensibles o vigilancia,
  se **dispara una DPIA con grc antes** de salir.
- **Derechos del titular (Arts. 12-22):** acceso, rectificación, supresión
  ("derecho al olvido"), portabilidad, oposición. *Criterio PO:* el producto
  **soporta operativamente** ejercer estos derechos.

Fuente: European Data Protection Board (EDPB), https://www.edpb.europa.eu/ .

---

## 2. Habeas Data — Ley 1581 de 2012 (Colombia, SIC)

Contexto **Colombia relevante** (operación local). Régimen general de protección de
datos personales, vigilado por la **Superintendencia de Industria y Comercio (SIC)**.

- **Autorización previa, expresa e informada** del titular antes de tratar el dato
  (Art. 9). *Criterio PO:* no hay tratamiento sin consentimiento capturado y
  auditable; la finalidad se informa de forma clara.
- **Derechos del titular (Art. 8):** conocer, actualizar, rectificar, revocar la
  autorización y solicitar prueba de la misma.
- **Tiempos de respuesta (clave para el diseño del flujo de atención):**
  **consultas ≤ 10 días hábiles**, **reclamos ≤ 15 días hábiles** (prorrogables).
  *Criterio PO:* el producto/proceso permite cumplir estos SLA.
- **Datos sensibles y de menores:** tratamiento restringido y reforzado.
- **Registro Nacional de Bases de Datos (RNBD)** ante la SIC cuando aplica.

Fuente: Superintendencia de Industria y Comercio (SIC),
https://www.sic.gov.co/tema/proteccion-de-datos-personales . tompo incorpora estos
plazos como criterios; **grc + legal** validan la interpretación.

---

## 3. CCPA / CPRA — California (CPPA)

Aplica a negocios que tratan datos de residentes de California por encima de ciertos
umbrales.

- **Derechos:** saber, acceder, **eliminar**, corregir, y **opt-out de venta/
  compartición** de datos personales.
- **Señal GPC (Global Privacy Control):** el producto debe **honrar la señal
  automática** del navegador como opt-out válido. *Criterio PO:* el front respeta
  GPC (lo implementa farola/uxuifull; tompo lo exige).
- **NUEVAS reglas vigentes desde el 1-ene-2026:** entre ellas la **prohibición
  reforzada de *dark patterns*** (interfaces que manipulan el consentimiento). El
  consentimiento debe ser **simétrico** (rechazar tan fácil como aceptar).
  *Criterio PO:* el flujo de consentimiento **no usa patrones oscuros**; es un
  criterio de aceptación de UX revisable.

Fuente: California Privacy Protection Agency (CPPA),
https://cppa.ca.gov/regulations/ . *(Convergente con la prohibición de dark
patterns del CPRA y con la simetría de consentimiento de GDPR.)*

---

## 4. Accesibilidad — WCAG 2.2 (W3C) y European Accessibility Act (EAA)

La accesibilidad es **obligación legal** en muchos mercados y **amplía el mercado**
(personas con discapacidad, contexto situacional). **La implementa uxuifull/farola;
tompo la EXIGE** como criterio.

- **WCAG 2.2 (W3C, recomendación oct-2023).** Objetivo legal habitual: **nivel AA**.
  Criterios nuevos clave para el PO:
  - **Target Size (2.5.8): objetivos táctiles ≥ 24×24 px.**
  - **Accessible Authentication (3.3.8):** no exigir pruebas cognitivas (recordar/
    transcribir) para autenticarse; permitir pegar/gestor de contraseñas.
  - **Focus visible/no obstruido**, ayuda consistente, entrada redundante evitada.
- **European Accessibility Act (Directiva UE 2019/882):** **EN APLICACIÓN desde el
  28-jun-2025**. Obliga a accesibilidad en productos y servicios digitales clave
  (e-commerce, banca, transporte, e-books) en la UE.

*Criterio PO:* "Toda historia con UI cumple WCAG 2.2 AA; los criterios de
accesibilidad relevantes son parte de la DoR/DoD y los verifica amado". tompo
prioriza la accesibilidad como requisito legal y de alcance de mercado, no como
"nice to have".

Fuentes: W3C WCAG 2.2, https://www.w3.org/TR/WCAG22/ ; EAA (UE 2019/882),
https://eur-lex.europa.eu/eli/dir/2019/882/oj .

---

## 5. Seguridad de aplicación — OWASP Top 10:2025

El PO **no diseña controles** (eso es destroyer), pero **conoce los riesgos** para
exigirlos como criterio de aceptación de negocio y priorizarlos.

- **A01 — Broken Access Control (#1):** el riesgo más crítico. *Criterio PO:* cada
  historia define **quién puede ver/hacer qué** (reglas de autorización por rol/
  tenant) como criterio testeable; amado lo prueba, destroyer lo asegura.
- **A03 — Software Supply Chain (cadena de suministro):** dependencias, librerías y
  *build* comprometidos. *Criterio PO:* aceptar el coste de gestión de dependencias
  y SBOM como parte del trabajo (riesgo de viabilidad).
- Otros (inyección, fallos criptográficos, mala configuración): entran como
  *non-functional requirements* que el cluster destroyer posee.

*Postura PO:* la seguridad es **criterio de aceptación y gate de release**, no una
épica opcional. El sign-off técnico es del cluster destroyer.

Fuente: OWASP Top 10:2025, https://owasp.org/Top10/2025/ .

---

## 6. HIPAA — Salud (EE. UU., HHS)

Aplica a información de salud protegida (PHI). El PO en healthtech debe exigir:

- **BAA (Business Associate Agreement):** todo tercero/proveedor que toque PHI
  necesita BAA firmado **antes** de integrarse. *Criterio PO:* "ninguna integración
  con PHI entra sin BAA" — lo gestiona legal/sello, tompo lo bloquea si falta.
- **Salvaguardas** administrativas, físicas y técnicas (control de acceso, auditoría,
  cifrado).
- **NPRM (propuesta de modificación de la Security Rule, ene-2025):** propone hacer
  **obligatorios el cifrado y la MFA**, entre otros. **AÚN NO FINAL** — tratar como
  dirección regulatoria probable, no como requisito vigente. *Criterio PO:* diseñar
  asumiendo cifrado/MFA reduce el riesgo de re-trabajo.

Fuente: U.S. Department of Health and Human Services (HHS),
https://www.hhs.gov/hipaa/ . **[NO FINAL]** marca el NPRM 2025.

---

## 7. PCI DSS v4.0.1 — Pagos con tarjeta

Aplica si el producto procesa, almacena o transmite datos de tarjeta. La mejor
estrategia de negocio suele ser **reducir el alcance** (tokenización, no almacenar
PAN, delegar en pasarela certificada).

- **Requisitos *future-dated* obligatorios desde el 31-mar-2025:** los **51**
  requisitos antes "buenas prácticas" pasaron a ser **exigibles**. Para e-commerce
  destacan los **controles anti-skimming** (integridad de scripts de la página de
  pago, detección de cambios no autorizados — req. 6.4.3 y 11.6.1).
- *Criterio PO:* "el flujo de pago minimiza el alcance PCI y cumple anti-skimming";
  el cumplimiento técnico y la certificación QSA/SAQ son de grc + el adquirente.

Fuente: PCI Security Standards Council, PCI DSS v4.0.1,
https://www.pcisecuritystandards.org/ .

---

## 8. PSD2 SCA — Pagos y banca abierta (EU, EBA)

Aplica a pagos electrónicos y *open banking* en la UE.

- **SCA (Strong Customer Authentication):** **dos factores** independientes
  (conocimiento/posesión/inherencia) + **dynamic linking** (el factor liga importe y
  beneficiario). *Criterio PO:* el checkout aplica SCA cuando corresponde.
- **Exenciones en checkout** (bajo importe, beneficiario de confianza, análisis de
  riesgo de transacción): son **palancas de conversión vs. fricción** que el PO
  prioriza con datos. *Trade-off PO:* menos fricción = más conversión pero más
  responsabilidad de fraude.
- **Open banking:** APIs de acceso a cuentas (AIS/PIS) con consentimiento del cliente.

Fuente: European Banking Authority (EBA), guías sobre SCA y PSD2,
https://www.eba.europa.eu/ . *(PSD3/PSR en proceso legislativo — tratar como
dirección futura, **[NO FINAL]**.)*

---

## 9. Tabla maestra — Regulación → qué exige el PO → quién la implementa

| Regulación | **Jurisdicción / dónde aplica** | Qué exige tompo como **criterio de aceptación / priorización** | Quién lo **implementa / es A técnico** |
|---|---|---|---|
| **GDPR** (Art. 25/6/30/33/35) | **UE/EEE** (y quien trate datos de residentes UE) | Minimización y opt-in por defecto; base legal por dato; disparar RoPA y DPIA; soportar derechos del titular | **sello** (privacidad/DPO) + **legal**; datos: **andulfo/caudal/brujula/prisma**; UI consentimiento: **uxuifull/farola** |
| **Habeas Data / Ley 1581** (SIC) | **Colombia** | Autorización previa/expresa/informada; SLA consultas 10 d / reclamos 15 d; soporte a derechos | **sello** + **legal**; flujo: **uxuifull/motor** |
| **LGPD** (Lei 13.709, ANPD) | **Brasil** (equivalente de GDPR/Ley 1581) | Base legal/consentimiento; finalidad; derechos del titular; encargado/operador | **sello** + **legal**; datos: **andulfo/caudal/brujula/prisma** |
| **CCPA/CPRA** (vigente 1-ene-2026) | **California (EE. UU.)** | Honrar señal **GPC**; consentimiento simétrico; **sin dark patterns**; opt-out de venta | **uxuifull/farola** (GPC, UX); **grc/legal** (alcance) |
| **WCAG 2.2 AA / EAA** (EAA desde 28-jun-2025) | **Amplia** (WCAG: estándar global; EAA: UE) | Cumplir AA; target ≥24×24; autenticación accesible; en DoR/DoD | **uxuifull/farola** (implementa); **amado** (verifica) |
| **OWASP Top 10:2025** | **Universal** (buena práctica, no jurisdiccional) | Reglas de autorización por historia (A01); gestionar supply chain (A03) | **destroyer** (controles); **amado** (prueba); **motor/eneida** |
| **HIPAA** (NPRM 2025 **[NO FINAL]**) | **Solo EE. UU.** | BAA antes de integrar PHI; asumir cifrado/MFA; control de acceso | **legal/sello** (BAA); **destroyer** (cifrado/MFA); **andulfo/caudal/brujula/prisma** |
| **PCI DSS v4.0.1** (51 req. desde 31-mar-2025) | **Global** (contractual, donde se procesen tarjetas) | Minimizar alcance (tokenización); anti-skimming en checkout | **destroyer/sello** (cumplimiento); **motor/farola** (pago) |
| **PSD2 SCA** (EBA) | **Solo UE/EEE** | SCA 2FA + dynamic linking; gestionar exenciones como trade-off conversión/fraude | **motor** (integración pago); **eneida**; **grc** |
| **Superintendencia Financiera de Colombia** | **Colombia** (regulador financiero local, fintech) | Requisitos de entidad vigilada/aliado (SARLAFT, circulares, continuidad); identificarlos antes de comprometer alcance | **legal/sello** + negocio; **motor/eneida** (técnico) |
| **Regulador sectorial local** | **Según país/sector** | Identificar el regulador y marco aplicables a la jurisdicción real antes de fijar criterios | **legal/sello** (interpreta); tompo lo dispara |

> Lectura: la columna **Jurisdicción** evita el sesgo EU/US — cada marco aplica
> donde corresponde (PSD2/SCA y HIPAA son **solo** UE/EEE y EE. UU.; en Colombia
> rigen Ley 1581 y la Superintendencia Financiera). La columna de criterios es
> **de tompo** (qué exigir y cuándo). La columna derecha **no es de tompo**: es quien
> construye u opera el control. tompo **firma el go/no-go de valor**; el sign-off de
> cumplimiento es de **sello + legal**.

---

## 10. Cómo entra el cumplimiento en el flujo del PO (modos A→E)

| Modo | Acción regulatoria del PO |
|---|---|
| **A — Descubrimiento** | Detecta criticidad/regulación del dominio; marca **[SUPUESTO]** regulatorio; convoca a **sello** temprano. Identifica si hay datos personales, pagos, salud o UI pública. |
| **B — Estrategia** | Incluye el riesgo regulatorio en la priorización (coste de incumplir, coste de retraso); decide si una DPIA/BAA es prerrequisito del Product Goal. |
| **C — Backlog/Definición** | Convierte cada obligación en **criterio de aceptación testeable** y parte de la **DoR/DoD**; ninguna historia con datos personales está Ready sin su criterio de privacidad/accesibilidad. |
| **D — Entrega/Decisión** | No aprueba release sin **sign-off de sello** (cumplimiento) y **amado** (calidad); documenta el trade-off de negocio aceptado. |
| **E — Medición** | Monitorea métricas de cumplimiento (tasa de consentimiento, SLA de derechos, hallazgos de accesibilidad) como guardrails. |

---

## 11. Checklist del PO — "historia/release regulado listo"

```
- [ ] ¿Identifiqué qué regulación aplica al feature (datos personales, pago, salud, UI pública)?
- [ ] ¿Cada dato personal tiene base legal y finalidad declaradas (GDPR Art. 6 / Ley 1581)?
- [ ] ¿Apliqué minimización y opción más protectora por defecto (privacy by default)?
- [ ] ¿El flujo de consentimiento es simétrico y sin dark patterns (CCPA/GDPR)?
- [ ] ¿La UI cumple WCAG 2.2 AA y está en la DoR/DoD (verifica amado/uxuifull)?
- [ ] ¿Las reglas de autorización (quién hace qué) son criterio testeable (OWASP A01)?
- [ ] ¿Disparé DPIA/RoPA/BAA con grc cuando el riesgo lo exige?
- [ ] ¿Marqué la regulación NO FINAL (HIPAA NPRM, PSD3) como dirección, no requisito?
- [ ] ¿Obtuve el sign-off de sello (cumplimiento) y amado (calidad) antes del release?
- [ ] ¿Declaré el riesgo de negocio aceptado y di el go/no-go de valor?
```

---

## 12. Recordatorio de frontera de rol

tompo **NO es el experto legal ni de seguridad.** Define **qué/por qué** y el
**riesgo de negocio aceptable**, e **incorpora** el cumplimiento como criterio de
aceptación y de priorización desde la discovery. **No implementa controles, no
interpreta la ley, no certifica.** Colabora estrechamente con **sello +
legal** (cumplimiento/privacidad), el **cluster destroyer** (seguridad), **uxuifull/
farola** (accesibilidad), **eneida** (arquitectura) y **andulfo/caudal/brujula/prisma** (datos). RACI y
handoffs en [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md). Para
features de IA, ver [ia-producto.md](ia-producto.md).
