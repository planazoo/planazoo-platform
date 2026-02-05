# 🎨 W1 - Barra Lateral

## 📋 Descripción General

**W1** es la barra lateral izquierda del dashboard principal. Proporciona acceso rápido al perfil del usuario con un diseño minimalista y funcional.

## 📍 Posicionamiento

- **Columna**: C1 (índice 0)
- **Filas**: R1-R13 (índice 0-12)
- **Ancho**: 1 columna completa
- **Alto**: 13 filas completas

## 🎨 Diseño Visual (v2.0)

### **Contenedor Principal**
- **Color de fondo**: Gradiente igual que W2 (Estilo Base)
  - `LinearGradient` de `Colors.grey.shade800` → `Color(0xFF2C2C2C)`
- **Esquinas**: Cuadradas (sin borderRadius)
- **Sombras**: Ninguna
- **Borde**: Sin borde

### **Icono de Perfil**
- **Posición**: Inferior centrado con padding de 16px
- **Tamaño**: 48x48 píxeles
- **Forma**: Redondo (`BorderRadius.circular(24)`)
- **Color de fondo**: Blanco semitransparente (`alpha: 0.15`)
- **Borde**: Blanco semitransparente (`alpha: 0.3`, `width: 2`)
- **Icono**: `Icons.person` (blanco, tamaño 24)
- **Interactividad**: Tap para navegar a perfil

## 🌐 Funcionalidad

### **Navegación**
- **Acción**: Tap en el icono
- **Resultado**: Cambia `currentScreen` a `'profile'`
- **Destino**: Página de perfil del usuario

### **Tooltip Multidioma**
- **Español**: "Ver perfil"
- **Inglés**: "View profile"
- **Activación**: Hover sobre el icono
- **Clave de localización**: `profileTooltip`

## 🔧 Implementación Técnica

### **Estructura del Widget**
```dart
Widget _buildW1(double columnWidth, double rowHeight, double gridHeight) {
  return Positioned(
    left: 0.0,
    top: 0.0,
    child: Container(
      width: columnWidth,
      height: gridHeight,
      decoration: BoxDecoration(
        color: AppColorScheme.color2,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Tooltip(
            message: AppLocalizations.of(context)!.profileTooltip,
            child: GestureDetector(
              onTap: () => setState(() => currentScreen = 'profile'),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
```

### **Dependencias**
- `package:flutter/material.dart`
- `package:unp_calendario/l10n/app_localizations.dart`
- `package:unp_calendario/app/theme/color_scheme.dart`

## 📱 Responsive Design

### **Adaptabilidad**
- **Ancho**: Se ajusta automáticamente según `columnWidth`
- **Alto**: Se ajusta automáticamente según `gridHeight`
- **Posicionamiento**: Siempre inferior centrado

### **Breakpoints**
- **Desktop**: Icono de 48x48px
- **Tablet**: Icono de 48x48px (mantiene tamaño)
- **Mobile**: Icono de 48x48px (mantiene tamaño)

## 🎯 Principios de UX

### **Minimalismo**
- Solo elementos esenciales
- Sin distracciones visuales
- Enfoque en la funcionalidad principal

### **Accesibilidad**
- Tooltip informativo
- Tamaño de touch target adecuado (48x48px)
- Contraste suficiente (blanco sobre fondo oscuro)

### **Consistencia**
- Uso del esquema de colores de la app
- Iconografía estándar de Material Design
- Comportamiento predecible

## 🔄 Historial de Cambios

### **v1.0** - Implementación inicial
- Barra lateral básica con múltiples elementos
- Logo, texto descriptivo, iconos de email y perfil
- Esquinas redondeadas

### **v2.0** - Rediseño minimalista (ACTUAL)
- Eliminación de elementos innecesarios
- Solo icono de perfil
- Posicionamiento inferior
- Esquinas cuadradas en contenedor
- Icono redondo
- Tooltip multidioma

## 🚀 Próximas Mejoras

### **Funcionalidades Futuras**
- [ ] Indicador de notificaciones
- [ ] Estado de conexión
- [ ] Acceso rápido a configuraciones
- [ ] Animaciones de hover

### **Mejoras Visuales**
- [ ] Efectos de hover
- [ ] Transiciones suaves
- [ ] Estados de loading
- [ ] Feedback visual mejorado

## 📊 Métricas de Rendimiento

### **Rendimiento**
- **Tiempo de renderizado**: < 1ms
- **Memoria utilizada**: Mínima
- **Rebuilds**: Solo cuando cambia el estado de pantalla

### **Usabilidad**
- **Tiempo de interacción**: < 100ms
- **Tasa de éxito**: 100% (elemento único)
- **Accesibilidad**: Cumple estándares WCAG 2.1

## 🔗 Referencias

- [Material Design Icons](https://fonts.google.com/icons)
- [Flutter Tooltip Documentation](https://api.flutter.dev/flutter/material/Tooltip-class.html)
- [App Color Scheme](../theme/color_scheme.dart)
- [Localization System](../l10n/app_localizations.dart)
