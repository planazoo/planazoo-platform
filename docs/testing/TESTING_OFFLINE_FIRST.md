# 🧪 Guía de Testing - Sistema Offline First

## 📱 Requisitos

- **Plataforma**: iOS o Android (NO funciona en web)
- **Dispositivo/Emulador**: iOS Simulator o Android Emulator funcionando

## 🗄️ Persistencia local (Hive) — inventario canónico

Solo **móvil** (`HiveService.isMobile`). En web estas operaciones se ignoran.

| Box (`HiveService`) | Contenido | Origen principal |
|---------------------|-----------|------------------|
| `plans` | Snapshots de planes del usuario | `RealtimeSyncService` + `PlanLocalService` |
| `events` | Eventos (no alojamientos en esta caja) | `RealtimeSyncService` + `EventLocalService` |
| `participations` | `plan_participations` activas | `RealtimeSyncService` + `ParticipationLocalService` |
| `sync_queue` | Operaciones pendientes (`create` / `update` / `delete` + payload) | `SyncQueueService` + `SyncService` *(infra preparada; ver arquitectura abajo)* |
| **`current_user`** | **Un único documento** (`key: current`): perfil del usuario autenticado alineado con `UserModel` | **`UserLocalService` + `AuthNotifier`** |

### Arquitectura offline en móvil (fuente de verdad operativa)

Para **planes, eventos y participaciones**, el comportamiento offline que usa la app hoy se apoya en:

1. **Persistencia offline de Firestore** (activada por defecto en iOS/Android): las lecturas con `.snapshots()` / `.get()` pueden servirse desde caché local; las **escrituras** sin red quedan en la **cola del SDK** y se envían al volver la conectividad.
2. **Hive (`plans`, `events`, `participations`)** como **réplica** cuando hay red: `RealtimeSyncService` escucha Firestore y actualiza cajas vía `*LocalService`.
3. **`current_user` en Hive** para **perfil**: arranque y sesión coherentes si Firestore no responde pero Auth sigue válido (no lo sustituye el SDK de la misma forma).

La **`sync_queue` propia** y **`SyncService.syncAll`** (`lib/features/offline/domain/services/sync_service.dart`) implementan cola explícita + resolución “último `updatedAt` gana” para alinear Hive ↔ remoto, pero **no están cableadas** al reconectar como segundo motor de sync sobre las mismas escrituras (no conviene duplicar la cola del SDK sin diseño explícito). Evolución posible: tareas **T56–T62** / roadmap offline. Hasta entonces, las pruebas de “reconexión y conflictos” deben interpretarse en términos de **Firestore + reglas de negocio en servidor**, no de logs `Item añadido a cola de sincronización` en rutas normales de creación de eventos.

### Perfil en `current_user` (offline-first)

- **Escritura:** tras un login exitoso con datos cargados desde Firestore (`getUser` OK), se guarda en Hive el `UserModel` actualizado (en segundo plano).
- **Lectura:** si `getUser` devuelve `null` o falla la red (timeout / excepción), pero Firebase Auth sigue con sesión válida, se intenta **restaurar** el perfil desde Hive **solo si** el `id` cacheado coincide con `firebaseUser.uid`.
- **Borrado:** al cerrar sesión (`firebaseUser == null`), se elimina la entrada `current` para no mezclar cuentas.

**Código de referencia:** `lib/features/offline/domain/services/user_local_service.dart`, `lib/features/offline/domain/services/hive_service.dart`, `lib/features/auth/presentation/notifiers/auth_notifier.dart`.

**Flujo de producto (registro/login/perfil):** la misma lógica está resumida en [`docs/flujos/FLUJO_CRUD_USUARIOS.md`](../flujos/FLUJO_CRUD_USUARIOS.md) (sección *Snapshot de perfil en Hive*).

Si no hay snapshot en Hive y Firestore no responde, el arranque sigue el fallback con `UserModel.fromFirebaseAuth` (datos mínimos desde Auth).

