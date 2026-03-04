# T246 – Rellenar evento desplazamiento por número de vuelo o tren

**Objetivo:** Al crear (o editar) un **evento de tipo Desplazamiento**, el usuario puede introducir un **número de vuelo** (ej. IB6842, AF1135) o un **número de tren** (según operador), y una API devuelve los datos del trayecto para rellenar automáticamente el evento: origen, destino, hora salida, hora llegada, descripción, etc. Misma idea que Google Places para alojamientos, pero para desplazamientos.

**Requisitos:** Elegir y configurar API(s) para vuelos y/o trenes; campo opcional en el modal de evento (visible cuando tipo = Desplazamiento); llamada desde backend/Cloud Function para no exponer API keys; mapeo de la respuesta al modelo del evento.

---

## Estado

**Estado:** ✅ Fase 1 implementada (vuelos con Amadeus).  
**Configuración:** Ver `docs/configuracion/CONFIGURAR_AMADEUS_FLIGHT_STATUS.md`.

---

## Lo que queda por hacer (pendiente)

Documentado para retomarlo cuando se quiera, sin codificar aún:

### Configuración y pruebas (Fase 1 – vuelos)

- [ ] **Configurar Amadeus en Firebase:** Crear cuenta en [developers.amadeus.com](https://developers.amadeus.com), obtener API Key (client_id) y Secret (client_secret). Ejecutar:
  ```bash
  firebase functions:config:set amadeus.client_id="..." amadeus.client_secret="..."
  ```
- [ ] **Desplegar la Cloud Function** `flightStatus`: `cd functions && npm run deploy`.
- [ ] **Probar en la app:** Crear evento → Desplazamiento / Avión → número de vuelo (ej. IB6842) → "Obtener datos del vuelo". Comprobar que se rellenan descripción, fecha, hora y duración.
- [ ] **Ajustar mapeo si hace falta:** La Cloud Function normaliza la respuesta de Amadeus (`departure`, `arrival`, etc.). Si en pruebas reales la API devuelve otros nombres de campos, actualizar la normalización en `functions/index.js` (bloque que construye el objeto de retorno).

### Mejoras opcionales (Fase 1)

- [ ] **Campo explícito "Fecha del vuelo":** Ahora se usa la fecha del evento. Si se quiere que el usuario pueda buscar un vuelo por fecha antes de elegir día en el calendario, añadir un campo opcional "Fecha del vuelo" y usarlo en la llamada a la API.
- [ ] **Mostrar más datos en la tarjeta:** Horario salida/llegada y aerolínea en el resumen bajo el botón (ahora solo `shortDescription`: origen → destino).

### Documentación y flujos

- [x] **TESTING_CHECKLIST.md:** Casos EVENT-C-020 (crear evento con número de vuelo) y EVENT-C-021 (editar y volver a obtener datos).
- [x] **FLUJO_CRUD_EVENTOS.md:** Añadido punto "Número de vuelo (T246)" en Completar campos del flujo de creación manual.
- [x] **REGISTRO_OBSERVACIONES_PRUEBAS.md:** Añadido en "Cambios recientes" la funcionalidad T246.

### Fase 2 – Trenes (no iniciada)

- [ ] Decidir alcance: solo Renfe (España) o también otros operadores.
- [ ] Cloud Function (o endpoint) que consulte Renfe Open Data (o SNCF, etc.) por número de tren / fecha.
- [ ] En el modal de evento: cuando tipo = Desplazamiento y subtipo = Tren, mostrar campo "Número de tren" + operador (o selector) y botón "Obtener datos del tren".
- [ ] Mapeo de respuesta a descripción, fecha/hora y extraData (trainNumber, originStation, destinationStation, etc.).

---

**Recomendación para Fase 1 (vuelos):** **Amadeus for Developers** — cuota gratuita en test y producción, On-Demand Flight Status API (consulta por número de vuelo + fecha), sin coste inicial ni mínimo mensual; solo pay-as-you-go si se supera la cuota.

---

## APIs disponibles (resumen)

### Vuelos – búsqueda por número de vuelo

Google **no** ofrece una API pública para consultar vuelos por número. Opciones de terceros:

| Proveedor | Búsqueda por número | Datos típicos | Plan gratuito | Notas |
|-----------|---------------------|---------------|----------------|-------|
| **Amadeus for Developers** | **On-Demand Flight Status API**: número de vuelo + fecha | Origen/destino, horarios, terminal/puerta, duración, estado, retrasos | **Cuota mensual gratuita** en test y producción; luego pay-as-you-go. Ver [Pricing](https://developers.amadeus.com/pricing). | Plataforma GDS; ideal para “rellenar evento por número”. OAuth 2.0, SDKs. |
| **AviationStack** | `flight_iata` (ej. IB6842), `flight_icao`, opcional `flight_date` | Origen/destino (IATA/ICAO), hora salida/llegada (scheduled/actual), aerolínea, estado | 100 req/mes gratis (uso personal) | Muy usado; respuesta JSON clara. |
| **AirLabs** | IATA/ICAO flight number | Origen, destino, tiempos, aeronave, estado | Tier gratuito limitado | Alternativa a AviationStack. |
| **FlightLabs (GoFlightLabs)** | Flight number | Similar a arriba | Prueba gratuita (solo pruebas) | Otra opción. |
| **Sabre** | Búsqueda/precios; no “status by number” estándar | GDS: inventario, reservas | Solo sandbox gratis; producción por contrato (mensualidad alta). | Ver § Precios – Sabre y Travelport. |
| **Travelport (Universal API)** | **Flight Information**: número + carrier + fecha | Horarios, puertas, retrasos, estado | Trial 30 días; producción por contrato. | Encaja con “por número” pero sin tier gratuito en prod. |

- El usuario puede escribir **código IATA** (ej. `IB6842`) o solo número; conviene aceptar ambos y normalizar (añadir código aerolínea si solo ponen "6842" para Iberia).
- Para **fecha**: si el usuario no la indica, se puede usar la fecha del evento; si la indica, pasarla a la API para obtener el vuelo concreto (un mismo número opera varios días).

**Ejemplo AviationStack (flights):**
```
GET https://api.aviationstack.com/v1/flights?access_key=XXX&flight_iata=IB6842&flight_date=2025-03-15
```
Respuesta incluye: `departure` (airport, scheduled_time, timezone), `arrival` (idem), `flight` (number, status), `airline`.

---

### Trenes – búsqueda por número de tren / itinerario

No hay una **API global** de trenes por número. Depende del país/operador:

| Ámbito | API / Fuente | Búsqueda por número | Notas |
|--------|--------------|----------------------|-------|
| **España (Renfe)** | Renfe Open Data (CKAN DataStore) | SQL / filtros por recurso; hay datasets por tipo de tren | Sin API key. Base: `https://data.renfe.com/api/3/action/datastore_search` o `datastore_search_sql`. |
| **Francia (SNCF)** | SNCF Open Data / SNCF Voyageurs | Búsqueda por número de tren y fecha en la web; API para partners/integración | Documentación en data.sncf.com. |
| **Varios países (Europa)** | TheTrainline Global API | Cobertura multi-operador | Orientado a partners/comercial. |

- Para **MVP** tiene sentido empezar por **vuelos** (APIs más estándar y un solo proveedor tipo AviationStack) y, si se quiere, añadir **Renfe** en una segunda fase (España; sin coste de API pero integración más específica).

---

## Precios de las APIs (referencia)

### Vuelos – plataformas tipo Amadeus (consulta gratuita)

| Proveedor | ¿Gratis? | Detalle | Caso de uso “por número de vuelo” |
|-----------|----------|---------|------------------------------------|
| **Amadeus for Developers** | **Sí, con cuota gratuita** en test y en producción. | Entorno **test**: cuota mensual gratuita por API (límite varía por API), 10 TPS, datos cacheados. **Producción**: misma cuota gratuita; al superarla, pay-as-you-go según [Pricing](https://developers.amadeus.com/pricing). Sin coste inicial; solo pagas por uso extra. | **On-Demand Flight Status API**: consulta por número de vuelo (y fecha). Devuelve origen, destino, horarios, terminal/puerta, estado. Ideal para “rellenar evento por número de vuelo”. |
| **Skyscanner (Partners)** | **Gratis** para partners aprobados. | Sin cuota por petición ni cuota fija; modelo por **revenue share** (comisión por reservas). Requiere **solicitud y aprobación** como partner; debes mostrar deeplinks de reserva. No es “API abierta” para cualquier app. | Búsqueda de vuelos (origen/destino/fechas), no búsqueda directa “por número de vuelo”. |

**Resumen Amadeus:** Cuenta gratuita, entorno test con cuota gratis, y en producción mantienes esa cuota; el **On-Demand Flight Status** encaja con “usuario escribe IB6842 → rellenar evento”. Las cifras exactas de peticiones gratis por API están en [developers.amadeus.com/pricing](https://developers.amadeus.com/pricing).

### Vuelos – otros proveedores (AviationStack, AirLabs, etc.)

| Proveedor | Plan gratuito | Planes de pago (mensual) | Exceso (overage) |
|-----------|----------------|---------------------------|-------------------|
| **AviationStack** | **0 €/mes** – 100 peticiones/mes, uso personal, sin soporte. | **Basic:** 49,99 $/mes (44,99 $/año) → 10.000 req. **Professional:** 149,99 $/mes (131,99 $/año) → 50.000 req. **Business:** 499,99 $/mes (424,99 $/año) → 250.000 req. **Enterprise:** a medida. | Basic: ~0,01 $/req extra. Pro: ~0,006 $/req. Business: ~0,004 $/req. |
| **AirLabs** | Tier gratuito con límite de consultas/mes (detalle en airlabs.co). | Planes por niveles; facturación mensual o anual. Precios concretos solo en registro/contacto. | Pago por consulta adicional según plan. |
| **GoFlightLabs / FlightLabs** | Prueba gratuita solo para **uso personal y pruebas**; no uso comercial/público. | Planes de pago y **Enterprise** para uso comercial; precios bajo solicitud. | — |

**Resumen vuelos:** Para **consulta por número de vuelo con opción gratuita seria**, **Amadeus** (cuota gratis en test y producción) es la opción más sólida. Alternativas sin aprobación: **AviationStack Free** (100 req/mes) o **AirLabs** free tier. Para volumen comercial: AviationStack Basic (~50 $/mes, 10k req) o Amadeus pay-as-you-go tras la cuota gratis.

### Sabre y Travelport (GDS – sin tier gratuito en producción)

| Proveedor | ¿Gratis? | Detalle | “Por número de vuelo” |
|-----------|----------|---------|------------------------|
| **Sabre** (sabre.com / developer.sabre.com) | **Solo sandbox** para desarrollo. **No hay tier gratuito en producción.** | Producción: acuerdo comercial. Costes típicos (orientativos): setup único ~500–1.500 $, **suscripción mensual ~300–5.000+ $** según módulos y volumen, más comisión por reserva (2–5 %) y fees GDS. Precios no públicos; por región y contrato. | APIs de vuelos (búsqueda, precios, etc.); documentación en [Dev Studio](https://developer.sabre.com/). No hay un “Flight Status by number” tan explícito como Amadeus; se suele usar para búsqueda y reserva, no solo consulta de estado. |
| **Travelport** (Universal API) | **Prueba de 30 días** (sandbox) para evaluación. **Sin tier gratuito permanente en producción.** | Tras el trial hay que firmar contrato y contactar ventas (MyTravelport). Precios y condiciones por acuerdo comercial; no publicados. | **Flight Information**: consulta por **número de vuelo + compañía + fecha** ([Flight Information](https://support.travelport.com/webhelp/uapi/Content/Air/Flight_Information/Flight_Information.htm)). Devuelve horarios, puertas, retrasos, estado. Ideal para “rellenar evento por número”, pero **acceso solo comercial**. |

**Resumen:** Sabre y Travelport son GDS orientados a agencias y volumen. No ofrecen cuota gratuita en producción como Amadeus; tienen sandbox/trial para probar, pero el uso real requiere contrato y costes mensuales relevantes. Para un producto tipo Planazoo (consultas puntuales por número de vuelo), **Amadeus for Developers** o **AviationStack** siguen siendo opciones más adecuadas que Sabre/Travelport a menos que ya se tenga contrato GDS.

### Trenes

| Proveedor | Coste |
|-----------|--------|
| **Renfe Open Data** | **Gratis.** Sin API key para lectura pública. Límites por uso/ratio según portal de datos. |
| **SNCF Open Data** | **Gratis** hasta **5.000 peticiones/día**. Por encima, modelo de pago (contacto SNCF). Requiere registro para token. |
| **TheTrainline Global API** | **Contacto comercial** (Corporate.Sales@thetrainline.com). Sin precios públicos. |

**Resumen trenes:** Renfe y SNCF Open Data permiten uso gratuito dentro de límites generosos; TheTrainline es para integraciones comerciales con presupuesto.

---

## Propuesta de implementación

### Alcance sugerido (por fases)

1. **Fase 1 – Solo vuelos**
   - En el modal de evento, cuando el usuario elige tipo **Desplazamiento**, mostrar un campo opcional **“Número de vuelo”** (ej. IB6842).
   - Opcional: campo **Fecha del vuelo** (por defecto = fecha del evento).
   - Al pulsar “Buscar” o al salir del campo (según UX): llamar a una **Cloud Function** que consulte AviationStack (u otro) con `flight_iata` + `flight_date`, y devuelva JSON con origen, destino, hora salida, hora llegada, nombre aerolínea, etc.
   - La app rellena: descripción (ej. “IB6842 Madrid – Roma”), fecha/hora inicio y fin (o duración), y opcionalmente origen/destino en `location` o `extraData` (por ejemplo `originIata`, `destinationIata`, `flightNumber`).

2. **Fase 2 (opcional) – Trenes**
   - Campo **“Número de tren”** (y operador o país) o selector de operador (ej. Renfe) + número.
   - Cloud Function que llame a Renfe Open Data (o en el futuro SNCF/TheTrainline) y devuelva datos equivalentes.
   - Mismo mapeo: descripción, hora salida/llegada, origen/destino en el evento.

### Modelo de datos del evento

- Ya existente: `EventCommonPart` (descripción, fecha/hora, tipo, subtipo, `location`, `extraData`).
- En `extraData` se puede guardar, por ejemplo:
  - `flightNumber`, `flightIata`, `originIata`, `originName`, `destinationIata`, `destinationName`, `airlineName`, `departureScheduled`, `arrivalScheduled` (vuelos).
  - `trainNumber`, `trainOperator`, `originStation`, `destinationStation`, etc. (trenes).

### Seguridad y costes

- **API key** de AviationStack (u otro) solo en backend (Cloud Function); la app nunca expone la key.
- Plan gratuito AviationStack: 100 peticiones/mes; si se supera, plan de pago o límite por usuario.
- Renfe Open Data: sin API key; límites por uso/ratio si los hay en el portal.

### UX (alineado con T225 – Places)

- Misma estética que el resto del modal (tipo login).
- Bloque “Desplazamiento” con:
  - Tipo de transporte: **Vuelo** | **Tren** (en Fase 2).
  - Campo “Número de vuelo” (ej. IB6842) + opcional “Fecha del vuelo”.
  - Botón “Obtener datos del vuelo” (o búsqueda automática al validar).
  - Tarjeta de resumen con origen → destino, horarios, aerolínea; botón “Rellenar evento” o rellenado automático al recibir datos.

---

## Preguntas para el usuario

1. **Alcance:** ¿Empezamos solo con **vuelos** (Fase 1) y dejamos trenes para más adelante?
2. **Proveedor vuelos:** ¿Te encaja **AviationStack** (100 req/mes gratis) o prefieres otro (AirLabs, FlightLabs)?
3. **Fecha del vuelo:** ¿Siempre usar la fecha del evento como fecha del vuelo, o quieres campo explícito “Fecha del vuelo” por si el usuario la introduce antes de elegir día en el calendario?
4. **Trenes:** Si quieres trenes en el MVP, ¿solo Renfe (España) o también otros operadores (SNCF, etc.)?

---

## Referencias

- **Configuración Amadeus:** `docs/configuracion/CONFIGURAR_AMADEUS_FLIGHT_STATUS.md`.
- **Código:** Cloud Function `flightStatus` en `functions/index.js`; servicio `lib/features/flights/data/flight_status_service.dart`; DTO `flight_status_result.dart`; UI en `lib/widgets/wd_event_dialog.dart` (bloque "Número de vuelo" cuando Desplazamiento + Avión).
- [Amadeus On-Demand Flight Status](https://developers.amadeus.com/self-service/category/flights/api-doc/on-demand-flight-status).
- [AviationStack – Flights API](https://aviationstack.com/documentation) (parámetros `flight_iata`, `flight_icao`, `flight_date`).
- [Renfe Open Data](https://data.renfe.com/) – CKAN DataStore.
- T225 (Google Places): flujo equivalente para alojamientos/eventos con búsqueda de lugar; mismo patrón “campo + API → rellenar formulario”.
- Flujo eventos: `docs/flujos/FLUJO_CRUD_EVENTOS.md`.
