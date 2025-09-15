import 'package:flutter/material.dart';
import 'package:unp_calendario/widgets/wd_date_selector.dart';

class CalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final VoidCallback onAddColumn;

  const CalendarAppBar({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.onAddColumn,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Calendar'),
      actions: [
        IconButton(
          onPressed: onAddColumn,
          icon: const Icon(Icons.add),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DateSelector(
            selectedDate: selectedDate,
            onDateChanged: onDateChanged,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(120);
}