import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final double cellWidth;
  final double cellHeight;
  final int hoursPerDay;
  final int daysPerWeek;

  GridPainter({
    required this.cellWidth,
    required this.cellHeight,
    this.hoursPerDay = 24,
    this.daysPerWeek = 7,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..strokeWidth = 1.0;

    // Draw vertical lines
    for (int i = 0; i <= daysPerWeek; i++) {
      final x = i * cellWidth;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (int i = 0; i <= hoursPerDay; i++) {
      final y = i * cellHeight;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}