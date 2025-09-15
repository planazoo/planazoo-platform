import 'package:flutter/material.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final bool isEnabled;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: isEnabled ? () => _previousDate() : null,
          icon: const Icon(Icons.chevron_left),
        ),
        GestureDetector(
          onTap: isEnabled ? () => _selectDate(context) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2), // Azul más oscuro como en la documentación
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              DateFormatter.formatDate(selectedDate),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white, // Texto blanco como en la documentación
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: isEnabled ? () => _nextDate() : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  void _previousDate() {
    onDateChanged(selectedDate.subtract(const Duration(days: 1)));
  }

  void _nextDate() {
    onDateChanged(selectedDate.add(const Duration(days: 1)));
  }

  void _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      onDateChanged(date);
    }
  }
}