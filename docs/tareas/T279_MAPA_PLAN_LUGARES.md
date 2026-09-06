# T279 — Mapa del plan (lugares a visitar)

**Estado:** Implementado (2026-09-05). Pendiente confirmación de usuario para marcar Completada.  
**Dominio:** Eventos (+ calendario). Contrato: [`FLUJO_CRUD_EVENTOS.md`](../flujos/FLUJO_CRUD_EVENTOS.md).  
**Nota WIP:** se implementó a petición explícita mientras el WIP de proceso sigue en **#2 Planes**.

## Qué hay

- Entrada: icono mapa en **Mi resumen** (barra verde en dashboard; botón flotante en detalle iOS).
- Pines de eventos con `placeLat`/`placeLng` (no taxis/trenes/etc.). Si no hay coords pero sí lugar/título, el mapa **geocodifica** (Geocoding API) y pinta el pin.
- El mapa usa los eventos del plan (no el filtro «solo borradores» de Mi resumen).
- Vuelos (`Desplazamiento` / `Avión`): pin **A** en aeropuertos con `departureAirportLat`/`arrivalAirportLat`. Sin número. El aeropuerto de casa no se pinta si queda lejos (~180 km) de visitas/hoteles.
- Color por **día del plan**; número = orden horario ese día (solo visitas).
- Alojamiento con coordenadas: pin **H**, visible en las noches del stay.
- Línea del día: A llegada → visitas → A salida.
- Filtro Todos / Día N. Lista: A llegada → visitas numeradas → A salida → **hotel al final** (sección Alojamiento, **H** en cuadrado). Pin de hotel cuadrado con H. Pin ↔ fila.
- Sin clave o si falla JS: lista con el mismo color+número + «abrir en Google Maps».

## Clave y APIs

Misma clave que Places: `--dart-define=PLACES_API_KEY=…` (o `MAPS_API_KEY`).  
Habilitar **Maps JavaScript API** en el proyecto Cloud. Ver [`CONFIGURAR_GOOGLE_PLACES_API.md`](../configuracion/CONFIGURAR_GOOGLE_PLACES_API.md).

Coste: SKU Dynamic Maps (10k cargas/mes gratis, luego ~7 $/1.000). Los pins numerados no añaden SKU.

## Código

- `PlanMapStopBuilder` / `PlanMapDayColors`
- `wd_plan_map_screen.dart` + HTML Maps JS (`PlanMapHtml`: `callback=initMap&loading=async` + `Marker`)
- Tests: `test/features/calendar/plan_map_stop_builder_test.dart`

## Pruebas (humano)

- Online iOS/Android: [TESTING_CHECKLIST.md](../configuracion/TESTING_CHECKLIST.md) **EVENT-MAP-001** (iPhone 2026-09-05: mapa OK con red).
- Offline móvil: **OFF-005** — lista del recorrido desde caché; el mapa Google no es obligatorio sin red. Proceso: [`TESTING_OFFLINE_FIRST.md`](../testing/TESTING_OFFLINE_FIRST.md). Dominio eventos: [`CHECKLIST_CRUD_EVENTOS.md`](../testing/CHECKLIST_CRUD_EVENTOS.md) **E13**.
