import 'package:flutter/material.dart';

/// Widget que envuelve un campo de formulario con indicadores visuales de permisos
class PermissionField extends StatelessWidget {
  final Widget child;
  final bool canEdit;
  final String? tooltipText;
  final String fieldType; // 'common' o 'personal'
  final String fieldName;
  final IconData? icon;

  const PermissionField({
    super.key,
    required this.child,
    required this.canEdit,
    required this.fieldType,
    required this.fieldName,
    this.tooltipText,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con indicadores
        Row(
          children: [
            // Icono de tipo de campo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: fieldType == 'common' 
                    ? Colors.blue.shade50 
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: fieldType == 'common' 
                      ? Colors.blue.shade200 
                      : Colors.green.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    fieldType == 'common' ? Icons.group : Icons.person,
                    size: 12,
                    color: fieldType == 'common' 
                        ? Colors.blue.shade700 
                        : Colors.green.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    fieldType == 'common' ? 'Común' : 'Personal',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: fieldType == 'common' 
                          ? Colors.blue.shade700 
                          : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Icono de permisos
            Icon(
              canEdit ? Icons.lock_open : Icons.lock,
              size: 16,
              color: canEdit ? Colors.green.shade600 : Colors.grey.shade500,
            ),
            const SizedBox(width: 4),
            // Texto de estado
            Text(
              canEdit ? 'Editable' : 'Solo lectura',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: canEdit ? Colors.green.shade700 : Colors.grey.shade600,
              ),
            ),
            const Spacer(),
            // Tooltip
            if (tooltipText != null)
              Tooltip(
                message: tooltipText!,
                child: Icon(
                  Icons.help_outline,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Campo envuelto
        child,
      ],
    );
  }
}

/// Widget para campos de texto con indicadores de permisos
class PermissionTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool canEdit;
  final String fieldType;
  final String? tooltipText;
  final IconData? prefixIcon;
  final int? maxLines;
  final TextInputType? keyboardType;

  const PermissionTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.canEdit,
    required this.fieldType,
    this.tooltipText,
    this.prefixIcon,
    this.maxLines,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionField(
      canEdit: canEdit,
      fieldType: fieldType,
      fieldName: labelText,
      tooltipText: tooltipText,
      icon: prefixIcon,
      child: TextField(
        controller: controller,
        readOnly: !canEdit,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon != null 
              ? Icon(
                  prefixIcon,
                  color: canEdit ? Colors.green.shade600 : Colors.grey.shade500,
                )
              : null,
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: canEdit ? Colors.green.shade300 : Colors.grey.shade300,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: canEdit ? Colors.green.shade300 : Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: canEdit ? Colors.green.shade500 : Colors.grey.shade400,
            ),
          ),
          filled: true,
          fillColor: canEdit ? Colors.green.shade50 : Colors.grey.shade50,
          suffixIcon: canEdit 
              ? Icon(Icons.edit, size: 16, color: Colors.green.shade600)
              : Icon(Icons.lock, size: 16, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}

/// Widget para dropdowns con indicadores de permisos
class PermissionDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String labelText;
  final bool canEdit;
  final String fieldType;
  final String? tooltipText;
  final IconData? prefixIcon;

  const PermissionDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.labelText,
    required this.canEdit,
    required this.fieldType,
    this.tooltipText,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionField(
      canEdit: canEdit,
      fieldType: fieldType,
      fieldName: labelText,
      tooltipText: tooltipText,
      icon: prefixIcon,
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: prefixIcon != null 
              ? Icon(
                  prefixIcon,
                  color: canEdit ? Colors.green.shade600 : Colors.grey.shade500,
                )
              : null,
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: canEdit ? Colors.green.shade300 : Colors.grey.shade300,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: canEdit ? Colors.green.shade300 : Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: canEdit ? Colors.green.shade500 : Colors.grey.shade400,
            ),
          ),
          filled: true,
          fillColor: canEdit ? Colors.green.shade50 : Colors.grey.shade50,
          suffixIcon: canEdit 
              ? Icon(Icons.arrow_drop_down, color: Colors.green.shade600)
              : Icon(Icons.lock, size: 16, color: Colors.grey.shade500),
        ),
        items: items,
        onChanged: canEdit ? onChanged : null,
      ),
    );
  }
}
