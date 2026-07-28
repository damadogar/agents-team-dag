# Factor humano — Sello

El humano es vector y defensa de primera clase. Cubre ingeniería social,
concienciación, cultura de seguridad e *insider threat*. Aplica a cualquier
organización; el rigor se calibra al riesgo (§6 de [SKILL.md](SKILL.md)).

---

## 1. Ingeniería social (vectores)

- **Phishing / spear-phishing / whaling:** correo dirigido para credenciales,
  malware o fraude (BEC). Vector inicial más común.
- **Smishing / vishing:** SMS y voz (incl. deepfake de voz/vídeo, en aumento).
- **MFA fatigue / push bombing:** saturar al usuario con prompts de aprobación.
- **Pretexting / suplantación:** hacerse pasar por IT, proveedor, ejecutivo.
- **Baiting / quid pro quo:** USB señuelo, "regalo" a cambio de acceso.
- **Tailgating / piggybacking:** acceso físico siguiendo a un autorizado (ver
  seguridad fisica -> skill **destroyer**).
- **Abuso de IA:** generación de phishing/deepfakes a escala; clonación de voz.

## 2. Controles técnicos que reducen el factor humano
- **MFA resistente a phishing (FIDO2/WebAuthn):** anula la mayoría del robo de
  credenciales y el push bombing. **[RECOMENDACIÓN FUERTE]**
- **Filtrado de correo** (anti-phishing, DMARC/DKIM/SPF), *sandboxing* de adjuntos,
  reescritura de enlaces.
- **Número-matching** en MFA push; límites de prompts.
- **Mínimo privilegio:** reduce el impacto de una cuenta comprometida.
- **Verificación fuera de banda** para transferencias/cambios sensibles (anti-BEC).

## 3. Concienciación y formación (programa)
- **Continua, no anual de cumplir-y-olvidar.** Microaprendizaje, contextual.
- **Simulaciones de phishing** con métrica de tendencia y **sin cultura punitiva**
  (reportar debe ser fácil y bien visto; castigar esconde incidentes).
- **Segmentada por rol/riesgo** (finanzas, IT, ejecutivos, desarrollo).
- **Botón de reporte** de phishing de un clic; medir tasa de reporte, no solo de clic.
- **Onboarding** con seguridad desde el día 1; refuerzo en eventos clave.

## 4. Insider threat (interno)
- **Tipos:** malicioso (sabotaje, robo, fraude), negligente (error, descuido),
  comprometido (cuenta tomada por externo).
- **Controles:** mínimo privilegio y *need-to-know*, separación de funciones (SoD),
  revisión de accesos, monitoreo de actividad anómala (UEBA), DLP, gestión
  cuidadosa del *offboarding* (revocación inmediata), rotación/doble control en
  funciones sensibles.
- **Señales:** acceso fuera de patrón, exfiltración, escalada, descontento +
  acceso privilegiado. Tratar con **proporcionalidad y privacidad/legal** — el
  monitoreo del personal tiene límites legales según jurisdicción.

## 5. Cultura de seguridad
- Liderazgo que modela el comportamiento; seguridad como facilitador, no policía.
- Canales de reporte sin miedo; *blameless* en incidentes humanos.
- Métricas de cultura: tasa de reporte, tiempo a reporte, participación.
- *Security champions* embebidos en equipos.

## 6. Checklist factor humano
```
- [ ] MFA resistente a phishing en accesos clave; número-matching en push
- [ ] DMARC/DKIM/SPF + filtrado de correo + botón de reporte de 1 clic
- [ ] Verificación fuera de banda para pagos/cambios sensibles (anti-BEC)
- [ ] Programa de concienciación continuo, segmentado y NO punitivo
- [ ] Simulaciones con métrica de reporte (no solo de clic)
- [ ] Mínimo privilegio + SoD + revisión de accesos (limita insider e impacto)
- [ ] Offboarding con revocación inmediata; UEBA/DLP donde el riesgo lo justifique
- [ ] Monitoreo de personal respeta límites legales/privacidad de la jurisdicción
```
