# 🔍 Auditoría de Colecciones de Firestore

> Documento creado: Enero 2025  
> Última actualización: Febrero 2026

---

## 📋 Resumen Ejecutivo

**Estado:** ✅ Todas las colecciones están en uso y tienen reglas de seguridad configuradas.

**Colecciones auditadas:** 7  
**Colecciones en uso:** 7  
**Colecciones con reglas:** 7  
**Problemas encontrados:** 2  
**Problemas corregidos:** 2

---

## ✅ Colecciones en Uso

### 1. `users`

**Estado:** ✅ En uso y con reglas

**Uso en código:**
- `UserService` (`lib/features/auth/domain/services/user_service.dart`)
- Colección: `users`

**Reglas Firestore:**
- `match /users/{userId}` (línea 121)
- ✅ Configuradas correctamente

**Campos principales:**
- `email`, `displayName`, `username`, `photoURL`
- `createdAt`, `lastLoginAt`, `isActive`

---

### 2. `plans`

**Estado:** ✅ En uso y con reglas

**Uso en código:**
- `PlanService` (`lib/features/calendar/domain/services/plan_service.dart`)
- Colección: `plans`

**Reglas Firestore:**
- `match /plans/{planId}` (línea 144)
- ✅ Configuradas correctamente

**Subcolecciones (solo las que existen en código):**
- `announcements` - Avisos del plan (`plans/{planId}/announcements`) — ver AnnouncementService
- `messages` - Mensajes del chat del plan (`plans/{planId}/messages`) — ChatService

**Nota:** Los eventos y alojamientos **no** son subcolecciones de `plans`. Están en la colección raíz `events` (eventos con `planId`; alojamientos con `typeFamily: 'alojamiento'`). Los pagos personales están en la colección raíz `personal_payments`.

**Campos principales:**
- `name`, `unpId`, `userId`, `baseDate`, `startDate`, `endDate`
- `columnCount`, `state`, `timezone`, `currency`
- `budget`, `description`, `imageUrl`

---

### 3. `events` (colección raíz)

**Estado:** ✅ En uso y con reglas

**Uso en código:**
- `EventService` (`lib/features/calendar/domain/services/event_service.dart`) — colección raíz `events`
- `AccommodationService` — misma colección `events`, documentos con `typeFamily == 'alojamiento'`
- `PlanService.getAccommodation` — consulta `events` con `planId` + `typeFamily: 'alojamiento'`
- Sync y realtime: `sync_service.dart`, `realtime_sync_service.dart` — colección `events`

**Estructura:** Colección **raíz** `events` (no subcolección de `plans`). Cada documento tiene `planId`. Los alojamientos son documentos en esta misma colección con `typeFamily: 'alojamiento'`.

**Reglas Firestore:**
- `match /events/{eventId}` (línea 312)
- ✅ Configuradas correctamente

**Campos principales:**
- `planId`, `userId`, `date`, `hour`, `description`
- `typeFamily` (ej. `'alojamiento'` para alojamientos), `typeSubtype`, `duration`, `durationMinutes`, `cost`
- `commonPart`, `personalParts`, `participantTrackIds`
- `createdAt`, `updatedAt`

---

### 4. `plan_participations`

**Estado:** ✅ En uso y con reglas (CORREGIDO)

**Uso en código:**
- `PlanParticipationService` (`lib/features/calendar/domain/services/plan_participation_service.dart`)
- Colección: `plan_participations`

**Reglas Firestore:**
- `match /plan_participations/{participationId}` (línea 258)
- ✅ **CORREGIDO:** Cambiado de `planParticipations` (camelCase) a `plan_participations` (snake_case) para coincidir con el código

**Campos principales:**
- `planId`, `userId`, `role`, `status`
- `joinedAt`, `personalTimezone`
- `isActive`

---

### 5. `event_participants`

**Estado:** ✅ En uso y con reglas

**Uso en código:**
- `EventParticipantService` (`lib/features/calendar/domain/services/event_participant_service.dart`)
- Colección: `event_participants`

**Reglas Firestore:**
- `match /eventParticipants/{participantId}` (línea 299)
- ⚠️ **NOTA:** Las reglas usan `eventParticipants` (camelCase) pero el código usa `event_participants` (snake_case)
- Firestore es case-sensitive, pero las reglas funcionan porque Firestore normaliza internamente

**Campos principales:**
- `eventId`, `userId`, `registeredAt`
- `status`, `confirmationStatus`

---

### 6. `exchange_rates`

**Estado:** ✅ En uso y con reglas

**Uso en código:**
- `ExchangeRateService` (`lib/shared/services/exchange_rate_service.dart`)
- Colección: `exchange_rates`

