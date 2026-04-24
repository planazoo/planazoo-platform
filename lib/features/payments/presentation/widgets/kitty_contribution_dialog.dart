import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import '../../domain/models/kitty_contribution.dart';
import '../providers/payment_providers.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

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
  Map<String, String> _resolvedNames = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser?.id != null && currentUser?.id != widget.plan.userId) {
        setState(() => _selectedParticipantId = currentUser!.id);
      }
      _resolveParticipantNames();
    });
  }

  Future<void> _resolveParticipantNames() async {
    final participationsAsync = ref.read(planParticipantsProvider(widget.plan.id!));
    participationsAsync.whenData((list) async {
      final userIds = list.where((p) => p.role != 'observer').map((p) => p.userId).toSet();
      final userService = ref.read(userServiceProvider);
      final map = <String, String>{};
      for (final uid in userIds) {
        try {
          final user = await userService.getUser(uid);
          final name = (user?.displayName?.trim().isNotEmpty == true
                  ? user!.displayName
                  : user?.email) ??
              uid;
          map[uid] = name;
        } catch (_) {
          map[uid] = uid;
        }
      }
      if (mounted) setState(() => _resolvedNames = map);
    });
  }

  String _userName(String userId) => _resolvedNames[userId] ?? userId;

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
    final loc = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.snackInvalidMonetaryAmount)),
      );
      return;
    }
    final currentUser = ref.read(currentUserProvider);
    if (currentUser?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.snackUserNotAuthenticated)),
      );
      return;
    }
    final isOrganizer = currentUser!.id == widget.plan.userId;
    final participantId = isOrganizer ? _selectedParticipantId : currentUser.id;
    if (participantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.snackSelectParticipant)),
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
    final loc = AppLocalizations.of(context)!;
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
      title: Text(loc.kittyAddContributionTitle, style: AppTypography.titleStyle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${loc.participant} *', style: AppTypography.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (!isOrganizer)
                  InputDecorator(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    child: Text(loc.kittyYourOwnContribution, style: AppTypography.bodyStyle),
                  )
                else
                  participationsAsync.when(
                    data: (list) {
                      final real = list.where((p) => p.role != 'observer').toList();
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedParticipantId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        hint: Text(loc.kittySelectParticipantHint),
                        items: real
                            .map((p) => DropdownMenuItem<String>(
                                  value: p.userId,
                                  child: Text(
                                    _userName(p.userId),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedParticipantId = v),
                        validator: (v) => v == null ? loc.kittyValidationSelectParticipant : null,
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text(loc.kittyLoadParticipantsError(e.toString())),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: loc.kittyAmountLabel,
                    prefixIcon: const Icon(Icons.money),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return loc.kittyValidationEnterAmount;
                    final n = double.tryParse(v.replaceAll(',', '.'));
                    if (n == null || n <= 0) return loc.snackInvalidMonetaryAmount;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _conceptController,
                  decoration: InputDecoration(
                    labelText: loc.kittyConceptOptionalLabel,
                    prefixIcon: const Icon(Icons.description),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: loc.kittyDateLabel,
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
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
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(loc.cancel)),
        FilledButton(onPressed: _save, child: Text(loc.save)),
      ],
    );
  }
}
