import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/invitation_service.dart';
import 'package:flutter/services.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_invitation.dart';
import 'package:unp_calendario/features/security/utils/validator.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

class ParticipantsScreen extends ConsumerStatefulWidget {
  final Plan plan;
  final VoidCallback? onBack;

  const ParticipantsScreen({
    super.key,
    required this.plan,
    this.onBack,
  });

  @override
  ConsumerState<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends ConsumerState<ParticipantsScreen> {
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoadingUsers = true;
  String _searchQuery = '';
  
  final InvitationService _invitationService = InvitationService();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  UserModel? _findUser(String userId) {
    try {
      return _allUsers.firstWhere((user) => user.id == userId);
    } catch (_) {
      return null;
    }
  }

  String _formatUserDisplay(UserModel? user, String fallback) {
    if (user == null) return fallback;

    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      return user.displayName!;
    }
    if (user.username != null && user.username!.trim().isNotEmpty) {
      return '@${user.username!}';
    }
    return user.email;
  }

  String _initialsFor(UserModel? user, String fallback) {
    final source = user?.displayName?.trim();
    if (source != null && source.isNotEmpty) {
      final parts = source.split(' ');
      if (parts.length >= 2) {
        return (parts.first[0] + parts.last[0]).toUpperCase();
      }
      return source.substring(0, 1).toUpperCase();
    }
    if (user?.username != null && user!.username!.isNotEmpty) {
      return user.username![0].toUpperCase();
    }
    if (user != null) {
      return user.email[0].toUpperCase();
    }
    return fallback.isNotEmpty ? fallback.substring(0, 1).toUpperCase() : '?';
  }

  Future<void> _loadUsers() async {
    try {
      final userService = ref.read(userServiceProvider);
      final users = await userService.getAllUsers();
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
      });
      LoggerService.error('Error loading users', context: 'ParticipantsScreen', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar usuarios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers.where((user) {
          final name = (user.displayName ?? '').toLowerCase();
          final email = user.email.toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || email.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _inviteUser(UserModel user) async {
    try {
      final participationService = ref.read(planParticipationServiceProvider);
      final currentUser = ref.read(currentUserProvider);
      
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      await participationService.createParticipation(
        planId: widget.plan.id!,
        userId: user.id,
        role: 'participant',
        invitedBy: currentUser.id,
        autoAccept: true,
      );

      await ref.read(planParticipationNotifierProvider(widget.plan.id!).notifier).reload();
      ref
        ..invalidate(planParticipantsProvider(widget.plan.id!))
        ..invalidate(planRealParticipantsProvider(widget.plan.id!));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${user.displayName ?? user.email} invitado al plan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      LoggerService.error('Error inviting user', context: 'ParticipantsScreen', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al invitar usuario: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showInvitationLink(String invitationId) async {
    try {
      final inv = await _invitationService.getInvitationById(invitationId);
      if (inv == null || inv.token == null) return;
      final link = _invitationService.generateInvitationLink(inv.token!);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invitación creada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Comparte este enlace con la persona invitada:'),
              const SizedBox(height: 8),
              SelectableText(link),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: link));
                if (mounted) Navigator.of(context).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enlace copiado al portapapeles')),
                  );
                }
              },
              child: const Text('Copiar enlace'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      LoggerService.error('Error showing invitation link', context: 'ParticipantsScreen', error: e);
    }
  }

  Future<void> _inviteByEmailDialog() async {
    final emailController = TextEditingController();
    final messageController = TextEditingController();
    String role = 'participant';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Invitar por email'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'usuario@correo.com',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: role,
                  items: const [
                    DropdownMenuItem(value: 'participant', child: Text('Participante')),
                    DropdownMenuItem(value: 'observer', child: Text('Observador')),
                  ],
                  onChanged: (v) {
                    role = v ?? 'participant';
                  },
                  decoration: const InputDecoration(
                    labelText: 'Rol',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Mensaje (opcional)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Enviar invitación'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    final email = emailController.text.trim();
    if (email.isEmpty) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc?.emailRequired ?? 'El email es obligatorio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (!Validator.isValidEmail(email)) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc?.emailInvalid ?? 'El formato del email no es válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final currentUser = ref.read(currentUserProvider);
      final userService = ref.read(userServiceProvider);
      final participationService = ref.read(planParticipationServiceProvider);
      
      // Normalizar email para la búsqueda
      final normalizedEmail = email.toLowerCase().trim();
      
      // Verificar si el usuario ya es participante del plan
      final existingUser = await userService.getUserByEmail(normalizedEmail);
      if (existingUser != null) {
        final isAlreadyParticipant = await participationService.isUserParticipant(widget.plan.id!, existingUser.id);
        if (isAlreadyParticipant) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Este usuario ya es participante del plan'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
      }
      
      // Verificar si ya existe una invitación pendiente para este email
      final existingInvitation = await _invitationService.getPendingInvitationByEmail(
        widget.plan.id!,
        email,
      );
      
      if (existingInvitation != null) {
        // Ya existe una invitación pendiente, mostrar diálogo con opciones
        if (mounted) {
          final action = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Invitación pendiente'),
              content: Text(
                'Ya existe una invitación pendiente para $email.\n\n'
                '¿Qué deseas hacer?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop('cancel'),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop('cancel_invitation'),
                  child: const Text('Cancelar invitación anterior'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop('resend'),
                  child: const Text('Re-enviar invitación'),
                ),
              ],
            ),
          );
          
          if (action == 'cancel') {
            return; // Usuario canceló
          }
          
          if (action == 'cancel_invitation') {
            // Cancelar la invitación anterior
            final cancelled = await _invitationService.cancelInvitation(existingInvitation.id!);
            if (cancelled && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Invitación anterior cancelada'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            // Continuar para crear una nueva invitación
          } else if (action == 'resend') {
            // Re-enviar: mostrar el link de la invitación existente
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Re-enviando invitación a $email'),
                  backgroundColor: Colors.blue,
                ),
              );
              await _showInvitationLink(existingInvitation.id!);
              setState(() {});
            }
            return; // No crear nueva invitación, solo re-enviar
          }
        }
      }
      
