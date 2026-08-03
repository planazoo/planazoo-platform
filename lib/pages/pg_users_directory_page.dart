import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// Directorio de usuarios de la plataforma (solo lectura).
/// Visible temporalmente para autenticados; objetivo producto: solo power_admin.
class UsersDirectoryPage extends ConsumerStatefulWidget {
  const UsersDirectoryPage({
    super.key,
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  ConsumerState<UsersDirectoryPage> createState() => _UsersDirectoryPageState();
}

class _UsersDirectoryPageState extends ConsumerState<UsersDirectoryPage> {
  late Future<List<UserModel>> _usersFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _usersFuture = ref.read(userServiceProvider).getAllUsers();
  }

  Future<void> _reload() async {
    setState(() {
      _usersFuture = ref.read(userServiceProvider).getAllUsers();
    });
    await _usersFuture;
  }

  List<UserModel> _filter(List<UserModel> users) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return users;
    return users.where((u) {
      final hay = [
        u.email,
        u.username ?? '',
        u.displayName ?? '',
        u.id,
        u.defaultTimezone ?? '',
        u.isAdmin ? 'power_admin' : 'user',
      ].join(' ').toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  String _formatUserCard(UserModel user, AppLocalizations loc, DateFormat dateFmt) {
    final title = (user.displayName?.trim().isNotEmpty == true)
        ? user.displayName!.trim()
        : (user.username?.trim().isNotEmpty == true
            ? '@${user.username!.trim()}'
            : user.email);
    final accessLabel = user.isAdmin
        ? loc.usersDirectoryAccessPowerAdmin
        : loc.usersDirectoryAccessUser;
    return [
      '---',
      title,
      '${loc.usersDirectoryFieldAccess}: $accessLabel',
      '${loc.usersDirectoryFieldStatus}: ${user.isActive ? loc.usersDirectoryStatusActive : loc.usersDirectoryStatusInactive}',
      '${loc.usersDirectoryFieldEmail}: ${user.email}',
      if (user.username != null && user.username!.trim().isNotEmpty)
        '${loc.usersDirectoryFieldUsername}: @${user.username!.trim()}',
      if (user.displayName != null && user.displayName!.trim().isNotEmpty)
        '${loc.usersDirectoryFieldDisplayName}: ${user.displayName!.trim()}',
      '${loc.usersDirectoryFieldId}: ${user.id}',
      '${loc.usersDirectoryFieldTimezone}: ${user.defaultTimezone?.trim().isNotEmpty == true ? user.defaultTimezone! : '—'}',
      '${loc.usersDirectoryFieldCreated}: ${dateFmt.format(user.createdAt.toLocal())}',
      '${loc.usersDirectoryFieldLastLogin}: ${user.lastLoginAt != null ? dateFmt.format(user.lastLoginAt!.toLocal()) : '—'}',
      if (user.photoURL != null && user.photoURL!.trim().isNotEmpty)
        '${loc.usersDirectoryFieldPhoto}: ${user.photoURL}',
    ].join('\n');
  }

  Future<void> _copyAllVisible(
    List<UserModel> users,
    AppLocalizations loc,
    DateFormat dateFmt,
  ) async {
    if (users.isEmpty) return;
    final buffer = StringBuffer()
      ..writeln(loc.usersDirectoryTitle)
      ..writeln(loc.usersDirectoryCount(users.length, users.length))
      ..writeln();
    for (final u in users) {
      buffer.writeln(_formatUserCard(u, loc, dateFmt));
      buffer.writeln();
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString().trim()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.usersDirectoryAllCopied(users.length)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final dateFmt = DateFormat.yMMMd().add_Hm();

    return Scaffold(
      backgroundColor: AppColorScheme.color0,
      appBar: AppBar(
        backgroundColor: AppColorScheme.color2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onClose,
        ),
        title: Text(
          loc.usersDirectoryTitle,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            tooltip: loc.usersDirectoryCopyAll,
            icon: const Icon(Icons.copy_all, color: Colors.white),
            onPressed: () async {
              final all = await _usersFuture;
              if (!mounted) return;
              await _copyAllVisible(_filter(all), loc, dateFmt);
            },
          ),
          IconButton(
            tooltip: loc.usersDirectoryRefresh,
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _reload,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              loc.usersDirectorySubtitle,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: loc.usersDirectorySearchHint,
                hintStyle: GoogleFonts.poppins(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1F2937),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SelectionArea(
              child: FutureBuilder<List<UserModel>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColorScheme.color2),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        loc.usersDirectoryLoadError(snapshot.error.toString()),
                        style: GoogleFonts.poppins(color: Colors.red.shade300),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final all = snapshot.data ?? [];
                final users = _filter(all);
                if (users.isEmpty) {
                  return Center(
                    child: Text(
                      loc.usersDirectoryEmpty,
                      style: GoogleFonts.poppins(color: Colors.white54),
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              loc.usersDirectoryCount(users.length, all.length),
                              style: GoogleFonts.poppins(
                                color: Colors.white60,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: () => _copyAllVisible(users, loc, dateFmt),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColorScheme.color2,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                            ),
                            icon: const Icon(Icons.copy_all, size: 18),
                            label: Text(
                              loc.usersDirectoryCopyAll,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: users.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return _UserDirectoryCard(
                            user: user,
                            dateFmt: dateFmt,
                            accessLabel: user.isAdmin
                                ? loc.usersDirectoryAccessPowerAdmin
                                : loc.usersDirectoryAccessUser,
                            formatCard: () => _formatUserCard(user, loc, dateFmt),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserDirectoryCard extends StatelessWidget {
  const _UserDirectoryCard({
    required this.user,
    required this.dateFmt,
    required this.accessLabel,
    required this.formatCard,
  });

  final UserModel user;
  final DateFormat dateFmt;
  final String accessLabel;
  final String Function() formatCard;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final title = (user.displayName?.trim().isNotEmpty == true)
        ? user.displayName!.trim()
        : (user.username?.trim().isNotEmpty == true
            ? '@${user.username!.trim()}'
            : user.email);

    return Material(
      color: const Color(0xFF1F2937),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white12,
                  backgroundImage: user.photoURL != null && user.photoURL!.isNotEmpty
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null || user.photoURL!.isEmpty
                      ? Text(
                          title.isNotEmpty ? title[0].toUpperCase() : '?',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _Chip(
                            label: accessLabel,
                            color: user.isAdmin
                                ? AppColorScheme.color3
                                : Colors.blueGrey.shade400,
                          ),
                          _Chip(
                            label: user.isActive
                                ? loc.usersDirectoryStatusActive
                                : loc.usersDirectoryStatusInactive,
                            color: user.isActive
                                ? Colors.green.shade700
                                : Colors.orange.shade800,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: loc.usersDirectoryCopyCard,
                  icon: const Icon(Icons.copy_all, color: Colors.white54, size: 18),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: formatCard()));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(loc.usersDirectoryCardCopied),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  tooltip: loc.usersDirectoryCopyId,
                  icon: const Icon(Icons.copy, color: Colors.white54, size: 18),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: user.id));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(loc.usersDirectoryIdCopied),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MetaRow(label: loc.usersDirectoryFieldEmail, value: user.email),
            if (user.username != null && user.username!.trim().isNotEmpty)
              _MetaRow(
                label: loc.usersDirectoryFieldUsername,
                value: '@${user.username!.trim()}',
              ),
            _MetaRow(label: loc.usersDirectoryFieldId, value: user.id),
            _MetaRow(
              label: loc.usersDirectoryFieldTimezone,
              value: user.defaultTimezone?.trim().isNotEmpty == true
                  ? user.defaultTimezone!
                  : '—',
            ),
            _MetaRow(
              label: loc.usersDirectoryFieldCreated,
              value: dateFmt.format(user.createdAt.toLocal()),
            ),
            _MetaRow(
              label: loc.usersDirectoryFieldLastLogin,
              value: user.lastLoginAt != null
                  ? dateFmt.format(user.lastLoginAt!.toLocal())
                  : '—',
            ),
            _MetaRow(
              label: loc.usersDirectoryFieldAccess,
              value: accessLabel,
            ),
            _MetaRow(
              label: loc.usersDirectoryFieldStatus,
              value: user.isActive
                  ? loc.usersDirectoryStatusActive
                  : loc.usersDirectoryStatusInactive,
            ),
            if (user.displayName != null && user.displayName!.trim().isNotEmpty)
              _MetaRow(
                label: loc.usersDirectoryFieldDisplayName,
                value: user.displayName!.trim(),
              ),
            if (user.photoURL != null && user.photoURL!.trim().isNotEmpty)
              _MetaRow(
                label: loc.usersDirectoryFieldPhoto,
                value: user.photoURL!,
              ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
