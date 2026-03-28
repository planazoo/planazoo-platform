# Publicar en App Store (iOS) con Fastlane

Guía paso a paso para subir **unp_calendario** a TestFlight y a la App Store usando Fastlane.

**Referencias:** T256 (`docs/tareas/T256_IMPLEMENTAR_FASTLANE.md`), evaluación T255 (`docs/tareas/archivo/T255_EVALUACION_FASTLANE.md`).  
**Checklist imprimible:** [FASTLANE_IOS_CHECKLIST.md](./FASTLANE_IOS_CHECKLIST.md).  
**Índice de configuraciones:** [CONFIGURACIONES_PROYECTO.md](./CONFIGURACIONES_PROYECTO.md) (sección Apple / Fastlane).

---

## Importante: cuenta con doble factor (2FA)

`upload_to_testflight` invoca **altool** / Content Delivery. Con Apple ID y **2FA activado**, la subida **falla** con error **-22938** (“Sign in with the app-specific password…”) si no usas una **contraseña específica de apps**.

**Antes de `bundle exec fastlane beta` (o `release`), en la misma terminal:**

```bash
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"
```

La contraseña se crea en [appleid.apple.com](https://appleid.apple.com) → **Inicio de sesión y seguridad** → **Contraseñas para apps**.  
**No** uses la contraseña normal de iCloud; **no** commitees este valor (solo variable de entorno local o secreto de CI).

**Recomendación a medio plazo:** [App Store Connect API Key](https://docs.fastlane.tools/app-store-connect-api/) en el `Fastfile` para CI sin contraseñas.

**Alternativa sin fastlane:** arrastra el `.ipa` de `build/ios/ipa/` a la app **Transporter** (Mac App Store).

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
# Con 2FA, obligatoria para subir el IPA (ver sección "Importante" al inicio):
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

El IPA queda en `build/ios/ipa/` (nombre habitual `unp_calendario.ipa`; si Flutter genera otro nombre, la lane toma el primer `.ipa` de esa carpeta, ver `ios/fastlane/Fastfile`).

Si el export falla pero el **archive** existe, Xcode puede exportar manualmente: abre `build/ios/archive/Runner.xcarchive` con **Organizer** → **Distribute App**.

---

## Paso 6: Subir a TestFlight (beta)

Desde la **raíz del repo**:

```bash
cd ios
bundle exec fastlane beta
```

(O en una sola línea desde la raíz: `(cd ios && bundle exec fastlane beta)`.)

La lane **beta** sube el IPA ya generado en `build/ios/ipa/`. Con 2FA, exporta siempre `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` antes de ejecutar (ver arriba).

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
- **`exportArchive No Accounts` / `No signing certificate "iOS Distribution"`**: en **Xcode → Settings → Accounts** debe haber al menos un Apple ID con el equipo del proyecto; hace falta certificado **Apple Distribution** y perfil **App Store** (o gestión automática de firma). Sin cuenta en Xcode, el export del IPA falla.
- **`-22938` / “app-specific password”** al subir: exporta `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` (no la contraseña de iCloud). Ver sección “Importante: cuenta con doble factor” al inicio de este documento.
- **Firma / provisioning**: **Runner** → **Signing & Capabilities** → team y perfil de distribución correctos para **Release**.
- **Bundle ID**: debe coincidir con App Store Connect y `Appfile` (`app_identifier`).

Para más opciones (API Key de App Store Connect, Match para certificados en equipo), ver [Fastlane iOS setup](https://docs.fastlane.tools/getting-started/ios/setup/) y [upload_to_testflight](https://docs.fastlane.tools/actions/upload_to_testflight/).
