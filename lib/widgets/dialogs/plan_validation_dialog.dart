import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../shared/utils/plan_validation_utils.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/color_scheme.dart';

/// VALID-1, VALID-2: Diálogo para mostrar validaciones del plan antes de confirmar
class PlanValidationDialog extends StatelessWidget {
  final PlanValidationUtils validation;
  final List<String> participantNames; // Nombres de participantes sin eventos (opcional)

  const PlanValidationDialog({
    super.key,
    required this.validation,
    this.participantNames = const [],
  });

  @override
  Widget build(BuildContext context) {
    // Si no hay warnings ni errors, no mostrar nada
    if (validation.warnings.isEmpty && validation.errors.isEmpty) {
      return const SizedBox.shrink();
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            validation.errors.isNotEmpty ? Icons.error : Icons.warning_amber,
            color: validation.errors.isNotEmpty ? Colors.red : Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              validation.errors.isNotEmpty
                  ? 'Error en la Validación'
                  : 'Revisar Plan',
              style: TextStyle(
                color: validation.errors.isNotEmpty ? Colors.red : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              validation.errors.isNotEmpty
                  ? 'No se puede confirmar el plan debido a los siguientes errores:'
                  : 'Se han detectado las siguientes observaciones:',
              style: AppTypography.bodyStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Errores
            if (validation.errors.isNotEmpty) ...[
              ...validation.errors.map((error) => _buildValidationItem(
                error,
                Colors.red,
                Icons.error_outline,
              )),
              const SizedBox(height: 16),
            ],
            
            // Warnings
            if (validation.warnings.isNotEmpty) ...[
              if (validation.errors.isEmpty)
                Text(
                  'Aunque el plan puede confirmarse, te recomendamos revisar:',
                  style: AppTypography.bodyStyle.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              const SizedBox(height: 8),
              ...validation.warnings.map((warning) => _buildValidationItem(
                warning,
                Colors.orange,
                Icons.info_outline,
              )),
            ],
            
            const SizedBox(height: 16),
            
            // Nota informativa
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.help_outline, size: 20, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      validation.errors.isNotEmpty
                          ? 'Corrige los errores antes de poder confirmar el plan.'
                          : 'Puedes continuar con la confirmación o volver a revisar el plan.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (validation.errors.isEmpty) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Volver'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar de todas formas'),
          ),
        ] else ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cerrar'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildValidationItem(String text, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyStyle.copyWith(
                color: AppColorScheme.color4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Muestra el diálogo de validaciones y retorna true si el usuario quiere continuar
Future<bool?> showPlanValidationDialog({
  required BuildContext context,
  required PlanValidationUtils validation,
  List<String> participantNames = const [],
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => PlanValidationDialog(
      validation: validation,
      participantNames: participantNames,
    ),
  );
  return result;
}

