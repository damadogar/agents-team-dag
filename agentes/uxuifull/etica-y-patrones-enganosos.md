# Ética de diseño y patrones engañosos (deceptive/dark patterns)

El diseño ético no es un añadido moral opcional: es **parte nuclear del craft**
de un UX/UI master. Una interfaz que funciona pero manipula, oscurece costos,
dificulta la salida o explota sesgos cognitivos es un **defecto de experiencia**,
por más pulida que se vea. uxuifull diseña para el interés del usuario y **rechaza
y reescribe** cualquier patrón que lo traicione, aunque suba una métrica de negocio
a corto plazo.

> Principio: **diseño honesto**. Nunca manipular, nunca oscurecer costo o
> consentimiento, nunca explotar sesgos para forzar una acción que el usuario no
> tomaría con información completa y simétrica.

## 1. Taxonomía de patrones engañosos (deceptive patterns)

Los patrones nombrados provienen del catálogo de Harry Brignull
(*deceptive.design*, antes *darkpatterns.org*); las **meta-categorías** (Nagging,
Sneaking, Obstruction, Forced action, Interface interference) son de **Gray, Kou,
Battles, Hoggatt & Toombs (2018)**, con aportes de la EU/EDPB. Cada patrón tiene
su **alternativa honesta**, que es lo que uxuifull especifica.

| Categoría | Patrón engañoso | Síntoma | Alternativa honesta |
|-----------|-----------------|---------|---------------------|
| **Nagging** | Insistencia repetida | Pop-ups/permisos que reaparecen hasta que cedes | Preguntar una vez, respetar el "no", ofrecer reactivar en ajustes |
| **Sneaking** | Sneak into basket / costos ocultos / suscripción oculta | Cargos, ítems o renovaciones que aparecen tarde | Mostrar costo total y compromisos **antes** de decidir |
| **Obstruction** | Roach motel / cancelación difícil | Fácil entrar, tortuoso salir | Salir/cancelar tan fácil como entrar (paridad de esfuerzo) |
| **Forced action** | Forced continuity / enrollment / privacy zuckering | Obligan a dar datos, aceptar o suscribir para avanzar | Pedir solo lo necesario; opt-in real; degradar con gracia |
| **Interface interference** | Confirmshaming, trick wording, jerarquía falsa, preselección | "No, no quiero ahorrar dinero"; opción mala resaltada; casillas premarcadas | Lenguaje neutral; jerarquía visual que **no** sesga; sin premarcar consentimiento |
| **Misdirection** | Visual interference, disguised ads | La atención se desvía; anuncios disfrazados de contenido/botón | Distinguir claramente anuncio de UI; foco en la tarea del usuario |
| **Social proof falso** | Testimonios/actividad inventados | "12 personas viendo esto ahora" sin base | Prueba social real y verificable, o ninguna |
| **Scarcity/urgency falsa** | Fake countdown, low-stock mentiroso | Contadores que se reinician; "solo 2 left" falso | Urgencia/escasez solo si es real y comprobable |

**Regla de detección rápida (test de asimetría):** *¿el usuario aceptaría esto si
viera con claridad lo que ocurre y le costara lo mismo aceptar que rechazar?* Si la
respuesta es no, es un patrón engañoso.

## 2. Marco regulatorio (awareness, no asesoría legal)

Los patrones engañosos hoy están **regulados**; ignorarlos es riesgo legal además
de ético. uxuifull diseña conforme; la **conformidad regulatoria formal y la
privacidad legal son de `sello` (GRC/privacidad/DPO)** — uxuifull aporta el diseño
honesto, no dictamina cumplimiento.

- **UE — Digital Services Act (DSA), art. 25:** prohíbe a las plataformas diseñar
  interfaces que engañen o manipulen (dark patterns).
- **UE — GDPR + EDPB (Guidelines 03/2022 sobre deceptive patterns):** el
  consentimiento debe ser libre, informado, específico e inequívoco; nada de
  casillas premarcadas ni "aceptar" más fácil que "rechazar".
- **UE — EAA / EN 301 549:** accesibilidad como derecho (adyacente, ver
  `accesibilidad.md`).
- **EE. UU. — FTC Act §5** (prácticas engañosas) y regla **"click to cancel"**;
  **CPRA (California)** define y limita dark patterns en consentimiento.
- Principio transversal: **simetría de opciones** (aceptar/rechazar con el mismo
  esfuerzo y prominencia) y **costo/compromiso visible antes de confirmar**.

Estas jurisdicciones son **ilustrativas de una tendencia regulatoria global**, no
una lista cerrada: verifica la normativa local aplicable (p. ej. **LGPD** en
Brasil, **DPDP** en India, **Ley 1581** en Colombia, y equivalentes). El diseño
honesto es el piso universal; el dictamen de conformidad por región es de `sello`.

## 3. Persuasión ética vs. manipulación

Persuadir no es malo; **manipular** sí. La diferencia es transparencia, simetría y
alineación con el interés del usuario.

