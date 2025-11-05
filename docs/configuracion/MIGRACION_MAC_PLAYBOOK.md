# 🍎 Playbook de Migración a Mac - Planazoo

> **Documento ejecutable para la IA**: Este documento contiene todos los pasos necesarios para migrar el proyecto Planazoo desde Windows a Mac. La IA puede seguir este documento paso a paso para gestionar toda la instalación y migración.

**Fecha de creación:** Enero 2025  
**Proyecto:** Planazoo (unp_calendario)  
**Destino:** Mac con macOS (última versión estable)  
**Objetivo:** Migrar proyecto completo, configurar entorno de desarrollo (Cursor, Flutter, Firebase), habilitar compilación Web/Android/iOS

---

## 📋 INSTRUCCIONES PARA LA IA

**Cuando el usuario comparta este documento en la nueva instalación de Mac:**

1. **Lee este documento completo** antes de empezar
2. **Ejecuta cada paso secuencialmente**
3. **Verifica cada paso** antes de continuar
4. **Reporta problemas** inmediatamente al usuario
5. **Actualiza el checklist** marcando completados según avances
6. **Pregunta al usuario** si hay dudas o problemas que no puedas resolver

**Formato de trabajo:**
- Ejecutar comandos en terminal
- Verificar resultados
- Actualizar checklists
- Reportar progreso al usuario
- Continuar con el siguiente paso solo si el anterior fue exitoso

---

## 🎯 RESUMEN EJECUTIVO

**Objetivos:**
- ✅ Instalar Cursor IDE (última versión)
- ✅ Conectar proyecto con GitHub
- ✅ Configurar IA de Cursor
- ✅ Instalar Flutter SDK (Web/Android/iOS)
- ✅ Instalar Xcode para iOS
- ✅ Instalar Android Studio para Android
- ✅ Configurar Firebase
- ✅ Compilar y probar en todas las plataformas
- ✅ Optimizar Cursor para el proyecto
- ✅ Instalar Firebase CLI (T155)
- ✅ Actualizar índices de Firestore (T156)
- ✅ **Preparar entorno para desarrollo Offline First** (T56-T62)

**Nota importante:** Después de completar la migración, el usuario quiere empezar a trabajar en la implementación de Offline First (Tareas T56-T62). El entorno debe estar preparado para este desarrollo.

**Tiempo estimado:** 1-2 días  
**Complejidad:** Alta

---

## 📦 FASE 1: VERIFICACIÓN INICIAL Y PREPARACIÓN

### **Paso 1.1: Verificar Sistema Operativo**

**Comando:**
```bash
sw_vers
```

**Verificar:**
- ✅ macOS está instalado
- ✅ Versión es compatible (macOS 10.15 o superior recomendado)

**Resultado esperado:** Información del sistema operativo

---

### **Paso 1.2: Verificar Espacio en Disco**

**Comando:**
```bash
df -h
```

**Verificar:**
- ✅ Al menos 50GB de espacio libre disponible
- ✅ Espacio suficiente para Xcode (~15GB), Android Studio (~5GB), Flutter (~2GB)

**Resultado esperado:** Lista de discos con espacio disponible

---

### **Paso 1.3: Verificar Conexión a Internet**

**Comando:**
```bash
ping -c 3 google.com
```

**Verificar:**
- ✅ Conexión a internet funciona
- ✅ No hay problemas de conectividad

**Resultado esperado:** Respuestas de ping exitosas

---

### **Paso 1.4: Crear Directorio de Desarrollo**

**Comando:**
```bash
mkdir -p ~/development
cd ~/development
pwd
```

**Verificar:**
- ✅ Directorio `~/development` creado
- ✅ Estamos en el directorio correcto

**Resultado esperado:** `/Users/tu-usuario/development`

---

## 📦 FASE 2: INSTALACIÓN DE CURSOR IDE

### **Paso 2.1: Descargar Cursor IDE**

