# T266 — Asistente por reglas (sugerencias inteligentes de eventos)

**Estado:** Pendiente (definición de producto; sin implementar hasta cerrar alcance).  
**Origen:** Ítem QA 98 → T266. Ampliado 2026-08 con catálogo de casos.  
**Relacionado:** T246 (vuelo por número), T243 (copiar), T250 / `EVENT_FORM_FIELDS.md`, T271 (fotos Places), helpers de hotel/origen-destino en evento.

---

## 1. Objetivo

Ayudar al usuario a **completar el itinerario** sugiriendo eventos derivados (sobre todo desplazamientos y acciones de viaje) de forma rápida, con reglas deterministas y confirmación en 1–2 toques. No es un chat IA genérico en esta fase.

---

## 2. Principios UX

- Sugerir **después** de crear/editar un evento o al detectar un hueco claro; nunca crear eventos en silencio.
- Presentación: bottom sheet / chips tipo *«¿Añadir taxi Hotel → Coliseo?»* con aceptar / elegir modo / descartar.
- Origen/destino por defecto: hotel del día, hotel D-1, ubicación del evento anterior o destino del último trayecto (ya parcialmente en app).
- Duración: valor por defecto editable; ETA real solo si más adelante hay Routes/Maps de pago.
- Todas las sugerencias deben ser **desactivables** (no molestar) a nivel usuario/plan (definir en implementación).

---

## 3. Catálogo de reglas (casos)

### A. Desplazamientos (núcleo)

| ID | Disparador | Sugerencia |
|----|------------|------------|
| R01 | Actividad (monumento, museo, etc.) con ubicación | Desplazamiento **hacia** el sitio desde “dónde estoy” |
| R02 | Tras actividad, siguiente evento lejos / sin transporte | Desplazamiento de vuelta a hotel o al siguiente sitio |
| R03 | Dos eventos seguidos en sitios distintos con hueco | Rellenar hueco (taxi / caminar / coche) |
| R04 | Avión (llegada) | Transfer/taxi/shuttle **aeropuerto → hotel** |
| R05 | Avión (salida) | Hotel → aeropuerto + Tiempo en aeropuerto (+ Embarque opcional) |
| R06 | Tren/Autobús llegada o salida | Estación ↔ hotel / siguiente evento |
| R07 | Check-in alojamiento nuevo | Trayecto hacia el hotel |
| R08 | Cambio de hotel entre noches | Desplazamiento entre alojamientos |
| R09 | Desplazamiento con origen/destino incompleto | Autocompletar con hotel D-1 / hotel del día |

### B. Paquetes de viaje

| ID | Disparador | Paquete |
|----|------------|---------|
| R10 | Vuelo de salida | Tiempo en aeropuerto + Embarque + Vuelo (+ taxi hotel→aero) |
| R11 | Vuelo de llegada | Vuelo + Transfer + (opcional) enlace a hotel |
| R12 | Recogida vehículo alquiler | Sugerir **Entrega** el día checkout / fin de uso |
| R13 | Punto de encuentro grupal | Recordatorio + desplazamientos si hay ubicaciones |

### C. Restauración y ritmo del día

| ID | Disparador | Sugerencia |
|----|------------|------------|
| R14 | Día con actividades y sin comida 12–15 / 19–22 | Comida / Cena cerca de última actividad o hotel |
| R15 | Sin desayuno y hay hotel | Desayuno en hotel / cerca |
| R16 | Actividad larga a mediodía | Snack / pausa opcional |

### D. Alojamientos ↔ calendario

| ID | Disparador | Sugerencia |
|----|------------|------------|
| R17 | Nuevo alojamiento | Acciones/eventos ligeros check-in / check-out (opcional) |
| R18 | Día del plan sin hotel en rango | Aviso + crear alojamiento |
| R19 | Hueco entre checkout y siguiente hotel | Desplazamiento o “día en tránsito” |

### E. Aceleradores de datos (no crean evento solos)

| ID | Disparador | Ayuda |
|----|------------|-------|
| R20 | Número de vuelo (T246) | Rellenar origen/destino/horas |
| R21 | Places al elegir lugar | Nombre, dirección, web (+ foto T271 futuro) |
| R22 | Duplicar día/plan (T243) | Reutilizar plantilla de itinerario |
| R23 | Parseo email reserva | Crear vuelo/hotel/restaurante desde correo |

### F. Colaboración

| ID | Disparador | Ayuda |
|----|------------|-------|
| R24 | Propuesta de visita aceptada | Ofertar desplazamiento asociado |
| R25 | Varios participantes, mismo día | Punto de encuentro común |

---

## 4. MVP propuesto (priorizar)

Implementar primero (alto valor, datos ya disponibles):

1. **R01** — Actividad con sitio → desplazamiento desde hotel/evento anterior  
2. **R04** — Vuelo llegada → transfer al hotel  
3. **R05** — Vuelo salida → hotel → aeropuerto + tiempo en aeropuerto  
4. **R03** — Hueco entre dos sitios → transporte intermedio  
5. **R09** — Ampliar autocompletado origen/destino con hoteles  

El resto queda en backlog de la misma tarea / fases siguientes.

---

## 5. Criterios antes de implementar

- [ ] Validar con producto el MVP (lista §4).  
- [ ] Definir copy ES/EN y momentos de disparo (tras guardar vs al abrir día).  
- [ ] Definir métricas mínimas: sugerencias mostradas / aceptadas / descartadas.  
- [ ] No depender de Directions API de pago en MVP (duración por defecto).  
- [ ] Documentar reglas activas en código (ids Rxx) para tests.

---

## 6. Notas técnicas (borrador)

- Motor de reglas puro en domain (entrada: eventos + alojamientos del día; salida: `Suggestion` con tipo/subtipo, horas, origen/destino).  
- Reutilizar `PreviousPlanLocationHelper` y campos `taxiOriginAddress` / `taxiDestinationAddress`.  
- UI: sheet reutilizable desde calendario y modal de evento.  
- Tests unitarios por regla (R01, R03, R04, R05, R09 como mínimo del MVP).
