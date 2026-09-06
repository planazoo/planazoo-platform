import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Mapa Google (Maps JavaScript API) en WebView nativo iOS/Android.
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
  late final WebViewController _controller;
  var _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF000000))
      ..addJavaScriptChannel(
        'PlanMap',
        onMessageReceived: (message) {
          _handleRaw(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            _ready = true;
            applyDayFilter(widget.selectedDayIndex);
            applySelectStop(widget.selectedStopId);
          },
        ),
      )
      ..loadHtmlString(
        widget.html,
        baseUrl: 'https://maps.googleapis.com/',
      );
  }

  @override
  void didUpdateWidget(PlanMapGoogleJsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.html != widget.html) {
      _ready = false;
      _controller.loadHtmlString(
        widget.html,
        baseUrl: 'https://maps.googleapis.com/',
      );
    } else {
      if (oldWidget.selectedDayIndex != widget.selectedDayIndex) {
        applyDayFilter(widget.selectedDayIndex);
      }
      if (oldWidget.selectedStopId != widget.selectedStopId) {
        applySelectStop(widget.selectedStopId);
      }
    }
  }

  void applyDayFilter(int? dayIndex) {
    if (!_ready) return;
    final arg = dayIndex == null ? 'null' : '$dayIndex';
    _controller.runJavaScript('if (window.setDayFilter) setDayFilter($arg);');
    applySelectStop(widget.selectedStopId);
  }

  void applySelectStop(String? stopId) {
    if (!_ready) return;
    final idJson = jsonEncode(stopId);
    _controller.runJavaScript(
      'if (window.highlightStop) highlightStop($idJson);',
    );
  }

  void _handleRaw(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        widget.onMessage(decoded);
      } else if (decoded is Map) {
        widget.onMessage(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