- **Nudge vs. sludge.** Un *nudge* facilita la mejor decisión para el usuario
  (defaults sensatos, fricción reducida). El *sludge* añade fricción para atrapar
  (cancelación tortuosa). uxuifull usa nudges pro-usuario; elimina sludge.
- **Modelo de comportamiento de Fogg (B=MAP)** y **Hook (Eyal)** son potentes y
  por eso exigen contrapeso ético: úsalos para formar hábitos **valiosos y
  consentidos**, nunca compulsión o retención por atrapamiento. (Craft
  emocional/conductual en `interaccion-disenio.md` §6 bis.)
- **Sesgos que NO se explotan:** nombrar el sesgo es saber cuál no estás usando en
  contra del usuario — anclaje, aversión a la pérdida, efecto default, framing,
  prueba social, escasez, sunk cost. La persuasión ética los usa para *ayudar* a
  decidir, no para atrapar.
- **Consentimiento y privacidad como UX honesta:** permission priming que explica
  el porqué **antes** del prompt del sistema; solicitud *just-in-time* en el
  momento de valor; banners de cookies con "Rechazar todo" tan visible como
  "Aceptar todo"; sin *privacy zuckering* (extraer más datos de los necesarios).
  Honra las **señales automatizadas de opt-out** (Global Privacy Control / GPC,
  exigida por CPRA) y no las ignores en la UI.
- **Defaults responsables:** el default es una decisión de diseño con enorme peso;
  elige el que protege al usuario (privacidad, gasto, atención), no el que exprime
  al negocio.
- **Usuarios vulnerables y menores:** en dominios sensibles (salud, gobierno,
  finanzas, menores) sube el listón: **safety-by-design** y **age-appropriate
  design** (p. ej. UK *Children's Code* / AADC), defaults más protectores, y
  diseño para personas en crisis o baja alfabetización. La persuasión que sería
  aceptable con un adulto informado puede ser inaceptable aquí.

## 4. Cómo cambia según el estado del sistema

| Contexto | Postura de uxuifull |
|----------|---------------------|
| Greenfield / antes de construir | Diseñar honesto desde el día cero: simetría de opciones, costos visibles, consentimiento real, defaults pro-usuario. Incluir el filtro ético en el DoR de experiencia. |
| En construcción | Revisar flujos en curso contra la taxonomía §1 antes de que se cementen; corregir preselecciones, confirmshaming y cancelaciones asimétricas temprano. |
| Brownfield / auditoría | **Auditar el sistema existente** contra §1 y §2, marcar cada patrón engañoso con severidad e impacto (usuario + riesgo legal), y entregar la alternativa honesta en el handoff (P0 los de riesgo regulatorio). |

## 5. Frontera

- **uxuifull** posee la **ética del diseño y la experiencia honesta** (detectar y
  reescribir patrones engañosos, consentimiento/privacidad como UX).
- **`sello`** posee la **conformidad regulatoria y de privacidad** (GDPR/DSA/CPRA,
  DPO, evidencia de cumplimiento). uxuifull diseña conforme y señala el riesgo;
  el dictamen legal es de `sello`.
- **`tompo`** decide el valor de producto; uxuifull veta el patrón engañoso aunque
  suba una métrica, y ofrece la alternativa honesta que sostiene el valor sin
  manipular.

```
Checklist anti-patrón engañoso (antes de entregar)
[ ] ¿Costos, compromisos y renovaciones son visibles ANTES de confirmar?
[ ] ¿Salir/cancelar es tan fácil como entrar/suscribir? (paridad de esfuerzo)
[ ] ¿Aceptar y rechazar tienen el mismo peso visual y de esfuerzo? (simetría)
[ ] ¿El consentimiento es opt-in real, sin casillas premarcadas ni privacy zuckering?
[ ] ¿El lenguaje es neutral (sin confirmshaming ni trick wording)?
[ ] ¿La jerarquía visual NO empuja hacia la opción que perjudica al usuario?
[ ] ¿Escasez/urgencia/prueba social son reales y verificables?
[ ] ¿Los anuncios se distinguen claramente de la UI y del contenido?
[ ] Test de asimetría: ¿el usuario lo aceptaría con información completa y costo simétrico?
[ ] ¿Los defaults protegen al usuario (privacidad, gasto, atención)?
```

## Referencias

- Harry Brignull, *Deceptive Patterns* (2023) y *deceptive.design* (patrones nombrados).
- Gray, Kou, Battles, Hoggatt & Toombs, *The Dark (Patterns) Side of UX Design* (CHI 2018) — meta-categorías.
- EDPB, *Guidelines 03/2022 on deceptive design patterns in social media platform interfaces*.
- UE, *Digital Services Act* (art. 25); *GDPR* (consentimiento).
- FTC, *Bringing Dark Patterns to Light* (2022); regla "click to cancel"; CPRA (California) + Global Privacy Control (GPC).
- ICO (UK), *Age Appropriate Design Code (Children's Code)*.
- Thaler & Sunstein, *Nudge*; concepto de *sludge*. B. J. Fogg, *Behavior Model*.
