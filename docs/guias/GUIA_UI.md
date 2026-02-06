# 🎨 Guía de Interfaz de Usuario (UI)

> Define todos los parámetros, componentes y patrones de diseño para mantener consistencia visual en toda la aplicación

**Relacionado con:** T91, T92  
**Versión:** 1.0  
**Fecha:** Enero 2025

**⚠️ Tema por defecto:** La aplicación Planazoo utiliza por defecto el **Estilo Base** (UI oscura). Ver [Estilo Base](../ux/estilos/ESTILO_SOFISTICADO.md). Esta guía documenta además la paleta y componentes de referencia (AppColorScheme, etc.).

---

## 🎯 Objetivo

Establecer un sistema de diseño consistente que:
- Mantenga coherencia visual en toda la app
- Permita cambios globales de forma fácil
- Proporcione componentes reutilizables
- Facilite el desarrollo sin experiencia de UI

---

## 🎨 SISTEMA DE COLORES

### Colores Actuales de la App (AppColorScheme)

**⚠️ IMPORTANTE: Estos son los colores que ya existen en `lib/app/theme/color_scheme.dart`**

```dart
// Sistema de colores personalizado existente
class AppColorScheme {
  // Colores principales según la propuesta original del usuario
  static const Color color0 = Color(0xFFFFFFFF);     // Fondo principal (blanco)
  static const Color color1 = Color(0xFFBCE1E7);     // Fondos secundarios (verde azulado claro)
  static const Color color2 = Color(0xFF79A2A8);      // Elementos interactivos (verde azulado)
  static const Color color3 = Color(0xFFA24000);     // Botones de acción (naranja oscuro)
  static const Color color4 = Color(0xFF4F606A);     // Texto y bordes (gris azulado oscuro)
  
  // Colores adicionales para tipografías
  static const Color titleColor = Color(0xFF00796B);      // Títulos (verde oscuro)
  static const Color bodyColor = Color(0xFF424242);       // Cuerpo de texto (gris oscuro)
  static const Color interactiveColor = Color(0xFF1976D2); // Texto interactivo (azul)
  
  // Colores para estados
  static const Color hoverColor = Color(0xFF5D8A90);       // Hover (verde azulado medio)
  static const Color activeColor = Color(0xFF8B5A00);      // Activo (naranja oscuro)
  static const Color disabledColor = Color(0xFFB0BEC5);    // Deshabilitado (gris)
  
  // Colores para la UX Demo Page
  static const Color gridLineColor = Color(0xFFE0E0E0);
  static const Color widgetBackgroundColor = Color(0xFFF5F5F5);
  static const Color widgetBorderColor = Color(0xFFBDBDBD);
}
```

### Reglas de Uso

- **color0 (Blanco)**: Fondo principal, tarjetas, superficies limpias
- **color1 (Verde Azulado Claro)**: Fondos secundarios, barras de navegación
- **color2 (Verde Azulado)**: Elementos interactivos, botones principales, AppBar
- **color3 (Naranja Oscuro)**: Botones de acción, CTAs importantes, alertas
- **color4 (Gris Azulado Oscuro)**: Texto principal, bordes, elementos estructurales
- **titleColor (Verde Oscuro)**: Títulos de secciones, headers
- **bodyColor (Gris Oscuro)**: Texto de cuerpo, descripciones
- **interactiveColor (Azul)**: Enlaces, texto interactivo

---

## 📐 TIPOGRAFÍA

### Tipografías Actuales de la App (AppTypography)

**⚠️ IMPORTANTE: Estos son los estilos que ya existen en `lib/app/theme/typography.dart`**

```dart
class AppTypography {
  // Tipografía: Noto Sans (igual que Google Calendar)
  // Usando Google Fonts para cargar Noto Sans
  
  // Estilos de títulos (usando Google Fonts)
  static TextStyle get titleStyle => GoogleFonts.notoSans(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColorScheme.titleColor,
  );
  
  static TextStyle get largeTitle => GoogleFonts.notoSans(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: AppColorScheme.titleColor,
  );
  
  static TextStyle get mediumTitle => GoogleFonts.notoSans(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: AppColorScheme.titleColor,
  );
  
  // Estilos de cuerpo
  static TextStyle get bodyStyle => GoogleFonts.notoSans(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppColorScheme.bodyColor,
  );
  
  static TextStyle get smallBody => GoogleFonts.notoSans(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColorScheme.bodyColor,
  );
  
  // Estilos de texto interactivo
  static TextStyle get interactiveStyle => GoogleFonts.notoSans(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColorScheme.interactiveColor,
  );
  
  // Caption (texto pequeño)
  static TextStyle get caption => GoogleFonts.notoSans(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColorScheme.color4,
  );
}
```

