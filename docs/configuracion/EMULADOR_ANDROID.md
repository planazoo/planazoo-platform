# 📱 Emulador Android - Planazoo

## ✅ Estado Actual

**Emulador Android:** ✅ Disponible  
**Android SDK:** `C:\Users\cclaraso\AppData\Local\Android\Sdk`  
**Dispositivos AVD disponibles:**
- `Pixel_3a_API_34_extension_level_7_x86_64`
- `Pixel_7_API_30_cricla`

## 🚀 Cómo Usar el Emulador

### 1. Iniciar el Emulador

**Opción A: Desde línea de comandos**
```powershell
# Establecer variable de entorno (opcional, solo para esta sesión)
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"

# Iniciar emulador específico
& "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\emulator\emulator.exe" -avd Pixel_7_API_30_cricla
```

**Opción B: Desde Android Studio**
1. Abre Android Studio
2. Ve a **Tools → Device Manager**
3. Selecciona un dispositivo AVD
4. Click en el botón **▶️ Play**

**Opción C: Listar dispositivos disponibles**
```powershell
& "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\emulator\emulator.exe" -list-avds
```

### 2. Verificar que el Emulador está Corriendo

```powershell
& "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\platform-tools\adb.exe" devices
```

**Salida esperada:**
```
List of devices attached
emulator-5554    device
```

### 3. Ejecutar Flutter en el Emulador

**Opción A: Flutter detecta automáticamente**
```bash
flutter run
```

**Opción B: Especificar dispositivo Android**
```bash
flutter run -d android
```

**Opción C: Especificar por ID de dispositivo**
```bash
# Primero ver dispositivos disponibles
flutter devices

# Luego ejecutar en el dispositivo específico
flutter run -d emulator-5554
```

### 4. Hot Reload

Mientras la app está corriendo en el emulador:
- Presiona `r` en la terminal para hot reload
- Presiona `R` para hot restart
- Presiona `q` para salir

## 🔧 Configuración

### Variables de Entorno (Recomendado)

Para que Flutter encuentre automáticamente el Android SDK, añade estas variables de entorno:

**Windows (Permanent):**
1. Abre **Configuración del Sistema** → **Configuración avanzada del sistema**
2. Click en **Variables de entorno**
3. En **Variables del sistema**, añade:
   - `ANDROID_HOME` = `C:\Users\cclaraso\AppData\Local\Android\Sdk`
   - Añade a `Path`:
     - `%ANDROID_HOME%\platform-tools`
     - `%ANDROID_HOME%\emulator`
     - `%ANDROID_HOME%\tools`
     - `%ANDROID_HOME%\tools\bin`

**Windows (Temporal - Solo esta sesión):**
```powershell
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
$env:PATH += ";$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\emulator"
```

### Verificar Configuración

```bash
flutter doctor
```

Deberías ver:
```
[✓] Android toolchain - develop for Android devices
    • Android SDK at C:\Users\cclaraso\AppData\Local\Android\Sdk
    • Platform android-34
    • Java development kit (JDK) version X.X.X
```

## 📱 Dispositivos Disponibles

### Pixel_7_API_30_cricla
- **Android:** API 30 (Android 11)
- **Arquitectura:** x86_64
- **Resolución:** Similar a Pixel 7

### Pixel_3a_API_34_extension_level_7_x86_64
- **Android:** API 34 (Android 14)
- **Arquitectura:** x86_64
- **Resolución:** Similar a Pixel 3a

## 🐛 Troubleshooting

### El emulador no aparece en `flutter devices`

**Problema:** Flutter no encuentra el Android SDK  
**Solución:**
1. Verifica que `ANDROID_HOME` esté configurado
2. Verifica que el emulador esté corriendo (`adb devices`)
3. Reinicia la terminal después de configurar variables de entorno

### El emulador es muy lento

**Problema:** Emulador sin aceleración de hardware  
**Solución:**
1. Verifica que **Virtualization** esté habilitado en BIOS
2. Instala **HAXM** (Intel) o **Hyper-V** (Windows)
3. Usa un emulador con menos RAM configurada

### Error: "No devices found"

**Problema:** ADB no detecta el emulador  
**Solución:**
```powershell
# Reiniciar ADB
& "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\platform-tools\adb.exe" kill-server
& "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\platform-tools\adb.exe" start-server
& "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\platform-tools\adb.exe" devices
```

### Error: "SDK location not found"

**Problema:** Flutter no encuentra el SDK  
**Solución:**
1. Verifica que `android/local.properties` existe
2. Añade o actualiza:
   ```
   sdk.dir=C:\\Users\\cclaraso\\AppData\\Local\\Android\\Sdk
   ```

## 💡 Tips

### Performance
- **Cierra otros programas** cuando uses el emulador (consume mucha RAM)
- **Usa un emulador con menos RAM** si tu PC es limitado
- **Configura el emulador con GPU acceleration** en Android Studio

### Desarrollo
- **Hot reload funciona** en el emulador igual que en web
- **Puedes hacer screenshots** desde Android Studio
- **Puedes simular llamadas/SMS** desde el emulador
- **Configura geolocalización** desde el emulador para testing

### Testing
- **Prueba diferentes tamaños** de pantalla
- **Prueba orientación** (portrait/landscape)
- **Prueba diferentes versiones** de Android (API 30, API 34)

## 📝 Comandos Útiles

### Ver dispositivos conectados
```powershell
& "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\platform-tools\adb.exe" devices
```

### Instalar APK directamente
```powershell
& "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\platform-tools\adb.exe" install app.apk
```

### Ver logs del emulador
```powershell
& "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\platform-tools\adb.exe" logcat
```

### Reiniciar ADB
```powershell
& "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\platform-tools\adb.exe" kill-server
& "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\platform-tools\adb.exe" start-server
```

## 🔗 Referencias

- [Flutter Android Setup](https://docs.flutter.dev/get-started/install/windows#android-setup)
- [Android Emulator Documentation](https://developer.android.com/studio/run/emulator)
- [ADB Documentation](https://developer.android.com/studio/command-line/adb)

---

**Última actualización:** Enero 2025  
**Versión:** 1.0  
**Ruta SDK:** `C:\Users\cclaraso\AppData\Local\Android\Sdk`

