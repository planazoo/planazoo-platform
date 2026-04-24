import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/widgets/plan/wd_participants_list_widget.dart';
import 'package:unp_calendario/widgets/dialogs/invite_group_dialog.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_state_permissions.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/invitation_providers.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';

class PlanParticipantsPage extends ConsumerStatefulWidget {
  final Plan plan;

  const PlanParticipantsPage({
    super.key,
    required this.plan,
  });

  @override
  ConsumerState<PlanParticipantsPage> createState() => _PlanParticipantsPageState();
}

class _PlanParticipantsPageState extends ConsumerState<PlanParticipantsPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar participantes al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(planParticipationNotifierProvider(widget.plan.id!).notifier)
          .loadPlanParticipants(widget.plan.id!);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final participantsAsync = ref.watch(planParticipantsProvider(widget.plan.id!));
    final pendingInvitationsAsync = ref.watch(pendingInvitationsProvider(widget.plan.id!));
    
    final participantCount = participantsAsync.when(
      data: (participants) => participants.where((p) => p.role == 'participant' && p.isActive).length,
      loading: () => 0,
      error: (_, __) => 0,
    );
    
    final organizerCount = participantsAsync.when(
      data: (participants) => participants.where((p) => p.role == 'organizer' && p.isActive).length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.participants),
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        actions: [
          // T109: Deshabilitar botones según estado del plan
          IconButton(
            onPressed: PlanStatePermissions.canAddParticipants(widget.plan) 
                ? _showInviteGroupDialog 
                : null,
            icon: const Icon(Icons.group_add),
            tooltip: PlanStatePermissions.canAddParticipants(widget.plan) 
                ? 'Invitar grupo' 
                : PlanStatePermissions.getBlockedReason('add_participants', widget.plan) ?? 'No disponible',
          ),
          IconButton(
            onPressed: PlanStatePermissions.canAddParticipants(widget.plan) 
                ? _showInviteDialog 
                : null,
            icon: const Icon(Icons.person_add),
            tooltip: PlanStatePermissions.canAddParticipants(widget.plan) 
                ? 'Invitar usuario' 
                : PlanStatePermissions.getBlockedReason('add_participants', widget.plan) ?? 'No disponible',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Estadísticas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF1F2937),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(
                    'Total',
                    participantCount.toString(),
                    Icons.people,
                    AppColorScheme.color2,
                  ),
                  _buildStatCard(
                    loc.planRoleOrganizer,
                    organizerCount.toString(),
                    Icons.admin_panel_settings,
                    Colors.orange.shade300,
                  ),
                  _buildStatCard(
                    loc.participants,
                    (participantCount - organizerCount).toString(),
                    Icons.person,
                    Colors.green.shade300,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                loc.participantsRegistered,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ParticipantsListWidget(
                planId: widget.plan.id!,
                showActions: currentUser?.id == widget.plan.userId, // Solo el creador puede gestionar
                compact: true,
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                loc.invitationsSectionTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            pendingInvitationsAsync.when(
              data: (invites) {
                if (invites.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: Text(loc.notificationsEmpty,
                        style: const TextStyle(color: Colors.grey)),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: invites.length,
                    itemBuilder: (context, index) {
                      final invite = invites[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: const Color(0xFF1F2937),
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.mail_outline, color: AppColorScheme.color2),
                          title: Text(
                            invite.email,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${loc.statusShortPending} · ${invite.expiresAt.day}/${invite.expiresAt.month}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Text(
                  loc.errorLoadingParticipants(err.toString()),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  void _showInviteDialog() {
    final loc = AppLocalizations.of(context)!;
    // T109: Verificar si se puede añadir participantes según el estado del plan
    if (!PlanStatePermissions.canAddParticipants(widget.plan)) {
      final blockedReason = PlanStatePermissions.getBlockedReason('add_participants', widget.plan);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(blockedReason ?? loc.snackCannotAddParticipantsCurrentState),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        final dloc = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(dloc.inviteUserDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(dloc.inviteUserDialogDescription),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: dloc.emailLabel,
                  hintText: dloc.emailHint,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _emailController.clear();
              },
              child: Text(dloc.cancel),
            ),
            ElevatedButton(
              onPressed: _inviteUser,
              child: Text(dloc.inviteUserInvite),
            ),
          ],
        );
      },
    );
  }

  void _showInviteGroupDialog() {
    final loc = AppLocalizations.of(context)!;
    // T109: Verificar si se puede añadir participantes según el estado del plan
    if (!PlanStatePermissions.canAddParticipants(widget.plan)) {
      final blockedReason = PlanStatePermissions.getBlockedReason('add_participants', widget.plan);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(blockedReason ?? loc.snackCannotAddParticipantsCurrentState),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    showDialog(
      context: context,
      builder: (context) => InviteGroupDialog(
        planId: widget.plan.id!,
        userId: currentUser.id,
      ),
    );
  }

  void _inviteUser() async {
    final loc = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.snackPleaseEnterEmail)),
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[A-Za-z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.snackInvalidEmailShort)),
      );
      return;
    }

    // Invitar por email usando InvitationService (T104)
    // El servicio detecta si es email y busca usuario o crea invitación con token
    final notifier = ref.read(planParticipationNotifierProvider(widget.plan.id!).notifier);
    final currentUser = ref.read(currentUserProvider);
    
    final success = await notifier.inviteUserToPlan(
      widget.plan.id!,
      email, // Puede ser email o userId - el servicio lo detecta
      invitedBy: currentUser?.id,
    );

    if (mounted) {
      Navigator.of(context).pop();
      _emailController.clear();
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.snackInvitationSentSuccess), backgroundColor: Colors.green),
        );
      } else {
        // El error ya está manejado por el notifier, pero mostramos un mensaje genérico si no hay detalle
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.snackInviteDailyLimitReached),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
