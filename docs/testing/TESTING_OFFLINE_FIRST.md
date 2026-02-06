# 🧪 Guía de Testing - Sistema Offline First

## 📱 Requisitos

- **Plataforma**: iOS o Android (NO funciona en web)
- **Dispositivo/Emulador**: iOS Simulator o Android Emulator funcionando

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

**Última actualización:** Febrero 2026

