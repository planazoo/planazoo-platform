import 'package:flutter/material.dart';
import 'wd_date_selector.dart';

class CalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final VoidCallback onAddColumn;
  final VoidCallback onRemoveColumn;
  final bool canRemoveColumn;

  const CalendarAppBar({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.onAddColumn,
    required this.onRemoveColumn,
    required this.canRemoveColumn,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Calendario UNP'),
      centerTitle: true,
      actions: [
        const Spacer(),
        IconButton(
          onPressed: canRemoveColumn ? onRemoveColumn : null,
          icon: Icon(
            Icons.remove,
            color: canRemoveColumn ? null : Colors.grey,
          ),
          tooltip: 'Eliminar día',
        ),
        IconButton(
          onPressed: onAddColumn,
          icon: const Icon(Icons.add),
          tooltip: 'Añadir día',
        ),
        const SizedBox(width: 16),
        DateSelector(
          selectedDate: selectedDate,
          onDateChanged: onDateChanged,
        ),
        const Spacer(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 