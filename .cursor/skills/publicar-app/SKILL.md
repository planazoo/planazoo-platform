---
name: publicar-app
description: >-
  Executes the Planazoo release cycle (git, Firebase backend, web Hosting,
  iOS TestFlight) without waiting for per-step confirmation. Use when the
  user asks to publicar, publicar la app, sacar versión, release, deploy
  web, TestFlight, or to run the PUBLICAR_APP process.
---

# Publicar app

Ejecutar **todo** el ciclo de `docs/configuracion/PUBLICAR_APP.md` de forma
autónoma cuando el usuario lo pida. No pedir confirmación entre pasos.
Android queda fuera. App Store (`fastlane release`) solo si lo pide.

## Arranque

1. Leer `docs/configuracion/PUBLICAR_APP.md` (fuente de verdad).
2. Copiar el checklist y marcarlo mientras avanzas.

```
- [ ] 1 Inventario
- [ ] 2 Calidad
- [ ] 3 Versión iOS
- [ ] 4 Commit y push
- [ ] 5 Backend Firebase
- [ ] 6 Web (build + Hosting)
- [ ] 7 Verificar web
- [ ] 8 iOS TestFlight
- [ ] 9 Verificar TestFlight (o dejar claro qué no se pudo)
- [ ] 10 Docs del proceso
```

## 1 Inventario

`git status`. Decidir destinos:

| Cambió | Destino |
|--------|---------|
| `lib/`, `web/`, assets, l10n | Web + IPA |
| `functions/` | `npx firebase deploy --only functions` |
| `firestore.rules` | `--only firestore:rules` |
| `firestore.indexes.json` | `--only firestore:indexes` |
| `storage.rules` | `--only storage` |

No commitear secretos, capturas sueltas (`flutter_*.png`),
`.firebase/*cache` ni `ios/fastlane/report.xml`.

## 2 Calidad

```bash
dart analyze
```

Tests del área que cambia (p. ej. `flutter test test/features/calendar/`
si tocó planes/eventos/mapa). Parar si hay **errores** de analyzer o tests
en rojo. Warnings/info previos no bloquean.

## 3 Versión

Si hay IPA: subir `+build` en `pubspec.yaml` (`x.y.z+N`). Actualizar el
ejemplo de versión en `PUBLICAR_APP.md`.

## 4 Commit y push

Un commit de la versión (mensaje `feat`/`fix`/`docs` al estilo del repo).
Push a la rama actual. Git **no** despliega.

## 5 Backend

Solo destinos del inventario, desde la raíz, con `npx`.

## 6 Web

Clave Places/Maps: `docs/configuracion/ACCESOS_Y_CUENTAS.md` § Places.
No escribirla en código ni en el resumen al usuario.

```bash
flutter build web --dart-define=PLACES_API_KEY="$PLACES_API_KEY"
npx firebase-tools deploy --only hosting
```

## 7 Verificar web

Abrir `https://app.planoon.com`: carga, login si hay sesión, humo del
cambio. Si no hay browser tools, curl/HTTP y decirlo.

## 8 iOS

```bash
flutter build ipa --dart-define=PLACES_API_KEY="$PLACES_API_KEY"
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD
cd ios && bundle exec fastlane beta
```

IPA: `build/ios/ipa/planazoo.ipa`. Contraseña en
`docs/configuracion/ACCESOS_Y_CUENTAS.md` § Application Password.
Si Fastlane pide 2FA / `Unauthorized Access`, no rebuild: subir con
`xcrun altool --upload-app` (esa contraseña sí vale para altool).

## 9 TestFlight

El procesamiento en App Store Connect tarda. Indicar que hay que instalar
cuando el build esté Ready. No esperar la revisión de Apple.

## 10 Docs

Alinear `PUBLICAR_APP.md` y guías enlazadas con lo que **se hizo**.
Errores nuevos → `docs/configuracion/LOG_ERRORES_AUTOFIX.md`. Commit corto
de docs si hace falta.

## Al cerrar

Resumen breve: qué se desplegó, URLs, versión `x.y.z+N`, qué quedó
pendiente (TestFlight password, Android, App Store).
