import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/chat/presentation/providers/chat_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// Modal que muestra la lista de planes con chats que tienen mensajes no leídos.
/// Al hacer clic en un plan se cierra el modal y se llama [onPlanSelected].
void showPlansWithUnreadChatModal({
  required BuildContext context,
  required List<Plan> plans,
  required void Function(Plan plan) onPlanSelected,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF111827),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _PlansWithUnreadChatModal(
      plans: plans,
      onPlanSelected: (plan) {
        Navigator.of(context).pop();
        onPlanSelected(plan);
      },
    ),
  );
}

class _PlansWithUnreadChatModal extends ConsumerWidget {
  static const Color _pageBg = Color(0xFF111827);
  final List<Plan> plans;
  final void Function(Plan plan) onPlanSelected;

  const _PlansWithUnreadChatModal({
    required this.plans,
    required this.onPlanSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final plansWithId = plans.where((p) => p.id != null).cast<Plan>().toList();

    // Filtrar solo planes con mensajes no leídos (watch para que se actualice en tiempo real)
    final withUnread = <Plan>[];
    for (final p in plansWithId) {
      final count = ref.watch(unreadMessagesCountProvider(p.id!)).valueOrNull ?? 0;
      if (count > 0) withUnread.add(p);
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.25,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: _pageBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  loc.dashboardTabChat,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const Divider(height: 1, color: Colors.white12),
              Flexible(
                child: withUnread.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          loc.notificationsEmpty,
                          style: GoogleFonts.poppins(color: Colors.white60),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        shrinkWrap: true,
                        itemCount: withUnread.length,
                        itemBuilder: (context, index) {
                          final plan = withUnread[index];
                          return _PlanUnreadTile(
                            plan: plan,
                            onTap: () => onPlanSelected(plan),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlanUnreadTile extends ConsumerWidget {
  static const Color _surface = Color(0xFF1F2937);
  final Plan plan;
  final VoidCallback onTap;

  const _PlanUnreadTile({
    required this.plan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = plan.id != null
        ? ref.watch(unreadMessagesCountProvider(plan.id!)).valueOrNull ?? 0
        : 0;

    if (count == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: ListTile(
        title: Text(
          plan.name,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Colors.white60,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
