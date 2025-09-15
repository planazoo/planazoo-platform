import 'package:flutter/material.dart';

class EventCellController {
  final String eventId;
  final VoidCallback? onResize;
  final VoidCallback? onMove;
  final VoidCallback? onDelete;

  EventCellController({
    required this.eventId,
    this.onResize,
    this.onMove,
    this.onDelete,
  });

  void notifyResize() {
    onResize?.call();
  }

  void notifyMove() {
    onMove?.call();
  }

  void notifyDelete() {
    onDelete?.call();
  }
  
  void notifyResizeAffects(Duration newDuration) {
    // Implementation for resize notification
  }
  
  void clearResizeAffects() {
    // Implementation for clearing resize affects
  }
}

