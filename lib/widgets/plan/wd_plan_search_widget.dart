import 'package:flutter/material.dart';
import '../../app/theme/color_scheme.dart';

class PlanSearchWidget extends StatelessWidget {
  final String? searchQuery;
  final Function(String)? onSearchChanged;
  final VoidCallback? onSearchPressed;

  const PlanSearchWidget({
    super.key,
    this.searchQuery,
    this.onSearchChanged,
    this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar planes...',
        prefixIcon: Icon(
          Icons.search,
          color: AppColorScheme.color1,
        ),
        filled: true,
        fillColor: AppColorScheme.color0, // Fondo color0
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColorScheme.color1, // Bordes color1
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8), // Bordes redondeados
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColorScheme.color1, // Bordes color1
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8), // Bordes redondeados
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColorScheme.color1, // Bordes color1
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8), // Bordes redondeados
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
      style: TextStyle(
        color: AppColorScheme.color1,
      ),
      onChanged: onSearchChanged,
      onSubmitted: (_) => onSearchPressed?.call(),
    );
  }
}