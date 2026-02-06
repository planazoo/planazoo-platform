# ℹ️ W14 - Acceso a Información del Plan

## 📋 Descripción General

El widget **W14** es el botón de acceso a la información del plan seleccionado en la interfaz de usuario de Planazoo. Permite al usuario ver los detalles completos del plan en la pantalla principal (W31) mediante un diseño visual claro con icono y texto.

## 📍 Ubicación y Dimensiones

- **Posición en el Grid**: C6 (Columna 6), R2 (Fila 2)
- **Dimensiones**: 1 columna de ancho, 1 fila de alto
- **Coordenadas**:
  - `w14X = columnWidth * 5` (Empieza en la columna C6, índice 5)
  - `w14Y = rowHeight` (Empieza en la fila R2, índice 1)
  - `w14Width = columnWidth` (Ancho de 1 columna)
  - `w14Height = rowHeight` (Alto de 1 fila)

## 🎨 Diseño Visual (v1.1)

### Estados Visuales:
- **No Seleccionado**: 
  - Fondo: Color0 (`AppColorScheme.color0`)
  - Borde: Color2 de 2px
  - Icono: Color2
  - Texto: Color1
- **Seleccionado**:
  - Fondo: Color2 (`AppColorScheme.color2`)
  - Borde: Color2 de 2px
  - Icono: Color2
  - Texto: Color1

### Elementos:
- **Icono**: `Icons.info` color2, tamaño 20px
- **Texto**: "planazoo" debajo del icono, fuente 6px, color1
- **Forma**: Rectangular con esquinas redondeadas (4px)
- **Espaciado**: 4px entre icono y texto

## 🎯 Funcionalidad

### Interacción:
- **Click**: Al hacer clic, selecciona W14 y cambia la pantalla a 'planData'
- **Navegación**: Muestra la información completa del plan en W31
- **Estado**: Mantiene el estado de selección visual

### Integración:
- **W31**: Muestra `PlanDataScreen` con detalles del plan
- **W28**: Requiere que haya un plan seleccionado para funcionar
- **Sistema de selección**: Integrado con `selectedWidgetId`

## 🔧 Implementación Técnica

El widget `_buildW14` se implementa en `lib/pages/pg_dashboard_page.dart`:

```dart
Widget _buildW14(double columnWidth, double rowHeight) {
  // W14: C6 (R2) - Acceso info planazoo
  final w14X = columnWidth * 5; // Empieza en la columna C6 (índice 5)
  final w14Y = rowHeight; // Empieza en la fila R2 (índice 1)
  final w14Width = columnWidth; // Ancho de 1 columna (C6)
  final w14Height = rowHeight; // Alto de 1 fila (R2)
  
  // Determinar colores según el estado de selección
  final isSelected = selectedWidgetId == 'W14';
  final backgroundColor = isSelected ? AppColorScheme.color2 : AppColorScheme.color0;
  final iconColor = AppColorScheme.color2;
  final textColor = isSelected ? AppColorScheme.color1 : AppColorScheme.color1;
  
  return Positioned(
    left: w14X,
    top: w14Y,
    child: Container(
      width: w14Width,
      height: w14Height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: AppColorScheme.color2, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: () {
          _selectWidget('W14');
          _changeScreen('planData');
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono "i" color2
              Icon(
                Icons.info,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(height: 4),
              // Texto "planazoo" debajo del icono
              Text(
                'planazoo',
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
- **v1.1**: Actualización según T5 - Cambio de colores (color0/color2), añadido icono "i" color2 y texto "planazoo".

## 🎨 Consideraciones de UX

### Visual:
- **Claridad**: El icono "i" indica claramente que es información
- **Consistencia**: Mantiene la paleta de colores de la aplicación
- **Estados**: Diferencia visual clara entre seleccionado y no seleccionado
- **Legibilidad**: Texto pequeño pero legible para el contexto

### Interacción:
- **Feedback**: Cambio visual inmediato al hacer clic
- **Navegación**: Acceso directo a la información del plan
- **Contexto**: Solo funciona cuando hay un plan seleccionado

### Técnico:
- **Responsive**: Se adapta al tamaño de las columnas del grid
- **Performance**: Widget simple con interacción directa
- **Integración**: Funciona con el sistema de selección de widgets existente

## 🚀 Funcionalidades Futuras Consideradas

- **Indicador de estado**: Mostrar si el plan tiene información pendiente
- **Contador**: Número de eventos o participantes del plan
- **Acceso rápido**: Atajos de teclado para acceder a la información
- **Notificaciones**: Alertas visuales si hay cambios en el plan

**Implementación actual:** `lib/pages/pg_dashboard_page.dart`, método `_buildW14`. **Última actualización:** Febrero 2026
