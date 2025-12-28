import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/invitation_providers.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';

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
    final invitationAsync = ref.watch(invitationByTokenProvider(widget.token));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitación a Plan'),
      ),
      body: invitationAsync.when(
        data: (invitation) {
          if (invitation == null) {
            return _buildError('Invitación no encontrada o inválida');
          }

          if (invitation.isExpired) {
            return _buildError('Esta invitación ha expirado');
          }

          if (invitation.isAccepted) {
            return _buildSuccess('Ya has aceptado esta invitación');
          }

          if (invitation.isRejected) {
            return _buildError('Has rechazado esta invitación');
          }

          // Invitación válida: mostrar detalles y botones
          return _buildInvitationDetails(invitation);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          LoggerService.error(
            'Error loading invitation: ${widget.token}',
            context: 'INVITATION_PAGE',
            error: error,
          );
          return _buildError('Error al cargar la invitación: $error');
        },
      ),
    );
  }

  Widget _buildInvitationDetails(invitation) {
    final currentUser = ref.watch(currentUserProvider);
    final planAsync = ref.watch(planByIdProvider(invitation.planId));

    return planAsync.when(
      data: (plan) {
        if (plan == null) {
          return _buildError('Plan no encontrado');
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
                      '¡Has sido invitado!',
                      style: AppTypography.titleStyle.copyWith(
                        color: AppColorScheme.color3,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Te han invitado a unirse a un plan',
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
                        'Detalles del Plan',
                        style: AppTypography.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(Icons.title, 'Nombre', plan.name),
                      if (plan.description != null && plan.description!.isNotEmpty)
                        _buildDetailRow(Icons.description, 'Descripción', plan.description!),
                      if (plan.startDate != null)
                        _buildDetailRow(
                          Icons.calendar_today,
                          'Fecha inicio',
                          _formatDate(plan.startDate!),
                        ),
                      if (plan.endDate != null)
                        _buildDetailRow(
                          Icons.calendar_today,
                          'Fecha fin',
                          _formatDate(plan.endDate!),
                        ),
                      _buildDetailRow(Icons.email, 'Email invitado', invitation.email),
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
                              'Mensaje personalizado',
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
                _buildNotAuthenticatedWarning(invitation),
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
                            'Esta invitación es para ${invitation.email}, pero estás conectado como ${currentUser.email}. Por favor, inicia sesión con el email correcto.',
                            style: TextStyle(color: Colors.orange.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else
                  // Email coincide: mostrar botones de acción
                  _buildActionButtons(invitation, currentUser.id),
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
                        'Esta invitación expira el ${_formatDate(invitation.expiresAt)}',
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
      error: (error, stack) => _buildError('Error al cargar el plan: $error'),
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

  Widget _buildNotAuthenticatedWarning(invitation) {
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
                'Inicia sesión para aceptar la invitación',
                style: AppTypography.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Necesitas una cuenta para unirte al plan',
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
            // Navegar a login (guardar token para después)
            // TODO: Implementar navegación a login con token guardado
            Navigator.of(context).pushNamed('/');
          },
          icon: const Icon(Icons.login),
          label: const Text('Iniciar sesión'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColorScheme.color3,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            // TODO: Implementar navegación a registro con token guardado
            Navigator.of(context).pushNamed('/');
          },
          child: const Text('Crear cuenta'),
        ),
      ],
    );
  }

  Widget _buildActionButtons(invitation, String userId) {
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
          label: Text(_isProcessing ? 'Procesando...' : 'Aceptar invitación'),
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
          label: const Text('Rechazar invitación'),
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
          const SnackBar(
            content: Text('✅ Invitación aceptada. Redirigiendo al plan...'),
            backgroundColor: Colors.green,
          ),
        );

        // Esperar un poco para que el usuario vea el mensaje
        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;

        // Redirigir al dashboard (el plan se seleccionará automáticamente si hay argumentos)
        Navigator.of(context).pushReplacementNamed('/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al aceptar la invitación'),
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
            content: Text('Error: $e'),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazar invitación'),
        content: const Text('¿Estás seguro de que quieres rechazar esta invitación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Rechazar'),
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
          const SnackBar(
            content: Text('Invitación rechazada'),
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
          const SnackBar(
            content: Text('❌ Error al rechazar la invitación'),
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
            content: Text('Error: $e'),
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

  Widget _buildSuccess(String message) {
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

  Widget _buildError(String message) {
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
              child: const Text('Volver'),
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

