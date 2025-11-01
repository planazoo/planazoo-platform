import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/image_service.dart';
import 'package:unp_calendario/features/calendar/presentation/widgets/plan_state_badge.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';

class PlanCardWidget extends StatelessWidget {
  final Plan plan;
  final VoidCallback? onTap;
  final bool isSelected;
  final VoidCallback? onDelete;

  const PlanCardWidget({
    super.key,
    required this.plan,
    this.onTap,
    this.isSelected = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColorScheme.color1 : AppColorScheme.color0, // fondo1 si seleccionado, fondo0 si no
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSelected ? AppColorScheme.color1 : AppColorScheme.color0,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Imagen del plan (izquierda)
              _buildPlanImage(),
              const SizedBox(width: 8),
              // Información del plan (centro)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del plan (doble línea)
                    Text(
                      plan.name ?? 'Unnamed Plan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColorScheme.color2, // texto2
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Fechas del plan
                    Text(
                      _formatPlanDates(),
                      style: TextStyle(
                        color: AppColorScheme.color2, // texto2
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Duración en días
                    Text(
                      '${plan.columnCount} días',
                      style: TextStyle(
                        color: AppColorScheme.color2, // texto2
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Badge de estado
                    PlanStateBadgeCompact(
                      plan: plan,
                      fontSize: 8,
                    ),
                    const SizedBox(height: 2),
                    // Participantes (fuente pequeña)
                    Text(
                      _formatParticipants(),
                      style: TextStyle(
                        color: AppColorScheme.color2, // texto2
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              // Iconos (derecha) - de momento ninguno según especificación
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPlanDates() {
    if (plan.startDate != null && plan.endDate != null) {
      final start = plan.startDate!;
      final end = plan.endDate!;
      return '${_formatDate(start)} - ${_formatDate(end)}';
    }
    return 'Sin fechas';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatParticipants() {
    // Por ahora mostramos un placeholder, ya que no tenemos la información de participantes
    return 'Participantes: 0';
  }

  Widget _buildPlanImage() {
    const double imageSize = 40.0; // Imagen más pequeña para la lista
    
    if (plan.imageUrl != null && ImageService.isValidImageUrl(plan.imageUrl)) {
      return Container(
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColorScheme.color2.withOpacity(0.3)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: plan.imageUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColorScheme.color2.withOpacity(0.1),
              child: const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: (context, url, error) => _buildDefaultImage(),
          ),
        ),
      );
    } else {
      return Container(
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColorScheme.color2.withOpacity(0.3)),
        ),
        child: _buildDefaultImage(),
      );
    }
  }

  Widget _buildDefaultImage() {
    return Container(
      color: AppColorScheme.color2.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.image,
          color: AppColorScheme.color2.withOpacity(0.5),
          size: 20,
        ),
      ),
    );
  }
}