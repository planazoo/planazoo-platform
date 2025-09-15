import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';

class AccommodationCell extends StatelessWidget {
  final List<Accommodation> accommodations;
  final VoidCallback? onTap;
  final Function(Accommodation)? onAccommodationTap;
  final double? width;
  final double? height;

  const AccommodationCell({
    super.key,
    required this.accommodations,
    this.onTap,
    this.onAccommodationTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (accommodations.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: accommodations.first.color is Color 
              ? accommodations.first.color as Color 
              : const Color(0xFF4CAF50), // Verde Material Design
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          accommodations.first.hotelName ?? 'Accommodation',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}