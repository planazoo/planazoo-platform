import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/services/event_service.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/models/permission.dart';
import 'package:unp_calendario/shared/models/plan_permissions.dart';
import 'package:unp_calendario/shared/services/permission_service.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';

/// Diálogo para editar información personal de otros participantes (admin).
class EditPersonalInfoDialog extends ConsumerStatefulWidget {
  const EditPersonalInfoDialog({
    super.key,
    required this.event,
    required this.participantId,
    required this.participantName,
    required this.planId,
    this.onSaved,
  });

  final Event event;
  final String participantId;
  final String participantName;
  final String planId;
  final void Function(Event)? onSaved;

  @override
  ConsumerState<EditPersonalInfoDialog> createState() =>
      _EditPersonalInfoDialogState();
}

class _EditPersonalInfoDialogState
    extends ConsumerState<EditPersonalInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _asientoController;
  late TextEditingController _menuController;
  late TextEditingController _preferenciasController;
  late TextEditingController _numeroReservaController;
  late TextEditingController _gateController;
  late TextEditingController _notasPersonalesController;
  late TextEditingController _ticketCodeController;
  late TextEditingController _ticketDocUrlController;
  late bool _tarjetaObtenida;

  PlanPermissions? _userPermissions;
  bool _isLoading = true;
  bool _hasPermission = false;
  bool _isSaving = false;

  bool get _isActivity => widget.event.commonPart?.family == 'Actividad';

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _checkPermissions();
  }

  void _initializeFields() {
    final personalPart = widget.event.personalParts?[widget.participantId];
    final personalFields = personalPart?.fields ?? {};

    _asientoController =
        TextEditingController(text: personalFields['asiento']?.toString() ?? '');
    _menuController =
        TextEditingController(text: personalFields['menu']?.toString() ?? '');
    _preferenciasController = TextEditingController(
      text: personalFields['preferencias']?.toString() ?? '',
    );
    _numeroReservaController = TextEditingController(
      text: personalFields['numeroReserva']?.toString() ?? '',
    );
    _gateController =
        TextEditingController(text: personalFields['gate']?.toString() ?? '');
    _notasPersonalesController = TextEditingController(
      text: personalFields['notasPersonales']?.toString() ?? '',
    );
    _ticketCodeController = TextEditingController(
      text: personalFields['ticketCode']?.toString() ?? '',
    );
    _ticketDocUrlController = TextEditingController(
      text: personalFields['ticketDocUrl']?.toString() ?? '',
    );
    _tarjetaObtenida = personalFields['tarjetaObtenida'] == true;
  }

  Future<void> _checkPermissions() async {
    final currentUserId = ref.read(currentUserProvider)?.id;
    if (currentUserId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasPermission = false;
        });
      }
      return;
    }

    final permissionService = PermissionService();
    _userPermissions = await permissionService.getUserPermissions(
      widget.planId,
      currentUserId,
    );

    _hasPermission =
        _userPermissions?.hasPermission(Permission.eventEditOthersPersonal) ??
            false;

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _asientoController.dispose();
    _menuController.dispose();
    _preferenciasController.dispose();
    _numeroReservaController.dispose();
    _gateController.dispose();
    _notasPersonalesController.dispose();
    _ticketCodeController.dispose();
    _ticketDocUrlController.dispose();
    super.dispose();
  }

  String? _maxLenValidator(String? value, int max, AppLocalizations loc) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (v.length > max) return loc.maxCharacters(max);
    return null;
  }

  Future<void> _savePersonalInfo() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final loc = AppLocalizations.of(context)!;

    try {
      final personalFields = {
        'asiento': _asientoController.text.trim(),
        'menu': _menuController.text.trim(),
        'preferencias': _preferenciasController.text.trim(),
        'numeroReserva': _numeroReservaController.text.trim(),
        'gate': _gateController.text.trim(),
        'notasPersonales': _notasPersonalesController.text.trim(),
        'ticketCode': _ticketCodeController.text.trim(),
        'ticketDocUrl': _ticketDocUrlController.text.trim(),
        'tarjetaObtenida': _tarjetaObtenida,
      };

      final updatedPersonalPart = EventPersonalPart(
        participantId: widget.participantId,
        fields: personalFields,
      );

      final updatedPersonalParts =
          Map<String, EventPersonalPart>.from(widget.event.personalParts ?? {});
      updatedPersonalParts[widget.participantId] = updatedPersonalPart;

      final updatedEvent =
          widget.event.copyWith(personalParts: updatedPersonalParts);

      await EventService().updateEvent(updatedEvent);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.personalInfoUpdated(widget.participantName)),
          backgroundColor: Colors.green,
        ),
      );
      widget.onSaved?.call(updatedEvent);
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.personalInfoSaveError('$e')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: IosFormColors.pageBg,
        body: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: IosFormColors.pageBg,
        body: SafeArea(
          child: Column(
            children: [
              IosFormEditBar(
                editing: true,
                canEdit: false,
                title: loc.noPermissionTitle,
                editLabel: loc.edit,
                cancelLabel: loc.close,
                saveLabel: loc.save,
                onEdit: () {},
                onCancel: () => Navigator.of(context).pop(),
                onSave: () {},
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    loc.noPermissionEditPersonalInfoOthers,
                    style: const TextStyle(
                      color: IosFormColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final cardChildren = <Widget>[
      IosEditField(
        label: loc.seat,
        controller: _asientoController,
        hint: loc.seatHint,
        validator: (v) => _maxLenValidator(v, 50, loc),
      ),
    ];

    if (_isActivity) {
      cardChildren.addAll([
        const IosRowSeparator(),
        IosEditField(
          label: loc.eventMyInfoEntryCodeLabel,
          controller: _ticketCodeController,
          hint: loc.eventMyInfoEntryCodeHint,
          validator: (v) => _maxLenValidator(v, 50, loc),
        ),
        const IosRowSeparator(),
        IosEditField(
          label: loc.eventMyInfoTicketUrlLabel,
          controller: _ticketDocUrlController,
          hint: loc.eventMyInfoTicketUrlHint,
          keyboardType: TextInputType.url,
          validator: (v) => _maxLenValidator(v, 500, loc),
        ),
      ]);
    } else {
      cardChildren.addAll([
        const IosRowSeparator(),
        IosEditField(
          label: loc.menu,
          controller: _menuController,
          hint: loc.menuHint,
          validator: (v) => _maxLenValidator(v, 100, loc),
        ),
        const IosRowSeparator(),
        IosEditField(
          label: loc.preferences,
          controller: _preferenciasController,
          hint: loc.preferencesHint,
          maxLines: 2,
          minLines: 1,
          validator: (v) => _maxLenValidator(v, 200, loc),
        ),
        const IosRowSeparator(),
        IosEditField(
          label: loc.reservationNumber,
          controller: _numeroReservaController,
          hint: loc.reservationNumberHint,
          validator: (v) => _maxLenValidator(v, 50, loc),
        ),
        const IosRowSeparator(),
        IosEditField(
          label: loc.gate,
          controller: _gateController,
          hint: loc.gateHint,
          validator: (v) => _maxLenValidator(v, 50, loc),
        ),
      ]);
    }

    cardChildren.addAll([
      const IosRowSeparator(),
      IosSwitchRow(
        label: loc.cardObtained,
        value: _tarjetaObtenida,
        onChanged: (v) => setState(() => _tarjetaObtenida = v),
      ),
      const IosRowSeparator(),
      IosEditField(
        label: loc.personalNotes,
        controller: _notasPersonalesController,
        hint: loc.eventMyInfoPersonalNotesHint,
        maxLines: 4,
        minLines: 2,
        validator: (v) => _maxLenValidator(v, 1000, loc),
      ),
    ]);

    return Scaffold(
      backgroundColor: IosFormColors.pageBg,
      body: SafeArea(
        child: Material(
          color: IosFormColors.pageBg,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                IosFormEditBar(
                  editing: true,
                  canEdit: true,
                  saving: _isSaving,
                  centeredTitle: true,
                  modalIconActions: true,
                  title: loc.editPersonalInfoTitle(widget.participantName),
                  editLabel: loc.edit,
                  cancelLabel: loc.cancel,
                  saveLabel: loc.save,
                  onEdit: () {},
                  onCancel: () => Navigator.of(context).pop(),
                  onSave: _savePersonalInfo,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    child: IosGroupedCard(children: cardChildren),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
