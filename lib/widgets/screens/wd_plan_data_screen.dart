import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/image_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_state_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_state_permissions.dart';
import 'package:unp_calendario/features/calendar/presentation/widgets/plan_state_badge.dart';
import 'package:unp_calendario/features/calendar/presentation/widgets/state_transition_dialog.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';

class PlanDataScreen extends ConsumerStatefulWidget {
  final Plan plan;
  final VoidCallback? onPlanDeleted;

  const PlanDataScreen({
    super.key,
    required this.plan,
    this.onPlanDeleted,
  });

  @override
  ConsumerState<PlanDataScreen> createState() => _PlanDataScreenState();
}

class _PlanDataScreenState extends ConsumerState<PlanDataScreen> {
  late Plan currentPlan;
  XFile? _selectedImage;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    currentPlan = widget.plan;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentPlan.name ?? 'Plan Data'),
        backgroundColor: AppColorScheme.color2,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showDeleteConfirmation(context),
            icon: const Icon(Icons.delete),
            tooltip: 'Eliminar Plan',
          ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade50,
      child: Column(
        children: [
            // Header personalizado similar al perfil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                  Text(
                    'Planazoo',
                    style: AppTypography.mediumTitle.copyWith(
                      color: AppColorScheme.color1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 20,
                  ),
                ),
              ),
            ],
          ),
            ),
            // Contenido principal con scroll
          Expanded(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    // Información de permisos según estado (si hay restricciones)
                    if (PlanStatePermissions.isReadOnly(currentPlan)) ...[
                      _buildReadOnlyWarning(),
                      const SizedBox(height: 24),
                    ],
                    
                    // Imagen del plan
                    _buildPlanImageSection(),
                    const SizedBox(height: 24),
                    
                    // Información del plan en formato compacto
                    _buildInfoSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Gestión de estado del plan
                    _buildStateManagementSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Botón de eliminar
                    _buildDeleteButton(),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información del Plan',
            style: AppTypography.mediumTitle.copyWith(
              color: AppColorScheme.color4,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildCompactInfoItem('Nombre:', currentPlan.name ?? 'N/A', 
              editable: PlanStatePermissions.canEditBasicInfo(currentPlan)),
          _buildCompactInfoItem('UNP ID:', currentPlan.unpId ?? 'N/A', editable: false),
          _buildCompactInfoItem('ID:', currentPlan.id ?? 'N/A', editable: false),
          _buildCompactInfoItem('Fecha de Inicio:', _formatDate(currentPlan.startDate),
              editable: PlanStatePermissions.canModifyDates(currentPlan),
              blockedReason: PlanStatePermissions.getBlockedReason('modify_dates', currentPlan)),
          _buildCompactInfoItem('Fecha de Fin:', _formatDate(currentPlan.endDate),
              editable: PlanStatePermissions.canModifyDates(currentPlan),
              blockedReason: PlanStatePermissions.getBlockedReason('modify_dates', currentPlan)),
          _buildCompactInfoItem('Duración:', '${currentPlan.columnCount} días', editable: false),
          _buildCompactInfoItem('Creado:', _formatDate(currentPlan.createdAt), editable: false),
          const SizedBox(height: 12),
          // Badge de estado
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  'Estado:',
                  style: AppTypography.bodyStyle.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              PlanStateBadge(
                plan: currentPlan,
                fontSize: 12,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfoItem(String label, String value, {
    bool editable = false,
    String? blockedReason,
  }) {
    final isBlocked = !editable && blockedReason != null;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Row(
              children: [
                if (isBlocked)
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Icon(
                      Icons.lock,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                Flexible(
                  child: Text(
                    label,
                    style: AppTypography.bodyStyle.copyWith(
                      color: isBlocked ? Colors.grey.shade500 : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTypography.bodyStyle.copyWith(
                    color: isBlocked ? Colors.grey.shade400 : AppColorScheme.color4,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
                if (isBlocked && blockedReason != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    blockedReason!,
                    style: AppTypography.bodyStyle.copyWith(
                      color: Colors.orange.shade700,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyWarning() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              PlanStatePermissions.getBlockedReason('view', currentPlan) ?? 
                  'Este plan tiene restricciones de edición según su estado.',
              style: AppTypography.bodyStyle.copyWith(
                color: Colors.orange.shade900,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateManagementSection() {
    final currentUser = ref.read(currentUserProvider);
    final isOwner = currentUser?.id == currentPlan.userId;
    final currentState = currentPlan.state ?? 'borrador';
    final stateService = PlanStateService();

    // Solo mostrar controles si es el organizador y el plan no está finalizado o cancelado
    if (!isOwner || currentState == 'finalizado' || currentState == 'cancelado') {
      return const SizedBox.shrink();
    }

    // Determinar qué transiciones son válidas
    List<Map<String, dynamic>> availableTransitions = [];

    switch (currentState) {
      case 'borrador':
        availableTransitions.add({
          'state': 'planificando',
          'label': 'Iniciar Planificación',
          'icon': Icons.event_note,
        });
        break;
      case 'planificando':
        availableTransitions.add({
          'state': 'confirmado',
          'label': 'Confirmar Plan',
          'icon': Icons.check_circle_outline,
        });
        availableTransitions.add({
          'state': 'cancelado',
          'label': 'Cancelar Plan',
          'icon': Icons.cancel_outlined,
        });
        break;
      case 'confirmado':
        availableTransitions.add({
          'state': 'en_curso',
          'label': 'Marcar como En Curso',
          'icon': Icons.play_circle_outline,
        });
        availableTransitions.add({
          'state': 'planificando',
          'label': 'Volver a Planificación',
          'icon': Icons.undo,
        });
        availableTransitions.add({
          'state': 'cancelado',
          'label': 'Cancelar Plan',
          'icon': Icons.cancel_outlined,
        });
        break;
      case 'en_curso':
        availableTransitions.add({
          'state': 'finalizado',
          'label': 'Finalizar Plan',
          'icon': Icons.check_circle,
        });
        break;
    }

    if (availableTransitions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestión de Estado',
            style: AppTypography.mediumTitle.copyWith(
              color: AppColorScheme.color4,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...availableTransitions.map((transition) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _changePlanState(transition['state'] as String),
                    icon: Icon(transition['icon'] as IconData, size: 18),
                    label: Text(transition['label'] as String),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _changePlanState(String newState) async {
    final confirmed = await showStateTransitionDialog(
      context: context,
      plan: currentPlan,
      newState: newState,
    );

    if (!confirmed || currentPlan.id == null) return;

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Usuario no autenticado'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final stateService = PlanStateService();
      final success = await stateService.changePlanState(
        planId: currentPlan.id!,
        newState: newState,
        userId: currentUser.id,
      );

      if (success && mounted) {
        // Actualizar el plan localmente
        final planService = ref.read(planServiceProvider);
        final updatedPlan = await planService.getPlanById(currentPlan.id!);
        if (updatedPlan != null && mounted) {
          setState(() {
            currentPlan = updatedPlan;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Estado del plan actualizado a: ${PlanStateService.getStateDisplayInfo(newState)['label']}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cambiar el estado del plan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDeleteButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Text(
            'Zona de Peligro',
            style: AppTypography.bodyStyle.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Eliminar este plan eliminará todos los eventos asociados y no se puede deshacer.',
            style: AppTypography.bodyStyle.copyWith(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showDeleteConfirmation(context),
              icon: const Icon(Icons.delete, size: 18),
              label: const Text('Eliminar Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Plan'),
          content: const Text(
            '¿Estás seguro de que quieres eliminar este plan definitivamente?\n\n'
            'Esta acción eliminará:\n'
            '• El plan de la base de datos\n'
            '• Todos los eventos del plan\n'
            '• Todas las participaciones\n\n'
            'Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _deletePlan(context);
    }
  }

  Future<void> _deletePlan(BuildContext context) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final planService = ref.read(planServiceProvider);
      final eventService = ref.read(eventServiceProvider);

      // Eliminar imagen si existe
      if (currentPlan.imageUrl != null) {
        await ImageService.deletePlanImage(currentPlan.imageUrl!);
      }
      
      // Eliminar eventos del plan primero
      await eventService.deleteEventsByPlanId(currentPlan.id!);
      
      // Eliminar el plan (esto también elimina las participaciones)
      final success = await planService.deletePlan(currentPlan.id!);

      // Cerrar el indicador de carga
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        // Mostrar mensaje de éxito
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Plan "${currentPlan.name}" eliminado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        // Notificar que el plan fue eliminado
        widget.onPlanDeleted?.call();
      } else {
        // Mostrar mensaje de error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar el plan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Cerrar el indicador de carga si está abierto
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

  Widget _buildPlanImageSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Imagen del Plan',
                style: AppTypography.mediumTitle.copyWith(
                  color: AppColorScheme.color4,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Row(
                children: [
                  if (currentPlan.imageUrl != null)
                    _buildActionButton(
                      icon: Icons.edit,
                      label: 'Cambiar',
                      onPressed: _isUploadingImage ? null : _pickImage,
                    ),
                  if (currentPlan.imageUrl == null)
                    _buildActionButton(
                      icon: Icons.add_photo_alternate,
                      label: 'Añadir',
                      onPressed: _isUploadingImage ? null : _pickImage,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPlanImageDisplay(),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColorScheme.color2.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColorScheme.color2.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: AppColorScheme.color2,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.bodyStyle.copyWith(
                color: AppColorScheme.color2,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanImageDisplay() {
    if (currentPlan.imageUrl != null && ImageService.isValidImageUrl(currentPlan.imageUrl)) {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: currentPlan.imageUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColorScheme.color2.withOpacity(0.1),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => _buildDefaultImage(),
          ),
        ),
      );
    } else {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: _buildDefaultImage(),
      );
    }
  }

  Widget _buildDefaultImage() {
    return Container(
      color: AppColorScheme.color2.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: 48,
              color: AppColorScheme.color2.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Sin imagen',
              style: AppTypography.bodyStyle.copyWith(
                color: AppColorScheme.color2.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await ImageService.pickImageFromGallery();
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _isUploadingImage = true;
        });
        
        // Validar imagen
        final validationError = await ImageService.validateImage(image);
        if (validationError != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(validationError),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _isUploadingImage = false;
          });
          return;
        }
        
        // Subir imagen
        final uploadedImageUrl = await ImageService.uploadPlanImage(image, currentPlan.id!);
        
        if (uploadedImageUrl != null) {
          // Actualizar el plan con la nueva URL de imagen
          final updatedPlan = currentPlan.copyWith(imageUrl: uploadedImageUrl);
          final planService = ref.read(planServiceProvider);
          final success = await planService.updatePlan(updatedPlan);
          
          if (success) {
            setState(() {
              currentPlan = updatedPlan;
              _isUploadingImage = false;
            });
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Imagen actualizada correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            throw Exception('Error al actualizar el plan');
          }
        } else {
          throw Exception('Error al subir la imagen');
        }
      }
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });
      
      if (mounted) {
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