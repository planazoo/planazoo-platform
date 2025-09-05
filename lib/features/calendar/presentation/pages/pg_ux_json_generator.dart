import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class UXJsonGenerator {
  static const Map<String, Map<String, dynamic>> widgetDefinitions = {
    'W1': {
      'ubicacion': 'C1 (R1-R13)',
      'funcion': 'Barra lateral que muestra la lista de Planazoos y accesos rápidos.',
      'gridBBox': {'cmin': 1, 'cmax': 1, 'rmin': 1, 'rmax': 13},
      'color': 'blue',
    },
    'W2': {
      'ubicacion': 'C2-C3 (R1)',
      'funcion': 'Logo de la app',
      'gridBBox': {'cmin': 2, 'cmax': 3, 'rmin': 1, 'rmax': 1},
      'color': 'green',
    },
    'W3': {
      'ubicacion': 'C4 (R1)',
      'funcion': 'Botón nuevo planazoo',
      'gridBBox': {'cmin': 4, 'cmax': 4, 'rmin': 1, 'rmax': 1},
      'color': 'orange',
    },
    'W4': {
      'ubicacion': 'C5 (R1)',
      'funcion': 'Menú de opciones',
      'gridBBox': {'cmin': 5, 'cmax': 5, 'rmin': 1, 'rmax': 1},
      'color': 'purple',
    },
    'W5': {
      'ubicacion': 'C6 (R1)',
      'funcion': 'Icono planazoo seleccionado',
      'gridBBox': {'cmin': 6, 'cmax': 6, 'rmin': 1, 'rmax': 1},
      'color': 'pink',
    },
    'W6': {
      'ubicacion': 'C7-C11 (R1)',
      'funcion': 'Información del planazoo seleccionado',
      'gridBBox': {'cmin': 7, 'cmax': 11, 'rmin': 1, 'rmax': 1},
      'color': 'cyan',
    },
    'W7': {
      'ubicacion': 'C12 (R1)',
      'funcion': 'Info',
      'gridBBox': {'cmin': 12, 'cmax': 12, 'rmin': 1, 'rmax': 1},
      'color': 'lime',
    },
    'W8': {
      'ubicacion': 'C13 (R1)',
      'funcion': 'Presupuesto',
      'gridBBox': {'cmin': 13, 'cmax': 13, 'rmin': 1, 'rmax': 1},
      'color': 'deepOrange',
    },
    'W9': {
      'ubicacion': 'C14 (R1)',
      'funcion': 'Contador participantes',
      'gridBBox': {'cmin': 14, 'cmax': 14, 'rmin': 1, 'rmax': 1},
      'color': 'deepPurple',
    },
    'W10': {
      'ubicacion': 'C15 (R1)',
      'funcion': 'Mi estado en el planazoo',
      'gridBBox': {'cmin': 15, 'cmax': 15, 'rmin': 1, 'rmax': 1},
      'color': 'blueGrey',
    },
    'W11': {
      'ubicacion': 'C16 (R1)',
      'funcion': 'Libre',
      'gridBBox': {'cmin': 16, 'cmax': 16, 'rmin': 1, 'rmax': 1},
      'color': 'lightGreen',
    },
    'W12': {
      'ubicacion': 'C17 (R1)',
      'funcion': 'Menu opciones',
      'gridBBox': {'cmin': 17, 'cmax': 17, 'rmin': 1, 'rmax': 1},
      'color': 'grey',
    },
    'W13': {
      'ubicacion': 'C2-C5 (R2)',
      'funcion': 'Campo de búsqueda',
      'gridBBox': {'cmin': 2, 'cmax': 5, 'rmin': 2, 'rmax': 2},
      'color': 'teal',
    },
    'W14': {
      'ubicacion': 'C6 (R2)',
      'funcion': 'Acceso info planazoo',
      'gridBBox': {'cmin': 6, 'cmax': 6, 'rmin': 2, 'rmax': 2},
      'color': 'lightBlue',
    },
    'W15': {
      'ubicacion': 'C7 (R2)',
      'funcion': 'Acceso calendario',
      'gridBBox': {'cmin': 7, 'cmax': 7, 'rmin': 2, 'rmax': 2},
      'color': 'lightGreen',
    },
    'W16': {
      'ubicacion': 'C8 (R2)',
      'funcion': 'Por definir',
      'gridBBox': {'cmin': 8, 'cmax': 8, 'rmin': 2, 'rmax': 2},
      'color': 'yellow',
    },
    'W17': {
      'ubicacion': 'C9 (R2)',
      'funcion': 'Por definir',
      'gridBBox': {'cmin': 9, 'cmax': 9, 'rmin': 2, 'rmax': 2},
      'color': 'orange',
    },
    'W18': {
      'ubicacion': 'C10 (R2)',
      'funcion': 'Por definir',
      'gridBBox': {'cmin': 10, 'cmax': 10, 'rmin': 2, 'rmax': 2},
      'color': 'red',
    },
    'W19': {
      'ubicacion': 'C11 (R2)',
      'funcion': 'Por definir',
      'gridBBox': {'cmin': 11, 'cmax': 11, 'rmin': 2, 'rmax': 2},
      'color': 'purple',
    },
    'W20': {
      'ubicacion': 'C12 (R2)',
      'funcion': 'Por definir',
      'gridBBox': {'cmin': 12, 'cmax': 12, 'rmin': 2, 'rmax': 2},
      'color': 'indigo',
    },
    'W21': {
      'ubicacion': 'C13 (R2)',
      'funcion': 'Por definir',
      'gridBBox': {'cmin': 13, 'cmax': 13, 'rmin': 2, 'rmax': 2},
      'color': 'teal',
    },
    'W22': {
      'ubicacion': 'C14 (R2)',
      'funcion': 'Por definir',
      'gridBBox': {'cmin': 14, 'cmax': 14, 'rmin': 2, 'rmax': 2},
      'color': 'cyan',
    },
    'W23': {
      'ubicacion': 'C15 (R2)',
      'funcion': 'Por definir',
      'gridBBox': {'cmin': 15, 'cmax': 15, 'rmin': 2, 'rmax': 2},
      'color': 'amber',
    },
    'W24': {
      'ubicacion': 'C16 (R2)',
      'funcion': 'Icono notificaciones',
      'gridBBox': {'cmin': 16, 'cmax': 16, 'rmin': 2, 'rmax': 2},
      'color': 'deepOrange',
    },
    'W25': {
      'ubicacion': 'C17 (R2)',
      'funcion': 'Icono mensajes',
      'gridBBox': {'cmin': 17, 'cmax': 17, 'rmin': 2, 'rmax': 2},
      'color': 'deepPurple',
    },
    'W26': {
      'ubicacion': 'C2-C5 (R3)',
      'funcion': 'Filtros fijos de la lista de planazoos',
      'gridBBox': {'cmin': 2, 'cmax': 5, 'rmin': 3, 'rmax': 3},
      'color': 'indigo',
    },
    'W27': {
      'ubicacion': 'C2-C5 (R4)',
      'funcion': 'Espacio extra no definido',
      'gridBBox': {'cmin': 2, 'cmax': 5, 'rmin': 4, 'rmax': 4},
      'color': 'amber',
    },
    'W28': {
      'ubicacion': 'C2-C5 (R5-R12)',
      'funcion': 'Lista de planazoos con imagen, información e iconos de acción (editar, eliminar, estado)',
      'gridBBox': {'cmin': 2, 'cmax': 5, 'rmin': 5, 'rmax': 12},
      'color': 'red',
    },
    'W29': {
      'ubicacion': 'C2-C5 (R13)',
      'funcion': 'Por definir',
      'gridBBox': {'cmin': 2, 'cmax': 5, 'rmin': 13, 'rmax': 13},
      'color': 'brown',
    },
    'W30': {
      'ubicacion': 'C6-C17 (R13)',
      'funcion': 'Por definir',
      'gridBBox': {'cmin': 6, 'cmax': 17, 'rmin': 13, 'rmax': 13},
      'color': 'lightGreen',
    },
    'W31': {
      'ubicacion': 'C6-C17 (R3-R12)',
      'funcion': 'Pantalla principal donde se muestran los formularios e informaciones seleccionados del planazoo',
      'gridBBox': {'cmin': 6, 'cmax': 17, 'rmin': 3, 'rmax': 12},
      'color': 'blue',
    },
  };

  static Map<String, dynamic> generateUXSpecification() {
    final List<Map<String, dynamic>> widgets = [];
    
    widgetDefinitions.forEach((widgetId, definition) {
      final Map<String, dynamic> widget = {
        'Widget ID': widgetId,
        'Ubicación (texto)': definition['ubicacion'],
        'Función (texto)': definition['funcion'],
        'GridBBox': definition['gridBBox'],
        'LayoutPx': _generateLayoutPx(definition['gridBBox']),
        'Color': definition['color'],
        'Estado': 'Implementado',
        'Última actualización': DateTime.now().toIso8601String(),
      };
      
      widgets.add(widget);
    });

    return {
      'metadata': {
        'version': '2.0',
        'fecha_generacion': DateTime.now().toIso8601String(),
        'total_widgets': widgets.length,
        'grid_dimensions': {
          'columnas': 17,
          'filas': 13,
        },
        'especificaciones_tecnicas': {
          'framework': 'Flutter',
          'lenguaje': 'Dart',
          'responsive': true,
          'grid_system': '17x13 columnas/filas uniformes',
          'posicionamiento': 'Stack + Positioned widgets',
          'custom_painting': 'GridPainter para líneas del grid',
          'layout_builder': 'Dimensiones responsivas automáticas',
          'estado': 'StatefulWidget con setState',
          'navegacion': 'Navigator.push para transiciones',
          'estilos': 'Material Design con colores personalizados',
          'opacidad': 'withOpacity(0.7) para transparencia',
          'bordes': 'Border.all con borderRadius.circular(4)',
          'tipografia': 'TextStyle con diferentes tamaños y pesos'
        },
        'instrucciones_reconstruccion': [
          '1. Crear proyecto Flutter con estructura de carpetas features/',
          '2. Implementar UXDemoPage como StatefulWidget',
          '3. Crear GridPainter extendiendo CustomPainter',
          '4. Usar LayoutBuilder para obtener constraints del padre',
          '5. Calcular columnWidth = maxWidth / 17 y rowHeight = maxHeight / 13',
          '6. Implementar Stack con CustomPaint de fondo',
          '7. Añadir Positioned widgets usando coordenadas del JSON',
          '8. Aplicar colores, estilos y contenido según especificaciones',
          '9. Implementar AppBar con botones de actualización e información',
          '10. Crear UXJsonGenerator para mantener JSON sincronizado'
        ],
        'estructura_archivos': {
          'ux_demo_page.dart': 'Página principal con implementación de todos los widgets',
          'ux_json_generator.dart': 'Generador automático del JSON de especificaciones',
          'ux_specification.json': 'Especificación completa de la UX (assets/)',
          'docs/ux_specification.json': 'Copia de respaldo de la especificación'
        },
        'dependencias_flutter': [
          'flutter/material.dart',
          'dart:convert',
          'dart:io'
        ],
        'notas': 'JSON generado automáticamente desde UXDemoPage - Documentación completa para reconstrucción',
        'ultima_actualizacion': DateTime.now().toIso8601String(),
        'autor': 'Sistema Automático de Generación UX',
        'proyecto': 'UNP Calendario - Flutter App'
      },
      'widgets': widgets,
    };
  }

  static Map<String, dynamic> _generateLayoutPx(Map<String, dynamic> gridBBox) {
    // Generar coordenadas pixel basadas en el grid
    final int cmin = gridBBox['cmin'] as int;
    final int cmax = gridBBox['cmax'] as int;
    final int rmin = gridBBox['rmin'] as int;
    final int rmax = gridBBox['rmax'] as int;
    
    // Calcular dimensiones (asumiendo grid de 1920x1080)
    final double columnWidth = 1920.0 / 17;
    final double rowHeight = 1080.0 / 13;
    
    final double x = (cmin - 1) * columnWidth;
    final double y = (rmin - 1) * rowHeight;
    final double width = (cmax - cmin + 1) * columnWidth;
    final double height = (rmax - rmin + 1) * rowHeight;
    
    return {
      'desktop': {
        'x': x.roundToDouble(),
        'y': y.roundToDouble(),
        'width': width.roundToDouble(),
        'height': height.roundToDouble(),
      },
      'tablet': {
        'x': (x * 0.9).roundToDouble(),
        'y': (y * 0.95).roundToDouble(),
        'width': (width * 0.9).roundToDouble(),
        'height': (height * 0.95).roundToDouble(),
      },
      'mobile': {
        'x': (x * 0.7).roundToDouble(),
        'y': (y * 0.9).roundToDouble(),
        'width': (width * 0.7).roundToDouble(),
        'height': (height * 0.9).roundToDouble(),
      },
    };
  }

  static Future<void> saveUXSpecification() async {
    try {
      final jsonData = generateUXSpecification();
      final jsonString = JsonEncoder.withIndent('  ').convert(jsonData);
      
      // Guardar en assets
      final assetsFile = File('assets/ux_specification.json');
      await assetsFile.writeAsString(jsonString);
      
      // Guardar también en docs para respaldo
      final docsFile = File('docs/ux_specification.json');
      await docsFile.writeAsString(jsonString);
      
      debugPrint('✅ UX Specification actualizada automáticamente');
      debugPrint('📁 Guardado en: assets/ux_specification.json');
      debugPrint('📁 Guardado en: docs/ux_specification.json');
    } catch (e) {
      debugPrint('❌ Error al guardar UX Specification: $e');
    }
  }
}
