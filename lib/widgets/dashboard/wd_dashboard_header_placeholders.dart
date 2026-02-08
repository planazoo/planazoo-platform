import 'package:flutter/material.dart';

/// Celdas vacías de la barra superior del dashboard (W7–W12: C12–C17, R1).
/// Mantienen el mismo fondo que el header para alinear visualmente la rejilla.
class WdDashboardHeaderPlaceholders extends StatelessWidget {
  final double columnWidth;
  final double rowHeight;

  const WdDashboardHeaderPlaceholders({
    super.key,
    required this.columnWidth,
    required this.rowHeight,
  });

  static const int _startColumn = 11; // C12 (índice 11)
  static const int _cellCount = 6; // W7 a W12

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (int i = 0; i < _cellCount; i++)
          Positioned(
            left: columnWidth * (_startColumn + i) - 1,
            top: 0,
            child: Container(
              width: columnWidth + 1,
              height: rowHeight,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
              ),
            ),
          ),
      ],
    );
  }
}
