import 'dart:convert';
import 'dart:typed_data';

import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';

/// Enlace del resumen compartible: texto visible + URL completa de destino.
class PlanSummaryShareLink {
  const PlanSummaryShareLink({
    required this.label,
    required this.url,
  });

  final String label;
  final String url;
}

/// Bloque de un día (evento o alojamiento) en el preview o en el HTML.
class PlanSummaryShareBlock {
  const PlanSummaryShareBlock({
    required this.title,
    this.subtitle,
    this.links = const [],
    this.isAccommodation = false,
  });

  final String title;
  final String? subtitle;
  final List<PlanSummaryShareLink> links;
  final bool isAccommodation;
}

/// Contenido estructurado del resumen para preview (links subrayados) y exportación.
class PlanSummaryShareContent {
  const PlanSummaryShareContent({
    required this.planName,
    required this.headerLines,
    required this.daySections,
  });

  final String planName;
  final List<String> headerLines;
  final List<({String dayLabel, List<PlanSummaryShareBlock> items})> daySections;

  static PlanSummaryShareContent fromData({
    required String planName,
    required DateTime? planStart,
    required DateTime? planEnd,
    required String viewLabel,
    required List<Event> events,
    required List<Accommodation> accommodations,
    required String Function(Event e) formatEventTime,
    String mapsLabel = 'maps',
    String webLabel = 'web',
    String routeLabel = 'ruta',
  }) {
    final name = planName.trim().isEmpty ? 'Plan' : planName.trim();
    final headers = <String>[];
    if (planStart != null && planEnd != null) {
      headers.add(
        '${DateFormatter.formatDate(planStart)} – ${DateFormatter.formatDate(planEnd)}',
      );
    }
    headers.add(viewLabel);

    final dayKeys = <DateTime>{};
    for (final e in events) {
      dayKeys.add(DateTime(e.date.year, e.date.month, e.date.day));
    }
    for (final a in accommodations) {
      var d = DateTime(a.checkIn.year, a.checkIn.month, a.checkIn.day);
      final lastNight = DateTime(
        a.checkOut.year,
        a.checkOut.month,
        a.checkOut.day,
      ).subtract(const Duration(days: 1));
      while (!d.isAfter(lastNight)) {
        dayKeys.add(d);
        d = d.add(const Duration(days: 1));
      }
    }

    final sortedDays = dayKeys.toList()..sort();

    final days = <({String dayLabel, List<PlanSummaryShareBlock> items})>[];
    for (final day in sortedDays) {
      final items = <PlanSummaryShareBlock>[];

      final dayEvents = events.where((e) {
        final ed = DateTime(e.date.year, e.date.month, e.date.day);
        return ed == day;
      }).toList()
        ..sort((a, b) {
          final ha = a.hour * 60 + a.startMinute;
          final hb = b.hour * 60 + b.startMinute;
          return ha.compareTo(hb);
        });

      for (final e in dayEvents) {
        items.add(_eventBlock(e, formatEventTime, mapsLabel, webLabel, routeLabel));
      }

      final dayHotels = accommodations.where((a) => a.isDateInRange(day)).toList()
        ..sort((a, b) => a.hotelName.compareTo(b.hotelName));

      for (final a in dayHotels) {
        items.add(_accommodationBlock(a, mapsLabel, webLabel));
      }

      if (items.isNotEmpty) {
        days.add((dayLabel: DateFormatter.formatDate(day), items: items));
      }
    }

    return PlanSummaryShareContent(
      planName: name,
      headerLines: headers,
      daySections: days,
    );
  }

