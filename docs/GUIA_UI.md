# 🎨 Guía de Interfaz de Usuario (UI)

> Define todos los parámetros, componentes y patrones de diseño para mantener consistencia visual en toda la aplicación

**Relacionado con:** T91, T92  
**Versión:** 1.0  
**Fecha:** Enero 2025

---

## 🎯 Objetivo

Establecer un sistema de diseño consistente que:
- Mantenga coherencia visual en toda la app
- Permita cambios globales de forma fácil
- Proporcione componentes reutilizables
- Facilite el desarrollo sin experiencia de UI

---

## 🎨 SISTEMA DE COLORES

### Colores Principales

```dart
// Usar AppColorScheme para todos los colores
class AppColors {
  // Colores primarios
  static const Color primary = Color(0xFF2196F3);      // Azul (acción principal)
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);
  
  // Colores secundarios
  static const Color secondary = Color(0xFF4CAF50);     // Verde (éxito)
  static const Color secondaryDark = Color(0xFF388E3C);
  static const Color secondaryLight = Color(0xFF81C784);
  
  // Colores de acento
  static const Color accent = Color(0xFFFF9800);        // Naranja (alerta/importante)
  static const Color accentDark = Color(0xFFF57C00);
  static const Color accentLight = Color(0xFFFFB74D);
  
  // Colores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Colores neutros
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);
  
  // Colores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  // Colores específicos del calendario
  static const Color trackBorder = Color(0xFFE0E0E0);
  static const Color eventDefault = Color(0xFF2196F3);
  static const Color eventHover = Color(0xFF1976D2);
  static const Color accommodationDefault = Color(0xFF4CAF50);
}
```

### Reglas de Uso

- **Primario (Azul)**: Botones principales, enlaces, acciones importantes
- **Secundario (Verde)**: Éxito, confirmaciones, estados positivos
- **Acento (Naranja)**: Alertas, advertencias, eventos importantes
- **Texto**: Usar niveles de opacidad (primary, secondary, disabled)
- **Fondo**: Surface blanco para contenido, background gris claro para contenedores

---

## 📐 TIPOGRAFÍA

### Familias de Fuentes

```dart
class AppTypography {
  // Títulos
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    height: 1.3,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );
  
  // Texto de cuerpo
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.15,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    height: 1.43,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.33,
  );
  
  // Especiales
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.25,
    height: 1.5,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.33,
  );
  
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1.5,
  );
}
```

### Reglas de Uso

- **H1**: Títulos de página (Dashboard, Plan)
- **H2**: Secciones principales
- **H3**: Subtítulos de secciones
- **Body**: Texto general, descripciones
- **Button**: Botones y CTAs
- **Caption**: Texto secundario, fechas pequeñas
- **Overline**: Etiquetas, badges

---

## 📦 ESPACIADO Y LAYOUT

### Sistema de Espaciado

```dart
class AppSpacing {
  static const double xs = 4.0;    // Elementos muy cercanos
  static const double sm = 8.0;     // Elementos relacionados
  static const double md = 16.0;   // Espaciado estándar
  static const double lg = 24.0;   // Separación de secciones
  static const double xl = 32.0;   // Separación mayor
  static const double xxl = 48.0;  // Separación de página
}
```

### Breakpoints Responsivos

```dart
class AppBreakpoints {
  static const double mobile = 600;      // Móvil
  static const double tablet = 960;       // Tablet
  static const double desktop = 1280;    // Desktop
  static const double large = 1920;      // Pantalla grande
}
```

### Reglas de Uso

- Usar `AppSpacing` para padding y margins consistentes
- Evitar valores hardcodeados (no `SizedBox(height: 20)` → usar `SizedBox(height: AppSpacing.md)`)
- Layout responsive usando `LayoutBuilder` y breakpoints

---

## 🔘 COMPONENTES REUTILIZABLES

### Botones

```dart
// Usar siempre estos componentes, NO crear botones ad-hoc

// Botón principal
AppPrimaryButton(
  text: "Guardar",
  onPressed: () {},
  icon: Icons.save,
)

// Botón secundario
AppSecondaryButton(
  text: "Cancelar",
  onPressed: () {},
)

// Botón de texto
AppTextButton(
  text: "Ver más",
  onPressed: () {},
)

// Botón con estado de carga
AppLoadingButton(
  text: "Guardando...",
  isLoading: true,
)
```

### Tarjetas y Contenedores

```dart
// Tarjeta estándar
AppCard(
  child: Column(...),
  elevation: 2,
  margin: EdgeInsets.all(AppSpacing.md),
)

// Tarjeta elevada
AppCard.elevated(
  child: ...,
  elevation: 4,
)

// Tarjeta con sombra
AppCard.shadow(
  child: ...,
)

// Contenedor con padding estándar
AppContainer(
  padding: AppSpacing.md,
  child: ...,
)
```

### Inputs y Formularios

```dart
// Campo de texto estándar
AppTextInput(
  label: "Nombre",
  hint: "Ingresa tu nombre",
  controller: controller,
)

// Campo con validación
AppTextInput.validated(
  label: "Email",
  hint: "email@ejemplo.com",
  validator: (value) => ...,
)

// Checkbox
AppCheckbox(
  title: "Aceptar términos",
  value: accepted,
  onChanged: (value) {},
)

// Switch
AppSwitch(
  title: "Notificaciones",
  value: enabled,
  onChanged: (value) {},
)
```

