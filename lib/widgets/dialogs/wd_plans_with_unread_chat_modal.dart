import 'package:flutter/foundation.dart' show kIsWeb;
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
    backgroundColor: kIsWeb ? const Color(0xFFF1F5F9) : Colors.grey.shade900,
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
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                loc.dashboardTabChat,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: kIsWeb ? const Color(0xFF1F2937) : Colors.white,
                ),
              ),
            ),
            Divider(
              height: 1,
              color: kIsWeb ? const Color(0xFFE2E8F0) : Colors.grey.shade700,
            ),
            Flexible(
              child: withUnread.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        loc.notificationsEmpty,
                        style: GoogleFonts.poppins(
                          color: kIsWeb
                              ? const Color(0xFF64748B)
                              : Colors.grey.shade400,
                        ),
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
        );
      },
    );
  }
}

class _PlanUnreadTile extends ConsumerWidget {
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

    return ListTile(
      title: Text(
        plan.name,
        style: GoogleFonts.poppins(
          color: kIsWeb ? const Color(0xFF0F172A) : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: kIsWeb ? const Color(0xFF64748B) : Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }
}
