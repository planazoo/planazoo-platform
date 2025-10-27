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

### Colores Actuales de la App (AppColorScheme)

**⚠️ IMPORTANTE: Estos son los colores que ya existen en `lib/app/theme/color_scheme.dart`**

```dart
// Sistema de colores personalizado existente
class AppColorScheme {
  // Colores principales según la propuesta original del usuario
  static const Color color0 = Color(0xFFFFFFFF);     // Fondo principal (blanco)
  static const Color color1 = Color(0xFFBCE1E7);     // Fondos secundarios (verde azulado claro)
  static const Color color2 = Color(0xFF79A2A8);      // Elementos interactivos (verde azulado)
  static const Color color3 = Color(0xFFA24000);     // Botones de acción (naranja oscuro)
  static const Color color4 = Color(0xFF4F606A);     // Texto y bordes (gris azulado oscuro)
  
  // Colores adicionales para tipografías
  static const Color titleColor = Color(0xFF00796B);      // Títulos (verde oscuro)
  static const Color bodyColor = Color(0xFF424242);       // Cuerpo de texto (gris oscuro)
  static const Color interactiveColor = Color(0xFF1976D2); // Texto interactivo (azul)
  
  // Colores para estados
  static const Color hoverColor = Color(0xFF5D8A90);       // Hover (verde azulado medio)
  static const Color activeColor = Color(0xFF8B5A00);      // Activo (naranja oscuro)
  static const Color disabledColor = Color(0xFFB0BEC5);    // Deshabilitado (gris)
  
  // Colores para la UX Demo Page
  static const Color gridLineColor = Color(0xFFE0E0E0);
  static const Color widgetBackgroundColor = Color(0xFFF5F5F5);
  static const Color widgetBorderColor = Color(0xFFBDBDBD);
}
```

### Reglas de Uso

- **color0 (Blanco)**: Fondo principal, tarjetas, superficies limpias
- **color1 (Verde Azulado Claro)**: Fondos secundarios, barras de navegación
- **color2 (Verde Azulado)**: Elementos interactivos, botones principales, AppBar
- **color3 (Naranja Oscuro)**: Botones de acción, CTAs importantes, alertas
- **color4 (Gris Azulado Oscuro)**: Texto principal, bordes, elementos estructurales
- **titleColor (Verde Oscuro)**: Títulos de secciones, headers
- **bodyColor (Gris Oscuro)**: Texto de cuerpo, descripciones
- **interactiveColor (Azul)**: Enlaces, texto interactivo

---

## 📐 TIPOGRAFÍA

### Tipografías Actuales de la App (AppTypography)

**⚠️ IMPORTANTE: Estos son los estilos que ya existen en `lib/app/theme/typography.dart`**

```dart
class AppTypography {
  // Familias de fuentes
  static const String titleFont = 'Roboto';
  static const String bodyFont = 'Roboto';
  static const String interactiveFont = 'Open Sans';
  
  // Estilos de títulos
  static const TextStyle titleStyle = TextStyle(
    fontFamily: titleFont,
    fontWeight: FontWeight.bold,
    fontSize: 24.0,
    color: AppColorScheme.titleColor,
  );
  
  static const TextStyle largeTitle = TextStyle(
    fontFamily: titleFont,
    fontWeight: FontWeight.bold,
    fontSize: 32.0,
    color: AppColorScheme.titleColor,
  );
  
  static const TextStyle mediumTitle = TextStyle(
    fontFamily: titleFont,
    fontWeight: FontWeight.bold,
    fontSize: 20.0,
    color: AppColorScheme.titleColor,
  );
  
  // Estilos de cuerpo
  static const TextStyle bodyStyle = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.normal,
    fontSize: 16.0,
    color: AppColorScheme.bodyColor,
  );
  
  static const TextStyle smallBody = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.normal,
    fontSize: 14.0,
    color: AppColorScheme.bodyColor,
  );
  
  // Estilos de texto interactivo
  static const TextStyle interactiveStyle = TextStyle(
    fontFamily: interactiveFont,
    fontWeight: FontWeight.w500,
    fontSize: 14.0,
    color: AppColorScheme.interactiveColor,
  );
  
  // Caption (texto pequeño)
  static const TextStyle caption = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.normal,
    fontSize: 12.0,
    color: AppColorScheme.color4,
  );
}
```

### Reglas de Uso

- **largeTitle (32px, bold)**: Títulos principales de página (Dashboard, Plan)
- **titleStyle (24px, bold)**: Secciones principales
- **mediumTitle (20px, bold)**: Subtítulos de secciones
- **bodyStyle (16px)**: Texto general, descripciones
- **smallBody (14px)**: Texto secundario
- **interactiveStyle (14px, medium)**: Enlaces, CTAs
- **caption (12px)**: Texto secundario, fechas pequeñas

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

**Lo que ya existe en el código:**
- ✅ `AppColorScheme` en `lib/app/theme/color_scheme.dart` (color0-color4, estados)
- ✅ `AppTypography` en `lib/app/theme/typography.dart` (titleStyle, bodyStyle, etc.)
- ✅ `AppTheme` en `lib/app/theme/app_theme.dart` (tema light configurado)
- ✅ Componentes de calendario específicos
- ✅ Algunos componentes básicos reutilizables
- ✅ Navegación estructurada

**Lo que falta (para completar el sistema):**
- ❌ Sistema de espaciado estandarizado (`AppSpacing`)
- ❌ Componentes UI reutilizables completos (botones, cards, inputs documentados)
- ❌ Catálogo de iconos documentado y estandarizado
- ❌ Documentación visual de componentes existentes
- ❌ Responsive design completo con breakpoints definidos
- ❌ Checklist de implementación para nuevos componentes

---

*Guía de UI para mantener consistencia visual*  
*Última actualización: Enero 2025*

