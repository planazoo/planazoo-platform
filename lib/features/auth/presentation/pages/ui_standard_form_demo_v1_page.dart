import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';

class UiStandardFormDemoV1Page extends StatefulWidget {
  const UiStandardFormDemoV1Page({super.key});

  @override
  State<UiStandardFormDemoV1Page> createState() =>
      _UiStandardFormDemoV1PageState();
}

class _UiStandardFormDemoV1PageState extends State<UiStandardFormDemoV1Page> {
  static const Color _cPageBg = Color(0xFF111827);
  static const Color _cSurfaceBg = Color(0xFF1F2937);
  static const Color _cTextPrimary = Colors.white;
  static const Color _cTextSecondary = Colors.white70;
  static const Color _cTextTertiary = Colors.white60;
  static const Color _cDanger = Colors.redAccent;
  static const double _aBorderStrong = 0.12;
  static const double _aBorderSoft = 0.10;
  static const double _aBorderSubtle = 0.08;
  static const double _aSurfaceMuted = 0.04;
  static const double _aSurfaceChip = 0.06;
  static const double _aAccentSelected = 0.32;

  // Escala tipografica fija del estandar UI.
  static const double _fsAppBar = 16;
  static const double _fsSectionTitle = 12;
  static const double _fsSectionSubtitle = 11;
  static const double _fsFieldLabel = 12;
  static const double _fsControl = 12;
  static const double _fsValue = 13;

  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _numberCtrl = TextEditingController(text: '150');
  final _notesCtrl = TextEditingController();

  final List<String> _mockFiles = ['reserva.pdf', 'ticket.png'];

  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  String _family = 'Evento';
  String _subtype = 'Actividad';
  String _status = 'Borrador';
  String _currency = 'EUR';
  bool _forAll = true;
  bool _requiresConfirmation = false;
  bool _switchA = true;
  double _priority = 3;
  int _segment = 0;
  final Set<String> _selectedParticipants = {'AG', 'BL'};

