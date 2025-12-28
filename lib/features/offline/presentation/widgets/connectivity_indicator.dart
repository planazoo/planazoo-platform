import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connectivity_providers.dart';

/// Widget que muestra un indicador visual del estado de conectividad
/// 
/// Muestra un banner en la parte superior cuando está offline.
class ConnectivityIndicator extends ConsumerWidget {
  const ConnectivityIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    // Si está online, no mostrar nada
    if (isOnline) {
      return const SizedBox.shrink();
    }

    // Si está offline, mostrar banner
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.shade700,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Sin conexión - Modo offline activo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget que muestra un pequeño indicador de estado en la esquina
class ConnectivityBadge extends ConsumerWidget {
  final double? size;
  
  const ConnectivityBadge({super.key, this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return Container(
      width: size ?? 12,
      height: size ?? 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOnline ? Colors.green : Colors.orange,
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
      ),
    );
  }
}

