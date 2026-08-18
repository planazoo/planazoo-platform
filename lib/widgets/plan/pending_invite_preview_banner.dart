import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/invitation_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/notifications/presentation/providers/notification_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';

/// Banner fijo (T276 / §1.5): preview pending con aceptar / rechazar / decidir más tarde.
class PendingInvitePreviewBanner extends ConsumerStatefulWidget {
  final Plan plan;

  /// Tras rechazar (o invitación inválida): salir del detalle del plan.
  final VoidCallback? onLeftPlan;

  const PendingInvitePreviewBanner({
    super.key,
    required this.plan,
    this.onLeftPlan,
  });

  @override
  ConsumerState<PendingInvitePreviewBanner> createState() =>
      _PendingInvitePreviewBannerState();
}

class _PendingInvitePreviewBannerState
    extends ConsumerState<PendingInvitePreviewBanner> {
  bool _isProcessing = false;
  bool _collapsed = false;

  Future<void> _respond(bool accept) async {
    final loc = AppLocalizations.of(context)!;
    final currentUser = ref.read(currentUserProvider);
    final planId = widget.plan.id;
    if (currentUser == null || planId == null || _isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final invitationService = ref.read(invitationServiceProvider);
      final recheck = await invitationService.evaluateInvitationActionability(
        planId: planId,
        userId: currentUser.id,
        cleanupIfInvalid: true,
      );
      if (!recheck.actionable) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(recheck.message),
            backgroundColor: Colors.orange.shade700,
          ),
        );
        widget.onLeftPlan?.call();
        return;
      }

      final result = accept
          ? await invitationService.acceptInvitationByPlanId(
              planId,
              currentUser.id,
            )
          : await invitationService.rejectInvitationByPlanId(
              planId,
              currentUser.id,
            );

      ref.invalidate(userPendingInvitationsProvider);
      ref.invalidate(planParticipantsProvider(planId));
      ref.invalidate(plansStreamProvider);
      ref.invalidate(globalNotificationsListProvider);
      ref.invalidate(globalUnreadCountProvider);
      try {
        ref.read(planParticipationNotifierProvider(planId).notifier).reload();
      } catch (_) {}

      if (!mounted) return;
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
          backgroundColor:
              result.success ? AppColorScheme.color2 : Colors.redAccent,
        ),
      );

      if (result.success && !accept) {
        widget.onLeftPlan?.call();
      }
    } catch (e) {
      LoggerService.error(
        'Error responding to invitation from preview banner',
        context: 'PENDING_INVITE_PREVIEW_BANNER',
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
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _decideLater() {
    if (_isProcessing) return;
    setState(() => _collapsed = true);
    final loc = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.pendingInvitePreviewDecideLaterHint),
        backgroundColor: const Color(0xFF1F2937),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (_collapsed) {
      return Material(
        color: AppColorScheme.color2.withValues(alpha: 0.25),
        child: InkWell(
          onTap: () => setState(() => _collapsed = false),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.mail_outline, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    loc.pendingInvitePreviewBannerMessage,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.expand_more, color: Colors.white70, size: 20),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 3, color: AppColorScheme.color2),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.mark_email_unread_outlined,
                      color: AppColorScheme.color2,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        loc.pendingInvitePreviewBannerMessage,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _isProcessing ? null : () => _respond(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColorScheme.color2,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          loc.invitationAcceptButton,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _isProcessing ? null : () => _respond(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    loc.invitationRejectButton,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _isProcessing ? null : _decideLater,
                  child: Text(
                    loc.invitationDecideLater,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