## 🚀 Ejecutar la App

### iOS
```bash
flutter run -d ios
```

### Android
```bash
flutter run -d android
```

## ✅ Checklist de Pruebas

### 0. Ejecución rápida para cerrar ítem 58 (15-20 min)

Objetivo: decidir **funciona / no funciona / parcial** con evidencia mínima reproducible.

1. **Baseline online (2 min)**
   - Abrir app con sesión iniciada.
   - Confirmar logs: `ConnectivityService inicializado` + eventos `REALTIME_SYNC`.
2. **Corte de red (4 min)**
   - Forzar offline en simulador/dispositivo.
   - Verificar banner `Sin conexión - Modo offline activo`.
   - **(Opcional ítem 58+)** Con sesión ya abierta, hacer **cold start** (matar app y abrir) en offline: debe entrar a la app (no quedarse en “Cargando…”) y el perfil debe coincidir con el último guardado en Hive cuando Firestore no responde.
   - Crear o editar al menos 1 dato visible (p. ej. evento o nota) sin cerrar app.
3. **Reconexión (4 min)**
   - Restaurar red.
   - Verificar transición a online y que el cambio realizado offline termina persistido.
4. **Chequeo de conflicto simple (5-8 min)**
   - Modificar el mismo dato en dos clientes (uno offline y otro online).
   - Reconectar cliente offline.
   - Verificar coherencia con **Firestore** (convención típica: última escritura al documento prevalece al sincronizar; no exigir log `Conflicto resuelto` del `SyncService` en rutas actuales).

**Criterio de cierre del 58**
- Si pasan 1-4: marcar `hecho` en la lista de puntos (ver `LISTA_PUNTOS_CORREGIR_APP.md`).
- Si falla algún bloque: mantener `en curso` y anotar bloqueo específico (reconexión Firestore, UX, perfil Hive, etc.).

### 1. Verificación Inicial

- [ ] La app se inicia correctamente
- [ ] No hay errores en la consola relacionados con Hive
- [ ] El indicador de conectividad aparece (verde cuando hay conexión)

### 2. Modo Online (Conexión Normal)

- [ ] Los datos se cargan desde Firestore
- [ ] Los cambios se guardan en Firestore
- [ ] El indicador muestra estado "online" (verde o no visible)
- [ ] Los cambios se sincronizan en tiempo real entre dispositivos

### 3. Modo Offline (Sin Conexión)

#### Simular Offline en iOS Simulator:
```bash
# Desactivar WiFi
xcrun simctl status_bar booted override --dataNetwork none

# O desde Settings → Developer → Network Link Conditioner → Enable → 100% Loss
```

#### Simular Offline en Android Emulator:
```bash
# Modo avión
adb shell svc wifi disable && adb shell svc data disable

# O desde Settings → Network & Internet → Airplane Mode
```

#### Pruebas en Modo Offline:

- [ ] El indicador muestra "Sin conexión - Modo offline activo" (banner naranja)
- [ ] Tras un login online previo, **reinicio en frío offline**: la app arranca y muestra usuario coherente (Hive `current_user` + Auth)
- [ ] La app sigue funcionando (puedes navegar, ver datos)
- [ ] Puedes crear nuevos planes/eventos (persistencia local vía **caché/ cola de Firestore**)
- [ ] Puedes editar planes/eventos existentes (igual)
- [ ] Tras reconectar, los cambios pendientes del SDK llegan a Firestore (la **`sync_queue` Hive** no es el camino activo para este CRUD)

### 4. Sincronización (Volver a Online)

#### Restaurar Conexión:

**iOS:**
```bash
xcrun simctl status_bar booted override --dataNetwork wifi
```

**Android:**
```bash
adb shell svc wifi enable && adb shell svc data enable
```

#### Pruebas de Sincronización:

- [ ] El indicador vuelve a verde (online)
- [ ] Los cambios pendientes se sincronizan automáticamente
- [ ] Los datos locales se actualizan con cambios remotos
- [ ] No hay pérdida de datos
- [ ] Tras ediciones concurrentes, los datos convergen con lo que refleje Firestore (sin depender de `SyncService.syncAll` en la build actual)

