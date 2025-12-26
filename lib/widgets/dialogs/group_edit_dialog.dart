import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/participant_group.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/participant_group_providers.dart';
import 'package:unp_calendario/features/auth/domain/services/user_service.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';

/// T123: Diálogo para crear o editar grupos de participantes
class GroupEditDialog extends ConsumerStatefulWidget {
  final ParticipantGroup? group;
  final String userId;

  const GroupEditDialog({
    super.key,
    this.group,
    required this.userId,
  });

  @override
  ConsumerState<GroupEditDialog> createState() => _GroupEditDialogState();
}

class _GroupEditDialogState extends ConsumerState<GroupEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _iconController;
  late TextEditingController _emailController;
  late String _selectedColor;
  
  List<String> _memberUserIds = [];
  List<String> _memberEmails = [];
  List<UserModel> _allUsers = [];
  bool _isLoading = false;

  final List<String> _availableColors = [
    'blue',
    'green',
    'orange',
    'purple',
    'red',
    'teal',
    'indigo',
    'pink',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group?.name ?? '');
    _descriptionController = TextEditingController(text: widget.group?.description ?? '');
    _iconController = TextEditingController(text: widget.group?.icon ?? '');
    _emailController = TextEditingController();
    _selectedColor = widget.group?.color ?? 'blue';
    _memberUserIds = List<String>.from(widget.group?.memberUserIds ?? []);
    _memberEmails = List<String>.from(widget.group?.memberEmails ?? []);
    _loadUsers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _iconController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      final userService = UserService();
      final users = await userService.getAllUsers();
      setState(() {
        _allUsers = users;
      });
    } catch (e) {
      // Error loading users
    }
  }

  Color _getColorFromName(String colorName) {
    final colorMap = {
      'blue': Colors.blue,
      'green': Colors.green,
      'orange': Colors.orange,
      'purple': Colors.purple,
      'red': Colors.red,
      'teal': Colors.teal,
      'indigo': Colors.indigo,
      'pink': Colors.pink,
    };
    return colorMap[colorName] ?? Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.group == null ? 'Crear Grupo' : 'Editar Grupo'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del grupo *',
                    hintText: 'Ej: Familia Ramos, Amigos Universidad',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.group),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
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
                    hintText: 'Breve descripción del grupo',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Icono (emoji)
                TextFormField(
                  controller: _iconController,
                  decoration: const InputDecoration(
                    labelText: 'Icono (opcional)',
                    hintText: 'Ej: 👨‍👩‍👧‍👦, 🎉, ⚽',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.emoji_emotions),
                  ),
                ),
                const SizedBox(height: 16),

                // Color
                DropdownButtonFormField<String>(
                  value: _selectedColor,
                  decoration: const InputDecoration(
                    labelText: 'Color',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.palette),
                  ),
                  items: _availableColors.map((color) {
                    return DropdownMenuItem(
                      value: color,
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _getColorFromName(color),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(color[0].toUpperCase() + color.substring(1)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedColor = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Separador
                const Divider(),
                const SizedBox(height: 16),

                // Añadir miembro por email
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Añadir email',
                          hintText: 'usuario@ejemplo.com',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addEmail,
                      icon: const Icon(Icons.add),
                      tooltip: 'Añadir email',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Lista de miembros
                Text(
                  'Miembros (${_memberUserIds.length + _memberEmails.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                
                if (_memberUserIds.isEmpty && _memberEmails.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No hay miembros añadidos',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  )
                else
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        // Emails
                        ..._memberEmails.map((email) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.email, size: 20),
                          title: Text(email),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                            onPressed: () {
                              setState(() {
                                _memberEmails.remove(email);
                              });
                            },
                          ),
                        )),
                        // User IDs (mostrar nombres si es posible)
                        ..._memberUserIds.map((userId) {
                          final user = _allUsers.firstWhere(
                            (u) => u.id == userId,
                            orElse: () => UserModel(
                              id: userId,
                              email: userId,
                              createdAt: DateTime.now(),
                            ),
                          );
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.person, size: 20),
                            title: Text(user.displayName ?? user.email),
                            subtitle: Text(user.email, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                              onPressed: () {
                                setState(() {
                                  _memberUserIds.remove(userId);
                                });
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveGroup,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.group == null ? 'Crear' : 'Guardar'),
        ),
      ],
    );
  }

  void _addEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[A-Za-z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email inválido')),
      );
      return;
    }

    if (_memberEmails.contains(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este email ya está en el grupo')),
      );
      return;
    }

    setState(() {
      _memberEmails.add(email);
      _emailController.clear();
    });
  }

  Future<void> _saveGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final groupService = ref.read(participantGroupServiceProvider);
      
      if (widget.group == null) {
        // Crear nuevo grupo
        final id = await groupService.createGroup(
          userId: widget.userId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          icon: _iconController.text.trim().isEmpty 
              ? null 
              : _iconController.text.trim(),
          color: _selectedColor,
          memberUserIds: _memberUserIds,
          memberEmails: _memberEmails,
        );

        if (id != null && mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Grupo creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Actualizar grupo existente
        final updatedGroup = widget.group!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          icon: _iconController.text.trim().isEmpty 
              ? null 
              : _iconController.text.trim(),
          color: _selectedColor,
          memberUserIds: _memberUserIds,
          memberEmails: _memberEmails,
        );

        final success = await groupService.updateGroup(updatedGroup);

        if (success && mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Grupo actualizado exitosamente'),
              backgroundColor: Colors.green,
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

