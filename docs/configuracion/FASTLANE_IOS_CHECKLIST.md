# Checklist: publicar unp_calendario en App Store (Fastlane)

Vamos paso a paso. Marca cada ítem cuando lo completes y rellena los datos abajo.

**Guía de referencia:** [FASTLANE_IOS_APPSTORE.md](./FASTLANE_IOS_APPSTORE.md)  
**Índice de todas las configuraciones del proyecto (Firebase, Google, Android, Cursor, etc.):** [CONFIGURACIONES_PROYECTO.md](./CONFIGURACIONES_PROYECTO.md)

**Nota:** Fastlane **no tiene cuenta propia**. Usa tu **Apple ID** y los datos de tu cuenta Apple Developer para subir a TestFlight/App Store. No hace falta registrarse en ningún sitio aparte de Apple.

---

## Qué puede faltar (primera vez que publicas)

Si hasta ahora solo has trabajado en local, es posible que falte:

| Qué | Dónde / Cómo |
|-----|----------------|
| **Cuenta Apple Developer** | Inscripción en [Apple Developer Program](https://developer.apple.com/programs/) — 99 €/año. Sin esto no puedes publicar en App Store ni TestFlight. |
| **Team ID** | Aparece cuando ya tienes cuenta Developer (Membership → Team ID). |
| **App en App Store Connect** | Se crea después de tener cuenta Developer; mismo Bundle ID que el proyecto. |
| **Xcode** | Instalado y abierto al menos una vez (aceptar licencia). Necesario para firma y certificados iOS. |
| **Firma y certificados** | Xcode puede generarlos al elegir tu Team en Signing & Capabilities (Paso 3). |
| **App-specific password** | Opcional pero recomendado para que Fastlane no pida 2FA cada vez (appleid.apple.com). |
| **GoogleService-Info.plist (iOS)** | Si usas Firebase/Google Sign-In: descargar desde Firebase Console y añadir a `ios/Runner/`. |
| **google-services.json (Android)** | Para publicar en Play Store más adelante: descargar desde Firebase y poner en `android/app/`. |

---

## Datos que voy anotando (cumplimentar al hacer los pasos)

| Dato | Valor (rellenar aquí) |
|------|------------------------|
| Apple ID (email) |  |
| Team ID (Developer Portal) |  |
| App Store Connect Team ID (itc_team_id) |  |
| Bundle ID que uso | `com.example.unpCalendario` (o el que registres) |
| App-specific password | Creada sí / no — Uso en variable de entorno sí / no |

---

## Progreso paso a paso

### Paso 0: Obtener cuenta Apple Developer (si aún no la tienes)
- [ ] He entrado en [Apple Developer Program](https://developer.apple.com/programs/)
- [ ] He iniciado la inscripción (Enroll) con mi Apple ID
- [ ] He completado el pago (99 €/año) y la verificación si aplica
- [ ] Mi cuenta está activa y puedo entrar en [developer.apple.com](https://developer.apple.com) y en [App Store Connect](https://appstoreconnect.apple.com)
- [ ] He anotado mi **Apple ID** y, en Membership, mi **Team ID** (Paso 0 completado cuando tengas ya el Team ID)
- [x] Tengo **Xcode** instalado y lo he abierto al menos una vez (licencia aceptada). Sin Xcode no se puede firmar ni generar el IPA.

**Notas:**  
*(p. ej. si usas cuenta de organización, el Team ID puede tardar en aparecer)*

- **Estado actual (Paso 0):** Inscripción hecha; pendiente de confirmación por Apple. Cuando esté activa, anotar Apple ID y Team ID en la tabla de arriba y marcar los ítems del Paso 0.

---

### Paso 1: Cuenta Apple y app en App Store Connect
- [x] Tengo cuenta Apple Developer ($99/año) activa
- [x] He entrado en [App Store Connect](https://appstoreconnect.apple.com)
- [x] La app está creada en App Store Connect (o la creo ahora) con el mismo Bundle ID que el proyecto
- [x] He anotado **Apple ID**, **Team ID** y **App Store Connect Team ID** en la tabla de arriba

**Notas:**  
*(escribe aquí si cambiaste el Bundle ID o cualquier incidencia)*

---

### Paso 2: Rellenar Appfile de Fastlane
- [x] He editado `ios/fastlane/Appfile` con mi Apple ID, team_id e itc_team_id  
  **O** he definido las variables de entorno: `FASTLANE_APPLE_ID`, `FASTLANE_TEAM_ID`, `FASTLANE_ITC_TEAM_ID`
- [x] He comprobado que `app_identifier` coincide con el Bundle ID de la app en App Store Connect

**Notas:**

---

### Paso 3: Firma y certificados en Xcode
- [x] He abierto `ios/Runner.xcworkspace` en Xcode
- [x] En **Runner** → **Signing & Capabilities** tengo **Automatically manage signing** activado
- [x] He seleccionado mi **Team** y Xcode ha creado/usa un perfil de distribución (App Store / TestFlight)
- [x] No hay errores de firma en el proyecto

**Notas:**

---

### Paso 4: Instalar Fastlane (bundle install)
- [x] He ido a la carpeta del proyecto y ejecutado: `cd ios` (desde la raíz del repo)
- [x] He ejecutado: `bundle install --path vendor/bundle` (instala en el proyecto, sin usar sudo)
- [x] La instalación termina sin error y existe `ios/Gemfile.lock`
- [x] He comprobado: `bundle exec fastlane --version` (sale la versión)

**Notas:** Si `bundle install` pide contraseña para instalar en el sistema, usa `bundle install --path vendor/bundle` para instalar las gemas dentro de `ios/vendor/bundle` y no tocar el Ruby del sistema.

---

### Paso 5: Generar el IPA con Flutter
- [x] He ejecutado desde la **raíz del proyecto**: `flutter build ipa`
- [x] El build termina correctamente
- [x] Existe el archivo `build/ios/ipa/unp_calendario.ipa` (o el .ipa en build/ios/ipa/)

**Notas:**

---

### Paso 6: Subir a TestFlight (beta)
- [x] He creado una **contraseña específica de apps** en [appleid.apple.com](https://appleid.apple.com) (necesaria si la cuenta tiene 2FA)
- [x] En la misma terminal, antes de fastlane: `export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"` (**no** usar `FASTLANE_PASSWORD` para esto; altool exige la variable oficial)
- [x] He ejecutado desde la raíz del repo: `cd ios && bundle exec fastlane beta`
- [x] Fastlane ha subido el IPA a TestFlight sin error
- [x] Veo el build en App Store Connect → TestFlight

**Notas:**

---

### Paso 7: (Opcional) Subir a App Store (release)
- [ ] En App Store Connect tengo la versión creada y metadatos/capturas rellenados si aplica
- [ ] He ejecutado: `flutter build ipa` (o uso el mismo IPA de beta si es el mismo)
- [ ] He ejecutado: `cd ios && bundle exec fastlane release`
- [ ] El build aparece en la versión de la app en App Store Connect y puedo enviar a revisión cuando quiera

**Notas:**

---

## Resumen rápido de comandos

```bash
# Instalar Fastlane (una vez)
cd ios && bundle install

# Build + subir a TestFlight (cuenta con 2FA: exportar contraseña específica antes)
flutter build ipa
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"
cd ios && bundle exec fastlane beta

# Subir a App Store (release)
flutter build ipa
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"
cd ios && bundle exec fastlane release
```
