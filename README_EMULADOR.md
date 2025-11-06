# 📱 Ejecutar App en Emulador Android - Guía Rápida

## ✅ Requisitos Previos

- ✅ Emulador Android instalado y disponible
- ✅ Flutter SDK instalado
- ✅ Emulador corriendo (visible en pantalla)

## 🚀 Ejecución Rápida

### Problema Común

Si ejecutas `flutter run` y solo ves Windows/Chrome/Edge pero no el emulador Android, es porque las variables de entorno no están configuradas.

### Solución Rápida (3 opciones)

#### Opción 1: Script Automático (Recomendado)
```powershell
.\ejecutar-flutter.ps1
flutter run
```

#### Opción 2: Comando Manual (Una línea)
```powershell
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"; $env:PATH += ";$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\emulator;$env:ANDROID_HOME\tools;$env:ANDROID_HOME\tools\bin;C:\Users\cclaraso\Downloads\flutter\bin"; flutter run
```

#### Opción 3: Configurar Variables y Ejecutar
```powershell
# Configurar variables
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
$env:PATH += ";$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\emulator"
$env:PATH += ";C:\Users\cclaraso\Downloads\flutter\bin"

# Verificar que detecta el emulador
flutter devices

# Ejecutar
flutter run
```

## 📋 Verificar que Funciona

### 1. Verificar que el emulador está corriendo
```powershell
& "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\platform-tools\adb.exe" devices
```

**Debería mostrar:**
```
List of devices attached
emulator-5554   device
```

### 2. Verificar que Flutter detecta el emulador
```powershell
flutter devices
```

**Debería mostrar:**
```
sdk gphone x86 (mobile) • emulator-5554 • android-x86 • Android 11 (API 30) (emulator)
```

## 🔧 Si el Emulador No Está Corriendo

### Iniciar el emulador:
```powershell
.\iniciar-emulador.ps1
```

O manualmente:
```powershell
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
Start-Process -FilePath "$env:ANDROID_HOME\emulator\emulator.exe" -ArgumentList "-avd", "Pixel_7_API_30_cricla" -WindowStyle Normal
```

Espera 30-45 segundos a que inicie completamente.

## ⚠️ Nota Importante

**Las variables de entorno se configuran solo para la sesión actual de PowerShell.**

Si cierras y abres una nueva terminal, necesitarás ejecutar el script o los comandos de configuración nuevamente.

## 🔄 Para Configurar Permanentemente

Si quieres evitar configurar las variables cada vez:

1. **Abre Variables de Entorno de Windows:**
   - `Win + R` → `sysdm.cpl` → "Opciones avanzadas" → "Variables de entorno"

2. **Añade estas variables:**
   - `ANDROID_HOME` = `C:\Users\cclaraso\AppData\Local\Android\Sdk`
   - Añade al `Path`:
     - `%ANDROID_HOME%\platform-tools`
     - `%ANDROID_HOME%\emulator`
     - `C:\Users\cclaraso\Downloads\flutter\bin`

3. **Reinicia la terminal** después de configurarlo

## 📝 Scripts Disponibles

- `ejecutar-flutter.ps1` - Configura variables y muestra dispositivos
- `iniciar-emulador.ps1` - Inicia el emulador automáticamente
- `iniciar-y-ejecutar.ps1` - Inicia emulador y ejecuta Flutter (todo en uno)

## 🐛 Troubleshooting

### "flutter: El término 'flutter' no se reconoce"
**Solución:** Flutter no está en el PATH. Ejecuta el script `ejecutar-flutter.ps1` o añade Flutter al PATH permanentemente.

### "No supported devices found"
**Solución:** El emulador no está corriendo o las variables de entorno no están configuradas. Ejecuta `ejecutar-flutter.ps1`.

### "Emulador no detectado"
**Solución:** 
1. Verifica que el emulador está visible en pantalla
2. Ejecuta `adb devices` para verificar conexión
3. Espera 30-45 segundos después de iniciar el emulador

---

**Última actualización:** Enero 2025

