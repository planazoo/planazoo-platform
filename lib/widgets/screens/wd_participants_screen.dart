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
import 'package:unp_calendario/widgets/plan/membership_solo_items_warning.dart';
import 'package:unp_calendario/widgets/plan/wd_plan_user_status_label.dart';
import 'package:unp_calendario/widgets/plan/plan_status_chip_actions.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';

class ParticipantsScreen extends ConsumerStatefulWidget {
  final Plan plan;
  final VoidCallback? onBack;
  /// Si false, no se envuelve en Scaffold/AppBar (p. ej. cuando se usa dentro de PlanDetailPage en iOS).
  final bool embedInScaffold;
  /// Si true y está embebido, dibuja barra superior interna "Participantes".
  final bool showEmbeddedHeader;

  const ParticipantsScreen({
    super.key,
    required this.plan,
    this.onBack,
    this.embedInScaffold = true,
    this.showEmbeddedHeader = true,
  });

  @override
  ConsumerState<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends ConsumerState<ParticipantsScreen> {
  static const Color _webPageBg = IosFormColors.pageBg;
  static const Color _webBorder = Color(0x1FFFFFFF);
  static const Color _webOnSurface = Colors.white;
  static const Color _webMuted = Colors.white70;

  /// Tarjeta lista participantes (secciones legacy pendientes / mis invitaciones).
  BoxDecoration _participantCardDecoration({double radius = 12}) {
    return BoxDecoration(
      color: IosFormColors.groupedBg,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.08),
        width: 1,
      ),
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
        final loc = AppLocalizations.of(context)!;
        _showSnackBarError(context, loc.errorLoadingParticipants(e.toString()));
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

      final email = user.email.trim().toLowerCase();
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
          final display = user.displayName ?? user.email;
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
          final display = user.displayName ?? user.email;
          _showSnackBarSuccess(context, loc.snackInviteSentWillAppearPending(display));
          setState(() {});
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
          inviterName: currentUser.displayName ?? currentUser.email,
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
          loc.snackInviteSentToUserDisplay(user.displayName ?? user.email),
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
      if (inv == null) return;
      final link = ref.read(invitationServiceProvider).generateInvitationLink(inv.token);
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => Theme(
          data: AppTheme.darkTheme,
          child: AlertDialog(
            backgroundColor: const Color(0xFF1F2937),
            title: Text(
              loc.invitationCreatedTitle,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _webOnSurface,
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
                    color: _webMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _webBorder,
                      width: 1,
                    ),
                  ),
                  child: SelectableText(
                    link,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _webOnSurface,
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
                    color: _webMuted,
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
                      AppColorScheme.color2.withValues(alpha: 0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorScheme.color2.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: link));
                    if (!dialogContext.mounted) return;
                    Navigator.of(dialogContext).pop();
                    _showSnackBarSuccess(dialogContext, loc.linkCopiedToClipboard);
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
          data: AppTheme.darkTheme,
          child: StatefulBuilder(
            builder: (context, setInnerState) {
              return AlertDialog(
                backgroundColor: const Color(0xFF1F2937),
                title: Text(
                  loc.inviteByEmailTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _webOnSurface,
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
                            color: _webOnSurface,
                          ),
                        ),
                      ] else ...[
                        if (errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade900.withValues(alpha: 0.4),
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
                            color: const Color(0xFF1F2937),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _webBorder,
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !isLoading,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: _webOnSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: loc.emailLabel,
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: _webMuted,
                                fontWeight: FontWeight.w500,
                              ),
                              hintText: loc.emailHint,
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                color: _webMuted,
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
                            color: const Color(0xFF1F2937),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _webBorder,
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            initialValue: role,
                            dropdownColor: const Color(0xFF1F2937),
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: _webOnSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'participant',
                                child: Text(
                                  loc.participantRoleLabel,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: _webOnSurface,
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
                                    color: _webOnSurface,
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
                                color: _webMuted,
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
                            color: const Color(0xFF1F2937),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _webBorder,
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: messageController,
                            maxLines: 3,
                            enabled: !isLoading,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: _webOnSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: loc.inviteOptionalMessageLabel,
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: _webMuted,
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
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
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
                            final email = emailController.text.trim();
                            final currentUser = ref.read(currentUserProvider);
                            final customMessage = messageController.text.trim().isEmpty
                                ? null
                                : messageController.text.trim();
                            _showSnackBarSuccess(
                              dialogContext,
                              loc.participantsInviteResending(email),
                            );
                            Navigator.of(dialogContext).pop(true);
                            // createInvitation cancela el pending previo y crea uno nuevo
                            // → campana/push + email (CF onCreate).
                            final invitationId = await ref.read(invitationServiceProvider).createInvitation(
                              planId: widget.plan.id!,
                              email: email,
                              invitedBy: currentUser?.id,
                              role: role,
                              customMessage: customMessage,
                            );
                            if (!mounted) return;
                            if (invitationId == null) {
                              _showSnackBarWarning(context, loc.snackCouldNotCreateInvitation);
                              return;
                            }
                            ref.invalidate(planParticipantsProvider(widget.plan.id!));
                            ref.invalidate(planRealParticipantsProvider(widget.plan.id!));
                            ref.invalidate(pendingInvitationsProvider(widget.plan.id!));
                            ref.read(planParticipationNotifierProvider(widget.plan.id!).notifier).reload();
                            if (invitationId.startsWith('direct:')) {
                              _showSnackBarSuccess(
                                context,
                                loc.snackInviteSentWillAppearPending(email),
                              );
                            } else {
                              await _showInvitationLink(invitationId);
                            }
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
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColorScheme.color2,
                                AppColorScheme.color2.withValues(alpha: 0.85),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColorScheme.color2.withValues(alpha: 0.4),
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
                                        final existingPart = await participationService.getParticipation(
                                          widget.plan.id!,
                                          existingUser.id,
                                        );
                                        if (existingPart != null &&
                                            existingPart.isActive &&
                                            existingPart.status == 'accepted') {
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
                                        if (!dialogContext.mounted) return;
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
                                        if (!dialogContext.mounted) return;
                                        _showSnackBarSuccess(dialogContext, loc.snackInviteCreatedForEmail(email));
                                        Navigator.of(dialogContext).pop(true);
                                        await _showInvitationLink(invitationId);
                                        if (mounted) setState(() {});
                                      } else {
                                        if (!dialogContext.mounted) return;
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

  Future<void> _cancelPendingEmailInvitation(PlanInvitation invitation) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final dLoc = AppLocalizations.of(dialogContext)!;
        return Theme(
          data: AppTheme.darkTheme,
          child: AlertDialog(
            backgroundColor: const Color(0xFF1F2937),
            title: Text(
              dLoc.cancelInvitationConfirmTitle,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _webOnSurface,
              ),
            ),
            content: Text(
              dLoc.cancelInvitationConfirmMessage,
              style: GoogleFonts.poppins(fontSize: 14, color: _webMuted),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(dLoc.cancel, style: GoogleFonts.poppins(color: _webMuted)),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(
                  dLoc.cancelInvitationMenuLabel,
                  style: GoogleFonts.poppins(color: Colors.red.shade400, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (confirmed != true || !mounted) return;
    final planId = widget.plan.id;
    if (planId == null || invitation.id == null) return;

    final ok = await ref.read(invitationServiceProvider).cancelInvitation(invitation.id!);
    if (!mounted) return;
    if (ok) {
      ref
        ..invalidate(pendingInvitationsProvider(planId))
        ..invalidate(invitationsForPlanProvider(planId))
        ..invalidate(planParticipantsProvider(planId))
        ..invalidate(planRealParticipantsProvider(planId));
      await ref.read(planParticipationNotifierProvider(planId).notifier).reload();
      if (!mounted) return;
      setState(() {});
      _showSnackBarSuccess(context, loc.snackInvitationCancelledShort);
    } else {
      if (!mounted) return;
      _showSnackBarError(context, loc.snackInvitationCancelFailed);
    }
  }

  Future<void> _cancelPendingParticipationInvite(PlanParticipation participation) async {
    final loc = AppLocalizations.of(context)!;
    final planId = widget.plan.id;
    if (planId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final dLoc = AppLocalizations.of(dialogContext)!;
        return Theme(
          data: AppTheme.darkTheme,
          child: AlertDialog(
            backgroundColor: const Color(0xFF1F2937),
            title: Text(
              dLoc.cancelInvitationConfirmTitle,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _webOnSurface,
              ),
            ),
            content: Text(
              dLoc.cancelInvitationConfirmMessage,
              style: GoogleFonts.poppins(fontSize: 14, color: _webMuted),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(dLoc.cancel, style: GoogleFonts.poppins(color: _webMuted)),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(
                  dLoc.cancelInvitationMenuLabel,
                  style: GoogleFonts.poppins(color: Colors.red.shade400, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (confirmed != true || !mounted) return;

    final ok = await ref.read(invitationServiceProvider).cancelPendingForParticipation(
          planId: planId,
          userId: participation.userId,
        );
    if (!mounted) return;
    if (ok) {
      ref
        ..invalidate(pendingInvitationsProvider(planId))
        ..invalidate(invitationsForPlanProvider(planId))
        ..invalidate(planParticipantsProvider(planId))
        ..invalidate(planRealParticipantsProvider(planId));
      await ref.read(planParticipationNotifierProvider(planId).notifier).reload();
      if (!mounted) return;
      setState(() {});
      _showSnackBarSuccess(context, loc.snackInvitationCancelledShort);
    } else {
      if (!mounted) return;
      _showSnackBarError(context, loc.snackInvitationCancelFailed);
    }
  }

  /// Re-invitar tras rechazo desde la fila de participantes (LISTA 116).
  Future<void> _reinviteRejectedParticipant(PlanParticipation participation) async {
    final user = _findUser(participation.userId);
    if (user != null) {
      await _inviteUser(user);
      return;
    }
    // Sin UserModel en caché: invitar por email si lo conocemos.
    try {
      final fetched = await ref.read(userServiceProvider).getUser(participation.userId);
      if (fetched != null) {
        await _inviteUser(fetched);
        return;
      }
    } catch (_) {}
    if (mounted) {
      final loc = AppLocalizations.of(context)!;
      _showSnackBarError(context, loc.snackInviteSendError('Usuario no encontrado'));
    }
  }

  Future<void> _removeParticipant(PlanParticipation participation) async {
    try {
      final planId = widget.plan.id!;
      final loc = AppLocalizations.of(context)!;
      final soloItems = await ref
          .read(planParticipationServiceProvider)
          .previewSoloOwnedItemsOnLeave(
            planId: planId,
            userId: participation.userId,
          );
      if (!mounted) return;
      final soloWarn = formatMembershipSoloItemsWarning(
        loc,
        soloItems,
        leavingSelf: false,
      );
      final message = soloWarn.isEmpty
          ? loc.participantRemoveConfirmMessage
          : '${loc.participantRemoveConfirmMessage}\n\n$soloWarn';

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return Theme(
            data: AppTheme.darkTheme,
            child: AlertDialog(
              backgroundColor: const Color(0xFF1F2937),
              title: Text(
                loc.confirmDeleteTitle,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _webOnSurface,
                ),
              ),
              content: SingleChildScrollView(
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: _webMuted,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(
                    loc.cancel,
                    style: GoogleFonts.poppins(
                      color: _webMuted,
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
                      Colors.red.shade600.withValues(alpha: 0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade600.withValues(alpha: 0.4),
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
        final currentUser = ref.read(currentUserProvider);
        final removerName = currentUser?.displayName?.trim().isNotEmpty == true
            ? currentUser!.displayName!.trim()
            : (currentUser?.email ?? 'El organizador');
        // Aviso al expulsado antes de borrar la participación (LISTA 120 / diagrama §3).
        await NotificationHelper().notifyParticipantRemoved(
          removedUserId: participation.userId,
          planId: planId,
          planName: widget.plan.name,
          removerDisplayName: removerName,
        );

        final participationService = ref.read(planParticipationServiceProvider);
        await participationService.removeParticipation(planId, participation.userId);

        await ref.read(planParticipationNotifierProvider(planId).notifier).reload();
        ref
          ..invalidate(planParticipantsProvider(planId))
          ..invalidate(planRealParticipantsProvider(planId));

        if (mounted) {
          final locOk = AppLocalizations.of(context)!;
          _showSnackBarSuccess(context, locOk.snackParticipantRemovedFromPlan);
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
        final loc = AppLocalizations.of(context)!;
        _showSnackBarError(context, loc.genericErrorWithMessage(e.toString()));
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
                  AppLocalizations.of(context)!.calculating,
                  style: GoogleFonts.poppins(
                    color: _webMuted,
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
                  AppLocalizations.of(context)!.errorLoadingParticipants(error.toString()),
                  style: GoogleFonts.poppins(
                    color: _webMuted,
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
                        AppColorScheme.color2.withValues(alpha: 0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColorScheme.color2.withValues(alpha: 0.4),
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
                      AppLocalizations.of(context)!.adminInsightsRetry,
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
        .map((p) => _findUser(p.userId)?.email.trim().toLowerCase())
        .whereType<String>()
        .toSet();
    final pendingEmailOnly = pendingInvitations
        .where((inv) => inv.email.trim().toLowerCase().isNotEmpty && !participationEmails.contains(inv.email.trim().toLowerCase()))
        .toList();

    final hasParticipants = participations.isNotEmpty;
    final hasPendingEmails = pendingEmailOnly.isNotEmpty;
    if (!hasParticipants && !hasPendingEmails) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Column(
          children: [
            Icon(Icons.group_outlined, size: 48, color: IosFormColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.adminInsightsNoParticipants,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: IosFormColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final loc = AppLocalizations.of(context)!;
    final rows = <Widget>[];
    for (var i = 0; i < participations.length; i++) {
      if (i > 0) rows.add(const IosRowSeparator());
      rows.add(_buildParticipantCard(participations[i]));
    }
    for (var i = 0; i < pendingEmailOnly.length; i++) {
      if (rows.isNotEmpty) rows.add(const IosRowSeparator());
      rows.add(_buildPendingEmailInvitationCard(pendingEmailOnly[i], loc));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IosSectionLabel(loc.participants),
          IosGroupedCard(children: rows),
        ],
      ),
    );
  }

  /// Fila para invitación pendiente por email (usuario aún no registrado).
  Widget _buildPendingEmailInvitationCard(PlanInvitation invitation, AppLocalizations loc) {
    final email = invitation.email;
    final currentUser = ref.watch(currentUserProvider);
    final isOwner = currentUser?.id == widget.plan.userId;

    return Padding(
      padding: EdgeInsets.only(
        left: IosFormColors.nestPaddingLeft(0),
        right: 4,
        top: 10,
        bottom: 10,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: PlanUserStatusColors.pendingBg,
            child: Text(
              email.isNotEmpty ? email[0].toUpperCase() : '?',
              style: TextStyle(
                color: PlanUserStatusColors.pendingText,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  email,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: IosFormColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${loc.invitationPendingEmailLabel} · ${loc.statusShortPending}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: PlanUserStatusColors.pendingText,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isOwner)
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.more_horiz, color: IosFormColors.textSecondary),
              onSelected: (value) {
                if (value == 'cancel') {
                  _cancelPendingEmailInvitation(invitation);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel_outlined, color: Colors.red.shade400, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        loc.cancelInvitationMenuLabel,
                        style: TextStyle(color: Colors.red.shade400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
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

    // Estado: solo destacar pendiente / fuera (no el chip «dentro» habitual).
    Widget? statusWidget;
    if (participation.isPending) {
      statusWidget = _statusTextChip(
        loc.statusShortPending,
        PlanUserStatusColors.pendingText,
      );
      final isMe =
          currentUser != null && participation.userId == currentUser.id && planId != null;
      if (isMe) {
        statusWidget = Material(
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
            child: statusWidget,
          ),
        );
      }
    } else if (participation.isRejected) {
      statusWidget = _statusTextChip(
        loc.statusShortOut,
        PlanUserStatusColors.outText,
      );
    }

    final showRoleLabel = participation.role != 'participant';
    final roleLabel = showRoleLabel ? _getRoleLabel(participation.role) : null;

    final subtitleParts = <String>[
      if (usernameLabel != null) usernameLabel,
      if (roleLabel != null) roleLabel,
    ];
    final subtitle = subtitleParts.join(' · ');

    final canManage = currentUser?.id == widget.plan.userId &&
        participation.userId != widget.plan.userId;

    return Padding(
      padding: EdgeInsets.only(
        left: IosFormColors.nestPaddingLeft(0),
        right: canManage ? 4 : IosFormColors.rowPaddingH,
        top: 10,
        bottom: 10,
      ),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: IosFormColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: IosFormColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (statusWidget != null) ...[
            const SizedBox(width: 8),
            statusWidget,
          ],
          if (canManage)
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.more_horiz, color: IosFormColors.textSecondary),
              onSelected: (value) {
                switch (value) {
                  case 'change_role':
                    _showRoleChangeDialog(participation);
                    break;
                  case 'remove':
                    _removeParticipant(participation);
                    break;
                  case 'cancel_invite':
                    _cancelPendingParticipationInvite(participation);
                    break;
                  case 'reinvite':
                    _reinviteRejectedParticipant(participation);
                    break;
                }
              },
              itemBuilder: (context) {
                if (participation.isPending) {
                  return [
                    PopupMenuItem(
                      value: 'cancel_invite',
                      child: Row(
                        children: [
                          Icon(Icons.cancel_outlined, color: Colors.red.shade400),
                          const SizedBox(width: 8),
                          Text(
                            loc.cancelInvitationMenuLabel,
                            style: TextStyle(color: Colors.red.shade400),
                          ),
                        ],
                      ),
                    ),
                  ];
                }
                if (participation.isRejected) {
                  return [
                    PopupMenuItem(
                      value: 'reinvite',
                      child: Row(
                        children: [
                          const Icon(Icons.mail_outline),
                          const SizedBox(width: 8),
                          Text(loc.participantsInviteResendButton),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          const Icon(Icons.remove_circle, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(loc.delete, style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ];
                }
                return [
                  PopupMenuItem(
                    value: 'change_role',
                    child: Row(
                      children: [
                        const Icon(Icons.edit),
                        const SizedBox(width: 8),
                        Text(loc.edit),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        const Icon(Icons.remove_circle, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(loc.delete, style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ];
              },
            ),
        ],
      ),
    );
  }

  Widget _statusTextChip(String label, Color color) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  void _showRoleChangeDialog(PlanParticipation participation) {
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: AppTheme.darkTheme,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1F2937),
          title: Text(
            AppLocalizations.of(context)!.edit,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _webOnSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.roleFieldLabel,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: _webMuted,
                ),
              ),
              const SizedBox(height: 16),
              RadioGroup<String>(
                groupValue: participation.role,
                onChanged: (value) {
                  if (value == null) return;
                  Navigator.of(context).pop();
                  _changeRole(participation, value);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildRoleOption('organizer',
                        AppLocalizations.of(context)!.planRoleOrganizer),
                    _buildRoleOption('participant',
                        AppLocalizations.of(context)!.planRoleParticipant),
                    _buildRoleOption('observer',
                        AppLocalizations.of(context)!.planRoleObserver),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(String role, String label) {
    return RadioListTile<String>(
      value: role,
      activeColor: AppColorScheme.color2,
      title: Text(
        label,
        style: GoogleFonts.poppins(
          color: _webOnSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _getRoleDescription(role),
        style: GoogleFonts.poppins(
          color: _webMuted,
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IosGroupedCard(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: IosFormColors.nestPaddingLeft(0),
                  right: IosFormColors.rowPaddingH,
                  top: 12,
                  bottom: 12,
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
                            AppLocalizations.of(context)!.planCardLeavePlanTitle,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: IosFormColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppLocalizations.of(context)!
                                .planCardLeavePlanConfirmBody(widget.plan.name),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: IosFormColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showLeavePlanConfirmation(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange.shade300,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.planCardLeavePlanButton,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showLeavePlanConfirmation() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || widget.plan.id == null) return;
    final loc = AppLocalizations.of(context)!;
    final soloItems = await ref
        .read(planParticipationServiceProvider)
        .previewSoloOwnedItemsOnLeave(
          planId: widget.plan.id!,
          userId: currentUser.id,
        );
    if (!mounted) return;
    final soloWarn = formatMembershipSoloItemsWarning(
      loc,
      soloItems,
      leavingSelf: true,
    );
    final body = soloWarn.isEmpty
        ? loc.planCardLeavePlanConfirmBody(widget.plan.name)
        : '${loc.planCardLeavePlanConfirmBody(widget.plan.name)}\n\n$soloWarn';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Theme(
          data: AppTheme.darkTheme,
          child: AlertDialog(
            backgroundColor: const Color(0xFF1F2937),
            title: Text(
              loc.planCardLeavePlanTitle,
              style: GoogleFonts.poppins(
                color: _webOnSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: SingleChildScrollView(
              child: Text(
                body,
                style: GoogleFonts.poppins(
                  color: _webMuted,
                  fontSize: 14,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(
                  loc.cancel,
                  style: GoogleFonts.poppins(
                    color: _webMuted,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(
                  loc.planCardLeavePlanButton,
                  style: GoogleFonts.poppins(
                    color: Colors.orange.shade300,
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
      final leftDisplay = currentUser.displayName?.trim().isNotEmpty == true
          ? currentUser.displayName!.trim()
          : currentUser.email;
      final organizerId = widget.plan.userId;
      final success = await participationService.removeParticipation(widget.plan.id!, currentUser.id);
      if (!mounted) return;
      if (success) {
        if (organizerId.isNotEmpty && organizerId != currentUser.id) {
          await NotificationHelper().notifyParticipantLeft(
            organizerUserId: organizerId,
            planId: widget.plan.id!,
            leftUserDisplay: leftDisplay,
            planName: widget.plan.name,
            deletedSoloItemLabels: soloOwnedItemLabelsForNotification(soloItems),
          );
        }
        if (!mounted) return;
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
  Widget _buildInviteUsersSection({bool hideTitle = false}) {
    return Consumer(
      builder: (context, ref, _) {
        final participantsAsync = ref.watch(planParticipantsProvider(widget.plan.id!));
        final loc = AppLocalizations.of(context)!;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!hideTitle) IosSectionLabel(loc.participantsInviteSectionTitle),
              IosGroupedCard(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _inviteByEmailDialog,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: IosFormColors.nestPaddingLeft(0),
                          right: IosFormColors.rowPaddingH,
                          top: 12,
                          bottom: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.mail_outline, color: IosFormColors.accent, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                loc.participantsInviteByEmailRow,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: IosFormColors.textPrimary,
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right, color: IosFormColors.textTertiary, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const IosRowSeparator(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      IosFormColors.nestPaddingLeft(0),
                      8,
                      IosFormColors.rowPaddingH,
                      8,
                    ),
                    child: TextField(
                      onChanged: _filterUsers,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: IosFormColors.textPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: loc.participantsSearchUsersHint,
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          color: IosFormColors.textTertiary,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: IosFormColors.textSecondary,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const IosRowSeparator(),
                  participantsAsync.when(
                    data: (participations) {
                      final idsBlockingInvite = participations
                          .where((p) => p.isAccepted || p.isPending)
                          .map((p) => p.userId)
                          .toSet();
                      final availableUsers = _filteredUsers
                          .where((user) =>
                              !idsBlockingInvite.contains(user.id) &&
                              user.id != widget.plan.userId)
                          .toList();

                      if (_isLoadingUsers) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (availableUsers.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          child: Text(
                            _searchQuery.isEmpty
                                ? loc.planDetailsNoAvailableParticipants
                                : loc.search,
                            style: GoogleFonts.poppins(
                              color: IosFormColors.textSecondary,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 280),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: availableUsers.length,
                          separatorBuilder: (_, __) => const IosRowSeparator(),
                          itemBuilder: (context, index) {
                            final user = availableUsers[index];
                            final username = user.username != null &&
                                    user.username!.trim().isNotEmpty
                                ? '@${user.username!.trim()}'
                                : null;
                            return Padding(
                              padding: EdgeInsets.only(
                                left: IosFormColors.nestPaddingLeft(0),
                                right: IosFormColors.rowPaddingH,
                                top: 10,
                                bottom: 10,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
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
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _formatUserDisplay(user, user.id),
                                          style: GoogleFonts.poppins(
                                            color: IosFormColors.textPrimary,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (username != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            username,
                                            style: GoogleFonts.poppins(
                                              color: IosFormColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _inviteUser(user),
                                    style: TextButton.styleFrom(
                                      foregroundColor: IosFormColors.accent,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      loc.inviteUserInvite,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
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
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        loc.errorLoadingParticipants(error.toString()),
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
        return AppLocalizations.of(context)!.planRoleOrganizer;
      case 'participant':
        return AppLocalizations.of(context)!.planRoleParticipant;
      case 'observer':
        return AppLocalizations.of(context)!.planRoleObserver;
      default:
        return AppLocalizations.of(context)!.planRoleUnknown;
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
      case 'pending': return AppLocalizations.of(context)!.statusShortPending;
      case 'accepted': return AppLocalizations.of(context)!.statusAccepted;
      case 'rejected': return AppLocalizations.of(context)!.statusRejected;
      case 'cancelled': return AppLocalizations.of(context)!.cancel;
      case 'expired': return AppLocalizations.of(context)!.close;
      default: return status ?? AppLocalizations.of(context)!.statusShortPending;
    }
  }

  Widget _buildPendingInvitationsSection({bool hideTitle = false}) {
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
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              loc.participantsInvitationsEmpty,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _webMuted,
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!hideTitle) ...[
                Text(
                  loc.invitationsSectionTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _webOnSurface,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              ...items.map((inv) {
                final created = _formatDate(inv.createdAt);
                final expires = _formatDate(inv.expiresAt);
                final statusLabel = _invitationStatusLabel(inv.status);
                final isPending = inv.status == 'pending';
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: _participantCardDecoration(radius: 18),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      title: Text(
                        inv.email,
                        style: GoogleFonts.poppins(
                          color: _webOnSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Estado: $statusLabel • Rol: ${inv.role} • Creada: $created${isPending ? ' • Expira: $expires' : ''}',
                        style: GoogleFonts.poppins(
                          color: _webMuted,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isPending)
                            IconButton(
                              tooltip: loc.tooltipCopyInviteLink,
                              icon: Icon(Icons.link, color: Colors.white70),
                              onPressed: () async {
                                final link = ref
                                    .read(invitationServiceProvider)
                                    .generateInvitationLink(inv.token);
                                await Clipboard.setData(
                                    ClipboardData(text: link));
                                if (!context.mounted) return;
                                _showSnackBarSuccess(
                                    context, loc.snackLinkCopiedShort);
                              },
                            ),
                          if (isOwner && isPending)
                            IconButton(
                              tooltip: loc.tooltipCancelAction,
                              icon: Icon(Icons.cancel,
                                  color: Colors.red.shade400),
                              onPressed: () async {
                                if (inv.id == null) return;
                                final ok = await ref
                                    .read(invitationServiceProvider)
                                    .cancelInvitation(inv.id!);
                                if (!context.mounted) return;
                                if (ok) {
                                  ref.invalidate(invitationsForPlanProvider(
                                      widget.plan.id!));
                                  if (mounted) setState(() {});
                                  _showSnackBarSuccess(context,
                                      loc.snackInvitationCancelledShort);
                                } else {
                                  _showSnackBarError(context,
                                      loc.snackInvitationCancelFailed);
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
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
            color: const Color(0xFF1F2937),
            border: Border.all(
              color: hasPendingInvitations
                  ? Colors.orange.shade400.withValues(alpha: 0.5)
                  : AppColorScheme.color2.withValues(alpha: 0.5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 12,
                offset: const Offset(0, 2),
                spreadRadius: 0,
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
                        color: _webOnSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasPendingInvitations
                          ? 'Puedes aceptarlas desde el enlace recibido en tu correo.'
                          : 'Si recibiste una invitación, acepta desde el enlace en tu correo.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _webMuted,
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
        color: _webPageBg,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
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
    final loc = AppLocalizations.of(context)!;

    Widget content() {
      final tabbedBody = DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Builder(
                builder: (context) {
                  final tabController = DefaultTabController.of(context);
                  return ListenableBuilder(
                    listenable: tabController,
                    builder: (context, _) {
                      return IosSegmentedControl(
                        labels: [
                          loc.participants,
                          loc.participantsTabInvite,
                          loc.participantsTabInvitations,
                        ],
                        selectedIndex: tabController.index,
                        fontSize: 12,
                        onChanged: tabController.animateTo,
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      _buildParticipantsList(),
                      _buildLeavePlanSection(),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      _buildInviteUsersSection(hideTitle: true),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      _buildPendingInvitationsSection(hideTitle: true),
                      _buildMyInvitationsSection(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      final gradientBox = Container(
        decoration: const BoxDecoration(color: _webPageBg),
        child: isCompact
            ? tabbedBody
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildParticipantsHeader(),
                  Expanded(child: tabbedBody),
                ],
              ),
      );

      // P15: misma barra verde que otras pestañas cuando está embebido en PlanDetailPage (iOS).
      if (isCompact && !widget.embedInScaffold && widget.showEmbeddedHeader) {
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
        data: AppTheme.darkTheme,
        child: Scaffold(
          backgroundColor: _webPageBg,
          appBar: AppBar(
            toolbarHeight: 48,
            surfaceTintColor: Colors.transparent,
            backgroundColor: _webPageBg,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              loc.participants,
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
