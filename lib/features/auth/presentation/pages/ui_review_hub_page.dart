import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';

/// Hub temporal para navegar a demos UI en revisión.
class UiReviewHubPage extends StatelessWidget {
  const UiReviewHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('UI Review Hub (temporal)'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Accesos rápidos para demos de pantallas en revisión.',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
              leading: const Icon(Icons.login),
              title: const Text('Login v2 (demo)'),
              subtitle: const Text('/demo/login-v2'),
              onTap: () => Navigator.of(context).pushNamed('/demo/login-v2'),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
              leading: const Icon(Icons.list_alt),
              title: const Text('Lista de planes v1 (demo)'),
              subtitle: const Text('/demo/plans-list-v1'),
              onTap: () => Navigator.of(context).pushNamed('/demo/plans-list-v1'),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
              leading: const Icon(Icons.summarize_outlined),
              title: const Text('Resumen del plan v1 (demo)'),
              subtitle: const Text('/demo/plan-summary-v1'),
              onTap: () => Navigator.of(context).pushNamed('/demo/plan-summary-v1'),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
              leading: const Icon(Icons.calendar_view_week_outlined),
              title: const Text('Calendario del plan v1 (demo)'),
              subtitle: const Text('/demo/calendar-v1'),
              onTap: () => Navigator.of(context).pushNamed('/demo/calendar-v1'),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
              leading: const Icon(Icons.edit_calendar_outlined),
              title: const Text('Formulario de evento v1 (demo)'),
              subtitle: const Text('/demo/event-form-v1'),
              onTap: () => Navigator.of(context).pushNamed('/demo/event-form-v1'),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
              leading: const Icon(Icons.hotel_outlined),
              title: const Text('Formulario de alojamiento v1 (demo)'),
              subtitle: const Text('/demo/accommodation-form-v1'),
              onTap: () =>
                  Navigator.of(context).pushNamed('/demo/accommodation-form-v1'),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
              leading: const Icon(Icons.dashboard_customize_outlined),
              title: const Text('UI estandar pagina v1 (demo)'),
              subtitle: const Text('/demo/ui-standard-page-v1'),
              onTap: () =>
                  Navigator.of(context).pushNamed('/demo/ui-standard-page-v1'),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
              leading: const Icon(Icons.fact_check_outlined),
              title: const Text('UI estandar formulario v1 (demo)'),
              subtitle: const Text('/demo/ui-standard-form-v1'),
              onTap: () =>
                  Navigator.of(context).pushNamed('/demo/ui-standard-form-v1'),
            ),
          ],
        ),
      ),
    );
  }
}
