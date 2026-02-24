import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/theme/color_scheme.dart';
import '../app/theme/typography.dart';

/// Página de demostración del estilo principal de la app (oscuro y propuesta claro).
/// Regla: en elementos seleccionados (cards de plan, filtros, toggle vista, etc.) los iconos
/// y textos de estado (ej. "Borrador") han de ser claramente visibles (contraste adecuado).
class UIShowcasePage extends StatefulWidget {
  const UIShowcasePage({super.key});

  @override
  State<UIShowcasePage> createState() => _UIShowcasePageState();
}

class _UIShowcasePageState extends State<UIShowcasePage> {
  // 0: Estilo oscuro principal de la app
  // 1: Propuesta de estilo claro
  int _selectedStyle = 0;
  bool _showCalendarView = false;

  @override
  Widget build(BuildContext context) {
    final isDark = _selectedStyle == 0;

    return Theme(
      data: isDark
          ? ThemeData.dark().copyWith(
              scaffoldBackgroundColor: Colors.grey.shade900,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColorScheme.color2,
                brightness: Brightness.dark,
                background: Colors.grey.shade900,
              ),
            )
          : ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: AppColorScheme.color0,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColorScheme.color2,
                brightness: Brightness.light,
                background: AppColorScheme.color0,
              ),
            ),
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey.shade900 : AppColorScheme.color0,
        appBar: AppBar(
          backgroundColor: isDark ? Colors.grey.shade800 : AppColorScheme.color1,
          title: const Text('UI Showcase – Estilo principal y claro'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildStyleButton(0, 'Oscuro (principal)', Icons.dark_mode),
                  const SizedBox(width: 8),
                  _buildStyleButton(1, 'Claro (propuesta)', Icons.light_mode),
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
              _buildSectionTitle('Cards de plan (seleccionada / no seleccionada)'),
              const SizedBox(height: 16),
              _buildPlanCardsSection(),
              const SizedBox(height: 32),
              _buildSectionTitle('Botón crear plan'),
              const SizedBox(height: 16),
              _buildCreatePlanButtonSection(),
              const SizedBox(height: 32),
              _buildSectionTitle('Filtros del dashboard (W26)'),
              const SizedBox(height: 16),
              _buildDashboardFiltersSection(),
              const SizedBox(height: 32),
              _buildSectionTitle('Vista Lista / Calendario (W27)'),
              const SizedBox(height: 16),
              _buildViewModeToggleSection(),
              const SizedBox(height: 32),
              _buildSectionTitle('Botones de acción (primario color3 / secundario color2)'),
              const SizedBox(height: 16),
              _buildActionButtonsSection(),
              const SizedBox(height: 32),
              _buildSectionTitle('Más controles (TextButton, peligro, badge, iconos)'),
              const SizedBox(height: 16),
              _buildExtraControlsSection(),
              const SizedBox(height: 32),
              _buildSectionTitle('Barras inferiores (SnackBar estándar)'),
              const SizedBox(height: 16),
              _buildSnackBarSection(context),
              const SizedBox(height: 32),
              _buildSectionTitle('Panel W31 estándar (barra superior + contenido)'),
              const SizedBox(height: 16),
              _buildW31PanelStandard(),
              const SizedBox(height: 32),
              _buildSectionTitle('Chat (input + burbujas de mensaje)'),
              const SizedBox(height: 16),
              _buildChatSection(),
              const SizedBox(height: 32),
              _buildSectionTitle('Barra guardar y aviso (estándar)'),
              const SizedBox(height: 16),
              _buildSaveBarAndWarningSection(),
              const SizedBox(height: 32),
              _buildSectionTitle('Modales y diálogos'),
              const SizedBox(height: 16),
              _buildModalsSection(context),
              const SizedBox(height: 32),
              _buildSectionTitle('Tarjetas'),
              const SizedBox(height: 16),
              _buildCardsSection(),
              const SizedBox(height: 32),
              _buildSectionTitle('Card de sección (estándar, gradiente radius 18)'),
              const SizedBox(height: 16),
              _buildSectionCardStandard(),
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
    final isDark = index == 0;
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () => setState(() => _selectedStyle = index),
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? AppColorScheme.color2
              : (isDark ? Colors.grey.shade800 : AppColorScheme.color1),
          foregroundColor: isSelected ? Colors.white : (isDark ? Colors.grey.shade300 : AppColorScheme.bodyColor),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildModalsSection(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton(
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: const Text('Confirmar acción'),
                  content: const Text('¿Seguro que quieres guardar los cambios del plan?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Guardar'),
                    ),
                  ],
                );
              },
            );
          },
          child: const Text('Abrir diálogo de confirmación'),
        ),
        OutlinedButton(
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (ctx) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Acciones rápidas del plan',
                        style: AppTypography.mediumTitle,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.person_add),
                        title: const Text('Invitar participantes'),
                        onTap: () => Navigator.of(ctx).pop(),
                      ),
                      ListTile(
                        leading: const Icon(Icons.event),
                        title: const Text('Crear evento'),
                        onTap: () => Navigator.of(ctx).pop(),
                      ),
                      ListTile(
                        leading: const Icon(Icons.notifications),
                        title: const Text('Publicar aviso'),
                        onTap: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: const Text('Abrir hoja inferior (bottom sheet)'),
        ),
      ],
    );
  }

  bool get _isDark => _selectedStyle == 0;

  Color _sectionColor() => _isDark ? Colors.white : AppColorScheme.bodyColor;

  /// Cards de plan: estilo PlanCardWidget (seleccionada = color2, no seleccionada = grey800).
  Widget _buildPlanCardsSection() {
    final unselectedBg = _isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final selectedBg = AppColorScheme.color2;
    final textPrimary = _isDark ? Colors.white : AppColorScheme.bodyColor;
    final textSecondary = _isDark ? Colors.white.withOpacity(0.95) : AppColorScheme.bodyColor.withOpacity(0.8);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'No seleccionada',
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: _sectionColor()),
        ),
        const SizedBox(height: 6),
        _buildPlanCardMock(
          title: 'Viaje a París',
          subtitle: '15 mar - 22 mar • 7 días',
          participants: 3,
          isSelected: false,
          bgColor: unselectedBg,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        const SizedBox(height: 16),
        Text(
          'Seleccionada',
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: _sectionColor()),
        ),
        const SizedBox(height: 6),
        _buildPlanCardMock(
          title: 'Buenos Aires Marzo 2026',
          subtitle: '23 mar - 29 mar • 6 días',
          participants: 2,
          isSelected: true,
          bgColor: selectedBg,
          textPrimary: Colors.white,
          textSecondary: Colors.white.withOpacity(0.9),
        ),
      ],
    );
  }

  Widget _buildPlanCardMock({
    required String title,
    required String subtitle,
    required int participants,
    required bool isSelected,
    required Color bgColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    // En elementos seleccionados (fondo color2): iconos y textos como estado han de ser visibles (contraste claro).
    final iconColor = isSelected ? Colors.white : AppColorScheme.color2.withOpacity(0.6);
    final iconBgColor = isSelected ? Colors.white.withOpacity(0.2) : AppColorScheme.color2.withOpacity(0.2);
    final stateTextColor = isSelected ? Colors.white : AppColorScheme.color2;
    final stateBgColor = isSelected ? Colors.white.withOpacity(0.25) : AppColorScheme.color2.withOpacity(0.2);
    final stateBorderColor = isSelected ? Colors.white.withOpacity(0.4) : AppColorScheme.color2.withOpacity(0.4);

    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: Colors.white.withOpacity(0.25), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isSelected ? 0.35 : 0.2),
            blurRadius: isSelected ? 10 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.image, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                ),
                Text(
                  'Participantes: $participants',
                  style: GoogleFonts.poppins(color: textSecondary, fontSize: 10, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: stateBgColor,
                    border: Border.all(color: stateBorderColor, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Borrador',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: stateTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Botón crear plan: circular color3 con "+" (estilo W3).
  Widget _buildCreatePlanButtonSection() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColorScheme.color3,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColorScheme.color3.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '+',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Crear plan (W3)',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: _sectionColor(),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Filtros: Todos | Estoy in | Pendientes | Cerrados (uno seleccionado).
  Widget _buildDashboardFiltersSection() {
    const filters = ['Todos', 'Estoy in', 'Pendientes', 'Cerrados'];
    const selectedIndex = 0;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(filters.length, (i) {
        final isSelected = i == selectedIndex;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorScheme.color2,
                      AppColorScheme.color2.withOpacity(0.85),
                    ],
                  )
                : null,
            color: isSelected ? null : (_isDark ? Colors.grey.shade700 : Colors.grey.shade400),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColorScheme.color2.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            filters[i],
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : (_isDark ? Colors.grey.shade400 : Colors.grey.shade800),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        );
      }),
    );
  }

  /// Toggle Lista / Calendario (W27).
  Widget _buildViewModeToggleSection() {
    return Container(
      decoration: BoxDecoration(
        color: _isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewModeChip(
            label: 'Lista',
            icon: Icons.view_list_outlined,
            selected: !_showCalendarView,
            onTap: () => setState(() => _showCalendarView = false),
          ),
          _buildViewModeChip(
            label: 'Calendario',
            icon: Icons.calendar_month_outlined,
            selected: _showCalendarView,
            onTap: () => setState(() => _showCalendarView = true),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? AppColorScheme.color2 : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? Colors.white : (_isDark ? Colors.grey.shade400 : Colors.grey.shade700),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : (_isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Botones de acción: primario (color3) y secundario (color2).
  Widget _buildActionButtonsSection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColorScheme.color3,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            shadowColor: AppColorScheme.color3.withOpacity(0.4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, size: 20),
              const SizedBox(width: 8),
              Text('Crear plan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColorScheme.color2,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_add, size: 20),
              const SizedBox(width: 8),
              Text('Invitar', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColorScheme.color2,
            side: BorderSide(color: AppColorScheme.color2, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('Cancelar', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
        ),
      ],
    );
  }

  /// Barra de guardar (color2) + botón "Cancelar cambios" naranja + aviso solo lectura (fondo oscuro).
  Widget _buildSaveBarAndWarningSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColorScheme.color2,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.orange.shade300),
                  foregroundColor: Colors.orange.shade200,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Cancelar cambios', style: GoogleFonts.poppins(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save_outlined, size: 18),
                label: Text('Guardar', style: GoogleFonts.poppins(fontSize: 12)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isDark ? Colors.grey.shade800 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isDark ? Colors.orange.shade700 : Colors.orange.shade200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: _isDark ? Colors.orange.shade300 : Colors.orange.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Este plan tiene restricciones de edición según su estado.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: _isDark ? Colors.orange.shade200 : Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Card de sección estándar: gradiente grey800 → 2C2C2C, radius 18, sombra (Info del plan).
  Widget _buildSectionCardStandard() {
    const cardEnd = Color(0xFF2C2C2C);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _isDark ? Colors.grey.shade800 : Colors.grey.shade300,
            _isDark ? cardEnd : Colors.grey.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isDark ? Colors.grey.shade700.withOpacity(0.5) : Colors.grey.shade500,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isDark ? 0.4 : 0.15),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(_isDark ? 0.2 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información detallada',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _isDark ? Colors.white : AppColorScheme.bodyColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Contenido de la sección. Estilo estándar para bloques tipo Info del plan.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: _isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// TextButton, botón peligro (Salir/Eliminar), badge Invitación, iconos solos (estilo app).
  Widget _buildExtraControlsSection() {
    final fgMuted = _isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    return Wrap(
      spacing: 12,
      runSpacing: 16,
      children: [
        TextButton(
          onPressed: () {},
          child: Text('Ver más', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColorScheme.color2)),
        ),
        TextButton.icon(
          onPressed: () {},
          icon: Icon(Icons.info_outline, size: 18, color: AppColorScheme.color2),
          label: Text('Ayuda', style: GoogleFonts.poppins(fontSize: 14, color: AppColorScheme.color2)),
        ),
        const SizedBox(width: 24),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade700,
            side: BorderSide(color: Colors.red.shade400, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.exit_to_app, size: 18, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Text('Salir del plan', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.red.shade700)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.shade400,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mail_outline, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text('Invitación', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.palette, color: AppColorScheme.color2),
          style: IconButton.styleFrom(
            backgroundColor: _isDark ? Colors.grey.shade800 : AppColorScheme.color1.withOpacity(0.5),
          ),
          tooltip: 'UI Showcase',
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications_outlined, color: fgMuted),
          tooltip: 'Notificaciones',
        ),
      ],
    );
  }

  /// Barras inferiores estándar: éxito (verde), error (rojo), aviso (naranja). Uso: ScaffoldMessenger.showSnackBar.
  Widget _buildSnackBarSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Al completar una acción o mostrar un mensaje de error, usar SnackBar con el estilo siguiente.',
          style: GoogleFonts.poppins(fontSize: 14, color: _isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Plan guardado correctamente', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                    backgroundColor: Colors.green.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Mostrar éxito'),
              style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700),
            ),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al guardar. Inténtalo de nuevo.', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.error_outline, size: 18),
              label: const Text('Mostrar error'),
              style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            ),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tienes cambios sin guardar', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                    backgroundColor: Colors.orange.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.warning_amber_outlined, size: 18),
              label: const Text('Mostrar aviso'),
              style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade700),
            ),
          ],
        ),
      ],
    );
  }

  /// Modelo estándar de panel W31: barra superior (color2, nombre de sección + iconos) + área de contenido.
  /// Inspirado en Stats y Calendario: misma barra para todas las vistas del panel derecho.
  Widget _buildW31PanelStandard() {
    return Container(
      decoration: BoxDecoration(
        color: _isDark ? Colors.grey.shade900 : AppColorScheme.color0,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isDark ? Colors.grey.shade700 : Colors.grey.shade300, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra superior W31: nombre de sección + acciones (iconos)
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: AppColorScheme.color2,
            child: Row(
              children: [
                Text(
                  'Nombre de la sección',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
                  tooltip: 'Actualizar',
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
                  tooltip: 'Más opciones',
                ),
              ],
            ),
          ),
          // Área de contenido
          Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.topLeft,
            child: Text(
              'Contenido del panel. Aquí va la vista específica (Stats, Calendario, Resumen, etc.). La barra superior es común: color2, título centrado o a la izquierda, iconos de acción a la derecha.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Input de chat estándar: barra inferior con campo tipo pill (grey800, radius 24) + botón enviar circular color2.
  /// Burbujas: mensaje propio (color2, derecha), mensaje recibido (grey800, izquierda). Poppins 15.
  Widget _buildChatSection() {
    return Container(
      decoration: BoxDecoration(
        color: _isDark ? Colors.grey.shade900 : AppColorScheme.color0,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isDark ? Colors.grey.shade700 : Colors.grey.shade300, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ejemplo de burbujas
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mensaje recibido de otro participante.',
                          style: GoogleFonts.poppins(fontSize: 15, color: _isDark ? Colors.white : Colors.grey.shade900, height: 1.4),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '10:30',
                          style: GoogleFonts.poppins(fontSize: 11, color: (_isDark ? Colors.white : Colors.grey.shade700).withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColorScheme.color2,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Mensaje propio (color2).',
                          style: GoogleFonts.poppins(fontSize: 15, color: Colors.white, height: 1.4),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '10:32',
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Input de chat
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _isDark ? Colors.grey.shade900 : AppColorScheme.color0,
              border: Border(top: BorderSide(color: _isDark ? Colors.grey.shade700 : Colors.grey.shade400, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        hintStyle: GoogleFonts.poppins(fontSize: 15, color: Colors.grey.shade500),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      style: GoogleFonts.poppins(fontSize: 15, color: _isDark ? Colors.white : Colors.grey.shade900, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColorScheme.color2,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {},
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _sectionColor(),
        letterSpacing: 0.1,
      ),
    );
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
    if (_isDark) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade700.withOpacity(0.5), width: 1),
        ),
        child: TextField(
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
            hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColorScheme.color2, width: 2.5),
            ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          ),
        ),
      );
    }
    return TextField(
      style: GoogleFonts.poppins(fontSize: 15, color: AppColorScheme.bodyColor),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500),
        filled: true,
        fillColor: AppColorScheme.color0,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColorScheme.color2, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
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
    if (_isDark) {
      return InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColorScheme.color2, width: 2.5),
        ),
        filled: true,
        fillColor: Colors.grey.shade800,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      );
    }
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
      filled: true,
      fillColor: AppColorScheme.color0,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColorScheme.color2, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
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
    return GoogleFonts.poppins(
      fontSize: 15,
      color: _isDark ? Colors.white : AppColorScheme.bodyColor,
    );
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
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorScheme.color2,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: _isDark ? 0 : 2,
        shadowColor: AppColorScheme.color2.withOpacity(0.3),
      ),
      child: Text('Guardar', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildSecondaryButton() {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColorScheme.color2,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(
          color: AppColorScheme.color2.withOpacity(_isDark ? 0.7 : 1),
          width: 2,
        ),
      ),
      child: Text('Cancelar', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildIconButton() {
    return IconButton(
      onPressed: () {},
      icon: const Icon(Icons.favorite),
      style: IconButton.styleFrom(
        backgroundColor: _isDark ? Colors.grey.shade800 : AppColorScheme.color2.withOpacity(0.15),
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
    final bg = _isDark ? Colors.grey.shade800 : AppColorScheme.color1.withOpacity(0.4);
    final titleColor = _isDark ? Colors.white : AppColorScheme.bodyColor;
    final subColor = _isDark ? Colors.grey.shade400 : Colors.grey.shade700;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(
          color: _isDark ? Colors.grey.shade700 : Colors.grey.shade400,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: _isDark
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColorScheme.color2.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColorScheme.color2, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: titleColor),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(fontSize: 14, color: subColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildListItem('Participante 1', isOrganizer: false),
        const SizedBox(height: 8),
        _buildListItem('Organizador (estándar color2)', isOrganizer: true),
        const SizedBox(height: 8),
        _buildListItem('Participante 2', isOrganizer: false),
        const SizedBox(height: 8),
        _buildListItem('Participante 3', isOrganizer: false),
      ],
    );
  }

  Widget _buildListItem(String title, {bool isOrganizer = false}) {
    final textColor = _isDark ? Colors.white : AppColorScheme.bodyColor;
    final borderColor = _isDark ? Colors.grey.shade700 : Colors.grey.shade400;
    final avatarBg = isOrganizer
        ? AppColorScheme.color2.withOpacity(0.3)
        : (_isDark ? Colors.grey.shade700 : AppColorScheme.color2.withOpacity(0.2));
    final avatarFg = isOrganizer ? Colors.white : (_isDark ? Colors.white : AppColorScheme.color2);
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: _isDark ? Colors.grey.shade800 : AppColorScheme.color0,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: avatarBg,
            child: isOrganizer
                ? Icon(Icons.admin_panel_settings, color: avatarFg, size: 22)
                : Text(
                    title[0],
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: avatarFg),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: isOrganizer ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: borderColor, size: 22),
        ],
      ),
    );
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
    final color = _isDark ? Colors.white : AppColorScheme.bodyColor;
    final style = GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: color);
    return Text('$text (${size}px)', style: style);
  }
}

