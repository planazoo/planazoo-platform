import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';

class OverlappingAccommodationsCell extends StatelessWidget {
  final List<Accommodation> accommodations;
  final int hour;
  final String planId;
  final DateTime date;
  final Function(Accommodation)? onAccommodationTap;
  final Function(Accommodation)? onAccommodationEdit;
  final Function(Accommodation)? onAccommodationDelete;

  const OverlappingAccommodationsCell({
    super.key,
    required this.accommodations,
    required this.hour,
    required this.planId,
    required this.date,
    this.onAccommodationTap,
    this.onAccommodationEdit,
    this.onAccommodationDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (accommodations.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 40,
      child: Stack(
        children: accommodations.map((accommodation) {
          return Positioned(
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => onAccommodationTap?.call(accommodation),
              child: Container(
                margin: const EdgeInsets.all(2),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accommodation.color is Color 
                      ? accommodation.color as Color 
                      : Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  accommodation.hotelName ?? 'Accommodation',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
