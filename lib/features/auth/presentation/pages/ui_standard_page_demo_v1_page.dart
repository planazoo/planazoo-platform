import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';

class UiStandardPageDemoV1Page extends StatefulWidget {
  const UiStandardPageDemoV1Page({super.key});

  @override
  State<UiStandardPageDemoV1Page> createState() =>
      _UiStandardPageDemoV1PageState();
}

class _UiStandardPageDemoV1PageState extends State<UiStandardPageDemoV1Page> {
  static const Color _cPageBg = Color(0xFF111827);
  static const Color _cSurfaceBg = Color(0xFF1F2937);
  static const Color _cTextPrimary = Colors.white;
  static const Color _cTextSecondary = Colors.white70;
  static const Color _cTextTertiary = Colors.white60;
  static const Color _cDanger = Colors.redAccent;
  static const double _aBorderStrong = 0.12;
  static const double _aBorderSubtle = 0.08;
  static const double _aSurfaceMuted = 0.04;
  static const double _aSurfaceChip = 0.06;
  static const double _aAccentSelected = 0.32;

  static const double _fsAppBar = 16;
  static const double _fsSectionTitle = 12;
  static const double _fsSectionSubtitle = 11;
  static const double _fsControl = 12;
  static const double _fsValue = 13;

  bool _showLoading = false;
  bool _showEmpty = false;
  bool _showError = false;
  int _selectedTab = 0;

  static const _tabs = ['Resumen', 'Actividad', 'Archivos'];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: _cPageBg,
        appBar: AppBar(
          backgroundColor: _cPageBg,
          elevation: 0,
          title: Text(
            'UI estandar · pagina demo v1',
            style: GoogleFonts.poppins(
              color: _cTextPrimary,
              fontWeight: FontWeight.w600,
              fontSize: _fsAppBar,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Notificaciones',
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
            IconButton(
              tooltip: 'Mas opciones',
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          children: [
            _headerSection(),
            const SizedBox(height: 10),
            _kpiRow(),
            const SizedBox(height: 10),
            _tabsSection(),
            const SizedBox(height: 10),
            _statesSection(),
            const SizedBox(height: 10),
            _contentSection(),
            const SizedBox(height: 10),
            _actionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _headerSection() {
    return _sectionCard(
      title: 'Cabecera de pagina',
      subtitle: 'Contexto + acciones principales',
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan Tokyo 2026',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _cTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Vista de referencia para estandar visual',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _cTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Accion principal ejecutada')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Crear'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorScheme.color2,
              foregroundColor: _cTextPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiRow() {
    return _sectionCard(
      title: 'KPIs',
      subtitle: 'Tarjetas metricas compactas',
      child: Row(
        children: [
          Expanded(child: _kpi('12', 'Participantes', Icons.people_alt_outlined)),
          const SizedBox(width: 8),
          Expanded(child: _kpi('37', 'Eventos', Icons.event_outlined)),
          const SizedBox(width: 8),
          Expanded(child: _kpi('8', 'Alojamientos', Icons.hotel_outlined)),
        ],
      ),
    );
  }

  Widget _tabsSection() {
    return _sectionCard(
      title: 'Tabs / Segmentos',
      subtitle: 'Navegacion local por contexto',
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final selected = _selectedTab == index;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                onTap: () => setState(() => _selectedTab = index),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColorScheme.color2.withValues(alpha: _aAccentSelected)
                        : _cTextPrimary.withValues(alpha: _aSurfaceChip),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppColorScheme.color2
                          : _cTextPrimary.withValues(alpha: _aBorderStrong),
                    ),
                  ),
                  child: Text(
                    _tabs[index],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: selected ? _cTextPrimary : _cTextSecondary,
                      fontSize: _fsControl,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _statesSection() {
    return _sectionCard(
      title: 'Estados',
      subtitle: 'Empty / Loading / Error',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilterChip(
            selected: _showLoading,
            onSelected: (v) => setState(() => _showLoading = v),
            label: const Text('Loading'),
            selectedColor: AppColorScheme.color2.withValues(alpha: _aAccentSelected),
            backgroundColor: _cTextPrimary.withValues(alpha: _aSurfaceChip),
          ),
          FilterChip(
            selected: _showEmpty,
            onSelected: (v) => setState(() => _showEmpty = v),
            label: const Text('Empty'),
            selectedColor: AppColorScheme.color2.withValues(alpha: _aAccentSelected),
            backgroundColor: _cTextPrimary.withValues(alpha: _aSurfaceChip),
          ),
          FilterChip(
            selected: _showError,
            onSelected: (v) => setState(() => _showError = v),
            label: const Text('Error'),
            selectedColor: AppColorScheme.color2.withValues(alpha: _aAccentSelected),
            backgroundColor: _cTextPrimary.withValues(alpha: _aSurfaceChip),
          ),
        ],
      ),
    );
  }

  Widget _contentSection() {
    if (_showLoading) {
      return _sectionCard(
        title: 'Contenido',
        subtitle: 'Estado loading',
        child: const SizedBox(
          height: 90,
          child: Center(child: CircularProgressIndicator(color: AppColorScheme.color2)),
        ),
      );
    }

    if (_showError) {
      return _sectionCard(
        title: 'Contenido',
        subtitle: 'Estado error',
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: _cDanger, size: 28),
            const SizedBox(height: 8),
            Text(
              'No se pudo cargar el bloque',
              style: GoogleFonts.poppins(color: _cTextSecondary, fontSize: _fsValue),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => setState(() => _showError = false),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_showEmpty) {
      return _sectionCard(
        title: 'Contenido',
        subtitle: 'Estado vacio',
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, color: _cTextTertiary, size: 28),
            const SizedBox(height: 8),
            Text(
              'No hay elementos para mostrar',
              style: GoogleFonts.poppins(color: _cTextSecondary, fontSize: _fsValue),
            ),
          ],
        ),
      );
    }

    return _sectionCard(
      title: 'Listado',
      subtitle: 'Items con iconos, chips y accion',
      child: Column(
        children: List.generate(3, (i) {
          return Container(
            margin: EdgeInsets.only(bottom: i == 2 ? 0 : 8),
            decoration: BoxDecoration(
              color: _cTextPrimary.withValues(alpha: _aSurfaceMuted),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _cTextPrimary.withValues(alpha: _aBorderSubtle)),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColorScheme.color2,
                child: Icon(Icons.person, color: _cTextPrimary, size: 18),
              ),
              title: Text(
                'Elemento ${i + 1}',
                style: GoogleFonts.poppins(color: _cTextPrimary, fontSize: _fsValue),
              ),
              subtitle: Text(
                'Detalle secundario',
                style: GoogleFonts.poppins(color: _cTextSecondary, fontSize: _fsSectionSubtitle),
              ),
              trailing: const Icon(Icons.chevron_right, color: _cTextSecondary),
            ),
          );
        }),
      ),
    );
  }

  Widget _actionsSection() {
    return _sectionCard(
      title: 'Botonera',
      subtitle: 'Acciones primaria / secundaria / destructiva',
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorScheme.color2,
                foregroundColor: _cTextPrimary,
              ),
              child: const Text('Guardar'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextButton(
              onPressed: () {},
              child: const Text('Eliminar', style: TextStyle(color: _cDanger)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpi(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _cTextPrimary.withValues(alpha: _aSurfaceMuted),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cTextPrimary.withValues(alpha: _aBorderSubtle)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColorScheme.color2, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _cTextPrimary,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: _fsSectionSubtitle, color: _cTextSecondary),
          ),
        ],
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
}

