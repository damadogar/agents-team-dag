# Catálogo de herramientas (tool-agnostic) — Vector

Mapa de **categorías** de herramientas por rama, con ejemplos representativos. No
hay lealtad a ninguna: Destroyer **elige la mejor para el caso y el contexto** y la
justifica. **Verifica vigencia** (el panorama cambia rápido). Toda herramienta
ofensiva se usa **solo bajo autorización** (§0 de [SKILL.md](SKILL.md)).

> Método de selección: define el objetivo → elige categoría → escoge herramienta
> por encaje (cobertura, fiabilidad, integrabilidad, coste, madurez del equipo) →
> justifica → deja la ejecución **reproducible** (scripts/IaC/pipeline).

---

## 1. Reconocimiento y superficie
- **OSINT / ASM:** Amass, Subfinder, Shodan, Censys, theHarvester, SpiderFoot.
- **Descubrimiento:** Nmap/Masscan (puertos/servicios), httpx, dnsx.

## 2. Análisis de vulnerabilidades (escaneo)
- **Red/infra:** Nessus, OpenVAS, Qualys, Nuclei (plantillas).
- **Web/API:** OWASP ZAP, Burp Suite, Nikto, Nuclei.
- **Cloud posture (CSPM):** ScoutSuite, Prowler, Steampipe, herramientas nativas.

## 3. Explotación / pentest (autorizado)
- **Frameworks:** Metasploit, Cobalt Strike (red team licenciado), Sliver, Havoc.
- **Web:** Burp Suite (intruder/repeater), sqlmap, ffuf/feroxbuster.
- **Identidad/AD:** BloodHound, Impacket, CrackMapExec/NetExec, Responder.
- **Cracking/auth:** Hashcat, John the Ripper (auditoría de contraseñas).
- **Wireless/otros:** Aircrack-ng, según alcance.
> Uso estrictamente bajo autorización y reglas de enfrentamiento.

## 4. AppSec / código (SDLC)
- **SAST:** Semgrep, CodeQL, SonarQube, Checkmarx, Fortify.
- **SCA / dependencias:** OWASP Dependency-Check, Snyk, Trivy, Grype, Dependabot.
- **DAST:** OWASP ZAP, Burp, StackHawk.
- **Secret scanning:** Gitleaks, TruffleHog, detect-secrets.
- **IaC scanning:** Checkov, tfsec, Terrascan, KICS.
- **SBOM / supply chain:** Syft (SBOM), Cosign/Sigstore (firma), in-toto, SLSA.

## 5. Contenedores / Kubernetes
- **Imágenes:** Trivy, Grype, Clair.
- **Postura/runtime k8s:** kube-bench, kube-hunter, Falco (runtime), Kubescape.
- **Admission/policy:** OPA/Gatekeeper, Kyverno.

## 6. Bases de datos
- **Evaluación:** sqlmap (inyección, autorizado), scripts de auditoría de
  privilegios, CIS Benchmarks por motor, herramientas nativas de auditoría.
- **Descubrimiento de datos sensibles / DLP:** clasificadores, escáneres de PII.
- **Cifrado/gestión:** TDE del motor, KMS/HSM, enmascaramiento dinámico.
> Para administración/tuning profundo de BD, coordina con un perfil DBA; Destroyer
> evalúa y corrige la **seguridad** de la BD (acceso, cifrado, inyección, auditoría,
> exposición, parcheo).

## 7. Cloud (AWS/Azure/GCP/otros)
- **Postura/derechos:** Prowler, ScoutSuite, Steampipe, CIEM, nativas
  (Security Hub/Defender/SCC).
- **IAM/acceso:** Access Analyzer, PMapper, herramientas de *privilege escalation
  path* (en auditoría autorizada).

## 8. Detección, SIEM y BAS
- **SIEM/análisis:** Splunk, Elastic, Sentinel, Chronicle, Wazuh (open).
- **EDR/XDR:** según proveedor.
- **Reglas/detección:** Sigma (portable), YARA (archivos/malware), Suricata/Zeek (red).
- **BAS / validación:** Atomic Red Team, Caldera, herramientas de emulación de adversario.

## 9. DFIR y forense
- **Triage/memoria:** Velociraptor, Volatility, KAPE.
- **Disco/artefactos:** Autopsy/Sleuth Kit, plaso/log2timeline.
- **Análisis de malware (defensivo):** sandbox, herramientas de RE (Ghidra, radare2)
  para **comprender** comportamiento, no para producir malware.

## 10. Threat modeling y gobierno
- **Threat modeling:** OWASP Threat Dragon, IriusRisk, Microsoft TMT.
- **Gestión de vulnerabilidades/riesgo:** DefectDojo, plataformas GRC.
- **Crosswalk de marcos:** mapeos NIST↔ISO↔CIS (ver [frameworks.md](frameworks.md)).

---

## 11. Operación autónoma con herramientas
Cuando una herramienta no está disponible, Destroyer la **aprovisiona** (instala/
contiene/levanta entorno efímero) **dentro de su propio alcance autorizado**, deja
todo **reproducible**, y respeta las guardas de [ejecucion-autonoma.md](ejecucion-autonoma.md):
nada destructivo ni contra terceros sin autorización; entorno desconocido = producción.
La herramienta es medio, no fin: el objetivo es **encontrar y cerrar el riesgo**.
