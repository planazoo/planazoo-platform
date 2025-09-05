# 📱 UX Technical Documentation - UNP Calendario

## 🎯 Overview
Esta documentación describe la implementación técnica completa de la interfaz de usuario (UX) para la aplicación UNP Calendario, permitiendo su reconstrucción desde cero.

## 🏗️ Arquitectura del Sistema

### Framework y Tecnologías
- **Framework**: Flutter 3.x
- **Lenguaje**: Dart
- **Plataforma**: Multiplataforma (Web, Mobile, Desktop)
- **Arquitectura**: Feature-based con Riverpod para state management

### Estructura de Carpetas
```
lib/
├── features/
│   └── calendar/
│       ├── presentation/
│       │   ├── pages/
│       │   │   ├── ux_demo_page.dart          # Página principal UX
│       │   │   └── ux_json_generator.dart     # Generador JSON
│       │   └── widgets/
│       └── domain/
├── shared/
│   └── services/
└── app/
```

## 📐 Sistema de Grid

### Dimensiones del Grid
- **Columnas**: 17 (C1-C17)
- **Filas**: 13 (R1-R13)
- **Distribución**: Uniforme (ancho y alto igual para todas las celdas)

### Cálculo de Posiciones
```dart
final columnWidth = constraints.maxWidth / 17;
final rowHeight = constraints.maxHeight / 13;

// Para un widget en C2-C5, R3:
final x = columnWidth * 1;        // Empieza en C2 (índice 1)
final y = rowHeight * 2;          // Empieza en R3 (índice 2)
final width = columnWidth * 4;    // Ocupa 4 columnas (C2-C5)
final height = rowHeight;         // Ocupa 1 fila (R3)
```

## 🎨 Implementación Visual

### CustomPainter para Grid
```dart
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    // Líneas verticales (17 columnas)
    for (int i = 0; i <= 17; i++) {
      final x = (size.width / 17) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Líneas horizontales (13 filas)
    for (int i = 0; i <= 13; i++) {
      final y = (size.height / 13) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
}
```

### Estructura de Widgets
```dart
Widget _buildGrid() {
  return LayoutBuilder(
    builder: (context, constraints) {
      final columnWidth = constraints.maxWidth / 17;
      final rowHeight = constraints.maxHeight / 13;
      
      return Container(
        child: Stack(
          children: [
            CustomPaint(painter: GridPainter()),
            _buildW1(columnWidth, rowHeight, constraints.maxHeight),
            _buildW2(columnWidth, rowHeight),
            // ... resto de widgets
          ],
        ),
      );
    },
  );
}
```

## 🎯 Especificación de Widgets

### Widget W1 - Barra Lateral
- **Ubicación**: C1 (R1-R13)
- **Función**: Barra lateral con lista de Planazoos
- **Dimensiones**: 1 columna × 13 filas
- **Color**: Azul (Colors.blue.shade200)
- **Implementación**: `_buildW1(columnWidth, rowHeight, gridHeight)`

### Widget W2 - Logo de la App
- **Ubicación**: C2-C3 (R1)
- **Función**: Logo principal de la aplicación
- **Dimensiones**: 2 columnas × 1 fila
- **Color**: Verde (Colors.green.shade200)
- **Implementación**: `_buildW2(columnWidth, rowHeight)`

### Widget W13 - Campo de Búsqueda
- **Ubicación**: C2-C5 (R2)
- **Función**: Campo de búsqueda principal
- **Dimensiones**: 4 columnas × 1 fila
- **Color**: Teal (Colors.teal.shade200)
- **Implementación**: `_buildW13(columnWidth, rowHeight)`

### Widget W28 - Lista de Planazoos
- **Ubicación**: C2-C5 (R5-R12)
- **Función**: Lista principal de planazoos con imágenes e iconos
- **Dimensiones**: 4 columnas × 8 filas
- **Color**: Rojo (Colors.red.shade200)
- **Implementación**: `_buildW28(columnWidth, rowHeight)`

### Widget W31 - Pantalla Principal
- **Ubicación**: C6-C17 (R3-R12)
- **Función**: Área principal para formularios e información
- **Dimensiones**: 12 columnas × 10 filas
- **Color**: Azul (Colors.blue.shade200)
- **Implementación**: `_buildW31(columnWidth, rowHeight)`

## 🔧 Sistema de Generación Automática

### UXJsonGenerator
El sistema incluye un generador automático que:
- Mantiene sincronizado el JSON con la implementación
- Genera coordenadas pixel automáticamente
- Incluye metadatos técnicos completos
- Proporciona instrucciones de reconstrucción

### Funcionalidades
```dart
class UXJsonGenerator {
  static Map<String, dynamic> generateUXSpecification();
  static Future<void> saveUXSpecification();
  static Map<String, dynamic> _generateLayoutPx(Map<String, dynamic> gridBBox);
}
```

## 📱 Responsive Design

