# 🎯 Estrategia Multi-Plataforma

> Guía para trabajar con iOS, Android y Web en la app

**Fecha:** Diciembre 2024  
**Última actualización:** Febrero 2026

---

## 📋 Principios

### 1. **Páginas Separadas** (cuando la UX es muy diferente)
- ✅ **Cuándo usar**: Cuando la experiencia de usuario es completamente diferente
- ✅ **Ejemplo**: `DashboardPage` (web) vs `PlansListPage` (móvil)
- ✅ **Ventajas**: Código más claro, fácil de mantener, UX optimizada por plataforma

### 2. **Widgets Compartidos** (componentes comunes)
- ✅ **Cuándo usar**: Componentes que funcionan bien en todas las plataformas
- ✅ **Ejemplos**: `PlanDataScreen`, `PlanCardWidget`, formularios, diálogos
- ✅ **Ventajas**: Reutilización, consistencia, menos código duplicado

### 3. **Adaptación Condicional** (diferencias menores)
- ✅ **Cuándo usar**: Cuando solo cambian tamaños, espaciados o layouts menores
- ✅ **Herramientas**: `MediaQuery`, `LayoutBuilder`, `Platform.isIOS`, `kIsWeb`
- ✅ **Ejemplo**: Padding diferente, tamaños de fuente, columnas vs filas

---

## 🏗️ Estructura de Archivos

### Convención de Nombres
- **`_web.dart`** - Solo web/desktop
- **`_mobile.dart`** - Solo iOS/Android  
- **`_shared.dart`** - Compartida (todas las plataformas)

```
lib/
├── pages/
│   ├── pg_dashboard_web.dart           # Web/Desktop (complejo)
│   ├── pg_plans_list_mobile.dart       # iOS/Android (simple)
│   └── pg_invitation_shared.dart       # Compartida (todas las plataformas)
│
├── widgets/
│   ├── screens/
│   │   ├── wd_plan_data_screen.dart     # Compartida (todas las plataformas)
│   │   ├── wd_calendar_screen.dart      # Compartida (adaptativa)
│   │   └── wd_participants_screen.dart  # Compartida (adaptativa)
│   │
│   └── plan/
│       ├── wd_plan_card_widget.dart     # Compartida (todas las plataformas)
│       └── plan_list_widget.dart        # Compartida (adaptativa)
│
└── app/
    └── app.dart                         # Router principal (detecta plataforma)
```

---

## 🔧 Detección de Plataforma

### En `app.dart` (Router Principal)
```dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

// Detectar plataforma
final isMobile = !kIsWeb && (Platform.isIOS || Platform.isAndroid);
final isWeb = kIsWeb;
final isDesktop = !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

// Usar en routing
home: AuthGuard(
  child: isMobile 
    ? const PlansListPage()      // Móvil: lista simple
    : const DashboardPage(),     // Web/Desktop: dashboard completo
),
```

### En Widgets (Adaptación)
```dart
// Opción 1: MediaQuery (tamaño de pantalla)
final screenWidth = MediaQuery.of(context).size.width;
final isCompact = screenWidth < 900;

// Opción 2: LayoutBuilder (constraints)
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return _buildMobileLayout();
    }
    return _buildDesktopLayout();
  },
)

// Opción 3: Platform (comportamiento específico)
if (Platform.isIOS) {
  // Comportamiento específico de iOS
}
```

---

## 📱 Ejemplos de Implementación

### Ejemplo 1: Página Separada (UX muy diferente)
```dart
// lib/pages/pg_plans_list_page.dart (iOS/Android)
class PlansListPage extends ConsumerWidget {
  // Lista simple, navegación por stack
}

// lib/pages/pg_dashboard_page.dart (Web/Desktop)
class DashboardPage extends ConsumerStatefulWidget {
  // Dashboard complejo con grid, múltiples widgets
}
```

### Ejemplo 2: Widget Compartido (funciona en todas)
```dart
// lib/widgets/screens/wd_plan_data_screen.dart
class PlanDataScreen extends ConsumerStatefulWidget {
  // Funciona perfectamente en todas las plataformas
  // Se adapta automáticamente con MediaQuery
}
```

### Ejemplo 3: Adaptación Condicional (diferencias menores)
```dart
// lib/widgets/plan/wd_plan_card_widget.dart
Widget build(BuildContext context) {
  final isCompact = MediaQuery.of(context).size.width < 600;
  
  return Container(
    padding: EdgeInsets.all(isCompact ? 12 : 20),
    child: Column(
      crossAxisAlignment: isCompact 
        ? CrossAxisAlignment.start 
        : CrossAxisAlignment.center,
      children: [
        // Contenido adaptativo
      ],
    ),
  );
}
```

---

## 🎨 Reglas de Decisión

### ¿Página Separada o Widget Compartido?

