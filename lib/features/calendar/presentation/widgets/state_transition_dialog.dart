import 'package:flutter/material.dart';
import '../../domain/services/plan_state_service.dart';
import '../../domain/models/plan.dart';

/// Diálogo de confirmación para cambiar el estado de un plan
/// 
/// Muestra información sobre la transición y solicita confirmación del usuario.
class StateTransitionDialog extends StatelessWidget {
  final Plan plan;
  final String newState;
  final String? customMessage;

  const StateTransitionDialog({
    super.key,
    required this.plan,
    required this.newState,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final currentState = plan.state ?? 'borrador';
    final currentInfo = PlanStateService.getStateDisplayInfo(currentState);
    final newInfo = PlanStateService.getStateDisplayInfo(newState);

    // Mensajes según la transición
    String title;
    String message;
    Color? titleColor;
    IconData titleIcon;

    switch (newState) {
      case 'confirmado':
        title = 'Confirmar Plan';
        titleColor = Colors.green;
        titleIcon = Icons.check_circle_outline;
        message = customMessage ??
            'Este plan quedará como confirmado. Los cambios importantes estarán bloqueados.\n\n'
                '¿Deseas continuar?';
        break;

      case 'en_curso':
        title = 'Marcar Plan como En Curso';
        titleColor = Colors.orange;
        titleIcon = Icons.play_circle_outline;
        message = customMessage ??
            'El plan pasará a estado "En Curso". Solo se permitirán cambios urgentes.\n\n'
                '¿Deseas continuar?';
        break;

      case 'finalizado':
        title = 'Finalizar Plan';
        titleColor = Colors.blueGrey;
        titleIcon = Icons.check_circle;
        message = customMessage ??
            'El plan pasará a estado "Finalizado". No se podrán realizar más cambios.\n\n'
                '¿Deseas continuar?';
        break;

      case 'cancelado':
        title = 'Cancelar Plan';
        titleColor = Colors.red;
        titleIcon = Icons.cancel_outlined;
        message = customMessage ??
            '⚠️ ADVERTENCIA:\n\n'
                '• Todos los participantes serán notificados\n'
                '• El plan no se podrá reactivar\n'
                '• Se cancelarán todos los eventos futuros\n\n'
                '¿Estás seguro de que deseas cancelar este plan?';
        break;

      case 'planificando':
        title = 'Volver a Planificación';
        titleColor = Colors.blue;
        titleIcon = Icons.event_note;
        message = customMessage ??
            'El plan volverá a estado "Planificando". Se desbloquearán todas las restricciones.\n\n'
                '¿Deseas continuar?';
        break;

      default:
        title = 'Cambiar Estado del Plan';
        titleColor = Colors.grey;
        titleIcon = Icons.info_outline;
        message = customMessage ??
            '¿Deseas cambiar el estado del plan de "${currentInfo['label']}" a "${newInfo['label']}"?';
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(titleIcon, color: titleColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges de estado actual y nuevo
          Row(
            children: [
              _buildStateChip(currentInfo['label'] as String,
                  Color(currentInfo['color'] as int)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, size: 20),
              ),
              _buildStateChip(
                  newInfo['label'] as String, Color(newInfo['color'] as int)),
            ],
          ),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: titleColor,
            foregroundColor: Colors.white,
          ),
          child: Text(title.contains('Cancelar') ? 'Cancelar Plan' : 'Confirmar'),
        ),
      ],
    );
  }

  Widget _buildStateChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Muestra el diálogo de confirmación y retorna true si el usuario confirma
Future<bool> showStateTransitionDialog({
  required BuildContext context,
  required Plan plan,
  required String newState,
  String? customMessage,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => StateTransitionDialog(
      plan: plan,
      newState: newState,
      customMessage: customMessage,
    ),
  );
  return result ?? false;
}

