import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_summary_service.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// T193: Diálogo que muestra el resumen del plan en texto y permite copiarlo.
void showPlanSummaryDialog({
  required BuildContext context,
  required Plan plan,
  required String userId,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => _PlanSummaryDialog(
      plan: plan,
      userId: userId,
    ),
  );
}

class _PlanSummaryDialog extends StatefulWidget {
  final Plan plan;
  final String userId;

  const _PlanSummaryDialog({
    required this.plan,
    required this.userId,
  });

  @override
  State<_PlanSummaryDialog> createState() => _PlanSummaryDialogState();
}

class _PlanSummaryDialogState extends State<_PlanSummaryDialog> {
  String? _summary;
  Object? _error;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  static final _summaryService = PlanSummaryService();

  Future<void> _loadSummary() async {
    try {
      final text = await _summaryService.generatePlanSummaryText(widget.plan, widget.userId);
      if (mounted) setState(() { _summary = text; _error = null; });
    } catch (e) {
      if (mounted) setState(() { _error = e; _summary = null; });
    }
  }

  Future<void> _copyToClipboard() async {
    final summary = _summary;
    if (summary == null) return;
    await Clipboard.setData(ClipboardData(text: summary));
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
    return AlertDialog(
      backgroundColor: Colors.grey.shade800,
      title: Row(
        children: [
          Icon(Icons.summarize, color: AppColorScheme.color2),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.planSummaryTitle,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(width: double.maxFinite, child: _buildContent(context)),
      actions: [
        if (_summary != null)
          TextButton.icon(
            onPressed: _copied ? null : _copyToClipboard,
            icon: Icon(_copied ? Icons.check : Icons.copy, size: 18, color: Colors.white70),
            label: Text(_copied ? l10n.planSummaryCopied : l10n.planSummaryCopy, style: const TextStyle(color: Colors.white70)),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.planSummaryClose, style: const TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            const SizedBox(height: 8),
            Text(
              _error.toString(),
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
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
              Text(l10n.planSummaryGenerating, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 400),
      child: SingleChildScrollView(
        child: SelectableText(
          _summary!,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
