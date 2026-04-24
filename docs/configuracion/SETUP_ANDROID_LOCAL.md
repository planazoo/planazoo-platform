# 📱 Setup Android local (Planazoo)

Guía rápida para poder ejecutar la app en Android físico/emulador desde este repo.

---

## 1) Pre-requisitos

- Android Studio instalado.
- SDK Android instalado desde Android Studio (SDK Manager).
- JDK disponible (normalmente el embebido en Android Studio).
- `flutter doctor -v` sin error en **Android toolchain**.

> Estado actual detectado en este entorno: `flutter doctor` indica "Unable to locate Android SDK".  
> Hasta resolver eso no se podrá ejecutar `flutter run` en Android.

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

1. Activar **Opciones de desarrollador** y **Depuración USB**.
2. Conectar por USB y aceptar huella RSA.
3. Verificar:

```bash
flutter devices
```

### Opción B — Emulador

1. Crear AVD desde Android Studio.
2. Iniciar emulador.
3. Verificar con `flutter devices`.

---

## 5) Ejecutar Planazoo en Android

Desde raíz del proyecto:

```bash
flutter pub get
flutter run -d <ANDROID_DEVICE_ID>
```

Opcional (release local):

```bash
flutter run --release -d <ANDROID_DEVICE_ID>
```

---

## 6) Smoke test mínimo Android (primer pase)

1. Login con usuario de prueba.
2. Navegación base (lista planes, detalle de plan, calendario).
3. Crear/editar un evento.
4. Verificar token FCM guardado en `users/{uid}/fcmTokens/{token}` (`platform=android`).
5. Probar push de invitación desde otro usuario/dispositivo (flujo T267).

---

## 7) Troubleshooting rápido

- `No Android SDK found`: revisar variables y SDK Manager.
- `No devices found`: revisar USB debugging / emulador encendido.
- `INSTALL_FAILED_*`: desinstalar app previa del dispositivo y relanzar.
- Push no llega: comprobar token en Firestore, permisos de notificación (Android 13+), y Cloud Functions desplegadas.

---

## Referencias

- `docs/tareas/TASKS.md` (T267 — app Android + push FCM).
- `docs/configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md` (contrato de payload push; adaptar casos a Android).
- `docs/testing/TESTING_CHECKLIST.md` (matriz de pruebas funcionales).
