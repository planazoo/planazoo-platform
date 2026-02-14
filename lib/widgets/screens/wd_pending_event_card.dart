import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/pending_email_event.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/event_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/pending_email_event_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_service.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// Tarjeta reutilizable para un evento pendiente (correo). Usada en buzón y en notificaciones unificadas.
class WdPendingEventCard extends StatelessWidget {
  final PendingEmailEvent pending;
  final String userId;
  final VoidCallback onAssign;
  final VoidCallback onDiscard;

  const WdPendingEventCard({
    super.key,
    required this.pending,
    required this.userId,
    required this.onAssign,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    pending.displayTitle,
                    style: AppTypography.bodyStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColorScheme.color1,
                    ),
                  ),
                ),
                if (!pending.isParsed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColorScheme.color4.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      loc.pendingEventUnparsed,
                      style: AppTypography.caption.copyWith(color: AppColorScheme.color4),
                    ),
                  ),
              ],
            ),
            if (pending.location != null && pending.location!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                pending.location!,
                style: AppTypography.caption.copyWith(color: AppColorScheme.color4),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDiscard,
                  child: Text(loc.pendingEventsDiscard),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onAssign,
                  child: Text(loc.pendingEventsAssignToPlan),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Acciones compartidas para asignar/descartar eventos pendientes (usadas por buzón y notificaciones).
class PendingEmailEventActions {
  PendingEmailEventActions._();

  static Future<void> showAssignDialog(
    BuildContext context,
    WidgetRef ref,
    PendingEmailEvent pending,
    String userId,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final planService = PlanService();
    final plans = await planService.getPlansForUser(userId).first;
    if (!context.mounted) return;
    if (plans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.pendingEventsNoPlans)),
      );
      return;
    }
    final selected = await showModalBottomSheet<Plan>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(loc.pendingEventAssignTitle, style: AppTypography.titleStyle),
            ),
            ...plans.map((plan) => ListTile(
                  title: Text(plan.name),
                  onTap: () => Navigator.of(ctx).pop(plan),
                )),
          ],
        ),
      ),
    );
    if (selected == null || !context.mounted) return;
    await assignToPlan(context, ref, pending, userId, selected);
  }

  static Future<void> assignToPlan(
    BuildContext context,
    WidgetRef ref,
    PendingEmailEvent pending,
    String userId,
    Plan plan,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final eventService = EventService();
    final pendingService = PendingEmailEventService();
    final start = pending.startDateTime ?? DateTime.now();
    final commonPart = EventCommonPart(
      description: pending.displayTitle,
      date: DateTime(start.year, start.month, start.day),
      startHour: start.hour,
      startMinute: start.minute,
      durationMinutes: 60,
      location: pending.location,
      family: pending.eventType,
      subtype: null,
    );
    final event = Event(
      planId: plan.id!,
      userId: userId,
      date: commonPart.date,
      hour: commonPart.startHour,
      duration: 1,
      startMinute: commonPart.startMinute,
      durationMinutes: commonPart.durationMinutes,
      description: commonPart.description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      commonPart: commonPart,
    );
    final created = await eventService.createEvent(event);
    if (created != null) {
      await pendingService.markAsAssigned(userId, pending.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.pendingEventAssigned)),
        );
      }
    }
  }

  static Future<void> discard(
    BuildContext context,
    WidgetRef ref,
    PendingEmailEvent pending,
    String userId,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.pendingEventsDiscard),
        content: Text(loc.pendingEventDiscardConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(loc.cancel)),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(loc.pendingEventsDiscard)),
        ],
      ),
    );
    if (confirmed == true) {
      await PendingEmailEventService().markAsDiscarded(userId, pending.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.pendingEventDiscarded)),
        );
      }
    }
  }
}
