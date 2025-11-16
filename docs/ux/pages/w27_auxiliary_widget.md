# W27 - Auxiliar

## Descripción
Interruptor de vista que permite alternar la lista de planes (W28) entre modo lista y modo calendario. Se ubica entre los filtros (W26) y el contenedor principal de planes (W28).

## Ubicación en el Grid
- **Posición**: C2-C5, R4
- **Dimensiones**: 4 columnas de ancho × 1 fila de alto
- **Área**: Fila auxiliar entre filtros y lista de planes

## Diseño Visual

### Colores
- **Fondo**: `AppColorScheme.color0` (color base)
- **Toggle**: Pastilla blanca con borde `AppColorScheme.color2` al 30 %
- **Iconografía**: `AppColorScheme.color2` cuando está activo, gris medio cuando está inactivo

### Contenido
- **Componente**: `ToggleButtons` con dos opciones (`Lista`, `Calendario`)
- **Tipografía**: `AppTypography.bodyStyle`, 12 px, semibold
- **Distribución**: Alineado a la derecha con padding horizontal de 20 px

## Funcionalidad
- **Acción**: Cambiar la variable `_isCalendarView`
- **Estados**: 
  - `Lista` (valor por defecto) → W28 muestra tarjetas
  - `Calendario` → W28 muestra el nuevo calendario bimestral
- **Comportamiento adicional**:
  - Al entrar en modo calendario, W28 centra el scroll en el mes actual.
  - Al volver a modo lista se conserva el plan seleccionado previamente.
- **Feedback**: Cambio de color en icono y texto al estado seleccionado

## Implementación Técnica

### Widget Principal
```dart
Widget _buildW27(double columnWidth, double rowHeight) {
  // W27: C2-C5 (R4) - Auxiliar
  final w27X = columnWidth; // Empieza en la columna C2 (índice 1)
  final w27Y = rowHeight * 3; // Empieza en la fila R4 (índice 3)
  final w27Width = columnWidth * 4; // Ancho de 4 columnas (C2-C5)
  final w27Height = rowHeight; // Alto de 1 fila (R4)
  final loc = AppLocalizations.of(context)!;
  
  return Positioned(
    left: w27X,
    top: w27Y,
    child: Container(
      width: w27Width,
      height: w27Height,
      decoration: BoxDecoration(
        color: AppColorScheme.color0, // Fondo color0
        // Sin borde
        // Sin borderRadius (esquinas en ángulo recto)
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerRight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColorScheme.color2.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ToggleButtons(
          isSelected: [
            !_isCalendarView,
            _isCalendarView,
          ],
          onPressed: (index) {
            setState(() {
              _isCalendarView = index == 1;
            });
          },
          borderRadius: BorderRadius.circular(24),
          renderBorder: false,
          constraints: const BoxConstraints(minHeight: 36, minWidth: 48),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.view_list_outlined,
                    color: !_isCalendarView ? AppColorScheme.color2 : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    loc.planViewModeList,
                    style: AppTypography.bodyStyle.copyWith(
                      fontSize: 12,
                      color: !_isCalendarView ? AppColorScheme.color2 : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    color: _isCalendarView ? AppColorScheme.color2 : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    loc.planViewModeCalendar,
                    style: AppTypography.bodyStyle.copyWith(
                      fontSize: 12,
                      color: _isCalendarView ? AppColorScheme.color2 : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
```

### Características Técnicas
- **Tipo**: `Positioned` con `Container` y `ToggleButtons`
- **Decoración**: Pastilla blanca con borde suave
- **Responsive**: Ocupa toda la fila reservada; los botones se adaptan al ancho
- **Interacción**: Gestionada con `setState` (cambio inmediato de `_isCalendarView`)

## Historial de Cambios

### v2.0 - Selector lista/calendario (enero 2025)
- Se reemplaza el espacio vacío por el toggle de vistas
- Se internacionalizan las etiquetas (`Lista`, `Calendario`)
- Se alinea el componente a la derecha para evitar interferir con filtros

### T13 - Implementación inicial
- **Fecha**: Diciembre 2024
- **Cambios**:
  - Fondo cambiado a `AppColorScheme.color0`
  - Eliminado contenido de prueba y decoraciones
  - Eliminado borde y borderRadius
  - Simplificado a contenedor básico

## Consideraciones de UX

### Propósito Futuro
- **Funcionalidades adicionales**: Botones, controles, información
- **Espaciador visual**: Separación entre secciones
- **Área de reserva**: Para futuras implementaciones

### Diseño
- **Consistencia**: Sigue el esquema de colores de la app
- **Minimalismo**: Diseño limpio sin distracciones
- **Preparado para contenido**: Estructura lista para futuras implementaciones

## Estado Actual
- ✅ **Implementado**: Toggle funcional lista ↔ calendario
- ✅ **Documentado**: Especificaciones y estilo actualizados
- ⏳ **Pendiente**: Animaciones adicionales (si fueran necesarias)
- ⏳ **Pendiente**: Estadísticas visuales complementarias (futuro)

## Notas de Desarrollo
- Mantener sincronía con nuevas vistas posibles en W28 (p.ej. timeline)
- Evaluar accesos rápidos (shortcuts) si se añaden más modos
- Verificar contraste del estado activo al actualizar el esquema de colores
