import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/auth/presentation/pages/edit_profile_page.dart';
import 'package:unp_calendario/features/auth/presentation/pages/account_settings_page.dart';
import 'package:unp_calendario/features/calendar/domain/services/event_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_participation_service.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    // Método para formatear fechas
    String _formatDate(DateTime date) {
      return '${date.day}/${date.month}/${date.year}';
    }

    return Scaffold(
      backgroundColor: AppColorScheme.color0,
      body: currentUser == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // Top bar con logo y botón de cerrar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    color: AppColorScheme.color2,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Planazoo',
                        style: AppTypography.largeTitle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Contenido principal
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        
                        // Header compacto con foto y datos
                        Row(
                          children: [
                            // Foto de perfil más pequeña
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColorScheme.color2.withValues(alpha: 0.1),
                                border: Border.all(
                                  color: AppColorScheme.color2,
                                  width: 2,
                                ),
                              ),
                              child: currentUser.photoURL != null
                                  ? ClipOval(
                                      child: Image.network(
                                        currentUser.photoURL!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.person,
                                            size: 40,
                                            color: AppColorScheme.color2,
                                          );
                                        },
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 40,
                                      color: AppColorScheme.color2,
                                    ),
                            ),
                            
                            const SizedBox(width: 20),
                            
                            // Información del usuario
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentUser.displayName ?? 'Usuario',
                                    style: AppTypography.mediumTitle.copyWith(
                                      color: AppColorScheme.color4,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currentUser.email,
                                    style: AppTypography.bodyStyle.copyWith(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Miembro desde ${_formatDate(currentUser.createdAt)}',
                                    style: AppTypography.caption.copyWith(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Opciones de texto simple
                        Column(
                          children: [
                            _buildTextOption(
                              'Editar Perfil',
                              () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const EditProfilePage(),
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 8),
                            
                            _buildTextOption(
                              'Configuración de Cuenta',
                              () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const AccountSettingsPage(),
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 8),
                            
                            _buildTextOption(
                              'Migrar Eventos',
                              () async {
                                if (currentUser != null) {
                                  final eventService = EventService();
                                  final success = await eventService.migrateEventsWithUserId(currentUser!.id);
                                  
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          success 
                                            ? 'Eventos migrados correctamente' 
                                            : 'Error al migrar eventos',
                                        ),
                                        backgroundColor: success ? Colors.green : Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                            
                            const SizedBox(height: 8),
                            
                            _buildTextOption(
                              'Participar en Todos los Planes',
                              () async {
                                if (currentUser != null) {
                                  // Mostrar diálogo de confirmación
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Participar en Planes'),
                                        content: const Text(
                                          '¿Quieres añadirte como participante a todos los planes existentes?\n\n'
                                          'Esto te permitirá ver los eventos de todos los planes en el calendario.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: const Text('Participar'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirmed == true) {
                                    // Mostrar indicador de carga
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );

                                    try {
                                      final planParticipationService = PlanParticipationService();
                                      final result = await planParticipationService.addUserToAllPlans(currentUser!.id);
                                      
                                      // Cerrar indicador de carga
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                        
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(result['message'] as String),
                                            backgroundColor: result['success'] as bool ? Colors.green : Colors.orange,
                                            duration: const Duration(seconds: 5),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      // Cerrar indicador de carga
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                        
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                }
                              },
                            ),
                            
                            const SizedBox(height: 8),
                            
                            _buildTextOption(
                              'Cerrar Sesión',
                              () async {
                                await authNotifier.signOut();
                                if (context.mounted) {
                                  Navigator.of(context).pushReplacementNamed('/');
                                }
                              },
                              isDestructive: true,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.mediumTitle.copyWith(
            color: AppColorScheme.color4,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTypography.bodyStyle.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyStyle.copyWith(
                color: AppColorScheme.color4,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextOption(
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDestructive ? Colors.red.shade200 : AppColorScheme.color2.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.bodyStyle.copyWith(
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red : AppColorScheme.color4,
                fontSize: 14,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
    String? subtitle,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDestructive ? Colors.red.shade200 : AppColorScheme.color2.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDestructive 
                        ? Colors.red.withValues(alpha: 0.1)
                        : AppColorScheme.color2.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive ? Colors.red : AppColorScheme.color2,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDestructive ? Colors.red : AppColorScheme.color4,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: AppTypography.caption.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
