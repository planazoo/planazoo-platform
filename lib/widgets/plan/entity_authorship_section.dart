import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/auth/domain/services/user_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';

/// Pie de autoría al final del formulario de evento/alojamiento (nombre + fecha).
class EntityAuthorshipSection extends ConsumerWidget {
  const EntityAuthorshipSection({
    super.key,
    required this.createdAt,
    this.createdByUserId,
    this.planId,
    this.isProposal = false,
  });

  final DateTime createdAt;
  final String? createdByUserId;
  final String? planId;
  final bool isProposal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final dateStr = DateFormatter.formatDateTime(createdAt);
    final userId = createdByUserId?.trim();
    if (userId == null || userId.isEmpty) {
      return _card(
        loc.entityAuthorshipDateOnly(dateStr),
      );
    }

    String? nameFromPlan;
    if (planId != null && planId!.isNotEmpty) {
      nameFromPlan =
          ref.watch(planParticipantDisplayNamesProvider(planId!)).valueOrNull?[userId];
    }

    if (nameFromPlan != null && nameFromPlan.trim().isNotEmpty) {
      return _card(_line(loc, nameFromPlan.trim(), dateStr));
    }

    return FutureBuilder(
      future: UserService().getUserById(userId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        var name = userId;
        if (user != null) {
          final display = user.displayName?.trim();
          final username = user.username?.trim();
          if (display != null && display.isNotEmpty) {
            name = display;
          } else if (username != null && username.isNotEmpty) {
            name = username;
          } else if (user.email.trim().isNotEmpty) {
            name = user.email.trim();
          }
        }
        return _card(_line(loc, name, dateStr));
      },
    );
  }

  String _line(AppLocalizations loc, String name, String dateStr) {
    return isProposal
        ? loc.entityAuthorshipProposedBy(name, dateStr)
        : loc.entityAuthorshipCreatedBy(name, dateStr);
  }

  Widget _card(String text) {
    return IosGroupedCard(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.person_outline,
                size: 18,
                color: IosFormColors.textTertiary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: IosFormColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
