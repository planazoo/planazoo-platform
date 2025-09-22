# W13 - Buscador de planes

## Descripción
Widget de búsqueda que permite filtrar la lista de planes en tiempo real. Los usuarios pueden introducir palabras clave para buscar planes específicos, y la lista W28 se actualiza automáticamente con los resultados filtrados.

## Ubicación en el Grid
- **Posición**: C2-C5, R2
- **Dimensiones**: 4 columnas de ancho × 1 fila de alto
- **Área**: Fila superior del área de filtros y búsqueda

## Diseño Visual

### Colores
- **Fondo del contenedor**: `AppColorScheme.color0` (color base)
- **Fondo del campo de búsqueda**: `AppColorScheme.color0` (color base)
- **Bordes del campo**: `AppColorScheme.color1` (color de acento)
- **Texto**: `AppColorScheme.color1` (color de acento)
- **Icono**: `AppColorScheme.color1` (color de acento)

### Estilo del Campo de Búsqueda
- **Bordes redondeados**: `BorderRadius.circular(8)`
- **Estados del borde**:
  - Normal: borde color1, grosor 1px
  - Enfocado: borde color1, grosor 2px
- **Padding interno**: 12px horizontal, 8px vertical

## Funcionalidad

### Búsqueda en Tiempo Real
- **Filtrado automático**: Al escribir, la lista W28 se filtra inmediatamente
- **Callback**: `onSearchChanged` conectado a `_filterPlanazoos`
- **Búsqueda por texto**: Busca en nombre y otros campos del plan

### Interacción
- **Campo de texto**: `TextField` con placeholder "Buscar planes..."
- **Icono de búsqueda**: `Icons.search` como prefijo
- **Enter para buscar**: `onSubmitted` para confirmar búsqueda

## Implementación Técnica

### Widget Principal
```dart
Widget _buildW13(double columnWidth, double rowHeight) {
  // W13: C2-C5 (R2) - Campo de búsqueda
  final w13X = columnWidth; // Empieza en la columna C2 (índice 1)
  final w13Y = rowHeight; // Empieza en la fila R2 (índice 1)
  final w13Width = columnWidth * 4; // Ancho de 4 columnas (C2-C5)
  final w13Height = rowHeight; // Alto de 1 fila (R2)
  
  return Positioned(
    left: w13X,
    top: w13Y,
    child: Container(
      width: w13Width,
      height: w13Height,
      decoration: BoxDecoration(
        color: AppColorScheme.color0, // Fondo color0
        // Sin borde adicional (el TextField ya tiene sus propios bordes)
        // Sin borderRadius (el TextField maneja sus propios bordes redondeados)
      ),
      padding: const EdgeInsets.all(8), // Padding para el TextField
      child: PlanSearchWidget(onSearchChanged: _filterPlanazoos),
    ),
  );
}
```

### PlanSearchWidget
```dart
class PlanSearchWidget extends StatelessWidget {
  // ... propiedades ...
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar planes...',
        prefixIcon: Icon(Icons.search, color: AppColorScheme.color1),
        filled: true,
        fillColor: AppColorScheme.color0, // Fondo color0
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColorScheme.color1, width: 1),
          borderRadius: BorderRadius.circular(8), // Bordes redondeados
        ),
        // ... otros estados del borde ...
      ),
      style: TextStyle(color: AppColorScheme.color1),
      onChanged: onSearchChanged,
      onSubmitted: (_) => onSearchPressed?.call(),
    );
  }
}
```

### Características Técnicas
- **Tipo**: `Positioned` con `Container` + `PlanSearchWidget`
- **Responsive**: Se adapta al tamaño de columnas y filas
- **Integración**: Conectado con el sistema de filtrado de planes
- **Estado**: Mantiene el estado de búsqueda en el dashboard

## Historial de Cambios

### T11 - Actualización de colores y estilo
- **Fecha**: Diciembre 2024
- **Cambios**:
  - Fondo del contenedor cambiado a `AppColorScheme.color0`
  - Campo de búsqueda con fondo color0 y bordes color1
  - Bordes redondeados implementados
  - Texto e iconos con color1 para mejor contraste
  - Padding añadido para mejor espaciado
  - Placeholder traducido a español

## Consideraciones de UX

### Experiencia de Usuario
- **Búsqueda intuitiva**: Campo de texto claro con icono de búsqueda
- **Feedback visual**: Bordes que cambian al enfocar
- **Búsqueda rápida**: Filtrado en tiempo real sin necesidad de presionar botones
- **Accesibilidad**: Placeholder descriptivo y colores con buen contraste

### Integración
- **Con W28**: Filtrado directo de la lista de planes
- **Con el sistema**: Integrado con el estado global del dashboard
- **Responsive**: Se adapta a diferentes tamaños de pantalla

## Estado Actual
- ✅ **Implementado**: Widget funcional con búsqueda en tiempo real
- ✅ **Colores actualizados**: Sigue el esquema de colores de la app
- ✅ **Documentado**: Especificaciones completas
- ✅ **Integrado**: Conectado con el sistema de filtrado

## Notas de Desarrollo
- El widget está completamente funcional y integrado
- Mantiene consistencia visual con el resto del dashboard
- Sigue las especificaciones de la T11
- Preparado para futuras mejoras de funcionalidad de búsqueda
