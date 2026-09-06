import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_state_permissions.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';

class ParticipantsListWidget extends ConsumerWidget {
  final String planId;
  final bool showActions;
  /// Menos altura por tarjeta (padding y avatar más pequeños)
  final bool compact;

  const ParticipantsListWidget({
    super.key,
    required this.planId,
    this.showActions = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final participantsAsync = ref.watch(planParticipantsProvider(planId));
    final currentUser = ref.watch(currentUserProvider);
    final planAsync = ref.watch(planByIdStreamProvider(planId));
    final userService = ref.watch(userServiceProvider);

    return planAsync.when(
      data: (plan) {
        return participantsAsync.when(
      data: (participations) {
        if (participations.isEmpty) {
          return Center(
            child: Text(
              loc.noParticipants,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: participations.length,
          itemBuilder: (context, index) {
            final participation = participations[index];
            final isCurrentUser = participation.userId == currentUser?.id;
            final isOrganizer = participation.isOrganizer;

            return FutureBuilder(
              future: userService.getUser(participation.userId),
              builder: (context, snapshot) {
                final user = snapshot.data;
                final displayName = user?.displayName ?? participation.userId;
                final username = user?.username != null ? '@${user!.username}' : participation.userId;

                final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                final textColor = isDarkMode ? Colors.white : const Color(0xFF111827);
                // Estándar UIShowcase: organizador con color2 (no azul).
                final organizerBg = isDarkMode
                    ? AppColorScheme.color2.withValues(alpha: 0.3)
                    : AppColorScheme.color2.withValues(alpha: 0.2);
                final organizerFg = isDarkMode ? Colors.white : AppColorScheme.color2;

                final padding = compact ? const EdgeInsets.symmetric(horizontal: 12, vertical: 4) : const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
                final radius = compact ? 14.0 : 18.0;
                final iconSize = compact ? 14.0 : 18.0;
                return Card(
                  margin: EdgeInsets.only(bottom: compact ? 4 : 8),
                  child: ListTile(
                    contentPadding: padding,
                    leading: CircleAvatar(
                      radius: radius,
                      backgroundColor: isOrganizer
                          ? organizerBg
                          : (isDarkMode ? Colors.white.withValues(alpha: 0.12) : Colors.white70),
                      child: Icon(
                          isOrganizer ? Icons.admin_panel_settings : Icons.person,
                          color: isOrganizer
                              ? organizerFg
                              : (isDarkMode ? Colors.white70 : Colors.white.withValues(alpha: 0.12)),
                          size: iconSize),
                    ),
                    title: Text(
                      '$displayName $username',
                      style: TextStyle(
                        fontSize: compact ? 11 : 12,
                        color: textColor,
                        fontWeight: isCurrentUser ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    trailing: showActions && isCurrentUser && isOrganizer && plan != null
                        ? PopupMenuButton<String>(
                            onSelected: (value) {
                              _handleMenuAction(context, ref, participation, value, plan);
                            },
                            itemBuilder: (context) => [
                              if (!isOrganizer)
                                PopupMenuItem(
                                  value: 'make_organizer',
                                  child: Text(loc.makeOrganizer),
                                ),
                              if (!isOrganizer &&
                                  PlanStatePermissions.canRemoveParticipants(plan))
                                PopupMenuItem(
                                  value: 'remove',
                                  child: Text(loc.removeParticipant),
                                ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            );
          },
        );
      },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Center(
            child: Text(
              loc.loadParticipantsError,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Text(
          loc.loadPlanError,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    PlanParticipation participation,
    String action,
    Plan plan, // T109: Plan para verificar estado
  ) {
    final loc = AppLocalizations.of(context)!;
    final notifier = ref.read(planParticipationNotifierProvider(planId).notifier);

    switch (action) {
      case 'make_organizer':
        _showConfirmDialog(
          context,
          loc.makeOrganizer,
          loc.makeOrganizerConfirm,
          () async {
            final success = await notifier.changeParticipantRole(
              planId,
              participation.userId,
              'organizer',
            );
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.userPromotedOrganizer)),
              );
            }
          },
        );
        break;
      case 'remove':
        // T109: Verificar si se puede remover participantes según el estado del plan
        if (!PlanStatePermissions.canRemoveParticipants(plan)) {
          final blockedReason = PlanStatePermissions.getBlockedReason('remove_participants', plan);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(blockedReason ?? loc.cannotRemoveParticipantsNow),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }
        
        _showConfirmDialog(
          context,
          loc.removeParticipant,
          loc.removeParticipantConfirm,
          () async {
            final success = await notifier.removeUserFromPlan(
              planId,
              participation.userId,
            );
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.userRemovedFromPlan)),
              );
            }
          },
        );
        break;
    }
  }

  Future<void> _showConfirmDialog(
    BuildContext context,
    String title,
    String content,
    VoidCallback onConfirm,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final ok = await IosFormConfirmSheet.show(
      context: context,
      title: title,
      message: content,
      cancelLabel: loc.cancel,
      confirmLabel: loc.confirm,
    );
    if (ok) onConfirm();
  }
}
