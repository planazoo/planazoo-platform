import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/color_scheme.dart';

class PlanSearchWidget extends StatefulWidget {
  final String? searchQuery;
  final Function(String)? onSearchChanged;
  final VoidCallback? onSearchPressed;

  const PlanSearchWidget({
    super.key,
    this.searchQuery,
    this.onSearchChanged,
    this.onSearchPressed,
  });

  @override
  State<PlanSearchWidget> createState() => _PlanSearchWidgetState();
}

class _PlanSearchWidgetState extends State<PlanSearchWidget> {
  static const Color _surface = Color(0xFF1F2937);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Colors.white70;
  static const Color _textTertiary = Colors.white60;
  static const Color _border = Colors.white12;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery ?? '');
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(PlanSearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery &&
        _controller.text != (widget.searchQuery ?? '')) {
      _controller.text = widget.searchQuery ?? '';
    }
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearchChanged?.call('');
    // Quitar foco del campo (cierra teclado en iOS, deselecciona en web)
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// Botón X para borrar: GestureDetector asegura que el tap se reciba en web e iOS.
  /// Área mínima 44x44 para cumplir con las guías de accesibilidad (iOS).
  Widget _buildClearButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _clearSearch,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Icon(
            Icons.close,
            color: _textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double fieldHeight = 40;

    return Container(
      height: fieldHeight,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _border,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: _textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar planes...',
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: _textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: _textSecondary,
            size: 22,
          ),
          suffixIcon: _controller.text.isEmpty
              ? null
              : _buildClearButton(),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          filled: true,
          fillColor: Colors.transparent,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColorScheme.color2,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
        onChanged: (value) => widget.onSearchChanged?.call(value),
        onSubmitted: (_) => widget.onSearchPressed?.call(),
      ),
    );
  }
}