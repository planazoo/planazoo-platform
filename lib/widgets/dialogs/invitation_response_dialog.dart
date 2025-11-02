import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_participation_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';

/// Diálogo para que el usuario acepte o rechace una invitación a un plan
class InvitationResponseDialog extends ConsumerStatefulWidget {
  final Plan plan;

  const InvitationResponseDialog({
    super.key,
    required this.plan,
  });

  @override
  ConsumerState<InvitationResponseDialog> createState() => _InvitationResponseDialogState();
}

class _InvitationResponseDialogState extends ConsumerState<InvitationResponseDialog> {
  bool _isProcessing = false;

  Future<void> _respondToInvitation(bool accept) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Usuario no autenticado'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final participationService = ref.read(planParticipationServiceProvider);
      final success = accept
          ? await participationService.acceptInvitation(widget.plan.id!, currentUser.id)
          : await participationService.rejectInvitation(widget.plan.id!, currentUser.id);

      if (mounted) {
        Navigator.of(context).pop(); // Cerrar diálogo
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(accept ? '✅ Has aceptado la invitación' : 'Has rechazado la invitación'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Error al responder a la invitación'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.error('Error responding to invitation', context: 'INVITATION_RESPONSE_DIALOG', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Invitación al Plan',
        style: AppTypography.mediumTitle.copyWith(color: AppColorScheme.color4),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Asistes al plan',
            style: AppTypography.bodyStyle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColorScheme.color1.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColorScheme.color2, width: 1),
            ),
            child: Text(
              widget.plan.name,
              style: AppTypography.bodyStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColorScheme.color4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '?',
            style: AppTypography.bodyStyle.copyWith(fontSize: 24),
          ),
        ],
      ),
      actions: [
        // Botón rechazar
        TextButton(
          onPressed: _isProcessing ? null : () => _respondToInvitation(false),
          child: Text(
            'No puedo asistir',
            style: AppTypography.bodyStyle.copyWith(color: Colors.red),
          ),
        ),
        // Botón aceptar
        ElevatedButton(
          onPressed: _isProcessing ? null : () => _respondToInvitation(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColorScheme.color3,
            foregroundColor: Colors.white,
          ),
          child: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Sí, asistiré'),
        ),
      ],
    );
  }
}

