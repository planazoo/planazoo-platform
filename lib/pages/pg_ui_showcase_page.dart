import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/theme/color_scheme.dart';
import '../app/theme/typography.dart';

/// Página de demostración de diferentes estilos de UI "de lujo"
/// Permite comparar diferentes variantes de diseño
class UIShowcasePage extends StatefulWidget {
  const UIShowcasePage({super.key});

  @override
  State<UIShowcasePage> createState() => _UIShowcasePageState();
}

class _UIShowcasePageState extends State<UIShowcasePage> {
  int _selectedStyle = 0; // 0: Minimalista, 1: Sofisticado, 2: Clásico, 3: Moderno

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade800,
          title: const Text('UI Showcase - Estilos de Lujo (Modo Oscuro)'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildStyleButton(0, 'Minimalista', Icons.auto_awesome),
                  const SizedBox(width: 8),
                  _buildStyleButton(1, 'Sofisticado', Icons.layers),
                  const SizedBox(width: 8),
                  _buildStyleButton(2, 'Clásico', Icons.account_balance),
                  const SizedBox(width: 8),
                  _buildStyleButton(3, 'Moderno', Icons.bolt),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Formularios'),
              const SizedBox(height: 16),
              _buildFormSection(),
              const SizedBox(height: 32),
              _buildSectionTitle('Botones'),
              const SizedBox(height: 16),
              _buildButtonsSection(),
              const SizedBox(height: 32),
              _buildSectionTitle('Tarjetas'),
              const SizedBox(height: 16),
              _buildCardsSection(),
              const SizedBox(height: 32),
              _buildSectionTitle('Listas'),
              const SizedBox(height: 16),
              _buildListsSection(),
              const SizedBox(height: 32),
              _buildSectionTitle('Tipografía'),
              const SizedBox(height: 16),
              _buildTypographySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyleButton(int index, String label, IconData icon) {
    final isSelected = _selectedStyle == index;
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () => setState(() => _selectedStyle = index),
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColorScheme.color2 : Colors.grey.shade800,
          foregroundColor: isSelected ? Colors.white : Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    switch (_selectedStyle) {
      case 0: // Minimalista
        return Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        );
      case 1: // Sofisticado
        return Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        );
      case 2: // Clásico
        return Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        );
      case 3: // Moderno
        return Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        );
      default:
        return Text(title, style: AppTypography.mediumTitle.copyWith(color: Colors.white));
    }
  }

  Widget _buildFormSection() {
    return Column(
      children: [
        _buildTextField('Nombre del plan', 'Ej: Viaje a París'),
        const SizedBox(height: 16),
        _buildDropdownField('Moneda', ['EUR', 'USD', 'GBP']),
        const SizedBox(height: 16),
        _buildCheckboxField('Plan privado', false),
      ],
    );
  }

  Widget _buildTextField(String label, String hint) {
    switch (_selectedStyle) {
      case 0: // Minimalista
        return TextField(
          style: GoogleFonts.inter(fontSize: 15, color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            labelStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400),
            hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade700),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade700),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColorScheme.color2, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        );
      case 1: // Sofisticado
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade800,
                const Color(0xFF2C2C2C), // Gris más oscuro para gradiente
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade700.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 1),
                spreadRadius: -2,
              ),
            ],
          ),
          child: TextField(
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.white,
              letterSpacing: 0.1,
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              labelStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade500,
                letterSpacing: 0.1,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColorScheme.color2,
                  width: 2.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            ),
          ),
        );
      case 2: // Clásico
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            border: Border.all(color: Colors.grey.shade700, width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              labelStyle: GoogleFonts.merriweather(fontSize: 13, color: Colors.grey.shade400),
              hintStyle: GoogleFonts.merriweather(fontSize: 14, color: Colors.grey.shade600),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
          ),
        );
      case 3: // Moderno
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade800, Colors.grey.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade700, width: 1),
          ),
          child: TextField(
            style: GoogleFonts.spaceGrotesk(fontSize: 15, color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              labelStyle: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade400),
              hintStyle: GoogleFonts.spaceGrotesk(fontSize: 14, color: Colors.grey.shade600),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        );
      default:
        return TextField(decoration: InputDecoration(labelText: label, hintText: hint));
    }
  }

  Widget _buildDropdownField(String label, List<String> options) {
    String? selectedValue = options.first;
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: _getInputDecoration(label),
      items: options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
      onChanged: (value) {},
    );
  }

  InputDecoration _getInputDecoration(String label) {
    switch (_selectedStyle) {
      case 0: // Minimalista
        return InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade700),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade700),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColorScheme.color2, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        );
      case 1: // Sofisticado
        return InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: AppColorScheme.color2,
              width: 2.5,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        );
      case 2: // Clásico
        return InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.merriweather(fontSize: 13, color: Colors.grey.shade400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey.shade700, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey.shade700, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey.shade500, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade800,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        );
      case 3: // Moderno
        return InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade700),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade700),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColorScheme.color2, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade800,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        );
      default:
        return InputDecoration(labelText: label);
    }
  }

  Widget _buildCheckboxField(String label, bool value) {
    return CheckboxListTile(
      title: Text(label, style: _getBodyTextStyle()),
      value: value,
      onChanged: (val) {},
      contentPadding: EdgeInsets.zero,
    );
  }

  TextStyle _getBodyTextStyle() {
    switch (_selectedStyle) {
      case 0:
        return GoogleFonts.inter(fontSize: 15, color: Colors.white);
      case 1:
        return GoogleFonts.poppins(fontSize: 15, color: Colors.white);
      case 2:
        return GoogleFonts.merriweather(fontSize: 15, color: Colors.white);
      case 3:
        return GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white);
      default:
        return AppTypography.bodyStyle.copyWith(color: Colors.white);
    }
  }

  Widget _buildButtonsSection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildPrimaryButton(),
        _buildSecondaryButton(),
        _buildIconButton(),
      ],
    );
  }

  Widget _buildPrimaryButton() {
    switch (_selectedStyle) {
      case 0: // Minimalista
        return ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey.shade900,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: Text('Guardar', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
        );
      case 1: // Sofisticado
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColorScheme.color2,
                AppColorScheme.color2.withOpacity(0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColorScheme.color2.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: -2,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Text(
              'Guardar',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        );
      case 2: // Clásico
        return ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade800,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            elevation: 2,
          ),
          child: Text('Guardar', style: GoogleFonts.merriweather(fontSize: 15, fontWeight: FontWeight.w700)),
        );
      case 3: // Moderno
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColorScheme.color2, AppColorScheme.color2.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColorScheme.color2.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text('Guardar', style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        );
      default:
        return ElevatedButton(onPressed: () {}, child: const Text('Guardar'));
    }
  }

  Widget _buildSecondaryButton() {
    switch (_selectedStyle) {
      case 0: // Minimalista
        return OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: BorderSide(color: Colors.grey.shade600, width: 1.5),
          ),
          child: Text('Cancelar', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500)),
        );
      case 1: // Sofisticado
        return OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColorScheme.color2,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            side: BorderSide(
              color: AppColorScheme.color2.withOpacity(0.7),
              width: 2,
            ),
          ),
          child: Text(
            'Cancelar',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        );
      case 2: // Clásico
        return OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: BorderSide(color: Colors.grey.shade600, width: 1.5),
          ),
          child: Text('Cancelar', style: GoogleFonts.merriweather(fontSize: 15, fontWeight: FontWeight.w600)),
        );
      case 3: // Moderno
        return OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColorScheme.color2,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            side: BorderSide(color: AppColorScheme.color2, width: 2),
          ),
          child: Text('Cancelar', style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700)),
        );
      default:
        return OutlinedButton(onPressed: () {}, child: const Text('Cancelar'));
    }
  }

  Widget _buildIconButton() {
    return IconButton(
      onPressed: () {},
      icon: const Icon(Icons.favorite),
      style: IconButton.styleFrom(
        backgroundColor: _selectedStyle == 1 || _selectedStyle == 3
            ? AppColorScheme.color2.withOpacity(0.2)
            : Colors.grey.shade800,
        foregroundColor: AppColorScheme.color2,
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildCardsSection() {
    return Column(
      children: [
        _buildCard('Plan: Viaje a París', '3 participantes • 5 días', Icons.calendar_today),
        const SizedBox(height: 16),
        _buildCard('Evento: Vuelo IB3412', '15:30 - 17:45', Icons.flight),
      ],
    );
  }

  Widget _buildCard(String title, String subtitle, IconData icon) {
    switch (_selectedStyle) {
      case 0: // Minimalista
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            border: Border.all(color: Colors.grey.shade700, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey.shade400, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400)),
                  ],
                ),
              ),
            ],
          ),
        );
      case 1: // Sofisticado
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade800,
                const Color(0xFF2C2C2C), // Gris más oscuro para gradiente
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.grey.shade700.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 24,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 2),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorScheme.color2.withOpacity(0.25),
                      AppColorScheme.color2.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColorScheme.color2.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: AppColorScheme.color2, size: 24),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case 2: // Clásico
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            border: Border.all(color: Colors.grey.shade700, width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey.shade400, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.merriweather(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: GoogleFonts.merriweather(fontSize: 14, color: Colors.grey.shade400)),
                  ],
                ),
              ),
            ],
          ),
        );
      case 3: // Moderno
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade800, Colors.grey.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade700, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColorScheme.color2, AppColorScheme.color2.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade400)),
                  ],
                ),
              ),
            ],
          ),
        );
      default:
        return Card(child: ListTile(title: Text(title), subtitle: Text(subtitle)));
    }
  }

  Widget _buildListsSection() {
    final items = ['Participante 1', 'Participante 2', 'Participante 3'];
    return Column(
      children: items.map((item) => _buildListItem(item)).toList(),
    );
  }

  Widget _buildListItem(String title) {
    switch (_selectedStyle) {
      case 0: // Minimalista
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade700, width: 1)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade700,
                child: Text(title[0], style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: GoogleFonts.inter(fontSize: 15, color: Colors.white)),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade500, size: 20),
            ],
          ),
        );
      case 1: // Sofisticado
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade800,
                const Color(0xFF2C2C2C), // Gris más oscuro para gradiente
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade700.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 1),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorScheme.color2.withOpacity(0.25),
                      AppColorScheme.color2.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColorScheme.color2.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    title[0],
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColorScheme.color2,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
                size: 22,
              ),
            ],
          ),
        );
      case 2: // Clásico
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade700, width: 1.5)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade700,
                child: Text(title[0], style: GoogleFonts.merriweather(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: GoogleFonts.merriweather(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade500, size: 20),
            ],
          ),
        );
      case 3: // Moderno
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade800, Colors.grey.shade900],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade700, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColorScheme.color2, AppColorScheme.color2.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(title[0], style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
              Icon(Icons.arrow_forward_ios, color: AppColorScheme.color2, size: 16),
            ],
          ),
        );
      default:
        return ListTile(title: Text(title));
    }
  }

  Widget _buildTypographySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTypographyExample('Título Grande', 32, FontWeight.bold),
        const SizedBox(height: 8),
        _buildTypographyExample('Título', 24, FontWeight.bold),
        const SizedBox(height: 8),
        _buildTypographyExample('Subtítulo', 20, FontWeight.w600),
        const SizedBox(height: 8),
        _buildTypographyExample('Texto de cuerpo', 16, FontWeight.normal),
        const SizedBox(height: 8),
        _buildTypographyExample('Texto pequeño', 14, FontWeight.normal),
        const SizedBox(height: 8),
        _buildTypographyExample('Caption', 12, FontWeight.normal),
      ],
    );
  }

  Widget _buildTypographyExample(String text, double size, FontWeight weight) {
    TextStyle style;
    switch (_selectedStyle) {
      case 0: // Minimalista
        style = GoogleFonts.inter(fontSize: size, fontWeight: weight, color: Colors.white, letterSpacing: -0.5);
        break;
      case 1: // Sofisticado
        style = GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: Colors.white);
        break;
      case 2: // Clásico
        style = GoogleFonts.merriweather(fontSize: size, fontWeight: weight, color: Colors.white);
        break;
      case 3: // Moderno
        style = GoogleFonts.spaceGrotesk(fontSize: size, fontWeight: weight, color: Colors.white, letterSpacing: 0.5);
        break;
      default:
        style = TextStyle(fontSize: size, fontWeight: weight, color: Colors.white);
    }
    return Text('$text (${size}px)', style: style);
  }
}

