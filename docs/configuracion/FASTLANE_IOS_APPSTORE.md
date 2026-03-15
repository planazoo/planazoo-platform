# Publicar en App Store (iOS) con Fastlane

Guía paso a paso para subir **unp_calendario** a TestFlight y a la App Store usando Fastlane.

**Referencias:** T256 (`docs/tareas/T256_IMPLEMENTAR_FASTLANE.md`), evaluación T255 (`docs/tareas/archivo/T255_EVALUACION_FASTLANE.md`).

---

## Requisitos previos

- **macOS** (necesario para compilar y firmar iOS).
- **Ruby 2.5+** (en tu sistema suele venir 2.6; recomendado usar `rbenv` si quieres una versión fija).
- **Bundler:** `gem install bundler` si no lo tienes.
- **Cuenta Apple Developer** ($99/año) y app creada en **App Store Connect**.
- **Xcode** instalado y abierto al menos una vez (aceptar licencia).
- **Flutter** configurado y proyecto que compile: `flutter build ipa` desde la raíz del proyecto.

---

## Paso 1: Configurar identidad de la app

1. En **Apple Developer** (developer.apple.com) y en **App Store Connect** (appstoreconnect.apple.com):
   - Crea la app si aún no existe (mismo **Bundle ID** que el proyecto: `com.example.unpCalendario`).
   - Si quieres otro Bundle ID (por ejemplo `com.tudominio.unpcalendario`), cámbialo en Xcode (`ios/Runner.xcodeproj`) y en `ios/fastlane/Appfile` (`app_identifier`).

2. Anota:
   - **Apple ID** (email de la cuenta desarrollador).
   - **Team ID** (Developer → Membership → Team ID).
   - **App Store Connect Team ID** (Users and Access → Team ID; a veces coincide con el anterior).

---

## Paso 2: Configurar Fastlane (Appfile)

Edita `ios/fastlane/Appfile` y sustituye los placeholders:

- `apple_id`: tu email de Apple Developer.
- `team_id`: Team ID del Developer Portal.
- `itc_team_id`: Team ID de App Store Connect.

O bien define variables de entorno (útil para CI o para no dejar el email en el repo):

```bash
export FASTLANE_APPLE_ID="tu@email.com"
export FASTLANE_TEAM_ID="XXXXXXXXXX"
export FASTLANE_ITC_TEAM_ID="XXXXXXXXXX"
```

Para subir a TestFlight, Fastlane puede pedirte la **contraseña de Apple ID**. Mejor usar una **App-specific password** (appleid.apple.com → Sign-In and Security → App-Specific Passwords) y definir:

```bash
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"
```

---

## Paso 3: Instalar dependencias

Desde la raíz del proyecto:

```bash
cd ios
bundle install
```

Esto crea/actualiza `Gemfile.lock`. Ejecuta siempre Fastlane con:

```bash
bundle exec fastlane <lane>
```

---

## Paso 4: Firma y certificados

Para que `flutter build ipa` genere un IPA válido para App Store / TestFlight:

1. Abre `ios/Runner.xcworkspace` en Xcode.
2. Selecciona el target **Runner** → **Signing & Capabilities**.
3. Marca **Automatically manage signing** y elige tu **Team**.
4. Asegúrate de tener un **certificado de distribución** (Distribution) y un **perfil de aprovisionamiento** para App Store/TestFlight (Xcode puede crearlos al hacer el primer archive).

Si ya has archivado la app desde Xcode con éxito, la firma está lista para usar con Flutter.

---

## Paso 5: Generar el IPA con Flutter

Desde la **raíz del proyecto** (no desde `ios/`):

```bash
flutter build ipa
```

El IPA se generará en: `build/ios/ipa/unp_calendario.ipa`.

---

## Paso 6: Subir a TestFlight (beta)

Desde la raíz:

```bash
cd ios
bundle exec fastlane beta
```

La lane **beta** usa el IPA ya generado en `build/ios/ipa/unp_calendario.ipa` y lo sube a TestFlight. La primera vez te pedirá Apple ID y contraseña (o usará las variables de entorno si las definiste).

Opciones útiles en `ios/fastlane/Fastfile`:
- `skip_waiting_for_build_processing: true`: no espera a que Apple procese el build (más rápido).
- Puedes descomentar la línea que ejecuta `flutter build ipa` dentro de la lane para hacer build + subida en un solo comando.

---

## Paso 7: Subir a App Store (release)

Cuando quieras publicar en la App Store (no solo TestFlight):

1. En App Store Connect, crea la versión de la app y rellena metadatos (descripción, capturas, etc.) si aún no está.
2. Desde la raíz del proyecto, genera el IPA y sube:

```bash
flutter build ipa
cd ios
bundle exec fastlane release
```

La lane **release** sube el IPA con `upload_to_app_store` (`submit_for_review: false` para no enviar a revisión automáticamente; puedes hacerlo después desde App Store Connect).

---

## Resumen de comandos

| Objetivo              | Comandos |
|-----------------------|----------|
| Solo instalar Fastlane | `cd ios && bundle install` |
| Beta (TestFlight)     | `flutter build ipa` → `cd ios && bundle exec fastlane beta` |
| Release (App Store)  | `flutter build ipa` → `cd ios && bundle exec fastlane release` |

---

## Errores frecuentes

- **"No se encontró el IPA"**: ejecuta `flutter build ipa` desde la raíz del proyecto antes de `fastlane beta` o `release`.
- **Firma / provisioning**: revisa en Xcode que el target Runner tenga Signing correcto y un perfil de distribución.
- **Bundle ID**: debe coincidir con el registrado en App Store Connect y en `Appfile` (`app_identifier`).
- **Contraseña Apple**: usa App-specific password y `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` para evitar fallos con 2FA.

Para más opciones (API Key de App Store Connect, Match para certificados en equipo), ver [Fastlane iOS setup](https://docs.fastlane.tools/getting-started/ios/setup/) y [upload_to_testflight](https://docs.fastlane.tools/actions/upload_to_testflight/).
