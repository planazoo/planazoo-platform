import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:unp_calendario/features/calendar/domain/services/invitation_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/invitation_providers.dart';
import 'package:flutter/services.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_invitation.dart';
import 'package:unp_calendario/features/security/utils/validator.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/features/notifications/domain/services/notification_helper.dart';

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
        _showSnackBarError(context, 'Error al cargar usuarios: $e');
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

  /// SnackBar estándar UI: éxito (verde), Poppins blanco 14, floating.
  void _showSnackBarSuccess(BuildContext context, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// SnackBar estándar UI: error (rojo), Poppins blanco 14, floating.
  void _showSnackBarError(BuildContext context, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// SnackBar estándar UI: aviso (naranja), Poppins blanco 14, floating.
  void _showSnackBarWarning(BuildContext context, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Invita a un usuario desde la lista: crea invitación (pending) y notificación.
  /// El invitado puede aceptar o rechazar; no se añade directamente al plan.
  Future<void> _inviteUser(UserModel user) async {
    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final email = (user.email ?? '').trim().toLowerCase();
      if (email.isEmpty) {
        throw Exception('El usuario no tiene email');
      }

      final invitationId = await ref.read(invitationServiceProvider).createInvitation(
        planId: widget.plan.id!,
        email: email,
        invitedBy: currentUser.id,
        role: 'participant',
      );

      if (invitationId == null) {
        final existingInv = await ref.read(invitationServiceProvider).getPendingInvitationByEmail(widget.plan.id!, email);
        if (mounted) {
          _showSnackBarWarning(
            context,
            existingInv != null
                ? 'Ya existe una invitación pendiente para ${user.displayName ?? user.email}'
                : '${user.displayName ?? user.email} ya es participante o no se pudo crear la invitación',
          );
        }
        return;
      }

      final invitation = await ref.read(invitationServiceProvider).getInvitationById(invitationId);
      if (invitation != null) {
        final notificationHelper = NotificationHelper();
        await notificationHelper.notifyInvitationCreated(
          planId: widget.plan.id!,
          invitedUserId: user.id,
          invitedEmail: email,
          inviterUserId: currentUser.id,
          invitationToken: invitation.token,
          planName: widget.plan.name,
          inviterName: currentUser.displayName ?? currentUser.email ?? 'Un usuario',
        );
      }

      await ref.read(planParticipationNotifierProvider(widget.plan.id!).notifier).reload();
      ref.invalidate(planParticipantsProvider(widget.plan.id!));
      ref.invalidate(planRealParticipantsProvider(widget.plan.id!));

      if (mounted) {
        _showSnackBarSuccess(context, 'Invitación enviada a ${user.displayName ?? user.email}. Puede aceptar o rechazar.');
        setState(() {});
      }
    } catch (e) {
      LoggerService.error('Error inviting user', context: 'ParticipantsScreen', error: e);
      if (mounted) {
        _showSnackBarError(context, 'Error al enviar invitación: $e');
      }
    }
  }

  Future<void> _showInvitationLink(String invitationId) async {
    try {
      final inv = await ref.read(invitationServiceProvider).getInvitationById(invitationId);
      if (inv == null || inv.token == null) return;
      final link = ref.read(invitationServiceProvider).generateInvitationLink(inv.token!);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => Theme(
          data: AppTheme.darkTheme,
          child: AlertDialog(
            backgroundColor: Colors.grey.shade800,
            title: Text(
              'Invitación creada',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comparte este enlace con la persona invitada:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade700.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: SelectableText(
                    link,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cerrar',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorScheme.color2,
                      AppColorScheme.color2.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorScheme.color2.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: link));
                    if (mounted) Navigator.of(context).pop();
                    if (mounted) {
                      _showSnackBarSuccess(context, 'Enlace copiado al portapapeles');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Copiar enlace',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
    String? errorMessage;
    bool isLoading = false;
    bool showPendingOptions = false;
    PlanInvitation? pendingInvitation;
    final loc = AppLocalizations.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Theme(
          data: AppTheme.darkTheme,
          child: StatefulBuilder(
            builder: (context, setInnerState) {
              return AlertDialog(
                backgroundColor: Colors.grey.shade800,
                title: Text(
                  'Invitar por email',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showPendingOptions && pendingInvitation != null) ...[
                        Text(
                          'Ya existe una invitación pendiente para ${emailController.text.trim()}.\n\n¿Qué deseas hacer?',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ] else ...[
                        if (errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade900.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade700),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, size: 20, color: Colors.red.shade300),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.red.shade200,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (isLoading) ...[
                          const Center(child: CircularProgressIndicator()),
                          const SizedBox(height: 12),
                        ],
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.grey.shade700.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !isLoading,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                              hintText: 'usuario@correo.com',
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: AppColorScheme.color2,
                                  width: 2.5,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.grey.shade700.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: role,
                            dropdownColor: Colors.grey.shade800,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'participant',
                                child: Text(
                                  'Participante',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'observer',
                                child: Text(
                                  'Observador',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: isLoading ? null : (v) => role = v ?? 'participant',
                            decoration: InputDecoration(
                              labelText: 'Rol',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: AppColorScheme.color2,
                                  width: 2.5,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.grey.shade700.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: messageController,
                            maxLines: 3,
                            enabled: !isLoading,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Mensaje (opcional)',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: AppColorScheme.color2,
                                  width: 2.5,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: showPendingOptions && pendingInvitation != null
                    ? [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(false),
                          child: Text(
                            'Cerrar',
                            style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final cancelled = await ref.read(invitationServiceProvider).cancelInvitation(pendingInvitation!.id!);
                            if (!context.mounted) return;
                            if (cancelled) {
                              _showSnackBarWarning(dialogContext, 'Invitación anterior cancelada');
                            }
                            setInnerState(() {
                              showPendingOptions = false;
                              pendingInvitation = null;
                              errorMessage = null;
                            });
                          },
                          child: Text(
                            'Cancelar invitación anterior',
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            _showSnackBarSuccess(dialogContext, 'Re-enviando invitación a ${emailController.text.trim()}');
                            Navigator.of(dialogContext).pop(true);
                            await _showInvitationLink(pendingInvitation!.id!);
                            if (mounted) setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorScheme.color2,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Re-enviar invitación', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                      ]
                    : [
                        TextButton(
                          onPressed: isLoading ? null : () => Navigator.of(dialogContext).pop(false),
                          child: Text(
                            'Cancelar',
                            style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColorScheme.color2,
                                AppColorScheme.color2.withOpacity(0.85),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColorScheme.color2.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final email = emailController.text.trim();
                                    if (email.isEmpty) {
                                      setInnerState(() {
                                        errorMessage = loc?.emailRequired ?? 'El email es obligatorio';
                                      });
                                      return;
                                    }
                                    if (!Validator.isValidEmail(email)) {
                                      setInnerState(() {
                                        errorMessage = loc?.emailInvalid ?? 'El formato del email no es válido';
                                      });
                                      return;
                                    }
                                    setInnerState(() {
                                      errorMessage = null;
                                      isLoading = true;
                                    });
                                    try {
                                      final currentUser = ref.read(currentUserProvider);
                                      final userService = ref.read(userServiceProvider);
                                      final participationService = ref.read(planParticipationServiceProvider);
                                      final normalizedEmail = email.toLowerCase().trim();
                                      final existingUser = await userService.getUserByEmail(normalizedEmail);
                                      if (existingUser != null) {
                                        final isAlreadyParticipant = await participationService.isUserParticipant(widget.plan.id!, existingUser.id);
                                        if (isAlreadyParticipant) {
                                          setInnerState(() {
                                            errorMessage = 'Este usuario ya es participante del plan';
                                            isLoading = false;
                                          });
                                          return;
                                        }
                                      }
                                      final existingInv = await ref.read(invitationServiceProvider).getPendingInvitationByEmail(widget.plan.id!, email);
                                      if (existingInv != null) {
                                        setInnerState(() {
                                          pendingInvitation = existingInv;
                                          showPendingOptions = true;
                                          isLoading = false;
                                          errorMessage = null;
                                        });
                                        return;
                                      }
                                      final invitationId = await ref.read(invitationServiceProvider).createInvitation(
                                        planId: widget.plan.id!,
                                        email: email,
                                        invitedBy: currentUser?.id,
                                        role: role,
                                        customMessage: messageController.text.trim().isEmpty ? null : messageController.text.trim(),
                                      );
                                      if (invitationId == null) {
                                        final existingCheck = await ref.read(invitationServiceProvider).getPendingInvitationByEmail(widget.plan.id!, email);
                                        setInnerState(() {
                                          errorMessage = existingCheck != null
                                              ? 'Ya existe una invitación pendiente para este email'
                                              : 'No se pudo crear la invitación';
                                          isLoading = false;
                                        });
                                        return;
                                      }
                                      final invitation = await ref.read(invitationServiceProvider).getInvitationById(invitationId);
                                      if (invitation != null) {
                                        final existingUserForNotif = await userService.getUserByEmail(normalizedEmail);
                                        if (existingUserForNotif != null) {
                                          final notificationHelper = NotificationHelper();
                                          await notificationHelper.notifyInvitationCreated(
                                            planId: widget.plan.id!,
                                            invitedUserId: existingUserForNotif.id,
                                            invitedEmail: email,
                                            inviterUserId: currentUser?.id ?? '',
                                            invitationToken: invitation.token,
                                            planName: widget.plan.name,
                                            inviterName: currentUser?.displayName ?? currentUser?.email ?? 'Un usuario',
                                          );
                                        }
                                        _showSnackBarSuccess(dialogContext, 'Invitación creada para $email');
                                        Navigator.of(dialogContext).pop(true);
                                        await _showInvitationLink(invitationId);
                                        if (mounted) setState(() {});
                                      } else {
                                        _showSnackBarSuccess(dialogContext, 'Usuario $email añadido al plan');
                                        Navigator.of(dialogContext).pop(true);
                                        if (mounted) setState(() {});
                                      }
                                    } catch (e) {
                                      LoggerService.error('Error creating email invitation', context: 'ParticipantsScreen', error: e);
                                      setInnerState(() {
                                        errorMessage = 'Error al crear invitación: ${e.toString().replaceFirst(RegExp(r'^Exception:?\s*'), '')}';
                                        isLoading = false;
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Enviar invitación',
                                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                      ],
                );
          },
        )
      );
      },
    );

    if (result == true && mounted) setState(() {});
  }

  Future<void> _removeParticipant(PlanParticipation participation) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => Theme(
          data: AppTheme.darkTheme,
          child: AlertDialog(
            backgroundColor: Colors.grey.shade800,
            title: Text(
              'Confirmar eliminación',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            content: Text(
              '¿Estás seguro de que quieres eliminar a este participante del plan?',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.red.shade600,
                      Colors.red.shade600.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade600.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Eliminar',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
          _showSnackBarSuccess(context, 'Participante eliminado del plan');
        }
      }
    } catch (e) {
      LoggerService.error('Error removing participant', context: 'ParticipantsScreen', error: e);
      if (mounted) {
        _showSnackBarError(context, 'Error al eliminar participante: $e');
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
        _showSnackBarSuccess(context, 'Rol actualizado a $newRole');
      }
    } catch (e) {
      LoggerService.error('Error updating role', context: 'ParticipantsScreen', error: e);
      if (mounted) {
        _showSnackBarError(context, 'Error al actualizar rol: $e');
      }
    }
  }

  Widget _buildParticipantsList() {
    return Consumer(
      builder: (context, ref, child) {
        final participantsAsync = ref.watch(planParticipantsProvider(widget.plan.id!));
        
        return participantsAsync.when(
          data: (participations) => _buildParticipantsContent(participations),
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColorScheme.color2),
                const SizedBox(height: 16),
                Text(
                  'Cargando participantes...',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar participantes: $error',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColorScheme.color2,
                        AppColorScheme.color2.withOpacity(0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColorScheme.color2.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      ref.invalidate(planParticipantsProvider(widget.plan.id!));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Reintentar',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No hay participantes en este plan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade800,
            const Color(0xFF2C2C2C),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade700.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: _getRoleColor(participation.role),
              child: Text(
                _initialsFor(user, participation.userId),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (usernameLabel != null || emailLabel != null)
                    Text(
                      usernameLabel ?? emailLabel ?? '',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRoleColor(participation.role),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getRoleLabel(participation.role),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Se unió: ${_formatDate(participation.joinedAt)}',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade400,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
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
      builder: (context) => Theme(
        data: AppTheme.darkTheme,
        child: AlertDialog(
          backgroundColor: Colors.grey.shade800,
          title: Text(
            'Cambiar rol',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selecciona un nuevo rol para ${participation.userId}:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 16),
              _buildRoleOption(participation, 'organizer', 'Organizador'),
              _buildRoleOption(participation, 'participant', 'Participante'),
              _buildRoleOption(participation, 'observer', 'Observador'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(PlanParticipation participation, String role, String label) {
    return ListTile(
      leading: Radio<String>(
        value: role,
        groupValue: participation.role,
        activeColor: AppColorScheme.color2,
        onChanged: (value) {
          Navigator.of(context).pop();
          _changeRole(participation, value!);
        },
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _getRoleDescription(role),
        style: GoogleFonts.poppins(
          color: Colors.grey.shade400,
          fontSize: 12,
        ),
      ),
    );
  }

  /// Sección "Salir del plan" para el usuario actual cuando es participante (no organizador).
  Widget _buildLeavePlanSection() {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null || widget.plan.id == null) return const SizedBox.shrink();
    if (currentUser.id == widget.plan.userId) return const SizedBox.shrink();

    final participantsAsync = ref.watch(planParticipantsProvider(widget.plan.id!));
    final isParticipant = participantsAsync.maybeWhen(
      data: (list) => list.any((p) => p.userId == currentUser.id),
      orElse: () => false,
    );
    if (!isParticipant) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade700.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.exit_to_app, color: Colors.orange.shade300, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Salir del plan',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Dejarás de ser participante de este plan.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => _showLeavePlanConfirmation(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade300,
                side: BorderSide(color: Colors.orange.shade400),
              ),
              child: Text(
                'Salir',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLeavePlanConfirmation() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || widget.plan.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Theme(
        data: AppTheme.darkTheme,
        child: AlertDialog(
          backgroundColor: Colors.grey.shade800,
          title: Text(
            'Salir del plan',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: Text(
            '¿Estás seguro de que quieres salir de "${widget.plan.name}"? Dejarás de ver eventos y participantes.',
            style: GoogleFonts.poppins(color: Colors.grey.shade300, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar', style: GoogleFonts.poppins(color: Colors.grey.shade400)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Salir', style: GoogleFonts.poppins(color: Colors.orange.shade300)),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final participationService = ref.read(planParticipationServiceProvider);
      final success = await participationService.removeParticipation(widget.plan.id!, currentUser.id);
      if (!mounted) return;
      if (success) {
        ref.read(planParticipationNotifierProvider(widget.plan.id!).notifier).reload();
        ref.invalidate(planParticipantsProvider(widget.plan.id!));
        ref.invalidate(planRealParticipantsProvider(widget.plan.id!));
        widget.onBack?.call();
        _showSnackBarSuccess(context, 'Has salido del plan');
      } else {
        _showSnackBarError(context, 'No se pudo salir del plan');
      }
    } catch (e) {
      LoggerService.error('Error leaving plan', context: 'ParticipantsScreen', error: e);
      if (mounted) {
        _showSnackBarError(context, 'Error al salir del plan: $e');
      }
    }
  }

  /// T233: Sin botón X; lista va primero, invitar a continuación.
  Widget _buildInviteUsersSection() {
    return Consumer(
      builder: (context, ref, _) {
        final participantsAsync = ref.watch(planParticipantsProvider(widget.plan.id!));

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade800,
                const Color(0xFF2C2C2C),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade700.withOpacity(0.5),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
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
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Wrap(
                      spacing: 8,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColorScheme.color2,
                                AppColorScheme.color2.withOpacity(0.85),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColorScheme.color2.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: TextButton.icon(
                            onPressed: _inviteByEmailDialog,
                            icon: const Icon(Icons.mail_outline, color: Colors.white),
                            label: Text(
                              'Invitar por email',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade800, // Color sólido, sin gradiente
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey.shade700.withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: _filterUsers,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Buscar usuarios por nombre, email o @usuario...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColorScheme.color2,
                        width: 2.5,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  ),
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
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey.shade800,
                            const Color(0xFF2C2C2C),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.grey.shade700.withOpacity(0.5),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: availableUsers.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  _searchQuery.isEmpty
                                      ? 'No hay usuarios disponibles'
                                      : 'No se encontraron usuarios',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade400,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: availableUsers.length,
                              itemBuilder: (context, index) {
                                final user = availableUsers[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.grey.shade800,
                                        const Color(0xFF2C2C2C),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade700.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppColorScheme.color2,
                                      child: Text(
                                        _computeInitials(user),
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      _formatUserDisplay(user, user.email),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      user.email,
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey.shade400,
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColorScheme.color2,
                                            AppColorScheme.color2.withOpacity(0.85),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColorScheme.color2.withOpacity(0.4),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () => _inviteUser(user),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          shadowColor: Colors.transparent,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        child: Text(
                                          'Invitar',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
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

  String _formatDate(DateTime date) => DateFormatter.formatDate(date);

  String _invitationStatusLabel(String? status) {
    switch (status) {
      case 'pending': return 'Pendiente';
      case 'accepted': return 'Aceptada';
      case 'rejected': return 'Rechazada';
      case 'cancelled': return 'Cancelada';
      case 'expired': return 'Expirada';
      default: return status ?? 'Pendiente';
    }
  }

  Widget _buildPendingInvitationsSection() {
    final currentUser = ref.watch(currentUserProvider);
    final isOwner = currentUser?.id == widget.plan.userId;
    return FutureBuilder<List<PlanInvitation>>(
      future: ref.read(invitationsForPlanProvider(widget.plan.id!).future),
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
              Text(
                'Invitaciones',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 8),
              ...items.map((inv) {
                final created = inv.createdAt != null ? _formatDate(inv.createdAt!) : '';
                final expires = inv.expiresAt != null ? _formatDate(inv.expiresAt!) : '';
                final statusLabel = _invitationStatusLabel(inv.status);
                final isPending = inv.status == 'pending';
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey.shade800,
                        const Color(0xFF2C2C2C),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.grey.shade700.withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      inv.email ?? '',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Estado: $statusLabel • Rol: ${inv.role ?? 'participant'} • Creada: $created${isPending ? ' • Expira: $expires' : ''}',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPending && inv.token != null)
                          IconButton(
                            tooltip: 'Copiar enlace',
                            icon: Icon(Icons.link, color: Colors.grey.shade400),
                            onPressed: () async {
                              if (inv.token != null) {
                                final link = ref.read(invitationServiceProvider).generateInvitationLink(inv.token!);
                                await Clipboard.setData(ClipboardData(text: link));
                                if (mounted) {
                                  _showSnackBarSuccess(context, 'Enlace copiado');
                                }
                              }
                            },
                          ),
                        if (isOwner && inv.id != null && isPending)
                          IconButton(
                            tooltip: 'Cancelar',
                            icon: Icon(Icons.cancel, color: Colors.red.shade400),
                            onPressed: () async {
                              final ok = await ref.read(invitationServiceProvider).cancelInvitation(inv.id!);
                              if (ok) {
                                ref.invalidate(invitationsForPlanProvider(widget.plan.id!));
                                if (mounted) setState(() {});
                                if (mounted) {
                                  _showSnackBarSuccess(context, 'Invitación cancelada');
                                }
                              } else {
                                if (mounted) {
                                  _showSnackBarError(context, 'No se pudo cancelar');
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
      future: ref.read(invitationServiceProvider).getPendingInvitationsByEmail(user.email),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        final hasPendingInvitations = items.isNotEmpty;
        
        return Container(
          margin: const EdgeInsets.all(12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade800,
                const Color(0xFF2C2C2C),
              ],
            ),
            border: Border.all(
              color: hasPendingInvitations
                  ? Colors.orange.shade400.withOpacity(0.5)
                  : AppColorScheme.color2.withOpacity(0.5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 2),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                hasPendingInvitations ? Icons.mail_outline : Icons.info_outline,
                color: hasPendingInvitations ? Colors.orange.shade300 : AppColorScheme.color2,
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
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasPendingInvitations
                          ? 'Puedes aceptarlas desde el enlace recibido en tu correo.'
                          : 'Si recibiste una invitación, acepta desde el enlace en tu correo.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Barra superior estándar W31: altura 48, color2. T233: solo nombre de la página, sin nombre del plan.
  Widget _buildParticipantsHeader() {
    final loc = AppLocalizations.of(context)!;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColorScheme.color2,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            loc.participants,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 900;

    Widget content() {
      final scrollContent = LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  _buildParticipantsList(),
                  _buildInviteUsersSection(),
                  _buildLeavePlanSection(),
                  _buildPendingInvitationsSection(),
                  _buildMyInvitationsSection(),
                ],
              ),
            ),
          );
        },
      );

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade800,
              const Color(0xFF2C2C2C),
            ],
          ),
        ),
        child: isCompact
            ? scrollContent
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildParticipantsHeader(),
                  Expanded(child: scrollContent),
                ],
              ),
      );
    }

    final body = content();

    if (isCompact) {
      final canPop = Navigator.of(context).canPop();
      return Theme(
        data: AppTheme.darkTheme,
        child: Scaffold(
          backgroundColor: Colors.grey.shade900,
          appBar: AppBar(
            toolbarHeight: 48,
            backgroundColor: AppColorScheme.color2,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              AppLocalizations.of(context)!.participants,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.1,
              ),
            ),
            leading: canPop
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).maybePop(),
                  )
                : null,
          ),
          body: body,
        ),
      );
    }

    return body;
  }
}
