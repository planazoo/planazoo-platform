import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/features/auth/presentation/pages/login_page.dart';
import 'package:unp_calendario/features/auth/presentation/pages/register_page.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_invitation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/invitation_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/pages/pg_plan_detail_page.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/shared/utils/platform_utils.dart';

/// Página pública del deep link `/invitation/{token}` (diagrama §2 + §1.2 J/K).
class InvitationPage extends ConsumerStatefulWidget {
  final String token;
  /// Desde el email: `accept` | `reject` (opcional).
  final String? initialAction;

  const InvitationPage({
    super.key,
    required this.token,
    this.initialAction,
  });

  @override
  ConsumerState<InvitationPage> createState() => _InvitationPageState();
}

class _InvitationPageState extends ConsumerState<InvitationPage> {
  bool _isProcessing = false;
  bool _didHandleInitialAction = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final invitationAsync = ref.watch(invitationByTokenProvider(widget.token));
    final currentUser = ref.watch(currentUserProvider);

    ref.listen(currentUserProvider, (prev, next) {
      if (prev == null && next != null && mounted) {
        // Volver desde Login/Register empujados sobre esta página.
        Navigator.of(context).popUntil((route) => route.isFirst);
        ref.invalidate(invitationByTokenProvider(widget.token));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.invitationTitle),
      ),
      body: invitationAsync.when(
        data: (invitation) {
          if (invitation == null) {
            if (currentUser == null) {
              return _buildNeedAuth(context, loc, missingInvite: true);
            }
            return _buildError(context, loc.invitationNotFound);
          }

          if (invitation.isExpired || invitation.status == 'expired') {
            return _buildError(context, loc.invitationExpired);
          }
          if (invitation.isAccepted) {
            return _buildSuccess(context, loc.invitationAlreadyAccepted);
          }
          if (invitation.isRejected) {
            return _buildError(context, loc.invitationAlreadyRejected);
          }
          if (invitation.status == 'cancelled') {
            return _buildError(
              context,
              'El organizador canceló la invitación',
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _maybeRunInitialAction(invitation, currentUser?.id);
          });

          return _buildInvitationDetails(context, invitation);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          LoggerService.error(
            'Error loading invitation: ${widget.token}',
            context: 'INVITATION_PAGE',
            error: error,
          );
          return _buildError(context, loc.invitationLoadError(error.toString()));
        },
      ),
    );
  }

  Future<void> _maybeRunInitialAction(
    PlanInvitation invitation,
    String? userId,
  ) async {
    if (_didHandleInitialAction || _isProcessing) return;
    final action = widget.initialAction?.toLowerCase().trim();
    if (action != 'accept' && action != 'reject') return;
    if (userId == null) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;
    if (currentUser.email.toLowerCase().trim() !=
        invitation.email.toLowerCase().trim()) {
      return;
    }

    _didHandleInitialAction = true;
    if (action == 'accept') {
      await _acceptInvitation(invitation, userId);
    } else {
      await _rejectInvitation(invitation, userId, skipConfirm: true);
    }
  }

  Widget _buildInvitationDetails(BuildContext context, PlanInvitation invitation) {
    final loc = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);
    final planAsync = ref.watch(planByIdProvider(invitation.planId));

    return planAsync.when(
      data: (plan) {
        if (plan == null) {
          return _buildError(context, loc.invitationNotFound);
        }

        final emailMatches = currentUser != null &&
            currentUser.email.toLowerCase().trim() ==
                invitation.email.toLowerCase().trim();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColorScheme.color3.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColorScheme.color3.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.mail_outline,
                      size: 64,
                      color: AppColorScheme.color3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.invitationYouHaveBeenInvited,
                      style: AppTypography.titleStyle.copyWith(
                        color: AppColorScheme.color3,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.invitationInvitedToJoinPlan,
                      style: AppTypography.bodyStyle.copyWith(
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.invitationPlanDetails,
                        style: AppTypography.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(Icons.title, loc.invitationLabelName, plan.name),
                      if (plan.description != null && plan.description!.isNotEmpty)
                        _buildDetailRow(
                          Icons.description,
                          loc.invitationLabelDescription,
                          plan.description!,
                        ),
                      _buildDetailRow(
                        Icons.calendar_today,
                        loc.invitationLabelStartDate,
                        _formatDate(plan.startDate),
                      ),
                      _buildDetailRow(
                        Icons.calendar_today,
                        loc.invitationLabelEndDate,
                        _formatDate(plan.endDate),
                      ),
                      _buildDetailRow(
                        Icons.email,
                        loc.invitationLabelInvitedEmail,
                        invitation.email,
                      ),
                    ],
                  ),
                ),
              ),
              if (invitation.customMessage != null &&
                  invitation.customMessage!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.message, size: 20, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              loc.invitationCustomMessage,
                              style: AppTypography.bodyStyle.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          invitation.customMessage!,
                          style: AppTypography.bodyStyle.copyWith(
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (currentUser == null)
                _buildNeedAuth(context, loc)
              else if (!emailMatches) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange.shade700, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          loc.invitationWrongUserWarning(
                            invitation.email,
                            currentUser.email,
                          ),
                          style: TextStyle(color: Colors.orange.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else
                _buildActionButtons(context, invitation, currentUser.id),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.invitationExpiresOn(_formatDate(invitation.expiresAt)),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          _buildError(context, loc.invitationLoadError(error.toString())),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTypography.bodyStyle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedAuth(
    BuildContext context,
    AppLocalizations loc, {
    bool missingInvite = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (missingInvite) ...[
            Text(
              loc.invitationLoginToAccept,
              style: AppTypography.titleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.login, size: 32, color: Colors.blue.shade700),
                const SizedBox(height: 12),
                Text(
                  loc.invitationLoginToAccept,
                  style: AppTypography.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.invitationNeedAccount,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.login),
            label: Text(loc.invitationLoginButton),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorScheme.color3,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const RegisterPage()),
              );
            },
            child: Text(loc.invitationCreateAccount),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    PlanInvitation invitation,
    String userId,
  ) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _isProcessing ? null : () => _acceptInvitation(invitation, userId),
          icon: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check_circle),
          label: Text(
            _isProcessing ? loc.invitationProcessing : loc.invitationAcceptButton,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isProcessing
              ? null
              : () => _rejectInvitation(invitation, userId),
          icon: const Icon(Icons.cancel),
          label: Text(loc.invitationRejectButton),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
      ],
    );
  }

  Future<void> _acceptInvitation(PlanInvitation invitation, String userId) async {
    setState(() => _isProcessing = true);
    try {
      final result = await ref.read(invitationServiceProvider).acceptInvitationByToken(
            widget.token,
            userId,
          );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.success
                ? AppLocalizations.of(context)!.invitationAcceptSuccess
                : result.message,
          ),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );

      if (!result.success) return;

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      final plan = await ref.read(planByIdProvider(invitation.planId).future);
      if (!mounted) return;
      if (plan != null && PlatformUtils.shouldShowMobileUI(context)) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (context) => PlanDetailPage(plan: plan),
          ),
        );
      } else {
        Navigator.of(context).pushReplacementNamed('/');
      }
    } catch (e) {
      LoggerService.error('Error accepting invitation', context: 'INVITATION_PAGE', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.genericErrorWithMessage(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _rejectInvitation(
    PlanInvitation invitation,
    String userId, {
    bool skipConfirm = false,
  }) async {
    final loc = AppLocalizations.of(context)!;
    if (!skipConfirm) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(loc.invitationRejectConfirmTitle),
          content: Text(loc.invitationRejectConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(loc.invitationCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(loc.invitationRejectConfirmButton),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _isProcessing = true);
    try {
      final result = await ref.read(invitationServiceProvider).rejectInvitationByToken(
            widget.token,
            userId,
          );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.success ? loc.invitationRejectedSuccess : result.message,
          ),
          backgroundColor: result.success ? Colors.orange : Colors.red,
        ),
      );

      if (result.success) {
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/');
      }
    } catch (e) {
      LoggerService.error('Error rejecting invitation', context: 'INVITATION_PAGE', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.genericErrorWithMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _buildSuccess(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTypography.titleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
              child: Text(AppLocalizations.of(context)!.invitationBack),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTypography.titleStyle.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
              child: Text(loc.invitationBack),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
