import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/features/calendar/domain/inbound_mailbox.dart';
import 'package:unp_calendario/features/calendar/domain/models/pending_email_event.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/accommodation_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/entity_communication_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/event_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/pending_email_event_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_service.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';
import 'package:unp_calendario/widgets/plan/communication_body_view.dart';
import 'package:unp_calendario/widgets/plan/compose_communication_sheet.dart';
import 'package:unp_calendario/widgets/wd_event_dialog.dart';

/// Acciones compartidas: colocar / descartar / leer (buzón y campana).
class PendingEmailEventActions {
  PendingEmailEventActions._();

  static Future<void> showBody(
    BuildContext context,
    PendingEmailEvent pending, {
    VoidCallback? onPlace,
    String? userId,
  }) async {
    final loc = AppLocalizations.of(context)!;
    final canEdit = userId != null && pending.kind == 'manual';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: IosFormColors.groupedBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pending.displayTitle,
                style: AppTypography.titleStyle.copyWith(
                  color: IosFormColors.textPrimary,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              if (pending.fromEmail != null && pending.fromEmail!.isNotEmpty)
                Text(
                  pending.fromEmail!,
                  style: AppTypography.caption.copyWith(color: IosFormColors.textSecondary),
                ),
              if (pending.createdAt != null)
                Text(
                  DateFormatter.formatDateTime(pending.createdAt!),
                  style: AppTypography.caption.copyWith(color: IosFormColors.textSecondary),
                ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: CommunicationBodyView(
                    bodyPlain: pending.bodyPlain,
                    bodyHtml: pending.bodyHtml,
                    attachments: pending.attachments,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (canEdit)
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        ComposeCommunicationSheet.show(
                          context,
                          userId: userId,
                          editingPending: pending,
                        );
                      },
                      child: Text(loc.edit),
                    ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(loc.cancel),
                  ),
                  if (onPlace != null) ...[
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        onPlace();
                      },
                      child: Text(loc.pendingEventsAssignToPlan),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> showAssignDialog(
    BuildContext context,
    WidgetRef ref,
    PendingEmailEvent pending,
    String userId,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final plans = await PlanService().getPlansForUser(userId).first;
    if (!context.mounted) return;
    if (plans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.pendingEventsNoPlans)),
      );
      return;
    }
    final selected = await showModalBottomSheet<Plan>(
      context: context,
      isScrollControlled: true,
      backgroundColor: IosFormColors.groupedBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => _PlacePlanPicker(plans: plans, loc: loc),
    );
    if (selected == null || selected.id == null || !context.mounted) return;
    await _showDestinationSheet(context, ref, pending, userId, selected);
  }

  static Future<void> _showDestinationSheet(
    BuildContext context,
    WidgetRef ref,
    PendingEmailEvent pending,
    String userId,
    Plan plan,
  ) async {
    final loc = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: IosFormColors.groupedBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => _PlaceDestinationSheet(
        pending: pending,
        userId: userId,
        plan: plan,
        loc: loc,
      ),
    );
  }

  static Future<void> discard(
    BuildContext context,
    WidgetRef ref,
    PendingEmailEvent pending,
    String userId,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await IosFormConfirmSheet.show(
      context: context,
      title: loc.pendingEventsDiscard,
      message: loc.pendingEventDiscardConfirm,
      cancelLabel: loc.cancel,
      confirmLabel: loc.pendingEventsDiscard,
      destructive: true,
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

  static Future<void> copyInboundAddress(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    await Clipboard.setData(const ClipboardData(text: kPlanoonInboundMailbox));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.pendingEventAddressCopied)),
      );
    }
  }
}

bool _placeQueryMatches(String haystack, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  return haystack.toLowerCase().contains(q);
}

class _PlaceSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool autofocus;
  final ValueChanged<String> onChanged;

  const _PlaceSearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          color: IosFormColors.textPrimary,
          fontSize: 17,
        ),
        cursorColor: IosFormColors.accent,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: IosFormColors.textTertiary,
            fontSize: 17,
          ),
          prefixIcon: const Icon(Icons.search, color: IosFormColors.textTertiary, size: 22),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, color: IosFormColors.textTertiary, size: 20),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
          filled: true,
          fillColor: IosFormColors.pageBg,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _PlacePlanPicker extends StatefulWidget {
  final List<Plan> plans;
  final AppLocalizations loc;

  const _PlacePlanPicker({required this.plans, required this.loc});

  @override
  State<_PlacePlanPicker> createState() => _PlacePlanPickerState();
}

