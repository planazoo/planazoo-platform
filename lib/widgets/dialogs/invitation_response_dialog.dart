import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/invitation_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/invitation_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/notifications/presentation/providers/notification_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';

/// Diálogo para que el usuario acepte, rechace o posponga una invitación.
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
  static const Color _pageBg = Color(0xFF111827);
  static const Color _surface = Color(0xFF1F2937);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Colors.white70;
  static const double _aBorder = 0.12;

  bool _isProcessing = false;
  bool _loadingCheck = true;
  InvitationActionabilityResult? _check;
  String? _inviterDisplayName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runActionabilityCheck());
  }

  Future<void> _runActionabilityCheck() async {
    final currentUser = ref.read(currentUserProvider);
    final planId = widget.plan.id;
    final loc = AppLocalizations.of(context)!;
    if (currentUser == null || planId == null) {
      if (!mounted) return;
      setState(() {
        _loadingCheck = false;
        _check = InvitationActionabilityResult(
          actionable: false,
          code: 'I',
          message: loc.invitationNotFound,
        );
      });
      return;
    }

    final invitationService = ref.read(invitationServiceProvider);
    final result = await invitationService.evaluateInvitationActionability(
      planId: planId,
      userId: currentUser.id,
    );

    String? inviterName;
    if (result.actionable) {
      inviterName = await _resolveInviterName(
        planId: planId,
        userId: currentUser.id,
        email: currentUser.email,
        fallbackSomeone: loc.invitationSomeone,
      );
    }

    if (!mounted) return;
    setState(() {
      _loadingCheck = false;
      _check = result;
      _inviterDisplayName = inviterName;
    });
  }

  Future<String> _resolveInviterName({
    required String planId,
    required String userId,
    required String? email,
    required String fallbackSomeone,
  }) async {
    try {
      String? inviterId;
      final participation = await ref
          .read(planParticipationServiceProvider)
          .getParticipation(planId, userId);
      inviterId = participation?.invitedBy;

      if ((inviterId == null || inviterId.isEmpty) &&
          email != null &&
          email.isNotEmpty) {
        final invitation = await ref
            .read(invitationServiceProvider)
            .getPendingInvitationByEmail(planId, email);
        inviterId = invitation?.invitedBy;
      }

      if (inviterId == null || inviterId.isEmpty) {
        inviterId = widget.plan.userId;
      }

      if (inviterId.isEmpty) return fallbackSomeone;

      final inviter = await ref.read(userServiceProvider).getUser(inviterId);
      if (inviter == null) return fallbackSomeone;

      final display = inviter.displayName?.trim();
      if (display != null && display.isNotEmpty) return display;
      final username = inviter.username?.trim();
      if (username != null && username.isNotEmpty) return username;
      if (inviter.email.isNotEmpty) return inviter.email;
      return fallbackSomeone;
    } catch (e) {
      LoggerService.error(
        'Error resolving inviter name',
        context: 'INVITATION_RESPONSE_DIALOG',
        error: e,
      );
      return fallbackSomeone;
    }
  }

  void _decideLater() {
    if (_isProcessing) return;
    Navigator.of(context).pop();
  }

  Future<void> _respondToInvitation(bool accept) async {
    final loc = AppLocalizations.of(context)!;
    setState(() {
      _isProcessing = true;
    });

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.invitationNotAuthenticated),
              backgroundColor: Colors.redAccent,
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
        final planId = widget.plan.id;
        if (planId != null) {
          ref.invalidate(userPendingInvitationsProvider);
          ref.invalidate(planParticipantsProvider(planId));
          ref.invalidate(plansStreamProvider);
          ref.invalidate(globalNotificationsListProvider);
          ref.invalidate(globalUnreadCountProvider);
          try {
            ref.read(planParticipationNotifierProvider(planId).notifier).reload();
          } catch (_) {}
        }
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success
                  ? (accept
                      ? loc.invitationAcceptedParticipant
                      : loc.invitationRejected)
                  : (accept
                      ? loc.invitationAcceptFailed
                      : loc.invitationRejectFailed),
            ),
            backgroundColor: result.success ? AppColorScheme.color2 : Colors.redAccent,
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
            content: Text(loc.invitationAcceptError),
            backgroundColor: Colors.redAccent,
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
    final loc = AppLocalizations.of(context)!;

    if (_loadingCheck) {
      return Dialog(
        backgroundColor: _pageBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: _aBorder)),
        ),
        child: const SizedBox(
          height: 120,
          width: 280,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final check = _check;
    if (check == null || !check.actionable) {
      return _InvitationShell(
        title: loc.invitationUnavailableTitle,
        pageBg: _pageBg,
        surface: _surface,
        aBorder: _aBorder,
        onClose: () => Navigator.of(context).pop(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              check?.message ?? loc.invitationNotFound,
              style: GoogleFonts.poppins(fontSize: 14, color: _textSecondary),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColorScheme.color2,
                foregroundColor: _textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                loc.understood,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    final inviter = _inviterDisplayName ?? loc.invitationSomeone;
    final start = DateFormatter.formatDate(widget.plan.startDate);
    final end = DateFormatter.formatDate(widget.plan.endDate);
    final body = loc.invitationInviteMessage(
      inviter,
      widget.plan.name,
      start,
      end,
    );

    return _InvitationShell(
      title: loc.invitationTitle,
      pageBg: _pageBg,
      surface: _surface,
      aBorder: _aBorder,
      onClose: _isProcessing ? null : _decideLater,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            body,
            style: GoogleFonts.poppins(
              fontSize: 15,
              height: 1.45,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isProcessing ? null : () => _respondToInvitation(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColorScheme.color2,
              foregroundColor: _textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    loc.invitationAcceptButton,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _isProcessing ? null : () => _respondToInvitation(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              loc.invitationRejectButton,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: _isProcessing ? null : _decideLater,
            child: Text(
              loc.invitationDecideLater,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvitationShell extends StatelessWidget {
  const _InvitationShell({
    required this.title,
    required this.child,
    required this.pageBg,
    required this.surface,
    required this.aBorder,
    this.onClose,
  });

  final String title;
  final Widget child;
  final Color pageBg;
  final Color surface;
  final double aBorder;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: pageBg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: aBorder)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barra superior verde (estándar modales T226)
            Container(
              width: double.infinity,
              color: AppColorScheme.color2,
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (onClose != null)
                    IconButton(
                      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                      onPressed: onClose,
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: surface.withValues(alpha: 0.35),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
