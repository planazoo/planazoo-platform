import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/calendar_state.dart';

/// Widget que muestra diferentes estados de carga del calendario
class CalendarLoadingStates extends ConsumerWidget {
  final CalendarState state;
  final Widget child;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyStateWidget;

  const CalendarLoadingStates({
    super.key,
    required this.state,
    required this.child,
    this.loadingWidget,
    this.errorWidget,
    this.emptyStateWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Si hay un error, mostrar widget de error
    if (state.hasError) {
      return errorWidget ?? _buildDefaultErrorWidget(context);
    }

    // Si está cargando, mostrar widget de carga
    if (state.isLoading) {
      return loadingWidget ?? _buildDefaultLoadingWidget(context);
    }

    // 🚀 MODIFICACIÓN: Para planes recién creados, siempre mostrar el calendario
    // No mostrar estado vacío, sino el calendario funcional aunque no tenga eventos
    // Esto permite que el usuario pueda crear eventos inmediatamente
    
    // Si todo está bien, mostrar el contenido (incluyendo calendario vacío pero funcional)
    return child;
  }

  /// Widget de carga por defecto
  Widget _buildDefaultLoadingWidget(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Indicador de carga principal
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Título de carga
            Text(
              'Cargando Calendario',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Mensaje descriptivo
            Text(
              'Sincronizando eventos y configuraciones...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            
            // Indicadores de progreso
            _buildProgressIndicators(context),
          ],
        ),
      ),
    );
  }

  /// Construir indicadores de progreso
  Widget _buildProgressIndicators(BuildContext context) {
    return Column(
      children: [
        _buildProgressStep(
          context,
          'Conectando con la base de datos',
          Icons.cloud_sync,
          true,
        ),
        const SizedBox(height: 12),
        _buildProgressStep(
          context,
          'Cargando eventos del plan',
          Icons.event,
          state.events.isNotEmpty,
        ),
        const SizedBox(height: 12),
        _buildProgressStep(
          context,
          'Preparando interfaz',
          Icons.dashboard,
          !state.isLoading && state.events.isNotEmpty,
        ),
      ],
    );
  }

  /// Construir paso de progreso individual
  Widget _buildProgressStep(
    BuildContext context,
    String text,
    IconData icon,
    bool isCompleted,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? Colors.green : Colors.grey.shade400,
          size: 20,
        ),
        const SizedBox(width: 12),
        Icon(
          icon,
          color: isCompleted ? Colors.green : Colors.grey.shade400,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isCompleted ? Colors.green : Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// Widget de error por defecto
  Widget _buildDefaultErrorWidget(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono de error
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 24),
              
              // Título del error
              Text(
                'Error al Cargar',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 16),
              
              // Mensaje del error
              Text(
                state.errorMessage ?? 'Error desconocido',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 32),
              
              // Información adicional
              _buildErrorInfo(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Construir información del error
  Widget _buildErrorInfo(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Información del Error',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Estado: ${state.loadingState.name}',
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 14,
              ),
            ),
            if (state.lastSyncTime != null) ...[
              const SizedBox(height: 4),
              Text(
                'Última sincronización: ${_formatDateTime(state.lastSyncTime!)}',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Widget de estado vacío por defecto
  Widget _buildDefaultEmptyStateWidget(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono de calendario vacío
              Icon(
                Icons.calendar_today_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              
              // Título del estado vacío
              Text(
                'Calendario Vacío',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              
              // Mensaje descriptivo
              Text(
                'No hay eventos programados para esta fecha.\n¡Comienza creando tu primer evento!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              
              // Botón de acción
              ElevatedButton.icon(
                onPressed: () {
                  // Aquí podrías implementar la lógica para crear un evento
                },
                icon: const Icon(Icons.add),
                label: const Text('Crear Primer Evento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formatear fecha y hora
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Widget que envuelve el calendario con manejo de estados de carga
class CalendarWithLoadingStates extends ConsumerWidget {
  final CalendarState state;
  final Widget child;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyStateWidget;

  const CalendarWithLoadingStates({
    super.key,
    required this.state,
    required this.child,
    this.loadingWidget,
    this.errorWidget,
    this.emptyStateWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CalendarLoadingStates(
      state: state,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
      emptyStateWidget: emptyStateWidget,
      child: child,
    );
  }
}
