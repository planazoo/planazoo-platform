# Publicar una versión (web + iOS)

Orden operativo para **sacar una versión** a producción web y TestFlight.  
No sustituye las guías detalladas: las enlaza.

**App canónica:** `https://app.planoon.com` (Hosting también en `https://planazoo.web.app`).  
**iOS:** TestFlight primero; App Store cuando se decida. **Android:** más adelante.

---

## Orden de pasos

| # | Paso | Cuándo / criterio |
|---|------|-------------------|
| 1 | Inventario de qué hay que publicar | Antes de tocar git |
| 2 | Calidad mínima | Analyze + tests de lo que cambia |
| 3 | Versión iOS | Subir `version` en `pubspec.yaml` si hay IPA nuevo |
| 4 | Commit y push | Código y docs de producto en git |
| 5 | Backend Firebase | Solo si cambiaron rules / índices / storage / functions |
| 6 | Publicar web | Build + Hosting |
| 7 | Verificar web en producción | Humo en `app.planoon.com` |
| 8 | Publicar iOS (TestFlight) | IPA + Fastlane `beta` o `altool` si Spaceship pide 2FA |
| 9 | Verificar TestFlight | Humo en dispositivo |
| 10 | Revisar y actualizar la documentación de este proceso | Cerrar el ciclo |
| — | Android (Play) | Fuera de este ciclo hasta que se acuerde |

No hace falta App Store (`fastlane release`) en cada ciclo. Android no entra aquí.

---

## 1. Inventario

Mirar `git status` y decidir **qué** sale a producción:

| Si cambió… | Hay que desplegar / construir |
|------------|-------------------------------|
| App Flutter (`lib/`, `web/`, assets, l10n) | Web (paso 6) y/o IPA (paso 8) |
| `functions/` | `npx firebase deploy --only functions` |
| `firestore.rules` | `npx firebase deploy --only firestore:rules` |
| `firestore.indexes.json` | `npx firebase deploy --only firestore:indexes` |
| `storage.rules` | `npx firebase deploy --only storage` |

Hosting **no** sube rules, índices ni functions.

---

## 2. Calidad mínima

Desde la raíz:

```bash
dart analyze
```

Más los tests del área que cambia (p. ej. `flutter test test/features/calendar/`).  
No publicar con analyzer en rojo ni con tests rotos del cambio.

---

## 3. Versión (iOS / TestFlight)

En `pubspec.yaml`, `version` es `x.y.z+build` (hoy: `1.0.0+11`).

- Cada subida a TestFlight necesita un **`+build` nuevo**.
- Si solo se publica web, el bump es opcional.

---

## 4. Commit y push

Commit de lo que entra en la versión (sin secretos: `.env`, contraseñas Apple, API keys).  
No incluir capturas sueltas, `.firebase/*cache` ni `ios/fastlane/report.xml`.  
Push a remoto. **Git no despliega solo.**

---

## 5. Backend Firebase (si aplica)

Desde la raíz, solo los destinos del inventario. Ejemplos:

```bash
npx firebase deploy --only firestore:rules
npx firebase deploy --only firestore:indexes
npx firebase deploy --only storage
npx firebase deploy --only functions
```

Detalle: [DESPLEGAR_REGLAS_FIRESTORE.md](./DESPLEGAR_REGLAS_FIRESTORE.md), [DEPLOY_INDICES_FIRESTORE.md](./DEPLOY_INDICES_FIRESTORE.md).

---

## 6. Publicar web

Clave Places: [ACCESOS_Y_CUENTAS.md](./ACCESOS_Y_CUENTAS.md) § *Places / Maps* (no copiar el valor aquí).

```bash
export PLACES_API_KEY  # valor desde ACCESOS_Y_CUENTAS.md
flutter build web --dart-define=PLACES_API_KEY="$PLACES_API_KEY"
npx firebase-tools deploy --only hosting
```

Sin `PLACES_API_KEY` el mapa no llama a Maps JS. Setup primer Hosting: [DEPLOY_WEB_FIREBASE_HOSTING.md](./DEPLOY_WEB_FIREBASE_HOSTING.md). Places en GCP: [CONFIGURAR_GOOGLE_PLACES_API.md](./CONFIGURAR_GOOGLE_PLACES_API.md).

---

## 7. Verificar web

Abrir **`https://app.planoon.com`** (no solo `planazoo.web.app`):

