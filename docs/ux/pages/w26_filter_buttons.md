# W26 - Filtros de campos

## Descripción
Widget de filtros que permite seleccionar diferentes estados de planes. Incluye cuatro botones de filtro para categorizar los planes según su estado: "Todos", "Estoy in", "Pendientes" y "Cerrados". Actualmente sin funcionalidad de filtrado, solo visual.

## Ubicación en el Grid
- **Posición**: C2-C5, R3
- **Dimensiones**: 4 columnas de ancho × 1 fila de alto
- **Área**: Fila de filtros debajo del buscador W13

## Diseño Visual

### Colores
- **Fondo del contenedor**: `AppColorScheme.color0` (color base)
- **Botón no seleccionado**: 
  - Fondo: `AppColorScheme.color0`
  - Borde: `AppColorScheme.color2`
  - Texto: `AppColorScheme.color1`
- **Botón seleccionado**:
  - Fondo: `AppColorScheme.color2`
  - Borde: `AppColorScheme.color2`
  - Texto: `AppColorScheme.color1` (negrita)

### Estilo de Botones
- **Bordes redondeados**: `BorderRadius.circular(4)`
- **Espaciado**: 2px entre botones
- **Padding interno**: 4px en el contenedor
- **Tamaño de fuente**: 8px
- **Altura**: Altura de fila menos 8px de padding

## Funcionalidad

### Botones de Filtro
1. **"Todos"** - Filtro por defecto, muestra todos los planes
2. **"Estoy in"** - Filtro para planes en los que el usuario participa
3. **"Pendientes"** - Filtro para planes pendientes de confirmación
4. **"Cerrados"** - Filtro para planes cerrados o finalizados

### Estado de Selección
- **Estado inicial**: "Todos" seleccionado por defecto
- **Cambio de estado**: Al hacer clic, se actualiza `selectedFilter`
- **Funcionalidad actual**: Solo visual, sin filtrado real implementado

## Implementación Técnica

### Widget Principal
```dart
Widget _buildW26(double columnWidth, double rowHeight) {
  // W26: C2-C5 (R3) - Filtros fijos de la lista de planazoos
  final w26X = columnWidth; // Empieza en la columna C2 (índice 1)
  final w26Y = rowHeight * 2; // Empieza en la fila R3 (índice 2)
  final w26Width = columnWidth * 4; // Ancho de 4 columnas (C2-C5)
  final w26Height = rowHeight; // Alto de 1 fila (R3)
  
  return Positioned(
    left: w26X,
    top: w26Y,
    child: Container(
      width: w26Width,
      height: w26Height,
      decoration: BoxDecoration(
        color: AppColorScheme.color0, // Fondo color0
        // Sin borde adicional
        // Sin borderRadius (esquinas en ángulo recto)
      ),
      padding: const EdgeInsets.all(4), // Padding para los botones
      child: Row(
        children: [
          _buildFilterButton('todos', 'Todos', columnWidth),
          const SizedBox(width: 2),
          _buildFilterButton('estoy_in', 'Estoy in', columnWidth),
          const SizedBox(width: 2),
          _buildFilterButton('pendientes', 'Pendientes', columnWidth),
          const SizedBox(width: 2),
          _buildFilterButton('cerrados', 'Cerrados', columnWidth),
        ],
      ),
    ),
  );
}
```

### Botón de Filtro
```dart
Widget _buildFilterButton(String filterValue, String label, double columnWidth) {
  final isSelected = selectedFilter == filterValue;
  
  return Expanded(
    child: Container(
      height: rowHeight - 8, // Altura del botón
      decoration: BoxDecoration(
        color: isSelected ? AppColorScheme.color2 : AppColorScheme.color0,
        border: Border.all(
          color: AppColorScheme.color2, // Borde color2
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4), // Bordes redondeados
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedFilter = filterValue;
          });
          // De momento no hacen nada (sin funcionalidad)
        },
        borderRadius: BorderRadius.circular(4),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: AppColorScheme.color1, // Texto color1
              fontSize: 8,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
```

### Estado de la Aplicación
```dart
String selectedFilter = 'todos'; // 'todos', 'estoy_in', 'pendientes', 'cerrados'
```

### Características Técnicas
- **Tipo**: `Positioned` con `Container` + `Row` de botones
- **Responsive**: Los botones se adaptan al ancho disponible
- **Estado**: Mantiene el filtro seleccionado en `selectedFilter`
- **Interacción**: `InkWell` para feedback táctil

## Historial de Cambios

### T12 - Implementación inicial
- **Fecha**: Diciembre 2024
- **Cambios**:
  - Implementados cuatro botones de filtro
  - Aplicados colores según especificaciones
  - Añadido estado de selección
  - Eliminado contenido de prueba
  - Añadido padding y espaciado adecuado

## Consideraciones de UX

### Experiencia de Usuario
- **Selección clara**: El botón seleccionado se distingue visualmente
- **Feedback táctil**: `InkWell` proporciona respuesta al tocar
- **Distribución uniforme**: Los botones ocupan el espacio disponible equitativamente
- **Texto legible**: Tamaño de fuente apropiado para el espacio disponible

### Preparación para Funcionalidad
- **Estado listo**: Variable `selectedFilter` preparada para filtrado
- **Estructura flexible**: Fácil añadir lógica de filtrado real
- **Integración futura**: Preparado para conectar con W28 (lista de planes)

## Estado Actual
- ✅ **Implementado**: Widget funcional con cuatro botones
- ✅ **Colores correctos**: Sigue el esquema de colores de la app
- ✅ **Estado de selección**: Funcional y visual
- ✅ **Documentado**: Especificaciones completas
- ⏳ **Pendiente**: Funcionalidad de filtrado real (futuro)

## Notas de Desarrollo
- El widget está preparado para recibir funcionalidad de filtrado
- Mantiene consistencia visual con el resto del dashboard
- Sigue las especificaciones de la T12
- La estructura permite fácil implementación de filtrado real en el futuro

**Implementación actual:** `lib/pages/pg_dashboard_page.dart`, método `_buildW26`. **Última actualización:** Febrero 2026
