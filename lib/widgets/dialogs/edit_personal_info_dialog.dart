import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/services/event_service.dart';
import 'package:unp_calendario/shared/models/permission.dart';
import 'package:unp_calendario/shared/models/plan_permissions.dart';
import 'package:unp_calendario/shared/models/user_role.dart';
import 'package:unp_calendario/shared/services/permission_service.dart';

/// Diálogo para editar información personal de otros participantes
class EditPersonalInfoDialog extends ConsumerStatefulWidget {
  final Event event;
  final String participantId;
  final String participantName;
  final String planId;
  final Function(Event)? onSaved;

  const EditPersonalInfoDialog({
    super.key,
    required this.event,
    required this.participantId,
    required this.participantName,
    required this.planId,
    this.onSaved,
  });

  @override
  ConsumerState<EditPersonalInfoDialog> createState() => _EditPersonalInfoDialogState();
}

class _EditPersonalInfoDialogState extends ConsumerState<EditPersonalInfoDialog> {
  late TextEditingController _asientoController;
  late TextEditingController _menuController;
  late TextEditingController _preferenciasController;
  late TextEditingController _numeroReservaController;
  late TextEditingController _gateController;
  late TextEditingController _notasPersonalesController;
  late bool _tarjetaObtenida;
  
  PlanPermissions? _userPermissions;
  bool _isLoading = true;
  bool _hasPermission = false;
  final PermissionService _permissionService = PermissionService();

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _checkPermissions();
  }

  void _initializeFields() {
    final personalPart = widget.event.personalParts?[widget.participantId];
    final personalFields = personalPart?.fields ?? {};
    
    _asientoController = TextEditingController(text: personalFields['asiento'] ?? '');
    _menuController = TextEditingController(text: personalFields['menu'] ?? '');
    _preferenciasController = TextEditingController(text: personalFields['preferencias'] ?? '');
    _numeroReservaController = TextEditingController(text: personalFields['numeroReserva'] ?? '');
    _gateController = TextEditingController(text: personalFields['gate'] ?? '');
    _notasPersonalesController = TextEditingController(text: personalFields['notasPersonales'] ?? '');
    _tarjetaObtenida = personalFields['tarjetaObtenida'] ?? false;
  }

  Future<void> _checkPermissions() async {
    // Obtener permisos del usuario actual (simulado por ahora)
    // En una implementación real, obtendríamos el userId del contexto de autenticación
    final currentUserId = 'cristian_claraso'; // TODO: Obtener del contexto de auth
    
    final permissionService = PermissionService();
    _userPermissions = await permissionService.getUserPermissions(
      widget.planId,
      currentUserId,
    );

    _hasPermission = _userPermissions?.hasPermission(Permission.eventEditOthersPersonal) ?? false;
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _asientoController.dispose();
    _menuController.dispose();
    _preferenciasController.dispose();
    _numeroReservaController.dispose();
    _gateController.dispose();
    _notasPersonalesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Verificando permisos...'),
          ],
        ),
      );
    }

    if (!_hasPermission) {
      return AlertDialog(
        title: const Text('Sin permisos'),
        content: const Text('No tienes permisos para editar la información personal de otros participantes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.edit, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Editar información de ${widget.participantName}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del evento
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Evento: ${widget.event.commonPart?.description ?? "Sin descripción"}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fecha: ${widget.event.commonPart?.date.day}/${widget.event.commonPart?.date.month}/${widget.event.commonPart?.date.year}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Botón temporal para hacer admin (solo para testing)
              if (_userPermissions?.isAdmin ?? false)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🔧 ADMINISTRACIÓN (TEMPORAL)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _makeAdmin(),
                        icon: const Icon(Icons.admin_panel_settings),
                        label: const Text('Hacer Administrador'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Campos de información personal
              _buildField('Asiento', _asientoController, Icons.chair),
              _buildField('Menú', _menuController, Icons.restaurant_menu),
              _buildField('Preferencias', _preferenciasController, Icons.favorite),
              _buildField('Número de reserva', _numeroReservaController, Icons.confirmation_number),
              _buildField('Gate', _gateController, Icons.flight_takeoff),
              _buildField('Notas personales', _notasPersonalesController, Icons.note),
              
              const SizedBox(height: 16),
              
              // Tarjeta obtenida
              SwitchListTile(
                title: const Text('Tarjeta obtenida'),
                subtitle: const Text('¿Ya tienes la tarjeta de embarque/reserva?'),
                value: _tarjetaObtenida,
                onChanged: (value) {
                  setState(() {
                    _tarjetaObtenida = value;
                  });
                },
                secondary: const Icon(Icons.credit_card),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _savePersonalInfo,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        maxLines: label == 'Notas personales' ? 3 : 1,
      ),
    );
  }

  Future<void> _savePersonalInfo() async {
    try {
      // Crear nueva información personal
      final personalFields = {
        'asiento': _asientoController.text.trim(),
        'menu': _menuController.text.trim(),
        'preferencias': _preferenciasController.text.trim(),
        'numeroReserva': _numeroReservaController.text.trim(),
        'gate': _gateController.text.trim(),
        'notasPersonales': _notasPersonalesController.text.trim(),
        'tarjetaObtenida': _tarjetaObtenida,
      };

      // Crear EventPersonalPart actualizada
      final updatedPersonalPart = EventPersonalPart(
        participantId: widget.participantId,
        fields: personalFields,
      );

      // Actualizar el evento
      final updatedPersonalParts = Map<String, EventPersonalPart>.from(widget.event.personalParts ?? {});
      updatedPersonalParts[widget.participantId] = updatedPersonalPart;

      final updatedEvent = widget.event.copyWith(
        personalParts: updatedPersonalParts,
      );

      // Guardar en Firestore
      final eventService = EventService();
      await eventService.updateEvent(updatedEvent);

      // Mostrar confirmación
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Información de ${widget.participantName} actualizada'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Llamar callback si existe
        widget.onSaved?.call(updatedEvent);
        
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Método temporal para hacer admin a un usuario (solo para testing)
  Future<void> _makeAdmin() async {
    try {
      final currentUserId = 'cristian_claraso'; // TODO: Obtener del contexto de auth
      
      final success = await _permissionService.updateUserRole(
        planId: widget.planId,
        userId: widget.participantId,
        newRole: UserRole.admin,
        updatedBy: currentUserId,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.participantName} ahora es administrador'),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al asignar rol de administrador'),
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
    }
  }
}
