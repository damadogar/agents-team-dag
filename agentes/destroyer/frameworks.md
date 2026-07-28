# Marcos, estándares y fuentes — Destroyer

Catálogo **neutral** de referencia. **Verifica versiones y advisories vigentes**
(cambian con frecuencia); no fijes un estado estático. Úsalos como lenguaje común
y para demostrar cobertura, no como checklist ciego.

> **Sin lock-in (regla de neutralidad).** Ningún marco es el "correcto" por
> defecto. Destroyer **se mapea al estándar que la organización ya usa** (o a
> ninguno) y traduce entre marcos según convenga. La lente de evaluación es
> **riesgo + evidencia**, no el marco. Este catálogo evita centro de gravedad
> geográfico: incluye fuentes de EE.UU., UE/internacionales y notas regionales;
> aplica el que corresponda a la jurisdicción y sector del sistema.

Equivalencias rápidas: los marcos cubren outcomes parecidos con vocabularios
distintos (p. ej. *gobierno/identificar/proteger/detectar/responder/recuperar* en
CSF ≈ controles de gestión + Anexo A en ISO 27001 ≈ dominios de CIS v8). No los
trates como excluyentes; **crosswalk**, no religión.

---

## 1. NIST

- **CSF 2.0** (Cybersecurity Framework) — 6 funciones: **Govern, Identify,
  Protect, Detect, Respond, Recover**. *Govern* es nuevo en 2.0 (gobernanza,
  apetito de riesgo, roles, política). Taxonomía de outcomes, no prescriptiva.
- **SP 800-207** — **Zero Trust Architecture** (PEP/PDP, política dinámica).
- **SP 800-218 (SSDF)** — Secure Software Development Framework (prácticas seguras
  en el SDLC).
- **SP 800-53** — catálogo de controles de seguridad y privacidad.
- **SP 800-61** — Computer Security Incident Handling Guide (IR).
- **SP 800-30 / 800-37 / RMF** — gestión y evaluación de riesgo.
- **SP 800-190** — seguridad de contenedores.
- **SP 800-63** — identidad digital y niveles de aseguramiento (IAL/AAL/FAL).
- **NIST AI RMF (AI 100-1)** — gestión de riesgo de IA (Govern/Map/Measure/Manage).
- **PQC / post-cuántica:** **FIPS 203 (ML-KEM), 204 (ML-DSA), 205 (SLH-DSA)** —
  estándares de criptografía resistente a cuántica; base de la migración y la
  *crypto-agility* (ver criptografia -> skill **destroyer**).

## 2. ISO/IEC

- **27001:2022** — SGSI (sistema de gestión); **Anexo A** con 93 controles en 4
  temas (organizacional, personas, físico, tecnológico).
- **27002:2022** — guía de implementación de controles.
- **27005** — gestión de riesgo de seguridad de la información.
- **27017 / 27018** — seguridad y privacidad en cloud.
- **27701** — gestión de privacidad (PIMS).
- **IEC 62443** — seguridad para sistemas de control industrial (OT/ICS).

## 3. MITRE

- **ATT&CK** — base de conocimiento de TTPs adversarias (Enterprise, Mobile, ICS).
  Para threat modeling, detección y medición de cobertura.
- **ATLAS** — equivalente de ATT&CK para sistemas de **IA/ML**.
- **D3FEND** — contramedidas defensivas mapeables a ATT&CK (harden/detect/isolate/
  deceive/evict).
- **CAPEC** — patrones de ataque comunes.
- **Engage** — engaño/deception adversarial.

## 4. OWASP

- **Top 10** (web) — riesgos web más críticos (incl. Broken Access Control,
  Injection, Cryptographic Failures, SSRF, Security Misconfiguration...).
- **API Security Top 10** — riesgos de APIs (BOLA, Broken Auth, etc.).
- **ASVS** — Application Security Verification Standard (niveles 1-3) como baseline
  verificable.
- **SAMM** — Software Assurance Maturity Model (madurez del programa).
- **DSOMM** — DevSecOps Maturity Model.
- **Top 10 for LLM Applications 2025** — LLM01..LLM10 (ver seguridad de IA/LLM -> skill **vector**).
- **Agentic AI / GenAI Security Project** — amenazas y controles de IA agéntica.
- **Cheat Sheet Series**, **Threat Modeling**, **WSTG/MASVS**.

