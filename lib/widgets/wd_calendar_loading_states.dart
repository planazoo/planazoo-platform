import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/calendar_state.dart';

/// Widget que muestra diferentes estados de carga del calendario
class CalendarLoadingStates extends ConsumerWidget {
  final CalendarState state;
  final Widget child;

  const CalendarLoadingStates({
    super.key,
    required this.state,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (state.loadingState) {
      LoadingState.loading => const Center(
          child: CircularProgressIndicator(),
        ),
      LoadingState.idle => const SizedBox.shrink(),
      LoadingState.error => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${state.errorMessage ?? 'Unknown error'}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Retry logic
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      LoadingState.success => child,
    };
  }
}