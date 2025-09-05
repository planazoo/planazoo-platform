import 'package:flutter/material.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColorScheme.gridLineColor
      ..strokeWidth = 1;

    // Líneas verticales (columnas) - 17 columnas de ancho uniforme
    for (int i = 0; i <= 17; i++) {
      final x = (size.width / 17) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Líneas horizontales (filas) - 13 filas de alto uniforme
    for (int i = 0; i <= 13; i++) {
      final y = (size.height / 13) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
