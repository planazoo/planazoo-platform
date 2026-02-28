import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../data/places_api_service.dart';
import '../../../../l10n/app_localizations.dart';

/// Campo de búsqueda con autocompletado de Google Places (New).
/// Para alojamientos usa [lodgingOnly] = true (filtro tipo lodging).
/// Al seleccionar un resultado se obtienen detalles y se llama [onPlaceSelected].
/// Opcionalmente [onPlaceIdSelected] se llama con el placeId al pulsar una sugerencia (para rellenar campos con un botón).
/// Si [placesApiKey] está vacío, el campo se muestra pero no hace peticiones.
class PlaceAutocompleteField extends StatefulWidget {
  final String? initialAddress;
  final bool lodgingOnly;
  final void Function(PlaceDetails details) onPlaceSelected;
  /// Se llama al seleccionar una sugerencia con el [placeId]; permite al padre rellenar campos con un botón.
  final void Function(String placeId)? onPlaceIdSelected;
  final String? placesApiKey;

  const PlaceAutocompleteField({
    super.key,
    this.initialAddress,
    this.lodgingOnly = true,
    required this.onPlaceSelected,
    this.onPlaceIdSelected,
    this.placesApiKey,
  });

  @override
  State<PlaceAutocompleteField> createState() => _PlaceAutocompleteFieldState();
}

class _PlaceAutocompleteFieldState extends State<PlaceAutocompleteField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<PlacePrediction> _predictions = [];
  bool _loading = false;
  String? _sessionToken;
  OverlayEntry? _overlayEntry;
  final _layerLink = LayerLink();
  /// Evita lanzar una nueva búsqueda al rellenar el campo tras seleccionar un lugar.
  bool _skipNextFetch = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
      _controller.text = widget.initialAddress!;
    }
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  String get _apiKey =>
      widget.placesApiKey ??
      const String.fromEnvironment('PLACES_API_KEY', defaultValue: '');

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), _removeOverlay);
    }
  }

  void _onTextChanged() {
    if (_skipNextFetch) {
      _skipNextFetch = false;
      _debounce?.cancel();
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _fetchPredictions(_controller.text);
    });
  }

  Future<void> _fetchPredictions(String input) async {
    // En web usamos Cloud Function (no hace falta API key); en móvil sí
    if (!kIsWeb && _apiKey.isEmpty) return;
    if (input.trim().length < 2) {
      setState(() {
        _predictions = [];
        _loading = false;
      });
      _removeOverlay();
      return;
    }
    setState(() => _loading = true);
    _sessionToken ??= const Uuid().v4();
    final service = PlacesApiService(apiKey: _apiKey);
    final list = await service.autocomplete(
      input: input,
      sessionToken: _sessionToken,
      includedPrimaryTypes: widget.lodgingOnly ? ['lodging'] : null,
      languageCode: _getLanguageCode(),
    );
    if (!mounted) return;
    setState(() {
      _predictions = list;
      _loading = false;
    });
    if (_predictions.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  String _getLanguageCode() {
    final locale = Localizations.localeOf(context);
    final country = locale.countryCode;
    return '${locale.languageCode}_${(country != null && country.isNotEmpty) ? country : locale.languageCode.toUpperCase()}';
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: _getFieldWidth(),
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, _getFieldHeight() + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _predictions.length,
                itemBuilder: (context, index) {
                  final p = _predictions[index];
                  return ListTile(
                    leading: const Icon(Icons.place, size: 20),
                    title: Text(
                      p.mainText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: p.secondaryText.isNotEmpty
                        ? Text(
                            p.secondaryText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    onTap: () => _selectPlace(p.placeId),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  double _getFieldWidth() {
    final r = context.findRenderObject() as RenderBox?;
    return r?.size.width ?? 280;
  }

  double _getFieldHeight() {
    final r = context.findRenderObject() as RenderBox?;
    return r?.size.height ?? 56;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _selectPlace(String placeId) async {
    _removeOverlay();
    widget.onPlaceIdSelected?.call(placeId);
    if (!kIsWeb && _apiKey.isEmpty) return;
    setState(() => _loading = true);
    final service = PlacesApiService(apiKey: _apiKey.isEmpty ? null : _apiKey);
    final details = await service.getPlaceDetails(
      placeId: placeId,
      sessionToken: _sessionToken,
      languageCode: _getLanguageCode(),
    );
    _sessionToken = null;
    if (!mounted) return;
    setState(() => _loading = false);
    if (details != null) {
      _skipNextFetch = true;
      _controller.text = details.formattedAddress ?? details.displayName;
      // Ejecutar callback en el siguiente frame para que el setState del padre
      // corra después de cerrar el overlay y los campos se actualicen correctamente.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onPlaceSelected(details);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: loc.placeAddressLabel,
          hintText: loc.placeSearchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _loading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
          border: const OutlineInputBorder(),
        ),
        maxLines: 1,
        onTap: () {
          if (_controller.text.trim().length >= 2 && _predictions.isEmpty && !_loading) {
            _fetchPredictions(_controller.text);
          }
        },
      ),
    );
  }
}
