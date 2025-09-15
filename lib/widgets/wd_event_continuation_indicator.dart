import 'package:flutter/material.dart';

class EventContinuationIndicator extends StatelessWidget {
  final bool isContinuation;
  final VoidCallback? onTap;

  const EventContinuationIndicator({
    super.key,
    this.isContinuation = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isContinuation) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.more_horiz,
          color: Colors.white,
          size: 12,
        ),
      ),
    );
  }
}
