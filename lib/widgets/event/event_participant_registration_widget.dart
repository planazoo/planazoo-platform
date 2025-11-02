import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/event_participant.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/event_participant_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/auth/domain/services/user_service.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';

/// Widget para mostrar el botón de apuntarse/cancelar y la lista de participantes
class EventParticipantRegistrationWidget extends ConsumerWidget {
  final Event event;
  final String planId;

  const EventParticipantRegistrationWidget({
    super.key,
    required this.event,
    required this.planId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null || event.id == null) {
      return const SizedBox.shrink();
    }

    final eventId = event.id!;
    final participantsAsync = ref.watch(eventParticipantsProvider(eventId));
    final participantsCountAsync = ref.watch(eventParticipantsCountProvider(eventId));
    final isRegisteredAsync = ref.watch(
      isUserRegisteredProvider((eventId: eventId, userId: currentUser.id)),
    );

    return participantsAsync.when(
      data: (participants) {
        return participantsCountAsync.when(
          data: (count) {
            return isRegisteredAsync.when(
              data: (isRegistered) {
                return _buildContent(
                  context: context,
                  ref: ref,
                  participants: participants,
                  count: count,
                  isRegistered: isRegistered,
                  currentUserId: currentUser.id,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required WidgetRef ref,
    required List<EventParticipant> participants,
    required int count,
    required bool isRegistered,
    required String currentUserId,
  }) {
    final maxParticipants = event.maxParticipants;
    final isFull = maxParticipants != null && count >= maxParticipants;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Botón de apuntarse/cancelar
        if (!isRegistered && !isFull)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _registerParticipant(context, ref),
              icon: const Icon(Icons.person_add, size: 20),
              label: const Text('Apuntarse al evento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorScheme.color3,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          )
        else if (isRegistered)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _cancelRegistration(context, ref),
              icon: const Icon(Icons.person_remove, size: 20),
              label: const Text('Cancelar participación'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          )
        else if (isFull)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.person_off, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Evento completo ($count/$maxParticipants)',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Contador de participantes
        Row(
          children: [
            Icon(Icons.people, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              '$count ${count == 1 ? 'persona apuntada' : 'personas apuntadas'}',
              style: AppTypography.bodyStyle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (maxParticipants != null)
              Text(
                ' / $maxParticipants',
                style: AppTypography.bodyStyle.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Lista de participantes
        if (participants.isNotEmpty)
          _buildParticipantsList(context, ref, participants)
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Nadie se ha apuntado todavía',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildParticipantsList(
    BuildContext context,
    WidgetRef ref,
    List<EventParticipant> participants,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: participants.asMap().entries.map((entry) {
          final index = entry.key;
          final participant = entry.value;
          final isLast = index == participants.length - 1;

          return FutureBuilder<String>(
            future: _getUserDisplayName(participant.userId, ref),
            builder: (context, snapshot) {
              final displayName = snapshot.data ?? participant.userId.substring(0, 8);
              return Container(
                decoration: BoxDecoration(
                  border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColorScheme.color3.withOpacity(0.2),
                      child: Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: AppColorScheme.color3,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        displayName,
                        style: AppTypography.bodyStyle,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Future<String> _getUserDisplayName(String userId, WidgetRef ref) async {
    try {
      final userService = ref.read(userServiceProvider);
      final user = await userService.getUser(userId);
      return user?.displayIdentifier ?? userId.substring(0, 8);
    } catch (e) {
      LoggerService.error(
        'Error getting user display name: $userId',
        context: 'EVENT_PARTICIPANT_REGISTRATION_WIDGET',
        error: e,
      );
      return userId.substring(0, 8);
    }
  }

  Future<void> _registerParticipant(BuildContext context, WidgetRef ref) async {
    if (event.id == null) return;

    final eventParticipantService = ref.read(eventParticipantServiceProvider);
    final success = await eventParticipantService.registerParticipant(
      eventId: event.id!,
      userId: ref.read(currentUserProvider)!.id,
      planId: planId,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Te has apuntado al evento'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Error al apuntarse al evento'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelRegistration(BuildContext context, WidgetRef ref) async {
    if (event.id == null) return;

    final eventParticipantService = ref.read(eventParticipantServiceProvider);
    final success = await eventParticipantService.cancelRegistration(
      eventId: event.id!,
      userId: ref.read(currentUserProvider)!.id,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Has cancelado tu participación'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Error al cancelar participación'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

