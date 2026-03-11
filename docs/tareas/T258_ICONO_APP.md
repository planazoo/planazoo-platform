# T258 – Icono de la aplicación Planazoo

**Objetivo:** Tener un icono de app propio para iOS y Android (Planazoo), configurado desde código y sin borde blanco que reste espacio visual.

**Referencia en lista:** `docs/tareas/TASKS.md` (T258).

---

## Estado actual (hecho)

- **Asset:** `assets/app_icon/unplanazoo_icon1.png` (PNG, ~1 MB).
- **Configuración:** `pubspec.yaml` con `flutter_launcher_icons`:
  - `image_path`: icono base.
  - **iOS:** `remove_alpha_ios: true`, `background_color_ios: "#79A2A8"` (color de la app) para que las zonas transparentes no se rellenen de blanco.
  - **Android:** `adaptive_icon_background: "#79A2A8"`, `adaptive_icon_foreground` con el mismo PNG.
- **Generación:** `dart run flutter_launcher_icons` genera todos los tamaños en `ios/Runner/Assets.xcassets/AppIcon.appiconset/` y en `android/app/src/main/res/` (mipmap).
- **Clave en pubspec:** bloque `flutter_launcher_icons` (no el deprecado `flutter_icons`).

---

## Pendiente / mejoras opcionales

1. **Si sigue viéndose borde blanco:** El blanco puede estar dibujado en el propio PNG (diseño no a sangre). En ese caso:
   - Sustituir el asset por una versión **full bleed** (diseño que llega a los bordes del canvas, sin márgenes blancos), o
   - Recortar el blanco en un editor (Figma, Photopea, etc.) y volver a generar iconos.
2. **Reducir peso del PNG:** El icono base ocupa ~1 MB; para builds más ligeros se puede exportar una versión optimizada (ej. 1024×1024 px, compresión adecuada) y usarla como `image_path`.
3. **Web / PWA:** Si la app tiene icono en web (favicon, iconos PWA), considerar añadir los mismos assets o enlazar a la misma imagen de marca.

---

## Comandos útiles

```bash
flutter pub get
dart run flutter_launcher_icons
```

Tras cambiar el icono o la config, desinstalar la app en simulador/dispositivo y volver a instalar para evitar caché del icono anterior.
