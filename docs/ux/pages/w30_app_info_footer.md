# W30 - Pie de página informaciones app

## Descripción
Widget de pie de página dedicado a mostrar informaciones de la aplicación. Ubicado en la fila inferior del dashboard, proporciona espacio para información relevante sobre la app.

## Ubicación en el Grid
- **Posición**: C6-C17, R13
- **Dimensiones**: 12 columnas de ancho × 1 fila de alto
- **Área**: Fila inferior completa del dashboard

## Diseño Visual

### Colores
- **Fondo**: Gradiente igual que W1/W2 (Estilo Base)
  - `LinearGradient` de `Colors.grey.shade800` → `Color(0xFF2C2C2C)`
- **Borde**: Sin borde
- **Esquinas**: Ángulo recto (sin borderRadius)

### Contenido
- **Estado actual**: Sin contenido visible
- **Propósito**: Reservado para futuras informaciones de la app

## Funcionalidad
- **Interacción**: Ninguna
- **Estado**: Estático
- **Propósito**: Área reservada para información de la aplicación

## Implementación Técnica

### Widget Principal
```dart
Widget _buildW30(double columnWidth, double rowHeight) {
  // W30: C6-C17 (R13) - Pie de página informaciones app
  final w30X = columnWidth * 5; // Empieza en la columna C6 (índice 5)
  final w30Y = rowHeight * 12; // Empieza en la fila R13 (índice 12)
  final w30Width = columnWidth * 12; // Ancho de 12 columnas (C6-C17)
  final w30Height = rowHeight; // Alto de 1 fila (R13)
  
  return Positioned(
    left: w30X,
    top: w30Y,
    child: Container(
      width: w30Width,
      height: w30Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade800,
              const Color(0xFF2C2C2C),
            ],
          ),
          // Sin borderRadius (esquinas en ángulo recto)
          // Sin borde
        ),
      // Sin contenido
    ),
  );
}
```

### Características Técnicas
- **Tipo**: `Positioned` con `Container`
- **Decoración**: Solo color de fondo
- **Responsive**: Se adapta al tamaño de columnas y filas
- **Sin interacción**: No tiene `InkWell` ni `GestureDetector`

## Historial de Cambios

### T9 - Implementación inicial
- **Fecha**: Diciembre 2024
- **Cambios**:
  - Fondo cambiado a `AppColorScheme.color2`
  - Eliminado contenido de prueba
  - Eliminado borde y borderRadius
  - Simplificado a contenedor básico

### Diciembre 2025 - Actualización a Estilo Base
- **Cambios**:
  - Añadido borde blanco de 2px (mismo que W1)
  - Alineado con el Estilo Base de la aplicación

## Consideraciones de UX

### Propósito Futuro
- **Información de la app**: Versión, copyright, enlaces legales
- **Estado de la aplicación**: Conectividad, sincronización
- **Enlaces útiles**: Ayuda, soporte, configuración

### Diseño
- **Consistencia**: Sigue el esquema de colores de la app
- **Minimalismo**: Diseño limpio sin distracciones
- **Preparado para contenido**: Estructura lista para futuras implementaciones

## Estado Actual
- ✅ **Implementado**: Widget básico con colores correctos
- ✅ **Documentado**: Especificaciones completas
- ⏳ **Pendiente**: Contenido específico (futuro)
- ⏳ **Pendiente**: Funcionalidades específicas (futuro)

## Notas de Desarrollo
- El widget está preparado para recibir contenido futuro
- Mantiene consistencia visual con el resto del dashboard
- Sigue las especificaciones de la T9

**Implementación actual:** `lib/pages/pg_dashboard_page.dart`, método `_buildW30`. **Última actualización:** Febrero 2026
