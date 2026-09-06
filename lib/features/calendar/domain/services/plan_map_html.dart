import 'dart:convert';

import 'package:unp_calendario/features/calendar/domain/models/plan_map_stop.dart';

/// HTML + Maps JavaScript API (pines numerados y color por día).
class PlanMapHtml {
  PlanMapHtml._();

  static String build({
    required String apiKey,
    required List<PlanMapStop> stops,
    required List<PlanMapDayRoute> routes,
  }) {
    final payload = <String, dynamic>{
      'stops': [for (final s in stops) s.toJson()],
      'routes': [for (final r in routes) r.toJson()],
      'selectedDayIndex': null,
      'selectedStopId': null,
    };
    final json = jsonEncode(payload).replaceAll('<', r'\u003c');
    final key = apiKey.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '');
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
  <style>
    html, body, #map { margin: 0; padding: 0; height: 100%; width: 100%; background: #000; }
  </style>
</head>
<body>
  <div id="map"></div>
  <script>
    const DATA = $json;
    const STYLE = [
      {elementType:"geometry",stylers:[{color:"#1d1d1d"}]},
      {elementType:"labels.text.fill",stylers:[{color:"#8a8a8a"}]},
      {elementType:"labels.text.stroke",stylers:[{color:"#1d1d1d"}]},
      {featureType:"poi",stylers:[{visibility:"off"}]},
      {featureType:"poi.park",elementType:"geometry",stylers:[{color:"#181818"},{visibility:"on"}]},
      {featureType:"road",elementType:"geometry",stylers:[{color:"#2c2c2c"}]},
      {featureType:"road",elementType:"labels.text.fill",stylers:[{color:"#8a8a8a"}]},
      {featureType:"transit",stylers:[{visibility:"off"}]},
      {featureType:"water",elementType:"geometry",stylers:[{color:"#0e1626"}]}
    ];
    let map, markers = [], polylines = [];

    function hasPos(stop) {
      return typeof stop.lat === 'number' && typeof stop.lng === 'number';
    }

    function firstPos() {
      for (var i = 0; i < DATA.stops.length; i++) {
        if (hasPos(DATA.stops[i])) return DATA.stops[i];
      }
      return null;
    }

    function notify(payload) {
      payload.source = 'planazoo-map';
      const json = JSON.stringify(payload);
      if (window.PlanMap && window.PlanMap.postMessage) {
        window.PlanMap.postMessage(json);
      } else if (window.parent && window.parent !== window) {
        window.parent.postMessage(json, '*');
      }
    }

    window.gm_authFailure = function() {
      notify({ action: 'error', code: 'auth' });
    };

    function isVisible(stop, dayIndex) {
      if (dayIndex === null || dayIndex === undefined) return true;
      const days = stop.visibleOnDayIndexes || [];
      return days.indexOf(dayIndex) !== -1;
    }

    function isHotel(stop) {
      return stop.kind === 'accommodation';
    }

    function isLetter(stop) {
      return stop.kind === 'accommodation' || stop.kind === 'airport';
    }

    function stopIcon(stop, selected) {
      const letter = isLetter(stop);
      if (isHotel(stop)) {
        return {
          path: 'M -1,-1 L 1,-1 L 1,1 L -1,1 z',
          fillColor: stop.colorHex,
          fillOpacity: 1,
          strokeColor: '#FFFFFF',
          strokeWeight: selected ? 3 : 2,
          scale: selected ? 12 : 10
        };
      }
      return {
        path: google.maps.SymbolPath.CIRCLE,
        fillColor: stop.colorHex,
        fillOpacity: 1,
        strokeColor: '#FFFFFF',
        strokeWeight: selected ? 4 : (letter ? 3 : 2),
        scale: selected ? (letter ? 20 : 18) : (letter ? 16 : 14)
      };
    }

    function highlightStop(id) {
      DATA.selectedStopId = id || null;
      markers.forEach(function(entry) {
        const letter = isLetter(entry.stop);
        const selected = DATA.selectedStopId && entry.stop.id === DATA.selectedStopId;
        entry.marker.setIcon(stopIcon(entry.stop, selected));
        entry.marker.setZIndex(selected ? 1000 : (isHotel(entry.stop) ? 1 : (letter ? 2 : 10 + (entry.stop.sequenceInDay || 0))));
      });
      if (!id) return;
      for (var i = 0; i < markers.length; i++) {
        const entry = markers[i];
        if (entry.stop.id === id && entry.marker.getMap()) {
          map.panTo(entry.marker.getPosition());
          break;
        }
      }
    }
    window.highlightStop = highlightStop;

