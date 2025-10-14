import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/shared/utils/color_utils.dart';

class AccommodationDialog extends ConsumerStatefulWidget {
  final Accommodation? accommodation;
  final String planId;
  final DateTime planStartDate;
  final DateTime? planEndDate;
  final DateTime? initialCheckIn;
  final Function(Accommodation)? onSaved;
  final Function(String)? onDeleted;

  const AccommodationDialog({
    super.key,
    this.accommodation,
    required this.planId,
    required this.planStartDate,
    this.planEndDate,
    this.initialCheckIn,
    this.onSaved,
    this.onDeleted,
  });

  @override
  ConsumerState<AccommodationDialog> createState() => _AccommodationDialogState();
}

class _AccommodationDialogState extends ConsumerState<AccommodationDialog> {
  late TextEditingController _hotelNameController;
  late TextEditingController _descriptionController;
  late DateTime _selectedCheckIn;
  late DateTime _selectedCheckOut;
  late String _selectedColor;

  // Colores predefinidos para alojamientos
  final List<String> _accommodationColors = [
    'blue',
    'green',
    'purple',
    'orange',
    'red',
    'yellow',
    'pink',
    'brown',
  ];

  // Tipos de alojamiento
  final List<String> _accommodationTypes = [
    'Hotel',
    'Apartamento',
    'Hostal',
    'Casa',
    'Resort',
    'Camping',
    'Otro',
  ];

  late String _selectedType;

  @override
  void initState() {
    super.initState();
    
    // Inicializar controladores
    _hotelNameController = TextEditingController(
      text: widget.accommodation?.hotelName ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.accommodation?.description ?? '',
    );
    
    // Inicializar fechas
    _selectedCheckIn = widget.initialCheckIn ?? widget.accommodation?.checkIn ?? widget.planStartDate;
    _selectedCheckOut = widget.accommodation?.checkOut ?? _selectedCheckIn.add(const Duration(days: 1));
    _selectedColor = widget.accommodation?.color ?? 'blue';
    _selectedType = widget.accommodation?.typeSubtype ?? 'Hotel';
  }

  @override
  void dispose() {
    _hotelNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.accommodation == null ? 'Nuevo Alojamiento' : 'Editar Alojamiento'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del hotel/alojamiento
            TextField(
              controller: _hotelNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del alojamiento',
                hintText: 'Hotel, apartamento, etc.',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.hotel),
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            
            // Tipo de alojamiento
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo de alojamiento',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _accommodationTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value ?? 'Hotel';
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Descripción
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Notas adicionales',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Check-in
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.login),
              title: const Text('Check-in'),
              subtitle: Text('${_selectedCheckIn.day}/${_selectedCheckIn.month}/${_selectedCheckIn.year}'),
              onTap: _selectCheckInDate,
            ),
            
            // Check-out
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout),
              title: const Text('Check-out'),
              subtitle: Text('${_selectedCheckOut.day}/${_selectedCheckOut.month}/${_selectedCheckOut.year}'),
              onTap: _selectCheckOutDate,
            ),
            
            const SizedBox(height: 8),
            
            // Duración
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.nights_stay, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedCheckOut.difference(_selectedCheckIn).inDays} noche(s)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Color
            const Text('Color:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _accommodationColors.map((colorName) {
                final color = _getColorFromName(colorName);
                final isSelected = _selectedColor == colorName;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = colorName;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected 
                          ? Border.all(color: Colors.black, width: 3)
                          : Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: isSelected 
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        // Botón eliminar (solo si es edición)
        if (widget.accommodation != null)
          TextButton(
            onPressed: () => _confirmDelete(),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        
        // Botón cancelar
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        
        // Botón guardar
        ElevatedButton(
          onPressed: _saveAccommodation,
          child: Text(widget.accommodation == null ? 'Crear' : 'Guardar'),
        ),
      ],
    );
  }

  Future<void> _selectCheckInDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedCheckIn,
      firstDate: widget.planStartDate,
      lastDate: widget.planEndDate ?? widget.planStartDate.add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedCheckIn) {
      setState(() {
        _selectedCheckIn = picked;
        // Asegurar que check-out es después de check-in
        if (_selectedCheckOut.isBefore(_selectedCheckIn) || _selectedCheckOut.isAtSameMomentAs(_selectedCheckIn)) {
          _selectedCheckOut = _selectedCheckIn.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedCheckOut,
      firstDate: _selectedCheckIn.add(const Duration(days: 1)),
      lastDate: widget.planEndDate ?? widget.planStartDate.add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedCheckOut) {
      setState(() {
        _selectedCheckOut = picked;
      });
    }
  }

  Color _getColorFromName(String colorName) {
    return ColorUtils.colorFromName(colorName);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar el alojamiento "${widget.accommodation?.hotelName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.onDeleted != null && widget.accommodation?.id != null) {
      widget.onDeleted!(widget.accommodation!.id!);
    }
  }

  void _saveAccommodation() {
    // Validar nombre del hotel
    if (_hotelNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre del alojamiento es obligatorio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar fechas
    if (_selectedCheckOut.isBefore(_selectedCheckIn) || _selectedCheckOut.isAtSameMomentAs(_selectedCheckIn)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha de check-out debe ser posterior al check-in'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final accommodation = Accommodation(
      id: widget.accommodation?.id,
      planId: widget.planId,
      checkIn: _selectedCheckIn,
      checkOut: _selectedCheckOut,
      hotelName: _hotelNameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      color: _selectedColor,
      typeFamily: 'alojamiento',
      typeSubtype: _selectedType,
      createdAt: widget.accommodation?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.onSaved != null) {
      widget.onSaved!(accommodation);
    }
  }
}