**Acción:**
1. Abrir navegador y ir a [cursor.sh](https://cursor.sh/)
2. Descargar la última versión para macOS
3. O usar curl para descargar directamente:

**Comando (alternativo):**
```bash
cd ~/Downloads
# Obtener URL de descarga desde la web de Cursor
# curl -L -o Cursor.dmg "URL_DE_DESCARGA"
```

**Verificar:**
- ✅ Archivo Cursor.dmg descargado

---

### **Paso 2.2: Instalar Cursor**

**Comando:**
```bash
# Montar DMG
open ~/Downloads/Cursor.dmg

# Copiar a Aplicaciones (hacer manualmente desde Finder o usar):
# cp -R /Volumes/Cursor/Cursor.app /Applications/
```

**Verificar:**
- ✅ Cursor.app está en `/Applications/`

---

### **Paso 2.3: Abrir Cursor y Configuración Inicial**

**Comando:**
```bash
open -a Cursor
```

**Acciones manuales (guiar al usuario):**
1. ✅ Abrir Cursor
2. ✅ Completar configuración inicial (tema, preferencias básicas)
3. ✅ Crear/ingresar a cuenta de Cursor si es necesario

**Verificar:**
- ✅ Cursor se abre correctamente
- ✅ Configuración inicial completada

---

### **Paso 2.4: Instalar Extensiones Esenciales**

**Desde Cursor (abrir Command Palette: Cmd+Shift+P):**

1. **Dart Extension:**
   - Buscar: "Dart"
   - Instalar: "Dart" de Dart Code

2. **Flutter Extension:**
   - Buscar: "Flutter"
   - Instalar: "Flutter" de Dart Code

3. **GitLens:**
   - Buscar: "GitLens"
   - Instalar: "GitLens — Git supercharged"

4. **Error Lens:**
   - Buscar: "Error Lens"
   - Instalar: "Error Lens"

5. **Bracket Pair Colorizer:**
   - Buscar: "Bracket Pair Colorizer"
   - Instalar: "Bracket Pair Colorizer 2"

6. **Material Icon Theme:**
   - Buscar: "Material Icon Theme"
   - Instalar: "Material Icon Theme"

**Verificar:**
- ✅ Todas las extensiones instaladas
- ✅ Extensiones activas (no hay errores)

---

### **Paso 2.5: Configurar Preferencias de Cursor**

**Archivo:** `~/.cursor/settings.json` o desde Cursor Settings

**Configuración recomendada:**
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "Dart-Code.dart-code",
  "editor.fontSize": 14,
  "editor.fontFamily": "Menlo, Monaco, 'Courier New', monospace",
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000,
  "dart.enableSdkFormatter": true,
  "dart.lineLength": 80,
  "dart.flutterSdkPath": "",
  "git.enabled": true,
  "git.autofetch": true
}
```

**Verificar:**
- ✅ Preferencias guardadas
- ✅ Cursor se comporta según configuración

---

### **Paso 2.6: Intentar Migrar Chats de IA (si es posible)**

**Acción:**
1. Buscar archivos de configuración de Cursor en Windows (si el usuario los tiene)
2. Ubicación típica en Windows: `%APPDATA%\Cursor\User\globalStorage`
3. Copiar archivos de chat si existen
4. Ubicación en Mac: `~/.cursor/User/globalStorage`

**Comando (si el usuario proporciona archivos):**
```bash
# Si el usuario tiene archivos de chat de Windows
# Copiar a la ubicación de Mac
mkdir -p ~/.cursor/User/globalStorage
# cp -r /ruta/a/archivos/windows ~/.cursor/User/globalStorage/
```

**Nota:** Si no es posible migrar, documentar conversaciones importantes.

**Verificar:**
- ✅ Chats migrados (si fue posible)
- ✅ O documentación de conversaciones importantes creada

---

## 📦 FASE 3: CONFIGURACIÓN DE GIT Y GITHUB

### **Paso 3.1: Verificar/Instalar Git**

**Comando:**
```bash
git --version
```

**Si no está instalado:**
```bash
# Instalar Xcode Command Line Tools (incluye Git)
xcode-select --install
```

**Verificar:**
- ✅ Git está instalado
- ✅ Versión es 2.0 o superior

**Resultado esperado:** `git version 2.x.x`

---

### **Paso 3.2: Configurar Git**

**Comando:**
```bash
# Preguntar al usuario por nombre y email
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"

# Verificar configuración
git config --global --list
```

**Verificar:**
- ✅ Nombre y email configurados correctamente

---

### **Paso 3.3: Configurar SSH Keys para GitHub**

**Comando:**
```bash
# Verificar si ya existe una SSH key
ls -la ~/.ssh

