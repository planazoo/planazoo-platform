# Configuraciones del proyecto (índice)

Índice de todas las configuraciones relevantes del proyecto: Cursor, Firebase, Google, Apple/Fastlane, Android, variables de entorno y referencias a documentación existente.

**Mantener este documento actualizado** cuando se añadan nuevas integraciones o se cambie dónde se documenta cada cosa.

---

## 1. Cursor (IDE / IA)

| Qué | Dónde | Documentación |
|-----|--------|----------------|
| Reglas de la IA | `.cursor/rules/` | Reglas que se aplican en el workspace (p. ej. `error-learning.mdc` para registro de errores en `LOG_ERRORES_AUTOFIX.md`). |
| Skills | `.cursor/skills-cursor/` | Skills disponibles para el agente (crear reglas, skills, ajustar settings). |
| **Uso de tokens** | `.cursorignore` | Exclusiones para que Cursor no indexe ni envíe como contexto carpetas pesadas (build/, node_modules/, ios/vendor/bundle/, android/.gradle/, etc.). Reduce consumo de tokens y evita cuelgues. |

**Archivos típicos:** `.cursor/rules/*.mdc`, `.cursorignore`. No hay "cuenta Cursor" que configurar en el repo; la suscripción es por usuario.

---

## 2. Firebase

