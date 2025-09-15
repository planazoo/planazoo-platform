import 'package:flutter/material.dart';

class IOSSimulator extends StatelessWidget {
  final Widget child;
  final String title;

  const IOSSimulator({
    super.key,
    required this.child,
    this.title = 'iOS Simulator',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status bar
          Container(
            height: 30,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('9:41', style: TextStyle(color: Colors.white)),
                Row(
                  children: [
                    Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 16),
                    Icon(Icons.wifi, color: Colors.white, size: 16),
                    Icon(Icons.battery_full, color: Colors.white, size: 16),
                  ],
                ),
              ],
            ),
          ),
          // Screen content
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}