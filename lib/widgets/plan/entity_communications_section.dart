import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/models/entity_communication.dart';
import 'package:unp_calendario/features/calendar/domain/services/entity_communication_service.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';
import 'package:unp_calendario/widgets/plan/communication_body_view.dart';
import 'package:unp_calendario/widgets/plan/compose_communication_sheet.dart';

/// Comunicaciones (mails colocados) en ficha de evento o alojamiento.
class EntityCommunicationsSection extends ConsumerWidget {
  final String entityId;

  const EntityCommunicationsSection({super.key, required this.entityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final uid = ref.watch(authServiceProvider).currentUser?.uid;
    return StreamBuilder<List<EntityCommunication>>(
      stream: EntityCommunicationService().streamForEntity(entityId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return IosGroupedCard(
            children: [
              IosSettingsRow(
                label: loc.entityCommunicationsTitle,
                value: loc.entityCommunicationsLoadError,
                multiline: true,
              ),
            ],
          );
        }
        final all = snapshot.data ?? const <EntityCommunication>[];
        final items = all
            .where((c) => !c.isPrivate || (uid != null && c.ownerId == uid))
            .toList();
        final children = <Widget>[
          IosSettingsRow(
            label: loc.entityCommunicationsTitle,
            value: uid == null
                ? (items.isEmpty ? loc.entityCommunicationsEmpty : '${items.length}')
                : loc.communicationAdd,
            valueColor: uid == null ? null : IosFormColors.accent,
            chevron: uid != null,
            onTap: uid == null
                ? null
                : () => ComposeCommunicationSheet.show(context, userId: uid, entityId: entityId),
          ),
        ];
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          children.add(const IosRowSeparator());
          final date = item.placedAt ?? item.createdAt;
          final suffix = item.isPrivate ? ' · ${loc.entityCommunicationsPrivateBadge}' : '';
          final files = item.attachments.isEmpty
              ? ''
              : ' · ${loc.communicationFilesCount(item.attachments.length)}';
          children.add(
            IosSettingsRow(
              label: item.subject.isEmpty ? '—' : item.subject,
              value: '${date != null ? DateFormatter.formatDate(date) : ''}$files$suffix',
              chevron: true,
              multiline: true,
              onTap: () => _openDetail(context, loc, uid, item),
            ),
          );
        }
        return IosGroupedCard(children: children);
      },
    );
  }

  Future<void> _openDetail(
    BuildContext context,
    AppLocalizations loc,
    String? uid,
    EntityCommunication item,
  ) async {
    final isOwner = uid != null && uid == item.ownerId;
    var visibilityPlan = !item.isPrivate;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: IosFormColors.groupedBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (ctx, setLocal) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subject,
                      style: AppTypography.titleStyle.copyWith(
                        color: IosFormColors.textPrimary,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (item.fromEmail != null && item.fromEmail!.isNotEmpty)
                      Text(
                        item.fromEmail!,
                        style: AppTypography.caption.copyWith(color: IosFormColors.textSecondary),
                      ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.45),
                      child: SingleChildScrollView(
                        child: CommunicationBodyView(
                          bodyPlain: item.bodyPlain,
                          bodyHtml: item.bodyHtml,
                          attachments: item.attachments,
                        ),
                      ),
                    ),
                    if (isOwner) ...[
                      if (item.kind == 'manual')
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await ComposeCommunicationSheet.show(
                              context,
                              userId: uid,
                              entityId: entityId,
                              editingPlaced: item,
                            );
                          },
                          child: Text(loc.edit),
                        ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          visibilityPlan
                              ? loc.pendingEventVisibilityPlan
                              : loc.pendingEventVisibilityPrivate,
                          style: AppTypography.bodyStyle.copyWith(color: IosFormColors.textPrimary),
                        ),
                        activeTrackColor: IosFormColors.accent,
                        value: visibilityPlan,
                        onChanged: (v) async {
                          setLocal(() => visibilityPlan = v);
                          await EntityCommunicationService().setVisibility(
                            entityId: entityId,
                            communicationId: item.id,
                            visibility: v ? 'plan' : 'private',
                          );
                        },
                      ),
                      TextButton(
                        onPressed: () async {
                          final ok = await IosFormConfirmSheet.show(
                            context: ctx,
                            title: loc.entityCommunicationsRemove,
                            message: loc.entityCommunicationsRemoveConfirm,
                            cancelLabel: loc.cancel,
                            confirmLabel: loc.entityCommunicationsRemove,
                            destructive: true,
                          );
                          if (ok == true) {
                            await EntityCommunicationService().unplace(
                              userId: uid,
                              entityId: entityId,
                              communication: item,
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                          }
                        },
                        child: Text(
                          loc.entityCommunicationsRemove,
                          style: TextStyle(color: IosFormColors.danger),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
