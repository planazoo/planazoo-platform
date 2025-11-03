import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/widgets/plan/wd_participants_list_widget.dart';
import 'package:unp_calendario/widgets/dialogs/invite_group_dialog.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text('Participantes - ${widget.plan.name}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showInviteGroupDialog,
            icon: const Icon(Icons.group_add),
            tooltip: 'Invitar grupo',
          ),
          IconButton(
            onPressed: _showInviteDialog,
            icon: const Icon(Icons.person_add),
            tooltip: 'Invitar usuario',
          ),
        ],
      ),
      body: Column(
        children: [
          // Estadísticas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Total',
                  participantCount.toString(),
                  Icons.people,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Organizadores',
                  organizerCount.toString(),
                  Icons.admin_panel_settings,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Participantes',
                  (participantCount - organizerCount).toString(),
                  Icons.person,
                  Colors.green,
                ),
              ],
            ),
          ),
          
          // Lista de participantes
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ParticipantsListWidget(
                planId: widget.plan.id!,
                showActions: currentUser?.id == widget.plan.userId, // Solo el creador puede gestionar
              ),
            ),
          ),
        ],
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
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invitar usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa el email del usuario que quieres invitar:'),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'usuario@ejemplo.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _emailController.clear();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _inviteUser,
            child: const Text('Invitar'),
          ),
        ],
      ),
    );
  }

  void _showInviteGroupDialog() {
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
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un email')),
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[A-Za-z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email inválido')),
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
          const SnackBar(content: Text('Invitación enviada'), backgroundColor: Colors.green),
        );
      } else {
        // El error ya está manejado por el notifier, pero mostramos un mensaje genérico si no hay detalle
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al enviar invitación. Verifica que no hayas alcanzado el límite de invitaciones diarias (50/día).'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
