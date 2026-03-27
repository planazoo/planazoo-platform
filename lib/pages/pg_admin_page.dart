import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/pages/pg_ui_showcase_page.dart';
import 'package:unp_calendario/shared/providers/help_text_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_participation_service.dart';

/// Página de administración: solo accesible para usuarios admin (icono en W1).
/// Contiene: Actualizar ayuda (sync seed → Firestore), UI Showcase.
class AdminPage extends ConsumerWidget {
  const AdminPage({
    super.key,
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColorScheme.color0,
      appBar: AppBar(
        backgroundColor: AppColorScheme.color2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onClose,
        ),
        title: Text(
          'Administración',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _SectionTitle(title: 'Actualizar ayuda'),
          const SizedBox(height: 8),
          const _UpdateHelpSection(),
          const SizedBox(height: 32),
          _SectionTitle(title: 'UI Showcase'),
          const SizedBox(height: 8),
          _UIShowcaseSection(),
          const SizedBox(height: 32),
          _SectionTitle(title: 'Integridad de datos'),
          const SizedBox(height: 8),
          const _OrphanParticipationsSection(),
        ],
      ),
    );
  }
}

class _OrphanParticipationsSection extends StatefulWidget {
  const _OrphanParticipationsSection();

  @override
  State<_OrphanParticipationsSection> createState() => _OrphanParticipationsSectionState();
}

class _OrphanParticipationsSectionState extends State<_OrphanParticipationsSection> {
  bool _loading = false;
  String? _lastResult;

  Future<void> _runAudit(AppLocalizations loc) async {
    setState(() {
      _loading = true;
      _lastResult = null;
    });
    try {
      final svc = PlanParticipationService();
      final r = await svc.auditParticipations(deleteOrphans: false);
      if (mounted) {
        setState(() {
          _lastResult = loc.adminOrphanScanResult(r.totalRecords, r.orphanCount);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastResult = e.toString();
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.adminOrphanScanTitle,
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColorScheme.titleColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Busca documentos en la colección de participaciones cuyo planId ya no existe en Firestore. No borra nada; solo informa.',
              style: GoogleFonts.poppins(fontSize: 14, color: AppColorScheme.bodyColor),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loading ? null : () => _runAudit(loc),
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.search, size: 20),
              label: Text(loc.adminOrphanScanButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorScheme.color2,
                foregroundColor: Colors.white,
              ),
            ),
            if (_lastResult != null) ...[
              const SizedBox(height: 12),
              SelectableText(
                _lastResult!,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColorScheme.bodyColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColorScheme.titleColor,
      ),
    );
  }
}

class _UpdateHelpSection extends ConsumerWidget {
  const _UpdateHelpSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sube los textos de ayuda del seed (assets/help_texts_seed.json) a Firestore. Solo usuarios admin pueden escribir.',
              style: GoogleFonts.poppins(fontSize: 14, color: AppColorScheme.bodyColor),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _syncHelpTexts(context, ref),
              icon: const Icon(Icons.sync, size: 20),
              label: const Text('Actualizar ayuda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorScheme.color3,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UIShowcaseSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Abre la página de demostración del estilo de la app (oscuro y claro).',
              style: GoogleFonts.poppins(fontSize: 14, color: AppColorScheme.bodyColor),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UIShowcasePage(),
                  ),
                );
              },
              icon: const Icon(Icons.palette, size: 20),
              label: const Text('Abrir UI Showcase'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorScheme.color2,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _syncHelpTexts(BuildContext context, WidgetRef ref) async {
  try {
    final json = await rootBundle.loadString('assets/help_texts_seed.json');
    final seed = jsonDecode(json) as Map<String, dynamic>;
    final service = ref.read(helpTextServiceProvider);
    final count = await service.syncHelpTextsToFirestore(seed);
    if (context.mounted) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.snackHelpUpdatedCount(count))),
      );
    }
  } catch (e) {
    if (context.mounted) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.snackHelpSyncFailedDetail(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