### Badges y Etiquetas

```dart
// Badge de estado
AppBadge(
  text: "Activo",
  color: AppColors.success,
)

// Badge de prioridad
AppBadge.priority(
  level: PriorityLevel.high,
)

// Etiqueta
AppLabel(
  text: "URGENTE",
  color: AppColors.error,
)
```

---

## 🎭 ICONOS

### Sistema de Iconos

```dart
// Todos los iconos deben usar Material Icons de forma consistente

// Navegación
static const IconData navHome = Icons.home_outlined;
static const IconData navCalendar = Icons.calendar_today_outlined;
static const IconData navSettings = Icons.settings_outlined;

// Acciones
static const IconData actionAdd = Icons.add_circle_outline;
static const IconData actionEdit = Icons.edit_outlined;
static const IconData actionDelete = Icons.delete_outline;
static const IconData actionSave = Icons.save_outlined;
static const IconData actionCancel = Icons.cancel_outlined;

// Estados
static const IconData stateSuccess = Icons.check_circle_outline;
static const IconData stateError = Icons.error_outline;
static const IconData stateWarning = Icons.warning_outline;
static const IconData stateInfo = Icons.info_outline;

// Eventos
static const IconData eventDefault = Icons.event_outlined;
static const IconData eventFlight = Icons.flight_outlined;
static const IconData eventHotel = Icons.hotel_outlined;
static const IconData eventFood = Icons.restaurant_outlined;

// Usuarios y Participantes
static const IconData userProfile = Icons.person_outline;
static const IconData userGroup = Icons.people_outline;
static const IconData userAdd = Icons.person_add_outlined;
```

### Widget de Icono Consistente

```dart
// Widget wrapper para iconos consistentes
AppIcon(
  icon: AppIcons.eventDefault,
  size: AppIconSize.medium,
  color: AppColors.primary,
)

enum AppIconSize {
  small(16),
  medium(24),
  large(32),
  xlarge(48);
  
  final double value;
  const AppIconSize(this.value);
}
```

---

## 🎨 TEMAS Y MODO OSCURO

### Implementación de Temas

```dart
// Usar ThemeProvider para cambio de tema fácil
final themeProvider = Provider((ref) {
  return AppTheme.light(); // o .dark()
});

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      // ... más configuración
    );
  }
  
  static ThemeData dark() {
    return ThemeData(
      primaryColor: AppColors.primaryDark,
      scaffoldBackgroundColor: AppColors.textPrimary,
      // ... más configuración
    );
  }
}
```

---

## 📐 MEJORES PRÁCTICAS

### ✅ Hacer

- Usar los componentes de `AppColors`, `AppTypography`, `AppSpacing`
- Crear widgets en `lib/widgets/ui/` para cualquier componente reutilizable
- Usar `LayoutBuilder` para responsive
- Seguir el sistema de espaciado (xs, sm, md, lg, xl, xxl)
- Usar iconos de Material Icons consistentemente
- Documentar nuevos componentes en esta guía

### ❌ Evitar

- Colores hardcodeados (`Colors.blue`)
- Espaciado hardcodeado (`SizedBox(height: 20)`)
- Crear variantes de botones sin usar los componentes base
- Mezclar diferentes tamaños de iconos sin sistema
- Inconsistencia en tamaños de fuente
- Crear componentes sin añadirlos a la guía

---

## 🚀 FUTUROS CAMBIOS FÁCILES

### Cambiar Colores Globalmente

```dart
// Cambiar en AppColors en lib/shared/theme/app_colors.dart
// Todos los componentes automáticamente actualizados
```

### Cambiar Iconos Globalmente

```dart
// Cambiar en AppIcons en lib/shared/ui/app_icons.dart
// Refactorizar iconos de manera global
```

### Cambiar Espaciado

```dart
// Cambiar valores en AppSpacing
// Layout se ajustará proporcionalmente
```

---

## 📋 CHECKLIST PARA NUEVAS PANTALLAS

- [ ] Usar colores de `AppColors`
- [ ] Usar tipografía de `AppTypography`
- [ ] Usar espaciado de `AppSpacing`
- [ ] Usar componentes de `lib/widgets/ui/`
- [ ] Usar iconos de `AppIcons`
- [ ] Layout responsive con breakpoints
- [ ] Probar en diferentes tamaños de pantalla
- [ ] Documentar componentes nuevos en esta guía

---

## 📊 TAREAS RELACIONADAS

**Pendientes:**
- T91: Sistema de colores y tipografía
- T92: Componentes reutilizables de UI

**Completas ✅:**
- Base de color scheme definido
- Sistema de espaciado básico

---

## ✅ IMPLEMENTACIÓN ACTUAL

**Estado:** ⚠️ Parcialmente implementado

**Lo que ya existe:**
- ✅ `AppColorScheme` definido
- ✅ Algunos componentes básicos
- ✅ Navegación estructurada

**Lo que falta:**
- ❌ Sistema completo de tipografía
- ❌ Sistema completo de espaciado
- ❌ Componentes UI reutilizables
- ❌ Catálogo de iconos documentado
- ❌ Responsive design completo
- ❌ Documentación visual de componentes

---

*Guía de UI para mantener consistencia visual*  
*Última actualización: Enero 2025*