## 5. CIS

- **CIS Controls v8** — 18 controles priorizados (IG1/IG2/IG3 por madurez).
- **CIS Benchmarks** — líneas base de hardening por SO, nube, k8s, DB, navegador.

## 6. Supply chain / build integrity

- **SLSA** — niveles de integridad de la cadena de build/procedencia.
- **SBOM** — CycloneDX / SPDX.
- **in-toto, Sigstore/cosign** — firma y atestación de artefactos.

## 7. Threat intel / vulnerabilidad

- **Cyber Kill Chain** (Lockheed Martin) — fases de un ataque.
- **Diamond Model** — análisis de intrusiones.
- **CVSS** — severidad técnica; **EPSS** — probabilidad de explotación; **CISA
  KEV** — explotación activa conocida.
- **STIX/TAXII** — intercambio de threat intel.

## 8. Cloud (well-architected / seguridad — sin preferencia de proveedor)

- **AWS Well-Architected — Security Pillar**; AWS SRA.
- **Azure Well-Architected — Security**; Microsoft Cloud Security Benchmark.
- **Google Cloud Architecture Framework — Security**.
- **Otros / multi-nube:** Oracle, IBM, Alibaba y privadas; **CIS Foundations** por
  nube como base común y comparable. Para on-prem/mainframe/air-gapped aplican los
  mismos principios sin asumir nube (ver cobertura por sistema -> skill **destroyer**).

## 9. Privacidad y regulación (conceptual, multi-región — no asesoría legal)

Aplica el marco de la **jurisdicción y sector del sistema**; coordina con legal/
privacidad. **Mapeo de controles**, no interpretación legal vinculante.

- **Privacidad / datos personales:** GDPR (UE), UK GDPR, **Ley 1581 / Habeas
  Data** (Colombia), LGPD (Brasil), LFPDPPP (México), CCPA/CPRA (California),
  PIPEDA (Canadá), POPIA (Sudáfrica), APPI (Japón), PIPL (China), PDPA
  (Singapur). Marcos de gestión: ISO 27701, NIST Privacy Framework.
- **Sectoriales:** PCI-DSS (tarjetas, global), HIPAA (salud, EE.UU.), SOX
  (financiero, EE.UU.), DORA y NIS2 (UE), GLBA, FERPA.
- **Aseguramiento/certificación:** SOC 2, ISO 27001, C5 (Alemania), ENS (España),
  EUCS (esquema cloud UE), FedRAMP (gobierno EE.UU.), IRAP (Australia).

Principio transversal: **el cumplimiento es un piso, no un techo.** Diseña por
riesgo y mapea controles al requisito que aplique.

---

## 10. Cómo elegir marco según necesidad (referencia, no imposición)

Si la organización **ya tiene** un marco, **úsalo y mapéate a él**. Si no, estas
son opciones habituales por necesidad (con alternativas equivalentes):

| Necesidad | Opción habitual | Alternativas equivalentes |
|---|---|---|
| Estructurar un programa / lenguaje común | NIST CSF 2.0 | ISO 27001/27002; CIS v8; marcos regionales |
| Certificación / SGSI | ISO 27001:2022 | SOC 2; esquemas regionales (ENS, C5, IRAP) |
| Modelar amenazas y medir detección | MITRE ATT&CK (+ATLAS para IA) | STRIDE/PASTA; Kill Chain; Diamond |
| Verificar seguridad de una app | OWASP ASVS / Top 10 | requisitos propios mapeados a ASVS |
| Madurez del programa | OWASP SAMM / DSOMM | BSIMM; niveles CIS IG1-3; tiers CSF |
| Hardening de sistemas | CIS Benchmarks | guías del fabricante; STIG (DISA) |
| Zero Trust (si aplica) | NIST 800-207 | modelos de cada nube; no obligatorio |
| Integridad de supply chain | SLSA + SBOM + Sigstore | in-toto; políticas propias |
| Seguridad de IA/LLM | OWASP LLM Top 10 + ATLAS + NIST AI RMF | ISO/IEC 42001; controles propios |
| Privacidad | GDPR/marco local + ISO 27701 | NIST Privacy Framework; LINDDUN (técnico) |

La columna "opción habitual" **no es un default obligatorio**: es un punto de
partida que se sustituye por el marco vigente de la organización o su jurisdicción.
