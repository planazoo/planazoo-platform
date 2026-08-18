# Archivo — Lista de puntos corregidos (cerrados 2026-08)

**Documento histórico (solo lectura).**

- **Origen:** `LISTA_PUNTOS_CORREGIR_APP.md`.
- **Fecha de archivado:** 2026-08-18.
- **Rango:** **126**, **127** (cascada al borrar plan).

---

#### 127. Borrar plan (Info): `deleteEventsByPlanId` no elimina alojamientos
- **Fix:** `deleteEventsByPlanId` borra también docs `typeFamily: alojamiento`. `PlanService.deletePlan` llama a ese método.
- **Estado:** cerrado y validado por tests T277 P16
- **Referencias:** `event_service.dart` `deleteEventsByPlanId`; `plan_service.dart` `deletePlan`

#### 126. Borrar plan desde dashboard deja eventos huérfanos
- **Fix:** `deletePlan` llama a `deleteEventsByPlanId` (eventos + alojamientos). Dashboard e Info usan el mismo camino de servicio.
- **Estado:** cerrado y validado por tests T277 P16
- **Referencias:** `plan_service.dart` `deletePlan`; T277 P16
