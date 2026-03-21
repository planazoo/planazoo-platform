import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/image_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/invitation_providers.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/pages/pg_ui_showcase_page.dart';
import 'package:unp_calendario/shared/providers/help_text_providers.dart';

/// Barra superior del dashboard (W2–W6): logo, botón crear plan, showcase, imagen e info del plan.
class WdDashboardHeaderBar extends ConsumerWidget {
  final double columnWidth;
  final double rowHeight;
  final Plan? selectedPlan;
  final VoidCallback onCreatePlan;
  /// T252: Si se proporciona, se muestra un enlace "Ver mi resumen" en la info del plan.
  final VoidCallback? onShowMySummary;
  /// Si se proporciona, se usa para "Ver notificaciones" cuando hay invitación/participación pendiente.
  final VoidCallback? onOpenNotifications;

  const WdDashboardHeaderBar({
    super.key,
    required this.columnWidth,
    required this.rowHeight,
    required this.selectedPlan,
    required this.onCreatePlan,
    this.onShowMySummary,
    this.onOpenNotifications,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        _buildW2(context, ref, columnWidth, rowHeight),
        _buildW3(columnWidth, rowHeight),
        _buildW4(context, columnWidth, rowHeight),
        _buildW5(columnWidth, rowHeight),
        _buildW6(context, ref, columnWidth, rowHeight),
      ],
    );
  }

  Widget _buildW2(BuildContext context, WidgetRef ref, double columnWidth, double rowHeight) {
    return Positioned(
      left: columnWidth,
      top: 0,
      child: Container(
        width: columnWidth * 2,
        height: rowHeight,
        decoration: BoxDecoration(color: Colors.grey.shade900),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.dashboardLogo,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW3(double columnWidth, double rowHeight) {
    return Positioned(
      left: columnWidth * 3,
      top: 0,
      child: Container(
        width: columnWidth,
        height: rowHeight,
        decoration: BoxDecoration(color: Colors.grey.shade900),
        child: Center(
          child: GestureDetector(
            onTap: onCreatePlan,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColorScheme.color3,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColorScheme.color3.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '+',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW4(BuildContext context, double columnWidth, double rowHeight) {
    // UI Showcase movido a página Admin (solo accesible para admin desde W1).
    return Positioned(
      left: columnWidth * 4,
      top: 0,
      child: Container(
        width: columnWidth,
        height: rowHeight,
        decoration: BoxDecoration(color: Colors.grey.shade900),
        child: Row(
          children: [
            const Expanded(child: SizedBox.shrink()),
            Container(width: 4, color: AppColorScheme.color2),
          ],
        ),
      ),
    );
  }

  Widget _buildW5(double columnWidth, double rowHeight) {
    final w5Width = columnWidth + 1;
    final w5Height = rowHeight;
    final circleSize = (w5Width < w5Height ? w5Width : w5Height) * 0.8;

    return Positioned(
      left: columnWidth * 5,
      top: 0,
      child: Container(
        width: w5Width,
        height: w5Height,
        decoration: BoxDecoration(color: Colors.grey.shade900),
        child: Center(
          child: Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColorScheme.color2, width: 2),
            ),
            child: ClipOval(
              child: _buildPlanImage(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanImage() {
    if (selectedPlan?.imageUrl != null &&
        ImageService.isValidImageUrl(selectedPlan!.imageUrl)) {
      return CachedNetworkImage(
        imageUrl: selectedPlan!.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColorScheme.color2.withOpacity(0.1),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildDefaultIcon(),
      );
    }
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Container(
      color: AppColorScheme.color2.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColorScheme.color1,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildW6(
    BuildContext context,
    WidgetRef ref,
    double columnWidth,
    double rowHeight,
  ) {
    return Positioned(
      left: columnWidth * 6 - 1,
      top: 0,
      child: Container(
        width: columnWidth * 5 + 1,
        height: rowHeight,
        decoration: BoxDecoration(color: Colors.grey.shade900),
        child: selectedPlan != null
            ? _buildPlanInfoContent(context, ref)
            : _buildNoPlanSelectedInfo(context),
      ),
    );
  }

  Widget _buildPlanInfoContent(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);
    final handle = _formatUserHandle(currentUser);
    final plan = selectedPlan!;
    final isOrganizer = currentUser != null && plan.userId == currentUser.id;

    // Invitación pendiente (por email) para este plan
    final pendingInvitations = ref.watch(userPendingInvitationsProvider);
    final hasPendingInvitation = plan.id != null &&
        pendingInvitations.maybeWhen(
          data: (list) => list.any((inv) => inv.planId == plan.id),
          orElse: () => false,
        );

    // Participación pendiente (invitación directa ya creada)
    final hasPendingParticipation = plan.id != null &&
        currentUser != null &&
        ref.watch(planParticipantsProvider(plan.id!)).maybeWhen(
              data: (participants) =>
                  participants.any((p) =>
                      p.userId == currentUser.id && p.isPending),
              orElse: () => false,
            );

    String? statusLine;
    bool showOpenNotifications = false;
    if (isOrganizer) {
      statusLine = [if (handle.isNotEmpty) handle, loc.planRoleOrganizer]
          .where((s) => s.isNotEmpty)
          .join(' • ');
    } else if (hasPendingInvitation) {
      statusLine = loc.statusInvitationPending;
      showOpenNotifications = onOpenNotifications != null;
    } else if (hasPendingParticipation) {
      statusLine = loc.statusPendingToAccept;
      showOpenNotifications = onOpenNotifications != null;
    } else {
      final roleLabel = _currentPlanRoleLabel(ref, loc);
      statusLine = [
        if (handle.isNotEmpty) handle,
        if (roleLabel != null) loc.planRoleLabel(roleLabel),
      ].where((s) => s.isNotEmpty).join(' • ');
    }

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: rowHeight - 6),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                plan.name,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Row(
                children: [
                  Text(
                    '${_formatDateDDMMAA(plan.startDate)} - ${_formatDateDDMMAA(plan.endDate)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (statusLine != null && statusLine.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        statusLine,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: (hasPendingInvitation || hasPendingParticipation)
                              ? Colors.orange.shade200
                              : Colors.white.withOpacity(0.75),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              if (showOpenNotifications) ...[
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: onOpenNotifications,
                  child: Text(
                    loc.dashboardMessageCenterOpenNotifications,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColorScheme.color2,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoPlanSelectedInfo(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.dashboardSelectPlan,
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: Colors.white.withOpacity(0.6),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String? _currentPlanRoleLabel(WidgetRef ref, AppLocalizations loc) {
    final plan = selectedPlan;
    if (plan == null || plan.id == null) return null;
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return null;
    if (plan.userId == currentUser.id) {
      return loc.planRoleOrganizer;
    }
    final participantsAsync = ref.watch(planParticipantsProvider(plan.id!));
    final role = participantsAsync.maybeWhen<String?>(
      data: (participants) {
        for (final participation in participants) {
          if (participation.userId == currentUser.id) {
            return participation.role;
          }
        }
        return null;
      },
      orElse: () => null,
    );
    return _mapRoleToText(role, loc);
  }

  String _mapRoleToText(String? role, AppLocalizations loc) {
    switch (role) {
      case 'organizer':
        return loc.planRoleOrganizer;
      case 'participant':
        return loc.planRoleParticipant;
      case 'observer':
        return loc.planRoleObserver;
      default:
        return loc.planRoleUnknown;
    }
  }

  String _formatUserHandle(UserModel? user) {
    if (user == null) return '';
    final username = user.username?.trim();
    if (username != null && username.isNotEmpty) return '@$username';
    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) return email;
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    return '';
  }

  /// Formato DD/MM/AA para W6.
  static String _formatDateDDMMAA(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final a = (date.year % 100).toString().padLeft(2, '0');
    return '$d/$m/$a';
  }
}
