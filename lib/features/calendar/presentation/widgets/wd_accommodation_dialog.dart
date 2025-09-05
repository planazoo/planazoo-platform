import 'package:flutter/material.dart';
import '../../domain/models/accommodation.dart';
import '../../domain/services/accommodation_service.dart';

class AccommodationDialog extends StatefulWidget {
  final Accommodation? accommodation;
  final String planId;
  final DateTime planStartDate;
  final DateTime planEndDate;
  final Function(Accommodation) onSaved;
  final Function(String) onDeleted;
  final Function(Accommodation, DateTime, DateTime) onMoved;

  const AccommodationDialog({
    super.key,
    this.accommodation,
    required this.planId,
    required this.planStartDate,
    required this.planEndDate,
    required this.onSaved,
    required this.onDeleted,
    required this.onMoved,
  });

  @override
  State<AccommodationDialog> createState() => _AccommodationDialogState();
}

class _AccommodationDialogState extends State<AccommodationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _hotelNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late DateTime _checkIn;
  late DateTime _checkOut;
  String _selectedColor = 'blue';
  bool _isLoading = false;
  
  final AccommodationService _accommodationService = AccommodationService();

  @override
  void initState() {
    super.initState();
    
    if (widget.accommodation != null) {
      // Modo edición
      _hotelNameController.text = widget.accommodation!.hotelName;
      _descriptionController.text = widget.accommodation!.description ?? '';
      _checkIn = widget.accommodation!.checkIn;
      _checkOut = widget.accommodation!.checkOut;
      _selectedColor = widget.accommodation!.color ?? 'blue';
    } else {
      // Modo creación - usar fechas del plan
      _checkIn = widget.planStartDate;
      _checkOut = widget.planStartDate.add(const Duration(days: 1));
    }
  }

  @override
  void dispose() {
    _hotelNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.accommodation != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Editar Alojamiento' : 'Nuevo Alojamiento'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nombre del hotel
              TextFormField(
                controller: _hotelNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Hotel',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre del hotel es obligatorio';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Descripción
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 16),
              
              // Fecha de check-in
              ListTile(
                title: const Text('Check-in'),
                subtitle: Text(
                  '${_checkIn.day}/${_checkIn.month}/${_checkIn.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(true),
              ),
              
              // Fecha de check-out
              ListTile(
                title: const Text('Check-out'),
                subtitle: Text(
                  '${_checkOut.day}/${_checkOut.month}/${_checkOut.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(false),
              ),
              
              const SizedBox(height: 16),
              
              // Selector de color
              DropdownButtonFormField<String>(
                value: _selectedColor,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'red', child: _buildColorOption('red', 'Rojo')),
                  DropdownMenuItem(value: 'blue', child: _buildColorOption('blue', 'Azul')),
                  DropdownMenuItem(value: 'green', child: _buildColorOption('green', 'Verde')),
                  DropdownMenuItem(value: 'yellow', child: _buildColorOption('yellow', 'Amarillo')),
                  DropdownMenuItem(value: 'purple', child: _buildColorOption('purple', 'Morado')),
                  DropdownMenuItem(value: 'orange', child: _buildColorOption('orange', 'Naranja')),
                  DropdownMenuItem(value: 'pink', child: _buildColorOption('pink', 'Rosa')),
                  DropdownMenuItem(value: 'brown', child: _buildColorOption('brown', 'Marrón')),
                  DropdownMenuItem(value: 'grey', child: _buildColorOption('grey', 'Gris')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedColor = value;
                    });
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              // Duración calculada
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Duración:'),
                    Text(
                      '${_checkOut.difference(_checkIn).inDays} días',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (isEditing) ...[
          // Botón de eliminar solo en modo edición
          TextButton(
            onPressed: _isLoading ? null : _deleteAccommodation,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
        
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        
        ElevatedButton(
          onPressed: _isLoading ? null : _saveAccommodation,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Actualizar' : 'Crear'),
        ),
      ],
    );
  }

  Widget _buildColorOption(String color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _getColorFromString(color),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Color _getColorFromString(String color) {
    switch (color.toLowerCase()) {
      case 'red': return const Color(0xFFE57373);
      case 'blue': return const Color(0xFF81C784);
      case 'green': return const Color(0xFF64B5F6);
      case 'yellow': return const Color(0xFFFFB74D);
      case 'purple': return const Color(0xFFBA68C8);
      case 'orange': return const Color(0xFFFF8A65);
      case 'pink': return const Color(0xFFF06292);
      case 'brown': return const Color(0xFFA1887F);
      case 'grey':
      case 'gray': return const Color(0xFF90A4AE);
      default: return const Color(0xFF64B5F6);
    }
  }

  Future<void> _selectDate(bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkIn : _checkOut,
      firstDate: widget.planStartDate,
      lastDate: widget.planEndDate,
    );
    
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
          // Asegurar que check-out no sea anterior a check-in
          if (_checkOut.isBefore(_checkIn)) {
            _checkOut = DateTime(_checkIn.year, _checkIn.month, _checkIn.day + 1);
          }
        } else {
          _checkOut = picked;
          // Asegurar que check-in no sea posterior a check-out
          if (_checkIn.isAfter(_checkOut)) {
            _checkIn = DateTime(_checkOut.year, _checkOut.month, _checkOut.day - 1);
          }
        }
      });
    }
  }

  Future<void> _saveAccommodation() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final accommodation = Accommodation(
        id: widget.accommodation?.id,
        planId: widget.planId,
        checkIn: _checkIn,
        checkOut: _checkOut,
        hotelName: _hotelNameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        color: _selectedColor,
        typeFamily: 'alojamiento',
        typeSubtype: 'hotel',
        createdAt: widget.accommodation?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Verificar conflictos de fechas
      final hasConflict = await _accommodationService.hasDateConflict(
        accommodation,
        excludeId: widget.accommodation?.id,
      );

      if (hasConflict) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hay un conflicto de fechas con otro alojamiento'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final success = await _accommodationService.saveAccommodation(accommodation);
      
      if (success && mounted) {
        widget.onSaved(accommodation);
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.accommodation != null 
                  ? 'Alojamiento actualizado' 
                  : 'Alojamiento creado'
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al guardar el alojamiento'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAccommodation() async {
    if (widget.accommodation?.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar este alojamiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _accommodationService.deleteAccommodation(widget.accommodation!.id!);
        
        if (success && mounted) {
          widget.onDeleted(widget.accommodation!.id!);
          Navigator.of(context).pop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alojamiento eliminado'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al eliminar el alojamiento'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
