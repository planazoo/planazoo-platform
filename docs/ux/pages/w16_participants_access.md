# 👥 W16 - Acceso a Participantes del Plan

## 📋 Descripción General

El widget **W16** es el botón de acceso a la página de participantes del plan seleccionado en la interfaz de usuario de Planazoo. Permite al usuario ver y gestionar los participantes del plan en la pantalla principal (W31) mediante un diseño visual claro con icono y texto.

## 📍 Ubicación y Dimensiones

- **Posición en el Grid**: C8 (Columna 8), R2 (Fila 2)
- **Dimensiones**: 1 columna de ancho, 1 fila de alto
- **Coordenadas**:
  - `w16X = columnWidth * 7` (Empieza en la columna C8, índice 7)
  - `w16Y = rowHeight` (Empieza en la fila R2, índice 1)
  - `w16Width = columnWidth` (Ancho de 1 columna)
  - `w16Height = rowHeight` (Alto de 1 fila)

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
- **Icono**: `Icons.group` color2, tamaño 20px (representa "formas de personas")
- **Texto**: "in" debajo del icono, fuente 6px (color1 no seleccionado, color2 seleccionado)
- **Forma**: Rectangular con esquinas en ángulo recto (sin `borderRadius`)
- **Espaciado**: 4px entre icono y texto

## 🎯 Funcionalidad

### Interacción:
- **Click**: Al hacer clic, selecciona W16 y cambia la pantalla a 'participants'
- **Navegación**: Muestra la página de participantes del plan en W31
- **Estado**: Mantiene el estado de selección visual

### Integración:
- **W31**: Muestra `_buildParticipantsScreen()` con información de participantes
- **W28**: Requiere que haya un plan seleccionado para mostrar participantes
- **Sistema de selección**: Integrado con `selectedWidgetId`

## 🔧 Implementación Técnica

El widget `_buildW16` se implementa en `lib/pages/pg_dashboard_page.dart`:

```dart
Widget _buildW16(double columnWidth, double rowHeight) {
  // W16: C8 (R2) - Participante del plan
  final w16X = columnWidth * 7; // Empieza en la columna C8 (índice 7)
  final w16Y = rowHeight; // Empieza en la fila R2 (índice 1)
  final w16Width = columnWidth; // Ancho de 1 columna (C8)
  final w16Height = rowHeight; // Alto de 1 fila (R2)
  
  // Determinar colores según el estado de selección
  final isSelected = selectedWidgetId == 'W16';
  final backgroundColor = isSelected ? AppColorScheme.color2 : AppColorScheme.color0;
  final iconColor = AppColorScheme.color2;
  final textColor = isSelected ? AppColorScheme.color1 : AppColorScheme.color1;
  
  return Positioned(
    left: w16X,
    top: w16Y,
    child: Container(
      width: w16Width,
      height: w16Height,
      decoration: BoxDecoration(
        color: backgroundColor,
        // Sin borde
        // Sin borderRadius (esquinas en ángulo recto)
      ),
      child: InkWell(
        onTap: () {
          _selectWidget('W16');
          _changeScreen('participants');
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono "formas de personas" color2
              Icon(
                Icons.group,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(height: 4),
              // Texto "in" debajo del icono
              Text(
                'in',
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

### Pantalla de Participantes:

El método `_buildParticipantsScreen()` se implementa en el mismo archivo:

```dart
Widget _buildParticipantsScreen() {
  if (selectedPlan == null) {
    return const Center(
      child: Text(
        'Selecciona un plan para ver los participantes',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Participantes del Plan: ${selectedPlan!.name}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          'Funcionalidad en desarrollo',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            setState(() {
              currentScreen = 'calendar';
            });
          },
          child: const Text('Volver al Calendario'),
        ),
      ],
    ),
  );
}
```

## 📋 Historial de Cambios

- **v1.0**: Implementación inicial como "Por definir" con colores amarillos.
- **v1.1**: Actualización según T7 - Cambio de colores (color0/color2), añadido icono "formas de personas" color2, texto "in", y implementación de pantalla de participantes.

## 🎨 Consideraciones de UX

### Visual:
- **Claridad**: El icono de grupo indica claramente la funcionalidad de participantes
- **Consistencia**: Mantiene la paleta de colores de la aplicación
- **Estados**: Diferencia visual clara entre seleccionado y no seleccionado
- **Legibilidad**: Texto pequeño pero legible para el contexto

### Interacción:
- **Feedback**: Cambio visual inmediato al hacer clic
- **Navegación**: Acceso directo a la página de participantes
- **Contexto**: Solo funciona cuando hay un plan seleccionado

### Técnico:
- **Responsive**: Se adapta al tamaño de las columnas del grid
- **Performance**: Widget simple con interacción directa
- **Integración**: Funciona con el sistema de selección de widgets existente

## 🚀 Funcionalidades Futuras Consideradas

- **Lista de participantes**: Mostrar todos los participantes del plan
- **Gestión de participantes**: Añadir/eliminar participantes
- **Roles de participantes**: Diferentes tipos de participantes (organizador, participante, etc.)
- **Información de contacto**: Datos de contacto de los participantes
- **Estados de participación**: Confirmado, pendiente, rechazado
- **Notificaciones**: Alertas cuando se añaden nuevos participantes

**Implementación actual:** `lib/pages/pg_dashboard_page.dart`, método `_buildW16`. **Última actualización:** Febrero 2026
