import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/invitation_providers.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/shared/utils/platform_utils.dart';
import 'package:unp_calendario/pages/pg_plan_detail_page.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// Página para procesar invitaciones por token (T104)
/// 
/// URL esperada: /invitation/{token}
/// Puede ser accedida sin autenticación para ver detalles del plan
class InvitationPage extends ConsumerStatefulWidget {
  final String token;

  const InvitationPage({
    super.key,
    required this.token,
  });

  @override
  ConsumerState<InvitationPage> createState() => _InvitationPageState();
}

class _InvitationPageState extends ConsumerState<InvitationPage> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final invitationAsync = ref.watch(invitationByTokenProvider(widget.token));

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.invitationTitle),
      ),
      body: invitationAsync.when(
        data: (invitation) {
          if (invitation == null) {
            return _buildError(context, loc.invitationNotFound);
          }

          if (invitation.isExpired) {
            return _buildError(context, loc.invitationExpired);
          }

          if (invitation.isAccepted) {
            return _buildSuccess(context, loc.invitationAlreadyAccepted);
          }

          if (invitation.isRejected) {
            return _buildError(context, loc.invitationAlreadyRejected);
          }

          // Invitación válida: mostrar detalles y botones
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

  Widget _buildInvitationDetails(BuildContext context, invitation) {
    final loc = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);
    final planAsync = ref.watch(planByIdProvider(invitation.planId));

    return planAsync.when(
      data: (plan) {
        if (plan == null) {
          return _buildError(context, loc.invitationNotFound);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColorScheme.color3.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColorScheme.color3.withOpacity(0.3)),
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

              // Detalles del plan
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
                        _buildDetailRow(Icons.description, loc.invitationLabelDescription, plan.description!),
                      if (plan.startDate != null)
                        _buildDetailRow(
                          Icons.calendar_today,
                          loc.invitationLabelStartDate,
                          _formatDate(plan.startDate!),
                        ),
                      if (plan.endDate != null)
                        _buildDetailRow(
                          Icons.calendar_today,
                          loc.invitationLabelEndDate,
                          _formatDate(plan.endDate!),
                        ),
                      _buildDetailRow(Icons.email, loc.invitationLabelInvitedEmail, invitation.email),
                    ],
                  ),
                ),
              ),

              if (invitation.customMessage != null && invitation.customMessage!.isNotEmpty) ...[
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

              // Verificar si el usuario está autenticado
              if (currentUser == null) ...[
                _buildNotAuthenticatedWarning(context),
              ] else ...[
                // Verificar si el email del usuario coincide
                if (currentUser.email?.toLowerCase() != invitation.email.toLowerCase()) ...[
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
                            loc.invitationWrongUserWarning(invitation.email, currentUser.email),
                            style: TextStyle(color: Colors.orange.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else
                  // Email coincide: mostrar botones de acción
                  _buildActionButtons(context, invitation, currentUser.id),
              ],

              const SizedBox(height: 16),

              // Info de expiración
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
      error: (error, stack) => _buildError(context, loc.invitationLoadError(error.toString())),
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

  Widget _buildNotAuthenticatedWarning(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
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
            Navigator.of(context).pushNamed('/');
          },
          icon: const Icon(Icons.login),
          label: Text(loc.invitationLoginButton),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColorScheme.color3,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/');
          },
          child: Text(loc.invitationCreateAccount),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, invitation, String userId) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _isProcessing
              ? null
              : () => _acceptInvitation(invitation, userId),
          icon: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check_circle),
          label: Text(_isProcessing ? loc.invitationProcessing : loc.invitationAcceptButton),
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
              : () => _rejectInvitation(invitation),
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

  Future<void> _acceptInvitation(invitation, String userId) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final invitationService = ref.read(invitationServiceProvider);
      final success = await invitationService.acceptInvitationByToken(widget.token, userId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.invitationAcceptSuccess),
            backgroundColor: Colors.green,
          ),
        );

        // Esperar un poco para que el usuario vea el mensaje
        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;

        // En móvil: ir al detalle del plan aceptado. En web: al dashboard.
        final planId = invitation.planId;
        final plan = await ref.read(planByIdProvider(planId).future);
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.invitationAcceptError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      LoggerService.error(
        'Error accepting invitation',
        context: 'INVITATION_PAGE',
        error: e,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.genericErrorWithMessage(e.toString())),
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

  Future<void> _rejectInvitation(invitation) async {
    final loc = AppLocalizations.of(context)!;
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

    setState(() {
      _isProcessing = true;
    });

    try {
      final invitationService = ref.read(invitationServiceProvider);
      final success = await invitationService.rejectInvitationByToken(widget.token);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.invitationRejectedSuccess),
            backgroundColor: Colors.orange,
          ),
        );

        // Esperar un poco
        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;

        // Cerrar o redirigir
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.invitationRejectError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      LoggerService.error(
        'Error rejecting invitation',
        context: 'INVITATION_PAGE',
        error: e,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.genericErrorWithMessage(e.toString())),
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

  Widget _buildSuccess(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTypography.titleStyle,
              textAlign: TextAlign.center,
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
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTypography.titleStyle.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
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

// Provider temporal para obtener plan por ID (necesitamos crearlo)
final planByIdProvider = FutureProvider.family<Plan?, String>((ref, planId) async {
  final planService = PlanService();
  try {
    final plan = await planService.getPlanById(planId);
    return plan;
  } catch (e) {
    LoggerService.error(
      'Error getting plan by ID: $planId',
      context: 'INVITATION_PAGE',
      error: e,
    );
    return null;
  }
});

