import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';
import 'package:unp_calendario/widgets/plan/plan_summary_category_filter.dart';

/// Sheet de filtro por categorías del resumen.
/// Devuelve `null` si se cancela; [Set] (posiblemente vacío) o
/// un resultado con `cleared: true` vía [PlanCategoryFilterResult].
Future<PlanCategoryFilterResult?> showPlanCategoryFilterSheet({
  required BuildContext context,
  required Set<String>? current,
}) {
  return showModalBottomSheet<PlanCategoryFilterResult>(
    context: context,
    backgroundColor: IosFormColors.groupedBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (ctx) => _PlanCategoryFilterSheet(current: current),
  );
}

class PlanCategoryFilterResult {
  /// `null` = sin filtro (mostrar todo).
  final Set<String>? selected;

  const PlanCategoryFilterResult(this.selected);
}

class _PlanCategoryFilterSheet extends StatefulWidget {
  final Set<String>? current;

  const _PlanCategoryFilterSheet({required this.current});

  @override
  State<_PlanCategoryFilterSheet> createState() =>
      _PlanCategoryFilterSheetState();
}

class _PlanCategoryFilterSheetState extends State<_PlanCategoryFilterSheet> {
  late Set<String> _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.current == null
        ? PlanSummaryCategoryFilter.allKeys.toSet()
        : Set<String>.from(widget.current!);
  }

  String _labelFor(String key, AppLocalizations loc) {
    if (key == PlanSummaryCategoryFilter.accommodationKey) {
      return loc.planCategoryFilterAccommodation;
    }
    return key;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: IosFormColors.separator,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              loc.planCategoryFilterTitle,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final key in PlanSummaryCategoryFilter.allKeys)
                  FilterChip(
                    label: Text(
                      _labelFor(key, loc).toLowerCase(),
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    selected: _draft.contains(key),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _draft.add(key);
                        } else {
                          _draft.remove(key);
                        }
                      });
                    },
                    selectedColor: AppColorScheme.color2.withValues(alpha: 0.35),
                    checkmarkColor: Colors.white,
                    labelStyle: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    backgroundColor: IosFormColors.pageBg,
                    side: BorderSide(
                      color: _draft.contains(key)
                          ? AppColorScheme.color2
                          : Colors.white24,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      const PlanCategoryFilterResult(null),
                    );
                  },
                  child: Text(
                    loc.planCategoryFilterClear,
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    loc.cancel,
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColorScheme.color2,
                  ),
                  onPressed: () {
                    final all = PlanSummaryCategoryFilter.allKeys.toSet();
                    final selected = _draft.length == all.length &&
                            all.every(_draft.contains)
                        ? null
                        : Set<String>.from(_draft);
                    Navigator.of(context).pop(
                      PlanCategoryFilterResult(selected),
                    );
                  },
                  child: Text(
                    loc.planCategoryFilterApply,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