### 5. Resolución de Conflictos

Para probar conflictos:

1. **Crear conflicto manualmente:**
   - Modificar un plan en la app (offline)
   - Modificar el mismo plan desde otra app/dispositivo (online)
   - Volver a conectar la app offline
   - Verificar que el último cambio gana

2. **Verificar comportamiento:**
   - Coherencia de datos tras reconectar; el mensaje de log `Conflicto resuelto (último cambio gana)` en `SyncService` solo aplica si en el futuro se invoca `syncAll` / cola explícita.

### 6. Cola de escrituras pendientes (Firestore)

- [ ] Crear varios cambios offline (p. ej. varios eventos)
- [ ] Volver a conectar
- [ ] Verificar que los documentos aparecen en Firestore / en otros clientes (el SDK reintenta envíos)
- [ ] *(Opcional avanzado)* Inspección local: caché de Firestore; no confundir con la caja Hive `sync_queue` reservada para futuro `SyncService`

### 7. Sincronización en Tiempo Real

- [ ] Con la app abierta, hacer cambios desde otra app/dispositivo
- [ ] Verificar que los cambios aparecen automáticamente
- [ ] Verificar que se guardan localmente

## 🔍 Verificación de Logs

Buscar en la consola:

- `Hive inicializado correctamente` - Hive funcionando
- `ConnectivityService inicializado` - Conectividad funcionando
- `RealtimeSyncService inicializado` - Listeners activos (réplica Hive cuando hay red)
- `Item añadido a cola de sincronización` - Solo si se usa la cola Hive explícita (hoy **no** en flujo normal CRUD planes/eventos)
- `Item guardado localmente: current [current_user]` - Snapshot de perfil en Hive (tras guardado exitoso desde `AuthNotifier`)
- `Conflicto resuelto` - Solo si se ejecuta la ruta de `SyncService` con cola/remoto (hoy no cableada al reconectar)
- `Evento sincronizado en tiempo real` - Sincronización automática funcionando

## ⚠️ Problemas Comunes

### Hive no se inicializa
- Verificar que estás en iOS/Android (no web)
- Verificar logs de inicialización

### Indicador no aparece
- Verificar que `ConnectivityIndicator` está en `AuthGuard`
- Verificar que el usuario está autenticado

### Sincronización no funciona
- Verificar que el usuario está autenticado
- Verificar logs de `RealtimeSyncService`
- Verificar conexión a Firestore

### Datos no se guardan offline
- Verificar persistencia de Firestore (SDK) y que la app no fuerza solo `Source.server` en rutas críticas
- Verificar que Hive está inicializado (perfil + réplica cuando vuelve la red)
- Verificar logs de `LocalStorageService` / `RealtimeSyncService`

## 📝 Notas

- El sistema offline solo funciona en móviles (iOS/Android)
- En web, la app funcionará normalmente pero sin capacidades offline
- Los cambios offline de planes/eventos pasan por la **caché y cola del cliente Firestore**; Hive refleja el remoto al estar online
- Conflictos multi-dispositivo: reglas efectivas de **Firestore / última escritura**; `SyncService` documenta una estrategia `updatedAt` para cuando se active la cola Hive explícita
- El perfil del usuario autenticado tiene copia en Hive (`current_user`) para arranque y sesión sin Firestore
- Casos de prueba formales (checklist): [TESTING_CHECKLIST.md](../configuracion/TESTING_CHECKLIST.md) — **REG-2026-022** (§12.3, regresión ítem **58** / §0 de esta guía); sección 15 (**OFF-001–004**, **OFF-PROF-001**, **OFF-PROF-002**); borrado de cuenta **USER-D-007** (paso 5, móvil)

**Última actualización:** Abril 2026 — `current_user`; arquitectura Firestore-first vs `sync_queue` Hive aclarada

