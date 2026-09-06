import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

/// Mapa Google (Maps JavaScript API) en iframe para Flutter web.
class PlanMapGoogleJsView extends StatefulWidget {
  const PlanMapGoogleJsView({
    super.key,
    required this.html,
    required this.onMessage,
    this.selectedDayIndex,
    this.selectedStopId,
  });

  final String html;
  final ValueChanged<Map<String, dynamic>> onMessage;
  final int? selectedDayIndex;
  final String? selectedStopId;

  @override
  State<PlanMapGoogleJsView> createState() => PlanMapGoogleJsViewState();
}

class PlanMapGoogleJsViewState extends State<PlanMapGoogleJsView> {
  static var _nextViewId = 0;

  late final String _viewType;
  late final html.EventListener _listener;
  html.IFrameElement? _iframe;
  StreamSubscription<html.Event>? _loadSub;
  var _ready = false;
  var _disposed = false;

  @override
  void initState() {
    super.initState();
    _viewType = 'planazoo-plan-map-${_nextViewId++}';
    _listener = (html.Event event) {
      if (_disposed) return;
      if (event is! html.MessageEvent) return;
      final data = event.data;
      if (data is String) {
        _handleRaw(data);
      }
    };
    html.window.addEventListener('message', _listener);

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
      final iframe = html.IFrameElement()
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..srcdoc = widget.html;
      _loadSub?.cancel();
      _loadSub = iframe.onLoad.listen((_) {
        if (_disposed) return;
        _ready = true;
        applyDayFilter(widget.selectedDayIndex);
        applySelectStop(widget.selectedStopId);
      });
      _iframe = iframe;
      return iframe;
    });
  }

  @override
  void didUpdateWidget(PlanMapGoogleJsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_disposed) return;
    if (oldWidget.html != widget.html) {
      _ready = false;
      _iframe?.srcdoc = widget.html;
    } else {
      if (oldWidget.selectedDayIndex != widget.selectedDayIndex) {
        applyDayFilter(widget.selectedDayIndex);
      }
      if (oldWidget.selectedStopId != widget.selectedStopId) {
        applySelectStop(widget.selectedStopId);
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _ready = false;
    _loadSub?.cancel();
    _loadSub = null;
    html.window.removeEventListener('message', _listener);
    // Vaciar el mapa para soltar WebGL; no arrancar remove() en el mismo frame
    // (rompe CachedNetworkImage de la lista de planes en Flutter web).
    final iframe = _iframe;
    _iframe = null;
    if (iframe != null) {
      iframe.srcdoc = '';
      try {
        iframe.src = 'about:blank';
      } catch (_) {}
    }
    super.dispose();
  }

  void applyDayFilter(int? dayIndex) {
    if (_disposed || !_ready) return;
    final payload = jsonEncode({
      'source': 'planazoo-map',
      'action': 'filter',
      'dayIndex': dayIndex,
    });
    _iframe?.contentWindow?.postMessage(payload, '*');
    applySelectStop(widget.selectedStopId);
  }

  void applySelectStop(String? stopId) {
    if (_disposed || !_ready) return;
    final payload = jsonEncode({
      'source': 'planazoo-map',
      'action': 'selectStop',
      'id': stopId,
    });
    _iframe?.contentWindow?.postMessage(payload, '*');
  }

  void _handleRaw(String raw) {
    if (_disposed) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        final map = Map<String, dynamic>.from(decoded);
        if (map['source'] == 'planazoo-map') {
          widget.onMessage(map);
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
