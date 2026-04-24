import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';

class AccommodationFormDemoV1Page extends StatefulWidget {
  const AccommodationFormDemoV1Page({super.key});

  @override
  State<AccommodationFormDemoV1Page> createState() =>
      _AccommodationFormDemoV1PageState();
}

class _AccommodationFormDemoV1PageState
    extends State<AccommodationFormDemoV1Page> {
  final _formKey = GlobalKey<FormState>();

  final _hotelNameCtrl = TextEditingController(text: 'Shinjuku Granbell Hotel');
  final _addressCtrl = TextEditingController(
      text: '2 Chome-14-5 Kabukicho, Shinjuku City, Tokyo');
  final _descriptionCtrl =
      TextEditingController(text: 'Check-in en recepción principal');
  final _urlCtrl =
      TextEditingController(text: 'https://www.granbellhotel.jp/shinjuku/');
  final _bookingRefCtrl = TextEditingController(text: 'BOOK-9H21-PLN');
  final _costCtrl = TextEditingController(text: '1240');
  final _notesCtrl = TextEditingController();
  final _maxGuestsCtrl = TextEditingController(text: '2');

  final _participants = const ['AG', 'BL', 'CM', 'DS'];
  final Set<String> _selectedParticipants = {'AG', 'BL'};

  DateTime _checkIn = DateTime.now().add(const Duration(days: 7));
  DateTime _checkOut = DateTime.now().add(const Duration(days: 10));
  String _accommodationType = 'Hotel';
  String _color = 'blue';
  String _currency = 'EUR';
  bool _isForAll = false;
  bool _breakfastIncluded = true;
  bool _freeCancellation = true;
  bool _isDraft = false;

  static const _types = [
    'Hotel',
    'Apartamento',
    'Hostal',
    'Casa',
    'Resort',
    'Camping',
    'Crucero',
    'Otro',
  ];
  static const _currencies = ['EUR', 'USD', 'JPY', 'GBP'];

  @override
  void dispose() {
    _hotelNameCtrl.dispose();
    _addressCtrl.dispose();
    _descriptionCtrl.dispose();
    _urlCtrl.dispose();
    _bookingRefCtrl.dispose();
    _costCtrl.dispose();
    _notesCtrl.dispose();
    _maxGuestsCtrl.dispose();
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
                'Formulario alojamiento v1 (demo)',
                style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  children: _generalSections(),
                ),
              ),
              _bottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _generalSections() {
    return [
      _sectionCard(
        title: '1. Tipo y color',
        subtitle: 'Clasificación visual del alojamiento',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _types.map((type) {
                final selected = _accommodationType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: selected,
                  onSelected: (_) => setState(() => _accommodationType = type),
                  selectedColor: AppColorScheme.color2.withValues(alpha: 0.35),
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  side: BorderSide(
                    color: selected
                        ? AppColorScheme.color2
                        : Colors.white.withValues(alpha: 0.12),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _colorChip('blue', 'Azul')),
                const SizedBox(width: 8),
                Expanded(child: _colorChip('green', 'Verde')),
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
        subtitle: 'Nombre, dirección, estancia y detalle principal',
        child: Column(
          children: [
            TextFormField(
              controller: _hotelNameCtrl,
              decoration: _inputDecoration('Nombre alojamiento *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _addressCtrl,
              decoration: _inputDecoration('Dirección'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _pillField(
                    label: 'Check-in',
                    value: _fmtDate(_checkIn),
                    onTap: () => _pickDate(isCheckIn: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _pillField(
                    label: 'Check-out',
                    value: _fmtDate(_checkOut),
                    onTap: () => _pickDate(isCheckIn: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descriptionCtrl,
              decoration: _inputDecoration('Descripción corta'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _urlCtrl,
              decoration: _inputDecoration('URL (web del alojamiento)'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _bookingRefCtrl,
              decoration: _inputDecoration('Código de reserva'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      _sectionCard(
        title: '3. Participación y límites',
        subtitle: 'Quién usa este alojamiento y aforo opcional',
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
              controller: _maxGuestsCtrl,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Límite huéspedes (opcional)'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      _sectionCard(
        title: '4. Coste y condiciones',
        subtitle: 'Importe, moneda y opciones relevantes',
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _costCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecoration('Coste total'),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField<String>(
                    initialValue: _currency,
                    decoration: _inputDecoration('Moneda'),
                    items: _currencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _currency = v ?? _currency),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              value: _breakfastIncluded,
              onChanged: (v) => setState(() => _breakfastIncluded = v),
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColorScheme.color2,
              title: const Text('Incluye desayuno'),
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              value: _freeCancellation,
              onChanged: (v) => setState(() => _freeCancellation = v),
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColorScheme.color2,
              title: const Text('Cancelación flexible'),
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
        title: '5. Notas internas',
        subtitle: 'Información útil para el equipo',
        child: TextFormField(
          controller: _notesCtrl,
          minLines: 3,
          maxLines: 5,
          decoration: _inputDecoration('Notas del alojamiento'),
        ),
      ),
    ];
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
      hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.04),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColorScheme.color2, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
    );
  }

  Widget _colorChip(String value, String label) {
    final selected = _color == value;
    final color = switch (value) {
      'green' => const Color(0xFF16A34A),
      'purple' => const Color(0xFF7C3AED),
      _ => AppColorScheme.color2,
    };
    return InkWell(
      onTap: () => setState(() => _color = value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.30)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
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
              onPressed: _validateDemo,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorScheme.color2,
                foregroundColor: Colors.white,
              ),
              child: const Text('Validar demo'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate({required bool isCheckIn}) async {
    final initialDate = isCheckIn ? _checkIn : _checkOut;
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: initialDate,
    );
    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        if (!_checkOut.isAfter(_checkIn)) {
          _checkOut = _checkIn.add(const Duration(days: 1));
        }
      } else {
        _checkOut = picked.isAfter(_checkIn)
            ? picked
            : _checkIn.add(const Duration(days: 1));
      }
    });
  }

  void _validateDemo() {
    if (_formKey.currentState?.validate() != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Demo de alojamiento validada: estructura visual lista para pasar a real.',
        ),
      ),
    );
  }

  String _fmtDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }
}