    function fitVisible(dayIndex) {
      const b = new google.maps.LatLngBounds();
      let n = 0;
      DATA.stops.forEach(function(s) {
        if (!isVisible(s, dayIndex) || !hasPos(s)) return;
        b.extend({ lat: s.lat, lng: s.lng });
        n++;
      });
      if (n === 1) {
        DATA.stops.forEach(function(s) {
          if (isVisible(s, dayIndex) && hasPos(s)) {
            map.setCenter({ lat: s.lat, lng: s.lng });
            map.setZoom(14);
          }
        });
      } else if (n > 1) {
        map.fitBounds(b, 48);
      }
    }

    function setDayFilter(dayIndex) {
      DATA.selectedDayIndex = dayIndex;
      markers.forEach(function(entry) {
        entry.marker.setMap(isVisible(entry.stop, dayIndex) ? map : null);
      });
      polylines.forEach(function(entry) {
        const show = dayIndex === null || dayIndex === undefined || entry.dayIndex === dayIndex;
        entry.line.setMap(show ? map : null);
      });
      fitVisible(dayIndex);
      highlightStop(DATA.selectedStopId);
    }
    window.setDayFilter = setDayFilter;

    function addMarker(stop) {
      if (!hasPos(stop)) return;
      const letter = isLetter(stop);
      const labelText = stop.kind === 'accommodation'
        ? 'H'
        : (stop.kind === 'airport' ? 'A' : String(stop.sequenceInDay || ''));
      const marker = new google.maps.Marker({
        position: { lat: stop.lat, lng: stop.lng },
        map: map,
        title: stop.title,
        label: {
          text: labelText || '•',
          color: '#FFFFFF',
          fontWeight: '700',
          fontSize: letter ? '11px' : '12px'
        },
        icon: stopIcon(stop, false),
        zIndex: isHotel(stop) ? 1 : (letter ? 2 : 10 + (stop.sequenceInDay || 0))
      });
      marker.addListener('click', function() {
        notify({ action: 'select', id: stop.id });
      });
      markers.push({ marker: marker, stop: stop });
    }

    function drawRoutes() {
      DATA.routes.forEach(function(route) {
        const line = new google.maps.Polyline({
          path: route.points,
          geodesic: true,
          strokeColor: route.colorHex,
          strokeOpacity: 0.85,
          strokeWeight: 3,
          map: map
        });
        polylines.push({ line: line, dayIndex: route.dayIndex });
      });
    }

    function geocodeMissing(done) {
      const missing = DATA.stops.filter(function(s) {
        return !hasPos(s) && s.geocodeQuery;
      });
      if (!missing.length || !google.maps.Geocoder) {
        done();
        return;
      }
      const geocoder = new google.maps.Geocoder();
      var left = missing.length;
      function oneDone() {
        left--;
        if (left <= 0) done();
      }
      missing.forEach(function(s) {
        geocoder.geocode({ address: s.geocodeQuery }, function(results, status) {
          if (status === 'OK' && results && results[0]) {
            s.lat = results[0].geometry.location.lat();
            s.lng = results[0].geometry.location.lng();
          }
          oneDone();
        });
      });
    }

    function initMap() {
      const first = firstPos();
      const mapOpts = {
        center: first ? { lat: first.lat, lng: first.lng } : { lat: 51.75, lng: -1.26 },
        zoom: 12,
        styles: STYLE,
        mapTypeControl: false,
        streetViewControl: false,
        fullscreenControl: false,
        clickableIcons: false,
        gestureHandling: 'greedy'
      };
      // Raster: evita WebGL de Maps y que las fotos de Flutter web se queden negras al cerrar.
      if (google.maps.RenderingType && google.maps.RenderingType.RASTER) {
        mapOpts.renderingType = google.maps.RenderingType.RASTER;
      }
      map = new google.maps.Map(document.getElementById('map'), mapOpts);

      window.addEventListener('message', function(ev) {
        try {
          var data = typeof ev.data === 'string' ? JSON.parse(ev.data) : ev.data;
          if (!data || data.source !== 'planazoo-map') return;
          if (data.action === 'filter') setDayFilter(data.dayIndex);
          if (data.action === 'selectStop') highlightStop(data.id);
        } catch (e) {}
      });

      geocodeMissing(function() {
        DATA.stops.forEach(addMarker);
        drawRoutes();
        setDayFilter(DATA.selectedDayIndex);
        notify({ action: 'ready' });
      });
    }
    window.initMap = initMap;
  </script>
  <script async src="https://maps.googleapis.com/maps/api/js?key=$key&callback=initMap&loading=async"></script>
</body>
</html>
''';
  }
}
