# W29 - Pie de página publicitario

## Descripción
Widget de pie de página dedicado a mostrar informaciones publicitarias. Ubicado en la fila inferior del dashboard, proporciona espacio para contenido promocional o publicitario.

## Ubicación en el Grid
- **Posición**: C2-C5, R13
- **Dimensiones**: 4 columnas de ancho × 1 fila de alto
- **Área**: Parte izquierda de la fila inferior del dashboard

## Diseño Visual

### Colores
- **Fondo**: Gradiente igual que W1/W2 (Estilo Base)
  - `LinearGradient` de `Colors.grey.shade800` → `Color(0xFF2C2C2C)`
- **Borde**: Sin borde
- **Esquinas**: Ángulo recto (sin borderRadius)

### Contenido
- **Estado actual**: Sin contenido visible
- **Propósito**: Reservado para contenido publicitario

## Funcionalidad
- **Interacción**: Ninguna
- **Estado**: Estático
- **Propósito**: Área reservada para publicidad

## Implementación Técnica

### Widget Principal
```dart
Widget _buildW29(double columnWidth, double rowHeight) {
  // W29: C2-C5 (R13) - Pie de página publicitario
  final w29X = columnWidth; // Empieza en la columna C2 (índice 1)
  final w29Y = rowHeight * 12; // Empieza en la fila R13 (índice 12)
  final w29Width = columnWidth * 4; // Ancho de 4 columnas (C2-C5)
  final w29Height = rowHeight; // Alto de 1 fila (R13)
  
  return Positioned(
    left: w29X,
    top: w29Y,
    child: Container(
      width: w29Width,
      height: w29Height,
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
- **Decoración**: Fondo color0 + borde superior color1
- **Responsive**: Se adapta al tamaño de columnas y filas
- **Sin interacción**: No tiene `InkWell` ni `GestureDetector`

## Historial de Cambios

### T10 - Implementación inicial
- **Fecha**: Diciembre 2024
- **Cambios**:
  - Fondo cambiado a `AppColorScheme.color0`
  - Añadido borde superior `AppColorScheme.color1`
  - Eliminado contenido de prueba
  - Eliminado borderRadius
  - Simplificado a contenedor básico

### Diciembre 2025 - Actualización a Estilo Base
- **Cambios**:
  - Fondo cambiado a `AppColorScheme.color2` (mismo que W1)
  - Borde cambiado a blanco de 2px (mismo que W1)
  - Alineado con el Estilo Base de la aplicación

## Consideraciones de UX

### Propósito Futuro
- **Publicidad**: Banners, anuncios, promociones
- **Enlaces externos**: Patrocinadores, partners
- **Contenido promocional**: Ofertas, novedades

### Diseño
- **Consistencia**: Sigue el esquema de colores de la app
- **Separación visual**: Borde superior para distinguir del contenido principal
- **Preparado para contenido**: Estructura lista para futuras implementaciones

## Estado Actual
- ✅ **Implementado**: Widget básico con colores correctos
- ✅ **Documentado**: Especificaciones completas
- ⏳ **Pendiente**: Contenido publicitario específico (futuro)
- ⏳ **Pendiente**: Funcionalidades publicitarias (futuro)

## Notas de Desarrollo
- El widget está preparado para recibir contenido publicitario futuro
- Mantiene consistencia visual con el resto del dashboard
- Sigue las especificaciones de la T10
- El borde superior proporciona separación visual del contenido principal
