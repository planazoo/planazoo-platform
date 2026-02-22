import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_summary_service.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// Vista de resumen del plan para W31 (solo desde pestaña Calendario).
/// Muestra el texto generado y un botón para volver al calendario.
class WdPlanSummaryScreen extends StatefulWidget {
  final Plan plan;
  final String userId;
  final VoidCallback onShowCalendar;

  const WdPlanSummaryScreen({
    super.key,
    required this.plan,
    required this.userId,
    required this.onShowCalendar,
  });

  @override
  State<WdPlanSummaryScreen> createState() => _WdPlanSummaryScreenState();
}

class _WdPlanSummaryScreenState extends State<WdPlanSummaryScreen> {
  String? _summary;
  Object? _error;
  bool _copied = false;

  static final _summaryService = PlanSummaryService();

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  @override
  void didUpdateWidget(WdPlanSummaryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plan.id != widget.plan.id || oldWidget.userId != widget.userId) {
      _loadSummary();
    }
  }

  Future<void> _loadSummary() async {
    setState(() {
      _summary = null;
      _error = null;
      _copied = false;
    });
    try {
      final text = await _summaryService.generatePlanSummaryText(widget.plan, widget.userId);
      if (mounted) setState(() { _summary = text; _error = null; });
    } catch (e) {
      if (mounted) setState(() { _error = e; _summary = null; });
    }
  }

  Future<void> _copyToClipboard() async {
    if (_summary == null) return;
    await Clipboard.setData(ClipboardData(text: _summary!));
    if (!mounted) return;
    setState(() => _copied = true);
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.planSummaryCopiedToClipboard),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.grey.shade800,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: widget.onShowCalendar,
                  icon: const Icon(Icons.calendar_today, size: 18, color: Colors.white),
                  label: Text(
                    l10n.dashboardTabCalendar,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 36),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    l10n.planSummaryTitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (_summary != null)
                  TextButton.icon(
                    onPressed: _copied ? null : _copyToClipboard,
                    icon: Icon(
                      _copied ? Icons.check : Icons.copy,
                      size: 18,
                      color: Colors.white70,
                    ),
                    label: Text(
                      _copied ? l10n.planSummaryCopied : l10n.planSummaryCopy,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildContent(l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(
              l10n.planSummaryError,
              style: GoogleFonts.poppins(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    if (_summary == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColorScheme.color2),
              const SizedBox(height: 16),
              Text(
                l10n.planSummaryGenerating,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }
    return SelectableText(
      _summary!,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 13,
        height: 1.5,
      ),
    );
  }
}
