# W28 - Lista de planes

## Descripción
Widget que muestra los planes disponibles en dos modos: listado clásico y vista calendario bimestral. El usuario puede alternar el modo desde W27; ambos permiten seleccionar un plan para abrir sus detalles y el calendario principal.

## Ubicación en el Grid
- **Posición**: C2-C5, R5-R12
- **Dimensiones**: 4 columnas de ancho × 8 filas de alto
- **Área**: Área principal de la lista de planes

## Diseño Visual

### Colores
- **Contenedor W28**: Fondo `AppColorScheme.color0`, borde blanco, esquinas 4 px
- **Modo lista**:
  - Plan no seleccionado: fondo `color0`, texto `color2`
  - Plan seleccionado: fondo `color1`, texto `color2`
- **Modo calendario**:
  - Celda sin planes: fondo blanco, borde gris claro
  - Celda con planes: fondo `color2` al 12 %, borde `color2` 80 %, badge `color2`

### Estructuras
- **Modo lista**:
  - Imagen circular de 40 px
  - Nombre (12 px bold), fechas (10 px), duración y participantes (8–10 px)
  - Selección mediante `InkWell`
- **Modo calendario**:
  - Mes actual aparece al abrir; scroll arriba para meses previos y abajo para los siguientes (ventana: 5 anteriores, mes actual, 6 posteriores)
  - Scroll vertical con inercia (`ListView`)
  - Encabezado `MMMM yyyy` con `AppTypography.mediumTitle`
  - Cabecera de días (L–D) en mayúsculas
  - Celdas cuadradas con contador de planes, tooltip al pasar el ratón y selección táctil

## Funcionalidad

### Selección de Planes
- **Clic en tarjeta (modo lista)**: Selecciona el plan y actualiza W5, W6, W31
- **Tap en día con planes (modo calendario)**:
  - Si hay 1 plan → selección directa
  - Si hay varios → modal con lista de planes para elegir
- **Estado visual (lista)**: Plan seleccionado con fondo color1

### Información Mostrada
- **Modo lista**: Imagen, nombre, fechas, duración (días), participantes activos
- **Modo calendario**:
  - Leyenda visual con badge numérico
  - Tooltip con lista de planes al hover
  - Modal de detalle muestra nombre + rango de fechas
  - Texto “No hay planes en estos meses” cuando no hay datos
  - Scroll que permite revisar meses anteriores y posteriores

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
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _isCalendarView
            ? PlanCalendarView(
                key: const ValueKey('plan-calendar-view'),
                plans: filteredPlanazoos,
                isLoading: isLoading,
                onPlanSelected: (plan) {
                  if (plan.id != null) {
                    _selectPlanazoo(plan.id!);
                  }
                },
              )
            : PlanListWidget(
                key: const ValueKey('plan-list-view'),
                plans: filteredPlanazoos,
                selectedPlanId: selectedPlanId,
                isLoading: isLoading,
                onPlanSelected: _selectPlanazoo,
                onPlanDeleted: _deletePlanazoo,
              ),
      ),
    ),
  );
}
```

### PlanListWidget (modo lista)
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

### PlanCalendarView (modo calendario)
```dart
return Padding(
  padding: const EdgeInsets.all(16),
  child: ListView.builder(
    itemCount: months.length,
    physics: const BouncingScrollPhysics(),
    itemBuilder: (context, index) {
      final month = months[index];
      return Padding(
        padding: EdgeInsets.only(bottom: index == months.length - 1 ? 0 : 20),
        child: _MonthCalendar(
          month: month,
          planDays: planDays,
          onPlanSelected: onPlanSelected,
        ),
      );
    },
  ),
);
```

### Características Técnicas
- **Contenedor**: `Positioned` + `AnimatedSwitcher` para transición entre vistas
- **Modo lista**: `PlanListWidget` (ListView, selección por `InkWell`)
- **Modo calendario**:
  - Lista vertical de meses (`ListView`) con ventana fija (mes actual ± 6), scroll inicial posicionado en el mes vigente
  - Cada mes calcula su altura en función de las semanas
  - Badge numérico con cantidad de planes por día y tooltip con nombres
  - Modal inferior con listado cuando hay múltiples planes
- **Estado**: Controlado por `_isCalendarView` (toggle en W27)
- **Rendimiento**: Se reutilizan los planes filtrados (`filteredPlanazoos`)

## Historial de Cambios

### v2.1 - Calendario vertical desplazable (enero 2025)
- El calendario muestra ventana de 12 meses (scroll vertical) iniciando en el mes actual
- Cada mes ajusta su altura al número de semanas
- Tooltip con listado de planes al pasar el ratón por un día con contenido
- Scroll permite revisar meses previos y futuros sin salir de la vista

### v2.0 - Vista calendario opcional (enero 2025)
- Añadido `AnimatedSwitcher` para alternar lista/calendario
- Creado `PlanCalendarView` con selección de días
- Modal de selección cuando hay varios planes en la misma fecha
- Mensaje vacío cuando no existen planes en el rango mostrado

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
- **Selección clara**: Plan destacado tanto en lista como al elegir desde el calendario
- **Información completa**: Datos esenciales disponibles en ambos modos
- **Calendario visual**: Vista rápida de ocupación mensual
- **Tooltips contextuales**: Nombres de planes disponibles sin abrir el modal
- **Scroll natural**: Revisión de meses anteriores/posteriores con inercia suave
- **Feedback táctil**: `InkWell` en lista y celdas animadas en calendario

### Integración
- **Con W5**: Muestra la imagen del plan seleccionado
- **Con W6**: Actualiza la información del plan seleccionado
- **Con W31**: Abre el calendario principal del plan elegido
- **Con W13/W27**: La lista filtrada se comparte entre ambos modos

## Estado Actual
- ✅ **Implementado**: Lista + calendario conmutables
- ✅ **Colores correctos**: Se mantiene la paleta del dashboard
- ✅ **Información completa**: Nombre, fechas, participantes, ocupación mensual
- ✅ **Documentado**: Especificaciones actualizadas
- ⏳ **Pendiente**: Resumen de participantes en calendario (futuro)

## Notas de Desarrollo
- El widget está completamente funcional según las especificaciones
- Mantiene consistencia visual con el resto del dashboard
- Sigue las especificaciones de la T14
- Preparado para futuras mejoras de funcionalidad
