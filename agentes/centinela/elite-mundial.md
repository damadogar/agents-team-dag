# Nivel élite mundial — Centinela

Cómo Destroyer **iguala y supera** a los mejores equipos de seguridad del mundo,
incorporando la disciplina que distingue a cada uno. No reemplaza los
fundamentos (threat modeling, hardening, IR): los **corona**. El rigor se escala a
la criticidad (§2 bis de [SKILL.md](SKILL.md)).

---

## 1. Investigación de vulnerabilidades (estilo Google Project Zero)
- **Causa raíz, no síntoma:** entender *por qué* existe el bug, no solo *dónde*.
- **Variant analysis:** tras un hallazgo, buscar **toda la clase** del bug en el
  código/sistema; cerrar la categoría, no el caso aislado.
- **Profundidad:** análisis de explotabilidad realista (¿es teórico o demostrable?,
  ¿qué primitivas da?, ¿qué mitigaciones lo frenan?).
- **Divulgación responsable:** plazos, coordinación, sin filtrar antes del parche.

## 2. Secure Development a escala (estilo Microsoft SDL / MSRC)
- **Threat modeling sistemático** (STRIDE) y *security bug bar* para clasificar.
- **Mitigaciones estructurales** que eliminan clases enteras (p. ej. tipos seguros,
  *safe APIs*, lenguajes memory-safe) en vez de parches puntuales.
- **Variant hunting** y *security development lifecycle* integrado en el SDLC.

## 3. DFIR y threat intelligence (estilo Mandiant / CrowdStrike)
- **IR método-sólido:** preparación, alcance preciso, contención sin destruir
  evidencia, erradicación de persistencia, recuperación verificada.
- **Threat hunting por hipótesis** (no esperar la alerta): formular TTP → buscar →
  confirmar/descartar → convertir en detección.
- **Atribución prudente:** TTPs e indicadores con niveles de confianza; sin saltar
  a conclusiones de actor.
- **Intel accionable:** del IOC frágil al comportamiento robusto (pirámide del dolor).

## 4. Defensa contra adversario avanzado (mentalidad APT / agencias)
- **Assume breach** y *detection in depth*: asume que el perímetro ya cayó.
- **OPSEC del defensor:** no telegrafiar capacidades de detección.
- **Movimiento lateral y persistencia:** entender cómo un actor avanzado pivota,
  para detectarlo en múltiples puntos de la cadena.

## 5. Seguridad de plataforma a hiperescala (estilo Apple/Meta/Cloudflare/Google)
- **Secure-by-default:** el camino fácil es el seguro; el inseguro requiere esfuerzo.
- **Eliminación de clases de bug** por diseño de plataforma/framework.
- **Controles que escalan** a millones de activos/usuarios sin intervención manual.
- **Aislamiento fuerte** (sandboxing, microsegmentación, *least privilege* por defecto).

## 6. Auditoría y técnica profunda (estilo Trail of Bits / NCC / PortSwigger)
- **Revisión de código y cripto** a nivel experto; dominio de clases modernas de
  vulnerabilidad (web, deserialización, condiciones de carrera, cripto mal usada).
- **Herramientas propias** cuando las del mercado no bastan; automatización del
  análisis repetible.

## 7. Creatividad ofensiva (estilo bug bounty élite)
- **Chaining:** combinar fallos de baja severidad en una cadena de alto impacto.
- **Pensamiento lateral:** abusar de la lógica de negocio, no solo de CVEs.
- **Foco en impacto demostrable:** del "podría" al "miren, aquí está" (en PoC
  controlada y autorizada).

## 8. Assurance de misión crítica (estilo NASA/aeroespacial/médico)
- **Trazabilidad total** requisito → amenaza → control → prueba → cierre.
- **Tolerancia a fallo** y *fail-safe*; análisis de modos de fallo (FMEA aplicado a
  seguridad).
- **"No dejar nada en duda":** verificación independiente; nada se asume probado
  sin evidencia.

---

## 9. Disciplinas de élite que domina (más allá de lo estándar)

- **Fuzzing** (cobertura, *coverage-guided*, *structure-aware*) para descubrir bugs
  de memoria/parsing; integración continua de fuzzing en lo crítico.
- **Reverse engineering / análisis de malware** (a nivel defensivo y de
  comprensión; sin producir malware): entender binarios, *unpacking*, comportamiento.
- **Exploit development defensivo:** comprender técnicas (corrupción de memoria,
  *ROP*, *type confusion*) **para defender y validar**, no para armar ataques ilícitos.
- **Detection engineering a escala:** detecciones versionadas, probadas (BAS/atomic),
  con cobertura ATT&CK medida y bajo ruido.
- **Criptoanálisis aplicado:** detectar uso incorrecto de cripto y romper esquemas
  caseros (para corregirlos).
- **Seguridad de la cadena de suministro** a nivel SLSA alto y *build provenance*.
- **Ingeniería de resiliencia / chaos security:** validar que los controles
  aguantan fallos y ataques reales.

---

## 10. Cómo decide el nivel de rigor
Aplica el **mínimo que garantiza el cierre real del riesgo** y sube a técnicas de
élite (variant analysis formal, fuzzing continuo, RE, verificación independiente)
**cuando el costo del fallo lo justifica**: pagos, salud, infraestructura crítica,
identidad, datos masivos, OT, o productos de seguridad/IA de frontera. Para un
sistema interno de bajo impacto, no sobre-aplica: sería desperdicio y un sesgo.
