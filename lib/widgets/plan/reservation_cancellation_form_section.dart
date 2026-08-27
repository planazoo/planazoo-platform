import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unp_calendario/features/calendar/domain/models/reservation_cancellation.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';

/// Opción de pagador para el picker (T273).
class ReservationPayerOption {
  final String userId;
  final String label;

  const ReservationPayerOption({required this.userId, required this.label});
}

/// Bloque «Reserva / cancelación» (evento y alojamiento) — Settings-only.
class ReservationCancellationFormSection extends StatefulWidget {
  final ReservationCancellation? initial;
  final List<ReservationPayerOption> payers;
  final String? defaultTimezone;
  final String currencyCode;
  final bool readOnly;

  const ReservationCancellationFormSection({
    super.key,
    this.initial,
    required this.payers,
    this.defaultTimezone,
    this.currencyCode = 'EUR',
    this.readOnly = false,
  });

  @override
  State<ReservationCancellationFormSection> createState() =>
      ReservationCancellationFormSectionState();
}

class ReservationCancellationFormSectionState
    extends State<ReservationCancellationFormSection> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  late final TextEditingController _fixedFeeCtrl;
  late final TextEditingController _pct1Ctrl;
  late final TextEditingController _pct2Ctrl;

  String? _payerId;
  String _status = 'pending';
  String? _timezone;
  bool _enabled = false;
  bool _tier1Enabled = false;
  bool _tier2Enabled = false;
  DateTime? _deadline1;
  DateTime? _deadline2;
  String _reminderPreset = CancellationReminderPreset.defaultPreset;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    _amountCtrl = TextEditingController(
      text: init?.guaranteeAmount?.toString() ?? '',
    );
    _noteCtrl = TextEditingController(text: init?.guaranteeNote ?? '');
    _fixedFeeCtrl = TextEditingController(
      text: init?.cancellationFixedFee?.toString() ?? '',
    );
    _payerId = init?.guaranteePayerUserId;
    _status = init?.guaranteeStatus ?? 'pending';
    _timezone = init?.timezone ?? widget.defaultTimezone;
    _reminderPreset =
        init?.reminderPreset ?? CancellationReminderPreset.defaultPreset;
    if (!CancellationReminderPreset.all.contains(_reminderPreset)) {
      _reminderPreset = CancellationReminderPreset.defaultPreset;
    }
    final tiers = init?.tiers ?? const <CancellationTier>[];
    if (tiers.isNotEmpty) {
      _tier1Enabled = true;
      _deadline1 = tiers[0].deadlineAt;
      _pct1Ctrl = TextEditingController(
        text: tiers[0].refundPercent.toStringAsFixed(
          tiers[0].refundPercent == tiers[0].refundPercent.roundToDouble()
              ? 0
              : 1,
        ),
      );
    } else {
      _pct1Ctrl = TextEditingController(text: '100');
    }
    if (tiers.length > 1) {
      _tier2Enabled = true;
      _deadline2 = tiers[1].deadlineAt;
      _pct2Ctrl = TextEditingController(
        text: tiers[1].refundPercent.toStringAsFixed(
          tiers[1].refundPercent == tiers[1].refundPercent.roundToDouble()
              ? 0
              : 1,
        ),
      );
    } else {
      _pct2Ctrl = TextEditingController(text: '50');
    }
    _enabled = init != null && !init.isEmpty;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _fixedFeeCtrl.dispose();
    _pct1Ctrl.dispose();
    _pct2Ctrl.dispose();
    super.dispose();
  }

  /// Valor actual del bloque (null si desactivado o vacío).
  ReservationCancellation? toModel() {
    if (!_enabled) return null;
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    final fixedFee = double.tryParse(_fixedFeeCtrl.text.replaceAll(',', '.'));
    final tiers = <CancellationTier>[];
    if (_tier1Enabled && _deadline1 != null) {
      final pct = double.tryParse(_pct1Ctrl.text.replaceAll(',', '.')) ?? 0;
      tiers.add(CancellationTier(
        deadlineAt: _deadline1!,
        refundPercent: pct.clamp(0, 100),
      ));
    }
    if (_tier2Enabled && _deadline2 != null) {
      final pct = double.tryParse(_pct2Ctrl.text.replaceAll(',', '.')) ?? 0;
      tiers.add(CancellationTier(
        deadlineAt: _deadline2!,
        refundPercent: pct.clamp(0, 100),
      ));
    }

    final reminder =
        ReservationCancellation.parseReminderPreset(_reminderPreset);
    final model = ReservationCancellation(
      guaranteeAmount: (amount != null && amount > 0) ? amount : null,
      guaranteePayerUserId: _payerId,
      guaranteeStatus: _status,
      guaranteeNote:
          _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      tiers: tiers,
      cancellationFixedFee:
          (fixedFee != null && fixedFee > 0) ? fixedFee : null,
      timezone: _timezone,
      reminderLeadHours: reminder.leadHours,
      reminderAlsoOnDay: reminder.alsoOnDay,
    );
    return model.isEmpty ? null : model;
  }

  String _moneyDisplay(TextEditingController ctrl) {
    final raw = ctrl.text.trim();
    if (raw.isEmpty) return '—';
    return '$raw ${widget.currencyCode}';
  }

  String _percentDisplay(TextEditingController ctrl) {
    final raw = ctrl.text.trim();
    if (raw.isEmpty) return '—';
    return raw.endsWith('%') ? raw : '$raw%';
  }

  Future<void> _editMoneyField({
    required String title,
    required TextEditingController controller,
  }) async {
    if (widget.readOnly) return;
    final loc = AppLocalizations.of(context)!;
    final temp = TextEditingController(text: controller.text);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: IosFormColors.groupedBg,
        title: Text(
          title,
          style: const TextStyle(
            color: IosFormColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: temp,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          style: const TextStyle(color: IosFormColors.textPrimary, fontSize: 17),
          decoration: InputDecoration(
            hintText: '0',
            suffixText: widget.currencyCode,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, temp.text),
            child: Text(loc.save),
          ),
        ],
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => temp.dispose());
    if (!mounted || result == null) return;
    setState(() => controller.text = result.trim());
  }

  Future<void> _editPercentField(TextEditingController controller) async {
    if (widget.readOnly) return;
    final loc = AppLocalizations.of(context)!;
    final temp = TextEditingController(text: controller.text.replaceAll('%', ''));
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: IosFormColors.groupedBg,
        title: Text(
          loc.reservationFieldPercent,
          style: const TextStyle(
            color: IosFormColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: temp,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          style: const TextStyle(color: IosFormColors.textPrimary, fontSize: 17),
          decoration: const InputDecoration(
            hintText: '0',
            suffixText: '%',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, temp.text),
            child: Text(loc.save),
          ),
        ],
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => temp.dispose());
    if (!mounted || result == null) return;
    setState(() => controller.text = result.trim());
  }

  Future<void> _openNoteEditor(AppLocalizations loc) async {
    if (widget.readOnly) return;
    final temp = TextEditingController(text: _noteCtrl.text);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: IosFormColors.groupedBg,
        title: Text(
          loc.reservationFieldNote,
          style: const TextStyle(
            color: IosFormColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SizedBox(
          width: 480,
          child: TextField(
            controller: temp,
            minLines: 4,
            maxLines: 8,
            autofocus: true,
            style: const TextStyle(color: IosFormColors.textPrimary, fontSize: 17),
            decoration: InputDecoration(
              hintText: loc.reservationGuaranteeNote,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, temp.text),
            child: Text(loc.save),
          ),
        ],
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => temp.dispose());
    if (!mounted || result == null) return;
    setState(() => _noteCtrl.text = result);
  }

  Future<void> _pickDeadline(int tierIndex) async {
    if (widget.readOnly) return;
    final initial = tierIndex == 1
        ? (_deadline1 ?? DateTime.now().add(const Duration(days: 7)))
        : (_deadline2 ?? DateTime.now().add(const Duration(days: 3)));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;
    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (tierIndex == 1) {
        _deadline1 = combined;
      } else {
        _deadline2 = combined;
      }
    });
  }

  String _formatDeadline(DateTime? dt) {
    if (dt == null) return '—';
    final d =
        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    final t =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$d $t';
  }

  String _statusLabel(AppLocalizations loc, String status) {
    switch (status) {
      case 'paid':
        return loc.reservationStatusPaid;
      case 'refunded':
        return loc.reservationStatusRefunded;
      case 'retained':
        return loc.reservationStatusRetained;
      case 'pending':
      default:
        return loc.reservationStatusPending;
    }
  }

  String _payerLabel(AppLocalizations loc) {
    if (_payerId == null) return loc.reservationPayerNone;
    for (final p in widget.payers) {
      if (p.userId == _payerId) return p.label;
    }
    return loc.reservationPayerNone;
  }

  String _timezoneLabel() {
    final tz = _timezone;
    if (tz == null || tz.isEmpty) return '—';
    return TimezoneService.getTimezoneDisplayName(tz);
  }

  String _reminderLabel(AppLocalizations loc, [String? preset]) {
    switch (preset ?? _reminderPreset) {
      case CancellationReminderPreset.none:
        return loc.reservationReminderNone;
      case CancellationReminderPreset.day:
        return loc.reservationReminderDayOf;
      case CancellationReminderPreset.h24:
        return loc.reservationReminder24h;
      case CancellationReminderPreset.h24Day:
        return loc.reservationReminder24hAndDay;
      case CancellationReminderPreset.h48:
        return loc.reservationReminder48h;
      case CancellationReminderPreset.h48Day:
        return loc.reservationReminder48hAndDay;
      case CancellationReminderPreset.h168:
        return loc.reservationReminder7d;
      case CancellationReminderPreset.h168Day:
        return loc.reservationReminder7dAndDay;
      default:
        return loc.reservationReminderNone;
    }
  }

  Future<void> _pickStatus(AppLocalizations loc) async {
    if (widget.readOnly) return;
    final picked = await IosFormPickerSheet.show<String>(
      context: context,
      title: loc.reservationGuaranteeStatus,
      options: [
        for (final s in const ['pending', 'paid', 'refunded', 'retained'])
          IosFormPickerOption(
            value: s,
            title: _statusLabel(loc, s),
            selected: _status == s,
          ),
      ],
    );
    if (!mounted || picked == null) return;
    setState(() => _status = picked);
  }

  Future<void> _pickPayer(AppLocalizations loc) async {
    if (widget.readOnly) return;
    final picked = await IosFormPickerSheet.show<String>(
      context: context,
      title: loc.reservationGuaranteePayer,
      options: [
        IosFormPickerOption(
          value: '',
          title: loc.reservationPayerNone,
          selected: _payerId == null,
        ),
        ...widget.payers.map(
          (p) => IosFormPickerOption(
            value: p.userId,
            title: p.label,
            selected: _payerId == p.userId,
          ),
        ),
      ],
    );
    if (!mounted || picked == null) return;
    setState(() => _payerId = picked.isEmpty ? null : picked);
  }

  Future<void> _pickTimezone(AppLocalizations loc) async {
    if (widget.readOnly) return;
    final tzList = TimezoneService.getCommonTimezones().toList();
    if (_timezone != null && !tzList.contains(_timezone)) {
      tzList.insert(0, _timezone!);
    }
    final picked = await IosFormPickerSheet.show<String>(
      context: context,
      title: loc.reservationItemTimezone,
      options: [
        for (final tz in tzList)
          IosFormPickerOption(
            value: tz,
            title: TimezoneService.getTimezoneDisplayName(tz),
            selected: _timezone == tz,
          ),
      ],
    );
    if (!mounted || picked == null) return;
    setState(() => _timezone = picked);
  }

  Future<void> _pickReminder(AppLocalizations loc) async {
    if (widget.readOnly) return;
    final picked = await IosFormPickerSheet.show<String>(
      context: context,
      title: loc.reservationReminderSchedule,
      options: [
        for (final p in CancellationReminderPreset.all)
          IosFormPickerOption(
            value: p,
            title: _reminderLabel(loc, p),
            selected: _reminderPreset == p,
          ),
      ],
    );
    if (!mounted || picked == null) return;
    setState(() => _reminderPreset = picked);
  }

  List<Widget> _tierRows({
    required AppLocalizations loc,
    required bool enabled,
    required ValueChanged<bool> onEnabled,
    required String label,
    required DateTime? deadline,
    required VoidCallback onPickDeadline,
    required TextEditingController pctCtrl,
  }) {
    return [
      IosSwitchRow(
        label: label,
        value: enabled,
        nestLevel: 1,
        onChanged: widget.readOnly ? null : onEnabled,
      ),
      if (enabled) ...[
        const IosRowSeparator(nestLevel: 2),
        IosSettingsRow(
          label: loc.reservationTierDeadlineShort,
          value: _formatDeadline(deadline),
          nestLevel: 2,
          chevron: !widget.readOnly,
          onTap: widget.readOnly ? null : onPickDeadline,
        ),
        const IosRowSeparator(nestLevel: 2),
        IosSettingsRow(
          label: loc.reservationFieldPercent,
          value: _percentDisplay(pctCtrl),
          nestLevel: 2,
          chevron: !widget.readOnly,
          onTap: widget.readOnly ? null : () => _editPercentField(pctCtrl),
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final canEdit = !widget.readOnly;
    final notePreview = _noteCtrl.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IosGroupedCard(
          children: [
            IosSwitchRow(
              label: loc.reservationCancellationSectionTitle,
              value: _enabled,
              onChanged: canEdit
                  ? (v) => setState(() => _enabled = v)
                  : null,
            ),
            if (_enabled) ...[
              const IosRowSeparator(),
              IosGroupedCardCaption(loc.reservationGuaranteeLabel, nestLevel: 1),
              IosSettingsRow(
                label: loc.reservationFieldGuarantee,
                value: _moneyDisplay(_amountCtrl),
                nestLevel: 1,
                chevron: canEdit,
                onTap: canEdit
                    ? () => _editMoneyField(
                          title: loc.reservationFieldGuarantee,
                          controller: _amountCtrl,
                        )
                    : null,
              ),
              const IosRowSeparator(nestLevel: 1),
              IosSettingsRow(
                label: loc.reservationFieldStatus,
                value: _statusLabel(loc, _status),
                nestLevel: 1,
                chevron: canEdit,
                onTap: canEdit ? () => _pickStatus(loc) : null,
              ),
              const IosRowSeparator(nestLevel: 1),
              IosSettingsRow(
                label: loc.reservationFieldPayer,
                value: _payerLabel(loc),
                nestLevel: 1,
                chevron: canEdit,
                onTap: canEdit ? () => _pickPayer(loc) : null,
              ),
              const IosRowSeparator(nestLevel: 1),
              IosSettingsRow(
                label: loc.reservationFieldNote,
                value: notePreview.isEmpty ? '—' : notePreview,
                multiline: notePreview.length > 36,
                nestLevel: 1,
                chevron: canEdit,
                onTap: canEdit ? () => _openNoteEditor(loc) : null,
              ),
              const IosRowSeparator(nestLevel: 1),
              IosGroupedCardCaption(
                loc.reservationCancellationPolicyLabel,
                nestLevel: 1,
              ),
              IosSettingsRow(
                label: loc.reservationFieldTimezone,
                value: _timezoneLabel(),
                nestLevel: 1,
                chevron: canEdit,
                onTap: canEdit ? () => _pickTimezone(loc) : null,
              ),
              const IosRowSeparator(nestLevel: 1),
              IosSettingsRow(
                label: loc.reservationFieldReminder,
                value: _reminderLabel(loc),
                nestLevel: 1,
                chevron: canEdit,
                onTap: canEdit ? () => _pickReminder(loc) : null,
              ),
            ],
          ],
        ),
        if (_enabled) ...[
          const SizedBox(height: IosFormColors.cardGap),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IosGroupedCard(
              children: [
                IosSettingsRow(
                  label: loc.reservationFieldFixedFee,
                  value: _moneyDisplay(_fixedFeeCtrl),
                  nestLevel: 1,
                  chevron: canEdit,
                  onTap: canEdit
                      ? () => _editMoneyField(
                            title: loc.reservationFieldFixedFee,
                            controller: _fixedFeeCtrl,
                          )
                      : null,
                ),
                const IosRowSeparator(nestLevel: 1),
                ..._tierRows(
                  loc: loc,
                  enabled: _tier1Enabled,
                  onEnabled: (v) => setState(() => _tier1Enabled = v),
                  label: loc.reservationTier1,
                  deadline: _deadline1,
                  onPickDeadline: () => _pickDeadline(1),
                  pctCtrl: _pct1Ctrl,
                ),
                const IosRowSeparator(nestLevel: 1),
                ..._tierRows(
                  loc: loc,
                  enabled: _tier2Enabled,
                  onEnabled: (v) => setState(() => _tier2Enabled = v),
                  label: loc.reservationTier2,
                  deadline: _deadline2,
                  onPickDeadline: () => _pickDeadline(2),
                  pctCtrl: _pct2Ctrl,
                ),
              ],
            ),
          ),
          IosFormFooter(loc.reservationFixedFeeHint, nestLevel: 1),
          IosFormFooter(loc.reservationRefundPercentHint, nestLevel: 1),
          IosFormFooter(loc.reservationReminderScheduleHint, nestLevel: 1),
        ],
      ],
    );
  }
}
