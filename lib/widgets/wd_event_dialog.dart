import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/presentation/notifiers/calendar_notifier.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/shared/utils/color_utils.dart';

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
  late int _selectedStartMinute;
  late int _selectedDurationMinutes;
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
    _selectedStartMinute = widget.event?.startMinute ?? 0;
    _selectedDurationMinutes = widget.event?.durationMinutes ?? 60;
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
            
            // Borrador - Switch estilo iOS
            SwitchListTile.adaptive(
              title: const Text('Es borrador'),
              subtitle: const Text('Los borradores se muestran con menor opacidad'),
              value: _isDraft,
              onChanged: (value) {
                setState(() {
                  _isDraft = value;
                });
              },
            ),
            const SizedBox(height: 8),
            
            // Fecha - Con estilo editable
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fecha',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit, size: 20, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Hora - Con estilo editable
            InkWell(
              onTap: _selectStartTime,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hora de inicio',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_selectedHour.toString().padLeft(2, '0')}:${_selectedStartMinute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit, size: 20, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Duración - Con estilo editable
            InkWell(
              onTap: _selectDuration,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Duración',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDuration(_selectedDurationMinutes),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit, size: 20, color: Colors.grey.shade400),
                  ],
                ),
              ),
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

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _selectedHour, minute: _selectedStartMinute),
    );
    
    if (picked != null) {
      setState(() {
        _selectedHour = picked.hour;
        _selectedStartMinute = picked.minute;
      });
    }
  }

  Future<void> _selectDuration() async {
    final int? durationMinutes = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duración'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Opciones rápidas comunes (hasta 3 horas = 180 min)
              const Text('Duración común:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...List.generate(12, (index) {
                final minutes = (index + 1) * 15; // 15, 30, 45, 60, 75, 90, etc.
                return ListTile(
                  title: Text(_formatDuration(minutes)),
                  onTap: () => Navigator.of(context).pop(minutes),
                );
              }),
              const Divider(),
              // Opciones personalizadas (hasta 24 horas)
              const Text('Duraciones largas:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...List.generate(21, (index) {
                final hours = index + 4; // 4h, 5h, 6h... hasta 24h
                final minutes = hours * 60;
                return ListTile(
                  title: Text(_formatDuration(minutes)),
                  onTap: () => Navigator.of(context).pop(minutes),
                  trailing: hours == 24 
                      ? const Text('(máximo)', style: TextStyle(fontSize: 11, color: Colors.grey))
                      : null,
                );
              }),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '💡 Eventos máximo 24h.\nSi necesitas más → usa Alojamientos',
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    if (durationMinutes != null) {
      setState(() {
        _selectedDurationMinutes = durationMinutes;
        _selectedDuration = (durationMinutes / 60).ceil(); // Mantener compatibilidad
      });
    }
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes} min';
    } else if (minutes == 60) {
      return '1 hora';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}min';
      }
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
        content: Text('¿Estás seguro de que quieres eliminar el evento "${widget.event?.description}"?'),
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

    if (confirmed == true && widget.onDeleted != null && widget.event?.id != null) {
      widget.onDeleted!(widget.event!.id!);
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

    // Validar que el evento no dure más de 24 horas
    if (_selectedDurationMinutes > 1440) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠️ Un evento no puede durar más de 24 horas.\n\n'
            '• Si es alojamiento → usa la fila de Alojamientos\n'
            '• Si son actividades diferentes → crea eventos separados por día',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 6),
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
      startMinute: _selectedStartMinute,
      durationMinutes: _selectedDurationMinutes,
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