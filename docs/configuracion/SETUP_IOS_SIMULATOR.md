# 📱 Guía: Configurar iOS Simulator para Probar Offline First

## ✅ Pasos a Seguir (en orden)

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
~/development/flutter/bin/flutter devices
```

Deberías ver algo como:
```
iPhone 15 Pro (mobile) • 12345678-1234-1234-1234-123456789ABC • ios • com.apple.CoreSimulator.SimRuntime.iOS-17-0 (simulator)
```

### 7. Ejecutar la app en el simulador

```bash
cd /Users/emmclaraso/development/unp_calendario
~/development/flutter/bin/flutter run -d ios
```

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
- Verificar: `~/development/flutter/bin/flutter devices`

### Errores de compilación en iOS
- Limpiar build: `~/development/flutter/bin/flutter clean`
- Reinstalar pods: `cd ios && pod install && cd ..`
- Rebuild: `~/development/flutter/bin/flutter run -d ios`

## 📝 Notas

- La primera vez que ejecutes en iOS puede tardar más (compilación inicial)
- El simulador puede tardar en iniciar la primera vez
- Si cambias de dispositivo en el simulador, puede que necesites recompilar

