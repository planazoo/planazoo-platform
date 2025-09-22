# 📅 W15 - Acceso al Calendario

## 📋 Descripción General

El widget **W15** es el botón de acceso al calendario en la interfaz de usuario de Planazoo. Permite al usuario ver el calendario principal con todos los eventos del plan seleccionado en la pantalla principal (W31) mediante un diseño visual claro con icono y texto.

## 📍 Ubicación y Dimensiones

- **Posición en el Grid**: C7 (Columna 7), R2 (Fila 2)
- **Dimensiones**: 1 columna de ancho, 1 fila de alto
- **Coordenadas**:
  - `w15X = columnWidth * 6` (Empieza en la columna C7, índice 6)
  - `w15Y = rowHeight` (Empieza en la fila R2, índice 1)
  - `w15Width = columnWidth` (Ancho de 1 columna)
  - `w15Height = rowHeight` (Alto de 1 fila)

## 🎨 Diseño Visual (v1.1)

### Estados Visuales:
- **No Seleccionado**: 
  - Fondo: Color0 (`AppColorScheme.color0`)
  - Sin borde
  - Icono: Color2
  - Texto: Color1
- **Seleccionado**:
  - Fondo: Color1 (`AppColorScheme.color1`)
  - Sin borde
  - Icono: Color2
  - Texto: Color2

### Elementos:
- **Icono**: `Icons.calendar_today` color2, tamaño 20px
- **Texto**: "calendario" debajo del icono, fuente 6px (color1 no seleccionado, color2 seleccionado)
- **Forma**: Rectangular con esquinas en ángulo recto (sin `borderRadius`)
- **Espaciado**: 4px entre icono y texto

## 🎯 Funcionalidad

### Interacción:
- **Click**: Al hacer clic, selecciona W15 y cambia la pantalla a 'calendar'
- **Navegación**: Muestra el calendario principal en W31
- **Estado**: Mantiene el estado de selección visual

### Integración:
- **W31**: Muestra `CalendarScreen` con eventos del plan seleccionado
- **W28**: Requiere que haya un plan seleccionado para mostrar eventos
- **Sistema de selección**: Integrado con `selectedWidgetId`

## 🔧 Implementación Técnica

El widget `_buildW15` se implementa en `lib/pages/pg_dashboard_page.dart`:

```dart
Widget _buildW15(double columnWidth, double rowHeight) {
  // W15: C7 (R2) - Acceso calendario
  final w15X = columnWidth * 6; // Empieza en la columna C7 (índice 6)
  final w15Y = rowHeight; // Empieza en la fila R2 (índice 1)
  final w15Width = columnWidth; // Ancho de 1 columna (C7)
  final w15Height = rowHeight; // Alto de 1 fila (R2)
  
  // Determinar colores según el estado de selección
  final isSelected = selectedWidgetId == 'W15';
  final backgroundColor = isSelected ? AppColorScheme.color2 : AppColorScheme.color0;
  final iconColor = AppColorScheme.color2;
  final textColor = isSelected ? AppColorScheme.color1 : AppColorScheme.color1;
  
  return Positioned(
    left: w15X,
    top: w15Y,
    child: Container(
      width: w15Width,
      height: w15Height,
      decoration: BoxDecoration(
        color: backgroundColor,
        // Sin borde
        // Sin borderRadius (esquinas en ángulo recto)
      ),
      child: InkWell(
        onTap: () {
          _selectWidget('W15');
          _changeScreen('calendar');
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono calendario color2
              Icon(
                Icons.calendar_today,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(height: 4),
              // Texto "calendario" debajo del icono
              Text(
                'calendario',
                style: AppTypography.caption.copyWith(
                  color: textColor,
                  fontSize: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
```

## 📋 Historial de Cambios

- **v1.0**: Implementación inicial con diseño básico y funcionalidad de navegación.
- **v1.1**: Actualización según T6 - Cambio de colores (color0/color2), añadido icono calendario color2 y texto "calendario".

## 🎨 Consideraciones de UX

### Visual:
- **Claridad**: El icono de calendario indica claramente la funcionalidad
- **Consistencia**: Mantiene la paleta de colores de la aplicación
- **Estados**: Diferencia visual clara entre seleccionado y no seleccionado
- **Legibilidad**: Texto pequeño pero legible para el contexto

### Interacción:
- **Feedback**: Cambio visual inmediato al hacer clic
- **Navegación**: Acceso directo al calendario principal
- **Contexto**: Solo funciona cuando hay un plan seleccionado

### Técnico:
- **Responsive**: Se adapta al tamaño de las columnas del grid
- **Performance**: Widget simple con interacción directa
- **Integración**: Funciona con el sistema de selección de widgets existente

## 🚀 Funcionalidades Futuras Consideradas

- **Indicador de eventos**: Mostrar número de eventos pendientes
- **Vista previa**: Miniatura del calendario en el botón
- **Atajos de teclado**: Acceso rápido con teclas de función
- **Notificaciones**: Alertas visuales si hay eventos próximos