### Reglas de Uso

- **largeTitle (32px, bold)**: Títulos principales de página (Dashboard, Plan)
- **titleStyle (24px, bold)**: Secciones principales
- **mediumTitle (20px, bold)**: Subtítulos de secciones
- **bodyStyle (16px)**: Texto general, descripciones
- **smallBody (14px)**: Texto secundario
- **interactiveStyle (14px, medium)**: Enlaces, CTAs
- **caption (12px)**: Texto secundario, fechas pequeñas

---

## 📦 ESPACIADO Y LAYOUT

### Estado Actual

⚠️ **NO IMPLEMENTADO** - El sistema de espaciado estándar no existe todavía en el código.

### Sistema de Espaciado (Por Implementar)

```dart
class AppSpacing {
  static const double xs = 4.0;    // Elementos muy cercanos
  static const double sm = 8.0;     // Elementos relacionados
  static const double md = 16.0;   // Espaciado estándar
  static const double lg = 24.0;   // Separación de secciones
  static const double xl = 32.0;   // Separación mayor
  static const double xxl = 48.0;  // Separación de página
}
```

### Breakpoints Responsivos (Por Implementar)

```dart
class AppBreakpoints {
  static const double mobile = 600;      // Móvil
  static const double tablet = 960;       // Tablet
  static const double desktop = 1280;    // Desktop
  static const double large = 1920;      // Pantalla grande
}
```

### Reglas de Uso (Futuras)

- Usar `AppSpacing` para padding y margins consistentes (cuando se implemente)
- Evitar valores hardcodeados (no `SizedBox(height: 20)` → usar `SizedBox(height: AppSpacing.md)`)
- Layout responsive usando `LayoutBuilder` y breakpoints

**Nota**: Por ahora, usar valores de espaciado hardcodeados hasta que se implemente el sistema.

---

## 🔘 COMPONENTES REUTILIZABLES

### Estado Actual

✅ **USAR WIDGETS DE MATERIAL DESIGN** - No es necesario crear wrappers. Flutter ya proporciona todos los componentes necesarios.

### Guía de Uso

#### Botones
```dart
// Usar los botones estándar de Material
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColorScheme.color3,
    foregroundColor: AppColorScheme.color0,
  ),
  child: Text('Guardar'),
)

TextButton(
  onPressed: () {},
  child: Text('Cancelar'),
)

IconButton(
  onPressed: () {},
  icon: Icon(Icons.add),
)
```

#### Tarjetas y Contenedores
```dart
// Usar Card de Material
Card(
  elevation: 2,
  child: ListTile(
    title: Text('Título'),
    subtitle: Text('Subtítulo'),
  ),
)

// Usar Container con AppColorScheme
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColorScheme.color1,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text('Contenido'),
)
```

#### Inputs y Formularios
```dart
// Usar TextField de Material
TextField(
  decoration: InputDecoration(
    labelText: 'Nombre',
    hintText: 'Ingresa tu nombre',
    border: OutlineInputBorder(),
  ),
)

// Checkbox y Switch
Checkbox(
  value: checked,
  onChanged: (value) {},
)

Switch(
  value: enabled,
  onChanged: (value) {},
)
```

### Recomendación

✅ **Usar Material Design directamente** + `AppColorScheme` + `AppTypography` para mantener consistencia.

⚠️ **NO crear wrappers innecesarios** que solo añaden complejidad sin valor.

---

## 🎭 ICONOS

### Estado Actual

✅ **USAR MATERIAL ICONS DIRECTAMENTE** - No es necesario crear wrappers de iconos.

### Guía de Uso

