# T225 – Plan de implementación: Google Places para alojamientos y eventos

**Objetivo:** Integrar autocompletado y Place Details (Google Places API) para **alojamientos** y **eventos**. En alojamientos: campo de búsqueda con sugerencias (tipo lodging); al elegir un resultado, rellenar nombre (y opcionalmente dirección, coordenadas). En eventos: campo descripción/lugar con búsqueda.

**Requisitos:** API key en Google Cloud (Places API), variable de entorno para la key, UI de búsqueda + Place Details y mapeo a modelo. Coste: ~10k Place Details/mes gratis; Autocomplete en sesión no se cobra.

**Estado:** ✅ Implementación completa (Fases 1–4). Web usa Cloud Functions como proxy; móvil puede usar API directa con `--dart-define=PLACES_API_KEY`.

---

## Estado actual en el código

| Ámbito | Modelo | Campo(s) | UI actual |
|--------|--------|----------|-----------|
| **Alojamientos** | `AccommodationCommonPart` | `hotelName`, `address`, `extraData` (placeLat, placeLng, placeAddress, placeName) | Diálogo con estética tipo login: **búsqueda Places** (primer campo), nombre, **dirección** (visible y editable), tipo, descripción, coste, fechas, color, participantes. Tarjeta de ubicación con dirección y botón **"Abrir en Google Maps"**. |
| **Eventos** | `EventCommonPart` | `description`, `location`, `extraData` (placeLat, placeLng) | Diálogo con estética tipo login: descripción, **búsqueda Places** y campo **Lugar** (opcional), tipo, fecha/hora, etc. Tarjeta de ubicación con dirección y **"Abrir en Google Maps"**. |

---

## Fases de implementación

### Fase 1 – Configuración y dependencia
- [x] **Comprobar o crear API key:** Seguir **`docs/configuracion/CONFIGURAR_GOOGLE_PLACES_API.md`** (key disponible, Places API (New) habilitada, facturación vinculada).
- [x] **Dependencia:** Añadido paquete `http` y servicio propio contra Places API (New) (autocomplete + place details). Sin paquete third-party para evitar límites web/iOS.
- [x] **API key en la app:** Se lee con `String.fromEnvironment('PLACES_API_KEY')`. Ejecutar con `flutter run --dart-define=PLACES_API_KEY=xxx`. Ver CONFIGURAR_GOOGLE_PLACES_API.md § 2.4.
- [ ] (Opcional) Restringir la key por referrer web / bundle ID según [buenas prácticas de Google](https://developers.google.com/maps/api-security).

### Fase 2 – Alojamientos
- [x] En `wd_accommodation_dialog.dart`: añadido **PlaceAutocompleteField** (búsqueda con autocompletado tipo `lodging`).
- [x] Al seleccionar un lugar: se rellenan nombre del alojamiento y dirección; se guarda en `commonPart.address` y `commonPart.hotelName` (y campos planos del modelo).
- [x] El campo nombre sigue editable; la dirección se muestra y guarda en `AccommodationCommonPart.address`.
- [x] Localización: `placeSearchHint`, `placeAddressLabel` en `app_es.arb` / `app_en.arb`.

### Fase 3 – Eventos
- [x] En `wd_event_dialog.dart`: añadido campo "Lugar" (opcional) con autocompletado tipo genérico (`lodgingOnly: false`).
- [x] Al seleccionar un lugar: se rellenan `EventCommonPart.location` (nombre + dirección) y opcionalmente `extraData.placeLat` / `extraData.placeLng`.
- [x] Localización: `eventLocationLabel`, `eventLocationHint` en `app_es.arb` / `app_en.arb`.

### Fase 4 – Pruebas y documentación
- [x] Probar en web (Cloud Functions con API key de servidor; Place Details con header `X-Goog-FieldMask`).
- [x] Actualizar `TESTING_CHECKLIST.md` con casos de prueba para búsqueda de lugar en alojamiento y en evento (§ 5.5, § 4.1).
- [x] Actualizar flujos `FLUJO_CRUD_ALOJAMIENTOS.md` y `FLUJO_CRUD_EVENTOS.md` con la funcionalidad de lugar/Places.

---

## Preguntas para el usuario (al arrancar)

1. **API key:** ¿Tienes ya un proyecto en Google Cloud con Places API (o Maps Platform) habilitado y una API key? Si no, el primer paso será crearla y restringirla.
2. **Alcance inicial:** ¿Empezamos solo por **alojamientos** (Fase 2) y luego eventos (Fase 3), o quieres ambos en paralelo?
3. **Coordenadas:** ¿Quieres guardar lat/lng además de nombre y dirección para uso futuro (mapas, distancia)? El modelo puede usar `extraData` sin cambiar esquema Firestore.

---

*Creado: Febrero 2026. Actualizar este documento según se avance en T225.*
