import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_announcement.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/announcement_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_service.dart';
import 'package:unp_calendario/features/notifications/domain/services/notification_helper.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import '../../../../shared/services/logger_service.dart';

/// Diálogo para publicar un aviso en un plan
class AnnouncementDialog extends ConsumerStatefulWidget {
  final String planId;

  const AnnouncementDialog({
    super.key,
    required this.planId,
  });

  @override
  ConsumerState<AnnouncementDialog> createState() => _AnnouncementDialogState();
}

class _AnnouncementDialogState extends ConsumerState<AnnouncementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  String _selectedType = 'info'; // info, urgent, important
  bool _isPublishing = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  /// Crear notificaciones para los participantes cuando se publica un aviso
  Future<void> _createNotificationsForAnnouncement(
    String planId,
    String announcementUserId,
    String announcementMessage,
    String announcementType,
  ) async {
    try {
      // Obtener nombre del plan
      final planService = PlanService();
      final plan = await planService.getPlanById(planId);
      final planName = plan?.name;

      // Crear notificaciones usando el helper
      final notificationHelper = NotificationHelper();
      await notificationHelper.notifyAnnouncementCreated(
        planId: planId,
        announcementUserId: announcementUserId,
        announcementMessage: announcementMessage,
        announcementType: announcementType,
        planName: planName,
      );
    } catch (e) {
      LoggerService.error(
        'Error creating notifications for announcement',
        context: 'ANNOUNCEMENT_DIALOG',
        error: e,
      );
    }
  }

  Future<void> _publishAnnouncement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isPublishing = true;
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

      final announcement = PlanAnnouncement(
        planId: widget.planId,
        userId: currentUser.id,
        message: _messageController.text.trim(),
        type: _selectedType,
        createdAt: DateTime.now(),
      );

      final announcementService = ref.read(announcementServiceProvider);
      final announcementId = await announcementService.createAnnouncement(
        widget.planId,
        announcement,
      );

      if (mounted) {
        if (announcementId != null) {
          // Crear notificaciones para los participantes (en background, no bloquea UI)
          _createNotificationsForAnnouncement(
            widget.planId,
            currentUser.id,
            _messageController.text.trim(),
            _selectedType,
          ).catchError((e) {
            LoggerService.error(
              'Error creating notifications for announcement',
              context: 'ANNOUNCEMENT_DIALOG',
              error: e,
            );
          });

          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Aviso publicado'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Error al publicar el aviso'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.error('Error publishing announcement', context: 'ANNOUNCEMENT_DIALOG', error: e);
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
          _isPublishing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Publicar Aviso'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mensaje
                TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Mensaje',
                    hintText: 'Escribe tu aviso aquí...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.message),
                  ),
                  maxLines: 6,
                  maxLength: 1000,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa un mensaje';
                    }
                    if (value.trim().length < 3) {
                      return 'El mensaje debe tener al menos 3 caracteres';
                    }
                    if (value.trim().length > 1000) {
                      return 'El mensaje no puede exceder 1000 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Tipo de aviso
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'info',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 20),
                          SizedBox(width: 8),
                          Text('Información'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'urgent',
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, size: 20, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Urgente'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'important',
                      child: Row(
                        children: [
                          Icon(Icons.priority_high, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Importante'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Info adicional
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Este aviso será visible para todos los participantes del plan.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isPublishing ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isPublishing ? null : _publishAnnouncement,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColorScheme.color3,
          ),
          child: _isPublishing
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Publicando...'),
                  ],
                )
              : const Text('Publicar'),
        ),
      ],
    );
  }
}