  static const _families = ['Evento', 'Alojamiento', 'Pago', 'Otro'];
  static const _subtypes = ['Actividad', 'Vuelo', 'Reunion', 'Traslado'];
  static const _statuses = ['Borrador', 'Confirmado', 'Cancelado'];
  static const _currencies = ['EUR', 'USD', 'JPY'];
  static const _participants = ['AG', 'BL', 'CM', 'DS'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _urlCtrl.dispose();
    _numberCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: _cPageBg,
        appBar: AppBar(
          backgroundColor: _cPageBg,
          title: Text(
            'UI estandar · formulario demo v1',
            style: GoogleFonts.poppins(
              color: _cTextPrimary,
              fontWeight: FontWeight.w600,
              fontSize: _fsAppBar,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  children: [
                    _segmentSwitch(),
                    const SizedBox(height: 10),
                    _identitySection(),
                    const SizedBox(height: 10),
                    _basicFieldsSection(),
                    const SizedBox(height: 10),
                    _dateTimeSection(),
                    const SizedBox(height: 10),
                    _selectorsSection(),
                    const SizedBox(height: 10),
                    _participantsSection(),
                    const SizedBox(height: 10),
                    _filesSection(),
                    const SizedBox(height: 10),
                    _advancedSection(),
                  ],
                ),
              ),
              _bottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _segmentSwitch() {
    return _sectionCard(
      title: 'Segmento',
      subtitle: 'Selector superior de contexto',
      child: Container(
        decoration: BoxDecoration(
          color: _cSurfaceBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _cTextPrimary.withValues(alpha: _aBorderStrong)),
        ),
        child: Row(
          children: [
            _segmentButton('General', 0),
            _segmentButton('Personal', 1),
            _segmentButton('Avanzado', 2),
          ],
        ),
      ),
    );
  }

  Widget _segmentButton(String label, int idx) {
    final selected = _segment == idx;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _segment = idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColorScheme.color2.withValues(alpha: _aAccentSelected)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: selected ? _cTextPrimary : _cTextSecondary,
              fontSize: _fsControl,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _identitySection() {
    return _sectionCard(
      title: 'Identidad',
      subtitle: 'Familia, subtipo, estado y color',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Familia',
            style: GoogleFonts.poppins(fontSize: _fsFieldLabel, color: _cTextSecondary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _families.map((f) {
              final selected = _family == f;
              return ChoiceChip(
                label: Text(f),
                selected: selected,
                onSelected: (_) => setState(() => _family = f),
                selectedColor: AppColorScheme.color2.withValues(alpha: _aAccentSelected),
                backgroundColor: _cTextPrimary.withValues(alpha: _aSurfaceChip),
                side: BorderSide(
                  color: selected
                      ? AppColorScheme.color2
                      : _cTextPrimary.withValues(alpha: _aBorderStrong),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _basicFieldsSection() {
    return _sectionCard(
      title: 'Campos de texto',
      subtitle: 'Single line, multiline, URL y numerico',
      child: Column(
        children: [
          TextFormField(
            controller: _titleCtrl,
            decoration: _inputDecoration('Titulo *'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _descriptionCtrl,
            minLines: 1,
            maxLines: 2,
            decoration: _inputDecoration('Descripcion'),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _urlCtrl,
            keyboardType: TextInputType.url,
            decoration: _inputDecoration('URL'),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _numberCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration('Importe'),
          ),
        ],
      ),
    );
  }

  Widget _dateTimeSection() {
    return _sectionCard(
      title: 'Fecha y hora',
      subtitle: 'Pickers y duracion',
      child: Row(
        children: [
          Expanded(
            child: _pillField(
              label: 'Fecha',
              value:
                  '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
              onTap: _pickDate,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _pillField(
              label: 'Hora',
              value:
                  '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
              onTap: _pickTime,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: _inputDecoration('Estado'),
              style: _dropdownTextStyle(),
              items: _statuses
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(s, style: _dropdownTextStyle()),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectorsSection() {
    return _sectionCard(
      title: 'Selectores',
      subtitle: 'Dropdown, radio, switch, checkbox, slider',
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _subtype,
            decoration: _inputDecoration('Subtipo'),
            style: _dropdownTextStyle(),
            items: _subtypes
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s, style: _dropdownTextStyle()),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _subtype = v ?? _subtype),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _currency,
            decoration: _inputDecoration('Moneda'),
            style: _dropdownTextStyle(),
            items: _currencies
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(c, style: _dropdownTextStyle()),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _currency = v ?? _currency),
          ),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColorScheme.color2.withValues(alpha: _aAccentSelected);
                }
                return _cTextPrimary.withValues(alpha: _aSurfaceChip);
              }),
              foregroundColor: const WidgetStatePropertyAll(_cTextPrimary),
              side: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const BorderSide(color: AppColorScheme.color2);
                }
                return BorderSide(color: _cTextPrimary.withValues(alpha: _aBorderStrong));
              }),
            ),
            segments: const [
              ButtonSegment<bool>(value: true, label: Text('Modo A')),
              ButtonSegment<bool>(value: false, label: Text('Modo B')),
            ],
            selected: {_switchA},
            onSelectionChanged: (value) {
              if (value.isEmpty) return;
              setState(() => _switchA = value.first);
            },
          ),
          SwitchListTile(
            value: _forAll,
            onChanged: (v) => setState(() => _forAll = v),
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColorScheme.color2,
            title: const Text('Aplicar a todos'),
          ),
          CheckboxListTile(
            value: _requiresConfirmation,
            onChanged: (v) => setState(() => _requiresConfirmation = v ?? false),
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: AppColorScheme.color2,
            title: const Text('Requiere confirmacion'),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.low_priority, size: 18, color: _cTextSecondary),
              Expanded(
                child: Slider(
                  value: _priority,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  activeColor: AppColorScheme.color2,
                  label: _priority.toStringAsFixed(0),
                  onChanged: (v) => setState(() => _priority = v),
                ),
              ),
              Text(
                _priority.toStringAsFixed(0),
                style: GoogleFonts.poppins(color: _cTextPrimary, fontSize: _fsValue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _participantsSection() {
    return _sectionCard(
      title: 'Chips / participantes',
      subtitle: 'ChoiceChip + FilterChip',
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: _participants.map((p) {
          final selected = _selectedParticipants.contains(p);
          return FilterChip(
            selected: selected,
            onSelected: (on) {
              setState(() {
                if (on) {
                  _selectedParticipants.add(p);
                } else {
                  _selectedParticipants.remove(p);
                }
              });
            },
            selectedColor: AppColorScheme.color2.withValues(alpha: _aAccentSelected),
            backgroundColor: _cTextPrimary.withValues(alpha: _aSurfaceChip),
            side: BorderSide(
              color: selected
                  ? AppColorScheme.color2
                  : _cTextPrimary.withValues(alpha: _aBorderStrong),
            ),
            label: Text(p),
          );
        }).toList(),
      ),
    );
  }

  Widget _filesSection() {
    return _sectionCard(
      title: 'Carga de archivos (demo)',
      subtitle: 'Adjuntar, listar y eliminar',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _mockFiles.add('archivo_${_mockFiles.length + 1}.pdf');
              });
            },
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Adjuntar archivo'),
          ),
          const SizedBox(height: 8),
          if (_mockFiles.isEmpty)
            Text(
              'No hay archivos',
              style: GoogleFonts.poppins(color: _cTextTertiary, fontSize: _fsFieldLabel),
            ),
          ..._mockFiles.map((f) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: _cTextPrimary.withValues(alpha: _aSurfaceMuted),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _cTextPrimary.withValues(alpha: _aBorderSoft)),
              ),
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.attach_file, color: _cTextSecondary),
                title: Text(
                  f,
                  style: GoogleFonts.poppins(color: _cTextPrimary, fontSize: _fsValue),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: _cDanger),
                  onPressed: () => setState(() => _mockFiles.remove(f)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _advancedSection() {
    return _sectionCard(
      title: 'Notas largas',
      subtitle: 'Textarea de soporte',
      child: TextFormField(
        controller: _notesCtrl,
        minLines: 3,
        maxLines: 5,
        decoration: _inputDecoration('Notas internas'),
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: _cPageBg,
        border: Border(top: BorderSide(color: _cTextPrimary.withValues(alpha: _aBorderSubtle))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() != true) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Formulario demo validado')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorScheme.color2,
                foregroundColor: _cTextPrimary,
              ),
              child: const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: _fsFieldLabel, color: _cTextSecondary),
      hintStyle: GoogleFonts.poppins(fontSize: _fsFieldLabel, color: _cTextTertiary),
      filled: true,
      fillColor: _cTextPrimary.withValues(alpha: _aSurfaceMuted),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _cTextPrimary.withValues(alpha: _aBorderStrong)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColorScheme.color2, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  TextStyle _dropdownTextStyle() {
    return GoogleFonts.poppins(
      fontSize: _fsValue,
      color: _cTextPrimary,
      fontWeight: FontWeight.w500,
    );
  }

  Widget _pillField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _inputDecoration(label),
        child: Text(
          value,
          style: GoogleFonts.poppins(color: _cTextPrimary, fontSize: _fsValue),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cSurfaceBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cTextPrimary.withValues(alpha: _aBorderStrong)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: _fsSectionTitle,
              fontWeight: FontWeight.w600,
              color: _cTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: _fsSectionSubtitle,
              color: _cTextTertiary,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _date,
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked == null) return;
    setState(() => _time = picked);
  }
}

