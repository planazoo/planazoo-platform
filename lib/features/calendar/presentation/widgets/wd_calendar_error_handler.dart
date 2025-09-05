import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/calendar_state.dart';

/// Widget que maneja errores del calendario de manera elegante
class CalendarErrorHandler extends ConsumerWidget {
  final Widget child;
  final CalendarState state;
  final VoidCallback? onRetry;
  final VoidCallback? onClearError;
  final Widget? fallbackWidget;

  const CalendarErrorHandler({
    super.key,
    required this.child,
    required this.state,
    this.onRetry,
    this.onClearError,
    this.fallbackWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Si no hay error, mostrar el widget normal
    if (!state.hasError) {
      return child;
    }

    // Si hay un error pero estamos cargando (retry automático), mostrar loading
    if (state.loadingState == LoadingState.loading) {
      return _buildLoadingState();
    }

    // Si hay un error y operaciones pendientes, mostrar estado de operaciones
    if (state.hasPendingOperations) {
      return _buildPendingOperationsState(context);
    }

    // Mostrar error con opciones de retry
    return _buildErrorState(context);
  }

  /// Construir estado de carga
  Widget _buildLoadingState() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando...'),
          ],
        ),
      ),
    );
  }

  /// Construir estado de operaciones pendientes
  Widget _buildPendingOperationsState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operaciones Pendientes'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Operaciones Pendientes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hay ${state.pendingOperations.length} operación(es) que no se pudieron completar.',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: state.pendingOperations.length,
                itemBuilder: (context, index) {
                  final operationId = state.pendingOperations.keys.elementAt(index);
                  final operation = state.pendingOperations[operationId]!;
                  
                  return _buildPendingOperationCard(context, operationId, operation);
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onClearError,
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar Todas las Operaciones'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construir tarjeta de operación pendiente
  Widget _buildPendingOperationCard(
    BuildContext context, 
    String operationId, 
    Map<String, dynamic> operation
  ) {
    final type = operation['type'] as String;
    String title;
    String description;
    IconData icon;

    switch (type) {
      case 'create':
        title = 'Crear Evento';
        description = 'Evento: ${operation['event']?.description ?? 'N/A'}';
        icon = Icons.add_circle;
        break;
      case 'update':
        title = 'Actualizar Evento';
        description = 'Evento: ${operation['event']?.description ?? 'N/A'}';
        icon = Icons.edit;
        break;
      case 'delete':
        title = 'Eliminar Evento';
        description = 'ID: ${operation['eventId'] ?? 'N/A'}';
        icon = Icons.delete;
        break;
      case 'move':
        title = 'Mover Evento';
        description = 'Evento: ${operation['event']?.description ?? 'N/A'}';
        icon = Icons.drag_indicator;
        break;
              case 'resize':
          title = 'Redimensionar Evento';
          description = 'Evento: ${operation['event']?.description ?? 'N/A'}';
          icon = Icons.aspect_ratio;
          break;
      default:
        title = 'Operación Desconocida';
        description = 'Tipo: $type';
        icon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(description),
        trailing: ElevatedButton(
          onPressed: () => _retryOperation(context, operationId),
          child: const Text('Reintentar'),
        ),
      ),
    );
  }

  /// Reintentar operación
  void _retryOperation(BuildContext context, String operationId) {
    if (onRetry != null) {
      onRetry!();
    }
  }

  /// Construir estado de error
  Widget _buildErrorState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error del Calendario'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          if (onClearError != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClearError,
              tooltip: 'Cerrar Error',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              'Algo salió mal',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
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
            
            // Botón de reintentar
            if (onRetry != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Botón de fallback
            if (fallbackWidget != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Aquí podrías implementar lógica para mostrar el fallback
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Ver Vista Alternativa'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Información adicional
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Información del Error',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Estado: ${state.loadingState.name}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (state.lastSyncTime != null)
                      Text(
                        'Última sincronización: ${_formatDateTime(state.lastSyncTime!)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formatear fecha y hora
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Widget que envuelve el calendario con manejo de errores
class CalendarWithErrorHandling extends ConsumerWidget {
  final Widget child;
  final CalendarState state;
  final VoidCallback? onRetry;
  final VoidCallback? onClearError;
  final Widget? fallbackWidget;

  const CalendarWithErrorHandling({
    super.key,
    required this.child,
    required this.state,
    this.onRetry,
    this.onClearError,
    this.fallbackWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CalendarErrorHandler(
      state: state,
      onRetry: onRetry,
      onClearError: onClearError,
      fallbackWidget: fallbackWidget,
      child: child,
    );
  }
}