  static PlanSummaryShareBlock _eventBlock(
    Event e,
    String Function(Event e) formatEventTime,
    String mapsLabel,
    String webLabel,
    String routeLabel,
  ) {
    final code = _transportCode(e);
    final titleCore = code != null ? '$code · ${e.description}' : e.description;
    final title = '${formatEventTime(e)} $titleCore';
    final links = <PlanSummaryShareLink>[];

    final route = _eventRouteUrl(e);
    if (route != null) {
      links.add(PlanSummaryShareLink(label: routeLabel, url: route));
    } else {
      final mapsQuery = _eventMapsQuery(e);
      if (mapsQuery != null) {
        links.add(PlanSummaryShareLink(
          label: mapsLabel,
          url: _mapsSearchUrl(mapsQuery),
        ));
      }
    }

    final webUrl = _normalizeUrl(e.commonPart?.url);
    if (webUrl != null) {
      links.add(PlanSummaryShareLink(label: webLabel, url: webUrl));
    }

    return PlanSummaryShareBlock(title: title, links: links);
  }

  static PlanSummaryShareBlock _accommodationBlock(
    Accommodation a,
    String mapsLabel,
    String webLabel,
  ) {
    final links = <PlanSummaryShareLink>[];
    final address = (a.commonPart?.address ?? '').trim();
    if (address.isNotEmpty) {
      links.add(PlanSummaryShareLink(
        label: mapsLabel,
        url: _mapsSearchUrl(address),
      ));
    }
    final webUrl = _normalizeUrl(a.commonPart?.url);
    if (webUrl != null) {
      links.add(PlanSummaryShareLink(label: webLabel, url: webUrl));
    }

    return PlanSummaryShareBlock(
      title: a.hotelName,
      subtitle:
          '${DateFormatter.formatDate(a.checkIn)} – ${DateFormatter.formatDate(a.checkOut)}',
      links: links,
      isAccommodation: true,
    );
  }

  /// HTML con `<a>` (texto subrayado al abrir; href = URL completa).
  String toHtml() {
    final buf = StringBuffer()
      ..writeln('<!DOCTYPE html>')
      ..writeln('<html><head><meta charset="utf-8">')
      ..writeln('<meta name="viewport" content="width=device-width, initial-scale=1">')
      ..writeln('<title>${_escapeHtml(planName)}</title>')
      ..writeln('<style>')
      ..writeln(
          'body{font-family:system-ui,-apple-system,sans-serif;line-height:1.45;'
          'padding:16px;color:#111;max-width:720px;margin:0 auto}')
      ..writeln('h1{font-size:1.25rem;margin:0 0 4px}')
      ..writeln('h2{font-size:1.05rem;margin:20px 0 8px}')
      ..writeln('.meta{color:#555;margin:0 0 2px}')
      ..writeln('.item{margin:0 0 12px}')
      ..writeln('.title{font-weight:600}')
      ..writeln('.sub{color:#555;font-size:0.92rem}')
      ..writeln('.hotel{margin-top:14px;padding-top:10px;border-top:1px dashed #ccc}')
      ..writeln(
          'a{color:#1565c0;text-decoration:underline;display:inline-block;'
          'margin-right:10px;margin-top:2px}')
      ..writeln('</style></head><body>')
      ..writeln('<h1>${_escapeHtml(planName)}</h1>');
    for (final line in headerLines) {
      buf.writeln('<p class="meta">${_escapeHtml(line)}</p>');
    }

    if (daySections.isNotEmpty) {
      buf.writeln('<h2>Itinerario</h2>');
      for (final section in daySections) {
        buf.writeln('<h2>${_escapeHtml(section.dayLabel)}</h2>');
        for (final b in section.items) {
          buf.write(_blockHtml(b));
        }
      }
    }

    buf.writeln('</body></html>');
    return buf.toString();
  }

  String _blockHtml(PlanSummaryShareBlock b) {
    final itemClass = b.isAccommodation ? 'item hotel' : 'item';
    final buf = StringBuffer()
      ..writeln('<div class="$itemClass">')
      ..writeln('<div class="title">${_escapeHtml(b.title)}</div>');
    if (b.subtitle != null && b.subtitle!.trim().isNotEmpty) {
      buf.writeln('<div class="sub">${_escapeHtml(b.subtitle!)}</div>');
    }
    if (b.links.isNotEmpty) {
      buf.write('<div>');
      for (final link in b.links) {
        buf.write(
          '<a href="${_escapeHtml(link.url)}">${_escapeHtml(link.label)}</a>',
        );
      }
      buf.writeln('</div>');
    }
    buf.writeln('</div>');
    return buf.toString();
  }