# Si no existe, crear nueva SSH key
ssh-keygen -t ed25519 -C "tu@email.com"
# Presionar Enter para ubicación por defecto
# Opcional: agregar passphrase (recomendado)

# Mostrar la clave pública para agregar a GitHub
cat ~/.ssh/id_ed25519.pub
```

**Acción manual (guiar al usuario):**
1. ✅ Copiar la clave pública mostrada
2. ✅ Ir a GitHub.com → Settings → SSH and GPG keys
3. ✅ Click "New SSH key"
4. ✅ Pegar la clave y guardar

**Verificar conexión:**
```bash
ssh -T git@github.com
```

**Resultado esperado:** "Hi username! You've successfully authenticated..."

**Verificar:**
- ✅ SSH key creada
- ✅ SSH key agregada a GitHub
- ✅ Conexión funciona

---

### **Paso 3.4: Clonar Repositorio**

**Comando:**
```bash
cd ~/development
git clone git@github.com:tu-usuario/unp_calendario.git
cd unp_calendario
pwd
```

**Verificar:**
- ✅ Repositorio clonado correctamente
- ✅ Estamos en el directorio del proyecto

**Resultado esperado:** `~/development/unp_calendario`

---

### **Paso 3.5: Verificar Estado del Repositorio**

**Comando:**
```bash
git status
git branch
git log --oneline -5
```

**Verificar:**
- ✅ Repositorio en estado limpio
- ✅ Estamos en la rama correcta (main/master)
- ✅ Historial de commits visible

---

### **Paso 3.6: Abrir Proyecto en Cursor**

**Comando:**
```bash
cd ~/development/unp_calendario
cursor .
```

**Verificar:**
- ✅ Cursor abre el proyecto
- ✅ Cursor detecta el repositorio Git
- ✅ Archivos del proyecto visibles

---

## 📦 FASE 4: INSTALACIÓN DE FLUTTER SDK

### **Paso 4.1: Descargar Flutter SDK**

**Comando:**
```bash
cd ~/development
curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_stable.zip -o flutter.zip
# O para Intel Mac:
# curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.x.x-stable.zip -o flutter.zip

# Extraer
unzip flutter.zip
rm flutter.zip
```

**Verificar:**
- ✅ Flutter SDK descargado y extraído
- ✅ Directorio `flutter` existe en `~/development`

---

### **Paso 4.2: Configurar PATH de Flutter**

**Comando:**
```bash
# Verificar qué shell estamos usando
echo $SHELL

# Si es zsh (macOS por defecto desde Catalina)
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc

# Si es bash
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bash_profile

# Recargar configuración
source ~/.zshrc  # o source ~/.bash_profile
```

**Verificar:**
```bash
flutter --version
```

**Resultado esperado:** Versión de Flutter mostrada

**Verificar:**
- ✅ Flutter está en el PATH
- ✅ Comando `flutter` funciona

---

### **Paso 4.3: Ejecutar Flutter Doctor**

**Comando:**
```bash
flutter doctor -v
```

**Analizar salida:**
- ✅ Ver qué componentes están instalados
- ✅ Ver qué componentes faltan
- ✅ Identificar problemas

**Verificar:**
- ✅ Flutter Doctor ejecutado
- ✅ Problemas identificados y documentados

---

### **Paso 4.4: Instalar Dependencias de Flutter**

**Comando:**
```bash
# Aceptar licencias de Android (si se instala Android Studio después)
flutter doctor --android-licenses

# Verificar estado actualizado
flutter doctor
```

**Verificar:**
- ✅ Licencias aceptadas (si aplica)
- ✅ Flutter Doctor muestra menos problemas

---

## 📦 FASE 5: INSTALACIÓN DE XCODE (iOS)

### **Paso 5.1: Instalar Xcode desde App Store**

**Acción manual (guiar al usuario):**
1. ✅ Abrir App Store
2. ✅ Buscar "Xcode"
3. ✅ Instalar Xcode (última versión)
4. ✅ Esperar a que termine (puede tardar 30-60 minutos)

**Nota:** Este paso requiere interacción del usuario. Mientras tanto, continuar con otras tareas paralelas.

---

### **Paso 5.2: Configurar Xcode Command Line Tools**

**Comando:**
```bash
# Verificar que Xcode está instalado
xcode-select -p

