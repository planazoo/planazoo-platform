# T255 – Evaluar Fastlane para publicar apps iOS y Android

**Objetivo:** Evaluar [Fastlane](https://fastlane.tools/) como herramienta para automatizar la publicación y el despliegue de las apps de Planazoo en iOS (App Store) y Android (Google Play).

**Referencia en lista:** `docs/tareas/TASKS.md` (T255).

**Estado:** Evaluación completada (Marzo 2026).

---

## Alcance

- **Incluye:**
  - Revisión de la documentación y capacidades de Fastlane (https://fastlane.tools/).
  - Valoración de idoneidad para un proyecto Flutter (builds iOS y Android, firma, subida a stores, screenshots, metadatos).
  - Documentar conclusiones: ventajas, requisitos (Ruby, cuentas de desarrollador, CI), pasos recomendados para integrar Fastlane en el repo.
  - Si procede: propuesta de tarea de implementación (configuración inicial de lanes para build + deploy).
- **No incluye:**
  - Implementar Fastlane en el proyecto (eso sería una tarea derivada tras la evaluación).

---

## Resultado de la evaluación

### 1. Qué es Fastlane

Fastlane es una **plataforma open source** para automatizar tareas de desarrollo y publicación de apps móviles (iOS y Android). Permite definir **lanes** (flujos) en Ruby que encadenan acciones: incrementar versión, firmar, construir, subir a TestFlight/App Store o Google Play, generar capturas localizadas, notificar por Slack, etc. Se ejecuta con un solo comando (`fastlane beta`, `fastlane release`, etc.) y se integra con CI (GitHub Actions, CircleCI, etc.).

**Capacidades relevantes para Planazoo:**
- **Screenshots:** Generar capturas localizadas para las stores.
- **Beta:** Subir builds a TestFlight (iOS) y a canales internos/cerrados en Play (Android).
- **Release:** Publicar en App Store y en Google Play (subida de artefactos y metadatos).
- **Code signing (iOS):** Gestión de certificados y perfiles; [Match](https://docs.fastlane.tools/actions/match/) para sincronizar identidades en equipo/CI.
- **Integración CI:** Uso típico con variables de entorno para credenciales (no dejar secrets en el repo).

---

### 2. Idoneidad para Flutter

Fastlane **no sustituye** a Flutter para compilar: Flutter sigue siendo quien genera el IPA (iOS) y el AAB (Android) con `flutter build ipa` y `flutter build appbundle`. Fastlane se usa **después** del build de Flutter para:

- Subir el artefacto ya generado a TestFlight / App Store / Play.
- Gestionar firma iOS (certificados/perfiles) si se hace en CI.
- Incrementar build number, gestionar metadatos, screenshots, etc.

La documentación oficial de Fastlane incluye una [guía para Flutter](https://docs.fastlane.tools/getting-started/cross-platform/flutter/) y remite al [guide de Continuous Delivery de Flutter](https://docs.flutter.dev/deployment/cd), que describe:

- Inicializar Fastlane en `ios/` y en `android/` con `fastlane init`.
- Ajustar `Appfile` (bundle id, team id, package name) y credenciales.
- Definir lanes que llamen a `upload_to_testflight`, `upload_to_app_store`, `upload_to_play_store`, etc., apuntando a los artefactos que genera Flutter (p. ej. `../build/app/outputs/bundle/release/app-release.aab` para Android, o el `.xcarchive` para iOS con `skip_build_archive: true`).

**Conclusión:** Fastlane es **adecuado y muy usado** en proyectos Flutter para automatizar publicación en ambas plataformas sin duplicar lógica manual.

---

### 3. Requisitos

| Requisito | Detalle |
|-----------|---------|
| **Ruby** | Fastlane requiere Ruby 2.5+. Recomendado: no usar el Ruby del sistema en macOS; usar rbenv o Bundler. En CI, instalar Ruby o usar imagen que lo incluya. |
| **Bundler** | Recomendado para fijar versión de Fastlane y dependencias. Crear `Gemfile` en `ios/` y `android/` con `gem "fastlane"`, commitear `Gemfile` y `Gemfile.lock`, ejecutar con `bundle exec fastlane [lane]`. |
| **iOS** | Cuenta Apple Developer ($99/año), app en App Store Connect, certificado de distribución, perfiles de aprovisionamiento. Para CI: Match o variables de entorno para certificados; `FASTLANE_PASSWORD` (o App Store Connect API key) para subida. |
| **Android** | Cuenta Google Play Developer, servicio de cuenta (JSON) para Supply. En CI: contenido del JSON en variable de entorno; keystore de subida (p. ej. en base64) y deserializar en el job. |
| **Flutter** | Proyecto que construya correctamente con `flutter build ipa` y `flutter build appbundle`. |
| **Locale** | Definir `LC_ALL` y `LANG` en UTF-8 (p. ej. `en_US.UTF-8`) para evitar fallos en build/upload. |

---

### 4. Ventajas y desventajas

**Ventajas:**
- Un solo ecosistema para iOS y Android (misma filosofía, dos carpetas).
- Comunidad grande, muchas [actions](https://docs.fastlane.tools/actions/) y [plugins](https://docs.fastlane.tools/plugins/available-plugins/).
- Encaja con Flutter: Flutter hace el build, Fastlane automatiza firma, versión, subida y metadatos.
- Funciona en local y en CI; documentación oficial y guía Flutter claras.
- Code signing en iOS simplificado con Match para equipos y CI.

**Desventajas / consideraciones:**
- Dependencia de Ruby y de mantener `Fastfile`/`Appfile` en dos carpetas.
- Curva de aprendizaje si el equipo no conoce Ruby (la sintaxis de los Fastfile es sencilla).
- Para *solo* subir a stores desde máquina local, el valor es menor que cuando se automatiza en CI (donde Fastlane brilla).

---

### 5. Recomendación

**Sí, usar Fastlane** para Planazoo, con este orden de prioridad:

1. **Lanes beta (prioridad alta)**  
   - **iOS:** Lane que, tras `flutter build ipa` (o uso del `.xcarchive` existente), suba a TestFlight con `upload_to_testflight`.  
   - **Android:** Lane que, tras `flutter build appbundle`, suba a una pista interna/cerrada con `upload_to_play_store` (o Firebase App Distribution si se prefiere para betas rápidas).

2. **Lanes release (siguiente)**  
   - Subida a App Store y a Google Play para releases de producción, con incremento de versión/build y, si se desea, gestión de metadatos desde Fastlane.

3. **Screenshots y metadatos (opcional)**  
   - Automatizar capturas y metadatos cuando el equipo quiera reducir trabajo manual en las stores.

4. **CI (recomendado)**  
   - Integrar las lanes en GitHub Actions (u otro CI): build con Flutter en el job, luego `bundle exec fastlane beta` o `release` en `ios/` y `android/`, con secrets en variables de entorno (Match para iOS, JSON key y keystore para Android).

---

### 6. Pasos recomendados para integrar (resumen)

1. **Comprobar builds Flutter:**  
   `flutter build ipa` y `flutter build appbundle` deben completar sin error.

2. **Inicializar Fastlane:**  
   En `[proyecto]/ios` y `[proyecto]/android`: `fastlane init` (elegir descargar metadatos existentes si la app ya está en las stores).

3. **Configurar Appfile en cada plataforma:**  
   - iOS: `app_identifier`, `apple_id`, `itc_team_id`, `team_id`.  
   - Android: `package_name`; para Supply, cuenta de servicio y `fastlane supply init`.

4. **Credenciales y firma:**  
   - iOS: certificado de distribución y perfiles; en CI, considerar Match.  
   - Android: keystore de release y JSON de cuenta de servicio; en CI, variables de entorno.

5. **Crear Fastfile por plataforma:**  
   - Lanes que llamen a `upload_to_testflight` / `upload_to_app_store` (iOS) y `upload_to_play_store` (Android), apuntando a los artefactos generados por Flutter (rutas indicadas en la [guía Flutter CD](https://docs.flutter.dev/deployment/cd)).

6. **Usar Gemfile:**  
   En `ios/` y `android/`, añadir `Gemfile` con `gem "fastlane"`, `bundle install`, commitear `Gemfile` y `Gemfile.lock`, y ejecutar siempre con `bundle exec fastlane [lane]`.

7. **Opcional – CI:**  
   Añadir job que instale Flutter, Ruby, Bundler, ejecute `flutter build ...` y luego `bundle exec fastlane [lane]` con secrets inyectados por el CI.

---

### 7. Referencias

- **Fastlane:** https://fastlane.tools/
- **Docs Fastlane – Flutter:** https://docs.fastlane.tools/getting-started/cross-platform/flutter/
- **Flutter – Continuous delivery (CD):** https://docs.flutter.dev/deployment/cd
- **Fastlane – Setup iOS:** https://docs.fastlane.tools/getting-started/ios/setup/
- **Fastlane – Android setup / Supply:** https://docs.fastlane.tools/getting-started/android/setup/
- **Fastlane – iOS beta (TestFlight):** https://docs.fastlane.tools/getting-started/ios/beta-deployment/
- **Fastlane – Android beta/release:** https://docs.fastlane.tools/getting-started/android/beta-deployment/ y release deployment
- **Match (code signing):** https://docs.fastlane.tools/actions/match/
- **Ejemplos Flutter + Fastlane + GitHub Actions:**  
  - [Automate Flutter Deployments (Constant Solutions)](https://constantsolutions.dk/2024/06/06/automate-flutter-deployments-to-app-store-and-play-store-using-fastlane-and-github-actions/)  
  - [Flutter iOS CI/CD with Fastlane & GitHub Actions](https://aws.plainenglish.io/flutter-ios-ci-cd-automated-testflight-deployment-with-fastlane-github-actions-step-by-step-ac3b4b1c7ce0)

---

### 8. Tarea derivada sugerida

Crear una tarea de implementación (p. ej. **T256** o siguiente código disponible) para:

- Añadir `fastlane init` en `ios/` y `android/`, configurar `Appfile` y credenciales locales.
- Definir al menos una lane **beta** por plataforma que suba a TestFlight y a Play (pista interna).
- Añadir `Gemfile` en ambas carpetas y documentar en el repo los comandos (`bundle exec fastlane beta`, etc.).
- Opcional: job de GitHub Actions (o otro CI) que ejecute las lanes en push a `main` o al crear un tag de release.

---

## Entregables (originales)

1. ~~Documento breve de evaluación~~ → **Completado:** este documento con la sección "Resultado de la evaluación".
2. ~~Recomendación~~ → **Sí, usar Fastlane;** priorizar lanes beta, luego release, luego screenshots/metadatos; integrar en CI cuando sea posible.
3. ~~Referencias~~ → Incluidas en la sección 7.
