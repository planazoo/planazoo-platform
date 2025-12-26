# 🍎 Instrucciones Básicas para Migrar Proyecto a Mac

> **Guía rápida para pasar el proyecto Planazoo de Windows a Mac**

**Fecha:** Noviembre 2025  
**Proyecto:** Planazoo (unp_calendario)

---

## 📋 PASOS BÁSICOS

### 1. Preparar el Proyecto en Windows (Antes de Migrar)

1. **Asegurar que todo está en Git:**
   ```bash
   git status
   git add .
   git commit -m "chore: preparación para migración a Mac"
   git push
   ```

2. **Verificar que no hay archivos locales importantes sin commitear**

---

### 2. En el Mac: Instalar Cursor IDE

1. **Descargar Cursor:**
   - Ir a [cursor.sh](https://cursor.sh/)
   - Descargar versión para macOS
   - Instalar arrastrando a Aplicaciones

2. **Abrir Cursor y configurar:**
   - Completar configuración inicial
   - Instalar extensiones esenciales:
     - Dart
     - Flutter
     - GitLens

---

### 3. En el Mac: Configurar Git y Clonar Proyecto

1. **Verificar/Instalar Git:**
   ```bash
   git --version
   # Si no está: xcode-select --install
   ```

2. **Configurar Git:**
   ```bash
   git config --global user.name "Tu Nombre"
   git config --global user.email "tu@email.com"
   ```

3. **Configurar SSH para GitHub (si usas SSH):**
   ```bash
   ssh-keygen -t ed25519 -C "tu@email.com"
   cat ~/.ssh/id_ed25519.pub
   # Copiar y añadir a GitHub → Settings → SSH keys
   ```

4. **Clonar proyecto:**
   ```bash
   cd ~/development  # o donde quieras
   git clone git@github.com:tu-usuario/unp_calendario.git
   cd unp_calendario
   ```

5. **Abrir en Cursor:**
   ```bash
   cursor .
   ```

---

### 4. En el Mac: Instalar Flutter

1. **Descargar Flutter SDK:**
   ```bash
   cd ~/development
   # Para Mac con Apple Silicon (M1/M2/M3):
   curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_stable.zip -o flutter.zip
   # Para Mac Intel:
   # curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.x.x-stable.zip -o flutter.zip
   
   unzip flutter.zip
   rm flutter.zip
   ```

2. **Configurar PATH:**
   ```bash
   # Verificar shell (zsh o bash)
   echo $SHELL
   
   # Si es zsh (macOS por defecto):
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
   source ~/.zshrc
   
   # Si es bash:
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bash_profile
   source ~/.bash_profile
   ```

3. **Verificar instalación:**
   ```bash
   flutter --version
   flutter doctor
   ```

---

### 5. En el Mac: Instalar Xcode (para iOS)

1. **Instalar desde App Store:**
   - Abrir App Store
   - Buscar "Xcode"
   - Instalar (puede tardar 30-60 minutos)

2. **Configurar Command Line Tools:**
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

3. **Instalar CocoaPods:**
   ```bash
   sudo gem install cocoapods
   ```

---

### 6. En el Mac: Instalar Android Studio (para Android)

1. **Descargar e instalar:**
   - Ir a [developer.android.com/studio](https://developer.android.com/studio)
   - Descargar para macOS
   - Instalar

2. **Configurar Android SDK:**
   - Abrir Android Studio
   - Completar Setup Wizard
   - Instalar Android SDK (última versión estable)

3. **Configurar variables de entorno:**
   ```bash
   # Añadir a ~/.zshrc (o ~/.bash_profile)
   cat >> ~/.zshrc << 'EOF'
   
   # Android SDK
   export ANDROID_HOME=$HOME/Library/Android/sdk
   export PATH=$PATH:$ANDROID_HOME/emulator
   export PATH=$PATH:$ANDROID_HOME/platform-tools
   export PATH=$PATH:$ANDROID_HOME/tools
   export PATH=$PATH:$ANDROID_HOME/tools/bin
   
   # Java (JDK de Android Studio)
   export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
   export PATH=$PATH:$JAVA_HOME/bin
   EOF
   
   source ~/.zshrc
   ```

4. **Aceptar licencias:**
   ```bash
   flutter doctor --android-licenses
   ```

---

### 7. En el Mac: Configurar Proyecto

1. **Instalar dependencias:**
   ```bash
   cd ~/development/unp_calendario
   flutter pub get
   ```

2. **Verificar análisis:**
   ```bash
   flutter analyze
   ```

3. **Configurar Firebase:**
   - Descargar `google-services.json` (Android) desde Firebase Console
   - Descargar `GoogleService-Info.plist` (iOS) desde Firebase Console
   - Colocar en:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`

4. **Instalar pods de iOS:**
   ```bash
   cd ios
   pod install
   cd ..
   ```

---

### 8. En el Mac: Probar Compilación

1. **Verificar dispositivos:**
   ```bash
   flutter devices
   ```

2. **Compilar para Web:**
   ```bash
   flutter run -d chrome
   ```

3. **Compilar para iOS (si Xcode está instalado):**
   ```bash
   flutter run -d ios
   ```

4. **Compilar para Android (si Android Studio está instalado):**
   ```bash
   flutter run -d android
   ```

---

### 9. En el Mac: Configurar Cursor para el Proyecto

1. **Crear workspace settings:**
   - En Cursor, crear `.vscode/settings.json`:
   ```json
   {
     "editor.formatOnSave": true,
     "editor.defaultFormatter": "Dart-Code.dart-code",
     "dart.enableSdkFormatter": true,
     "dart.lineLength": 80,
     "editor.tabSize": 2,
     "files.autoSave": "afterDelay",
     "files.autoSaveDelay": 1000
   }
   ```

2. **Ajustar ruta de Flutter en settings si es necesario**

---

### 10. Poner al Día a la IA en el Mac

**Una vez que el proyecto esté funcionando en Mac:**

1. **Abrir Cursor en el proyecto**

2. **Decirle a la IA:**
   ```
   Lee el documento docs/configuracion/ONBOARDING_IA.md y ponte al día del proyecto.
   ```

3. **La IA debería:**
   - Leer el documento de onboarding
   - Revisar el estado actual del proyecto
   - Entender las normas y metodología
   - Estar lista para trabajar

---

## ✅ CHECKLIST DE VERIFICACIÓN

- [ ] Cursor IDE instalado y funcionando
- [ ] Proyecto clonado desde GitHub
- [ ] Flutter instalado y en PATH
- [ ] `flutter doctor` muestra todo configurado
- [ ] Xcode instalado (para iOS)
- [ ] Android Studio instalado (para Android)
- [ ] Dependencias del proyecto instaladas (`flutter pub get`)
- [ ] Firebase configurado (archivos de configuración en su lugar)
- [ ] Compilación Web funciona
- [ ] Compilación iOS funciona (si aplica)
- [ ] Compilación Android funciona (si aplica)
- [ ] IA de Cursor configurada y funcionando
- [ ] IA ha leído `ONBOARDING_IA.md` y está al día

---

## 📚 DOCUMENTOS DE REFERENCIA

- **`docs/configuracion/MIGRACION_MAC_PLAYBOOK.md`** - Guía completa y detallada (1650+ líneas)
- **`docs/configuracion/ONBOARDING_IA.md`** - Documento para que la IA se ponga al día
- **`docs/configuracion/CONTEXT.md`** - Normas del proyecto
- **`docs/guias/PROMPT_BASE.md`** - Metodología de trabajo

---

## 🆘 SI HAY PROBLEMAS

1. **Consultar el playbook completo:**
   - `docs/configuracion/MIGRACION_MAC_PLAYBOOK.md` tiene instrucciones detalladas para cada paso

2. **Verificar logs de errores:**
   - `flutter doctor -v` para ver detalles de configuración
   - Revisar mensajes de error en terminal

3. **Preguntar a la IA:**
   - La IA puede ayudar a resolver problemas específicos

---

## 📝 NOTAS IMPORTANTES

- **Ruta de Flutter en Mac:** `~/development/flutter` (ajustar según tu instalación)
- **Repositorio:** Asegúrate de tener acceso SSH o HTTPS configurado
- **Firebase:** Los archivos de configuración deben descargarse desde Firebase Console
- **Tiempo estimado:** 2-4 horas (depende de velocidad de descarga de Xcode)

---

**¡Listo! Una vez completado, el proyecto debería funcionar en Mac igual que en Windows.** 🚀

