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
            color: Colors.grey.shade400,
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
    const double fieldHeight = 36;
    return Container(
      height: fieldHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade800,
            const Color(0xFF2C2C2C),
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
        controller: _controller,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar planes...',
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade400,
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