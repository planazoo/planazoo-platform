import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/language/presentation/providers/language_providers.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(currentLanguageSyncProvider);
    final languageNotifier = ref.watch(languageNotifierProvider);

    return PopupMenuButton<Locale>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.language,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            _getLanguageFlag(currentLanguage),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      onSelected: (Locale locale) async {
        await languageNotifier.changeLanguage(locale);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<Locale>(
          value: const Locale('es', ''),
          child: Row(
            children: [
              Text('🇪🇸', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              const Text('Español'),
              if (currentLanguage.languageCode == 'es') ...[
                const Spacer(),
                Icon(Icons.check, color: Colors.green, size: 20),
              ],
            ],
          ),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('en', ''),
          child: Row(
            children: [
              Text('🇺🇸', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              const Text('English'),
              if (currentLanguage.languageCode == 'en') ...[
                const Spacer(),
                Icon(Icons.check, color: Colors.green, size: 20),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _getLanguageFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'es':
        return '🇪🇸';
      case 'en':
        return '🇺🇸';
      default:
        return '🇪🇸';
    }
  }
}
