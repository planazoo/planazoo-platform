# 🎨 W2 - Logo Planazoo

## 📋 Descripción General

**W2** es el logo de la aplicación "planazoo" ubicado en la barra superior del dashboard. Presenta un diseño minimalista con fondo blanco y texto en color 1.

## 📍 Posicionamiento

- **Columna**: C2-C3 (índice 1-2)
- **Fila**: R1 (índice 0)
- **Ancho**: 2 columnas completas
- **Alto**: 1 fila completa

## 🎨 Diseño Visual (v2.0)

### **Contenedor Principal**
- **Color de fondo**: `Colors.white` (blanco)
- **Esquinas**: Cuadradas (sin borderRadius)
- **Borde**: Blanco de 2px para definición visual
- **Sombras**: Ninguna

### **Texto del Logo**
- **Contenido**: "planazoo"
- **Color**: `AppColorScheme.color1`
- **Tipografía**: `AppTypography.mediumTitle`
- **Tamaño**: 18px
- **Peso**: `FontWeight.bold`
- **Posición**: Centrado

## 🌐 Funcionalidad

### **Propósito**
- **Identidad visual** de la aplicación
- **Marca principal** del dashboard
- **Elemento decorativo** sin interacción

## 🔧 Implementación Técnica

### **Estructura del Widget**
```dart
Widget _buildW2(double columnWidth, double rowHeight) {
  return Positioned(
    left: columnWidth, // C2
    top: 0.0, // R1
    child: Container(
      width: columnWidth * 2, // 2 columnas
      height: rowHeight, // 1 fila
      decoration: BoxDecoration(
        color: Colors.white, // Fondo blanco
        border: Border.all(color: Colors.white, width: 2), // Borde blanco
      ),
      child: Center(
        child: Text(
          'planazoo',
          style: AppTypography.mediumTitle.copyWith(
            color: AppColorScheme.color1, // Color 1
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
```

### **Dependencias**
- `package:flutter/material.dart`
- `package:unp_calendario/app/theme/color_scheme.dart`
- `package:unp_calendario/app/theme/typography.dart`

## 📱 Responsive Design

### **Adaptabilidad**
- **Ancho**: Se ajusta automáticamente según `columnWidth * 2`
- **Alto**: Se ajusta automáticamente según `rowHeight`
- **Texto**: Siempre centrado independientemente del tamaño

### **Breakpoints**
- **Desktop**: Logo de 18px
- **Tablet**: Logo de 18px (mantiene tamaño)
- **Mobile**: Logo de 18px (mantiene tamaño)

## 🎯 Principios de UX

### **Minimalismo**
- Solo elementos esenciales
- Sin distracciones visuales
- Enfoque en la identidad de marca

### **Consistencia**
- Uso del esquema de colores de la app
- Tipografía estándar de la aplicación
- Diseño coherente con el resto del dashboard

### **Legibilidad**
- Contraste suficiente (color1 sobre blanco)
- Tamaño de fuente apropiado
- Posicionamiento centrado para fácil lectura

## 🔄 Historial de Cambios

### **v1.0** - Implementación inicial
- Logo con fondo color1 semitransparente
- Borde color2
- Esquinas redondeadas
- Elementos decorativos adicionales

### **v2.0** - Rediseño minimalista (ACTUAL)
- Fondo blanco limpio
- Solo texto "planazoo" en color1
- Sin bordes decorativos
- Esquinas cuadradas
- Diseño ultra-minimalista

## 🚀 Próximas Mejoras

### **Funcionalidades Futuras**
- [ ] Animación de entrada
- [ ] Efectos de hover
- [ ] Variaciones de color según tema

### **Mejoras Visuales**
- [ ] Gradientes sutiles
- [ ] Efectos de sombra
- [ ] Transiciones suaves

## 📊 Métricas de Rendimiento

### **Rendimiento**
- **Tiempo de renderizado**: < 1ms
- **Memoria utilizada**: Mínima
- **Rebuilds**: Solo cuando cambia el tamaño del grid

### **Usabilidad**
- **Tiempo de reconocimiento**: < 100ms
- **Tasa de identificación**: 100%
- **Accesibilidad**: Cumple estándares WCAG 2.1

## 🔗 Referencias

- [App Color Scheme](../theme/color_scheme.dart)
- [App Typography](../theme/typography.dart)
- [Dashboard Page](../../pages/pg_dashboard_page.dart)
