# 🚀 Iniciar Emulador Android - Guía Rápida

## 📋 Pasos para Usar el Emulador

### Paso 1: Iniciar el Emulador

**Opción A: Desde PowerShell (Recomendado)**
```powershell
# Iniciar emulador Pixel 7
Start-Process -FilePath "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\emulator\emulator.exe" -ArgumentList "-avd", "Pixel_7_API_30_cricla" -WindowStyle Normal

# O Pixel 3a (Android 14)
Start-Process -FilePath "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\emulator\emulator.exe" -ArgumentList "-avd", "Pixel_3a_API_34_extension_level_7_x86_64" -WindowStyle Normal
```

**Opción B: Comando directo**
```powershell
& "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\emulator\emulator.exe" -avd Pixel_7_API_30_cricla
```

**Opción C: Desde Android Studio**
1. Abre Android Studio
2. Tools → Device Manager
3. Selecciona un dispositivo AVD
4. Click en ▶️ Play

### Paso 2: Esperar a que el Emulador Inicie

- ⏱️ **Tiempo estimado:** 1-2 minutos
- Verás la pantalla de Android arrancando
- Espera hasta que aparezca la pantalla de inicio del dispositivo

### Paso 3: Verificar que Está Corriendo

**Verificar con ADB:**
```powershell
& "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\platform-tools\adb.exe" devices
```

**Salida esperada:**
```
List of devices attached
emulator-5554    device
```

### Paso 4: Ejecutar Flutter

**Opción A: Si Flutter está en PATH**
```bash
flutter run
```

**Opción B: Si Flutter NO está en PATH**
```powershell
# Primero, añadir Flutter al PATH temporalmente
$env:PATH += ";C:\Users\cclaraso\Downloads\flutter\bin"

# Luego ejecutar
flutter run
```

**Opción C: Usar ruta completa**
```powershell
C:\Users\cclaraso\Downloads\flutter\bin\flutter.bat run
```

## 🔧 Configurar Variables de Entorno (Permanente)

Para que Flutter detecte automáticamente el emulador, configura las variables de entorno:

### Windows

1. **Abrir Configuración:**
   - Presiona `Win + R`
   - Escribe `sysdm.cpl` y presiona Enter
   - Click en **Variables de entorno**

2. **Añadir Variables del Sistema:**
   
   **Nueva Variable:**
   - Nombre: `ANDROID_HOME`
   - Valor: `C:\Users\cclaraso\AppData\Local\Android\Sdk`
   
   **Editar Path:**
   - Selecciona `Path` en Variables del sistema
   - Click en **Editar**
   - Click en **Nuevo** y añade:
     - `%ANDROID_HOME%\platform-tools`
     - `%ANDROID_HOME%\emulator`
     - `%ANDROID_HOME%\tools`
     - `%ANDROID_HOME%\tools\bin`
   
   **Añadir Flutter al Path:**
   - Click en **Nuevo** y añade:
     - `C:\Users\cclaraso\Downloads\flutter\bin`

3. **Reiniciar Terminal:**
   - Cierra todas las ventanas de PowerShell/CMD
   - Abre una nueva terminal
   - Verifica con: `flutter doctor`

## ✅ Verificar Configuración

### Verificar que Flutter Detecta Android

```bash
flutter doctor
```

**Salida esperada:**
```
[✓] Android toolchain - develop for Android devices
    • Android SDK at C:\Users\cclaraso\AppData\Local\Android\Sdk
    • Platform android-34
    • Java development kit (JDK) version X.X.X
```

### Ver Dispositivos Disponibles

```bash
flutter devices
```

**Salida esperada (con emulador corriendo):**
```
Android SDK built for x86_64 (mobile) • emulator-5554 • android-x86_64 • Android 11 (API 30) (emulator)
Windows (desktop)                     • windows       • windows-x64   • Microsoft Windows [Versión 10.0.22621.4317]
Chrome (web)                          • chrome        • web-javascript • Google Chrome 141.0.7390.125
```

## 🐛 Troubleshooting

### Flutter no detecta el emulador

**Problema:** `flutter devices` no muestra el emulador

**Solución 1: Verificar que el emulador está corriendo**
```powershell
& "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\platform-tools\adb.exe" devices
```

**Solución 2: Reiniciar ADB**
```powershell
& "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\platform-tools\adb.exe" kill-server
& "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\platform-tools\adb.exe" start-server
& "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\platform-tools\adb.exe" devices
```

**Solución 3: Verificar variables de entorno**
```powershell
$env:ANDROID_HOME
```

Si está vacío, configúralo:
```powershell
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
```

### Error: "No supported devices found"

**Problema:** Flutter no encuentra dispositivos Android

**Solución:**
1. Verifica que el emulador está corriendo
2. Verifica que ADB detecta el dispositivo
3. Verifica que `ANDROID_HOME` está configurado
4. Reinicia la terminal después de configurar variables de entorno

### El emulador tarda mucho en iniciar

**Problema:** Emulador lento

**Solución:**
- Cierra otros programas que consuman RAM
- Espera 1-2 minutos (primera vez puede tardar más)
- Considera usar un emulador con menos RAM configurada

## 💡 Tips

### Script Rápido para Iniciar Todo

Crea un archivo `start-emulator.ps1`:

```powershell
# Configurar variables de entorno
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
$env:PATH += ";$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\emulator"

# Iniciar emulador
Start-Process -FilePath "$env:ANDROID_HOME\emulator\emulator.exe" -ArgumentList "-avd", "Pixel_7_API_30_cricla" -WindowStyle Normal

Write-Host "Esperando a que el emulador inicie..."
Start-Sleep -Seconds 30

# Verificar dispositivos
& "$env:ANDROID_HOME\platform-tools\adb.exe" devices

Write-Host "Emulador iniciado. Puedes ejecutar 'flutter run' ahora."
```

Ejecutar con:
```powershell
powershell -ExecutionPolicy Bypass -File start-emulator.ps1
```

### Cerrar el Emulador

**Opción A: Desde la interfaz**
- Cierra la ventana del emulador

**Opción B: Desde PowerShell**
```powershell
Get-Process | Where-Object {$_.ProcessName -like "*emulator*"} | Stop-Process
```

## 📝 Dispositivos Disponibles

| Nombre AVD | Android | API | Notas |
|-----------|---------|-----|-------|
| Pixel_7_API_30_cricla | Android 11 | 30 | Recomendado para desarrollo |
| Pixel_3a_API_34_extension_level_7_x86_64 | Android 14 | 34 | Última versión |

---

**Última actualización:** Enero 2025  
**Ruta SDK:** `C:\Users\cclaraso\AppData\Local\Android\Sdk`  
**Ruta Flutter:** `C:\Users\cclaraso\Downloads\flutter`

