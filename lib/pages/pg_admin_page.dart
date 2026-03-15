import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/pages/pg_ui_showcase_page.dart';
import 'package:unp_calendario/shared/providers/help_text_providers.dart';

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
        ],
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ayuda actualizada: $count textos')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar ayuda: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