**Usa Página Separada si:**
- ❌ La estructura de navegación es diferente (stack vs tabs vs drawer)
- ❌ El layout es completamente diferente (grid vs lista)
- ❌ Hay funcionalidades específicas de plataforma
- ❌ La complejidad es muy diferente

**Usa Widget Compartido si:**
- ✅ La funcionalidad es idéntica
- ✅ Solo cambian tamaños/espaciados
- ✅ El flujo de usuario es el mismo
- ✅ Puede adaptarse con MediaQuery/LayoutBuilder

---

## 📊 Matriz de Decisión

| Componente | Web | iOS | Android | Estrategia | Nombre Archivo |
|------------|-----|-----|---------|-----------|---------------|
| Dashboard | ✅ Complejo | ❌ | ❌ | **Página Separada** | `pg_dashboard_web.dart` |
| Lista de Planes | ✅ En Dashboard | ✅ Simple | ✅ Simple | **Página Separada** | `pg_plans_list_mobile.dart` |
| Detalles Plan | ✅ | ✅ | ✅ | **Widget Compartido** | `wd_plan_data_screen.dart` (sin sufijo) |
| Calendario | ✅ | ✅ | ✅ | **Widget Compartido** (adaptativo) | `wd_calendar_screen.dart` (sin sufijo) |
| Formularios | ✅ | ✅ | ✅ | **Widget Compartido** | `wd_*.dart` (sin sufijo) |
| Diálogos | ✅ | ✅ | ✅ | **Widget Compartido** | `wd_*.dart` (sin sufijo) |
| Cards | ✅ | ✅ | ✅ | **Widget Compartido** (adaptativo) | `wd_*.dart` (sin sufijo) |

**Nota:** Los widgets/screens compartidos NO llevan sufijo (se asume que son compartidos por defecto).

---

## 🚀 Flujo de Trabajo Recomendado

### 1. **Crear Nuevo Componente**
1. ¿Funciona igual en todas las plataformas?
   - ✅ **Sí** → Crear widget compartido
   - ❌ **No** → Continuar

2. ¿La UX es muy diferente?
   - ✅ **Sí** → Crear páginas separadas
   - ❌ **No** → Crear widget adaptativo

### 2. **Modificar Componente Existente**
1. ¿El cambio afecta a todas las plataformas igual?
   - ✅ **Sí** → Modificar widget compartido
   - ❌ **No** → Usar condicionales o crear variante

### 3. **Testing**
- ✅ Probar en iOS (simulador)
- ✅ Probar en Android (emulador)
- ✅ Probar en Web (Chrome)
- ✅ Verificar responsive (diferentes tamaños)

---

## 💡 Buenas Prácticas

### ✅ Hacer
- Usar widgets compartidos cuando sea posible
- Documentar decisiones de diseño por plataforma
- Mantener consistencia visual entre plataformas
- Usar `AppColorScheme` y `AppTypography` en todas las plataformas
- Probar en todas las plataformas antes de mergear

### ❌ Evitar
- Duplicar código innecesariamente
- Crear páginas separadas por diferencias menores
- Hardcodear valores de tamaño (usar MediaQuery)
- Ignorar diferencias importantes de UX
- Asumir que funciona igual en todas las plataformas

---

## 🔄 Migración Futura

### Cuando añadir Android
1. **Verificar páginas móviles**: `PlansListPage` debería funcionar igual
2. **Ajustar si es necesario**: Comportamientos específicos de Android
3. **Testing**: Probar en emulador Android

### Cuando añadir Desktop (Windows/Linux)
1. **Evaluar DashboardPage**: ¿Funciona bien en desktop?
2. **Crear variante si es necesario**: Desktop puede necesitar su propia UX
3. **Testing**: Probar en diferentes resoluciones

---

## 📝 Notas

- **iOS y Android** comparten la misma UX móvil (páginas simples, navegación por stack)
- **Web** tiene UX diferente (dashboard complejo, múltiples widgets)
- **Widgets compartidos** se adaptan automáticamente con MediaQuery
- **Páginas separadas** permiten optimizar UX por plataforma

---

## 🎯 Resumen

**Estrategia Híbrida:**
- 📄 **Páginas separadas** para UX muy diferente (Dashboard vs Lista)
- 🧩 **Widgets compartidos** para componentes comunes (PlanDataScreen, Cards)
- 🔄 **Adaptación condicional** para diferencias menores (tamaños, espaciados)

**Convención de Nombres:**
- `_web.dart` - Solo web/desktop
- `_mobile.dart` - Solo iOS/Android
- `_shared.dart` - Compartida (todas las plataformas)
- Sin sufijo - Widgets/screens compartidos (por defecto)

**Resultado:**
- ✅ Código mantenible
- ✅ UX optimizada por plataforma
- ✅ Menos duplicación
- ✅ Fácil de extender a nuevas plataformas
- ✅ Nombres claros que indican la plataforma objetivo

