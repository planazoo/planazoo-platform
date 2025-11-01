import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/shared/utils/color_utils.dart';
import 'package:unp_calendario/features/security/utils/sanitizer.dart';

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
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _hotelNameController;
  late TextEditingController _descriptionController;
  late DateTime _selectedCheckIn;
  late DateTime _selectedCheckOut;
  late String _selectedColor;
  late List<String> _selectedParticipantTrackIds;

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
    
    // Normalizar tipo de alojamiento (capitalizar primera letra)
    final typeFromDB = widget.accommodation?.typeSubtype ?? '';
    _selectedType = _normalizeType(typeFromDB);
    
    // Inicializar participantes seleccionados
    _selectedParticipantTrackIds = widget.accommodation?.participantTrackIds ?? [];
  }
  
  /// Normaliza el tipo de alojamiento a formato capitalizado
  String _normalizeType(String type) {
    if (type.isEmpty) return 'Hotel';
    
    // Si el tipo está en la lista de tipos disponibles, devolverlo tal cual
    if (_accommodationTypes.contains(type)) {
      return type;
    }
    
    // Capitalizar la primera letra
    if (type.isNotEmpty) {
      return type[0].toUpperCase() + type.substring(1).toLowerCase();
    }
    
    return 'Hotel';
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
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del hotel/alojamiento
            TextFormField(
              controller: _hotelNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del alojamiento',
                hintText: 'Hotel, apartamento, etc.',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.hotel),
              ),
              maxLines: 1,
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return 'El nombre del alojamiento es obligatorio';
                if (v.length < 2) return 'Mínimo 2 caracteres';
                if (v.length > 100) return 'Máximo 100 caracteres';
                return null;
              },
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
              validator: (value) {
                // Validar que el valor esté en la lista
                if (value == null || !_accommodationTypes.contains(value)) {
                  return 'Tipo de alojamiento inválido';
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
                hintText: 'Notas adicionales',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return null;
                if (v.length > 1000) return 'Máximo 1000 caracteres';
                return null;
              },
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
            
            const SizedBox(height: 24),
            
            // Selección de participantes
            _buildParticipantSelection(),
          ],
        ),
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
    
    if (!mounted) return;
    
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
    
    if (!mounted) return;
    
    if (picked != null && picked != _selectedCheckOut) {
      setState(() {
        _selectedCheckOut = picked;
      });
    }
  }

  Color _getColorFromName(String colorName) {
    return ColorUtils.colorFromName(colorName);
  }

  /// Construye la sección de selección de participantes
  Widget _buildParticipantSelection() {
    return Consumer(
      builder: (context, ref, child) {
        final participationsAsync = ref.watch(planRealParticipantsProvider(widget.planId));
        
        return participationsAsync.when(
          data: (participations) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Participantes:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: participations.map((participation) {
                    final isSelected = _selectedParticipantTrackIds.contains(participation.userId);
                    return FutureBuilder<String>(
                      future: _getUserDisplayName(participation.userId),
                      builder: (context, snapshot) {
                        final displayName = snapshot.data ?? participation.userId;
                        return FilterChip(
                          label: Text(displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedParticipantTrackIds.add(participation.userId);
                              } else {
                                _selectedParticipantTrackIds.remove(participation.userId);
                              }
                            });
                          },
                          selectedColor: Colors.blue.shade100,
                          checkmarkColor: Colors.blue.shade800,
                        );
                      },
                    );
                  }).toList(),
                ),
                if (_selectedParticipantTrackIds.isEmpty)
                  const Text(
                    'Sin participantes seleccionados (aparecerá en el primer track)',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stackTrace) => Text(
            'Error al cargar participantes: $error',
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        );
      },
    );
  }

  /// Obtiene el nombre de visualización de un usuario
  Future<String> _getUserDisplayName(String userId) async {
    // Mapeo de user IDs a nombres reales para el plan Frankenstein
    final userNames = {
      'uJRMMGniO2bwfbdD3S11QMXQT912': 'Cristian Claraso',
      'mar_batllori': 'Mar Batllori',
      'emma_claraso': 'Emma Claraso',
      'matilde_claraso': 'Matilde Claraso',
      'jimena_claraso': 'Jimena Claraso',
    };
    
    return userNames[userId] ?? userId;
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
    if (!_formKey.currentState!.validate()) {
      return;
    }
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

    // Normalizar el tipo seleccionado antes de guardar
    final normalizedType = _normalizeType(_selectedType);

    final accommodation = Accommodation(
      id: widget.accommodation?.id,
      planId: widget.planId,
      checkIn: _selectedCheckIn,
      checkOut: _selectedCheckOut,
      hotelName: Sanitizer.sanitizePlainText(_hotelNameController.text, maxLength: 100),
      description: Sanitizer.sanitizePlainText(_descriptionController.text, maxLength: 1000).isEmpty
          ? null
          : Sanitizer.sanitizePlainText(_descriptionController.text, maxLength: 1000),
      color: _selectedColor,
      typeFamily: 'alojamiento',
      typeSubtype: normalizedType,
      participantTrackIds: _selectedParticipantTrackIds,
      createdAt: widget.accommodation?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.onSaved != null) {
      widget.onSaved!(accommodation);
    }
  }
}
