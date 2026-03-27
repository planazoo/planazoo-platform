import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/security/utils/sanitizer.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/constants/help_context_ids.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/widgets/help/help_icon_button.dart';

/// Modal para crear un plan con nombre y UNP ID.
/// Al crear, llama a [onPlanCreated] con el plan creado.
class WdCreatePlanModal extends ConsumerStatefulWidget {
  final void Function(Plan) onPlanCreated;

  const WdCreatePlanModal({
    super.key,
    required this.onPlanCreated,
  });

  @override
  ConsumerState<WdCreatePlanModal> createState() => _WdCreatePlanModalState();
}

class _WdCreatePlanModalState extends ConsumerState<WdCreatePlanModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unpIdController = TextEditingController();
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _generateAutoUnpId();
  }

  Future<void> _generateAutoUnpId() async {
    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        final planService = ref.read(planServiceProvider);
        final generatedId = await planService.generateUniqueUnpId(
          currentUser.id,
          username: currentUser.username,
        );
        if (mounted) {
          setState(() {
            _unpIdController.text = generatedId;
          });
        }
      }
    } catch (e) {
      LoggerService.error(
        'Error generating auto UNP ID',
        context: 'CREATE_PLAN_MODAL',
        error: e,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unpIdController.dispose();
    super.dispose();
  }

  Future<void> _createPlan() async {
    final formState = _formKey.currentState;
    if (formState == null) return;
    if (!formState.validate()) return;

    final currentUser = ref.read(currentUserProvider);
    final loc = AppLocalizations.of(context)!;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.createPlanAuthError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final now = DateTime.now();
      final sanitizedName = Sanitizer.sanitizePlainText(
        _nameController.text,
        maxLength: 100,
      );
      final sanitizedUnpId = Sanitizer.sanitizePlainText(
        _unpIdController.text,
        maxLength: 40,
      );
      final startDate = DateTime(now.year, now.month, now.day);
      final endDate = startDate.add(const Duration(days: 6));
      final columnCount = Plan.calendarDaysInclusive(startDate, endDate);

      final plan = Plan(
        name: sanitizedName,
        unpId: sanitizedUnpId,
        userId: currentUser.id,
        baseDate: startDate,
        startDate: startDate,
        endDate: endDate,
        columnCount: columnCount,
        description: null,
        state: 'planificando',
        visibility: 'private',
        timezone: TimezoneService.getSystemTimezone(),
        currency: 'EUR',
        participants: 0,
        createdAt: now,
        updatedAt: now,
        savedAt: now,
      );

      final planService = ref.read(planServiceProvider);
      final planId = await planService.createPlan(plan);

      if (planId == null) throw Exception('plan-create-error');

      final createdPlan = await planService.getPlanById(planId);

      if (!mounted) return;

      Navigator.of(context).pop();
      if (createdPlan != null) {
        widget.onPlanCreated(createdPlan);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.createPlanGenericError),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(loc.createPlan)),
          HelpIconButton(
            helpId: HelpContextIds.createPlanGeneral,
            contextLabel: loc.createPlan,
            defaultBody: 'Crea un nuevo plan con un nombre. Las fechas y el resto de la configuración se pueden completar después en la pantalla Info del plan. Solo necesitas un nombre para continuar.',
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: loc.createPlanNameLabel,
                  hintText: loc.createPlanNameHint,
                  prefixIcon: const Icon(Icons.edit),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return loc.createPlanNameRequiredError;
                  }
                  if (value.trim().length < 3) {
                    return loc.createPlanNameTooShortError;
                  }
                  if (value.trim().length > 100) {
                    return loc.createPlanNameTooLongError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                loc.createPlanQuickIntro,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                loc.createPlanDatesOptionalHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          child: Text(loc.cancel),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createPlan,
          child: _isCreating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(loc.createPlanContinueButton),
        ),
      ],
    );
  }
}
