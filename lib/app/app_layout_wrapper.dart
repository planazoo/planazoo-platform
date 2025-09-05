import 'package:flutter/material.dart';

class AppLayoutWrapper extends StatelessWidget {
  final Widget child;

  const AppLayoutWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < 800;
        
        // Calcular ancho de las columnas laterales
        final columnWidth = isSmallScreen ? 0.0 : 200.0;
        
        return Row(
          children: [
            // Columna izquierda
            if (!isSmallScreen)
              Container(
                width: columnWidth,
                color: Colors.grey.shade100,
                child: const Center(
                  child: Icon(Icons.calendar_today_outlined),
                ),
              ),
            // Contenido principal
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth - (columnWidth * 2),
                  ),
                  child: child,
                ),
              ),
            ),
            // Columna derecha
            if (!isSmallScreen)
              Container(
                width: columnWidth,
                color: Colors.grey.shade100,
                child: const Center(
                  child: Icon(Icons.settings_outlined),
                ),
              ),
          ],
        );
      },
    );
  }
} 