import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/invitation_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/invitation_providers.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';

/// Diálogo para que el usuario acepte o rechace una invitación a un plan.
/// Antes de mostrar acciones, valida §1.2 (sigue accionable).
class InvitationResponseDialog extends ConsumerStatefulWidget {
  final Plan plan;

  const InvitationResponseDialog({
    super.key,
    required this.plan,
  });

  @override
  ConsumerState<InvitationResponseDialog> createState() =>
      _InvitationResponseDialogState();
}

class _InvitationResponseDialogState
    extends ConsumerState<InvitationResponseDialog> {
  bool _isProcessing = false;
  bool _loadingCheck = true;
  InvitationActionabilityResult? _check;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runActionabilityCheck());
  }

  Future<void> _runActionabilityCheck() async {
    final currentUser = ref.read(currentUserProvider);
    final planId = widget.plan.id;
    if (currentUser == null || planId == null) {
      if (!mounted) return;
      setState(() {
        _loadingCheck = false;
        _check = const InvitationActionabilityResult(
          actionable: false,
          code: 'I',
          message: 'Esta invitación ya no está disponible',
        );
      });
      return;
    }
    final result = await ref.read(invitationServiceProvider).evaluateInvitationActionability(
          planId: planId,
          userId: currentUser.id,
        );
    if (!mounted) return;
    setState(() {
      _loadingCheck = false;
      _check = result;
    });
  }

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

      final invitationService = ref.read(invitationServiceProvider);
      // Revalidar antes de confirmar (casos P/Q del diagrama).
      final recheck = await invitationService.evaluateInvitationActionability(
        planId: widget.plan.id!,
        userId: currentUser.id,
        cleanupIfInvalid: true,
      );
      if (!recheck.actionable) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(recheck.message),
              backgroundColor: Colors.orange.shade700,
            ),
          );
        }
        return;
      }

      final result = accept
          ? await invitationService.acceptInvitationByPlanId(
              widget.plan.id!,
              currentUser.id,
            )
          : await invitationService.rejectInvitationByPlanId(
              widget.plan.id!,
              currentUser.id,
            );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success
                  ? (accept ? '✅ ${result.message}' : result.message)
                  : '❌ ${result.message}',
            ),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      LoggerService.error(
        'Error responding to invitation',
        context: 'INVITATION_RESPONSE_DIALOG',
        error: e,
      );
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
    if (_loadingCheck) {
      return const AlertDialog(
        content: SizedBox(
          height: 72,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final check = _check;
    if (check == null || !check.actionable) {
      return AlertDialog(
        title: Text(
          'Invitación no disponible',
          style: AppTypography.mediumTitle.copyWith(color: AppColorScheme.color4),
        ),
        content: Text(
          check?.message ?? 'Esta invitación ya no está disponible',
          style: AppTypography.bodyStyle.copyWith(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorScheme.color3,
              foregroundColor: Colors.white,
            ),
            child: const Text('Entendido'),
          ),
        ],
      );
    }

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
              color: AppColorScheme.color1.withValues(alpha: 0.1),
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
        TextButton(
          onPressed: _isProcessing ? null : () => _respondToInvitation(false),
          child: Text(
            'No puedo asistir',
            style: AppTypography.bodyStyle.copyWith(color: Colors.red),
          ),
        ),
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