# Si no está configurado:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# Aceptar licencia
sudo xcodebuild -runFirstLaunch

# Verificar
xcodebuild -version
```

**Verificar:**
- ✅ Xcode Command Line Tools configurados
- ✅ Licencia aceptada

---

### **Paso 5.3: Instalar CocoaPods**

**Comando:**
```bash
# Instalar CocoaPods
sudo gem install cocoapods

# Verificar
pod --version
```

**Verificar:**
- ✅ CocoaPods instalado
- ✅ Comando `pod` funciona

---

### **Paso 5.4: Verificar Configuración iOS en Flutter**

**Comando:**
```bash
flutter doctor
```

**Verificar:**
- ✅ Xcode aparece como configurado
- ✅ iOS toolchain aparece como disponible

---

## 📦 FASE 6: INSTALACIÓN DE ANDROID STUDIO

### **Paso 6.1: Descargar Android Studio**

**Comando:**
```bash
cd ~/Downloads
# Descargar desde la web oficial o usar curl
# curl -L -o android-studio.dmg "URL_DE_DESCARGA"
```

**Acción manual:**
1. ✅ Ir a [developer.android.com/studio](https://developer.android.com/studio)
2. ✅ Descargar Android Studio para macOS
3. ✅ Instalar Android Studio

---

### **Paso 6.2: Configurar Android Studio**

**Acciones manuales (guiar al usuario):**
1. ✅ Abrir Android Studio
2. ✅ Completar Setup Wizard
3. ✅ Instalar Android SDK:
   - SDK Platform (última versión estable)
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
   - Android Emulator
4. ✅ Crear un AVD (Android Virtual Device) para testing

---

### **Paso 6.3: Configurar Variables de Entorno Android**

**Comando:**
```bash
# Agregar a ~/.zshrc (o ~/.bash_profile)
cat >> ~/.zshrc << 'EOF'

# Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
EOF

# Recargar
source ~/.zshrc

# Verificar
echo $ANDROID_HOME
```

**Verificar:**
- ✅ Variables de entorno configuradas
- ✅ ANDROID_HOME está definido

---

### **Paso 6.4: Aceptar Licencias de Android**

**Comando:**
```bash
flutter doctor --android-licenses
```

**Acción:** Responder "y" a todas las preguntas

**Verificar:**
- ✅ Todas las licencias aceptadas

---

### **Paso 6.5: Verificar Configuración Android en Flutter**

**Comando:**
```bash
flutter doctor
```

**Verificar:**
- ✅ Android toolchain aparece como configurado

---

## 📦 FASE 7: CONFIGURACIÓN DE FLUTTER PARA WEB

### **Paso 7.1: Habilitar Soporte Web**

**Comando:**
```bash
flutter config --enable-web
```

**Verificar:**
```bash
flutter config
```

**Resultado esperado:** "Enable web: true"

---

### **Paso 7.2: Verificar Dispositivos Disponibles**

**Comando:**
```bash
flutter devices
```

**Verificar:**
- ✅ Chrome aparece como dispositivo disponible
- ✅ iOS Simulator aparece (si Xcode está instalado)
- ✅ Android Emulator aparece (si está corriendo)

---

## 📦 FASE 8: CONFIGURACIÓN DEL PROYECTO

### **Paso 8.1: Navegar al Proyecto**

**Comando:**
```bash
cd ~/development/unp_calendario
pwd
```

**Verificar:**
- ✅ Estamos en el directorio correcto

---

### **Paso 8.2: Verificar Rama de Git**

**Comando:**
```bash
git branch
git status
```

**Verificar:**
- ✅ Estamos en la rama correcta (main/master)
- ✅ Repositorio está limpio

---

### **Paso 8.3: Instalar Dependencias del Proyecto**

**Comando:**
```bash
flutter pub get
```

**Verificar:**
- ✅ Dependencias instaladas sin errores

---

### **Paso 8.4: Verificar Análisis del Código**

**Comando:**
```bash
flutter analyze
```

**Verificar:**
- ✅ No hay errores críticos
- ✅ Solo warnings menores (si los hay)

---

### **Paso 8.5: Configurar Firebase**

**Archivos necesarios:**
1. `android/app/google-services.json` (Android)
2. `ios/Runner/GoogleService-Info.plist` (iOS)

**Acción:**
1. ✅ Ir a Firebase Console
2. ✅ Descargar `google-services.json` para Android
3. ✅ Descargar `GoogleService-Info.plist` para iOS
4. ✅ Colocar en las ubicaciones correctas

**Comando:**
```bash
# Verificar que los archivos existen
ls -la android/app/google-services.json
ls -la ios/Runner/GoogleService-Info.plist
```

**Verificar:**
- ✅ Archivos de Firebase en ubicaciones correctas

---

### **Paso 8.6: Verificar Configuración de Firebase**

**Comando:**
```bash
# Verificar firebase.json
cat firebase.json

