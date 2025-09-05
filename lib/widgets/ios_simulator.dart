import 'package:flutter/material.dart';

class IOSSimulator extends StatelessWidget {
  final Widget child;
  final String deviceName;
  final double width;
  final double height;

  const IOSSimulator({
    super.key,
    required this.child,
    this.deviceName = 'iPhone 15 Pro',
    this.width = 375,
    this.height = 812,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcular el tamaño máximo disponible
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        
        // Calcular el factor de escala para que quepa en el espacio disponible
        final scaleX = (maxWidth - 40) / (width + 40);
        final scaleY = (maxHeight - 80) / (height + 80);
        final scale = scaleX < scaleY ? scaleX : scaleY;
        
        // Aplicar un límite mínimo y máximo de escala
        final finalScale = scale.clamp(0.3, 1.0);
        
        return Center(
          child: Transform.scale(
            scale: finalScale,
            child: Container(
              width: width + 40,
              height: height + 80,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Status bar
                  Container(
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 20),
                        Text(
                          deviceName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            // Signal
                            Container(
                              width: 20,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(4, (index) => 
                                  Container(
                                    width: 2,
                                    height: (6 - index).toDouble(),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            // Battery
                            Container(
                              width: 25,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(color: Colors.white, width: 1),
                              ),
                              child: Container(
                                width: 20,
                                height: 8,
                                margin: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Screen
                  Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: child,
                    ),
                  ),
                  // Home indicator
                  Container(
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 134,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
