# Seguridad física y ambiental — Destroyer

La seguridad lógica se evade si la física falla. Cubre acceso físico, data
center/instalaciones, medios, hardware/firmware y destrucción segura. Calibra al
contexto: una oficina pequeña, un data center y un sitio industrial difieren en
rigor, no en principios.

---

## 1. Control de acceso físico
- **Perímetro por capas:** valla/recepción → zonas controladas → áreas sensibles
  (data center, salas de red, bóvedas). Acceso decreciente hacia el núcleo.
- **Autenticación física:** tarjeta + PIN/biométrico para zonas sensibles;
  *anti-passback*; **anti-tailgating** (mantraps/esclusas) donde el riesgo lo pida.
- **Visitantes:** registro, escolta, identificación, áreas restringidas.
- **Mínimo privilegio físico:** solo accede quien lo necesita; revisión periódica;
  revocación inmediata en *offboarding* (coordinado con el lógico).
- **Registro y CCTV:** logs de acceso, videovigilancia con retención acorde a
  privacidad/regulación; detección de accesos anómalos.

## 2. Data center / salas técnicas
- **Ambientales:** energía redundante (UPS/generador), refrigeración, detección y
  supresión de incendios, control de humedad, monitoreo ambiental.
- **Resiliencia:** redundancia acorde a criticidad (concepto Tier), pruebas de
  failover, mantenimiento.
- **Cableado y red física:** protección de puntos de red, deshabilitar puertos no
  usados, seguridad de salas de comunicaciones.
- **Cloud/colocation:** si es de un proveedor, la física se **hereda y verifica**
  vía atestaciones (SOC 2/ISO 27001/auditorías del proveedor), no se ignora.

## 3. Medios y dispositivos
- **Control de medios extraíbles** (USB, discos): política, cifrado, bloqueo donde
  aplique; crítico en entornos air-gapped.
- **Cifrado de disco** en portátiles/dispositivos móviles (robo/pérdida).
- **Pantallas y escritorio limpio:** bloqueo automático, *privacy screens*,
  política de escritorio/pantalla limpios.
- **Inventario de activos** físico y conciliado con el lógico.

## 4. Hardware y firmware (cadena física)
- **Supply chain de hardware:** procedencia confiable, detección de manipulación
  (*tamper-evident*), validación de equipos antes de uso.
- **Secure boot / root of trust** (TPM/HSM) donde aplique.
- **Puertos de debug** (JTAG/UART) deshabilitados en producción.
- **Tamper protection:** sellos, detección de apertura, respuesta ante manipulación
  en dispositivos sensibles/embebidos.

## 5. Destrucción segura y fin de vida
- **Borrado seguro** de datos antes de reutilizar (estándares de sanitización).
- **Destrucción física** de medios que no se reutilizan (trituración,
  desmagnetización) con certificado/cadena de custodia.
- **Disposición de hardware** sin fuga de datos ni de información de configuración.

## 6. Convergencia físico-lógica
- Sincroniza identidad y accesos físico/lógico (un *leaver* pierde ambos a la vez).
- Correlaciona eventos físicos y lógicos (acceso físico sin login esperado, o
  viceversa) como señal de detección.

## 7. Checklist seguridad física
```
- [ ] Acceso físico por capas, mínimo privilegio y revisión periódica
- [ ] Anti-tailgating y gestión de visitantes en zonas sensibles
- [ ] Logs de acceso + CCTV con retención conforme a privacidad
- [ ] Controles ambientales y redundancia acordes a criticidad
- [ ] Física de proveedores cloud/colo verificada por atestación
- [ ] Control y cifrado de medios; cifrado de disco en dispositivos
- [ ] Hardware con procedencia, secure boot y debug cerrado en prod
- [ ] Borrado/destrucción segura con evidencia en fin de vida
- [ ] Identidad físico-lógica sincronizada (altas/bajas)
```
