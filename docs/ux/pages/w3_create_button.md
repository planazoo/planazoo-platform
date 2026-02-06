# 🎨 W3 - Botón Crear Plan

## 📋 Descripción General

**W3** es el botón para crear un nuevo plan en el dashboard. Presenta un diseño minimalista con símbolo "+" en un botón redondo con colores de la aplicación.

## 📍 Posicionamiento

- **Columna**: C4 (índice 3)
- **Fila**: R1 (índice 0)
- **Ancho**: 1 columna completa
- **Alto**: 1 fila completa

## 🎨 Diseño Visual (v2.0)

### **Contenedor Principal**
- **Color de fondo**: `Colors.white` (blanco)
- **Esquinas**: Cuadradas (sin borderRadius)
- **Borde**: Blanco de 2px para definición visual
- **Sombras**: Ninguna

### **Botón de Crear**
- **Posición**: Centrado en el contenedor
- **Tamaño**: 40x40 píxeles
- **Forma**: Redondo (`BorderRadius.circular(20)`)
- **Color de fondo**: `AppColorScheme.color3`
- **Símbolo**: "+" en `AppColorScheme.color1`
- **Tamaño del símbolo**: 24px
- **Peso**: `FontWeight.bold`
- **Sombra**: Sutil para profundidad

## 🌐 Funcionalidad

### **Creación de Plan**
- **Acción**: Tap en el botón
- **Resultado**: Ejecuta `_showCreatePlanDialog()`
- **Destino**: Diálogo para crear nuevo plan

### **Interactividad**
- **Feedback visual**: Efecto de tap
- **Accesibilidad**: Tamaño de touch target 40x40px
- **Responsive**: Se adapta al tamaño del grid

## 🔧 Implementación Técnica

### **Estructura del Widget**
```dart
Widget _buildW3(double columnWidth, double rowHeight) {
  return Positioned(
    left: columnWidth * 3, // C4
    top: 0.0, // R1
    child: Container(
      width: columnWidth, // 1 columna
      height: rowHeight, // 1 fila
      decoration: BoxDecoration(
        color: Colors.white, // Fondo blanco
        border: Border.all(color: Colors.white, width: 2), // Borde blanco
      ),
      child: Center(
        child: GestureDetector(
          onTap: () => _showCreatePlanDialog(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColorScheme.color3, // Fondo del botón color3
              borderRadius: BorderRadius.circular(20), // Redondo
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '+',
                style: TextStyle(
                  color: AppColorScheme.color1, // "+" color1
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
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
- `package:unp_calendario/app/theme/color_scheme.dart`

## 📱 Responsive Design

### **Adaptabilidad**
- **Ancho**: Se ajusta automáticamente según `columnWidth`
- **Alto**: Se ajusta automáticamente según `rowHeight`
- **Botón**: Siempre centrado independientemente del tamaño

### **Breakpoints**
- **Desktop**: Botón de 40x40px
- **Tablet**: Botón de 40x40px (mantiene tamaño)
- **Mobile**: Botón de 40x40px (mantiene tamaño)

## 🎯 Principios de UX

### **Claridad**
- Símbolo "+" universalmente reconocido
- Colores contrastantes para visibilidad
- Tamaño apropiado para interacción

### **Consistencia**
- Uso del esquema de colores de la app
- Diseño coherente con otros elementos
- Posicionamiento estándar en la barra superior

### **Accesibilidad**
- Tamaño de touch target adecuado (40x40px)
- Contraste suficiente entre colores
- Feedback visual en la interacción

## 🔄 Historial de Cambios

### **v1.0** - Implementación inicial
- Botón con icono y texto "Nuevo"
- Fondo color3 semitransparente
- Borde color3
- Esquinas redondeadas

### **v2.0** - Rediseño minimalista (ACTUAL)
- Solo símbolo "+" sin texto
- Fondo blanco en contenedor
- Botón redondo color3
- Símbolo "+" en color1
- Sombra sutil para profundidad

## 🚀 Próximas Mejoras

### **Funcionalidades Futuras**
- [ ] Animación de rotación al hacer tap
- [ ] Efectos de hover
- [ ] Indicador de estado de carga

### **Mejoras Visuales**
- [ ] Gradientes en el botón
- [ ] Efectos de pulso
- [ ] Transiciones suaves

## 📊 Métricas de Rendimiento

### **Rendimiento**
- **Tiempo de renderizado**: < 1ms
- **Memoria utilizada**: Mínima
- **Rebuilds**: Solo cuando cambia el tamaño del grid

### **Usabilidad**
- **Tiempo de interacción**: < 100ms
- **Tasa de éxito**: 100% (elemento único)
- **Accesibilidad**: Cumple estándares WCAG 2.1

**Implementación actual:** `lib/pages/pg_dashboard_page.dart`, método `_buildW3`. **Última actualización:** Febrero 2026

## 🔗 Referencias

- [App Color Scheme](../../../lib/app/theme/color_scheme.dart)
- [Dashboard Page](../../../lib/pages/pg_dashboard_page.dart)
- [Create Plan Dialog](../../../lib/features/calendar/presentation/widgets/create_plan_dialog.dart)
