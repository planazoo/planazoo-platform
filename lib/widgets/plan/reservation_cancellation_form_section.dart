import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/reservation_cancellation.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// Opción de pagador para el dropdown (T273).
class ReservationPayerOption {
  final String userId;
  final String label;

  const ReservationPayerOption({required this.userId, required this.label});
}

/// Bloque «Reserva / cancelación» reutilizable en evento y alojamiento.
/// Estilo alineado con el form de evento (compacto, campos en paralelo).
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
  static const Color _fieldSurface = Color(0xFF1F2937);
  static const double _fieldRadius = 14;
  static const double _gap = 10;

  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  late final TextEditingController _fixedFeeCtrl;
  late final TextEditingController _pct1Ctrl;
  late final TextEditingController _pct2Ctrl;

  String? _payerId;
  String _status = 'pending';
  String? _timezone;
  bool _expanded = false;
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
    _expanded = init != null && !init.isEmpty;
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

  /// Valor actual del bloque (null si vacío).
  ReservationCancellation? toModel() {
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

  Future<void> _openReservationNotesEditor() async {
    final loc = AppLocalizations.of(context)!;
    final tempController = TextEditingController(text: _noteCtrl.text);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          loc.reservationGuaranteeNote,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SizedBox(
          width: 680,
          child: TextField(
            controller: tempController,
            minLines: 8,
            maxLines: 16,
            autofocus: true,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              hintText: loc.reservationGuaranteeNote,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(tempController.text),
            child: Text(loc.save),
          ),
        ],
      ),
    );
    // Evitar dispose mientras el TextField del diálogo sigue montado.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tempController.dispose();
    });
    if (!mounted || result == null) return;
    setState(() {
      _noteCtrl.text = result;
    });
  }

  TextStyle get _labelOnBorderStyle => GoogleFonts.poppins(
        fontSize: 11,
        color: Colors.white70,
        fontWeight: FontWeight.w500,
      );

  TextStyle get _valueStyle => GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.white,
        fontWeight: FontWeight.w500,
        height: 1.2,
      );

  BoxDecoration get _borderedDecoration => BoxDecoration(
        color: _fieldSurface,
        borderRadius: BorderRadius.circular(_fieldRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      );

  InputDecoration _innerDec({String? hint, IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.white54),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 18, color: Colors.white70)
          : null,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  /// Campo con etiqueta sobre el borde (mismo patrón que fecha/hora del evento).
  Widget _labelOnBorder({
    required String label,
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      decoration: _borderedDecoration,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 12,
            top: -7,
            child: Container(
              color: _fieldSurface,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(label, style: _labelOnBorderStyle),
            ),
          ),
          Padding(
            padding: padding ??
                const EdgeInsets.only(top: 10, left: 4, right: 4, bottom: 4),
            child: child,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final tzList = TimezoneService.getCommonTimezones().toList();
    if (_timezone != null && !tzList.contains(_timezone)) {
      tzList.insert(0, _timezone!);
    }

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: Material(
        color: _fieldSurface,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          initiallyExpanded: _expanded,
          onExpansionChanged: (v) => setState(() => _expanded = v),
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          iconColor: Colors.white70,
          collapsedIconColor: Colors.white70,
          title: Text(
            loc.reservationCancellationSectionTitle,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            loc.reservationCancellationSectionSubtitle,
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12),
          ),
          children: [
            AbsorbPointer(
              absorbing: widget.readOnly,
              child: Opacity(
                opacity: widget.readOnly ? 0.7 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Garantía + estado
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _labelOnBorder(
                            label: loc.reservationGuaranteeAmount(
                                widget.currencyCode),
                            child: TextField(
                              controller: _amountCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.,]')),
                              ],
                              style: _valueStyle,
                              decoration: _innerDec(
                                hint: '0',
                                prefixIcon: Icons.account_balance_wallet_outlined,
                              ).copyWith(suffixText: widget.currencyCode),
                            ),
                          ),
                        ),
                        const SizedBox(width: _gap),
                        Expanded(
                          flex: 5,
                          child: _labelOnBorder(
                            label: loc.reservationGuaranteeStatus,
                            child: DropdownButtonFormField<String>(
                              value: _status,
                              isExpanded: true,
                              isDense: true,
                              dropdownColor: _fieldSurface,
                              style: _valueStyle,
                              decoration: _innerDec(),
                              items: [
                                DropdownMenuItem(
                                    value: 'pending',
                                    child: Text(loc.reservationStatusPending)),
                                DropdownMenuItem(
                                    value: 'paid',
                                    child: Text(loc.reservationStatusPaid)),
                                DropdownMenuItem(
                                    value: 'refunded',
                                    child:
                                        Text(loc.reservationStatusRefunded)),
                                DropdownMenuItem(
                                    value: 'retained',
                                    child:
                                        Text(loc.reservationStatusRetained)),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _status = v);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: _gap),
                    // Pagador + cargo fijo
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: _labelOnBorder(
                            label: loc.reservationGuaranteePayer,
                            child: DropdownButtonFormField<String>(
                              value: _payerId != null &&
                                      widget.payers
                                          .any((p) => p.userId == _payerId)
                                  ? _payerId
                                  : null,
                              isExpanded: true,
                              isDense: true,
                              dropdownColor: _fieldSurface,
                              style: _valueStyle,
                              decoration: _innerDec(
                                prefixIcon: Icons.person_outline,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(
                                    loc.reservationPayerNone,
                                    style: GoogleFonts.poppins(
                                        color: Colors.white70, fontSize: 13),
                                  ),
                                ),
                                ...widget.payers.map(
                                  (p) => DropdownMenuItem(
                                    value: p.userId,
                                    child: Text(
                                      p.label,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (v) => setState(() => _payerId = v),
                            ),
                          ),
                        ),
                        const SizedBox(width: _gap),
                        Expanded(
                          flex: 4,
                          child: _labelOnBorder(
                            label: loc.reservationFixedFee(widget.currencyCode),
                            child: TextField(
                              controller: _fixedFeeCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.,]')),
                              ],
                              style: _valueStyle,
                              decoration: _innerDec(hint: '0')
                                  .copyWith(suffixText: widget.currencyCode),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: _gap),
                    // Nota (multilínea, como notas del evento)
                    _labelOnBorder(
                      label: loc.reservationGuaranteeNote,
                      child: TextField(
                        controller: _noteCtrl,
                        minLines: 2,
                        maxLines: 4,
                        style: _valueStyle,
                        decoration: _innerDec(prefixIcon: Icons.notes_outlined)
                            .copyWith(
                          alignLabelWithHint: true,
                          suffixIcon: IconButton(
                            tooltip: 'Ampliar',
                            onPressed: widget.readOnly
                                ? null
                                : _openReservationNotesEditor,
                            icon: const Icon(
                              Icons.open_in_full,
                              size: 18,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: _gap),
                    // TZ + aviso
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _labelOnBorder(
                            label: loc.reservationItemTimezone,
                            child: DropdownButtonFormField<String>(
                              value: _timezone != null &&
                                      tzList.contains(_timezone)
                                  ? _timezone
                                  : (tzList.isNotEmpty ? tzList.first : null),
                              isExpanded: true,
                              isDense: true,
                              dropdownColor: _fieldSurface,
                              style: _valueStyle,
                              decoration: _innerDec(
                                prefixIcon: Icons.public,
                              ),
                              items: tzList
                                  .map(
                                    (tz) => DropdownMenuItem(
                                      value: tz,
                                      child: Text(
                                        TimezoneService.getTimezoneDisplayName(
                                            tz),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _timezone = v),
                            ),
                          ),
                        ),
                        const SizedBox(width: _gap),
                        Expanded(
                          flex: 5,
                          child: _labelOnBorder(
                            label: loc.reservationReminderSchedule,
                            child: DropdownButtonFormField<String>(
                              value: _reminderPreset,
                              isExpanded: true,
                              isDense: true,
                              dropdownColor: _fieldSurface,
                              style: _valueStyle,
                              decoration: _innerDec(
                                prefixIcon: Icons.notifications_outlined,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: CancellationReminderPreset.none,
                                  child: Text(loc.reservationReminderNone),
                                ),
                                DropdownMenuItem(
                                  value: CancellationReminderPreset.day,
                                  child: Text(loc.reservationReminderDayOf),
                                ),
                                DropdownMenuItem(
                                  value: CancellationReminderPreset.h24,
                                  child: Text(loc.reservationReminder24h),
                                ),
                                DropdownMenuItem(
                                  value: CancellationReminderPreset.h24Day,
                                  child:
                                      Text(loc.reservationReminder24hAndDay),
                                ),
                                DropdownMenuItem(
                                  value: CancellationReminderPreset.h48,
                                  child: Text(loc.reservationReminder48h),
                                ),
                                DropdownMenuItem(
                                  value: CancellationReminderPreset.h48Day,
                                  child:
                                      Text(loc.reservationReminder48hAndDay),
                                ),
                                DropdownMenuItem(
                                  value: CancellationReminderPreset.h168,
                                  child: Text(loc.reservationReminder7d),
                                ),
                                DropdownMenuItem(
                                  value: CancellationReminderPreset.h168Day,
                                  child:
                                      Text(loc.reservationReminder7dAndDay),
                                ),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() => _reminderPreset = v);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: _gap),
                    // Tramos (compactos, sin tarjeta anidada)
                    _buildCompactTier(
                      loc: loc,
                      enabled: _tier1Enabled,
                      onEnabled: (v) => setState(() => _tier1Enabled = v),
                      label: loc.reservationTier1,
                      deadline: _deadline1,
                      onPickDeadline: () => _pickDeadline(1),
                      pctCtrl: _pct1Ctrl,
                    ),
                    const SizedBox(height: 8),
                    _buildCompactTier(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactTier({
    required AppLocalizations loc,
    required bool enabled,
    required ValueChanged<bool> onEnabled,
    required String label,
    required DateTime? deadline,
    required VoidCallback onPickDeadline,
    required TextEditingController pctCtrl,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: Checkbox(
            value: enabled,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            onChanged: (v) => onEnabled(v ?? false),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 6,
          child: Opacity(
            opacity: enabled ? 1 : 0.45,
            child: IgnorePointer(
              ignoring: !enabled,
              child: _labelOnBorder(
                label: loc.reservationTierDeadlineShort,
                padding: const EdgeInsets.only(
                    top: 8, left: 2, right: 2, bottom: 2),
                child: InkWell(
                  onTap: onPickDeadline,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.event, size: 16, color: Colors.white70),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _formatDeadline(deadline),
                            style: _valueStyle.copyWith(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 72,
          child: Opacity(
            opacity: enabled ? 1 : 0.45,
            child: IgnorePointer(
              ignoring: !enabled,
              child: _labelOnBorder(
                label: loc.reservationRefundPercentShort,
                padding: const EdgeInsets.only(
                    top: 8, left: 2, right: 2, bottom: 2),
                child: TextField(
                  controller: pctCtrl,
                  textAlign: TextAlign.center,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  style: _valueStyle,
                  decoration: _innerDec(hint: '%').copyWith(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 10),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