```dart
// Usar Material Icons directamente con tamaños estándar
Icon(Icons.home, size: 24)
Icon(Icons.calendar_today, size: 24)
Icon(Icons.add_circle_outline, size: 32)

// Iconos comunes del proyecto
Icons.event           // Eventos
Icons.flight         // Vuelos
Icons.hotel          // Alojamientos
Icons.restaurant     // Restaurantes
Icons.person         // Usuarios
Icons.people         // Participantes
Icons.add_circle     // Crear
Icons.edit           // Editar
Icons.delete         // Eliminar
```

### Recomendación

✅ **Usar `Icons.*` de Material Icons** + `size` consistente (16, 24, 32, 48) + `AppColorScheme` para color.

⚠️ **NO crear `AppIcon` wrapper** a menos que realmente sea necesario para tu caso específico.

---

## 📐 SISTEMA DE GRID 17×13

### Descripción del Grid

La aplicación usa un **sistema de grid fijo** de **17 columnas × 13 filas** para el layout del dashboard principal. Este sistema proporciona:
- **Posicionamiento preciso** de widgets
- **Layout consistente** en todas las pantallas
- **Fácil cálculo** de posiciones y tamaños
- **Base sólida** para responsive design

### Arquitectura del Grid

```
Grid: 17 columnas (C1-C17) × 13 filas (R1-R13) = 221 celdas

Columnas: C1, C2, C3, ..., C17
Filas:    R1, R2, R3, ..., R13
```

### Implementación Técnica

#### Cálculo de Dimensiones

```dart
// En cualquier widget que use el grid:
LayoutBuilder(
  builder: (context, constraints) {
    final gridWidth = constraints.maxWidth;
    final gridHeight = constraints.maxHeight;
    final columnWidth = gridWidth / 17;
    final rowHeight = gridHeight / 13;
    
    return Container(
      child: Stack(
        children: [
          // Grid de fondo (debugging)
          CustomPaint(
            painter: GridPainter(
              cellWidth: columnWidth,
              cellHeight: rowHeight,
              daysPerWeek: 17,
            ),
          ),
          // Widgets posicionados según grid
          _buildWidgets(columnWidth, rowHeight),
        ],
      ),
    );
  },
)
```

#### Posicionamiento de Widgets

```dart
// Ejemplo: Widget en C2-C5, R3-R5
Widget _buildExample(double columnWidth, double rowHeight) {
  // Posición X: empieza en columna 2 (índice 1)
  final x = columnWidth * 1;
  
  // Posición Y: empieza en fila 3 (índice 2)
  final y = rowHeight * 2;
  
  // Ancho: 4 columnas (C2-C5)
  final width = columnWidth * 4;
  
  // Alto: 3 filas (R3-R5)
  final height = rowHeight * 3;
  
  return Positioned(
    left: x,
    top: y,
    child: Container(
      width: width,
      height: height,
      // Contenido del widget
    ),
  );
}
```

#### CustomPainter para Visualizar el Grid (Debugging)

```dart
class GridPainter extends CustomPainter {
  final double cellWidth;
  final double cellHeight;
  final int daysPerWeek;

  const GridPainter({
    required this.cellWidth,
    required this.cellHeight,
    required this.daysPerWeek,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    // Líneas verticales (17 columnas)
    for (int i = 0; i <= 17; i++) {
      final x = cellWidth * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Líneas horizontales (13 filas)
    for (int i = 0; i <= 13; i++) {
      final y = cellHeight * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

### Distribución del Grid en el Dashboard

```
    C1   C2   C3   C4   C5   C6   C7   C8   C9   C10  C11  C12  C13  C14  C15  C16  C17
R1  ┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┐
    │ W1  │ W2  │     │ W3  │ W4  │ W5  │ W6  │     │     │     │     │ W7  │ W8  │ W9  │ W10 │ W11 │ W12 │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R2  ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │ W13 │     │     │     │ W14 │ W15 │ W16 │ W17 │ W18 │ W19 │ W20 │ W21 │ W22 │ W23 │ W24 │ W25 │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R3  ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │ W26 │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R4  ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │ W27 │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R5  ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │ W28 │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R6  ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R7  ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R8  ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R9  ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R10 ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R11 ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R12 ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R13 └─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┘
    │ W29 │     │     │     │ W30 │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