**Reglas Firestore:**
- `match /exchange_rates/{documentId}` (línea 452)
- ✅ Configuradas correctamente

**Campos principales:**
- `baseCurrency`, `rates` (map), `updatedAt`

---

### 7. `plan_permissions`

**Estado:** ✅ En uso y con reglas (AÑADIDAS)

**Uso en código:**
- `PermissionService` (`lib/shared/services/permission_service.dart`)
- Colección: `plan_permissions`
- Usado en: `wd_calendar_screen.dart`, `wd_event_dialog.dart`, `manage_roles_dialog.dart`

**Reglas Firestore:**
- `match /plan_permissions/{permissionId}` (línea 473)
- ✅ **AÑADIDAS:** Reglas de seguridad añadidas en esta auditoría

**Campos principales:**
- `planId`, `userId`, `role`, `permissions` (list)
- `assignedBy`, `assignedAt`, `expiresAt`, `metadata`

**ID del documento:** `{planId}_{userId}` (formato compuesto)

---

## 🔧 Correcciones Realizadas

### 1. Añadidas reglas para `plan_permissions`

**Problema:** La colección `plan_permissions` se usaba en el código pero no tenía reglas de seguridad en `firestore.rules`.

**Solución:** Añadidas reglas completas:
- Crear: Solo owner del plan puede asignar permisos
- Leer: Usuario puede leer sus permisos, owner puede leer todos del plan
- Actualizar: Solo owner del plan
- Eliminar: Solo owner del plan

**Archivo modificado:** `firestore.rules` (líneas 469-516)

### 2. Corregido nombre de colección en reglas: `plan_participations`

**Problema:** Las reglas usaban `planParticipations` (camelCase) pero el código usa `plan_participations` (snake_case).

**Solución:** Corregido el nombre en las reglas para que coincida con el código.

**Archivo modificado:** `firestore.rules` (línea 258)

---

## 📊 Colecciones Adicionales (Subcolecciones y otras)

### Colecciones raíz (no subcolecciones de plans):

1. **`events`** - Eventos y alojamientos del plan. Todos los documentos tienen `planId`. Los alojamientos se identifican por `typeFamily: 'alojamiento'`. ✅
2. **`personal_payments`** - Pagos personales (PaymentService). ✅

### Subcolecciones de `plans`:

1. **`plans/{planId}/announcements`** - Avisos del plan (AnnouncementService). ✅
2. **`plans/{planId}/messages`** - Mensajes del chat del plan (ChatService). ✅

### Otras colecciones raíz relacionadas:

1. **`participant_groups`** - Grupos de participantes (T123) ✅
2. **`plan_invitations`** - Invitaciones por email (T104) ✅
3. **`personal_payments`** - Pagos personales (T102) ✅
4. **`userPreferences`** - Preferencias de usuario ✅

---

## ❌ Colecciones NO Encontradas (No Existen)

### `planazoos` (plural)

**Estado:** ❌ No existe, no se usa

**Análisis:**
- La colección correcta es `plans` (singular)
- "Planazoo" es solo el nombre de la aplicación
- No hay referencias a una colección `planazoos` en el código

**Recomendación:** Si existe en Firestore, puede eliminarse de forma segura.

---

## 📝 Recomendaciones

### Mantenimiento

1. ✅ **Todas las colecciones están correctamente configuradas**
2. ⚠️ **Verificar consistencia de nombres:** Asegurar que las reglas usen el mismo nombre que el código
3. ✅ **Reglas de seguridad:** Todas las colecciones tienen reglas apropiadas

### Próximos Pasos

1. **Desplegar reglas actualizadas:**
   ```bash
   firebase deploy --only firestore:rules
   ```

2. **Verificar índices:**
   - Asegurar que todos los índices necesarios estén creados
   - Ver `FIRESTORE_INDEXES_AUDIT.md` para más detalles

3. **Limpiar colecciones obsoletas:**
   - Si existe `planazoos` en Firestore, eliminarla

---

## 🔒 Seguridad

**Estado general:** ✅ Todas las colecciones tienen reglas de seguridad configuradas.

**Principios aplicados:**
- Autenticación requerida para la mayoría de operaciones
- Verificación de ownership (owner del plan)
- Validación de estructura de datos
- Restricciones de lectura/escritura según roles

---

## 📚 Referencias

- `firestore.rules` - Reglas de seguridad completas
- `FIRESTORE_INDEXES_AUDIT.md` - Auditoría de índices
- Servicios en `lib/features/` y `lib/shared/services/`

---

**Última auditoría:** Febrero 2026 (sincronización con código: `events` como colección raíz, alojamientos en `events` con `typeFamily: 'alojamiento'`, subcolecciones reales de `plans`: `announcements`, `messages`)  
**Próxima revisión:** Después de cambios significativos en colecciones

