import 'package:flutter/material.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/features/calendar/domain/models/communication_attachment.dart';
import 'package:unp_calendario/features/calendar/domain/models/entity_communication.dart';
import 'package:unp_calendario/features/calendar/domain/models/pending_email_event.dart';
import 'package:unp_calendario/features/calendar/domain/services/communication_file_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/entity_communication_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/pending_email_event_service.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';

/// Formulario para pegar una nota (WhatsApp, etc.) y opcionalmente adjuntar fotos/PDF.
class ComposeCommunicationSheet extends StatefulWidget {
  final String userId;
  /// Si se indica, la nota se coloca ya en ese evento/alojamiento.
  final String? entityId;
  final EntityCommunication? editingPlaced;
  final PendingEmailEvent? editingPending;

  const ComposeCommunicationSheet({
    super.key,
    required this.userId,
    this.entityId,
    this.editingPlaced,
    this.editingPending,
  });

  bool get isEditing => editingPlaced != null || editingPending != null;

  static Future<bool> show(
    BuildContext context, {
    required String userId,
    String? entityId,
    EntityCommunication? editingPlaced,
    PendingEmailEvent? editingPending,
  }) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: IosFormColors.groupedBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => ComposeCommunicationSheet(
        userId: userId,
        entityId: entityId,
        editingPlaced: editingPlaced,
        editingPending: editingPending,
      ),
    );
    return saved == true;
  }

  @override
  State<ComposeCommunicationSheet> createState() => _ComposeCommunicationSheetState();
}

