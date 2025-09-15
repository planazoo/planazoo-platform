import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';

class AccommodationDialog extends StatefulWidget {
  final Accommodation? accommodation;
  final String planId;
  final DateTime planStartDate;
  final DateTime? planEndDate;
  final Function(Accommodation)? onSaved;
  final Function(String)? onDeleted;
  final Function(Accommodation, DateTime, DateTime)? onMoved;

  const AccommodationDialog({
    super.key,
    this.accommodation,
    required this.planId,
    required this.planStartDate,
    this.planEndDate,
    this.onSaved,
    this.onDeleted,
    this.onMoved,
  });

  @override
  State<AccommodationDialog> createState() => _AccommodationDialogState();
}

class _AccommodationDialogState extends State<AccommodationDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.accommodation == null ? 'Add Accommodation' : 'Edit Accommodation'),
      content: const Text('Accommodation dialog - Under construction'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Save'),
        ),
      ],
    );
  }
}