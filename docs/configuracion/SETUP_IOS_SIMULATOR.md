# 📱 Guía: Probar la App en iOS Simulator

**✅ No se requiere cuenta de desarrollador de Apple** - El iOS Simulator es completamente gratuito.

## 🎯 Resumen Rápido

1. Abrir iOS Simulator
2. Ejecutar: `flutter run -d ios`

---

## ✅ Pasos Detallados (en orden)

### 1. Instalar Xcode
- ✅ Descargar desde App Store (en proceso)
- ⏳ Esperar a que termine la instalación (~15 GB)

### 2. Configurar Xcode (después de instalación)

Una vez instalado Xcode, ejecuta estos comandos:

```bash
# Configurar Xcode como herramienta de desarrollo
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# Ejecutar primera configuración de Xcode
sudo xcodebuild -runFirstLaunch

# Aceptar la licencia de Xcode
sudo xcodebuild -license accept
```

### 3. Instalar CocoaPods (necesario para plugins de iOS)

```bash
sudo gem install cocoapods
```

### 4. Configurar dependencias de iOS del proyecto

```bash
cd /Users/emmclaraso/development/unp_calendario
cd ios
pod install
cd ..
```

### 5. Abrir el Simulador de iOS

```bash
# Abrir Simulador desde línea de comandos
open -a Simulator

# O desde Xcode: Xcode → Open Developer Tool → Simulator
```

### 6. Verificar que Flutter detecta el simulador

```bash
flutter devices
```

Deberías ver algo como:
```
iPhone 15 Pro (mobile) • 12345678-1234-1234-1234-123456789ABC • ios • com.apple.CoreSimulator.SimRuntime.iOS-17-0 (simulator)
```

**Si no aparece ningún dispositivo iOS:**
- Asegúrate de que el Simulator esté abierto: `open -a Simulator`
- Espera unos segundos y vuelve a ejecutar `flutter devices`

### 7. Ejecutar la app en el simulador

Desde la raíz del proyecto:

```bash
cd /Users/emmclaraso/development/unp_calendario
flutter run -d ios
```

**Nota:** La primera vez puede tardar varios minutos (compilación inicial). Las siguientes veces será más rápido.

### 8. Probar el sistema offline

Una vez que la app esté corriendo:

#### Simular modo offline:
```bash
# Desactivar conexión de datos
xcrun simctl status_bar booted override --dataNetwork none
```

#### Restaurar conexión:
```bash
# Activar WiFi
xcrun simctl status_bar booted override --dataNetwork wifi
```

## 🔍 Verificaciones

### Cuando la app esté corriendo:

1. **Modo Online:**
   - ✅ La app carga datos normalmente
   - ✅ No aparece banner de "Sin conexión"
   - ✅ Los cambios se guardan en Firestore

2. **Modo Offline:**
   - ✅ Aparece banner naranja "Sin conexión - Modo offline activo"
   - ✅ Puedes crear/editar planes y eventos
   - ✅ Los cambios se guardan localmente (Hive)

3. **Sincronización:**
   - ✅ Al volver a conectar, los cambios se sincronizan automáticamente
   - ✅ Los datos remotos se actualizan localmente

## ⚠️ Problemas Comunes

### "Xcode installation is incomplete"
- Ejecutar: `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
- Ejecutar: `sudo xcodebuild -runFirstLaunch`

### "CocoaPods not installed"
- Instalar: `sudo gem install cocoapods`
- Si falla, puede necesitar: `brew install cocoapods`

### "No devices found"
- Abrir Simulator: `open -a Simulator`
- Esperar a que el simulador termine de iniciar
- Verificar: `flutter devices`
- Si usas **iPhone físico**, ver sección [Dispositivo físico iPhone](#dispositivo-físico-iphone) (emparejamiento / Confiar).

### Errores de compilación en iOS
- Limpiar build: `flutter clean`
- Reinstalar pods: `cd ios && pod install && cd ..`
- Rebuild: `flutter run -d ios`

---

## Dispositivo físico iPhone

Hace falta **Apple Developer** (cuenta de pago) y signing en Xcode (Team del proyecto).

1. Conectar el iPhone por USB y **desbloquearlo**.
2. En el iPhone: aceptar **«¿Confiar en este ordenador?»** si aparece.
3. Si Flutter / Xcode dicen *unpaired* / *not available because it is unpaired*:
   - Mac: **Xcode → Window → Devices and Simulators**
   - Seleccionar el iPhone y completar el emparejamiento; responder prompts en el teléfono.
4. Verificar:

```bash
flutter devices
```

Ejemplo del repo: `iPhone de Andorra` → id `00008030-001869E83699402E`.

5. Ejecutar:

```bash
flutter run -d 00008030-001869E83699402E
# o el id que muestre flutter devices
```

Push / deep links: validar siempre en físico — [`CHECKLIST_IOS_PUSH_DEEPLINKS.md`](./CHECKLIST_IOS_PUSH_DEEPLINKS.md).  
Matriz 3 dispositivos: [`USUARIOS_PRUEBA.md`](./USUARIOS_PRUEBA.md#matriz-mínima-multiplataforma-3-usuarios--3-dispositivos).  
Android físico: [`SETUP_ANDROID_LOCAL.md`](./SETUP_ANDROID_LOCAL.md).

## 📝 Notas Importantes

- **✅ Simulador:** no requiere cuenta de desarrollador de pago.
- **⏱️ Primera ejecución:** puede tardar varios minutos (compilación inicial).
- **📱 Dispositivo físico:** requiere cuenta Apple Developer + Trust / emparejamiento (sección anterior).
- **🔄 Cambios de dispositivo:** si cambias el modelo en el simulador, puede hacer falta recompilar.
- **🌐 Conexión:** el simulador usa la red del Mac.

## 🚫 Limitaciones del Simulador

- ✅ Login, eventos, calendario, etc. en UI.
- ❌ Push reales APNs / FCM end-to-end → dispositivo físico.
- ❌ Algunas APIs (cámara, GPS real) son simuladas o limitadas.
- ❌ Publicar en App Store → ver [`FASTLANE_IOS_APPSTORE.md`](./FASTLANE_IOS_APPSTORE.md).

