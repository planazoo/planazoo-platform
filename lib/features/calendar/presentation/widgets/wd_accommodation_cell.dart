import 'package:flutter/material.dart';
import '../../../../shared/services/logger_service.dart';
import '../../domain/models/accommodation.dart';

class AccommodationCell extends StatelessWidget {
  final List<Accommodation> accommodations;
  final VoidCallback? onTap;
  final Function(Accommodation)? onAccommodationTap;
  final double width;
  final double height;

  const AccommodationCell({
    super.key,
    required this.accommodations,
    this.onTap,
    this.onAccommodationTap,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Debug: verificar qué alojamientos estamos recibiendo

          for (int i = 0; i < accommodations.length; i++) {
        // Debug info removed
      }
    
    if (accommodations.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey.shade300),
            bottom: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hotel,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 2),
                Text(
                  'Agregar alojamiento',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Si hay múltiples alojamientos, apilarlos verticalmente
    if (accommodations.length > 1) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey.shade300),
            bottom: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: accommodations.take(3).map((accommodation) {
            final index = accommodations.indexOf(accommodation);
            return Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _getAccommodationColor(accommodation.color),
                  border: Border(
                    bottom: index < 2 ? BorderSide(color: Colors.grey.shade300, width: 0.5) : BorderSide.none,
                  ),
                ),
                child: InkWell(
                  onTap: () => onAccommodationTap?.call(accommodation),
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          accommodation.hotelName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 8,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (accommodation.description != null && accommodation.description!.isNotEmpty)
                          Text(
                            accommodation.description!,
                            style: const TextStyle(
                              fontSize: 6,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    // Si solo hay un alojamiento, mostrar normalmente
    final accommodation = accommodations.first;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
        color: _getAccommodationColor(accommodation.color),
      ),
      child: InkWell(
        onTap: () => onAccommodationTap?.call(accommodation),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                accommodation.hotelName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (accommodation.description != null && accommodation.description!.isNotEmpty)
                Text(
                  accommodation.description!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAccommodationColor(String? colorName) {
    switch (colorName) {
      case 'red':
        return Colors.red.shade100;
      case 'blue':
        return Colors.blue.shade100;
      case 'green':
        return Colors.green.shade100;
      case 'yellow':
        return Colors.yellow.shade100;
      case 'purple':
        return Colors.purple.shade100;
      case 'orange':
        return Colors.orange.shade100;
      default:
        return Colors.blue.shade100;
    }
  }
}
