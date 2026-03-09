# T256 – Implementar Fastlane para publicar apps iOS y Android

**Objetivo:** Integrar Fastlane en el proyecto Planazoo para automatizar builds y publicación en App Store (iOS) y Google Play (Android), siguiendo la evaluación realizada en T255.

**Referencia en lista:** `docs/tareas/TASKS.md` (T256).  
**Evaluación previa:** `docs/tareas/T255_EVALUACION_FASTLANE.md`.

---

## Alcance

- **Incluye:**
  - Inicializar Fastlane en `ios/` y `android/` (`fastlane init`).
  - Configurar `Appfile` en cada plataforma (bundle id, team id, package name, cuentas).
  - Configurar credenciales locales (firma iOS, keystore y JSON de cuenta de servicio en Android).
  - Crear al menos una **lane beta** por plataforma:
    - **iOS:** Tras `flutter build ipa`, subir a TestFlight (`upload_to_testflight`).
    - **Android:** Tras `flutter build appbundle`, subir a pista interna (`upload_to_play_store`).
  - Añadir `Gemfile` (y `Gemfile.lock`) en `ios/` y `android/` con `gem "fastlane"`; documentar en el repo el uso de `bundle exec fastlane [lane]`.
  - Documentar en README o en `docs/configuracion/` los pasos para ejecutar las lanes y los requisitos (Ruby, Bundler, cuentas desarrollador).
- **Opcional (fase posterior):**
  - Lanes **release** (App Store y Google Play producción).
  - Integración en CI (p. ej. GitHub Actions): job que ejecute `flutter build ...` y `bundle exec fastlane beta` (o release) con secrets en variables de entorno.
  - Uso de [Match](https://docs.fastlane.tools/actions/match/) para sincronizar certificados iOS en equipo/CI.

---

## Requisitos previos (según T255)

- Ruby 2.5+ (recomendado: rbenv o Bundler, no Ruby del sistema en macOS).
- Cuenta Apple Developer y app en App Store Connect; certificado de distribución.
- Cuenta Google Play Developer; cuenta de servicio (JSON) para Supply; keystore de release.
- Proyecto Flutter que construya correctamente con `flutter build ipa` y `flutter build appbundle`.
- Variables de entorno `LC_ALL` y `LANG` en UTF-8 (p. ej. `en_US.UTF-8`).

---

## Criterios de aceptación

1. Desde la raíz del proyecto (o desde `ios/` y `android/`), se puede ejecutar una lane que suba un build a TestFlight (iOS) y otra que suba a una pista interna de Play (Android).
2. Los comandos y requisitos están documentados (README o `docs/configuracion/`).
3. `Gemfile` y `Gemfile.lock` están en el repositorio en `ios/` y `android/`.

---

## Referencias

- T255: `docs/tareas/T255_EVALUACION_FASTLANE.md`
- Flutter CD: https://docs.flutter.dev/deployment/cd
- Fastlane Flutter: https://docs.fastlane.tools/getting-started/cross-platform/flutter/
- Fastlane iOS setup: https://docs.fastlane.tools/getting-started/ios/setup/
- Fastlane Android setup: https://docs.fastlane.tools/getting-started/android/setup/
