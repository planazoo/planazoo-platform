## Lista de puntos a corregir en la app (solo abiertos)

**Objetivo:** mantener aquí solo los puntos **pendientes / en progreso** de QA.

**Histórico de cerrados:**
- `ARCHIVO_LISTA_PUNTOS_CORREGIR_APP_2026_03.md` (bloque histórico 1-33 y P3-P20).
- `ARCHIVO_LISTA_PUNTOS_CORREGIR_APP_2026_04.md` (cierres de 34-109, excepto abiertos actuales).

---

### 1. Información del build (rellenar en cada ronda)

- **Versión de la app**:
- **Origen**: TestFlight / Web / Android / …
- **Fecha de la ronda de pruebas**:
- **Build ID (si aplica)**:

---

### 2. Cómo anotar cada punto nuevo

- **ID**: siguiente libre **110**.
- **Plataforma**: iOS / Web / Ambas / …
- **Pantalla / flujo**.
- **Tipo**: bug / mejora / copy / producto / discusión.
- **Gravedad**: alta / media / baja.
- **Descripción breve**.
- **Estado**: pendiente / en progreso / hecho.

> Al cerrar un punto: moverlo al archivo histórico del periodo para que esta lista siga limpia.

---

### 3. Resumen actual

- **Pendientes:** 0
- **En progreso:** 1 (`109`)
- **Movidos a TASKS.md como tareas nuevas:** `63`→`T263`, `64`→`T264`, `65`→`T265`, `98`→`T266`
- **Hechos/cerrados en histórico:** 71 (movidos fuera de este documento; `66` cerrado en 2026-04-09)

---

### 4. Puntos abiertos

| ID | Plataforma | Pantalla / flujo | Tipo | Gravedad | Descripción breve | Estado |
|----|------------|------------------|------|----------|-------------------|--------|
| 109 | iOS (+Ambas) | Notificaciones push | infra | alta | Completar pruebas reales de push en iOS (foreground/background/terminada). Referencias: `ACCIONES_PENDIENTES_APP.md` y `CHECKLIST_IOS_PUSH_DEEPLINKS.md`. | en progreso |

---

### 5. Referencias rápidas

- Normas: `docs/configuracion/CONTEXT.md`
- Tareas Txxx relacionadas: `docs/tareas/TASKS.md`
- Offline móvil (58 cerrado): `docs/testing/TESTING_OFFLINE_FIRST.md`
- Push iOS: `docs/testing/ACCIONES_PENDIENTES_APP.md`, `docs/configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md`
- Testing formal / regresiones: `docs/configuracion/TESTING_CHECKLIST.md`