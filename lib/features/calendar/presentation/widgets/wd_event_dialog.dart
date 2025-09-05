import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../shared/services/logger_service.dart';
import '../../domain/models/event.dart';
import '../../domain/services/event_service.dart';

class EventDialog extends StatefulWidget {
  final Event? event;
  final String planId;
  final DateTime date;
  final int hour;
  final bool Function(DateTime date, int startHour, int duration, String? excludeEventId)? validateEvent; // nuevo

  const EventDialog({
    super.key,
    this.event,
    required this.planId,
    required this.date,
    required this.hour,
    this.validateEvent,
  });

  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _eventService = EventService();

  // Tipificación
  String? _family; // desplazamiento, restauracion, actividad
  String? _subtype; // taxi, avion, comida, museo, etc.
  Map<String, dynamic> _details = {};

  String? _selectedColor;
  int _selectedDuration = 1;
  late DateTime _selectedDate; // Usar late para inicialización diferida
  late int _selectedHour; // Usar late para inicialización diferida
  List<EventDocument> _documents = []; // Nueva: lista de documentos
  bool _isSaving = false;
  bool _hasConflict = false; // nuevo
  bool _isDraft = false; // nuevo: estado de borrador

  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Sin color', 'value': null, 'color': Colors.grey},
    {'name': 'Azul', 'value': 'blue', 'color': Colors.blue},
    {'name': 'Verde', 'value': 'green', 'color': Colors.green},
    {'name': 'Rojo', 'value': 'red', 'color': Colors.red},
    {'name': 'Amarillo', 'value': 'yellow', 'color': Colors.yellow},
    {'name': 'Naranja', 'value': 'orange', 'color': Colors.orange},
    {'name': 'Púrpura', 'value': 'purple', 'color': Colors.purple},
  ];

  final Map<String, List<String>> _familiesToSubtypes = const {
    'desplazamiento': ['taxi', 'avion', 'tren', 'ferry', 'bus', 'coche', 'alquiler (recogida)', 'alquiler (devolución)'],
    'restauracion': ['desayuno', 'brunch', 'comida', 'cena'],
    'actividad': ['museo', 'lugar turístico', 'actividad deportiva'],
    'alojamiento': ['hotel', 'apartamento', 'casa rural'],
  };

  // Defaults por subtipo
  Map<String, dynamic> _getDefaults(String? family, String? subtype) {
    if (family == 'desplazamiento') {
      switch (subtype) {
        case 'taxi':
          return {'color': 'yellow', 'duration': 1};
        case 'avion':
          return {'color': 'blue', 'duration': 3};
        case 'tren':
          return {'color': 'green', 'duration': 2};
        case 'ferry':
          return {'color': 'blue', 'duration': 2};
        case 'bus':
          return {'color': 'orange', 'duration': 1};
        case 'coche':
          return {'color': 'orange', 'duration': 1};
        case 'alquiler (recogida)':
          return {'color': 'orange', 'duration': 1};
        case 'alquiler (devolución)':
          return {'color': 'orange', 'duration': 1};
      }
      return {'color': 'blue', 'duration': 1};
    }
    if (family == 'restauracion') {
      switch (subtype) {
        case 'desayuno':
          return {'color': 'orange', 'duration': 1};
        case 'brunch':
          return {'color': 'orange', 'duration': 2};
        case 'comida':
          return {'color': 'red', 'duration': 2};
        case 'cena':
          return {'color': 'red', 'duration': 2};
      }
      return {'color': 'red', 'duration': 1};
    }
    if (family == 'actividad') {
      switch (subtype) {
        case 'museo':
          return {'color': 'purple', 'duration': 2};
        case 'lugar turístico':
          return {'color': 'purple', 'duration': 2};
        case 'actividad deportiva':
          return {'color': 'green', 'duration': 2};
      }
      return {'color': 'purple', 'duration': 2};
    }
    if (family == 'alojamiento') {
      return {'color': 'purple', 'duration': 1};
    }
    return {'color': null, 'duration': 1};
  }

  void _applyDefaultsFromSelection() {
    final def = _getDefaults(_family, _subtype);
    setState(() {
      _selectedColor = def['color'] as String? ?? _selectedColor;
      _selectedDuration = def['duration'] as int? ?? _selectedDuration;
    });
    _validateConflict();
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date; // Inicializar fecha editable
    _selectedHour = widget.hour; // Inicializar hora editable
    
    if (widget.event != null) {
      _descriptionController.text = widget.event!.description;
      _selectedColor = widget.event!.color;
      _selectedDuration = widget.event!.duration;
      _family = widget.event!.typeFamily;
      _subtype = widget.event!.typeSubtype;
      _details = Map<String, dynamic>.from(widget.event!.details ?? {});
      _selectedDate = widget.event!.date; // Usar fecha del evento si existe
      _selectedHour = widget.event!.hour; // Usar hora del evento si existe
      _documents = List<EventDocument>.from(widget.event!.documents ?? []); // Cargar documentos existentes
      _isDraft = widget.event!.isDraft; // Cargar estado de borrador
    } else {
      // Preselección por defecto para facilitar la creación: alquiler (recogida)
      _family = 'desplazamiento';
      final subs = _familiesToSubtypes[_family] ?? [];
      _subtype = subs.contains('alquiler (recogida)') ? 'alquiler (recogida)' : (subs.isNotEmpty ? subs.first : null);
      _applyDefaultsFromSelection();
      _isDraft = true; // Por defecto, nuevos eventos son borradores
    }
    _validateConflict();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _validateConflict() {
    final validator = widget.validateEvent;
    if (validator != null) {
      final excludeId = widget.event?.id;
      final conflict = validator(_selectedDate, _selectedHour, _selectedDuration, excludeId);
      setState(() {
        _hasConflict = conflict;
      });
    }
  }

  Future<void> _saveEvent() async {

    LoggerService.debug('Context mounted en _saveEvent: ${mounted}', context: 'EVENT_DIALOG');
    
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa los campos requeridos (tipo y subtipo).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_hasConflict) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conflicto de horarios. Ajusta la duración.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now();
      final event = Event(
        id: widget.event?.id,
        planId: widget.planId,
        date: _selectedDate,
        hour: _selectedHour,
        duration: _selectedDuration,
        description: _descriptionController.text.trim(),
        color: _selectedColor,
        typeFamily: _family,
        typeSubtype: _subtype,
        details: _details.isEmpty ? null : _details,
        documents: _documents.isEmpty ? null : _documents, // Incluir documentos
        createdAt: widget.event?.createdAt ?? now,
        updatedAt: now,
        isDraft: _isDraft, // Incluir el estado de borrador
      );

      final success = await _eventService.saveEvent(event);

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(event);
        } else {
          LoggerService.warning('Context no está mounted, no se puede cerrar el diálogo', context: 'EVENT_DIALOG');
        }
      } else {
        LoggerService.error('Error al guardar el evento', context: 'EVENT_DIALOG');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al guardar el evento'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.error('Excepción al guardar evento: $e', context: 'EVENT_DIALOG', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el evento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteEvent() async {
    if (widget.event?.id == null) return;
    final ok = await _eventService.deleteEvent(widget.event!.id!);
    if (mounted) {
      if (ok) {
        Navigator.of(context).pop(null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar el evento'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _pickReturnDateHour() async {
    // Seleccionar fecha
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (pickedDate == null) return null;

    int selectedHour = widget.hour;
    int selectedDuration = 1;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar hora de devolución'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hora:'),
              const SizedBox(height: 8),
              DropdownButton<int>(
                value: selectedHour,
                items: List.generate(24, (i) => i).map((h) => DropdownMenuItem(
                  value: h,
                  child: Text('${h.toString().padLeft(2, '0')}:00'),
                )).toList(),
                onChanged: (v) {
                  if (v == null) return;
                  selectedHour = v;
                  (context as Element).markNeedsBuild();
                },
              ),
              const SizedBox(height: 12),
              const Text('Duración:'),
              const SizedBox(height: 8),
              DropdownButton<int>(
                value: selectedDuration,
                items: List.generate(8, (i) => i + 1).map((d) => DropdownMenuItem(
                  value: d,
                  child: Text('$d ${d == 1 ? 'hora' : 'horas'}'),
                )).toList(),
                onChanged: (v) {
                  if (v == null) return;
                  selectedDuration = v;
                  (context as Element).markNeedsBuild();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );

    if (result != true) return null;
    return {
      'date': DateTime(pickedDate.year, pickedDate.month, pickedDate.day),
      'hour': selectedHour,
      'duration': selectedDuration,
    };
  }

  Future<void> _createReturnEvent() async {
    // Solo aplica cuando es alquiler (recogida)
    if (!((_family ?? '').toLowerCase().contains('desplazamiento')) || _subtype != 'alquiler (recogida)') {
      return;
    }

    final picked = await _pickReturnDateHour();
    if (picked == null) return;
    final DateTime retDate = picked['date'] as DateTime;
    final int retHour = picked['hour'] as int;
    final int retDuration = picked['duration'] as int;

    // Validar conflicto
    final conflict = widget.validateEvent?.call(retDate, retHour, retDuration, null) ?? false;
    if (conflict) {
      // Verificar que el widget esté montado antes de usar el context
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede crear devolución: conflicto de horarios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final newEvent = Event(
      planId: widget.planId,
      date: retDate,
      hour: retHour,
      duration: retDuration,
      description: (_descriptionController.text.isNotEmpty)
          ? 'Devolución: ${_descriptionController.text.trim()}'
          : 'Devolución coche de alquiler',
      color: _selectedColor ?? 'orange',
      typeFamily: 'desplazamiento',
      typeSubtype: 'alquiler (devolución)',
      details: _details.isEmpty ? null : _details,
      createdAt: now,
      updatedAt: now,
      isDraft: true, // Las devoluciones son borradores
    );

    final ok = await _eventService.saveEvent(newEvent);
    if (mounted) {
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Devolución creada'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al crear la devolución'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTypeSelectors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Tipo de evento:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _family,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: _familiesToSubtypes.keys.map((fam) => DropdownMenuItem(
            value: fam,
            child: Text(fam[0].toUpperCase() + fam.substring(1)),
          )).toList(),
          onChanged: (value) {
            setState(() {
              _family = value;
              // reset subtipo
              final subtypes = _familiesToSubtypes[_family] ?? [];
              _subtype = subtypes.isNotEmpty ? subtypes.first : null;
              _details = {};
            });
            _applyDefaultsFromSelection();
          },
          validator: (_) => _family == null ? 'Selecciona una familia' : null,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _subtype,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: (_familiesToSubtypes[_family] ?? []).map((st) => DropdownMenuItem(
            value: st,
            child: Text(st[0].toUpperCase() + st.substring(1)),
          )).toList(),
          onChanged: (value) {
            setState(() {
              _subtype = value;
            });
            _applyDefaultsFromSelection();
          },
          validator: (_) => _subtype == null ? 'Selecciona un subtipo' : null,
        ),
      ],
    );
  }

  Widget _buildFamilySpecificFields() {
    // Campos mínimos por ejemplo. Se pueden ampliar
    if (_family == 'desplazamiento') {
      final isRental = (_subtype != null && _subtype!.toLowerCase().contains('alquiler'));
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          if (!isRental) ...[
            TextFormField(
              initialValue: _details['origen'] as String?,
              decoration: const InputDecoration(
                labelText: 'Origen',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _details['origen'] = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _details['destino'] as String?,
              decoration: const InputDecoration(
                labelText: 'Destino',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _details['destino'] = v,
            ),
          ] else ...[
            TextFormField(
              initialValue: _details['company'] as String?,
              decoration: const InputDecoration(
                labelText: 'Compañía de alquiler',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _details['company'] = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _details['bookingNumber'] as String?,
              decoration: const InputDecoration(
                labelText: 'Localizador / Contrato',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _details['bookingNumber'] = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _details['driverName'] as String?,
              decoration: const InputDecoration(
                labelText: 'Nombre del conductor',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _details['driverName'] = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _details['carCategory'] as String?,
              decoration: const InputDecoration(
                labelText: 'Categoría (p.ej., C, SUV)',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _details['carCategory'] = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _details['pickUpLocation'] as String?,
              decoration: const InputDecoration(
                labelText: 'Lugar de recogida',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _details['pickUpLocation'] = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _details['dropOffLocation'] as String?,
              decoration: const InputDecoration(
                labelText: 'Lugar de devolución',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _details['dropOffLocation'] = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _details['fuelPolicy'] as String?,
              decoration: const InputDecoration(
                labelText: 'Política de combustible',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _details['fuelPolicy'] = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _details['insurance'] as String?,
              decoration: const InputDecoration(
                labelText: 'Seguro',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _details['insurance'] = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _details['notes'] as String?,
              decoration: const InputDecoration(
                labelText: 'Notas',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (v) => _details['notes'] = v,
            ),
          ],
        ],
      );
    }

    if (_family == 'restauracion') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _details['lugar'] as String?,
            decoration: const InputDecoration(
              labelText: 'Lugar',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => _details['lugar'] = v,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _details['personas']?.toString(),
            decoration: const InputDecoration(
              labelText: 'Personas',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) => _details['personas'] = int.tryParse(v),
          ),
        ],
      );
    }

    if (_family == 'actividad') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _details['lugar'] as String?,
            decoration: const InputDecoration(
              labelText: 'Lugar',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => _details['lugar'] = v,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _details['nota'] as String?,
            decoration: const InputDecoration(
              labelText: 'Nota',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => _details['nota'] = v,
          ),
        ],
      );
    }

    if (_family == 'alojamiento') {
      DateTime? checkIn = (_details['checkIn'] != null) ? DateTime.tryParse(_details['checkIn']) : null;
      DateTime? checkOut = (_details['checkOut'] != null) ? DateTime.tryParse(_details['checkOut']) : null;

      Future<void> pickCheckIn() async {
        final picked = await showDatePicker(
          context: context,
          initialDate: checkIn ?? widget.date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (picked != null) {
          setState(() {
            checkIn = picked;
            _details['checkIn'] = picked.toIso8601String();
            // Si no hay checkOut o es anterior, ajustar
            if (checkOut == null || !checkOut!.isAfter(picked)) {
              final next = picked.add(const Duration(days: 1));
              checkOut = next;
              _details['checkOut'] = next.toIso8601String();
            }
          });
        }
      }

      Future<void> pickCheckOut() async {
        final picked = await showDatePicker(
          context: context,
          initialDate: checkOut ?? (checkIn ?? widget.date).add(const Duration(days: 1)),
          firstDate: (checkIn ?? widget.date),
          lastDate: DateTime(2035),
        );
        if (picked != null) {
          setState(() {
            checkOut = picked;
            _details['checkOut'] = picked.toIso8601String();
          });
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _details['hotelName'] as String?,
            decoration: const InputDecoration(
              labelText: 'Nombre del alojamiento',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => _details['hotelName'] = v,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _details['location'] as String?,
            decoration: const InputDecoration(
              labelText: 'Ubicación',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => _details['location'] = v,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: pickCheckIn,
                  child: Text(checkIn != null
                      ? 'Check-in: ${checkIn!.day}/${checkIn!.month}/${checkIn!.year}'
                      : 'Seleccionar Check-in'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: pickCheckOut,
                  child: Text(checkOut != null
                      ? 'Check-out: ${checkOut!.day}/${checkOut!.month}/${checkOut!.year}'
                      : 'Seleccionar Check-out'),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;
    final title = isEditing ? 'Editar Evento' : 'Crear Evento';
    final buttonText = isEditing ? 'Actualizar' : 'Crear';

    return AlertDialog(
      title: Text(title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fecha editable
              Row(
                children: [
                  const Text(
                    'Fecha: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                          _validateConflict();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Icon(Icons.calendar_today, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Hora editable
              Row(
                children: [
                  const Text(
                    'Hora: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedHour,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: List.generate(24, (index) => index).map((hour) {
                        return DropdownMenuItem<int>(
                          value: hour,
                          child: Text('${hour.toString().padLeft(2, '0')}:00'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedHour = value!;
                        });
                        _validateConflict();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tipo de evento
              _buildTypeSelectors(),

              // Campos específicos
              _buildFamilySpecificFields(),

              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Ej: Reunión con el equipo',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLines: 4,
                maxLength: 200,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Duración del evento:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedDuration,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: List.generate(8, (index) => index + 1).map((hours) {
                  return DropdownMenuItem<int>(
                    value: hours,
                    child: Text('$hours ${hours == 1 ? 'hora' : 'horas'}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDuration = value!;
                  });
                  _validateConflict();
                },
              ),
              if (_hasConflict) ...[
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Hay un evento que se solapa con esta duración.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              // Checkbox para estado de borrador
              Row(
                children: [
                  Checkbox(
                    value: _isDraft,
                    onChanged: (value) {
                      setState(() {
                        _isDraft = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Evento en borrador',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _isDraft 
                            ? 'Este evento aparecerá en gris hasta que sea confirmado'
                            : 'Este evento está confirmado y aparecerá con su color normal',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Color del evento:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _colorOptions.map((colorOption) {
                  final isSelected = _selectedColor == colorOption['value'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = colorOption['value'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? colorOption['color'] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? colorOption['color'] : Colors.grey[400]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        colorOption['name'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Sección de documentos
              _buildDocumentsSection(),
            ],
          ),
        ),
      ),
      actions: [
        if ((_family ?? '').toLowerCase().contains('desplazamiento') && _subtype == 'alquiler (recogida)')
          OutlinedButton.icon(
            onPressed: _isSaving ? null : _createReturnEvent,
            icon: const Icon(Icons.assignment_return),
            label: const Text('Crear devolución'),
          ),
        if (isEditing)
          TextButton(
            onPressed: _isSaving ? null : _deleteEvent,
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving || _hasConflict ? null : _saveEvent,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(buttonText),
        ),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Documentos adjuntos:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _addDocument,
              icon: const Icon(Icons.attach_file, size: 16),
              label: const Text('Añadir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_documents.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Text(
                'No hay documentos adjuntos',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _documents.length,
            itemBuilder: (context, index) {
              final doc = _documents[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    _getDocumentIcon(doc.type),
                    color: _getDocumentColor(doc.type),
                  ),
                  title: Text(
                    doc.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_formatFileSize(doc.size)} • ${doc.type.toUpperCase()}'),
                      if (doc.description != null && doc.description!.isNotEmpty)
                        Text(doc.description!, style: const TextStyle(fontStyle: FontStyle.italic)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeDocument(index),
                  ),
                  onTap: () => _viewDocument(doc),
                ),
              );
            },
          ),
      ],
    );
  }

  IconData _getDocumentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'image':
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getDocumentColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'image':
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.green;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'txt':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _addDocument() {
    // Por ahora, simulamos añadir un documento
    // En una implementación real, esto abriría un selector de archivos
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir Documento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Por ahora, esta funcionalidad está en desarrollo.'),
            const SizedBox(height: 16),
            const Text('En una versión futura podrás:'),
            const Text('• Seleccionar archivos del dispositivo'),
            const Text('• Subir a Firebase Storage'),
            const Text('• Vincular URLs externas'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _removeDocument(int index) {
    setState(() {
      _documents.removeAt(index);
    });
  }

  void _viewDocument(EventDocument document) {
    // Por ahora, mostramos información del documento
    // En una versión futura, esto abriría el documento
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(document.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${document.type.toUpperCase()}'),
            Text('Tamaño: ${_formatFileSize(document.size)}'),
            Text('Subido: ${_formatDate(document.uploadedAt)}'),
            if (document.description != null && document.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(document.description!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
} 