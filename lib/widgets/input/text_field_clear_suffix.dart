import 'package:flutter/material.dart';

/// `suffixIcon` con icono de borrar cuando el campo no está vacío (lista §3.2 ítem 67).
Widget textFieldClearSuffix(
  TextEditingController controller, {
  VoidCallback? onCleared,
  Color? iconColor,
  double iconSize = 20,
}) {
  return ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      if (controller.text.isEmpty) {
        return const SizedBox.shrink();
      }
      return IconButton(
        icon: Icon(Icons.clear, size: iconSize, color: iconColor ?? Colors.grey.shade400),
        onPressed: () {
          controller.clear();
          onCleared?.call();
        },
        tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
      );
    },
  );
}
