import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/pending_email_event.dart';
import 'package:unp_calendario/features/calendar/domain/services/pending_email_event_service.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/screens/wd_pending_event_card.dart';

/// Buzón de eventos pendientes (desde correo reenviado). Lista, asignar a plan y descartar.
class WdPendingEmailEventsScreen extends ConsumerWidget {
  const WdPendingEmailEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final authService = ref.watch(authServiceProvider);
    final authUid = authService.currentUser?.uid;
    if (user == null || authUid == null) {
      return const Center(child: CircularProgressIndicator());
    }
    // Las reglas de Firestore exigen request.auth.uid == userId; usamos el UID de Auth para la ruta
    final service = PendingEmailEventService();
    return StreamBuilder<List<PendingEmailEvent>>(
      stream: service.streamPendingEvents(authUid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SelectableText(
                  'ID usuario (Auth UID): $authUid',
                  style: AppTypography.caption.copyWith(
                    color: AppColorScheme.color4.withOpacity(0.7),
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Error al cargar: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyStyle.copyWith(color: Colors.red.shade700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Comprueba que el documento tenga el campo createdAt (timestamp). Sin él la consulta no devuelve el documento.',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: AppColorScheme.color4,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data ?? [];
        final pending = list.where((e) => e.status == 'pending').toList();
        final loc = AppLocalizations.of(context)!;

        final debugInfo = 'Documentos en users/$authUid/pending_email_events: ${list.length}. Con status "pending": ${pending.length}.';

        final userIdBar = Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: SelectableText(
            'ID usuario (Auth UID): $authUid',
            style: AppTypography.caption.copyWith(
              color: AppColorScheme.color4.withOpacity(0.7),
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        );

        if (pending.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              userIdBar,
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          loc.pendingEventsEmpty,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyStyle.copyWith(color: AppColorScheme.color4),
                        ),
                        const SizedBox(height: 16),
                        SelectableText(
                          'Firestore: users / $authUid / pending_email_events · status = "pending"',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: AppColorScheme.color4.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SelectableText(
                          debugInfo,
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: AppColorScheme.color4.withOpacity(0.8),
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Si "Documentos...: 0": la ruta no tiene docs o falta createdAt. Si "Con status pending: 0" pero hay documentos: el campo status no es exactamente "pending".',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: AppColorScheme.color4.withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            userIdBar,
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: pending.length,
                itemBuilder: (context, index) {
                  final item = pending[index];
                  return WdPendingEventCard(
                    pending: item,
                    userId: authUid,
                    onAssign: () => PendingEmailEventActions.showAssignDialog(context, ref, item, authUid),
                    onDiscard: () => PendingEmailEventActions.discard(context, ref, item, authUid),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

}
