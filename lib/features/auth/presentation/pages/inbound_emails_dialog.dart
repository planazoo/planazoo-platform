import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/features/auth/domain/services/inbound_email_service.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/inbound_mailbox.dart';
import 'package:unp_calendario/features/security/utils/validator.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/screens/wd_place_communication_flow.dart';

class InboundEmailsDialog extends ConsumerStatefulWidget {
  const InboundEmailsDialog({super.key});

  @override
  ConsumerState<InboundEmailsDialog> createState() => _InboundEmailsDialogState();
}

class _InboundEmailsDialogState extends ConsumerState<InboundEmailsDialog> {
  final _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _mapError(FirebaseFunctionsException e, AppLocalizations loc) {
    switch (e.code) {
      case 'invalid-argument':
        return loc.inboundEmailsInvalid;
      case 'already-exists':
        return loc.inboundEmailsTaken;
      case 'failed-precondition':
        return loc.inboundEmailsMax;
      default:
        if ((e.message ?? '').contains('primary')) return loc.inboundEmailsOwnPrimary;
        return loc.inboundEmailsError;
    }
  }

  Future<void> _request(String email, AppLocalizations loc) async {
    if (!Validator.isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.inboundEmailsInvalid)));
      return;
    }
    setState(() => _busy = true);
    try {
      await InboundEmailService().requestVerification(email);
      if (!mounted) return;
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.inboundEmailsSent)));
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_mapError(e, loc))));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.inboundEmailsError)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final uid = ref.watch(authServiceProvider).currentUser?.uid;
    if (user == null || uid == null) {
      return const SizedBox.shrink();
    }
    return AlertDialog(
      title: Text(loc.inboundEmailsTitle),
      content: SizedBox(
        width: 420,
        child: StreamBuilder<List<InboundEmailEntry>>(
          stream: InboundEmailService().streamExtras(uid),
          builder: (context, snapshot) {
            final extras = snapshot.data ?? const [];
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => PendingEmailEventActions.copyInboundAddress(context),
                    child: Text(
                      kPlanoonInboundMailbox,
                      style: AppTypography.bodyStyle.copyWith(
                        color: AppColorScheme.color2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(loc.inboundEmailsSubtitle, style: AppTypography.caption),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(user.email),
                    subtitle: Text(loc.inboundEmailsPrimaryLabel),
                  ),
                  ...extras.map(
                    (e) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(e.email),
                      subtitle: Text(e.verified ? loc.inboundEmailsVerified : loc.inboundEmailsPending),
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          if (!e.verified)
                            TextButton(
                              onPressed: _busy ? null : () => _request(e.email, loc),
                              child: Text(loc.inboundEmailsResend),
                            ),
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () async {
                                    setState(() => _busy = true);
                                    try {
                                      await InboundEmailService().remove(e.email);
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(this.context).showSnackBar(
                                        SnackBar(content: Text(loc.inboundEmailsRemoved)),
                                      );
                                    } catch (_) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(this.context).showSnackBar(
                                        SnackBar(content: Text(loc.inboundEmailsError)),
                                      );
                                    } finally {
                                      if (mounted) setState(() => _busy = false);
                                    }
                                  },
                            child: Text(loc.inboundEmailsRemove),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (extras.length < 2) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_busy,
                      decoration: InputDecoration(
                        hintText: loc.inboundEmailsAdd,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : () => _request(_controller.text.trim().toLowerCase(), loc),
          child: Text(loc.inboundEmailsAdd),
        ),
      ],
    );
  }
}
