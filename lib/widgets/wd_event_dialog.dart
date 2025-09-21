import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/presentation/notifiers/calendar_notifier.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';

class EventDialog extends ConsumerStatefulWidget {
  final Event? event;
  final String? planId;
  final DateTime? initialDate;
  final int? initialHour;
  final Function(Event)? onSaved;
  final Function(String)? onDeleted;

  const EventDialog({
    super.key,
    this.event,
    this.planId,
    this.initialDate,
    this.initialHour,
    this.onSaved,
    this.onDeleted,
  });

  @override
  ConsumerState<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends ConsumerState<EventDialog> {
  late TextEditingController _descriptionController;
  late TextEditingController _typeFamilyController;
  late TextEditingController _typeSubtypeController;
  late DateTime _selectedDate;
  late int _selectedHour;
  late int _selectedDuration;
  late String _selectedColor;
  late bool _isDraft;

  // Colores predefinidos para eventos
  final List<String> _eventColors = [
    'blue',
    'green',
    'orange',
    'purple',
    'red',
    'teal',
    'indigo',
    'pink',
  ];

  // Familias de tipos de eventos
  final List<String> _typeFamilies = [
    'Desplazamiento',
    'Restauración',
    'Actividad',
    'Alojamiento',
    'Otro',
  ];

  // Subtipos por familia
  final Map<String, List<String>> _typeSubtypes = {
    'Desplazamiento': ['Taxi', 'Avión', 'Tren', 'Autobús', 'Coche', 'Caminar'],
    'Restauración': ['Desayuno', 'Comida', 'Cena', 'Snack', 'Bebida'],
    'Actividad': ['Museo', 'Monumento', 'Parque', 'Teatro', 'Concierto', 'Deporte'],
    'Alojamiento': ['Hotel', 'Apartamento', 'Hostal', 'Casa'],
    'Otro': ['Compra', 'Reunión', 'Trabajo', 'Personal'],
  };

  @override
  void initState() {
    super.initState();
    
    // Inicializar controladores
    _descriptionController = TextEditingController(
      text: widget.event?.description ?? '',
    );
    _typeFamilyController = TextEditingController(
      text: widget.event?.typeFamily ?? '',
    );
    _typeSubtypeController = TextEditingController(
      text: widget.event?.typeSubtype ?? '',
    );
    
    // Inicializar valores
    _selectedDate = widget.initialDate ?? widget.event?.date ?? DateTime.now();
    _selectedHour = widget.initialHour ?? widget.event?.hour ?? 9;
    _selectedDuration = widget.event?.duration ?? 1;
    _selectedColor = widget.event?.color ?? 'blue';
    _isDraft = widget.event?.isDraft ?? false;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _typeFamilyController.dispose();
    _typeSubtypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.event == null ? 'Crear Evento' : 'Editar Evento'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Descripción
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Nombre del evento',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
            // Tipo de familia
            DropdownButtonFormField<String>(
              value: _typeFamilyController.text.isEmpty || !_typeFamilies.contains(_typeFamilyController.text) 
                  ? null 
                  : _typeFamilyController.text,
              decoration: const InputDecoration(
                labelText: 'Tipo de evento',
                border: OutlineInputBorder(),
              ),
              items: _typeFamilies.map((family) {
                return DropdownMenuItem(
                  value: family,
                  child: Text(family),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _typeFamilyController.text = value ?? '';
                  _typeSubtypeController.text = ''; // Reset subtipo
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Subtipo
            if (_typeFamilyController.text.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _typeSubtypeController.text.isEmpty || 
                       !(_typeSubtypes[_typeFamilyController.text] ?? []).contains(_typeSubtypeController.text)
                    ? null 
                    : _typeSubtypeController.text,
                decoration: const InputDecoration(
                  labelText: 'Subtipo',
                  border: OutlineInputBorder(),
                ),
                items: (_typeSubtypes[_typeFamilyController.text] ?? []).map((subtype) {
                  return DropdownMenuItem(
                    value: subtype,
                    child: Text(subtype),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _typeSubtypeController.text = value ?? '';
                  });
                },
              ),
            const SizedBox(height: 16),
            
            // Borrador
            CheckboxListTile(
              title: const Text('Es borrador'),
              value: _isDraft,
              onChanged: (value) {
                setState(() {
                  _isDraft = value ?? false;
                });
              },
            ),
            
            // Fecha
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Fecha'),
              subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              onTap: _selectDate,
            ),
            
            // Hora
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Hora'),
              subtitle: Text('${_selectedHour.toString().padLeft(2, '0')}:00'),
              onTap: _selectHour,
            ),
            
            // Duración
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Duración'),
              subtitle: Text('$_selectedDuration hora${_selectedDuration > 1 ? 's' : ''}'),
              onTap: _selectDuration,
            ),
            
            // Color
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Color'),
              subtitle: Row(
                children: _eventColors.map((colorName) {
                  final color = _getColorFromName(colorName);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = colorName;
                      });
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _selectedColor == colorName 
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Botón eliminar (solo si es edición)
        if (widget.event != null)
          TextButton(
            onPressed: () {
              if (widget.onDeleted != null && widget.event?.id != null) {
                widget.onDeleted!(widget.event!.id!);
              }
            },
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
        
        // Botones de borrador (solo si es un evento existente)
        if (widget.event != null && widget.event!.id != null) ...[
          // Botón para cambiar estado de borrador
          TextButton(
            onPressed: () => _toggleDraftStatus(),
            child: Text(widget.event!.isDraft ? 'Confirmar' : 'Marcar como Borrador'),
          ),
        ],
        
        // Botón guardar
        ElevatedButton(
          onPressed: _saveEvent,
          child: Text(widget.event == null ? 'Crear' : 'Guardar'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectHour() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _selectedHour, minute: 0),
    );
    
    if (picked != null) {
      setState(() {
        _selectedHour = picked.hour;
      });
    }
  }

  Future<void> _selectDuration() async {
    final int? duration = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duración'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(12, (index) {
            final hours = index + 1;
            return ListTile(
              title: Text('$hours hora${hours > 1 ? 's' : ''}'),
              onTap: () => Navigator.of(context).pop(hours),
            );
          }),
        ),
      ),
    );
    
