# Planoon (Planazoo) — monorepo

App Flutter (iOS / Android / web) + **web comercial** + documentación compartida.

| Pieza | Dónde | URL |
|-------|--------|-----|
| Documentación | [`docs/`](docs/) | — |
| App | raíz Flutter (`lib/`, `ios/`, …) | [app.planoon.com](https://app.planoon.com) |
| Landing | [`marketing/`](marketing/) | `planoon.com` (deploy pendiente) |

Detalle: [`docs/configuracion/MONOREPO.md`](docs/configuracion/MONOREPO.md) · Dominio: [`docs/configuracion/DOMINIO_PLANOON.md`](docs/configuracion/DOMINIO_PLANOON.md).

---

## 🚀 Descripción

Planoon es una aplicación Flutter para la planificación de viajes y eventos, diseñada con arquitectura **Offline First** para ofrecer una experiencia intuitiva y completa en la organización de itinerarios colaborativos.

## ✨ Características Principales

### 📅 **Calendario Inteligente**
- Visualización clara de eventos y actividades con precisión de minutos
- Sistema de eventos multi-día (hasta 24h por evento)
- Detección automática de eventos solapados (máximo 3 simultáneos)
- Drag & Drop con magnetismo para reorganizar eventos
- Auto-scroll inteligente al primer evento

### 🏨 **Gestión de Alojamientos**
- Control de reservas y estancias por día
- Integración visual con el calendario
- Tipos predefinidos: Hotel, Apartamento, Hostal, Casa, Resort, Camping

### 👥 **Colaboración y Permisos**
- Sistema de roles: Admin, Participante, Observador
- Eventos con parte común (para todos) + parte personal (individual)
- Permisos granulares por acción y tipo de evento

### 🌍 **Soporte de Timezones**
- Sistema "UTC del Plan" para eventos internacionales
- Conversión automática por participante
- Eventos cross-timezone (vuelos, transportes internacionales)

### 📱 **Offline First**
- Funcionalidad completa sin conexión a internet
- Sincronización automática cuando hay conexión
- Resolución automática de conflictos
- Cola de sincronización para cambios pendientes

### 🔔 **Notificaciones Push**
- Cambios en eventos existentes
- Nuevos eventos y eliminaciones
- Modificaciones de participantes
- Configuración personalizable por usuario

## 🛠️ Tecnologías

- **Flutter**: Framework de desarrollo móvil
- **Dart**: Lenguaje de programación
- **Riverpod**: Gestión de estado reactiva
- **Firebase/Firestore**: Backend y base de datos en la nube
- **SQLite/Hive**: Base de datos local para offline
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

## 📚 Documentación

### **Documentos Principales**
- 📖 **[Decisiones Arquitectónicas](docs/arquitectura/ARCHITECTURE_DECISIONS.md)** - Todas las decisiones fundamentales del proyecto
- 📋 **[Tareas Pendientes](docs/tareas/TASKS.md)** - Lista de tareas y próximos pasos (Siguiente: T137)
- ✅ **[Tareas Completadas](docs/tareas/COMPLETED_TASKS.md)** - Historial de implementaciones
- 📅 **[Capacidades del Calendario](docs/especificaciones/CALENDAR_CAPABILITIES.md)** - Funcionalidades y reglas de negocio
- 🧟 **[Plan Frankenstein](docs/especificaciones/FRANKENSTEIN_PLAN_SPEC.md)** - Plan de testing completo

### **Conceptos Clave**
- **Offline First**: La app funciona sin conexión, sincroniza cuando es posible
- **EventSegment**: Sistema para eventos multi-día (basado en Google Calendar)
- **Máximo 3 eventos simultáneos**: Regla de negocio para legibilidad del calendario
- **Eventos máximo 24h**: Para actividades, usa alojamientos para estancias largas
- **Sistema de Tracks**: Cada participante es un track (columna) en el calendario

## 🏗️ Arquitectura

### **8 Decisiones Fundamentales**
1. **Duplicación Total (MVP)** → Optimización automática futura
2. **Sincronización Híbrida** → Transactions + Optimistic Updates
3. **UTC del Plan** → Timezone base con conversión por participante
4. **Parte Común + Personal** → Eventos con información compartida e individual
5. **Notificaciones Push** → Sistema completo de alertas
6. **Tiempo Real** → Firestore Listeners + Riverpod
7. **Offline First Completo** → CRUD sin conexión + sincronización automática
8. **Permisos Granulares** → Roles + permisos específicos por acción

Ver detalles completos en **[ARCHITECTURE_DECISIONS.md](docs/arquitectura/ARCHITECTURE_DECISIONS.md)**

## 🚀 Próximos Pasos

### **En Desarrollo (T56-T67)**
- **T56-T62**: Implementación Offline First completa
- **T63-T67**: Sistema de permisos granulares

### **Pendientes**
- Timezones (T40-T45)
- Sistema de participantes (T46-T50)
- Validación y seguridad (T51-T53)

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