| Qué | Dónde en el repo | Documentación / Cómo configurar |
|-----|-------------------|----------------------------------|
| Proyecto Firebase | ID: **planazoo** | [Firebase Console](https://console.firebase.google.com/) → proyecto planazoo. |
| Opciones cliente (web) | `lib/firebase_options.dart` | Generado por FlutterFire CLI; contiene `apiKey`, `projectId`, `authDomain`, `storageBucket`, `messagingSenderId`, `appId`, `measurementId`. **No subir claves secretas**; este archivo suele estar en el repo para web; restringir por dominio en Google Cloud. |
| Hosting (web) | `firebase.json` → `hosting` | `public: build/web`; rewrites a `index.html`. Ver [DEPLOY_WEB_FIREBASE_HOSTING.md](./DEPLOY_WEB_FIREBASE_HOSTING.md). URL producción: `https://planazoo.web.app`. |
| Firestore | `firestore.rules`, `firestore.indexes.json` | Reglas e índices. Despliegue: `npx firebase deploy --only firestore:rules`. Ver [DESPLEGAR_REGLAS_FIRESTORE.md](./DESPLEGAR_REGLAS_FIRESTORE.md), [FIRESTORE_COLLECTIONS_AUDIT.md](./FIRESTORE_COLLECTIONS_AUDIT.md), [FIRESTORE_INDEXES_AUDIT.md](./FIRESTORE_INDEXES_AUDIT.md). |
| Storage | `storage.rules` | Reglas de Cloud Storage. Despliegue: `npx firebase deploy --only storage`. Ver [STORAGE_CORS.md](./STORAGE_CORS.md), [IMAGENES_PLAN_FIREBASE.md](./IMAGENES_PLAN_FIREBASE.md). |
| Functions | `functions/` | Node.js; ver `functions/package.json`. Despliegue: `npx firebase deploy --only functions`. |
| **iOS:** GoogleService-Info.plist | `ios/Runner/GoogleService-Info.plist` | **No está en el repo** (en `.gitignore`). Descargar desde Firebase Console → proyecto → Configuración del proyecto → apps iOS → añadir o descargar `GoogleService-Info.plist`. Necesario para Auth, Analytics, etc. en iOS. |
| **Android:** google-services.json | `android/app/google-services.json` | **No está en el repo** (en `.gitignore`). Descargar desde Firebase Console → apps Android. Necesario para build Android con Firebase. |

---

## 3. Google (APIs, Sign-In, Places)

| Qué | Dónde | Documentación |
|-----|--------|----------------|
| Google Sign-In | Firebase Auth + `web/index.html` (meta `google-signin-client_id`) | [CONFIGURAR_GOOGLE_SIGNIN.md](./CONFIGURAR_GOOGLE_SIGNIN.md). Requiere Web client ID en `web/index.html` y proveedor Google habilitado en Firebase Auth. |
| Google Places API | Google Cloud Console (proyecto planazoo) | [CONFIGURAR_GOOGLE_PLACES_API.md](./CONFIGURAR_GOOGLE_PLACES_API.md). Habilitar Places API, API key con restricciones; facturación activa (crédito gratis mensual). |
| Otras APIs Google | [Google Cloud Console](https://console.cloud.google.com/) → APIs y servicios | Mismo proyecto que Firebase (planazoo). Cualquier API nueva (Maps, etc.) se habilita y restringe aquí. |

---

## 4. Apple ID / Fastlane (iOS, App Store, TestFlight)

| Qué | Dónde | Documentación |
|-----|--------|----------------|
| Apple Developer | Cuenta en [developer.apple.com](https://developer.apple.com) | Inscripción en Apple Developer Program (99 €/año). Team ID en Membership. |
| App Store Connect | [appstoreconnect.apple.com](https://appstoreconnect.apple.com) | Crear la app con el mismo Bundle ID que el proyecto. itc_team_id en Users and Access. |
| Fastlane (iOS) | `ios/Gemfile`, `ios/fastlane/Appfile`, `ios/fastlane/Fastfile` | Appfile: `app_identifier`, `apple_id`, `team_id`, `itc_team_id`. No hay "cuenta Fastlane"; usa Apple ID. Ver [FASTLANE_IOS_APPSTORE.md](./FASTLANE_IOS_APPSTORE.md), [FASTLANE_IOS_CHECKLIST.md](./FASTLANE_IOS_CHECKLIST.md). |
| Bundle ID (iOS) | `ios/Runner.xcodeproj` (y `ios/fastlane/Appfile`) | Actual: `com.example.unpCalendario`. Debe coincidir con el registrado en App Store Connect. |
| Firma iOS | Xcode → Runner → Signing & Capabilities | Certificados y perfiles de aprovisionamiento (Automatically manage signing + Team). |

---

## 5. Android

| Qué | Dónde | Documentación |
|-----|--------|----------------|
| applicationId | `android/app/build.gradle` → `defaultConfig.applicationId` | Actual: `com.example.unp_calendario`. Para publicar en Play Store conviene cambiarlo a un ID único (p. ej. `com.tudominio.unpcalendario`) y configurar firma release. |
| namespace | `android/app/build.gradle` → `android.namespace` | Actual: `com.pzoo.planazoo`. |
| Firma release | `android/app/build.gradle` → `buildTypes.release.signingConfig` | Actualmente usa `signingConfigs.debug`. Para producción: keystore de release y configuración en `signingConfigs`. |
| google-services.json | `android/app/google-services.json` | En `.gitignore`; descargar desde Firebase Console. |

Fastlane para Android (T256) está previsto; cuando se implemente, documentar en este índice y en `android/fastlane/`.

---

## 6. Variables de entorno y secretos

| Qué | Dónde | Notas |
|-----|--------|--------|
| .env | Raíz del proyecto | En `.gitignore`. No commitear `.env`, `.env.local`, `.env.production`. Usar para claves o URLs sensibles si la app las lee en runtime. |
| Fastlane (Apple) | Opcional: variables de entorno | `FASTLANE_APPLE_ID`, `FASTLANE_TEAM_ID`, `FASTLANE_ITC_TEAM_ID`, `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` para no poner datos en `Appfile`. |

**Seguridad:** Ver [GUIA_SEGURIDAD.md](../guias/GUIA_SEGURIDAD.md). No hardcodear API keys secretas ni contraseñas en código.

---

## 7. Otras configuraciones documentadas

| Tema | Documento |
|------|-----------|
| Gmail / correo (SMTP, buzón) | [EMAILS_CON_GMAIL_SMTP.md](./EMAILS_CON_GMAIL_SMTP.md), [GMAIL_INBOUND_BUZON.md](./GMAIL_INBOUND_BUZON.md), [GUIA_PASO_A_PASO_GMAIL_EN.md](./GUIA_PASO_A_PASO_GMAIL_EN.md) |
| Amadeus (vuelos) | [CONFIGURAR_AMADEUS_FLIGHT_STATUS.md](./CONFIGURAR_AMADEUS_FLIGHT_STATUS.md) |
| Simulador iOS | [SETUP_IOS_SIMULATOR.md](./SETUP_IOS_SIMULATOR.md) |
| FCM (notificaciones) | [FCM_FASE1_IMPLEMENTACION.md](./FCM_FASE1_IMPLEMENTACION.md) |
| Usuarios de prueba | [USUARIOS_PRUEBA.md](./USUARIOS_PRUEBA.md) |
| Testing | [TESTING_CHECKLIST.md](./TESTING_CHECKLIST.md) |

---

## 8. Google Sites

**En este proyecto no hay configuración específica de Google Sites** (no hay integración con Google Sites en el código ni en Firebase). Si en el futuro se usa Google Sites para una landing o sitio de marketing, añadir aquí la referencia y crear un doc en `docs/configuracion/` si hace falta (URL del sitio, permisos, etc.).

---

## Resumen rápido por “primera vez que publico”

- **iOS (App Store / TestFlight):** [FASTLANE_IOS_CHECKLIST.md](./FASTLANE_IOS_CHECKLIST.md) (incluye Paso 0: cuenta Apple Developer, Xcode, luego Fastlane y subida).
- **Web (producción):** [DEPLOY_WEB_FIREBASE_HOSTING.md](./DEPLOY_WEB_FIREBASE_HOSTING.md).
- **Android (Play Store):** Por hacer (T256); mientras tanto: `applicationId` y firma en `android/app/build.gradle`, `google-services.json` desde Firebase.
