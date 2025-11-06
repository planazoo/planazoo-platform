# ☕ Configurar Java (JDK) para Flutter Android

## 📝 Estado Actual

**Windows:** ⏸️ Pendiente - Se configurará durante la migración a Mac  
**Mac:** ✅ Se configurará automáticamente durante la migración (Android Studio incluye JDK)

## 🔴 Problema

```
ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
```

**Nota:** Este error se encontró durante la configuración del emulador Android en Windows. La instalación y configuración de Java se ha dejado pendiente para la migración a Mac, donde será más sencillo (Android Studio incluye su propio JDK).

## ✅ Solución

Necesitas instalar Java JDK (Java Development Kit) para compilar aplicaciones Android.

### Opción 1: Instalar JDK desde Oracle (Recomendado)

1. **Descargar JDK:**
   - Ve a: https://www.oracle.com/java/technologies/downloads/
   - Descarga **JDK 17** o **JDK 21** (LTS)
   - Versión: **Windows x64 Installer**

2. **Instalar:**
   - Ejecuta el instalador
   - Instala en la ubicación por defecto (normalmente `C:\Program Files\Java\jdk-XX`)
   - Acepta instalar JRE también

3. **Configurar Variables de Entorno:**

   **Abrir Variables de Entorno:**
   - `Win + R` → `sysdm.cpl` → "Opciones avanzadas" → "Variables de entorno"

   **Añadir Variables:**
   - `JAVA_HOME` = `C:\Program Files\Java\jdk-17` (o la versión que instales)
   - Añade al `Path`:
     - `%JAVA_HOME%\bin`

4. **Verificar:**
   ```powershell
   java -version
   ```
   Debería mostrar la versión de Java instalada.

### Opción 2: Usar JDK de Android Studio (Si está instalado)

Si tienes Android Studio instalado, puede incluir su propio JDK:

1. **Buscar JDK de Android Studio:**
   ```powershell
   Get-ChildItem -Path "C:\Program Files\Android\Android Studio" -Recurse -Filter "java.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 FullName
   ```

2. **Configurar JAVA_HOME:**
   - Si encuentra algo como: `C:\Program Files\Android\Android Studio\jbr`
   - Configura: `JAVA_HOME` = `C:\Program Files\Android\Android Studio\jbr`

### Opción 3: Instalar JDK con Chocolatey (Si lo tienes)

```powershell
choco install openjdk17
```

Luego configura `JAVA_HOME` apuntando a la instalación de OpenJDK.

## 🔧 Configuración Temporal (Solo esta sesión)

Si instalaste Java pero no configuraste las variables permanentemente:

```powershell
# Configurar JAVA_HOME (ajusta la ruta según tu instalación)
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:PATH += ";$env:JAVA_HOME\bin"

# Verificar
java -version
```

## ✅ Verificar que Funciona

Después de configurar Java:

```powershell
# Verificar Java
java -version

# Verificar JAVA_HOME
echo $env:JAVA_HOME

# Verificar que Flutter detecta Java
flutter doctor
```

En `flutter doctor` deberías ver:
```
[✓] Android toolchain - develop for Android devices
    • Android SDK at C:\Users\...\AppData\Local\Android\Sdk
    • Java development kit (JDK) version X.X.X
```

## 📝 Nota

**Versión recomendada:** JDK 17 o JDK 21 (LTS)
- JDK 17 es la más estable
- JDK 21 es la última LTS
- Flutter requiere mínimo JDK 11

---

## 📝 Nota sobre Windows

**Decisión:** La configuración de Java en Windows se ha dejado pendiente por complejidad. Se configurará durante la migración a Mac, donde:

1. Android Studio incluye su propio JDK (no requiere instalación separada)
2. La configuración es más sencilla con Homebrew (si se necesita)
3. El entorno se configurará desde cero en Mac

**Referencia:** Ver `MIGRACION_MAC_PLAYBOOK.md` - Paso 6.3.5 para la configuración completa en Mac.

---

**Última actualización:** Enero 2025  
**Estado Windows:** Pendiente para migración a Mac

