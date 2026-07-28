# Privacidad (privacy engineering) — Sello

Seguridad ≠ privacidad: un sistema puede ser seguro y aún así violar la
privacidad. Cubre privacy by design, modelado de amenazas de privacidad (LINDDUN),
DPIA, minimización y derechos del titular. **Region-neutral:** aplica el marco de
la jurisdicción del sistema; **no es asesoría legal** — coordina con legal/DPO.

---

## 1. Principios (privacy by design / by default)
1. **Proactivo, no reactivo; preventivo.**
2. **Privacidad por defecto:** la configuración más protectora es la inicial.
3. **Privacidad embebida en el diseño**, no añadida después.
4. **Funcionalidad plena** (no falso dilema privacidad vs. utilidad).
5. **Seguridad de extremo a extremo** durante todo el ciclo de vida del dato.
6. **Visibilidad y transparencia** (qué se recoge, para qué, con quién se comparte).
7. **Respeto por el usuario** (centrado en el titular).

## 2. Conceptos base (vocabulario neutral)
- **Dato personal / PII:** identifica o hace identificable a una persona.
- **Categorías especiales / sensibles:** salud, biometría, origen, creencias,
  orientación, etc. — mayor protección.
- **Roles:** responsable/controlador (decide fines y medios) vs. encargado/
  procesador (procesa por cuenta del responsable).
- **Base de licitud / finalidad:** todo tratamiento necesita un propósito legítimo
  y declarado; no reutilizar fuera de él sin base.

## 3. Modelado de amenazas de privacidad — LINDDUN
Complementa a STRIDE (que cubre seguridad) con amenazas de **privacidad**:

| Amenaza | Significado |
|---|---|
| **L**inking | Vincular datos/acciones a una misma persona |
| **I**dentifying | Identificar a una persona antes anónima |
| **N**on-repudiation | Imposibilidad de negar una acción (cuando la privacidad la requiere) |
| **D**etecting | Inferir existencia de un dato/persona por observación |
| **D**ata disclosure | Exposición excesiva o indebida de datos |
| **U**nawareness | El titular no sabe/decide sobre su dato |
| **N**on-compliance | Incumplir políticas/regulación de privacidad |

Úsalo en diseño junto al threat model de seguridad.

## 4. Técnicas de privacy engineering
- **Minimización de datos:** recoge y retén solo lo necesario; el dato que no
  existe no se filtra.
- **Limitación de finalidad y de retención:** borra/anonimiza cuando ya no se
  necesita.
- **Anonimización vs. seudonimización:** anonimizar (irreversible) saca el dato del
  alcance regulatorio; seudonimizar (reversible con clave) sigue siendo personal.
- **PETs (Privacy-Enhancing Technologies):** *differential privacy*, computación
  segura multiparte (MPC), cifrado homomórfico, *federated learning*, tokenización,
  agregación. Aplica según caso de uso y madurez.
- **Segregación y control de acceso** por finalidad; *data access broker*.
- **Consentimiento y preferencias** gestionables y auditables (donde aplique).

## 5. DPIA / PIA (evaluación de impacto)
Cuándo: tratamiento de alto riesgo (datos sensibles a escala, perfilado,
monitoreo sistemático, nuevas tecnologías). Pasos:
```
1. Describir el tratamiento (datos, fines, flujos, actores, transferencias)
2. Evaluar necesidad y proporcionalidad
3. Identificar riesgos a los derechos de los titulares (usar LINDDUN)
4. Medidas de mitigación (técnicas y organizativas)
5. Riesgo residual + decisión + revisión periódica
```

## 6. Derechos del titular (transversal a regímenes)
Acceso, rectificación, supresión/olvido, oposición, portabilidad, limitación,
no decisión automatizada sin garantías. **Diseña el sistema para poder ejecutarlos**
(p. ej. localizar y borrar todos los datos de una persona) — si no se puede, es un
hallazgo de privacidad.

## 7. Transferencias y soberanía de datos
- **Residencia/soberanía:** dónde viven y se procesan los datos; restricciones por
  jurisdicción.
- **Transferencias transfronterizas:** mecanismos según régimen (cláusulas, marcos
  de adecuación); coordina con legal.
- **Subprocesadores (cuarta parte):** inventario y control contractual.

## 8. Relación con seguridad e IA
- Seguridad protege el dato; privacidad gobierna **si debe existir, para qué y por
  cuánto tiempo**. Trabajan juntas.
- **IA/LLM:** no enviar PII/datos sensibles a modelos no autorizados; minimizar el
  contexto; gobernar qué entra al prompt/entrenamiento (ver seguridad de IA/LLM -> skill **vector**).

## 9. Checklist privacidad
```
- [ ] Inventario de datos personales y su finalidad/base de licitud
- [ ] Minimización y retención/borrado definidos y aplicados
- [ ] LINDDUN aplicado en diseño (junto a STRIDE)
- [ ] DPIA para tratamientos de alto riesgo
- [ ] Anonimización/seudonimización correctamente distinguidas y aplicadas
- [ ] Derechos del titular ejecutables por diseño (incl. borrado completo)
- [ ] Transferencias/residencia conformes a la jurisdicción (con legal)
- [ ] PII fuera de logs/no-prod/IA no autorizada
- [ ] Marco regulatorio = el de la jurisdicción del sistema (no asumido)
```
