import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import '../../domain/models/kitty_contribution.dart';
import '../providers/payment_providers.dart';
import 'package:unp_calendario/app/theme/typography.dart';

/// T219: Diálogo para registrar un aporte al bote común
class KittyContributionDialog extends ConsumerStatefulWidget {
  final Plan plan;
  final VoidCallback? onSaved;

  const KittyContributionDialog({
    super.key,
    required this.plan,
    this.onSaved,
  });

  @override
  ConsumerState<KittyContributionDialog> createState() => _KittyContributionDialogState();
}

class _KittyContributionDialogState extends ConsumerState<KittyContributionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _conceptController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedParticipantId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser?.id != null && currentUser?.id != widget.plan.userId) {
        setState(() => _selectedParticipantId = currentUser!.id);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _conceptController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monto inválido')),
      );
      return;
    }
    final currentUser = ref.read(currentUserProvider);
    if (currentUser?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no autenticado')),
      );
      return;
    }
    final isOrganizer = currentUser!.id == widget.plan.userId;
    final participantId = isOrganizer ? _selectedParticipantId : currentUser.id;
    if (participantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un participante')),
      );
      return;
    }
    final contribution = KittyContribution(
      planId: widget.plan.id!,
      participantId: participantId,
      amount: amount,
      contributionDate: _selectedDate,
      concept: _conceptController.text.isEmpty ? null : _conceptController.text,
      registeredBy: currentUser.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final kittyService = ref.read(kittyServiceProvider);
    final id = await kittyService.createContribution(contribution);
    if (!mounted) return;
    if (id != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aportación registrada'), backgroundColor: Colors.green),
      );
      widget.onSaved?.call();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isOrganizer = currentUser?.id == widget.plan.userId;
    final participationsAsync = ref.watch(planParticipantsProvider(widget.plan.id!));

    if (!isOrganizer && currentUser?.id != null && _selectedParticipantId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedParticipantId == null) {
          setState(() => _selectedParticipantId = currentUser!.id);
        }
      });
    }

    return AlertDialog(
      title: Text('Añadir aportación al bote', style: AppTypography.titleStyle),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Participante *', style: AppTypography.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (!isOrganizer)
                  InputDecorator(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    child: Text('Tú (mi aportación)', style: AppTypography.bodyStyle),
                  )
                else
                  participationsAsync.when(
                    data: (list) {
                      final real = list.where((p) => p.role != 'observer').toList();
                      return DropdownButtonFormField<String>(
                        value: _selectedParticipantId,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        hint: const Text('Selecciona participante'),
                        items: real.map((p) => DropdownMenuItem(value: p.userId, child: Text(p.userId))).toList(),
                        onChanged: (v) => setState(() => _selectedParticipantId = v),
                        validator: (v) => v == null ? 'Selecciona un participante' : null,
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Monto *',
                    prefixIcon: Icon(Icons.money),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa un monto';
                    final n = double.tryParse(v.replaceAll(',', '.'));
                    if (n == null || n <= 0) return 'Monto inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _conceptController,
                  decoration: const InputDecoration(
                    labelText: 'Concepto (opcional)',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha *',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: AppTypography.bodyStyle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        FilledButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }
}
