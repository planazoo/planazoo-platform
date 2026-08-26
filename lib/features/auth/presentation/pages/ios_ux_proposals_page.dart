import 'package:flutter/material.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';

/// Demo temporal: propuestas UX tipo iOS.
/// Acceso: `/demo/ios-ux-proposals` o UI Review Hub.
/// **D** = híbrida recomendada (view/edit + Settings + tipografía iOS dark).
class IosUxProposalsPage extends StatefulWidget {
  const IosUxProposalsPage({super.key});

  @override
  State<IosUxProposalsPage> createState() => _IosUxProposalsPageState();
}

class _IosUxProposalsPageState extends State<IosUxProposalsPage> {
  int _screen = 0; // 0 info, 1 evento, 2 alojamiento
  int _proposal = 3; // D por defecto

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Builder(
        builder: (context) {
          final theme = _ProposalTheme.iosDark(_proposal);
          return Scaffold(
            backgroundColor: theme.pageBg,
            appBar: AppBar(
              backgroundColor: theme.pageBg,
              elevation: 0,
              foregroundColor: theme.textPrimary,
              title: Text(
                'Propuestas UX iOS (temporal)',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  letterSpacing: -0.41,
                ),
              ),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Colores iOS dark. Recomendada: D · Híbrida.',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _Segmented(
                        theme: theme,
                        labels: const ['Info', 'Evento', 'Aloj.'],
                        selected: _screen,
                        onChanged: (i) => setState(() => _screen = i),
                      ),
                      const SizedBox(height: 8),
                      _Segmented(
                        theme: theme,
                        labels: const ['A', 'B', 'C', 'D ★'],
                        selected: _proposal,
                        onChanged: (i) => setState(() => _proposal = i),
                      ),
                      const SizedBox(height: 8),
                      _ProposalBlurb(theme: theme, proposal: _proposal),
                    ],
                  ),
                ),
                Expanded(
                  child: switch (_screen) {
                    0 => _proposal == 3
                        ? _PlanInfoD(theme: theme)
                        : _PlanInfoLegacy(theme: theme, proposal: _proposal),
                    1 => _proposal == 3
                        ? _EventD(theme: theme)
                        : _EventLegacy(theme: theme, proposal: _proposal),
                    _ => _proposal == 3
                        ? _AccommodationD(theme: theme)
                        : _AccommodationLegacy(
                            theme: theme, proposal: _proposal),
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Theme ─────────────────────────────────────────────────────────────────

class _ProposalTheme {
  const _ProposalTheme({
    required this.pageBg,
    required this.groupedBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.separator,
    required this.labelSize,
    required this.valueSize,
    required this.sectionSize,
    required this.bordered,
  });

  final Color pageBg;
  final Color groupedBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color separator;
  final double labelSize;
  final double valueSize;
  final double sectionSize;
  final bool bordered;

  Color get accent => AppColorScheme.color2;
  Color get danger => const Color(0xFFFF453A); // systemRed dark

  static _ProposalTheme iosDark(int proposal) {
    const label = Color(0xFFFFFFFF);
    const secondaryLabel = Color(0x99EBEBF5);
    const tertiaryLabel = Color(0x4DEBEBF5);
    const page = Color(0xFF000000);
    const card = Color(0xFF1C1C1E);
    const sep = Color(0x99545458);

    switch (proposal) {
      case 1: // B
        return const _ProposalTheme(
          pageBg: page,
          groupedBg: card,
          textPrimary: label,
          textSecondary: secondaryLabel,
          textTertiary: tertiaryLabel,
          separator: sep,
          labelSize: 15,
          valueSize: 17,
          sectionSize: 13,
          bordered: true,
        );
      case 2: // C
        return const _ProposalTheme(
          pageBg: page,
          groupedBg: card,
          textPrimary: label,
          textSecondary: secondaryLabel,
          textTertiary: tertiaryLabel,
          separator: sep,
          labelSize: 13,
          valueSize: 17,
          sectionSize: 13,
          bordered: true,
        );
      case 3: // D · híbrida
        return const _ProposalTheme(
          pageBg: page,
          groupedBg: card,
          textPrimary: label,
          textSecondary: secondaryLabel,
          textTertiary: tertiaryLabel,
          separator: sep,
          labelSize: 15,
          valueSize: 17,
          sectionSize: 13,
          bordered: false,
        );
      default: // A
        return const _ProposalTheme(
          pageBg: page,
          groupedBg: card,
          textPrimary: label,
          textSecondary: secondaryLabel,
          textTertiary: tertiaryLabel,
          separator: sep,
          labelSize: 13,
          valueSize: 17,
          sectionSize: 13,
          bordered: true,
        );
    }
  }
}

class _ProposalBlurb extends StatelessWidget {
  const _ProposalBlurb({required this.theme, required this.proposal});
  final _ProposalTheme theme;
  final int proposal;

  @override
  Widget build(BuildContext context) {
    final text = switch (proposal) {
      1 => 'B · Tipografía más grande (15/17).',
      2 => 'C · View/Edit básico.',
      3 =>
        'D · Híbrida: ficha → Editar; filas Settings; título grande; Cancelar/Guardar; sin bordes duros; notas expandibles.',
      _ => 'A · Grouped tipo Ajustes.',
    };
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.groupedBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(color: theme.textSecondary, fontSize: 12, height: 1.35),
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.theme,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final _ProposalTheme theme;
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: theme.groupedBg,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: selected == i
                        ? const Color(0xFF636366)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          selected == i ? FontWeight.w600 : FontWeight.w500,
                      color: selected == i
                          ? theme.textPrimary
                          : theme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// D · HÍBRIDA
// ═══════════════════════════════════════════════════════════════════════════

class _PlanInfoD extends StatefulWidget {
  const _PlanInfoD({required this.theme});
  final _ProposalTheme theme;

  @override
  State<_PlanInfoD> createState() => _PlanInfoDState();
}

class _PlanInfoDState extends State<_PlanInfoD> {
  bool _editing = false;
  bool _notesExpanded = false;
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: 'Verano familia 2026');
    _desc = TextEditingController(
      text: 'Tres semanas en la costa. Mezcla de playa, barca y cenas.',
    );
    _notes = TextEditingController(
      text:
          'Casa alquilada · WiFi OK · Llevar toallas. Clave en la caja junto al buzón. Contacto: Ana +34 600 000 000.',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _setEditing(bool value) => setState(() => _editing = value);

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return Column(
      children: [
        _EditBar(
          theme: t,
          editing: _editing,
          onEdit: () => _setEditing(true),
          onCancel: () => _setEditing(false),
          onSave: () => _setEditing(false),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              _HeroHeader(
                theme: t,
                title: _name.text,
                subtitle: '12 jul – 2 ago · En planificación',
                chip: '4 personas',
              ),
              const SizedBox(height: 8),
              _HintBanner(
                theme: t,
                text: 'Próximo: Cena en Trattoria · jue 18 jul 20:30',
              ),
              _SectionLabel(theme: t, title: 'GENERAL'),
              _Card(
                theme: t,
                children: _editing
                    ? [
                        _EditField(theme: t, label: 'Nombre', controller: _name),
                        _Sep(theme: t),
                        _EditField(
                          theme: t,
                          label: 'Descripción',
                          controller: _desc,
                          maxLines: 3,
                        ),
                        _Sep(theme: t),
                        _SettingsRow(
                          theme: t,
                          label: 'Fechas',
                          value: '12 jul – 2 ago',
                          chevron: true,
                        ),
                        _Sep(theme: t),
                        _SettingsRow(
                          theme: t,
                          label: 'Estado',
                          value: 'En planificación',
                          chevron: true,
                        ),
                      ]
                    : [
                        _SettingsRow(
                          theme: t,
                          label: 'Nombre',
                          value: _name.text,
                        ),
                        _Sep(theme: t),
                        _SettingsRow(
                          theme: t,
                          label: 'Descripción',
                          value: _desc.text,
                          multiline: true,
                        ),
                        _Sep(theme: t),
                        _SettingsRow(
                          theme: t,
                          label: 'Fechas',
                          value: '12 jul – 2 ago 2026',
                        ),
                        _Sep(theme: t),
                        _SettingsRow(
                          theme: t,
                          label: 'Estado',
                          value: 'En planificación',
                          valueColor: t.accent,
                        ),
                      ],
              ),
              _SectionLabel(theme: t, title: 'NOTAS'),
              _Card(
                theme: t,
                children: [
                  if (_editing)
                    _EditField(
                      theme: t,
                      label: 'Notas de referencia',
                      controller: _notes,
                      maxLines: 4,
                    )
                  else
                    _ExpandableNote(
                      theme: t,
                      text: _notes.text,
                      expanded: _notesExpanded,
                      onToggle: () =>
                          setState(() => _notesExpanded = !_notesExpanded),
                    ),
                ],
              ),
              _SectionLabel(theme: t, title: 'PERSONAS'),
              _Card(
                theme: t,
                children: [
                  _SettingsRow(
                    theme: t,
                    label: 'Participantes',
                    value: '4',
                    chevron: !_editing,
                  ),
                  _Sep(theme: t),
                  _SettingsRow(
                    theme: t,
                    label: 'Invitaciones',
                    value: '1 pendiente',
                    valueColor: const Color(0xFFFF9F0A),
                    chevron: !_editing,
                  ),
                ],
              ),
              if (!_editing) ...[
                const SizedBox(height: 20),
                _DestructiveButton(
                  theme: t,
                  label: 'Salir del plan',
                  onPressed: () {},
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Los cambios se sincronizan con todos los participantes.',
                textAlign: TextAlign.center,
                style: TextStyle(color: t.textTertiary, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EventD extends StatefulWidget {
  const _EventD({required this.theme});
  final _ProposalTheme theme;

  @override
  State<_EventD> createState() => _EventDState();
}

class _EventDState extends State<_EventD> {
  bool _editing = false;
  bool _notesExpanded = false;
  late final TextEditingController _title;
  late final TextEditingController _place;
  late final TextEditingController _notes;
  late final TextEditingController _cost;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: 'Cena en Trattoria da Mario');
    _place = TextEditingController(text: 'Trastevere, Roma');
    _notes = TextEditingController(text: 'Reserva a nombre de Ana · Mesa terraza');
    _cost = TextEditingController(text: '180');
  }

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    _notes.dispose();
    _cost.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return Column(
      children: [
        _EditBar(
          theme: t,
          editing: _editing,
          onEdit: () => setState(() => _editing = true),
          onCancel: () => setState(() => _editing = false),
          onSave: () => setState(() => _editing = false),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              _HeroHeader(
                theme: t,
                title: _title.text,
                subtitle: 'Restauración · Cena',
                chip: 'En 2 días',
                chipAccent: true,
              ),
              _SectionLabel(theme: t, title: 'CUÁNDO Y DÓNDE'),
              _Card(
                theme: t,
                children: _editing
                    ? [
                        _EditField(theme: t, label: 'Título', controller: _title),
                        _Sep(theme: t),
                        _SettingsRow(
                          theme: t,
                          label: 'Fecha y hora',
                          value: 'Jue 18 jul · 20:30',
                          chevron: true,
                        ),
                        _Sep(theme: t),
                        _SettingsRow(
                          theme: t,
                          label: 'Duración',
                          value: '2 h',
                          chevron: true,
                        ),
                        _Sep(theme: t),
                        _EditField(theme: t, label: 'Lugar', controller: _place),
                      ]
                    : [
                        _SettingsRow(
                          theme: t,
                          label: 'Cuándo',
                          value: 'Jue 18 jul · 20:30',
                        ),
                        _Sep(theme: t),
                        _SettingsRow(theme: t, label: 'Duración', value: '2 h'),
                        _Sep(theme: t),
                        _SettingsRow(
                          theme: t,
                          label: 'Lugar',
                          value: _place.text,
                          chevron: true,
                        ),
                      ],
              ),
              _SectionLabel(theme: t, title: 'QUIÉN Y CUÁNTO'),
              _Card(
                theme: t,
                children: [
                  _SettingsRow(
                    theme: t,
                    label: 'Participantes',
                    value: _editing ? '3' : 'Ana, Luis, Bea',
                    chevron: _editing,
                  ),
                  _Sep(theme: t),
                  if (_editing)
                    _EditField(
                      theme: t,
                      label: 'Coste (EUR)',
                      controller: _cost,
                      keyboardType: TextInputType.number,
                    )
                  else
                    _SettingsRow(
                      theme: t,
                      label: 'Coste',
                      value: '${_cost.text} EUR',
                    ),
                ],
              ),
              _SectionLabel(theme: t, title: 'NOTAS'),
              _Card(
                theme: t,
                children: [
                  if (_editing)
                    _EditField(
                      theme: t,
                      label: 'Notas',
                      controller: _notes,
                      maxLines: 3,
                    )
                  else
                    _ExpandableNote(
                      theme: t,
                      text: _notes.text,
                      expanded: _notesExpanded,
                      onToggle: () =>
                          setState(() => _notesExpanded = !_notesExpanded),
                    ),
                ],
              ),
              if (!_editing) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SecondaryButton(
                        theme: t,
                        label: 'Cómo llegar',
                        icon: Icons.map_outlined,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SecondaryButton(
                        theme: t,
                        label: 'Añadir gasto',
                        icon: Icons.payments_outlined,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _DestructiveButton(
                  theme: t,
                  label: 'Eliminar evento',
                  onPressed: () {},
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AccommodationD extends StatefulWidget {
  const _AccommodationD({required this.theme});
  final _ProposalTheme theme;

  @override
  State<_AccommodationD> createState() => _AccommodationDState();
}

class _AccommodationDState extends State<_AccommodationD> {
  bool _editing = false;
  late final TextEditingController _name;
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: 'Casa Costa Brava');
    _address = TextEditingController(text: 'Carrer del Mar 12, Begur');
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return Column(
      children: [
        _EditBar(
          theme: t,
          editing: _editing,
          onEdit: () => setState(() => _editing = true),
          onCancel: () => setState(() => _editing = false),
          onSave: () => setState(() => _editing = false),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              _HeroHeader(
                theme: t,
                title: _name.text,
                subtitle: 'Alojamiento · 12 jul → 2 ago',
                chip: '4 huéspedes',
              ),
              _SectionLabel(theme: t, title: 'DETALLES'),
              _Card(
                theme: t,
                children: _editing
                    ? [
                        _EditField(theme: t, label: 'Nombre', controller: _name),
                        _Sep(theme: t),
                        _EditField(
                          theme: t,
                          label: 'Dirección',
                          controller: _address,
                          maxLines: 2,
                        ),
                        _Sep(theme: t),
                        _SettingsRow(
                          theme: t,
                          label: 'Check-in / out',
                          value: '12 jul → 2 ago',
                          chevron: true,
                        ),
                      ]
                    : [
                        _SettingsRow(
                          theme: t,
                          label: 'Dirección',
                          value: _address.text,
                          chevron: true,
                        ),
                        _Sep(theme: t),
                        _SettingsRow(
                          theme: t,
                          label: 'Estancia',
                          value: '12 jul → 2 ago',
                        ),
                        _Sep(theme: t),
                        _SettingsRow(theme: t, label: 'Huéspedes', value: '4'),
                        _Sep(theme: t),
                        _SettingsRow(theme: t, label: 'Coste', value: '2.400 EUR'),
                        _Sep(theme: t),
                        _SettingsRow(
                          theme: t,
                          label: 'Referencia',
                          value: 'AIR-8821',
                        ),
                      ],
              ),
              if (!_editing) ...[
                const SizedBox(height: 16),
                _SecondaryButton(
                  theme: t,
                  label: 'Abrir en Maps',
                  icon: Icons.map_outlined,
                  onPressed: () {},
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── D building blocks ─────────────────────────────────────────────────────

class _EditBar extends StatelessWidget {
  const _EditBar({
    required this.theme,
    required this.editing,
    required this.onEdit,
    required this.onCancel,
    required this.onSave,
  });

  final _ProposalTheme theme;
  final bool editing;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      child: Row(
        children: [
          if (editing)
            TextButton(
              onPressed: onCancel,
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: theme.accent,
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          else
            const SizedBox(width: 88),
          const Spacer(),
          if (editing)
            TextButton(
              onPressed: onSave,
              child: Text(
                'Guardar',
                style: TextStyle(
                  color: theme.accent,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            TextButton(
              onPressed: onEdit,
              child: Text(
                'Editar',
                style: TextStyle(
                  color: theme.accent,
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.theme,
    required this.title,
    required this.subtitle,
    this.chip,
    this.chipAccent = false,
  });

  final _ProposalTheme theme;
  final String title;
  final String subtitle;
  final String? chip;
  final bool chipAccent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 15,
              height: 1.3,
            ),
          ),
          if (chip != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: chipAccent
                    ? theme.accent.withValues(alpha: 0.22)
                    : const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                chip!,
                style: TextStyle(
                  color: chipAccent ? theme.accent : theme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HintBanner extends StatelessWidget {
  const _HintBanner({required this.theme, required this.text});
  final _ProposalTheme theme;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.groupedBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, size: 18, color: theme.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: theme.textTertiary, size: 18),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.theme, required this.title});
  final _ProposalTheme theme;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        title,
        style: TextStyle(
          color: theme.textTertiary,
          fontSize: theme.sectionSize,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.08,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.theme, required this.children});
  final _ProposalTheme theme;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.groupedBg,
        borderRadius: BorderRadius.circular(12),
        border: theme.bordered ? Border.all(color: theme.separator) : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _Sep extends StatelessWidget {
  const _Sep({required this.theme});
  final _ProposalTheme theme;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 16,
      color: theme.separator,
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.theme,
    required this.label,
    required this.value,
    this.chevron = false,
    this.multiline = false,
    this.valueColor,
  });

  final _ProposalTheme theme;
  final String label;
  final String value;
  final bool chevron;
  final bool multiline;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final display = value.trim().isEmpty ? '—' : value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: multiline
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: theme.labelSize,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  display,
                  style: TextStyle(
                    color: valueColor ?? theme.textSecondary,
                    fontSize: theme.valueSize - 1,
                    height: 1.35,
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: theme.valueSize,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    display,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: valueColor ?? theme.textSecondary,
                      fontSize: theme.valueSize,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (chevron) ...[
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right, color: theme.textTertiary, size: 20),
                ],
              ],
            ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.theme,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
  });

  final _ProposalTheme theme;
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: theme.valueSize,
              fontWeight: FontWeight.w400,
            ),
            cursorColor: theme.accent,
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableNote extends StatelessWidget {
  const _ExpandableNote({
    required this.theme,
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  final _ProposalTheme theme;
  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final long = text.length > 80;
    return InkWell(
      onTap: long ? onToggle : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              maxLines: expanded ? null : 2,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: theme.valueSize - 1,
                height: 1.35,
              ),
            ),
            if (long) ...[
              const SizedBox(height: 6),
              Text(
                expanded ? 'Ver menos' : 'Ver más',
                style: TextStyle(
                  color: theme.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.theme,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final _ProposalTheme theme;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.groupedBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: theme.accent),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.accent,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestructiveButton extends StatelessWidget {
  const _DestructiveButton({
    required this.theme,
    required this.label,
    required this.onPressed,
  });

  final _ProposalTheme theme;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.groupedBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.danger,
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// A / B / C legacy (compactos para comparar)
// ═══════════════════════════════════════════════════════════════════════════

class _PlanInfoLegacy extends StatefulWidget {
  const _PlanInfoLegacy({required this.theme, required this.proposal});
  final _ProposalTheme theme;
  final int proposal;

  @override
  State<_PlanInfoLegacy> createState() => _PlanInfoLegacyState();
}

class _PlanInfoLegacyState extends State<_PlanInfoLegacy> {
  bool _editing = false;
  final _name = TextEditingController(text: 'Verano familia 2026');
  final _desc = TextEditingController(text: 'Tres semanas en la costa.');

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final isView = widget.proposal == 2 && !_editing;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        if (widget.proposal == 2)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => setState(() => _editing = !_editing),
              child: Text(
                _editing ? 'Listo' : 'Editar',
                style: TextStyle(color: t.accent, fontSize: 17),
              ),
            ),
          ),
        _SectionLabel(theme: t, title: 'GENERAL'),
        _Card(
          theme: t,
          children: [
            if (isView) ...[
              _SettingsRow(theme: t, label: 'Nombre', value: _name.text),
              _Sep(theme: t),
              _SettingsRow(
                theme: t,
                label: 'Descripción',
                value: _desc.text,
                multiline: true,
              ),
            ] else ...[
              _EditField(theme: t, label: 'Nombre', controller: _name),
              _Sep(theme: t),
              _EditField(
                theme: t,
                label: 'Descripción',
                controller: _desc,
                maxLines: 2,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _EventLegacy extends StatefulWidget {
  const _EventLegacy({required this.theme, required this.proposal});
  final _ProposalTheme theme;
  final int proposal;

  @override
  State<_EventLegacy> createState() => _EventLegacyState();
}

class _EventLegacyState extends State<_EventLegacy> {
  bool _editing = false;
  final _title = TextEditingController(text: 'Cena en Trattoria da Mario');

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final isView = widget.proposal == 2 && !_editing;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        if (widget.proposal == 2)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => setState(() => _editing = !_editing),
              child: Text(
                _editing ? 'Listo' : 'Editar',
                style: TextStyle(color: t.accent, fontSize: 17),
              ),
            ),
          ),
        _SectionLabel(theme: t, title: 'EVENTO'),
        _Card(
          theme: t,
          children: [
            if (isView)
              _SettingsRow(theme: t, label: 'Título', value: _title.text)
            else
              _EditField(theme: t, label: 'Título', controller: _title),
            _Sep(theme: t),
            _SettingsRow(
              theme: t,
              label: 'Cuándo',
              value: 'Jue 18 jul · 20:30',
              chevron: !isView,
            ),
          ],
        ),
      ],
    );
  }
}

class _AccommodationLegacy extends StatefulWidget {
  const _AccommodationLegacy({required this.theme, required this.proposal});
  final _ProposalTheme theme;
  final int proposal;

  @override
  State<_AccommodationLegacy> createState() => _AccommodationLegacyState();
}

class _AccommodationLegacyState extends State<_AccommodationLegacy> {
  bool _editing = false;
  final _name = TextEditingController(text: 'Casa Costa Brava');

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final isView = widget.proposal == 2 && !_editing;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        if (widget.proposal == 2)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => setState(() => _editing = !_editing),
              child: Text(
                _editing ? 'Listo' : 'Editar',
                style: TextStyle(color: t.accent, fontSize: 17),
              ),
            ),
          ),
        _SectionLabel(theme: t, title: 'ALOJAMIENTO'),
        _Card(
          theme: t,
          children: [
            if (isView)
              _SettingsRow(theme: t, label: 'Nombre', value: _name.text)
            else
              _EditField(theme: t, label: 'Nombre', controller: _name),
            _Sep(theme: t),
            _SettingsRow(
              theme: t,
              label: 'Estancia',
              value: '12 jul → 2 ago',
            ),
          ],
        ),
      ],
    );
  }
}
