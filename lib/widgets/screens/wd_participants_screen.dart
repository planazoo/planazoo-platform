import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/invitation_providers.dart';
import 'package:flutter/services.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_invitation.dart';
import 'package:unp_calendario/features/security/utils/validator.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/features/notifications/domain/services/notification_helper.dart';
import 'package:unp_calendario/widgets/plan/wd_plan_user_status_label.dart';
import 'package:unp_calendario/widgets/plan/plan_status_chip_actions.dart';

class ParticipantsScreen extends ConsumerStatefulWidget {
  final Plan plan;
  final VoidCallback? onBack;
  /// Si false, no se envuelve en Scaffold/AppBar (p. ej. cuando se usa dentro de PlanDetailPage en iOS).
  final bool embedInScaffold;

  const ParticipantsScreen({
    super.key,
    required this.plan,
    this.onBack,
    this.embedInScaffold = true,
  });

  @override
  ConsumerState<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends ConsumerState<ParticipantsScreen> {
  static const Color _webPageBg = Color(0xFFF1F5F9);
  static const Color _webBorder = Color(0xFFE2E8F0);
  static const Color _webOnSurface = Color(0xFF0F172A);
  static const Color _webMuted = Color(0xFF64748B);

  /// Tarjeta lista participantes: oscura en móvil, clara en web (W13).
  BoxDecoration _participantCardDecoration({double radius = 12}) {
    if (kIsWeb) {
      return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _webBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.grey.shade800,
          const Color(0xFF2C2C2C),
        ],
      ),
      borderRadius: BorderRadius.circular(radius),
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
    );
  }

  /// Bloque superior “Invitar usuarios” (borde inferior en web).
  BoxDecoration _inviteSectionDecoration() {
    if (kIsWeb) {
      return BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: _webBorder),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }
    return BoxDecoration(
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
    );
  }

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
          final loc = AppLocalizations.of(context)!;
          final display = user.displayName ?? user.email ?? email;
          _showSnackBarWarning(
            context,
            existingInv != null
                ? loc.invitePendingExistsForEmail(display)
                : loc.snackInviteUserBlockedOrFailed(display),
          );
        }
        return;
      }

      // Invitación directa (usuario ya registrado): ya creada participación pending y notificación en el servicio
      if (invitationId.startsWith('direct:')) {
        await ref.read(planParticipationNotifierProvider(widget.plan.id!).notifier).reload();
        ref.invalidate(planParticipantsProvider(widget.plan.id!));
        ref.invalidate(planRealParticipantsProvider(widget.plan.id!));
        if (mounted) {
          final loc = AppLocalizations.of(context)!;
          final display = user.displayName ?? user.email ?? email;
          _showSnackBarSuccess(context, loc.snackInviteSentWillAppearPending(display));
          setState(() {});
        }
        return;
      }

      final invitation = await ref.read(invitationServiceProvider).getInvitationById(invitationId);
      if (invitation != null) {
        final loc = AppLocalizations.of(context)!;
        final notificationHelper = NotificationHelper();
        await notificationHelper.notifyInvitationCreated(
          planId: widget.plan.id!,
          invitedUserId: user.id,
          invitedEmail: email,
          inviterUserId: currentUser.id,
          invitationToken: invitation.token,
          planName: widget.plan.name,
          inviterName: currentUser.displayName ?? currentUser.email ?? loc.inviterNameFallback,
        );
      }

      await ref.read(planParticipationNotifierProvider(widget.plan.id!).notifier).reload();
      ref.invalidate(planParticipantsProvider(widget.plan.id!));
      ref.invalidate(planRealParticipantsProvider(widget.plan.id!));
      ref.invalidate(pendingInvitationsProvider(widget.plan.id!));

      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        _showSnackBarSuccess(
          context,
          loc.snackInviteSentToUserDisplay(user.displayName ?? user.email ?? ''),
        );
        setState(() {});
      }
    } catch (e) {
      LoggerService.error('Error inviting user', context: 'ParticipantsScreen', error: e);
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        _showSnackBarError(context, loc.snackInviteSendError(e.toString()));
      }
    }
  }

  Future<void> _showInvitationLink(String invitationId) async {
    try {
      final inv = await ref.read(invitationServiceProvider).getInvitationById(invitationId);
      if (inv == null || inv.token == null) return;
      final link = ref.read(invitationServiceProvider).generateInvitationLink(inv.token!);
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => Theme(
          data: kIsWeb ? AppTheme.lightTheme : AppTheme.darkTheme,
          child: AlertDialog(
            backgroundColor: kIsWeb ? Colors.white : Colors.grey.shade800,
            title: Text(
              loc.invitationCreatedTitle,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: kIsWeb ? _webOnSurface : Colors.white,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.invitationShareLinkHint,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: kIsWeb ? _webMuted : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kIsWeb ? const Color(0xFFF8FAFC) : Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: kIsWeb ? _webBorder : Colors.grey.shade700.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: SelectableText(
                    link,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: kIsWeb ? _webOnSurface : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  loc.close,
                  style: GoogleFonts.poppins(
                    color: kIsWeb ? _webMuted : Colors.grey.shade400,
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
                    if (mounted) Navigator.of(dialogContext).pop();
                    if (mounted) {
                      _showSnackBarSuccess(context, loc.linkCopiedToClipboard);
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
                    loc.tooltipCopyInviteLink,
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

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final loc = AppLocalizations.of(dialogContext)!;
        return Theme(
          data: kIsWeb ? AppTheme.lightTheme : AppTheme.darkTheme,
          child: StatefulBuilder(
            builder: (context, setInnerState) {
              return AlertDialog(
                backgroundColor: kIsWeb ? Colors.white : Colors.grey.shade800,
                title: Text(
                  loc.inviteByEmailTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: kIsWeb ? _webOnSurface : Colors.white,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showPendingOptions && pendingInvitation != null) ...[
                        Text(
                          loc.invitePendingExistsForEmail(emailController.text.trim()),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: kIsWeb ? _webOnSurface : Colors.white,
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
                            color: kIsWeb ? const Color(0xFFF8FAFC) : Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: kIsWeb ? _webBorder : Colors.grey.shade700.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !isLoading,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: kIsWeb ? _webOnSurface : Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: loc.emailLabel,
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: kIsWeb ? _webMuted : Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                              hintText: loc.emailHint,
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                color: kIsWeb ? _webMuted : Colors.grey.shade500,
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
                            color: kIsWeb ? const Color(0xFFF8FAFC) : Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: kIsWeb ? _webBorder : Colors.grey.shade700.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: role,
                            dropdownColor: kIsWeb ? Colors.white : Colors.grey.shade800,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: kIsWeb ? _webOnSurface : Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'participant',
                                child: Text(
                                  loc.participantRoleLabel,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: kIsWeb ? _webOnSurface : Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'observer',
                                child: Text(
                                  loc.observerRoleLabel,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: kIsWeb ? _webOnSurface : Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: isLoading ? null : (v) => role = v ?? 'participant',
                            decoration: InputDecoration(
                              labelText: loc.roleFieldLabel,
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: kIsWeb ? _webMuted : Colors.grey.shade400,
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
                            color: kIsWeb ? const Color(0xFFF8FAFC) : Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: kIsWeb ? _webBorder : Colors.grey.shade700.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: messageController,
                            maxLines: 3,
                            enabled: !isLoading,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: kIsWeb ? _webOnSurface : Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: loc.inviteOptionalMessageLabel,
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: kIsWeb ? _webMuted : Colors.grey.shade400,
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
                            loc.close,
                            style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final cancelled = await ref.read(invitationServiceProvider).cancelInvitation(pendingInvitation!.id!);
                            if (!context.mounted) return;
                            if (cancelled) {
                              _showSnackBarWarning(dialogContext, loc.snackPreviousInvitationCancelled);
                            }
                            setInnerState(() {
                              showPendingOptions = false;
                              pendingInvitation = null;
                              errorMessage = null;
                            });
                          },
                          child: Text(
                            loc.tooltipCancelPreviousInvitation,
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            _showSnackBarSuccess(dialogContext, loc.participantsInviteResending(emailController.text.trim()));
                            Navigator.of(dialogContext).pop(true);
                            await _showInvitationLink(pendingInvitation!.id!);
                            if (mounted) setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorScheme.color2,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(loc.participantsInviteResendButton, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                      ]
                    : [
                        TextButton(
                          onPressed: isLoading ? null : () => Navigator.of(dialogContext).pop(false),
                          child: Text(
                            loc.cancel,
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
                                        errorMessage = loc.emailRequired;
                                      });
                                      return;
                                    }
                                    if (!Validator.isValidEmail(email)) {
                                      setInnerState(() {
                                        errorMessage = loc.emailInvalid;
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
                                            errorMessage = loc.snackUserAlreadyParticipant;
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
                                              ? loc.snackPendingInviteExists
                                              : loc.snackCouldNotCreateInvitation;
                                          isLoading = false;
                                        });
                                        return;
                                      }
                                      // Invitación directa (email ya registrado): participación pending creada en el servicio
                                      if (invitationId.startsWith('direct:')) {
                                        ref.invalidate(planParticipantsProvider(widget.plan.id!));
                                        ref.invalidate(planRealParticipantsProvider(widget.plan.id!));
                                        ref.read(planParticipationNotifierProvider(widget.plan.id!).notifier).reload();
                                        _showSnackBarSuccess(dialogContext, loc.snackInviteSentWillAppearPending(email));
                                        Navigator.of(dialogContext).pop(true);
                                        if (mounted) setState(() {});
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
                                            inviterName: currentUser?.displayName ?? currentUser?.email ?? loc.inviterNameFallback,
                                          );
                                        }
                                        ref.invalidate(pendingInvitationsProvider(widget.plan.id!));
                                        _showSnackBarSuccess(dialogContext, loc.snackInviteCreatedForEmail(email));
                                        Navigator.of(dialogContext).pop(true);
                                        await _showInvitationLink(invitationId);
                                        if (mounted) setState(() {});
                                      } else {
                                        _showSnackBarSuccess(dialogContext, loc.snackUserAddedToPlan(email));
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
                                    loc.inviteSendInvitation,
                                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                      ],
                );
            },
          ),
        );
      },
    );

    if (result == true && mounted) setState(() {});
  }

  Future<void> _removeParticipant(PlanParticipation participation) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          final loc = AppLocalizations.of(dialogContext)!;
          return Theme(
            data: kIsWeb ? AppTheme.lightTheme : AppTheme.darkTheme,
            child: AlertDialog(
              backgroundColor: kIsWeb ? Colors.white : Colors.grey.shade800,
              title: Text(
                loc.confirmDeleteTitle,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: kIsWeb ? _webOnSurface : Colors.white,
                ),
              ),
              content: Text(
                loc.participantRemoveConfirmMessage,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: kIsWeb ? _webMuted : Colors.grey.shade400,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(
                    loc.cancel,
                    style: GoogleFonts.poppins(
                      color: kIsWeb ? _webMuted : Colors.grey.shade400,
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
                  onPressed: () => Navigator.of(dialogContext).pop(true),
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
                    loc.delete,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

      if (confirmed == true) {
        final participationService = ref.read(planParticipationServiceProvider);
        await participationService.removeParticipation(widget.plan.id!, participation.userId);

        await ref.read(planParticipationNotifierProvider(widget.plan.id!).notifier).reload();
        ref
          ..invalidate(planParticipantsProvider(widget.plan.id!))
          ..invalidate(planRealParticipantsProvider(widget.plan.id!));

        if (mounted) {
          final loc = AppLocalizations.of(context)!;
          _showSnackBarSuccess(context, loc.snackParticipantRemovedFromPlan);
        }
      }
    } catch (e) {
      LoggerService.error('Error removing participant', context: 'ParticipantsScreen', error: e);
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        _showSnackBarError(context, loc.snackParticipantRemoveError(e.toString()));
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
        final planId = widget.plan.id!;

        return participantsAsync.when(
          data: (participations) {
            final pendingInvAsync = ref.watch(pendingInvitationsProvider(planId));
            return pendingInvAsync.when(
              data: (pendingInvitations) => _buildParticipantsContent(participations, pendingInvitations),
              loading: () => _buildParticipantsContent(participations, const []),
              error: (_, __) => _buildParticipantsContent(participations, const []),
            );
          },
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColorScheme.color2),
                const SizedBox(height: 16),
                Text(
                  'Cargando participantes...',
                  style: GoogleFonts.poppins(
                    color: kIsWeb ? _webMuted : Colors.grey.shade400,
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
                    color: kIsWeb ? _webMuted : Colors.grey.shade400,
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

  Widget _buildParticipantsContent(List<PlanParticipation> participations, List<PlanInvitation> pendingInvitations) {
    // Solo mostrar invitaciones por email cuando ese email NO tiene ya una participación
    // (si tiene participación, se muestra la fila con nombre y usuario y estado pending)
    final participationEmails = participations
        .map((p) => _findUser(p.userId)?.email?.trim().toLowerCase())
        .whereType<String>()
        .toSet();
    final pendingEmailOnly = pendingInvitations
        .where((inv) => (inv.email?.trim().toLowerCase() ?? '').isNotEmpty && !participationEmails.contains(inv.email!.trim().toLowerCase()))
        .toList();

    final hasParticipants = participations.isNotEmpty;
    final hasPendingEmails = pendingEmailOnly.isNotEmpty;
    if (!hasParticipants && !hasPendingEmails) {
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

    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...participations.map((participation) => _buildParticipantCard(participation)),
          ...pendingEmailOnly.map((invitation) => _buildPendingEmailInvitationCard(invitation, loc)),
        ],
      ),
    );
  }

  /// Tarjeta para invitación pendiente por email (usuario aún no registrado).
  Widget _buildPendingEmailInvitationCard(PlanInvitation invitation, AppLocalizations loc) {
    final email = invitation.email ?? '';
    final statusLabel = loc.statusShortPending;
    final statusBg = PlanUserStatusColors.pendingBg;
    final statusBorder = PlanUserStatusColors.pendingBorder;
    final statusText = PlanUserStatusColors.pendingText;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: _participantCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade600,
              child: Text(
                email.isNotEmpty ? email[0].toUpperCase() : '?',
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
                    email,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: kIsWeb ? _webOnSurface : Colors.white,
                    ),
                  ),
                  Text(
                    loc.invitationPendingEmailLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: kIsWeb ? _webMuted : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusBorder, width: 1),
              ),
              child: Text(
                statusLabel,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantCard(PlanParticipation participation) {
    final user = _findUser(participation.userId);
    final displayName = _formatUserDisplay(user, participation.userId);
    final usernameLabel = user?.username != null && user!.username!.trim().isNotEmpty
        ? '@${user.username!}'
        : null;
    final loc = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);
    final planId = widget.plan.id;
    final pendingInvitations = ref.watch(userPendingInvitationsProvider);
    final hasPendingInvitation = planId != null &&
        pendingInvitations.maybeWhen(
          data: (list) => list.any((inv) => inv.planId == planId),
          orElse: () => false,
        );
    // Estado in/out/pending
    String statusLabel;
    Color statusBg;
    Color statusBorder;
    Color statusText;
    if (participation.isPending) {
      statusLabel = loc.statusShortPending;
      statusBg = PlanUserStatusColors.pendingBg;
      statusBorder = PlanUserStatusColors.pendingBorder;
      statusText = PlanUserStatusColors.pendingText;
    } else if (participation.isRejected) {
      statusLabel = loc.statusShortOut;
      statusBg = PlanUserStatusColors.outBg;
      statusBorder = PlanUserStatusColors.outBorder;
      statusText = PlanUserStatusColors.outText;
    } else {
      statusLabel = loc.statusShortIn;
      statusBg = PlanUserStatusColors.inBg;
      statusBorder = PlanUserStatusColors.inBorder;
      statusText = PlanUserStatusColors.inText;
    }

    Widget statusChipWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: statusBorder, width: 1),
      ),
      child: Text(
        statusLabel,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: statusText,
        ),
      ),
    );

    final isMe = currentUser != null && participation.userId == currentUser.id && planId != null;
    if (isMe) {
      if (participation.isPending) {
        statusChipWidget = Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => planStatusChipShowPendingActions(
              context,
              ref,
              planId: planId,
              userId: currentUser.id,
              hasPendingInvitation: hasPendingInvitation,
              hasPendingParticipation: participation.isPending,
            ),
            borderRadius: BorderRadius.circular(6),
            child: statusChipWidget,
          ),
        );
      } else if (participation.isAccepted) {
        if (widget.plan.userId == currentUser.id) {
          statusChipWidget = Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.planCardOrganizerChipMessage)),
                );
              },
              borderRadius: BorderRadius.circular(6),
              child: statusChipWidget,
            ),
          );
        } else {
          statusChipWidget = Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => planStatusChipShowLeavePlan(
                context,
                ref,
                plan: widget.plan,
                userId: currentUser.id,
              ),
              borderRadius: BorderRadius.circular(6),
              child: statusChipWidget,
            ),
          );
        }
      } else if (participation.isRejected) {
        statusChipWidget = Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.planStatusRejectedSnackbar, style: GoogleFonts.poppins(color: Colors.white)),
                  backgroundColor: Colors.grey.shade800,
                ),
              );
            },
            borderRadius: BorderRadius.circular(6),
            child: statusChipWidget,
          ),
        );
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: _participantCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            // Columna 1: imagen del usuario
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
            // Columna 2: nombre y usuario (sin email)
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
                      color: kIsWeb ? _webOnSurface : Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (usernameLabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      usernameLabel,
                      style: GoogleFonts.poppins(
                        color: kIsWeb ? _webMuted : Colors.grey.shade400,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Columna 3: rol y estado (in/out/pending)
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
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
                      const SizedBox(height: 4),
                      statusChipWidget,
                    ],
                  ),
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
          ],
        ),
      ),
    );
  }

  void _showRoleChangeDialog(PlanParticipation participation) {
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: kIsWeb ? AppTheme.lightTheme : AppTheme.darkTheme,
        child: AlertDialog(
          backgroundColor: kIsWeb ? Colors.white : Colors.grey.shade800,
          title: Text(
            'Cambiar rol',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: kIsWeb ? _webOnSurface : Colors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selecciona un nuevo rol para ${participation.userId}:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: kIsWeb ? _webMuted : Colors.grey.shade400,
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
          color: kIsWeb ? _webOnSurface : Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _getRoleDescription(role),
        style: GoogleFonts.poppins(
          color: kIsWeb ? _webMuted : Colors.grey.shade400,
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
          color: kIsWeb ? Colors.white : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: kIsWeb ? _webBorder : Colors.grey.shade700.withOpacity(0.5),
          ),
          boxShadow: kIsWeb
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
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
                      color: kIsWeb ? _webOnSurface : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Dejarás de ser participante de este plan.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: kIsWeb ? _webMuted : Colors.grey.shade400,
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
      builder: (dialogContext) {
        final loc = AppLocalizations.of(dialogContext)!;
        return Theme(
          data: kIsWeb ? AppTheme.lightTheme : AppTheme.darkTheme,
          child: AlertDialog(
            backgroundColor: kIsWeb ? Colors.white : Colors.grey.shade800,
            title: Text(
              loc.planCardLeavePlanTitle,
              style: GoogleFonts.poppins(
                color: kIsWeb ? _webOnSurface : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              loc.planCardLeavePlanConfirmBody(widget.plan.name),
              style: GoogleFonts.poppins(
                color: kIsWeb ? _webMuted : Colors.grey.shade300,
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(
                  loc.cancel,
                  style: GoogleFonts.poppins(
                    color: kIsWeb ? _webMuted : Colors.grey.shade400,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(
                  loc.planCardLeavePlanButton,
                  style: GoogleFonts.poppins(
                    color: kIsWeb ? Colors.orange.shade800 : Colors.orange.shade300,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
        final loc = AppLocalizations.of(context)!;
        _showSnackBarSuccess(context, loc.planCardLeftPlanSuccess);
      } else {
        final loc = AppLocalizations.of(context)!;
        _showSnackBarError(context, loc.planCardLeftPlanError);
      }
    } catch (e) {
      LoggerService.error('Error leaving plan', context: 'ParticipantsScreen', error: e);
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        _showSnackBarError(context, '${loc.planCardLeftPlanError}: $e');
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
          decoration: _inviteSectionDecoration(),
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
                        color: kIsWeb ? _webOnSurface : Colors.white,
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
                    hintText: 'Buscar usuarios por nombre o @usuario...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                      decoration: _participantCardDecoration(radius: 14),
                      child: availableUsers.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  _searchQuery.isEmpty
                                      ? 'No hay usuarios disponibles'
                                      : 'No se encontraron usuarios',
                                  style: GoogleFonts.poppins(
                                    color: kIsWeb ? _webMuted : Colors.grey.shade400,
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
                                  decoration: _participantCardDecoration(),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    leading: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColorScheme.color2,
                                      child: Text(
                                        _computeInitials(user),
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      _formatUserDisplay(user, user.id),
                                      style: GoogleFonts.poppins(
                                        color: kIsWeb ? _webOnSurface : Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: user.username != null && user.username!.trim().isNotEmpty
                                        ? Text(
                                            '@${user.username!.trim()}',
                                            style: GoogleFonts.poppins(
                                              color: kIsWeb ? _webMuted : Colors.grey.shade400,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : null,
                                    trailing: Material(
                                      color: AppColorScheme.color2,
                                      borderRadius: BorderRadius.circular(8),
                                      child: InkWell(
                                        onTap: () => _inviteUser(user),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          child: Text(
                                            'Invitar',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
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
        final loc = AppLocalizations.of(context)!;
        final items = snapshot.data ?? [];
        if (items.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.invitationsSectionTitle,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: kIsWeb ? _webOnSurface : Colors.white,
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
                  decoration: _participantCardDecoration(radius: 18),
                  child: ListTile(
                    title: Text(
                      inv.email ?? '',
                      style: GoogleFonts.poppins(
                        color: kIsWeb ? _webOnSurface : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Estado: $statusLabel • Rol: ${inv.role ?? 'participant'} • Creada: $created${isPending ? ' • Expira: $expires' : ''}',
                      style: GoogleFonts.poppins(
                        color: kIsWeb ? _webMuted : Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPending && inv.token != null)
                          IconButton(
                            tooltip: loc.tooltipCopyInviteLink,
                            icon: Icon(Icons.link, color: Colors.grey.shade400),
                            onPressed: () async {
                              if (inv.token != null) {
                                final link = ref.read(invitationServiceProvider).generateInvitationLink(inv.token!);
                                await Clipboard.setData(ClipboardData(text: link));
                                if (mounted) {
                                  _showSnackBarSuccess(context, loc.snackLinkCopiedShort);
                                }
                              }
                            },
                          ),
                        if (isOwner && inv.id != null && isPending)
                          IconButton(
                            tooltip: loc.tooltipCancelAction,
                            icon: Icon(Icons.cancel, color: Colors.red.shade400),
                            onPressed: () async {
                              final ok = await ref.read(invitationServiceProvider).cancelInvitation(inv.id!);
                              if (ok) {
                                ref.invalidate(invitationsForPlanProvider(widget.plan.id!));
                                if (mounted) setState(() {});
                                if (mounted) {
                                  _showSnackBarSuccess(context, loc.snackInvitationCancelledShort);
                                }
                              } else {
                                if (mounted) {
                                  _showSnackBarError(context, loc.snackInvitationCancelFailed);
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
          decoration: kIsWeb
              ? BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: hasPendingInvitations
                        ? Colors.orange.shade300
                        : _webBorder,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
              : BoxDecoration(
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
                        color: kIsWeb ? _webOnSurface : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasPendingInvitations
                          ? 'Puedes aceptarlas desde el enlace recibido en tu correo.'
                          : 'Si recibiste una invitación, acepta desde el enlace en tu correo.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: kIsWeb ? _webMuted : Colors.grey.shade400,
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
        color: kIsWeb ? _webPageBg : AppColorScheme.color2,
        border: kIsWeb
            ? const Border(bottom: BorderSide(color: _webBorder))
            : null,
        boxShadow: kIsWeb
            ? [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 1),
                ),
              ]
            : [
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
              color: kIsWeb ? const Color(0xFF1F2937) : Colors.white,
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

      final gradientBox = Container(
        decoration: kIsWeb
            ? const BoxDecoration(color: _webPageBg)
            : BoxDecoration(
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

      // P15: misma barra verde que otras pestañas cuando está embebido en PlanDetailPage (iOS).
      if (isCompact && !widget.embedInScaffold) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildParticipantsHeader(),
            Expanded(child: gradientBox),
          ],
        );
      }

      return gradientBox;
    }

    final body = content();

    if (isCompact && widget.embedInScaffold) {
      final canPop = Navigator.of(context).canPop();
      return Theme(
        data: kIsWeb ? AppTheme.lightTheme : AppTheme.darkTheme,
        child: Scaffold(
          backgroundColor: kIsWeb ? _webPageBg : Colors.grey.shade900,
          appBar: AppBar(
            toolbarHeight: 48,
            surfaceTintColor: Colors.transparent,
            backgroundColor: kIsWeb ? _webPageBg : AppColorScheme.color2,
            foregroundColor: kIsWeb ? const Color(0xFF1F2937) : Colors.white,
            elevation: 0,
            shape: kIsWeb
                ? const Border(bottom: BorderSide(color: _webBorder))
                : null,
            iconTheme: IconThemeData(
              color: kIsWeb ? const Color(0xFF1F2937) : Colors.white,
            ),
            title: Text(
              AppLocalizations.of(context)!.participants,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kIsWeb ? const Color(0xFF1F2937) : Colors.white,
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