# Verificar firestore.rules existe
ls -la firestore.rules

# Verificar firestore.indexes.json existe
ls -la firestore.indexes.json
```

**Verificar:**
- ✅ Configuración de Firebase presente

---

### **Paso 8.7: Verificar .gitignore**

**Comando:**
```bash
cat .gitignore | grep -i mac
cat .gitignore | grep -i ".DS_Store"
```

**Verificar:**
- ✅ `.gitignore` incluye archivos de Mac (`.DS_Store`, etc.)

**Si no está:**
```bash
# Agregar entradas para Mac
cat >> .gitignore << 'EOF'

# macOS
.DS_Store
.AppleDouble
.LSOverride
._*
EOF
```

---

## 📦 FASE 9: COMPILACIÓN Y PRUEBAS

### **Paso 9.1: Limpiar Build Previo**

**Comando:**
```bash
flutter clean
flutter pub get
```

**Verificar:**
- ✅ Proyecto limpiado
- ✅ Dependencias reinstaladas

---

### **Paso 9.2: Compilar para iOS**

**Comando:**
```bash
# Primero, instalar pods de iOS
cd ios
pod install
cd ..

# Compilar para iOS Simulator
flutter run -d ios
```

**Verificar:**
- ✅ App compila sin errores
- ✅ App se abre en iOS Simulator
- ✅ App funciona correctamente

**Si hay errores:**
- ✅ Documentar errores
- ✅ Intentar resolver
- ✅ Reportar al usuario si no se puede resolver

---

### **Paso 9.3: Compilar para Android**

**Comando:**
```bash
# Asegurar que Android Emulator está corriendo
flutter devices

# Compilar para Android
flutter run -d android
```

**Verificar:**
- ✅ App compila sin errores
- ✅ App se abre en Android Emulator
- ✅ App funciona correctamente

---

### **Paso 9.4: Compilar para Web**

**Comando:**
```bash
flutter run -d chrome
```

**Verificar:**
- ✅ App compila sin errores
- ✅ App se abre en Chrome
- ✅ App funciona correctamente

---

### **Paso 9.5: Verificar Funcionalidades Principales**

**Checklist de pruebas:**
- [ ] Login/Registro funciona
- [ ] Crear/editar planes funciona
- [ ] Crear/editar eventos funciona
- [ ] Calendario se visualiza correctamente
- [ ] Participantes e invitaciones funcionan
- [ ] Presupuesto y pagos funcionan
- [ ] Estadísticas funcionan
- [ ] Sincronización con Firestore funciona

**Verificar:**
- ✅ Funcionalidades principales probadas
- ✅ Problemas documentados

---

### **Paso 9.6: Preparar Pruebas Offline (Para Desarrollo Offline First)**

**Nota:** Este paso prepara el entorno para el desarrollo de Offline First (T56-T62) que comenzará después de la migración.

**Comando:**
```bash
# Verificar que podemos simular modo offline
flutter devices
```

**Acciones para preparar desarrollo offline:**
1. ✅ Documentar cómo simular modo offline en iOS Simulator:
   - Settings → Developer → Network Link Conditioner → Enable → 100% Loss
2. ✅ Documentar cómo simular modo offline en Android Emulator:
   - Settings → Network → Airplane Mode
3. ✅ Documentar cómo simular modo offline en Chrome:
   - DevTools → Network → Throttling → Offline

**Verificar:**
- ✅ Métodos de simulación offline documentados
- ✅ Entorno preparado para desarrollo offline

**Documentación de referencia:**
- Ver `docs/arquitectura/ARCHITECTURE_DECISIONS.md` - Sección "Offline First"
- Ver `docs/tareas/TASKS.md` - Tareas T56-T62 (Infraestructura Offline)

---

## 📦 FASE 10: OPTIMIZACIÓN DE CURSOR

### **Paso 10.1: Configurar Workspace Settings**

**Archivo:** `.vscode/settings.json` (o crear si no existe)

**Comando:**
```bash
mkdir -p .vscode
cat > .vscode/settings.json << 'EOF'
{
  "dart.flutterSdkPath": "",
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "Dart-Code.dart-code",
  "dart.enableSdkFormatter": true,
  "dart.lineLength": 80,
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000,
  "git.enabled": true,
  "git.autofetch": true
}
EOF
```

**Actualizar ruta de Flutter:**
```bash
# Obtener ruta de Flutter
which flutter

