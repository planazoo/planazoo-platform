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
| `sync_queue` | Operaciones pendientes (`create` / `update` / `delete` + payload) | `SyncQueueService` |
| **`current_user`** | **Un único documento** (`key: current`): perfil del usuario autenticado alineado con `UserModel` | **`UserLocalService` + `AuthNotifier`** |

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
   - Verificar regla vigente: "último cambio gana" (según `updatedAt`).

**Criterio de cierre del 58**
- Si pasan 1-4: marcar `hecho`.
- Si falla algún bloque: mantener `en curso` y anotar bloqueo específico (cola, reconexión, conflictos, UX).

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
- [ ] Puedes crear nuevos planes/eventos (se guardan localmente)
- [ ] Puedes editar planes/eventos existentes (se guardan localmente)
- [ ] Los cambios se añaden a la cola de sincronización

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
- [ ] Los conflictos se resuelven (último cambio gana)

### 5. Resolución de Conflictos

Para probar conflictos:

1. **Crear conflicto manualmente:**
   - Modificar un plan en la app (offline)
   - Modificar el mismo plan desde otra app/dispositivo (online)
   - Volver a conectar la app offline
   - Verificar que el último cambio gana

2. **Verificar logs:**
   - Buscar mensajes "Conflicto resuelto (último cambio gana)" en la consola

### 6. Cola de Sincronización

- [ ] Crear varios cambios offline
- [ ] Verificar que todos se añaden a la cola
- [ ] Volver a conectar
- [ ] Verificar que todos se sincronizan
- [ ] Verificar retry automático si hay errores

### 7. Sincronización en Tiempo Real

- [ ] Con la app abierta, hacer cambios desde otra app/dispositivo
- [ ] Verificar que los cambios aparecen automáticamente
- [ ] Verificar que se guardan localmente

## 🔍 Verificación de Logs

Buscar en la consola:

- `Hive inicializado correctamente` - Hive funcionando
- `ConnectivityService inicializado` - Conectividad funcionando
- `RealtimeSyncService inicializado` - Sincronización en tiempo real activa
- `Item añadido a cola de sincronización` - Cola funcionando
- `Item guardado localmente: current [current_user]` - Snapshot de perfil en Hive (tras guardado exitoso desde `AuthNotifier`)
- `Conflicto resuelto` - Resolución de conflictos funcionando
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
- Verificar que Hive está inicializado
- Verificar logs de `LocalStorageService`
- Verificar que los servicios usan los servicios locales cuando están offline

## 📝 Notas

- El sistema offline solo funciona en móviles (iOS/Android)
- En web, la app funcionará normalmente pero sin capacidades offline
- Los cambios offline se guardan en Hive y se sincronizan cuando hay conexión
- La resolución de conflictos usa "último cambio gana" basado en `updatedAt`
- El perfil del usuario autenticado tiene copia en Hive (`current_user`) para arranque y sesión sin Firestore
- Casos de prueba formales (checklist): [TESTING_CHECKLIST.md](../configuracion/TESTING_CHECKLIST.md) — sección 15.2 (**OFF-PROF-001**, **OFF-PROF-002**); borrado de cuenta **USER-D-007** (paso 5, móvil)

**Última actualización:** Abril 2026 (box `current_user` + flujo Auth documentados)

