import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/plan_notes/domain/models/plan_preparation_item.dart';
import 'package:unp_calendario/features/plan_notes/domain/models/plan_workspace_data.dart';
import 'package:unp_calendario/features/plan_notes/presentation/providers/plan_notes_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

/// T262: Notas comunes/personales y listas de preparación.
class PlanNotesScreen extends ConsumerStatefulWidget {
  final Plan plan;
  final bool embedInPlanDetail;

  const PlanNotesScreen({
    super.key,
    required this.plan,
    this.embedInPlanDetail = false,
  });

  @override
  ConsumerState<PlanNotesScreen> createState() => _PlanNotesScreenState();
}

class _PlanNotesScreenState extends ConsumerState<PlanNotesScreen>
    with SingleTickerProviderStateMixin {
  static const double _notesTextScale = 0.92;
  static const double _fsXs = 12;
  static const double _fsSm = 13;
  static const double _fsTitle = 15;
  late TabController _tabController;
  final _commonNoteCtrl = TextEditingController();
  final _personalNoteCtrl = TextEditingController();
  final _commonNewItemCtrl = TextEditingController();
  final _personalNewItemCtrl = TextEditingController();

  List<PlanPreparationItem> _commonPrep = [];
  List<PlanPreparationItem> _personalPrep = [];

  PreparationCommonEditPolicy _policy = PreparationCommonEditPolicy.organizerOnly;
  List<String> _selectedEditorIds = [];

  bool _dirtyCommon = false;
  bool _dirtyPersonal = false;
  bool _didEnsureWorkspace = false;
  String? _lastAppliedCommonFp;
  String? _lastAppliedPersonalFp;

  static const Color _pageBg = Color(0xFF111827);
  static const Color _surface = Color(0xFF1F2937);
  static const Color _borderSubtle = Colors.white12;

  Color get _textPrimary => Colors.white;

  Color get _textSecondary => Colors.white70;

  Color get _labelMuted => Colors.white70;

  Color get _inputFill => _surface;

  Color get _cardSurface => _surface;

  Color get _readOnlyHintColor => Colors.amber.shade200;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commonNoteCtrl.dispose();
    _personalNoteCtrl.dispose();
    _commonNewItemCtrl.dispose();
    _personalNewItemCtrl.dispose();
    super.dispose();
  }

  static String _workspaceFp(PlanWorkspaceData w) {
    return '${w.commonNoteText}\n${w.preparationItems.map((e) => '${e.id}:${e.done}:${e.text}').join('|')}\n${w.preparationCommonEditPolicy}\n${w.preparationCommonEditorUserIds.join(',')}\n${w.planParticipantUserIds.join(',')}\n${w.updatedAt?.millisecondsSinceEpoch}';
  }

  static String _personalFp(PersonalPlanNotesData w) {
    return '${w.personalNoteText}\n${w.preparationItems.map((e) => '${e.id}:${e.done}:${e.text}').join('|')}\n${w.updatedAt?.millisecondsSinceEpoch}';
  }

  bool _participantCanEditCommon(PlanWorkspaceData ws, String uid) {
    switch (ws.preparationCommonEditPolicy) {
      case PreparationCommonEditPolicy.organizerOnly:
        return false;
      case PreparationCommonEditPolicy.allParticipants:
        return ws.planParticipantUserIds.contains(uid);
      case PreparationCommonEditPolicy.selectedParticipants:
        return ws.preparationCommonEditorUserIds.contains(uid);
    }
  }

  List<String> _allAcceptedParticipantIds(List<PlanParticipation> parts, String organizerId) {
    final ids = <String>{organizerId};
    for (final p in parts) {
      if (p.isActive && p.isAccepted && !p.isObserver) {
        ids.add(p.userId);
      }
    }
    return ids.toList()..sort();
  }

  Future<void> _saveCommon({
    required bool isOrganizer,
    required String planId,
  }) async {
    final loc = AppLocalizations.of(context)!;
    final svc = ref.read(planNotesServiceProvider);
    if (isOrganizer) {
      final parts = ref.read(planRealParticipantsProvider(planId)).valueOrNull ?? [];
      final allIds = _allAcceptedParticipantIds(parts, widget.plan.userId);
      late List<String> planParticipantUserIds;
      late List<String> editorIds;
      switch (_policy) {
        case PreparationCommonEditPolicy.organizerOnly:
          planParticipantUserIds = [widget.plan.userId];
          editorIds = [];
        case PreparationCommonEditPolicy.allParticipants:
          planParticipantUserIds = allIds;
          editorIds = [];
        case PreparationCommonEditPolicy.selectedParticipants:
          planParticipantUserIds = allIds;
          editorIds = List<String>.from(_selectedEditorIds)..sort();
      }
      final data = PlanWorkspaceData(
        commonNoteText: _commonNoteCtrl.text,
        preparationItems: List<PlanPreparationItem>.from(_commonPrep),
        preparationCommonEditPolicy: _policy,
        preparationCommonEditorUserIds: editorIds,
        planParticipantUserIds: planParticipantUserIds,
      );
      final ok = await svc.saveWorkspaceFull(planId: planId, data: data);
      if (!mounted) return;
      if (ok) {
        setState(() => _dirtyCommon = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.planNotesSaved)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.planNotesSaveError)));
      }
    } else {
      final ok = await svc.saveWorkspaceParticipantContent(
        planId: planId,
        commonNoteText: _commonNoteCtrl.text,
        preparationItems: List<PlanPreparationItem>.from(_commonPrep),
      );
      if (!mounted) return;
      if (ok) {
        setState(() => _dirtyCommon = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.planNotesSaved)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.planNotesSaveError)));
      }
    }
  }

  Future<void> _savePersonal(String planId, String userId) async {
    final loc = AppLocalizations.of(context)!;
    final data = PersonalPlanNotesData(
      personalNoteText: _personalNoteCtrl.text,
      preparationItems: List<PlanPreparationItem>.from(_personalPrep),
    );
    final ok = await ref.read(planNotesServiceProvider).savePersonal(
          planId: planId,
          userId: userId,
          data: data,
        );
    if (!mounted) return;
    if (ok) {
      setState(() => _dirtyPersonal = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.planNotesSaved)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.planNotesSaveError)));
    }
  }

  Future<void> _openSelectEditorsDialog(
    List<PlanParticipation> participants,
    Map<String, String> names,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final initial = Set<String>.from(_selectedEditorIds);
    final picked = await showDialog<Set<String>>(
      context: context,
      builder: (ctx) {
        var local = Set<String>.from(initial);
        return StatefulBuilder(
          builder: (context, setLocal) {
            return Theme(
              data: AppTheme.darkTheme,
              child: AlertDialog(
                backgroundColor: _surface,
                title: Text(
                  loc.planNotesSelectParticipantsTitle,
                  style: const TextStyle(color: Colors.white),
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final p in participants)
                        if (p.isActive && p.isAccepted && !p.isObserver)
                          CheckboxListTile(
                            value: local.contains(p.userId),
                            onChanged: (v) {
                              setLocal(() {
                                if (v == true) {
                                  local.add(p.userId);
                                } else {
                                  local.remove(p.userId);
                                }
                              });
                            },
                            title: Text(
                              names[p.userId] ?? p.userId,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            activeColor: AppColorScheme.color2,
                          ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, local),
                    child: Text(loc.planNotesApplySelection),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedEditorIds = picked.toList()..sort();
        _dirtyCommon = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final plan = widget.plan;
    final planId = plan.id;
    final user = ref.watch(currentUserProvider);
    final userId = user?.id;

    if (planId == null || userId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isOrganizer = userId == plan.userId;

    ref.listen(planWorkspaceStreamProvider(planId), (previous, next) {
      next.whenData((ws) {
        if (ws == null) {
          if (isOrganizer && !_didEnsureWorkspace) {
            _didEnsureWorkspace = true;
            ref.read(planNotesServiceProvider).ensureWorkspaceDocument(
                  planId: planId,
                  organizerUserId: plan.userId,
                );
          }
          return;
        }
        if (_dirtyCommon) return;
        final fp = _workspaceFp(ws);
        if (fp == _lastAppliedCommonFp) return;
        _lastAppliedCommonFp = fp;
        _commonNoteCtrl.text = ws.commonNoteText;
        setState(() {
          _commonPrep = List<PlanPreparationItem>.from(ws.preparationItems);
          _policy = ws.preparationCommonEditPolicy;
          _selectedEditorIds = List<String>.from(ws.preparationCommonEditorUserIds);
        });
      });
    });

    ref.listen(
      personalPlanNotesStreamProvider(PersonalPlanNotesKey(planId: planId, userId: userId)),
      (previous, next) {
        next.whenData((p) {
          if (p == null) {
            if (!_dirtyPersonal && _lastAppliedPersonalFp == null) {
              _personalNoteCtrl.clear();
              setState(() => _personalPrep = []);
              _lastAppliedPersonalFp = '';
            }
            return;
          }
          if (_dirtyPersonal) return;
          final fp = _personalFp(p);
          if (fp == _lastAppliedPersonalFp) return;
          _lastAppliedPersonalFp = fp;
          _personalNoteCtrl.text = p.personalNoteText;
          setState(() {
            _personalPrep = List<PlanPreparationItem>.from(p.preparationItems);
          });
        });
      },
    );

    final wsAsync = ref.watch(planWorkspaceStreamProvider(planId));
    final workspace = wsAsync.valueOrNull;
    final canEditCommon =
        isOrganizer || (workspace != null && _participantCanEditCommon(workspace, userId));
    final readOnlyCommon = !canEditCommon;

    final participantsAsync = ref.watch(planRealParticipantsProvider(planId));
    final nameMapAsync = ref.watch(planParticipantDisplayNamesProvider(planId));
    final notesTabBar = TabBar(
      controller: _tabController,
      indicatorColor: AppColorScheme.color2,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      labelStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: _fsSm,
      ),
      tabs: [
        Tab(text: loc.planNotesTabCommon),
        Tab(text: loc.planNotesTabPersonal),
      ],
    );

    return Theme(
      data: AppTheme.darkTheme,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(_notesTextScale),
        ),
        child: Scaffold(
          backgroundColor: _pageBg,
          appBar: null,
          body: Column(
            children: [
              Material(
                color: _surface,
                child: notesTabBar,
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCommonTab(
                      context,
                      loc: loc,
                      planId: planId,
                      userId: userId,
                      isOrganizer: isOrganizer,
                      workspaceLoading: wsAsync.isLoading,
                      workspace: workspace,
                      readOnlyCommon: readOnlyCommon,
                      canEditCommon: canEditCommon,
                      participantsAsync: participantsAsync,
                      nameMapAsync: nameMapAsync,
                    ),
                    _buildPersonalTab(
                      context,
                      loc: loc,
                      planId: planId,
                      userId: userId,
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

  Widget _buildCommonTab(
    BuildContext context, {
    required AppLocalizations loc,
    required String planId,
    required String userId,
    required bool isOrganizer,
    required bool workspaceLoading,
    required PlanWorkspaceData? workspace,
    required bool readOnlyCommon,
    required bool canEditCommon,
    required AsyncValue<List<PlanParticipation>> participantsAsync,
    required AsyncValue<Map<String, String>> nameMapAsync,
  }) {
    if (workspaceLoading && workspace == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (workspace == null && !isOrganizer) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            loc.planNotesNoWorkspaceYet,
            textAlign: TextAlign.center,
            style: TextStyle(color: _textSecondary),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            loc.planNotesCommonIntro,
            style: TextStyle(color: _textSecondary, fontSize: _fsXs),
          ),
          if (readOnlyCommon) ...[
            const SizedBox(height: 8),
            Text(
              loc.planNotesReadOnlyHint,
              style: TextStyle(color: _readOnlyHintColor, fontSize: _fsXs),
            ),
          ],
          const SizedBox(height: 16),
          if (isOrganizer) ...[
            Text(
              loc.planNotesPolicyTitle,
              style: GoogleFonts.poppins(
                color: _textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: _fsSm,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(loc.planNotesPolicyOrganizerOnly),
                  selected: _policy == PreparationCommonEditPolicy.organizerOnly,
                  onSelected: (_) {
                    setState(() {
                      _policy = PreparationCommonEditPolicy.organizerOnly;
                      _dirtyCommon = true;
                    });
                  },
                ),
                ChoiceChip(
                  label: Text(loc.planNotesPolicySelected),
                  selected: _policy == PreparationCommonEditPolicy.selectedParticipants,
                  onSelected: (_) {
                    setState(() {
                      _policy = PreparationCommonEditPolicy.selectedParticipants;
                      _dirtyCommon = true;
                    });
                  },
                ),
                ChoiceChip(
                  label: Text(loc.planNotesPolicyAll),
                  selected: _policy == PreparationCommonEditPolicy.allParticipants,
                  onSelected: (_) {
                    setState(() {
                      _policy = PreparationCommonEditPolicy.allParticipants;
                      _dirtyCommon = true;
                    });
                  },
                ),
              ],
            ),
            if (_policy == PreparationCommonEditPolicy.selectedParticipants) ...[
              const SizedBox(height: 8),
              participantsAsync.when(
                data: (parts) {
                  return nameMapAsync.when(
                    data: (names) => OutlinedButton(
                      onPressed: () => _openSelectEditorsDialog(parts, names),
                      child: Text(loc.planNotesSelectParticipantsTitle),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
            const SizedBox(height: 16),
          ],
          Text(
            loc.planNotesPreparationTitle,
            style: GoogleFonts.poppins(
              color: AppColorScheme.color2,
              fontWeight: FontWeight.w600,
              fontSize: _fsTitle,
            ),
          ),
          const SizedBox(height: 8),
          ..._commonPrep.map((item) => _prepTile(
                item: item,
                readOnly: readOnlyCommon,
                onToggle: (done) {
                  setState(() {
                    _commonPrep = [
                      for (final i in _commonPrep)
                        if (i.id == item.id) i.copyWith(done: done) else i,
                    ];
                    _dirtyCommon = true;
                  });
                },
                onDelete: readOnlyCommon
                    ? null
                    : () {
                        setState(() {
                          _commonPrep = _commonPrep.where((i) => i.id != item.id).toList();
                          _dirtyCommon = true;
                        });
                      },
              )),
          if (!readOnlyCommon) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commonNewItemCtrl,
                    style: TextStyle(color: _textPrimary, fontSize: _fsSm),
                    decoration: InputDecoration(
                      hintText: loc.planNotesNewItemHint,
                      hintStyle: TextStyle(color: _textSecondary, fontSize: _fsSm),
                      isDense: true,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: _borderSubtle),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: AppColorScheme.color2),
                  onPressed: () {
                    final t = _commonNewItemCtrl.text.trim();
                    if (t.isEmpty) return;
                    setState(() {
                      _commonPrep = [
                        ..._commonPrep,
                        PlanPreparationItem(id: const Uuid().v4(), text: t),
                      ];
                      _commonNewItemCtrl.clear();
                      _dirtyCommon = true;
                    });
                  },
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Text(
            loc.planNotesCommonNoteLabel,
            style: GoogleFonts.poppins(color: _labelMuted, fontSize: _fsSm),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commonNoteCtrl,
            readOnly: readOnlyCommon,
            minLines: 4,
            maxLines: 12,
            onChanged: (_) => setState(() => _dirtyCommon = true),
            style: TextStyle(color: _textPrimary, fontSize: _fsSm),
            decoration: InputDecoration(
              filled: true,
              fillColor: _inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColorScheme.color2, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (canEditCommon)
            FilledButton(
              onPressed: () => _saveCommon(
                isOrganizer: isOrganizer,
                planId: planId,
              ),
              style: FilledButton.styleFrom(backgroundColor: AppColorScheme.color2),
              child: Text(loc.planNotesSave),
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalTab(
    BuildContext context, {
    required AppLocalizations loc,
    required String planId,
    required String userId,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            loc.planNotesPersonalIntro,
            style: TextStyle(color: _textSecondary, fontSize: _fsXs),
          ),
          const SizedBox(height: 16),
          Text(
            loc.planNotesPreparationTitle,
            style: GoogleFonts.poppins(
              color: AppColorScheme.color2,
              fontWeight: FontWeight.w600,
              fontSize: _fsTitle,
            ),
          ),
          const SizedBox(height: 8),
          ..._personalPrep.map((item) => _prepTile(
                item: item,
                readOnly: false,
                onToggle: (done) {
                  setState(() {
                    _personalPrep = [
                      for (final i in _personalPrep)
                        if (i.id == item.id) i.copyWith(done: done) else i,
                    ];
                    _dirtyPersonal = true;
                  });
                },
                onDelete: () {
                  setState(() {
                    _personalPrep = _personalPrep.where((i) => i.id != item.id).toList();
                    _dirtyPersonal = true;
                  });
                },
              )),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _personalNewItemCtrl,
                  style: TextStyle(color: _textPrimary, fontSize: _fsSm),
                  decoration: InputDecoration(
                    hintText: loc.planNotesNewItemHint,
                    hintStyle: TextStyle(color: _textSecondary, fontSize: _fsSm),
                    isDense: true,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: _borderSubtle),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColorScheme.color2),
                onPressed: () {
                  final t = _personalNewItemCtrl.text.trim();
                  if (t.isEmpty) return;
                  setState(() {
                    _personalPrep = [
                      ..._personalPrep,
                      PlanPreparationItem(id: const Uuid().v4(), text: t),
                    ];
                    _personalNewItemCtrl.clear();
                    _dirtyPersonal = true;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            loc.planNotesPersonalNoteLabel,
            style: GoogleFonts.poppins(color: _labelMuted, fontSize: _fsSm),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _personalNoteCtrl,
            minLines: 4,
            maxLines: 12,
            onChanged: (_) => setState(() => _dirtyPersonal = true),
            style: TextStyle(color: _textPrimary, fontSize: _fsSm),
            decoration: InputDecoration(
              filled: true,
              fillColor: _inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColorScheme.color2, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => _savePersonal(planId, userId),
            style: FilledButton.styleFrom(backgroundColor: AppColorScheme.color2),
            child: Text(loc.planNotesSave),
          ),
        ],
      ),
    );
  }

  Widget _prepTile({
    required PlanPreparationItem item,
    required bool readOnly,
    required ValueChanged<bool> onToggle,
    required VoidCallback? onDelete,
  }) {
    const strikeColor = Colors.white54;
    return Card(
      color: _cardSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _borderSubtle.withValues(alpha: 0.9)),
      ),
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Checkbox(
          value: item.done,
          onChanged: readOnly ? null : (v) => onToggle(v ?? false),
          activeColor: AppColorScheme.color2,
        ),
        title: Text(
          item.text,
          style: TextStyle(
            color: _textPrimary,
            fontSize: _fsSm,
            decoration: item.done ? TextDecoration.lineThrough : null,
            decorationColor: strikeColor,
          ),
        ),
        trailing: onDelete == null
            ? null
            : IconButton(
                icon: Icon(Icons.delete_outline, color: strikeColor),
                onPressed: onDelete,
              ),
      ),
    );
  }
}