  /// Texto plano con Markdown `[etiqueta](url completa)`.
  String toMarkdown() {
    final buf = StringBuffer()..writeln(planName);
    for (final line in headerLines) {
      buf.writeln(line);
    }
    buf.writeln();

    if (daySections.isNotEmpty) {
      buf.writeln('— Itinerario —');
      for (final section in daySections) {
        buf.writeln(section.dayLabel);
        for (final b in section.items) {
          buf.write(_blockMarkdown(b));
        }
        buf.writeln();
      }
    }

    return buf.toString().trimRight();
  }

  String _blockMarkdown(PlanSummaryShareBlock b) {
    final buf = StringBuffer()..writeln(b.title);
    if (b.subtitle != null && b.subtitle!.trim().isNotEmpty) {
      buf.writeln(b.subtitle);
    }
    for (final link in b.links) {
      buf.writeln('[${link.label}](${link.url})');
    }
    return buf.toString();
  }

  Uint8List toHtmlBytes() => Uint8List.fromList(utf8.encode(toHtml()));

  static String? _transportCode(Event e) {
    final ed = e.commonPart?.extraData;
    if (ed == null) return null;
    for (final key in ['flightNumber', 'trainNumber', 'transportNumber']) {
      final v = ed[key]?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return null;
  }

  static String? _eventMapsQuery(Event e) {
    final location = (e.commonPart?.location ?? '').trim();
    if (location.isNotEmpty) return location;
    final ed = e.commonPart?.extraData;
    final placeAddress = (ed?['placeAddress'] as String?)?.trim() ?? '';
    if (placeAddress.isNotEmpty) return placeAddress;
    final placeName = (ed?['placeName'] as String?)?.trim() ?? '';
    if (placeName.isNotEmpty) return placeName;
    final dest = (ed?['taxiDestinationAddress'] as String?)?.trim() ?? '';
    if (dest.isNotEmpty) return dest;
    return null;
  }

  static String? _eventRouteUrl(Event e) {
    final fam = (e.typeFamily ?? '').trim();
    if (fam != 'Desplazamiento') return null;
    final ed = e.commonPart?.extraData;
    if (ed == null) return null;
    final origin =
        _singleLine((ed['taxiOriginAddress'] as String?)?.trim() ?? '');
    final dest =
        _singleLine((ed['taxiDestinationAddress'] as String?)?.trim() ?? '');
    if (origin.isEmpty || dest.isEmpty) return null;
    return Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'origin': origin,
      'destination': dest,
    }).toString();
  }

  static String _mapsSearchUrl(String query) {
    final q = _singleLine(query);
    return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(q)}';
  }

  static String? _normalizeUrl(String? raw) {
    if (raw == null) return null;
    final value = raw.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return 'https://$value';
  }

  static String _singleLine(String text) =>
      text.replaceAll(RegExp(r'\s*\n\s*'), ', ').trim();

  static String _escapeHtml(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}

/// Compat: genera Markdown del resumen (URLs completas tras la etiqueta).
class PlanSummaryShareText {
  PlanSummaryShareText._();

  static String build({
    required String planName,
    required DateTime? planStart,
    required DateTime? planEnd,
    required String viewLabel,
    required List<Event> events,
    required List<Accommodation> accommodations,
    required String Function(Event e) formatEventTime,
    String mapsLabel = 'maps',
    String webLabel = 'web',
    String routeLabel = 'ruta',
  }) {
    return PlanSummaryShareContent.fromData(
      planName: planName,
      planStart: planStart,
      planEnd: planEnd,
      viewLabel: viewLabel,
      events: events,
      accommodations: accommodations,
      formatEventTime: formatEventTime,
      mapsLabel: mapsLabel,
      webLabel: webLabel,
      routeLabel: routeLabel,
    ).toMarkdown();
  }
}