    if (duration != null) {
      setState(() {
        _selectedDuration = duration;
      });
    }
  }

  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'orange': return Colors.orange;
      case 'purple': return Colors.purple;
      case 'red': return Colors.red;
      case 'teal': return Colors.teal;
      case 'indigo': return Colors.indigo;
      case 'pink': return Colors.pink;
      default: return Colors.blue;
    }
  }

  Future<void> _toggleDraftStatus() async {
    if (widget.event == null || widget.event!.id == null) return;
    
    // Obtener el userId del usuario actual
    final currentUser = ref.read(currentUserProvider);
    final userId = currentUser?.id ?? '';
    
    // Necesitamos los parámetros para el provider family
    final params = CalendarNotifierParams(
      planId: widget.event!.planId,
      userId: userId,
      initialDate: widget.event!.date,
      initialColumnCount: 7,
    );
    
    final calendarNotifier = ref.read(calendarNotifierProvider(params).notifier);
    final success = await calendarNotifier.toggleEventDraftStatus(widget.event!);
    
    if (success) {
      // Cerrar el diálogo para refrescar la vista
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.event!.isDraft 
            ? 'Evento confirmado' 
            : 'Evento marcado como borrador'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cambiar el estado del evento'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveEvent() {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La descripción es obligatoria'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Obtener el userId del usuario actual
    final currentUser = ref.read(currentUserProvider);
    final userId = currentUser?.id ?? '';

    final event = Event(
      id: widget.event?.id, // Mantener el ID original si existe
      planId: widget.planId ?? '',
      userId: userId,
      description: _descriptionController.text.trim(),
      date: _selectedDate,
      hour: _selectedHour,
      duration: _selectedDuration,
      color: _selectedColor,
      typeFamily: _typeFamilyController.text.isEmpty ? null : _typeFamilyController.text,
      typeSubtype: _typeSubtypeController.text.isEmpty ? null : _typeSubtypeController.text,
      isDraft: _isDraft,
      createdAt: widget.event?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.onSaved != null) {
      widget.onSaved!(event);
    }
  }
}