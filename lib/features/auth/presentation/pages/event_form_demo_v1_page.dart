import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';

class EventFormDemoV1Page extends StatefulWidget {
  const EventFormDemoV1Page({super.key});

  @override
  State<EventFormDemoV1Page> createState() => _EventFormDemoV1PageState();
}

class _EventFormDemoV1PageState extends State<EventFormDemoV1Page> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController(text: 'Vuelo Madrid → Tokyo');
  final _descriptionCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _flightNumberCtrl = TextEditingController(text: 'JL042');
  final _departureAirportCtrl = TextEditingController(text: 'Madrid Barajas (MAD)');
  final _arrivalAirportCtrl = TextEditingController(text: 'Tokyo Haneda (HND)');
  final _urlCtrl = TextEditingController(text: 'https://www.jal.co.jp');
  final _costCtrl = TextEditingController(text: '980');
  final _maxParticipantsCtrl = TextEditingController();

  // Mi información (tab/segmento personal en el formulario real).
  final _seatCtrl = TextEditingController(text: '32A');
  final _menuCtrl = TextEditingController(text: 'Vegetariano');
  final _preferencesCtrl = TextEditingController();
  final _reservationCtrl = TextEditingController(text: 'PNR-9F2K');
  final _gateCtrl = TextEditingController(text: 'T4-S');
  final _personalNotesCtrl = TextEditingController();

  final _participants = const ['AG', 'BL', 'CM', 'DS'];
  final Set<String> _selectedParticipants = {'AG', 'BL'};

  DateTime _date = DateTime.now();
  int _hour = 10;
  int _minute = 0;
  int _durationMinutes = 120;
  String _family = 'Desplazamiento';
  String _subtype = 'Avión';
  String _color = 'color2';
  bool _isDraft = false;
  bool _isForAll = true;
  bool _requiresConfirmation = false;
  bool _cardObtained = false;
  String _departureTimezone = 'Europe/Madrid';
  String _arrivalTimezone = 'Asia/Tokyo';
  String _costCurrency = 'EUR';
  bool _showFlightStatus = true;
  int _activeSegment = 0; // 0: General, 1: Mi informacion

  static const _families = ['Desplazamiento', 'Restauración', 'Actividad', 'Acción', 'Otro'];
  static const _subtypes = ['Taxi', 'Avión', 'Tren', 'Autobús', 'Shuttle', 'Transfer'];
  static const _timezones = ['Europe/Madrid', 'Europe/London', 'America/New_York', 'Asia/Tokyo'];
  static const _currencies = ['EUR', 'USD', 'JPY', 'GBP'];

  static const _statusChips = <String, String>{
    'Estado': 'Programado',
    'Salida': '10:20',
    'Llegada': '06:45 (+1)',
    'Duración': '14h 25m',
  };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _notesCtrl.dispose();
    _flightNumberCtrl.dispose();
    _departureAirportCtrl.dispose();
    _arrivalAirportCtrl.dispose();
    _urlCtrl.dispose();
    _costCtrl.dispose();
    _maxParticipantsCtrl.dispose();
    _seatCtrl.dispose();
    _menuCtrl.dispose();
    _preferencesCtrl.dispose();
    _reservationCtrl.dispose();
    _gateCtrl.dispose();
    _personalNotesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: const Color(0xFF111827),
        appBar: AppBar(
          backgroundColor: const Color(0xFF111827),
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'planaz',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    TextSpan(
                      text: 'oo',
                      style: GoogleFonts.poppins(
                        color: AppColorScheme.color2,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Formulario evento v1 (demo)',
                style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: _segmentSwitch(),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  children: _activeSegment == 0 ? _generalDemoSections() : _myInfoDemoSections(),
                ),
              ),
              _bottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _generalDemoSections() {
    return [
      _sectionCard(
        title: '1. Tipo y subtipo (botones)',
        subtitle: 'Mismo patrón visual del formulario real',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Familia', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
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
                  selectedColor: AppColorScheme.color2.withValues(alpha: 0.35),
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  side: BorderSide(
                    color: selected ? AppColorScheme.color2 : Colors.white.withValues(alpha: 0.12),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Text('Subtipo', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _subtypes.map((s) {
                final selected = _subtype == s;
                return ChoiceChip(
                  label: Text(s),
                  selected: selected,
                  onSelected: (_) => setState(() => _subtype = s),
                  selectedColor: AppColorScheme.color2.withValues(alpha: 0.35),
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  side: BorderSide(
                    color: selected ? AppColorScheme.color2 : Colors.white.withValues(alpha: 0.12),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _colorChip('color2', 'Principal')),
                const SizedBox(width: 8),
                Expanded(child: _colorChip('orange', 'Naranja')),
                const SizedBox(width: 8),
                Expanded(child: _colorChip('purple', 'Morado')),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      _sectionCard(
        title: '2. Datos generales',
        subtitle: 'Campos comunes (descripcion, fecha, hora, duracion, notas, url)',
        child: Column(
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: _inputDecoration('Descripcion / titulo *'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Obligatorio';
                if (v.trim().length < 3) return 'Minimo 3 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 10),
            Row(
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
                    label: 'Hora inicio',
                    value: '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}',
                    onTap: _pickTime,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _durationMinutes,
                    decoration: _inputDecoration('Duracion'),
                    items: const [30, 45, 60, 90, 120, 180, 240]
                        .map((m) => DropdownMenuItem(value: m, child: Text('$m min')))
                        .toList(),
                    onChanged: (v) => setState(() => _durationMinutes = v ?? 120),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _notesCtrl,
              minLines: 1,
              maxLines: 3,
              decoration: _inputDecoration('Notas largas / texto agencia'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _urlCtrl,
              decoration: _inputDecoration('URL (web check-in / referencia)'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      _sectionCard(
        title: '3. Desplazamiento · Avión (campos específicos)',
        subtitle: 'Numero de vuelo, aeropuertos, zonas horarias y estado',
        child: Column(
          children: [
            TextFormField(
              controller: _flightNumberCtrl,
              decoration: _inputDecoration('Numero de vuelo *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _departureAirportCtrl,
                    decoration: _inputDecoration('Aeropuerto salida'),
                  ),
                ),
                const SizedBox(width: 8),
                _tzBadge(_departureTimezone),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _arrivalAirportCtrl,
                    decoration: _inputDecoration('Aeropuerto llegada'),
                  ),
                ),
                const SizedBox(width: 8),
                _tzBadge(_arrivalTimezone),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _departureTimezone,
                    decoration: _inputDecoration('TZ salida'),
                    items: _timezones
                        .map((tz) => DropdownMenuItem(value: tz, child: Text(tz)))
                        .toList(),
                    onChanged: (v) => setState(() => _departureTimezone = v ?? _departureTimezone),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _arrivalTimezone,
                    decoration: _inputDecoration('TZ llegada'),
                    items: _timezones
                        .map((tz) => DropdownMenuItem(value: tz, child: Text(tz)))
                        .toList(),
                    onChanged: (v) => setState(() => _arrivalTimezone = v ?? _arrivalTimezone),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _showFlightStatus = !_showFlightStatus),
                icon: const Icon(Icons.travel_explore_outlined),
                label: Text(_showFlightStatus ? 'Ocultar estado vuelo demo' : 'Obtener datos vuelo (demo)'),
              ),
            ),
            if (_showFlightStatus) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColorScheme.color2.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColorScheme.color2.withValues(alpha: 0.45)),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _statusChips.entries
                      .map(
                        (e) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Text(
                            '${e.key}: ${e.value}',
                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 10),
      _sectionCard(
        title: '4. Participación y límites',
        subtitle: 'Alcance, registro y restricciones del evento',
        child: Column(
          children: [
            SwitchListTile(
              value: _isForAll,
              onChanged: (v) => setState(() => _isForAll = v),
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColorScheme.color2,
              title: const Text('Para todos los participantes'),
            ),
            if (!_isForAll) ...[
              const SizedBox(height: 6),
              Wrap(
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
                    selectedColor: AppColorScheme.color2.withValues(alpha: 0.35),
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    label: Text(p),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 8),
            TextFormField(
              controller: _maxParticipantsCtrl,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Limite participantes (opcional)'),
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              value: _requiresConfirmation,
              onChanged: (v) => setState(() => _requiresConfirmation = v),
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColorScheme.color2,
              title: const Text('Requiere confirmacion de asistencia'),
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              value: _isDraft,
              onChanged: (v) => setState(() => _isDraft = v),
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColorScheme.color2,
              title: const Text('Guardar como borrador/propuesta'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      _sectionCard(
        title: '5. Coste',
        subtitle: 'Importe y moneda (campo presente en el formulario real)',
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _costCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration('Coste'),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              child: DropdownButtonFormField<String>(
                initialValue: _costCurrency,
                decoration: _inputDecoration('Moneda'),
                items: _currencies
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _costCurrency = v ?? _costCurrency),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _myInfoDemoSections() {
    return [
      _sectionCard(
        title: 'Mi información (vuelo)',
        subtitle: 'Campos personales de Desplazamiento · Avión',
        child: Column(
          children: [
            TextFormField(controller: _seatCtrl, decoration: _inputDecoration('Asiento')),
            const SizedBox(height: 10),
            TextFormField(controller: _menuCtrl, decoration: _inputDecoration('Menu / comida')),
            const SizedBox(height: 10),
            TextFormField(
              controller: _preferencesCtrl,
              minLines: 1,
              maxLines: 2,
              decoration: _inputDecoration('Preferencias'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _reservationCtrl,
              decoration: _inputDecoration('Numero de reserva'),
            ),
            const SizedBox(height: 10),
            TextFormField(controller: _gateCtrl, decoration: _inputDecoration('Gate / puerta')),
            const SizedBox(height: 10),
            SwitchListTile(
              value: _cardObtained,
              onChanged: (v) => setState(() => _cardObtained = v),
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColorScheme.color2,
              title: const Text('Tarjeta obtenida'),
              subtitle: const Text('Estado personal del embarque'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _personalNotesCtrl,
              minLines: 2,
              maxLines: 3,
              decoration: _inputDecoration('Notas personales'),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColorScheme.color2.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColorScheme.color2.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Esta información es privada y no la ven otros participantes.',
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _segmentSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(child: _segmentButton(0, 'General')),
          const SizedBox(width: 6),
          Expanded(child: _segmentButton(1, 'Mi información')),
        ],
      ),
    );
  }

  Widget _segmentButton(int index, String label) {
    final selected = _activeSegment == index;
    return InkWell(
      onTap: () => setState(() => _activeSegment = index),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColorScheme.color2 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColorScheme.color2 : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.white70,
            ),
          ),
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
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _colorChip(String id, String label) {
    final selected = _color == id;
    final color = switch (id) {
      'orange' => const Color(0xFFA24000),
      'purple' => const Color(0xFF7C3AED),
      _ => AppColorScheme.color2,
    };
    return InkWell(
      onTap: () => setState(() => _color = id),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: selected ? 0.35 : 0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : Colors.white.withValues(alpha: 0.12),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _tzBadge(String timezone) {
    final short = timezone.contains('/')
        ? timezone.split('/').last.substring(0, 3).toUpperCase()
        : timezone.substring(0, 3).toUpperCase();
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColorScheme.color2.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: AppColorScheme.color2.withValues(alpha: 0.7)),
      ),
      alignment: Alignment.center,
      child: Text(
        short,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColorScheme.color2, width: 1.5),
      ),
    );
  }

  Widget _pillField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white60)),
            const SizedBox(height: 2),
            Text(value, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: _validateAndPreview,
              style: ElevatedButton.styleFrom(backgroundColor: AppColorScheme.color2),
              child: const Text('Validar demo vuelo'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
    );
    if (picked != null) {
      setState(() {
        _hour = picked.hour;
        _minute = picked.minute;
      });
    }
  }

  void _validateAndPreview() {
    if (!_formKey.currentState!.validate()) return;
    if (_family != 'Desplazamiento' || _subtype != 'Avión') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta demo esta pensada para Desplazamiento · Avión.')),
      );
      return;
    }
    if (!_isForAll && _selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un participante o marca "Para todos".')),
      );
      return;
    }

    final scope = _isForAll ? 'Todos' : _selectedParticipants.join(', ');
    final msg =
        'OK demo vuelo: ${_flightNumberCtrl.text.trim()} ${_departureAirportCtrl.text.trim()} → ${_arrivalAirportCtrl.text.trim()} · ${_durationMinutes}min · alcance: $scope.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
