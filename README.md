# Planazoo - Plataforma de Planificación de Viajes

## 🚀 Descripción

Planazoo es una aplicación Flutter para la planificación de viajes y eventos, diseñada para ofrecer una experiencia intuitiva y completa en la organización de itinerarios.

## ✨ Características

- 📅 **Calendario Interactivo**: Visualización clara de eventos y actividades
- 🏨 **Gestión de Alojamientos**: Control de reservas y estancias
- 🎯 **Eventos Multi-hora**: Soporte para actividades de larga duración
- 📱 **Interfaz Responsiva**: Diseño adaptativo para diferentes dispositivos
- 🔄 **Estados de Borrador**: Gestión de eventos en desarrollo
- 🎨 **Temas Personalizables**: Múltiples esquemas de color

## 🛠️ Tecnologías

- **Flutter**: Framework de desarrollo móvil
- **Dart**: Lenguaje de programación
- **Riverpod**: Gestión de estado
- **Firebase**: Backend y base de datos
- **Material Design**: Sistema de diseño

## 📁 Estructura del Proyecto

```
lib/
├── app/                    # Configuración de la aplicación
│   ├── theme/             # Temas y estilos
│   └── app_layout_wrapper.dart
├── features/              # Características principales
│   └── calendar/          # Módulo de calendario
│       ├── domain/        # Modelos y servicios
│       ├── presentation/  # UI y widgets
│       │   ├── pages/     # Páginas (pg_*)
│       │   └── widgets/   # Widgets (wd_*)
│       └── providers/     # Gestión de estado
├── shared/                # Código compartido
│   ├── services/          # Servicios comunes
│   ├── utils/             # Utilidades
│   └── widgets/           # Widgets reutilizables
└── core/                  # Configuración base
```

## 🚀 Instalación

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/tu-usuario/planazoo-plataforma.git
   cd planazoo-plataforma
   ```

2. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```

3. **Configurar Firebase**:
   - Agregar `google-services.json` en `android/app/`
   - Agregar `GoogleService-Info.plist` en `ios/Runner/`

4. **Ejecutar la aplicación**:
   ```bash
   flutter run
   ```

## 📱 Plataformas Soportadas

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🎨 Convenciones de Nomenclatura

- **Páginas**: `pg_*` (ej: `pg_home_page.dart`)
- **Widgets**: `wd_*` (ej: `wd_event_card.dart`)
- **Servicios**: `*_service.dart`
- **Modelos**: `*_model.dart`

## 🤝 Contribución

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 👥 Equipo

- **Desarrollo**: Equipo Planazoo
- **Diseño**: Equipo UX/UI

## 📞 Contacto

- **Email**: contacto@planazoo.com
- **Website**: https://planazoo.com
- **GitHub**: https://github.com/tu-usuario/planazoo-plataforma

---

**Planazoo** - Planifica tu viaje perfecto 🎯