```

### Leyenda de Widgets

#### **Header Superior (R1)** - C2-C17
- **W1**: Barra lateral con perfil (C1, R1-R13) - AppColorScheme.color2
- **W2**: Logo de la app (C2-C3, R1) 
- **W3**: Botón nuevo plan (C4, R1)
- **W4**: Espacio reservado (C5, R1)
- **W5**: Imagen del plan seleccionado (C6, R1)
- **W6**: Información del plan (C7-C11, R1)
- **W7**: Info (C12, R1)
- **W8**: Presupuesto (C13, R1)
- **W9**: Contador participantes (C14, R1)
- **W10**: Mi estado (C15, R1)
- **W11**: Libre (C16, R1)
- **W12**: Menú opciones (C17, R1)

#### **Barra de Herramientas (R2)** - C2-C17
- **W13**: Campo de búsqueda (C2-C5, R2)
- **W14**: Acceso info plan (C6, R2)
- **W15**: Acceso calendario (C7, R2)
- **W16-W17**: Reservados (C8-C9, R2)
- **W18-W21**: Reservados (C10-C13, R2)
- **W22-W23**: Reservados (C14-C15, R2)
- **W24**: Icono notificaciones (C16, R2)
- **W25**: Icono mensajes (C17, R2)

#### **Área de Contenido (R3-R12)**
- **W26**: Filtros fijos (C2-C5, R3)
- **W27**: Espacio extra (C2-C5, R4)
- **W28**: Lista de planazoos (C2-C5, R5-R12)
- **W31**: Pantalla principal (C6-C17, R3-R12)

#### **Footer (R13)**
- **W29**: Footer izquierdo (C2-C5, R13)
- **W30**: Footer derecho (C6-C17, R13)

**Nota**: Los colores actuales usan `AppColorScheme` (color0-color4), no los colores específicos del documento antiguo.

### Responsive Design

El grid se adapta automáticamente a diferentes tamaños de pantalla mediante `LayoutBuilder`:

#### Breakpoints de Referencia

```
Desktop (1920x1080): 100% del tamaño - Grid completo visible
Tablet (1728x1026):  90% del tamaño  - Grid se comprime proporcionalmente
Mobile (1344x972):   70% del tamaño  - Grid se comprime más aún
```

#### Adaptación Automática

- **LayoutBuilder**: Detecta dimensiones del dispositivo automáticamente
- **Cálculo Dinámico**: `columnWidth` y `rowHeight` se calculan proporcionalmente
- **Proporciones**: Mantiene relaciones de aspecto del grid (17:13)
- **Escalado**: Widgets se redimensionan proporcionalmente sin deformarse

**Nota Importante**: El cálculo de `columnWidth = gridWidth / 17` y `rowHeight = gridHeight / 13` se hace dinámicamente en cada frame, por lo que el grid siempre se adapta al tamaño de la pantalla.

### Archivos de Implementación

- **GridPainter**: `lib/widgets/grid/wd_grid_painter.dart` (⚠️ NOTA: Esta ruta es para el calendario 7×24, NO para el dashboard 17×13)
- **Dashboard Page**: `lib/pages/pg_dashboard_page.dart` (implementa el grid 17×13 manualmente)
- **Código relevante**: `lib/widgets/screens/wd_calendar_screen.dart`

### Notas Importantes

⚠️ **El grid 17×13 es un sistema de layout FIXO del dashboard principal**

- ✅ Se usa en `pg_dashboard_page.dart` para el layout general
- ✅ NO se usa en todas las pantallas de la app
- ✅ Solo aplica al dashboard principal
- ✅ Los widgets W1-W31 son específicos del dashboard
- ⚠️ El `GridPainter` en `lib/widgets/grid/wd_grid_painter.dart` es para el CALENDARIO (7×24), no para el dashboard (17×13)

**Archivos de documentación individual por widget**: `docs/ux/pages/w*.md`

### Uso Práctico del Grid

#### Ejemplo 1: Crear un Widget Básico

```dart
// Widget en C2-C5, R3-R5
Widget _buildExampleWidget(double columnWidth, double rowHeight) {
  // Calcular posición: C2 empieza en índice 1
  final x = columnWidth * 1;   // Columna 2
  
  // Calcular posición: R3 empieza en índice 2
  final y = rowHeight * 2;      // Fila 3
  
  // Ancho: 4 columnas (C2-C5)
  final width = columnWidth * 4;
  
  // Alto: 3 filas (R3-R5)
  final height = rowHeight * 3;
  
  return Positioned(
    left: x,
    top: y,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColorScheme.color1,
        border: Border.all(color: AppColorScheme.color2, width: 2),
      ),
      child: Center(
        child: Text(
          'Widget de Ejemplo',
          style: AppTypography.body,
        ),
      ),
    ),
  );
}
```

#### Ejemplo 2: Widget con Tooltip e Interacción

```dart
// Widget W1 - Barra lateral con perfil (C1, R1-R13)
Widget _buildBarraLateral(double columnWidth, double rowHeight, double totalHeight) {
  final x = 0;                           // C1 empieza en índice 0
  final y = 0;                           // R1 empieza en índice 0
  final width = columnWidth;             // 1 columna
  final height = totalHeight;            // 13 filas (full height)
  
  return Positioned(
    left: x,
    top: y,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColorScheme.color2,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: Tooltip(
            message: 'Ver perfil',
            child: GestureDetector(
              onTap: () {
                // Navegar a perfil
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                ),
                child: Icon(Icons.person, color: Colors.white, size: 24),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
```

#### Ejemplo 3: Widget que Ocupa Múltiples Filas

```dart
// Widget W28 - Lista de planazoos (C2-C5, R5-R12)
Widget _buildListaPlanazoos(double columnWidth, double rowHeight) {
  final x = columnWidth * 1;          // C2 (índice 1)
  final y = rowHeight * 4;             // R5 (índice 4)
  final width = columnWidth * 4;       // 4 columnas (C2-C5)
  final height = rowHeight * 8;        // 8 filas (R5-R12)
  
  return Positioned(
    left: x,
    top: y,
    child: Container(
      width: width,
      height: height,
      child: ListView.builder(
        itemCount: plans.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(plans[index].imageUrl),
            ),
            title: Text(plans[index].title, style: AppTypography.body),
            subtitle: Text(plans[index].description, style: AppTypography.caption),
            onTap: () {
              // Navegar a detalles del plan
            },
          );
        },
      ),
    ),
  );
}
```

### Debugging del Grid

#### Problema: Widgets no se muestran correctamente

**Síntomas**: Widgets aparecen fuera de posición o no se ven

**Soluciones**:
1. Verificar que las coordenadas del JSON coincidan con la implementación
2. Asegurar que el cálculo de `columnWidth` y `rowHeight` se hace correctamente
3. Comprobar que el `LayoutBuilder` detecta las dimensiones correctas
4. Verificar que no hay AppLayoutWrapper o márgenes que limiten el tamaño

**Código de verificación**:
```dart
debugPrint('columnWidth: $columnWidth');
debugPrint('rowHeight: $rowHeight');
debugPrint('Total width: ${constraints.maxWidth}');
debugPrint('Total height: ${constraints.maxHeight}');
```

#### Problema: Grid no ocupa toda la pantalla

**Síntomas**: Grid es más pequeño de lo esperado

**Soluciones**:
1. Verificar que no hay `AppLayoutWrapper` envolviendo el grid
2. Comprobar que no hay `padding` o `margin` innecesarios
3. Asegurar que el contenedor padre tiene `width` y `height` correctos
4. Verificar que no hay `Scaffold` con `appBar` que reduzca el espacio

#### Problema: Widgets se solapan

**Síntomas**: Varios widgets ocupan el mismo espacio

**Soluciones**:
1. Verificar que las posiciones calculadas son correctas
2. Comprobar que no hay widgets con el mismo `Positioned`
3. Asegurar que los anchos y altos no exceden los límites del grid
4. Revisar que el `Stack` tiene todos los widgets correctamente ordenados

**Código de verificación**:
```dart
debugPrint('Widget x: $x, y: $y');
debugPrint('Widget width: $width, height: $height');
debugPrint('Posición final: ($x, $y) a (${x + width}, ${y + height})');
```

#### Problema: Grid no es responsive

**Síntomas**: En móvil el grid se desborda o es demasiado pequeño

**Soluciones**:
1. Verificar que se usa `LayoutBuilder` para obtener las dimensiones
2. Comprobar que el cálculo es dinámico (no hardcodeado)
3. Asegurar que las proporciones 17:13 se mantienen
4. Probar en diferentes tamaños de pantalla (desktop, tablet, mobile)

#### Activar Visualización del Grid (Solo para Debugging)

```dart
// Añadir esto al Stack para ver las líneas del grid
Container(
  child: Stack(
    children: [
      // Grid de fondo (solo para debugging)
      CustomPaint(
        painter: GridPainter(
          cellWidth: columnWidth,
          cellHeight: rowHeight,
          daysPerWeek: 17,
        ),
      ),
      // Tus widgets aquí
      // ...
    ],
  ),
)
```

---

## 🎨 Estilo Base (UI Oscura)

### Estado Actual

✅ **IMPLEMENTADO** - La aplicación Planazoo utiliza una UI oscura por defecto.

**⚠️ IMPORTANTE:** La UI oscura no es un "modo oscuro" opcional. Es el diseño estándar de la aplicación. Todos los componentes deben seguir el Estilo Base documentado en `docs/ux/estilos/ESTILO_SOFISTICADO.md`.

### Implementación Actual

```dart
// En lib/app/app.dart:
MaterialApp(
  theme: AppTheme.lightTheme, // Usa el getter lightTheme
  // ...
)

// En lib/app/theme/app_theme.dart:
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: AppColorScheme.color2,
        secondary: AppColorScheme.color3,
        // ...
      ),
      textTheme: TextTheme(/* con AppTypography */),
      // ... más configuración
    );
  }
  
  // ❌ darkTheme aún no existe
  static ThemeData get darkTheme {
    // POR IMPLEMENTAR
  }
}
```

---

## 📐 MEJORES PRÁCTICAS

### ✅ Hacer

- Usar los colores de `AppColorScheme` (existe)
- Usar la tipografía de `AppTypography` (existe)
- Crear widgets en `lib/widgets/` para componentes reutilizables
- Usar `LayoutBuilder` para responsive
- Usar iconos de Material Icons de forma consistente
- Documentar nuevos componentes en esta guía
- Seguir el patrón de grid 17×13 para el dashboard

### ❌ Evitar

- Colores hardcodeados (`Colors.blue`) → Usar `AppColorScheme`
- Espaciado hardcodeado cuando el sistema esté implementado
- Mezclar diferentes tamaños de iconos sin sistema
- Inconsistencia en tamaños de fuente
- Usar componentes reutilizables que no existen todavía

**Nota**: Usa Material Design widgets + `AppColorScheme` + `AppTypography` para mantener consistencia. No necesitas wrappers personalizados.

---

## 🚀 FUTUROS CAMBIOS FÁCILES

### ✅ Cambiar Colores Globalmente (IMPLEMENTADO)

```dart
// Cambiar en lib/app/theme/color_scheme.dart
// Por ejemplo, cambiar color2:
static const Color color2 = Color(0xFF79A2A8); // Cambiar este valor