- HTTP 200 y `index.html` de Flutter (mínimo si no hay browser tools)
- Login
- Un plan: resumen, calendario, mapa si aplica
- Invitación / campana si el cambio las toca

---

## 8. Publicar iOS (TestFlight)

Misma `PLACES_API_KEY` que en web ([ACCESOS_Y_CUENTAS.md](./ACCESOS_Y_CUENTAS.md) § Places):

```bash
export PLACES_API_KEY  # valor desde ACCESOS_Y_CUENTAS.md
flutter build ipa --dart-define=PLACES_API_KEY="$PLACES_API_KEY"
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD  # § Application Password
cd ios && bundle exec fastlane beta
```

El IPA suele llamarse `build/ios/ipa/planazoo.ipa` (Fastlane toma el `*.ipa` de esa carpeta).

**Contraseña específica de apps:** no está en este runbook (a propósito). El valor temporal vive en [ACCESOS_Y_CUENTAS.md](./ACCESOS_Y_CUENTAS.md) § *Application Password*. Exportarla a `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD`; no copiarla aquí ni en el chat. Cuando Bitwarden esté activo, leerla de ahí.

**Fastlane vs altool:** `bundle exec fastlane beta` entra primero en Spaceship (App Store Connect). Si la sesión caducó, pide código 2FA y falla con `Unauthorized Access` **aunque** la contraseña específica esté bien. En ese caso **no** recompilar el IPA; subir con `altool`:

```bash
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD  # valor desde ACCESOS_Y_CUENTAS.md
xcrun altool --upload-app --type ios \
  -f build/ios/ipa/planazoo.ipa \
  -u unplanazoo@gmail.com \
  -p "$FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD"
```

El build aparece en App Store Connect → TestFlight tras unos minutos de procesamiento.

Guía: [FASTLANE_IOS_APPSTORE.md](./FASTLANE_IOS_APPSTORE.md). Checklist: [FASTLANE_IOS_CHECKLIST.md](./FASTLANE_IOS_CHECKLIST.md).  
App Store (`fastlane release`) es un paso extra, no de cada ciclo.

---

## 9. Verificar TestFlight

Cuando el build esté listo en App Store Connect:

- Instalar desde TestFlight
- Mismo humo que en web (login, plan, lo que cambió)
- Paridad web/iOS: [REVISION_IOS_VS_WEB.md](./REVISION_IOS_VS_WEB.md)

---

## 10. Revisar y actualizar la documentación de este proceso

Tras un ciclo real, alinear docs con lo que **se hizo** (comandos, URLs, versión, trampas):

| Documento | Qué comprobar |
|-----------|----------------|
| **Este archivo** | Orden, comandos, versión de ejemplo, omisiones |
| [DEPLOY_WEB_FIREBASE_HOSTING.md](./DEPLOY_WEB_FIREBASE_HOSTING.md) | Build (`dart-define`), Hosting, URL canónica `app.planoon.com` |
| [FASTLANE_IOS_APPSTORE.md](./FASTLANE_IOS_APPSTORE.md) / [FASTLANE_IOS_CHECKLIST.md](./FASTLANE_IOS_CHECKLIST.md) | Comandos, 2FA, Bundle ID |
| [CONTEXT.md](./CONTEXT.md) §10 / §10.1 | `npx` Firebase + iOS |
| [CONFIGURACIONES_PROYECTO.md](./CONFIGURACIONES_PROYECTO.md) | Índice: este runbook como entrada |
| [docs/README.md](../README.md) | Enlace a este runbook |
| [DOMINIO_PLANOON.md](./DOMINIO_PLANOON.md) | Estado de Hosting / SSL / AASA si se tocó |
| [TIMELINE_LANZAMIENTO.md](../producto/TIMELINE_LANZAMIENTO.md) | Soft launch (0.2) si aplica |

Si un comando falló y se resolvió: una línea en [LOG_ERRORES_AUTOFIX.md](./LOG_ERRORES_AUTOFIX.md).

Commit de esos ajustes de docs (puede ir en el mismo push del paso 4 si ya se sabían, o en uno corto al final).

---

## Android (fuera de este ciclo)

Play Store no está en este orden. Cuando se publique: `applicationId` / firma en [CONFIGURACIONES_PROYECTO.md](./CONFIGURACIONES_PROYECTO.md) §5 y T256.