class _PlacePlanPickerState extends State<_PlacePlanPicker> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.loc;
    final filtered = widget.plans
        .where((p) => _placeQueryMatches(p.name, _search.text))
        .toList();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  loc.pendingEventAssignTitle,
                  style: AppTypography.titleStyle.copyWith(
                    color: IosFormColors.textPrimary,
                    fontSize: 20,
                  ),
                ),
              ),
              _PlaceSearchField(
                controller: _search,
                hint: loc.pendingEventSearchPlanHint,
                autofocus: widget.plans.length > 6,
                onChanged: (_) => setState(() {}),
              ),
              const Divider(height: 1, color: IosFormColors.separator),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          loc.pendingEventSearchNoMatch,
                          style: AppTypography.caption.copyWith(color: IosFormColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final plan = filtered[i];
                          return ListTile(
                            title: Text(
                              plan.name,
                              style: const TextStyle(color: IosFormColors.textPrimary),
                            ),
                            onTap: () => Navigator.of(ctx).pop(plan),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceDestinationSheet extends StatefulWidget {
  final PendingEmailEvent pending;
  final String userId;
  final Plan plan;
  final AppLocalizations loc;

  const _PlaceDestinationSheet({
    required this.pending,
    required this.userId,
    required this.plan,
    required this.loc,
  });

  @override
  State<_PlaceDestinationSheet> createState() => _PlaceDestinationSheetState();
}

class _PlaceDestinationSheetState extends State<_PlaceDestinationSheet> {
  bool _visibleToPlan = true;
  bool _loading = true;
  bool _placing = false;
  List<_DestItem> _items = const [];
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final planId = widget.plan.id!;
    final events = await EventService().getEventsByPlanId(planId, widget.userId).first;
    final accs = await AccommodationService().getAccommodations(planId).first;
    if (!mounted) return;
    final items = <_DestItem>[
      ...events.where((e) => e.id != null).map(
            (e) => _DestItem(
              id: e.id!,
              title: e.description.isNotEmpty ? e.description : (e.commonPart?.description ?? '—'),
              subtitle: DateFormatter.formatDate(e.date),
            ),
          ),
      ...accs.where((a) => a.id != null).map(
            (a) => _DestItem(
              id: a.id!,
              title: a.hotelName,
              subtitle: DateFormatter.formatDate(a.checkIn),
              isAccommodation: true,
            ),
          ),
    ];
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  String get _visibilityLabel => _visibleToPlan
      ? widget.loc.pendingEventPlaceConfirmPlan
      : widget.loc.pendingEventPlaceConfirmPrivate;

  Future<void> _placeOn(String entityId, String name) async {
    final loc = widget.loc;
    final ok = await IosFormConfirmSheet.show(
      context: context,
      title: loc.pendingEventChooseDestination,
      message: loc.pendingEventPlaceConfirm(name, _visibilityLabel),
      cancelLabel: loc.cancel,
      confirmLabel: loc.confirm,
    );
    if (ok != true || !mounted) return;
    setState(() => _placing = true);
    try {
      await EntityCommunicationService().placeOn(
        userId: widget.userId,
        pending: widget.pending,
        entityId: entityId,
        visibility: _visibleToPlan ? 'plan' : 'private',
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.pendingEventPlacedOn(name))),
      );
    } catch (e, st) {
      LoggerService.error(
        'place communication on existing entity failed',
        context: 'PLACE_COMMUNICATION',
        error: e,
        stackTrace: st,
      );
      if (!mounted) return;
      setState(() => _placing = false);
      final code = e is FirebaseException ? e.code : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.pendingEventPlaceFailed} ($code)')),
      );
    }
  }

  Future<void> _createEvent() async {
    final loc = widget.loc;
    final rootNav = Navigator.of(context, rootNavigator: true);
    var placed = false;
    try {
      await showEventFormDialog<void>(
        context: context,
        barrierDismissible: false,
        dialog: EventDialog(
          planId: widget.plan.id,
          initialDescription: widget.pending.displayTitle,
          onSaved: (ev) async {
            final id = await EventService().createEvent(ev);
            if (id == null) {
              throw Exception('createEvent returned null');
            }
            await EntityCommunicationService().placeOn(
              userId: widget.userId,
              pending: widget.pending,
              entityId: id,
              visibility: _visibleToPlan ? 'plan' : 'private',
            );
            placed = true;
            // El diálogo va al navigator raíz; pop() sin rootNavigator cierra
            // el sheet y deja el formulario de crear abierto (segundo Guardar
            // crea otro evento sin el mail).
            if (rootNav.canPop()) {
              rootNav.pop();
            }
          },
        ),
      );
    } catch (e, st) {
      LoggerService.error(
        'place communication on new event failed',
        context: 'PLACE_COMMUNICATION',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.pendingEventPlaceFailed)),
        );
      }
      return;
    }
    if (!mounted || !placed) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.pendingEventAssigned)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.loc;
    final q = _search.text;
    final events = _items.where((i) => !i.isAccommodation && _placeQueryMatches(i.title, q)).toList();
    final accs = _items.where((i) => i.isAccommodation && _placeQueryMatches(i.title, q)).toList();
    final noMatch = !_loading && q.trim().isNotEmpty && events.isEmpty && accs.isEmpty;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.pendingEventChooseDestination,
                      style: AppTypography.titleStyle.copyWith(
                        color: IosFormColors.textPrimary,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.plan.name,
                      style: AppTypography.caption.copyWith(color: IosFormColors.textSecondary),
                    ),
                    Text(
                      widget.pending.displayTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(color: IosFormColors.textSecondary),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _visibleToPlan ? loc.pendingEventVisibilityPlan : loc.pendingEventVisibilityPrivate,
                        style: AppTypography.bodyStyle.copyWith(color: IosFormColors.textPrimary),
                      ),
                      activeTrackColor: IosFormColors.accent,
                      value: _visibleToPlan,
                      onChanged: _placing ? null : (v) => setState(() => _visibleToPlan = v),
                    ),
                  ],
                ),
              ),
              _PlaceSearchField(
                controller: _search,
                hint: loc.pendingEventSearchEventHint,
                autofocus: true,
                onChanged: (_) => setState(() {}),
              ),
              const Divider(height: 1, color: IosFormColors.separator),
              Expanded(
                child: _loading || _placing
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.add, color: IosFormColors.textPrimary),
                            title: Text(
                              loc.pendingEventCreateEvent,
                              style: const TextStyle(color: IosFormColors.textPrimary),
                            ),
                            onTap: _createEvent,
                          ),
                          if (_items.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                loc.pendingEventPlanEmpty,
                                style: AppTypography.caption.copyWith(color: IosFormColors.textSecondary),
                              ),
                            )
                          else if (noMatch)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                loc.pendingEventSearchNoMatch,
                                style: AppTypography.caption.copyWith(color: IosFormColors.textSecondary),
                              ),
                            ),
                          if (events.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                              child: Text(
                                loc.pendingEventSectionEvents,
                                style: AppTypography.caption.copyWith(color: IosFormColors.textTertiary),
                              ),
                            ),
                            ...events.map(
                              (e) => ListTile(
                                title: Text(
                                  e.title,
                                  style: const TextStyle(color: IosFormColors.textPrimary),
                                ),
                                subtitle: Text(
                                  e.subtitle,
                                  style: const TextStyle(color: IosFormColors.textSecondary),
                                ),
                                onTap: () => _placeOn(e.id, e.title),
                              ),
                            ),
                          ],
                          if (accs.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                              child: Text(
                                loc.pendingEventSectionAccommodations,
                                style: AppTypography.caption.copyWith(color: IosFormColors.textTertiary),
                              ),
                            ),
                            ...accs.map(
                              (e) => ListTile(
                                title: Text(
                                  e.title,
                                  style: const TextStyle(color: IosFormColors.textPrimary),
                                ),
                                subtitle: Text(
                                  e.subtitle,
                                  style: const TextStyle(color: IosFormColors.textSecondary),
                                ),
                                onTap: () => _placeOn(e.id, e.title),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestItem {
  final String id;
  final String title;
  final String subtitle;
  final bool isAccommodation;

  const _DestItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.isAccommodation = false,
  });
}