// Todos los componentes que usan AppColorScheme se actualizarán automáticamente
```

### ✅ Cambiar Tipografía Globalmente (IMPLEMENTADO)

```dart
// Cambiar en lib/app/theme/typography.dart
// Por ejemplo, cambiar el tamaño de títulos:
static TextStyle get titleStyle => _notoSans(
  fontSize: 24.0, // Cambiar este valor
  fontWeight: FontWeight.bold,
  color: AppColorScheme.titleColor,
);
```

### ⚠️ Cambiar Iconos Globalmente (USAR MATERIAL ICONS)

```dart
// No es necesario crear AppIcons
// Simplemente buscar/reemplazar en el código
// Ejemplo: Icons.home → Icons.home_rounded
// Usar "Find and Replace" del IDE
```

### ⚠️ Cambiar Espaciado Globalmente (POR IMPLEMENTAR)

```dart
// Cuando se implemente AppSpacing, cambiar en lib/app/theme/app_spacing.dart
// Layout se ajustará proporcionalmente

// Por ahora, buscar valores de espaciado común y reemplazar:
// EdgeInsets.all(16) → EdgeInsets.all(AppSpacing.md)
```

---

## 📋 CHECKLIST PARA NUEVAS PANTALLAS

### ✅ Lo que DEBES hacer (implementado):
- [ ] Usar colores de `AppColorScheme` (existe)
- [ ] Usar tipografía de `AppTypography` (existe)
- [ ] Usar el tema de `AppTheme.lightTheme` (existe)
- [ ] Crear widgets en `lib/widgets/` para reutilización
- [ ] Layout responsive con `LayoutBuilder`
- [ ] Probar en diferentes tamaños de pantalla
- [ ] Documentar componentes nuevos en esta guía

### ⚠️ Lo que NO necesitas (Material Design ya lo cubre):
- [x] ~~Usar wrappers de botones personalizados~~ → Usar `ElevatedButton` + `AppColorScheme`
- [x] ~~Usar wrappers de cards personalizados~~ → Usar `Card` + `AppColorScheme`
- [x] ~~Usar wrappers de inputs personalizados~~ → Usar `TextField` + `AppColorScheme`
- [x] ~~Usar iconos de `AppIcons`~~ → Usar `Icons.*` + `AppColorScheme`

**Nota**: Usa Material Design directamente con `AppColorScheme` y `AppTypography` para mantener consistencia.

---

## 📊 TAREAS RELACIONADAS

**Completas ✅:**
- ✅ Base de color scheme definido (`AppColorScheme`)
- ✅ Sistema de tipografía con Noto Sans (`AppTypography`)
- ✅ Tema base configurado (`AppTheme.lightTheme`)

**Opcional para Implementar ⚠️:**
- ❌ Sistema de espaciado estandarizado (`AppSpacing`) - Recomendado para consistencia
- ❌ Sistema de breakpoints responsivos (`AppBreakpoints`) - Recomendado para responsive
- ❌ Tema oscuro (`AppTheme.darkTheme`) - Opcional según necesidad

**NO Implementar (innecesario):**
- ✅ Material Design ya provee: botones, cards, inputs, iconos
- ✅ No crear wrappers innecesarios

---

## ✅ IMPLEMENTACIÓN ACTUAL

**Estado:** ⚠️ Parcialmente implementado

### ✅ Lo que YA EXISTE en el código:

- ✅ `AppColorScheme` en `lib/app/theme/color_scheme.dart` (color0-color4, estados)
- ✅ `AppTypography` en `lib/app/theme/typography.dart` con **Noto Sans** (usando Google Fonts)
- ✅ `AppTheme.lightTheme` en `lib/app/theme/app_theme.dart` (tema configurado)
- ✅ `google_fonts` instalado en `pubspec.yaml` para cargar Noto Sans
- ✅ Grid 17×13 implementado en `lib/pages/pg_dashboard_page.dart` (dashboard principal)
- ✅ Sistema de calendario (grid 7×24) en `lib/widgets/grid/wd_grid_painter.dart`
- ✅ Componentes de calendario específicos
- ✅ Navegación estructurada

### ⚠️ Lo que falta implementar (opcional, pero recomendado):

- ❌ `AppSpacing` - Sistema de espaciado estandarizado (recomendado)
- ❌ `AppBreakpoints` - Sistema de breakpoints responsivos (recomendado)
- ❌ Tema oscuro (`AppTheme.darkTheme`) - Opcional

### ⚠️ Lo que NO necesita implementarse:

- ✅ Material Design widgets ya cubren botones, cards, inputs, etc.
- ✅ Material Icons ya cubre los iconos necesarios
- ✅ No necesita wrappers innecesarios de componentes

### 🎯 Propósito de esta Guía:

Esta guía sirve como **referencia de diseño** que documenta:
1. Lo que **existe** actualmente (colores, tipografía, tema, grid)
2. Lo que **se puede implementar** para mejorar la consistencia (espaciado, breakpoints)
3. Lo que **NO necesita** implementarse (Material ya lo cubre)

Es una guía **práctica** que evita sobre-ingeniería.

---

*Guía de UI para mantener consistencia visual*  
*Última actualización: Febrero 2026*

