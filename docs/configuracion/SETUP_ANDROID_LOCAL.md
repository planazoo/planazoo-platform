# 📱 Setup Android local (Planazoo)

Guía rápida para poder ejecutar la app en Android físico/emulador desde este repo.

---

## 1) Pre-requisitos

- Android Studio instalado.
- SDK Android instalado desde Android Studio (SDK Manager).
- JDK disponible (normalmente el embebido en Android Studio).
- `flutter doctor -v` sin error en **Android toolchain**.

> Si `flutter doctor -v` muestra **Android toolchain** en verde, el SDK ya está bien. Si no, sigue la sección 2.

---

## 2) Configurar SDK Android (macOS)

1. Abrir Android Studio (primera ejecución) y completar instalación de SDK.
2. Ir a **Settings > Android SDK** y confirmar ruta, por ejemplo:
   - `/Users/<tu_usuario>/Library/Android/sdk`
3. Exportar variables (zsh):

```bash
echo 'export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"' >> ~/.zshrc
echo 'export ANDROID_HOME="$ANDROID_SDK_ROOT"' >> ~/.zshrc
echo 'export PATH="$PATH:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"' >> ~/.zshrc
source ~/.zshrc
```

4. Verificar:

```bash
flutter doctor -v
```

Debe desaparecer el error de Android toolchain.

---

## 3) Firebase Android

Para push FCM en Android, confirmar:

- Existe `android/app/google-services.json`.
- `applicationId` Android coincide con la app Android registrada en Firebase.
- Dependencias de Firebase activas (ya hay `firebase_core`, `firebase_messaging` en `pubspec.yaml`).

---

## 4) Preparar dispositivo Android

### Opción A — Móvil físico

1. En el teléfono: **Ajustes → Acerca del teléfono** → tocar **Número de compilación** 7 veces (activa opciones de desarrollador).
2. **Ajustes → Opciones de desarrollador** → activar **Depuración USB**.
3. Conectar por USB con un cable de **datos** (no solo carga). Desbloquear el teléfono.
4. Aceptar el diálogo «¿Permitir depuración USB?» (marcar «Siempre» / confiar en esta huella RSA).
5. Si aparece «USB usado para» / modo USB, elegir **Transferencia de archivos (MTP)** (no solo cargar).
6. Verificar en el Mac:

```bash
adb devices -l
flutter devices
```

Debe aparecer una línea con estado `device` (no `unauthorized` ni lista vacía). Ejemplo real del repo: Samsung `SM A715F` → id `RZ8NC11FRPJ`.

Si `adb devices` está vacío:

```bash
adb kill-server && adb start-server && adb devices
```

Probar otro cable/puerto si sigue vacío.

### Opción B — Emulador

1. Crear AVD desde Android Studio.
2. Iniciar emulador.
3. Verificar con `flutter devices`.

---

## 5) Ejecutar Planazoo en Android

Desde raíz del proyecto:

```bash
flutter pub get
flutter devices
flutter run -d <ANDROID_DEVICE_ID>
```

Opcional (release local):

```bash
flutter run --release -d <ANDROID_DEVICE_ID>
```

Para la matriz 3 usuarios (iPhone + Android + web): ver [`USUARIOS_PRUEBA.md`](./USUARIOS_PRUEBA.md#matriz-mínima-multiplataforma-3-usuarios--3-dispositivos).

---

## 6) Smoke test mínimo Android (primer pase)

1. Login con usuario de prueba.
2. Conceder **permiso de notificaciones** si Android lo pide (API 33+).
3. Navegación base (lista planes, detalle de plan, calendario).
4. Crear/editar un evento.
5. Verificar token FCM guardado en `users/{uid}/fcmTokens/{token}` (`platform=android`).
6. Con la app en **segundo plano**, recibir push de invitación desde otro usuario (canal `planazoo_default`).

---

## 7) Troubleshooting rápido

- `No Android SDK found`: revisar variables y SDK Manager.
- `adb devices` vacío / Flutter no lista el móvil: Depuración USB, cable de datos, MTP, aceptar RSA, `adb kill-server && adb start-server`.
- `unauthorized` en adb: desbloquear teléfono y aceptar depuración de nuevo; si hace falta, revocar autorizaciones USB en Opciones de desarrollador y reconectar.
- `INSTALL_FAILED_*`: desinstalar app previa del dispositivo y relanzar.
- Push no llega: permiso notificaciones (Android 13+), token en Firestore, canal `planazoo_default` (se crea al abrir la app), Cloud Functions desplegadas, app en background al probar.

---

## Referencias

- `docs/tareas/TASKS.md` (T267 — app Android + push FCM).
- `docs/configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md` (contrato de payload push; adaptar casos a Android).
- `docs/configuracion/SETUP_IOS_SIMULATOR.md` (iPhone físico / simulador).
- `docs/configuracion/USUARIOS_PRUEBA.md` (matriz UA/UB/UC).
- `docs/testing/TESTING_CHECKLIST.md` (matriz de pruebas funcionales).
