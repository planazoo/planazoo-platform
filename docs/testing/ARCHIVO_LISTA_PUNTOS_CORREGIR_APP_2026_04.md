# Archivo — Lista de puntos corregidos (cerrados 2026-04)

**Documento histórico (solo lectura).**

- **Origen:** limpieza de `LISTA_PUNTOS_CORREGIR_APP.md` para dejarlo con solo abiertos.
- **Fecha de archivado:** 2026-04-09.
- **Rango principal:** cierres de las rondas **34-109**.
- **Nota:** tras limpieza posterior (2026-04-09), los ítems `63`, `64`, `65` y `98` se trasladaron a tareas nuevas en `TASKS.md` (`T263`, `T264`, `T265`, `T266`). El ítem `66` se cerró por implementación (2026-04-09). En la lista QA queda abierto solo `109`.

---

## Resumen de lo archivado

- **Total archivado en esta limpieza:** 71 puntos (hecho/cerrado).
- **Incluye cierre documental del ítem 58** (offline móvil):
  - Referencia de arquitectura y checklist: `docs/testing/TESTING_OFFLINE_FIRST.md`
  - Regresión formal asociada: `REG-2026-022` en `docs/configuracion/TESTING_CHECKLIST.md`

---

## Bloques archivados

### Ronda 2026-03-24 (IDs 34-61)

- Estado al archivar:
  - `34-57`, `59-61` → **hecho**
  - `58` → **hecho** (cierre documental 2026-04-08)

### Ronda 2026-03-27 (IDs 62-109)

- Estado al archivar:
  - `62`, `67-97`, `99-108` → **hecho**
  - `79` → **cerrado (decisión de producto)**
- Abiertos que no se archivaron en ese momento:
  - `63`, `64`, `65`, `66`, `98`, `109`
  - **Actualización 2026-04-09:** `63/64/65/98` se movieron de la lista QA a `TASKS.md` como `T263-T266`.
  - **Actualización 2026-04-09 (cierre):** `66` marcado como cerrado tras implementar bloque de vehículo alquiler en `wd_event_dialog.dart` y actualizar `EVENT_FORM_FIELDS.md`.

---

## Referencias de detalle

Para el detalle funcional de cada cierre (descripción, contexto y notas de implementación), consultar:

- Históricos previos: `docs/testing/ARCHIVO_LISTA_PUNTOS_CORREGIR_APP_2026_03.md`
- Checklist de regresión: `docs/configuracion/TESTING_CHECKLIST.md` (sección 12.3, casos `REG-2026-001` en adelante)
- Roadmap de tareas relacionadas: `docs/tareas/TASKS.md`