class _ComposeCommunicationSheetState extends State<ComposeCommunicationSheet> {
  final _subject = TextEditingController();
  final _body = TextEditingController();
  final _files = <PickedPlanFile>[];
  var _kept = <CommunicationAttachment>[];
  var _visibleToPlan = true;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final placed = widget.editingPlaced;
    final pending = widget.editingPending;
    if (placed != null) {
      _subject.text = placed.subject;
      _body.text = placed.bodyPlain;
      _kept = List<CommunicationAttachment>.from(placed.attachments);
      _visibleToPlan = !placed.isPrivate;
    } else if (pending != null) {
      _subject.text = pending.subject;
      _body.text = pending.bodyPlain;
      _kept = List<CommunicationAttachment>.from(pending.attachments);
    }
  }

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  int get _totalFiles => _kept.length + _files.length;

  String _resolvedSubject(AppLocalizations loc) {
    final s = _subject.text.trim();
    if (s.isNotEmpty) return s;
    final body = _body.text.trim();
    if (body.isEmpty) return loc.communicationKindManual;
    final line = body.split('\n').first.trim();
    if (line.length <= 80) return line;
    return '${line.substring(0, 80)}…';
  }

  Future<void> _pickFile(AppLocalizations loc) async {
    if (_totalFiles >= CommunicationFileService.maxFiles) return;
    try {
      final picked = await CommunicationFileService.pick();
      if (picked == null) return;
      final err = CommunicationFileService.validate(picked);
      if (err != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
        return;
      }
      setState(() => _files.add(picked));
    } on PlanFilePickReadException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.communicationAttachFailed)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.communicationAttachFailed)));
    }
  }

  Future<List<CommunicationAttachment>> _uploadNew(String docId) async {
    final uploaded = <CommunicationAttachment>[];
    for (final f in _files) {
      uploaded.add(await CommunicationFileService.upload(
        userId: widget.userId,
        docId: docId,
        file: f,
      ));
    }
    return uploaded;
  }

  Future<void> _save(AppLocalizations loc) async {
    final body = _body.text.trim();
    if (body.isEmpty && _totalFiles == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.communicationComposeNeedBody)));
      return;
    }
    setState(() => _saving = true);
    try {
      final subject = _resolvedSubject(loc);
      if (widget.isEditing) {
        final docId = widget.editingPlaced?.id ?? widget.editingPending!.id;
        final uploaded = await _uploadNew(docId);
        final all = [..._kept, ...uploaded];
        final placed = widget.editingPlaced;
        if (placed != null) {
          final entityId = widget.entityId;
          if (entityId == null || entityId.isEmpty) {
            throw StateError('entityId required to edit a placed communication');
          }
          await EntityCommunicationService().updateManual(
            entityId: entityId,
            communicationId: placed.id,
            subject: subject,
            bodyPlain: body,
            attachments: all,
          );
        } else {
          await PendingEmailEventService().updateManual(
            userId: widget.userId,
            pendingId: widget.editingPending!.id,
            subject: subject,
            bodyPlain: body,
            attachments: all,
          );
        }
      } else {
        final entityId = widget.entityId;
        late final String docId;
        if (entityId != null) {
          docId = await EntityCommunicationService().createManualOnEntity(
            userId: widget.userId,
            entityId: entityId,
            subject: subject,
            bodyPlain: body,
            visibility: _visibleToPlan ? 'plan' : 'private',
          );
        } else {
          docId = await PendingEmailEventService().createManual(
            userId: widget.userId,
            subject: subject,
            bodyPlain: body,
          );
        }
        if (_files.isNotEmpty) {
          final uploaded = await _uploadNew(docId);
          if (entityId != null) {
            await EntityCommunicationService().setAttachments(
              entityId: entityId,
              communicationId: docId,
              attachments: uploaded,
            );
          } else {
            await PendingEmailEventService().setAttachments(
              userId: widget.userId,
              pendingId: docId,
              attachments: uploaded,
            );
          }
        }
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e, st) {
      LoggerService.error(
        'compose communication save failed',
        context: 'COMPOSE_COMMUNICATION',
        error: e,
        stackTrace: st,
      );
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.pendingEventPlaceFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final atMax = _totalFiles >= CommunicationFileService.maxFiles;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.82,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.isEditing ? loc.communicationEditTitle : loc.communicationComposeTitle,
                        style: AppTypography.titleStyle.copyWith(
                          color: IosFormColors.textPrimary,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _saving ? null : () => Navigator.pop(context, false),
                      child: Text(loc.cancel),
                    ),
                    FilledButton(
                      onPressed: _saving ? null : () => _save(loc),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(loc.communicationComposeSave),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    IosGroupedCard(
                      children: [
                        IosEditField(
                          label: loc.communicationComposeSubject,
                          controller: _subject,
                          hint: loc.communicationKindManual,
                        ),
                        const IosRowSeparator(),
                        IosEditField(
                          label: loc.communicationComposeBody,
                          controller: _body,
                          hint: loc.communicationComposeBodyHint,
                          maxLines: 10,
                          minLines: 6,
                        ),
                      ],
                    ),
                    if (widget.entityId != null && !widget.isEditing) ...[
                      const SizedBox(height: IosFormColors.cardGap),
                      IosGroupedCard(
                        children: [
                          IosSwitchRow(
                            label: _visibleToPlan
                                ? loc.pendingEventVisibilityPlan
                                : loc.pendingEventVisibilityPrivate,
                            value: _visibleToPlan,
                            onChanged: _saving ? null : (v) => setState(() => _visibleToPlan = v),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: IosFormColors.cardGap),
                    IosGroupedCard(
                      children: [
                        IosSettingsRow(
                          label: loc.communicationComposeAttach,
                          value: atMax ? '$_totalFiles' : loc.add,
                          valueColor: IosFormColors.accent,
                          chevron: !atMax,
                          onTap: _saving || atMax ? null : () => _pickFile(loc),
                        ),
                        for (var i = 0; i < _kept.length; i++) ...[
                          const IosRowSeparator(),
                          IosSettingsRow(
                            label: _kept[i].name,
                            value: loc.remove,
                            onTap: _saving
                                ? null
                                : () => setState(() => _kept.removeAt(i)),
                          ),
                        ],
                        for (var i = 0; i < _files.length; i++) ...[
                          const IosRowSeparator(),
                          IosSettingsRow(
                            label: _files[i].name,
                            value: loc.remove,
                            onTap: _saving
                                ? null
                                : () => setState(() => _files.removeAt(i)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
