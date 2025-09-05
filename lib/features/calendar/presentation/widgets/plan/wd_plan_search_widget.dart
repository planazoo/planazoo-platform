import 'package:flutter/material.dart';

class PlanSearchWidget extends StatelessWidget {
  final Function(String) onSearchChanged;

  const PlanSearchWidget({
    super.key,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: '🔍 Buscar planazoos...',
          hintStyle: TextStyle(
            color: Colors.teal.shade600,
            fontSize: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.teal.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(
            Icons.search,
            color: Colors.teal.shade600,
          ),
        ),
      ),
    );
  }
}
