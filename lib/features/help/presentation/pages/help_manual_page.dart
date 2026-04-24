import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// Manual rápido para nuevos usuarios durante fase de pruebas.
/// Ruta pública web: /help
class HelpManualPage extends StatelessWidget {
  const HelpManualPage({super.key});
  static const Color _pageBg = Color(0xFF111827);
  static const Color _surface = Color(0xFF1F2937);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: _pageBg,
        appBar: AppBar(
          title: Text(
            loc.helpManualTitle,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColorScheme.color2,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    loc.helpManualIntro,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    context,
                    icon: Icons.rocket_launch_outlined,
                    title: loc.helpManualSectionGettingStartedTitle,
                    bullets: [
                      loc.helpManualGettingStarted1,
                      loc.helpManualGettingStarted2,
                      loc.helpManualGettingStarted3,
                    ],
                  ),
                  _buildSection(
                    context,
                    icon: Icons.event_note_outlined,
                    title: loc.helpManualSectionPlanAndCalendarTitle,
                    bullets: [
                      loc.helpManualPlanCalendar1,
                      loc.helpManualPlanCalendar2,
                      loc.helpManualPlanCalendar3,
                    ],
                  ),
                  _buildSection(
                    context,
                    icon: Icons.group_outlined,
                    title: loc.helpManualSectionInvitationsTitle,
                    bullets: [
                      loc.helpManualInvitations1,
                      loc.helpManualInvitations2,
                      loc.helpManualInvitations3,
                    ],
                  ),
                  _buildSection(
                    context,
                    icon: Icons.notifications_active_outlined,
                    title: loc.helpManualSectionNotificationsTitle,
                    bullets: [
                      loc.helpManualNotifications1,
                      loc.helpManualNotifications2,
                      loc.helpManualNotifications3,
                    ],
                  ),
                  _buildSection(
                    context,
                    icon: Icons.lightbulb_outline,
                    title: loc.helpManualSectionTipsTitle,
                    bullets: [
                      loc.helpManualTips1,
                      loc.helpManualTips2,
                      loc.helpManualTips3,
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<String> bullets,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColorScheme.color2),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 6, color: AppColorScheme.color2),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      b,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