# Editar .vscode/settings.json y actualizar "dart.flutterSdkPath" con la ruta completa
```

**Verificar:**
- ✅ Workspace settings creados
- ✅ Ruta de Flutter configurada

---

### **Paso 10.2: Configurar Extensiones Recomendadas**

**Archivo:** `.vscode/extensions.json` (crear si no existe)

**Comando:**
```bash
cat > .vscode/extensions.json << 'EOF'
{
  "recommendations": [
    "dart-code.dart-code",
    "dart-code.flutter",
    "eamodio.gitlens",
    "usernamehw.errorlens",
    "coenraads.bracket-pair-colorizer-2",
    "pkief.material-icon-theme"
  ]
}
EOF
```

**Verificar:**
- ✅ Extensiones recomendadas configuradas

---

### **Paso 10.3: Probar Autocompletado y IA**

**Acción:**
1. ✅ Abrir un archivo Dart en Cursor
2. ✅ Verificar que autocompletado funciona
3. ✅ Probar sugerencias de IA
4. ✅ Verificar que formato automático funciona

**Verificar:**
- ✅ Autocompletado funciona
- ✅ IA de Cursor funciona
- ✅ Formato automático funciona

---

## 📦 FASE 11: ACTUALIZACIONES Y PAQUETES

### **Paso 11.1: Actualizar Flutter**

**Comando:**
```bash
flutter upgrade
```

**Verificar:**
- ✅ Flutter actualizado a última versión estable

---

### **Paso 11.2: Actualizar Dependencias del Proyecto**

**Comando:**
```bash
flutter pub upgrade
```

**Verificar:**
- ✅ Dependencias actualizadas
- ✅ No hay conflictos

---

### **Paso 11.3: Actualizar CocoaPods**

**Comando:**
```bash
cd ios
pod repo update
pod install
cd ..
```

**Verificar:**
- ✅ CocoaPods actualizado
- ✅ Dependencias de iOS actualizadas

---

### **Paso 11.4: Verificar que Todo Funciona Después de Actualizaciones**

**Comando:**
```bash
flutter doctor
flutter analyze
```

**Verificar:**
- ✅ Todo sigue funcionando
- ✅ No hay nuevos errores

---

## 📦 FASE 12: INSTALACIÓN DE FIREBASE CLI (T155)

### **Paso 12.1: Instalar Node.js**

**Comando:**
```bash
# Verificar si Node.js está instalado
node --version

# Si no está instalado, usar Homebrew (instalar si es necesario)
# brew install node