      final invitationId = await _invitationService.createInvitation(
        planId: widget.plan.id!,
        email: email,
        invitedBy: currentUser?.id,
        role: role,
        customMessage: messageController.text.trim().isEmpty ? null : messageController.text.trim(),
      );

      if (invitationId == null) {
        // No se pudo crear la invitación (usuario ya participa, ya existe invitación pendiente, u otro error)
        // Verificar el motivo específico
        final existingInvitationCheck = await _invitationService.getPendingInvitationByEmail(
          widget.plan.id!,
          email,
        );
        
        if (existingInvitationCheck != null && mounted) {
          // Ya existe una invitación pendiente (caso edge: se creó entre la verificación y la creación)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Ya existe una invitación pendiente para este email'),
              backgroundColor: Colors.orange,
            ),
          );
        } else if (mounted) {
          // Otro error (probablemente usuario ya participa)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ No se pudo crear la invitación'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Verificar si realmente se creó una invitación (no una participación existente)
      // Las invitaciones tienen IDs que empiezan con ciertos caracteres o podemos verificar en la BD
      final invitation = await _invitationService.getInvitationById(invitationId);
      
      if (invitation != null && mounted) {
        // Es una invitación real, mostrar mensaje de éxito y link
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Invitación creada para $email'),
            backgroundColor: Colors.green,
          ),
        );
        await _showInvitationLink(invitationId);
        setState(() {}); // trigger UI refresh if needed
      } else if (mounted) {
        // Es una participación (usuario existente), mostrar mensaje diferente
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Usuario $email añadido al plan'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // trigger UI refresh if needed
      }
    } catch (e) {
      LoggerService.error('Error creating email invitation', context: 'ParticipantsScreen', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al crear invitación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _acceptRejectTokenDialog() async {
    final tokenController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    // Usar StatefulBuilder para manejar el estado dentro del diálogo
    bool isAccept = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Gestionar invitación por token'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: tokenController,
                  decoration: const InputDecoration(
                    labelText: 'Link o token de invitación',
                    hintText: 'Pega el link completo o solo el token',
                    helperText: 'Ejemplo: https://planazoo.app/invitation/abc123... o solo abc123...',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Introduce el link o token';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Aceptar'),
                        value: true,
                        groupValue: isAccept,
                        onChanged: (v) => setDialogState(() => isAccept = v ?? true),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Rechazar'),
                        value: false,
                        groupValue: isAccept,
                        onChanged: (v) => setDialogState(() => isAccept = v ?? false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(context).pop(true);
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      String input = tokenController.text.trim();
      
      // Extraer token del link si se pegó el link completo
      String token = input;
      if (input.contains('/invitation/')) {
        // Extraer token del link: https://planazoo.app/invitation/{token}
        final parts = input.split('/invitation/');
        if (parts.length > 1) {
          token = parts[1].split('?').first; // Remover query params si existen
        }
      }
      
      if (token.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Token inválido'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      final user = ref.read(currentUserProvider);
      if (!mounted) return;
      bool ok = false;
      if (isAccept) {
        if (user == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Debes iniciar sesión para aceptar invitaciones'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        ok = await _invitationService.acceptInvitationByToken(token, user.id);
        if (ok) {
          await ref.read(planParticipationNotifierProvider(widget.plan.id!).notifier).reload();
          ref
            ..invalidate(planParticipantsProvider(widget.plan.id!))
            ..invalidate(planRealParticipantsProvider(widget.plan.id!));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Invitación aceptada. Has sido añadido al plan.'),
                backgroundColor: Colors.green,
              ),
            );
          }
          setState(() {}); // Actualizar UI
        } else if (mounted) {
          // Si falló, mostrar mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ No se pudo procesar el token. Verifica que sea válido y no haya expirado.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ok = await _invitationService.rejectInvitationByToken(token);
        if (ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Invitación rechazada'),
              backgroundColor: Colors.orange,
            ),
          );
        } else if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ No se pudo procesar el token. Verifica que sea válido y no haya expirado.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _removeParticipant(PlanParticipation participation) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar a este participante del plan?'),
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
        final participationService = ref.read(planParticipationServiceProvider);
        await participationService.removeParticipation(widget.plan.id!, participation.userId);

        await ref.read(planParticipationNotifierProvider(widget.plan.id!).notifier).reload();
        ref
          ..invalidate(planParticipantsProvider(widget.plan.id!))
          ..invalidate(planRealParticipantsProvider(widget.plan.id!));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Participante eliminado del plan'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.error('Error removing participant', context: 'ParticipantsScreen', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al eliminar participante: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _changeRole(PlanParticipation participation, String newRole) async {
    try {
      final participationService = ref.read(planParticipationServiceProvider);
      await participationService.updateParticipation(
        participation.copyWith(role: newRole),
      );

      await ref.read(planParticipationNotifierProvider(widget.plan.id!).notifier).reload();
      ref
        ..invalidate(planParticipantsProvider(widget.plan.id!))
        ..invalidate(planRealParticipantsProvider(widget.plan.id!));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Rol actualizado a $newRole'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      LoggerService.error('Error updating role', context: 'ParticipantsScreen', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al actualizar rol: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildParticipantsList() {
    return Consumer(
      builder: (context, ref, child) {
        final participantsAsync = ref.watch(planParticipantsProvider(widget.plan.id!));
        
        return participantsAsync.when(
          data: (participations) => _buildParticipantsContent(participations),
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando participantes...'),
              ],
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error al cargar participantes: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(planParticipantsProvider(widget.plan.id!));
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticipantsContent(List<PlanParticipation> participations) {
    if (participations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay participantes en este plan',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: participations.map((participation) {
          return _buildParticipantCard(participation);
        }).toList(),
      ),
    );
  }

  Widget _buildParticipantCard(PlanParticipation participation) {
    final user = _findUser(participation.userId);
    final displayName = _formatUserDisplay(user, participation.userId);
    final usernameLabel = user?.username != null && user!.username!.trim().isNotEmpty
        ? '@${user.username!}'
        : null;
    final emailLabel = user?.email;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: _getRoleColor(participation.role),
              child: Text(
                _initialsFor(user, participation.userId),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Información del participante
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: AppTypography.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (usernameLabel != null) ...[
                    Text(
                      usernameLabel,
                      style: AppTypography.caption.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  if (emailLabel != null) ...[
                    Text(
                      emailLabel,
                      style: AppTypography.caption.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ] else
                    const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRoleColor(participation.role),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getRoleLabel(participation.role),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Se unió: ${_formatDate(participation.joinedAt)}',
                        style: AppTypography.caption.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Botones de acción
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'change_role':
                    _showRoleChangeDialog(participation);
                    break;
                  case 'remove':
                    _removeParticipant(participation);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'change_role',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Cambiar rol'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.remove_circle, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleChangeDialog(PlanParticipation participation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar rol'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Selecciona un nuevo rol para ${participation.userId}:'),
            const SizedBox(height: 16),
            _buildRoleOption(participation, 'organizer', 'Organizador'),
            _buildRoleOption(participation, 'participant', 'Participante'),
            _buildRoleOption(participation, 'observer', 'Observador'),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption(PlanParticipation participation, String role, String label) {
    return ListTile(
      leading: Radio<String>(
        value: role,
        groupValue: participation.role,
        onChanged: (value) {
          Navigator.of(context).pop();
          _changeRole(participation, value!);
        },
      ),
      title: Text(label),
      subtitle: Text(_getRoleDescription(role)),
    );
  }

  Widget _buildInviteUsersSection({required bool showCloseButton}) {
    return Consumer(
      builder: (context, ref, _) {
        final participantsAsync = ref.watch(planParticipantsProvider(widget.plan.id!));

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColorScheme.color0,
            border: Border(
              bottom: BorderSide(color: AppColorScheme.color2, width: 1),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Invitar usuarios',
                      style: AppTypography.titleStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Wrap(
                      spacing: 8,
                      children: [
                        TextButton.icon(
                          onPressed: _inviteByEmailDialog,
                          icon: const Icon(Icons.mail_outline),
                          label: const Text('Invitar por email'),
                        ),
                        TextButton.icon(
                          onPressed: _acceptRejectTokenDialog,
                          icon: const Icon(Icons.vpn_key_outlined),
                          label: const Text('Aceptar/Rechazar por token'),
                        ),
                        if (showCloseButton && widget.onBack != null)
                          IconButton(
                            onPressed: widget.onBack,
                            icon: const Icon(Icons.close),
                            tooltip: 'Cerrar',
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: _filterUsers,
                decoration: InputDecoration(
                  hintText: 'Buscar usuarios por nombre, email o @usuario...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              participantsAsync.when(
                data: (participations) {
                  final existingIds = participations.map((p) => p.userId).toSet();
                  final availableUsers = _filteredUsers
                      .where((user) => !existingIds.contains(user.id))
                      .toList();

                  if (_isLoadingUsers) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: availableUsers.isEmpty
                          ? Center(
                              child: Text(
                                _searchQuery.isEmpty
                                    ? 'No hay usuarios disponibles'
                                    : 'No se encontraron usuarios',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: availableUsers.length,
                              itemBuilder: (context, index) {
                                final user = availableUsers[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColorScheme.color2,
                                    child: Text(
                                      _computeInitials(user),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(_formatUserDisplay(user, user.email)),
                                  subtitle: Text(user.email),
                                  trailing: ElevatedButton(
                                    onPressed: () => _inviteUser(user),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColorScheme.color2,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Invitar'),
                                  ),
                                );
                              },
                            ),
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Container(
                  height: 120,
                  alignment: Alignment.center,
                  child: Text(
                    'No se pudo cargar la lista de participantes: $error',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'organizer':
        return Colors.purple;
      case 'participant':
        return Colors.blue;
      case 'observer':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'organizer':
        return 'Organizador';
      case 'participant':
        return 'Participante';
      case 'observer':
        return 'Observador';
      default:
        return 'Desconocido';
    }
  }

  String _getRoleDescription(String role) {
    switch (role) {
      case 'organizer':
        return 'Puede editar el plan y gestionar participantes';
      case 'participant':
        return 'Puede ver y participar en el plan';
      case 'observer':
        return 'Puede ver el plan sin realizar cambios';
      default:
        return '';
    }
  }

  String _computeInitials(UserModel user) {
    final display = user.displayName?.trim();
    if (display != null && display.isNotEmpty) {
      final parts = display.split(' ');
      if (parts.length >= 2) {
        return (parts.first[0] + parts.last[0]).toUpperCase();
      }
      return display.substring(0, 1).toUpperCase();
    }
    if (user.username != null && user.username!.trim().isNotEmpty) {
      return user.username![0].toUpperCase();
    }
    if (user.email.isNotEmpty) {
      return user.email[0].toUpperCase();
    }
    return '?';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildPendingInvitationsSection() {
    final currentUser = ref.watch(currentUserProvider);
    final isOwner = currentUser?.id == widget.plan.userId;
    return FutureBuilder<List<PlanInvitation>>(
      future: _invitationService.getPendingInvitations(widget.plan.id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(),
          );
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invitaciones pendientes', style: AppTypography.titleStyle),
              const SizedBox(height: 8),
              ...items.map((inv) {
                final created = inv.createdAt != null ? _formatDate(inv.createdAt!) : '';
                final expires = inv.expiresAt != null ? _formatDate(inv.expiresAt!) : '';
                return Card(
                  child: ListTile(
                    title: Text(inv.email ?? ''),
                    subtitle: Text('Rol: ${inv.role ?? 'participant'} • Creada: $created • Expira: $expires'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Copiar enlace',
                          icon: const Icon(Icons.link),
                          onPressed: () async {
                            if (inv.token != null) {
                              final link = _invitationService.generateInvitationLink(inv.token!);
                              await Clipboard.setData(ClipboardData(text: link));
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Enlace copiado')),
                                );
                              }
                            }
                          },
                        ),
                        if (isOwner && inv.id != null)
                          IconButton(
                            tooltip: 'Cancelar',
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () async {
                              final ok = await _invitationService.cancelInvitation(inv.id!);
                              if (ok) {
                                if (mounted) setState(() {});
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Invitación cancelada')),
                                  );
                                }
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('No se pudo cancelar')),
                                  );
                                }
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyInvitationsSection() {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();
    return FutureBuilder<List<PlanInvitation>>(
      future: _invitationService.getPendingInvitationsByEmail(user.email),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        final hasPendingInvitations = items.isNotEmpty;
        
        return Container(
          margin: const EdgeInsets.all(12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: hasPendingInvitations ? Colors.orange.shade50 : Colors.blue.shade50,
            border: Border.all(
              color: hasPendingInvitations ? Colors.orange.shade200 : Colors.blue.shade200,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                hasPendingInvitations ? Icons.mail_outline : Icons.info_outline,
                color: hasPendingInvitations ? Colors.orange : Colors.blue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hasPendingInvitations
                          ? 'Tienes ${items.length} invitación(es) pendiente(s)'
                          : 'Aceptar invitaciones',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasPendingInvitations
                          ? 'Puedes aceptarlas desde el enlace recibido o con un token.'
                          : 'Si recibiste una invitación, puedes aceptarla usando el token o el enlace.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _acceptRejectTokenDialog,
                icon: const Icon(Icons.vpn_key_outlined, size: 18),
                label: const Text('Aceptar/Rechazar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasPendingInvitations ? Colors.orange : Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 900;

    Widget content() {
      return Container(
        color: Colors.grey.shade50,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    _buildInviteUsersSection(showCloseButton: !isCompact),
                    _buildPendingInvitationsSection(),
                    _buildMyInvitationsSection(),
                    _buildParticipantsList(),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    final body = content();

    if (isCompact) {
      final canPop = Navigator.of(context).canPop();
      return Scaffold(
        appBar: AppBar(
          title: Text('Participantes • ${widget.plan.name}'),
          actions: [
            IconButton(
              onPressed: _acceptRejectTokenDialog,
              icon: const Icon(Icons.vpn_key_outlined),
              tooltip: 'Aceptar/Rechazar invitación (token)',
            )
          ],
          leading: canPop
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).maybePop(),
                )
              : null,
        ),
        backgroundColor: Colors.grey.shade50,
        body: body,
      );
    }

    return body;
  }
}