### Adaptación Automática
- **LayoutBuilder**: Detecta dimensiones del dispositivo
- **Cálculo Dinámico**: columnWidth y rowHeight se adaptan automáticamente
- **Proporciones**: Mantiene relaciones de aspecto del grid
- **Escalado**: Widgets se redimensionan proporcionalmente

### Breakpoints
- **Desktop**: 1920x1080 (referencia)
- **Tablet**: 90% del tamaño desktop
- **Mobile**: 70% del tamaño desktop

## 🎨 Sistema de Colores

### Paleta de Colores
- **W1**: Colors.blue.shade200 (Barra lateral)
- **W2**: Colors.green.shade200 (Logo)
- **W3**: Colors.orange.shade200 (Nuevo plan)
- **W4**: Colors.purple.shade200 (Menú)
- **W5**: Colors.pink.shade200 (Icono plan)
- **W6**: Colors.cyan.shade200 (Info planazoo)
- **W7**: Colors.lime.shade200 (Info)
- **W8**: Colors.deepOrange.shade200 (Presupuesto)
- **W9**: Colors.deepPurple.shade200 (Participantes)
- **W10**: Colors.blueGrey.shade200 (Mi estado)
- **W11**: Colors.lightGreen.shade200 (Libre)
- **W12**: Colors.grey.shade200 (Menú opciones)
- **W13**: Colors.teal.shade200 (Búsqueda)
- **W14-W25**: Colores únicos para cada widget
- **W26**: Colors.indigo.shade200 (Filtros)
- **W27**: Colors.amber.shade200 (Espacio extra)
- **W28**: Colors.red.shade200 (Lista planazoos)
- **W29**: Colors.brown.shade200 (Por definir)
- **W30**: Colors.lightGreen.shade200 (Por definir)
- **W31**: Colors.blue.shade200 (Pantalla principal)

### Estilos Visuales
- **Opacidad**: 0.7 para transparencia
- **Bordes**: 3px con borderRadius.circular(4)
- **Tipografía**: Múltiples tamaños y pesos
- **Espaciado**: SizedBox para separación vertical

## 🚀 Instrucciones de Reconstrucción

### Paso 1: Configuración del Proyecto
```bash
flutter create unp_calendario
cd unp_calendario
```

### Paso 2: Estructura de Carpetas
Crear la estructura de carpetas según la arquitectura definida.

### Paso 3: Dependencias
```yaml
dependencies:
  flutter:
    sdk: flutter
  riverpod: ^2.4.9
```

### Paso 4: Implementación del Grid
1. Crear `GridPainter` extendiendo `CustomPainter`
2. Implementar `UXDemoPage` como `StatefulWidget`
3. Usar `LayoutBuilder` para dimensiones responsivas
4. Implementar `Stack` con `CustomPaint` de fondo

### Paso 5: Widgets Individuales
1. Implementar cada método `_buildWX` según las especificaciones
2. Usar coordenadas del JSON para posicionamiento
3. Aplicar colores y estilos definidos
4. Añadir contenido y funcionalidad

### Paso 6: Sistema de Generación
1. Implementar `UXJsonGenerator`
2. Conectar con botones de la interfaz
3. Generar JSON automáticamente

## 📊 Metadatos del Sistema

### Información del Proyecto
- **Nombre**: UNP Calendario
- **Versión**: 2.0
- **Framework**: Flutter
- **Arquitectura**: Feature-based
- **State Management**: Riverpod
- **Base de Datos**: Firebase Firestore

### Estadísticas de Widgets
- **Total Widgets**: 31
- **Grid**: 17×13 = 221 celdas
- **Widgets Implementados**: 31 (100%)
- **Última Actualización**: Automática

## 🔍 Debugging y Mantenimiento

### Herramientas de Desarrollo
- **Flutter Inspector**: Para inspeccionar widgets
- **Debug Console**: Para logs del generador JSON
- **Hot Reload**: Para desarrollo iterativo

### Logs del Sistema
```dart
debugPrint('✅ UX Specification actualizada automáticamente');
debugPrint('📁 Guardado en: assets/ux_specification.json');
debugPrint('📁 Guardado en: docs/ux_specification.json');
```

## 📚 Recursos Adicionales

### Archivos de Referencia
- `assets/ux_specification.json`: Especificación completa
- `docs/UX_TECHNICAL_DOCUMENTATION.md`: Esta documentación
- `lib/features/calendar/presentation/pages/ux_demo_page.dart`: Implementación

### Enlaces Útiles
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design Guidelines](https://material.io/design)

## 🎉 Conclusión

Esta documentación proporciona toda la información necesaria para reconstruir la interfaz de usuario de UNP Calendario desde cero. El sistema de generación automática garantiza que la documentación esté siempre sincronizada con la implementación.

Para cualquier pregunta o aclaración, consultar el código fuente y el JSON de especificaciones que se actualiza automáticamente.

---

**Generado automáticamente por UXJsonGenerator**  
**Última actualización**: ${DateTime.now().toString()}  
**Versión**: 2.0