# O descargar desde nodejs.org
```

**Verificar:**
- ✅ Node.js instalado (versión LTS recomendada)

---

### **Paso 12.2: Instalar Firebase CLI**

**Comando:**
```bash
npm install -g firebase-tools
```

**Verificar:**
```bash
firebase --version
```

**Resultado esperado:** Versión de Firebase CLI

---

### **Paso 12.3: Login en Firebase**

**Comando:**
```bash
firebase login
```

**Acción manual (guiar al usuario):**
1. ✅ Se abrirá navegador para autenticación
2. ✅ Iniciar sesión con cuenta de Google
3. ✅ Autorizar Firebase CLI

**Verificar:**
```bash
firebase projects:list
```

**Verificar:**
- ✅ Login exitoso
- ✅ Proyectos visibles

---

### **Paso 12.4: Configurar Proyecto Firebase**

**Comando:**
```bash
cd ~/development/unp_calendario
firebase use --add
```

**Acción:**
1. ✅ Seleccionar proyecto de la lista
2. ✅ Asignar alias (opcional)

**Verificar:**
```bash
firebase use
```

**Verificar:**
- ✅ Proyecto configurado correctamente

---

## 📦 FASE 13: ACTUALIZACIÓN DE ÍNDICES DE FIRESTORE (T156)

### **Paso 13.1: Verificar firestore.indexes.json**

**Comando:**
```bash
cat firestore.indexes.json | head -50
```

**Verificar:**
- ✅ Archivo existe
- ✅ Contiene los 25 índices requeridos

---

### **Paso 13.2: Desplegar Índices**

**Comando:**
```bash
firebase deploy --only firestore:indexes
```

**Verificar:**
- ✅ Comando ejecutado sin errores
- ✅ Índices desplegados

**Nota:** Los índices pueden tardar 5-30 minutos en crearse. Verificar en Firebase Console.

---

### **Paso 13.3: Verificar Índices en Firebase Console**

**Acción manual (guiar al usuario):**
1. ✅ Ir a Firebase Console → Firestore Database → Indexes
2. ✅ Verificar que hay 25 índices
3. ✅ Esperar a que todos estén "Enabled"

**Verificar:**
- ✅ 25 índices desplegados
- ✅ Todos en estado "Enabled"

---

### **Paso 13.4: Eliminar Índices Obsoletos**

**Índices a eliminar:**
1. `Hours` - `horaFecha` + `horaNum`
2. `users` - `email` + `isActive`
3. `users` - `planId` + `date` + `hour`

**Acción manual (guiar al usuario):**
1. ✅ En Firebase Console → Firestore Database → Indexes
2. ✅ Para cada índice obsoleto:
   - Click en el índice
   - Click en "Delete"
   - Confirmar eliminación

**Verificar:**
- ✅ Índices obsoletos eliminados
- ✅ Solo quedan los 25 índices válidos

---

## 📦 FASE 14: DOCUMENTACIÓN Y FINALIZACIÓN

### **Paso 14.1: Documentar Problemas Encontrados**

**Acción:**
1. ✅ Crear documento con problemas encontrados
2. ✅ Documentar soluciones aplicadas
3. ✅ Guardar en `docs/configuracion/MIGRACION_MAC_NOTAS.md`

---

### **Paso 14.2: Actualizar .gitignore**

**Verificar:**
```bash
cat .gitignore
```

**Asegurar que incluye:**
- `.DS_Store`
- Archivos de Mac
- Archivos de build
- Archivos de IDE

---

### **Paso 14.3: Hacer Commit Inicial (si hay cambios)**

**Comando:**
```bash
git status
git add .
git commit -m "chore: configuración inicial en Mac"
```

**Verificar:**
- ✅ Cambios commiteados (si los hay)

---

### **Paso 14.4: Verificación Final**

**Checklist final:**
- [ ] Cursor IDE instalado y configurado
- [ ] Proyecto conectado a GitHub
- [ ] IA de Cursor funciona
- [ ] Flutter SDK instalado y configurado
- [ ] Compilación iOS funciona
- [ ] Compilación Android funciona
- [ ] Compilación Web funciona
- [ ] Firebase configurado
- [ ] Firebase CLI instalado
- [ ] Índices de Firestore actualizados
- [ ] Todas las funcionalidades probadas
- [ ] Cursor optimizado
- [ ] **Entorno preparado para desarrollo Offline First (T56-T62)**

---

### **Paso 14.5: Preparación para Desarrollo Offline First**

**Nota:** El usuario quiere empezar a trabajar en Offline First después de la migración. Este paso prepara el entorno y documentación.

**Acciones:**
1. ✅ Revisar documentación de Offline First:
   ```bash
   # Leer documentación relevante
   cat docs/arquitectura/ARCHITECTURE_DECISIONS.md | grep -A 50 "Offline First"
   cat docs/tareas/TASKS.md | grep -A 20 "T56"
   ```

2. ✅ Verificar dependencias necesarias para offline:
   - SQLite/Hive para almacenamiento local
   - Verificar en `pubspec.yaml` si están incluidas

3. ✅ Crear documento de preparación (opcional):
   ```bash
   # Crear nota de inicio de desarrollo offline
   cat > docs/configuracion/OFFLINE_FIRST_PREPARACION.md << 'EOF'
   # Preparación para Desarrollo Offline First
   
   ## Estado Actual
   - Migración a Mac completada
   - Entorno de desarrollo configurado
   - Listo para comenzar T56-T62
   
   ## Próximos Pasos
   - Revisar T56: Base de datos local
   - Revisar T57: Cache de eventos
   - Revisar T58: Cola de sincronización
   - Etc.
   EOF
   ```

**Verificar:**
- ✅ Documentación de Offline First revisada
- ✅ Dependencias verificadas
- ✅ Entorno preparado para desarrollo offline

---

## ✅ RESUMEN DE VERIFICACIÓN

**Ejecutar al final:**
```bash
flutter doctor -v
flutter devices
firebase --version
git status
```

**Verificar que:**
- ✅ Flutter Doctor muestra todo configurado
- ✅ Todos los dispositivos disponibles
- ✅ Firebase CLI funciona
- ✅ Repositorio está limpio
- ✅ **Entorno preparado para desarrollo Offline First**

---

## 📱 PREPARACIÓN PARA OFFLINE FIRST

### **Documentación de Referencia**

**Tareas relacionadas:**
- T56: Base de datos local (SQLite/Hive)
- T57: Cache de eventos offline
- T58: Cola de sincronización
- T59: Indicadores de estado offline
- T60: Resolución de conflictos
- T61: Notificaciones push offline
- T62: Testing exhaustivo offline

**Documentos importantes:**
- `docs/arquitectura/ARCHITECTURE_DECISIONS.md` - Sección "Offline First"
- `docs/tareas/TASKS.md` - Grupo 4: Infraestructura Offline (T56-T62)
- `docs/configuracion/TESTING_CHECKLIST.md` - Sección "Sincronización y Offline"

### **Dependencias Necesarias para Offline First**

**Verificar en `pubspec.yaml`:**
- ✅ `sqflite` o `hive` para base de datos local
- ✅ `connectivity_plus` para detectar estado de conexión
- ✅ `workmanager` o `background_fetch` para tareas en background (opcional)

**Si faltan, agregar después de la migración:**
```yaml
dependencies:
  sqflite: ^latest  # Para SQLite local
  # o
  hive: ^latest     # Para Hive local
  connectivity_plus: ^latest  # Para detectar conexión
