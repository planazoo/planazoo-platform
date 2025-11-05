import 'package:flutter/material.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/shared/utils/constants.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_constants.dart';

/// Componente que representa la estructura base del grid del calendario
/// 
/// Responsabilidad: Estructura base del grid (columna de horas + área de datos)
/// 
/// Este componente encapsula:
/// - Columna fija de horas
/// - Área de datos con scroll sincronizado
/// - Layout base Row con horas + datos
class CalendarGrid extends StatelessWidget {
  /// Controlador de scroll para la columna de horas
  final ScrollController hoursScrollController;
  
  /// Controlador de scroll para el área de datos
  final ScrollController dataScrollController;
  
  /// Builder para construir las filas fijas (headers y alojamientos)
  final Widget Function() buildFixedRows;
  
  /// Builder para construir las filas de datos
  final Widget Function() buildDataRows;
  
  /// Builder para construir la capa de eventos
  final List<Widget> Function(double availableWidth) buildEventsLayer;

  const CalendarGrid({
    super.key,
    required this.hoursScrollController,
    required this.dataScrollController,
    required this.buildFixedRows,
    required this.buildDataRows,
    required this.buildEventsLayer,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Capa 1: Calendario base (fijo)
        Row(
          children: [
            // Columna FIJO (horas) - fija
            _buildFixedHoursColumn(),
            
            // Columnas de datos - 7 días fijos
            Expanded(
              child: _buildDataColumns(context),
            ),
          ],
        ),
      ],
    );
  }

  /// Construye la columna fija de horas
  Widget _buildFixedHoursColumn() {
    return Container(
      width: 80.0, // Ancho fijo para mostrar "00:00"
      child: Column(
        children: [
          // Encabezado (primera celda)
          Container(
            height: CalendarConstants.headerHeight,
            decoration: BoxDecoration(
              border: Border.all(color: AppColorScheme.gridLineColor),
              color: AppColorScheme.color1,
            ),
            child: const Center(
              child: SizedBox.shrink(), // Celda vacía
            ),
          ),
          
          // Fila de alojamientos FIJA
          Container(
            height: CalendarConstants.accommodationRowHeight,
            decoration: BoxDecoration(
              border: Border.all(color: AppColorScheme.gridLineColor),
              color: AppColorScheme.color1.withOpacity(0.3),
            ),
            child: const Center(
              child: Text(
                'Alojamiento',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
          ),
          
          // Filas de horas con scroll vertical
          Expanded(
            child: SingleChildScrollView(
              controller: hoursScrollController,
              child: Column(
                children: List.generate(AppConstants.defaultRowCount, (index) {
                  return Container(
                    height: AppConstants.cellHeight,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColorScheme.gridLineColor),
                      color: AppColorScheme.color0,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${index.toString().padLeft(2, '0')}:00',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye las columnas de datos (7 días)
  Widget _buildDataColumns(BuildContext context) {
    return Column(
      children: [
        // Filas fijas (encabezado y alojamientos)
        buildFixedRows(),
        
        // Filas con scroll vertical (datos de horas)
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Capa 1: Datos de la tabla
                  SingleChildScrollView(
                    controller: dataScrollController,
                    child: Stack(
                      children: [
                        buildDataRows(),
                        // Capa 2: Eventos (Positioned) - Ahora dentro del SingleChildScrollView
                        ...buildEventsLayer(constraints.maxWidth),
                        // Capa 3: Detector invisible para doble clicks en celdas vacías (deshabilitado temporalmente)
                        // _buildDoubleClickDetector(constraints.maxWidth),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

