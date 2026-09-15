import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/image_service.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';
import 'package:unp_calendario/widgets/plan/plan_cover_image.dart';
import 'package:unp_calendario/widgets/plan/wd_plan_user_status_label.dart';

/// Cabecera colapsable del plan (cover + nombre + fechas + estado).
/// Usar como único sliver en [NestedScrollView.headerSliverBuilder] (o junto a nav).
class PlanCollapsingHeader {
  PlanCollapsingHeader._();

  static const double expandedHeight = 107.52;

  static String dateRangeLabel(Plan plan) {
    final start = DateFormatter.formatDateShort(plan.startDate);
    final end = DateFormatter.formatDateShort(plan.endDate);
    final year = plan.endDate.year;
    return '$start – $end $year';
  }

  static Widget sliver({
    required Plan plan,
    required VoidCallback onBack,
    required bool collapsed,
    Widget? trailingHelp,
  }) {
    final hasCover = ImageService.isValidImageUrl(plan.imageUrl);
    final titleStyle = GoogleFonts.poppins(
      color: IosFormColors.textPrimary,
      fontSize: 17,
      fontWeight: FontWeight.w600,
    );

    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: expandedHeight,
      backgroundColor:
          collapsed ? IosFormColors.groupedBg : IosFormColors.pageBg,
      surfaceTintColor: Colors.transparent,
      elevation: collapsed ? 0.5 : 0,
      scrolledUnderElevation: collapsed ? 2 : 0,
      shadowColor: Colors.black54,
      forceElevated: collapsed,
      leading: IconButton(
        tooltip: 'volver',
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBack,
      ),
      title: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: collapsed ? 1 : 0,
        child: Row(
          children: [
            Expanded(
              child: Text(
                plan.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
            ),
            PlanUserStatusLabel(plan: plan, compact: true),
            if (trailingHelp != null) trailingHelp,
          ],
        ),
      ),
      bottom: collapsed
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: AppColorScheme.color2.withValues(alpha: 0.35),
              ),
            )
          : null,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (hasCover)
              PlanCoverImage(
                imageUrl: plan.imageUrl,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.zero,
                webMaskColor: IosFormColors.pageBg,
                error: _fallbackCover(),
              )
            else
              _fallbackCover(),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66000000),
                    Color(0xCC000000),
                  ],
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(56, 8, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dateRangeLabel(plan),
                                style: GoogleFonts.poppins(
                                  color: const Color(0xCCFFFFFF),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        PlanUserStatusLabel(plan: plan, compact: true),
                      ],
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

  static Widget _fallbackCover() {
    return ColoredBox(
      color: const Color(0xFF1C1C1E),
      child: Center(
        child: Icon(
          Icons.landscape_outlined,
          size: 48,
          color: AppColorScheme.color2.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}
