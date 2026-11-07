# Estrategia de protección de software

## 1. Pirámide (prioridad)

```
        ┌─────────────────────┐
        │ Respuesta / rotación│
        ├─────────────────────┤
        │ Detección / telemetría│
        ├─────────────────────┤
        │ Integridad / attestation│
        ├─────────────────────┤
        │ Ofuscación / packing  │
        ├─────────────────────┤
        │ Arquitectura (secretos│
        │  y reglas en servidor)│
        └─────────────────────┘
```

La base manda. Ofuscar un secreto que no debería existir en cliente es teatro.

## 2. Decisiones de arquitectura (las que más valen)

- Autorización y facturación en servidor
- Keys de corta vida / binding a dispositivo atestado
- Feature flags remotos para matar builds abusivos
- Separar “demo client” de “logic server”
- No dejar símbolos ni logs de debug en release

## 3. Ofuscación — uso correcto

**Sirve para:** subir costo, romper scripts tontos, retrasar mapas automáticos.

**No sirve para:** confidencialidad a largo plazo frente a RE determinado.

Tipos (elige por plataforma): control-flow flattening, string encryption,
virtualization (caro), renames, packing. Mide impacto en crash rates y perf.

## 4. Integridad y anti-tamper

- Firma de código (OS) + checks de recursos críticos
- Attestation donde el ecosistema lo permita (Play Integrity, App Attest, etc.)
- Respuestas: degradar features sensibles, no solo “exit(1)” predecible
- Cuidado: false positives destruyen UX y soporte

## 5. Empaquetado / loaders

Packers aumentan fricción; también aumentan falsos positivos AV y complejidad
de soporte. Úsalos con threat model, no por default.

## 6. White-box y crypto en cliente

Último recurso. Asume extractibilidad. Combina con server-side y rotación.

## 7. Métricas de éxito

- Time-to-first-useful-map ↑
- Cracks públicos triviales ↓
- Detecciones de tamper accionables ↑
- Incidentes de key leakage ↓
- Falsos positivos de integridad ↓