```

### **Métodos de Simulación Offline**

**Para pruebas durante desarrollo:**

1. **iOS Simulator:**
   - Settings → Developer → Network Link Conditioner
   - Enable → 100% Loss
   - O usar: `xcrun simctl status_bar booted override --dataNetwork none`

2. **Android Emulator:**
   - Settings → Network & Internet → Airplane Mode
   - O usar adb: `adb shell svc wifi disable && adb shell svc data disable`

3. **Chrome/Web:**
   - DevTools (F12) → Network tab → Throttling → Offline
   - O usar: `navigator.onLine = false` en consola

### **Próximos Pasos Después de Migración**

1. **Revisar documentación de Offline First**
2. **Verificar dependencias en `pubspec.yaml`**
3. **Comenzar con T56: Base de datos local**
4. **Configurar pruebas offline en cada plataforma**

---

## 📝 NOTAS IMPORTANTES

1. **Si hay problemas:** Documentar y reportar al usuario inmediatamente
2. **Preguntas:** Si algo no está claro, preguntar al usuario antes de continuar
3. **Backup:** Si se modifica algo importante, hacer backup antes
4. **Verificación:** Verificar cada paso antes de continuar
5. **Tiempo:** Algunos pasos pueden tardar (instalación de Xcode, etc.)
6. **Offline First:** Recordar que después de la migración, el usuario quiere empezar con el desarrollo de Offline First (T56-T62). Asegurar que el entorno está preparado.

---

## 🎯 ESTADO DEL CHECKLIST

**Última actualización:** [Fecha/Hora]  
**Completado por:** [IA/Usuario]  
**Problemas encontrados:** [Lista de problemas]  
**Siguiente paso:** [Próximo paso a ejecutar]

---

**Fin del Playbook**

