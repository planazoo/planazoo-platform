# W28 - Lista de planes

## Descripción
Widget que muestra la lista de planes disponibles. Cada plan se muestra con su imagen, información detallada y estado de selección. Los usuarios pueden seleccionar planes para ver sus detalles y calendario.

## Ubicación en el Grid
- **Posición**: C2-C5, R5-R12
- **Dimensiones**: 4 columnas de ancho × 8 filas de alto
- **Área**: Área principal de la lista de planes

## Diseño Visual

### Colores
- **Contenedor W28**:
  - Fondo: `AppColorScheme.color0` (blanco)
  - Bordes: `AppColorScheme.color0` (blancos, prácticamente invisibles)
- **Plan no seleccionado**: 
  - Fondo: `AppColorScheme.color0`
  - Texto: `AppColorScheme.color2`
- **Plan seleccionado**:
  - Fondo: `AppColorScheme.color1`
  - Texto: `AppColorScheme.color2`

### Estructura de cada Plan
- **Izquierda**: Icono/imagen del plan (40x40px)
- **Centro**: Información del plan en doble línea
  - Nombre del plan (fuente 12px, negrita)
  - Fechas del plan (fuente 10px)
  - Duración en días (fuente 10px)
  - Participantes (fuente 8px, pequeña)
- **Derecha**: Sin iconos (según especificación)

## Funcionalidad

### Selección de Planes
- **Clic en plan**: Selecciona el plan y actualiza W5, W6, W31
- **Estado visual**: El plan seleccionado se destaca con fondo color1
- **Navegación**: Al seleccionar, se activa el calendario por defecto

### Información Mostrada
- **Imagen del plan**: Circular, con fallback a icono por defecto
- **Nombre**: Hasta 2 líneas con ellipsis si es muy largo
- **Fechas**: Formato DD/MM/YYYY - DD/MM/YYYY
- **Duración**: Número de días del plan
- **Participantes**: Placeholder por ahora (se implementará en T20)

## Implementación Técnica

### Widget Principal
```dart
Widget _buildW28(double columnWidth, double rowHeight) {
  // W28: C2-C5 (R5-R12) - Lista de planazoos con imagen, información e iconos
  final w28X = columnWidth; // Empieza en la columna C2 (índice 1)
  final w28Y = rowHeight * 4; // Empieza en la fila R5 (índice 4)
  final w28Width = columnWidth * 4; // Ancho de 4 columnas (C2-C5)
  final w28Height = rowHeight * 8; // Alto de 8 filas (R5-R12)
  
  return Positioned(
    left: w28X,
    top: w28Y,
    child: Container(
      width: w28Width,
      height: w28Height,
      decoration: BoxDecoration(
        color: AppColorScheme.color0, // Fondo blanco
        border: Border.all(color: AppColorScheme.color0, width: 1), // Bordes blancos
        borderRadius: BorderRadius.circular(4),
      ),
      child: PlanListWidget(
        plans: filteredPlanazoos,
        selectedPlanId: selectedPlanId,
        isLoading: isLoading,
        onPlanSelected: _selectPlanazoo,
        onPlanDeleted: _deletePlanazoo,
      ),
    ),
  );
}
```

### PlanCardWidget
```dart
Widget build(BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
    decoration: BoxDecoration(
      color: isSelected ? AppColorScheme.color1 : AppColorScheme.color0,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(
        color: isSelected ? AppColorScheme.color1 : AppColorScheme.color0,
        width: 1,
      ),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            _buildPlanImage(), // Imagen del plan
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del plan (doble línea)
                  Text(plan.name ?? 'Unnamed Plan', ...),
                  // Fechas del plan
                  Text(_formatPlanDates(), ...),
                  // Duración en días
                  Text('${plan.columnCount} días', ...),
                  // Participantes (fuente pequeña)
                  Text(_formatParticipants(), ...),
                ],
              ),
            ),
            // Sin iconos a la derecha
          ],
        ),
      ),
    ),
  );
}
```

### Características Técnicas
- **Tipo**: `Positioned` con `Container` + `PlanListWidget`
- **Lista**: `ListView.builder` para rendimiento
- **Responsive**: Se adapta al tamaño de columnas y filas
- **Estado**: Mantiene el plan seleccionado en `selectedPlanId`
- **Interacción**: `InkWell` para feedback táctil

## Historial de Cambios

### T14 - Actualización según especificaciones
- **Fecha**: Diciembre 2024
- **Cambios**:
  - Actualizado diseño para seguir especificaciones exactas
  - Implementados colores correctos (fondo0/fondo1, texto2)
  - Añadida información de fechas y duración
  - Implementado nombre en doble línea
  - Añadido placeholder para participantes
  - Eliminados iconos a la derecha según especificación
  - Reducido tamaño de imagen para mejor proporción
  - **Actualización de contenedor**: Fondo blanco (color0) y bordes blancos

## Consideraciones de UX

### Experiencia de Usuario
- **Selección clara**: El plan seleccionado se distingue visualmente
- **Información completa**: Muestra todos los datos relevantes del plan
- **Feedback táctil**: `InkWell` proporciona respuesta al tocar
- **Información organizada**: Estructura clara y legible

### Integración
- **Con W5**: Muestra la imagen del plan seleccionado
- **Con W6**: Muestra la información del plan seleccionado
- **Con W31**: Navega al calendario del plan seleccionado
- **Con W13**: Se filtra según la búsqueda

## Estado Actual
- ✅ **Implementado**: Widget funcional con especificaciones correctas
- ✅ **Colores correctos**: Sigue el esquema de colores de la app
- ✅ **Información completa**: Muestra nombre, fechas, duración, participantes
- ✅ **Documentado**: Especificaciones completas
- ⏳ **Pendiente**: Implementación real de participantes (T20)

## Notas de Desarrollo
- El widget está completamente funcional según las especificaciones
- Mantiene consistencia visual con el resto del dashboard
- Sigue las especificaciones de la T14
- Preparado para futuras mejoras de funcionalidad
