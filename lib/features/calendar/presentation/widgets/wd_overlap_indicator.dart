import 'package:flutter/material.dart';

/// Widget que muestra un indicador visual de eventos solapados
class OverlapIndicator extends StatelessWidget {
  final int overlapCount;
  final Color color;
  final double size;

  const OverlapIndicator({
    super.key,
    required this.overlapCount,
    required this.color,
    this.size = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    if (overlapCount <= 1) return const SizedBox.shrink();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          overlapCount.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Widget que muestra un indicador de línea para eventos continuos
class EventContinuationIndicator extends StatelessWidget {
  final Color color;
  final double height;
  final bool isStart;
  final bool isEnd;

  const EventContinuationIndicator({
    super.key,
    required this.color,
    required this.height,
    this.isStart = false,
    this.isEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: color.withValues(alpha: 0.6),
            width: 2,
          ),
          right: BorderSide(
            color: color.withValues(alpha: 0.6),
            width: 2,
          ),
        ),
        color: color.withValues(alpha: 0.1),
      ),
      child: Stack(
        children: [
          // Línea central
          Center(
            child: Container(
              width: 2,
              height: height,
              color: color.withValues(alpha: 0.4),
            ),
          ),
          
          // Indicador de inicio
          if (isStart)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.8),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(2),
                    topRight: Radius.circular(2),
                  ),
                ),
              ),
            ),
          
          // Indicador de fin
          if (isEnd)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.8),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(2),
                    bottomRight: Radius.circular(2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
