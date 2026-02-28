import 'package:flutter/material.dart';
import '../../../../app/theme/color_scheme.dart';
import '../../domain/services/plan_state_service.dart';
import '../../domain/models/plan.dart';

/// Diálogo de confirmación para cambiar el estado de un plan (T205: estilo estándar, mensaje de implicación).
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
    Color? actionColor;
    IconData titleIcon;

    switch (newState) {
      case 'confirmado':
        title = 'Confirmar Plan';
        actionColor = Colors.green;
        titleIcon = Icons.check_circle_outline;
        message = customMessage ??
            'Este plan quedará como confirmado. Los cambios importantes estarán bloqueados.\n\n'
                '¿Deseas continuar?';
        break;

      case 'en_curso':
        title = 'Marcar Plan como En Curso';
        actionColor = Colors.orange;
        titleIcon = Icons.play_circle_outline;
        message = customMessage ??
            'El plan pasará a estado "En Curso". Solo se permitirán cambios urgentes.\n\n'
                '¿Deseas continuar?';
        break;

      case 'finalizado':
        title = 'Finalizar Plan';
        actionColor = Colors.blueGrey;
        titleIcon = Icons.check_circle;
        message = customMessage ??
            'El plan pasará a estado "Finalizado". No se podrán realizar más cambios.\n\n'
                '¿Deseas continuar?';
        break;

      case 'cancelado':
        title = 'Cancelar Plan';
        actionColor = Colors.red;
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
        actionColor = Colors.blue;
        titleIcon = Icons.event_note;
        message = customMessage ??
            'El plan volverá a estado "Planificando". Se desbloquearán todas las restricciones.\n\n'
                '¿Deseas continuar?';
        break;

      default:
        title = 'Cambiar Estado del Plan';
        actionColor = Colors.grey;
        titleIcon = Icons.info_outline;
        message = customMessage ??
            '¿Deseas cambiar el estado del plan de "${currentInfo['label']}" a "${newInfo['label']}"?';
    }

    final implicationText = currentState == 'borrador' && newState != 'cancelado'
        ? 'Implicación: Al salir de borrador, el plan podrá ser compartido y las restricciones de edición dependerán del nuevo estado.'
        : null;

    return AlertDialog(
      title: null,
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF79A2A8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              children: [
                Icon(titleIcon, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                if (implicationText != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColorScheme.color2.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColorScheme.color2.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 18, color: AppColorScheme.color2),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            implicationText,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade200
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
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
            backgroundColor: actionColor,
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
