# T247 – Eventos conectados a proveedores externos (Amadeus, email, etc.)

**Objetivo:** Definir cómo marcar, mostrar y gestionar **eventos conectados** a fuentes externas (APIs como Amadeus, importación desde email, futuros conectores), y qué ocurre cuando el usuario modifica esos eventos (en el modal o arrastrando en el calendario).

**Motivación:** Tras T225 (Google Places) y T246 (Amadeus – número de vuelo), algunos eventos ya están “rellenados” con datos externos. El usuario debe:
- Saber **cuándo** un evento está conectado.
- Saber **qué pasa** si modifica datos que venían del proveedor.
- Poder **desconectarlo conscientemente** (y seguir editando a mano) sin romper nada silenciosamente.

---

## Estado

**Estado:** Pendiente (diseño y planificación).  
**Depende de:** T134 (eventos desde email), T225 (Places), T246 (Amadeus – vuelos).

---

## 1. Modelo de conexión

Añadir a `EventCommonPart` (o a nivel de `Event`) un bloque opcional `connection`:

```json
\"connection\": {
  \"provider\": \"amadeus\" | \"gmail\" | \"booking\" | \"renfe\" | ...,
  \"type\": \"flight\" | \"train\" | \"email-import\" | \"hotel\" | ...,
  \"externalId\": \"LH1126-2026-03-25\",   // ID del vuelo, código de reserva, messageId, etc.
  \"source\": \"T246\" | \"T134\" | ...,
  \"lastSyncAt\": \"2026-03-03T08:57:21.521Z\",
  \"fields\": [\"date\", \"hour\", \"duration\", \"location\", \"extraData.flightNumber\", ...]
}
```

Notas:
- `provider` + `type` + `externalId` permiten saber de dónde vino el evento y qué datos están “sincronizados”.
- `fields` indica qué campos fueron rellenados/actualizados por la conexión (para decidir cuándo avisar).
- Para T246, al rellenar datos desde Amadeus, se marcaría:
  - `provider = "amadeus"`, `type = "flight"`, `externalId = "<carrier><flightNumber>-<date>"`.
  - `fields` incluye: `date`, `hour`, `durationMinutes`, `extraData.flightNumber`, `extraData.originIata`, etc.

---

## 2. Visibilidad en la UI

### 2.1. Calendario (tarjetas de evento)

- Mostrar un **badge** discreto en la tarjeta cuando `connection` exista:
  - Ejemplos: `🔗 Amadeus`, `🔗 Email`, `🔗 Provider`.
  - Tooltip (en desktop) con texto tipo:
    > \"Este evento está conectado a Amadeus (vuelo). Algunos datos se rellenan automáticamente.\"

### 2.2. Modal de evento

- En la parte superior (o cerca del título), si `connection` existe:
  - Texto / chip: **“Evento conectado a Amadeus (vuelo)”**.
  - Mini texto secundario: “Fecha/hora y datos del vuelo se rellenan desde el proveedor”.
- En secciones específicas:
  - Vuelo (T246): cerca del bloque “Número de vuelo”, un texto tipo:
    > \"Datos sincronizados con Amadeus. Si cambias fecha/hora o el número de vuelo, se desconectará.\"

---

## 3. Comportamiento al modificar un evento conectado

### 3.1. Qué cambios disparan aviso

Solo cambios en **campos sincronizados** (los listados en `connection.fields`):
- Fecha (`date`), hora (`hour`/`startMinute`), duración (`durationMinutes`).
- Campos de ubicación ligados al proveedor (ej. aeropuerto origen/destino si en el futuro se mapean).
- Identificador del recurso: número de vuelo/tren, código de reserva, etc.

No disparan aviso:
- Color, notas personales, participantes asignados, coste, documentos adjuntos, etiquetas, etc.

### 3.2. Modal de confirmación

Cuando el usuario cambia un campo sincronizado (tanto en el modal como con drag & drop en calendario):

- Mostrar un diálogo:

> **Este evento está conectado a {providerName}.**  
> Si cambias estos datos, el evento dejará de actualizarse desde el proveedor.
>
> - **Desconectar y mantener mis cambios**
> - **Deshacer cambios y mantener conectado**

Comportamiento:
- **Desconectar y mantener mis cambios**:
  - Se aplica la edición.
  - Se elimina el bloque `connection` del evento (y opcionalmente se marca algo como `wasConnected = true` en `extraData` solo a efectos de trazabilidad).
- **Deshacer cambios y mantener conectado**:
  - Se revierten los cambios en los campos sincronizados (restaurar valores previos).
  - El bloque `connection` se mantiene intacto.

### 3.3. Drag & drop en calendario

- Al arrastrar un evento conectado:
  - Detectar si el cambio afecta a `date`/`hour`/`startMinute`.
  - Antes de confirmar el movimiento, mostrar el mismo diálogo de arriba.
- Si el usuario cancela:
  - Revertir la posición (volver a la celda original).

---

## 4. Testing (añadir a TESTING_CHECKLIST)

Sección sugerida: `4.3 Eventos conectados (T247)`:

- **EVENT-CONN-001:** Ver evento conectado en calendario
  - Pasos: Crear evento de vuelo con T246 (número de vuelo), guardar; volver al calendario.
  - Esperado: Tarjeta del evento muestra un badge/indicador de conexión (ej. “🔗 Amadeus”).
  - Estado: 🔄

- **EVENT-CONN-002:** Ver detalle de conexión en modal
  - Pasos: Abrir el evento conectado; observar cabecera y bloque del proveedor.
  - Esperado: Se ve texto “Evento conectado a Amadeus (vuelo)” o similar, indicando el origen de los datos.
  - Estado: 🔄

- **EVENT-CONN-003:** Editar fecha/hora de evento conectado (modal)
  - Pasos: Abrir evento conectado, cambiar fecha/hora y pulsar guardar.
  - Esperado: Aparece diálogo de confirmación (desconectar vs deshacer); al elegir “Desconectar y mantener mis cambios”, se guardan los cambios y el evento ya no muestra badge de conexión.
  - Estado: 🔄

- **EVENT-CONN-004:** Cancelar cambio para mantener conexión (modal)
  - Pasos: Mismo caso que anterior, pero elegir “Deshacer cambios y mantener conectado”.
  - Esperado: Fecha/hora vuelven a los valores originales; el evento sigue marcado como conectado.
  - Estado: 🔄

- **EVENT-CONN-005:** Drag & drop de evento conectado en calendario
  - Pasos: Arrastrar un evento conectado a otro día/hora.
  - Esperado: Aparece el mismo diálogo de confirmación; opciones funcionan igual (desconectar o revertir movimiento).
  - Estado: 🔄

---

## 5. Documentación y flujos

### 5.1. FLUJO_CRUD_EVENTOS.md

Actualizar:
- Sección **“Completar campos”** para mencionar:
  - Que algunos eventos pueden estar conectados a proveedores (Amadeus, email, etc.).
  - Que el bloque `ConnectProvider` / “Conexión Proveedor” permite ver el estado de conexión y (en el futuro) refrescar datos.
- Añadir subsección “**Eventos conectados**”:
  - Describir que ciertos eventos tienen datos rellenados por APIs externas.
  - Explicar el comportamiento al editar campos sincronizados (diálogo de desconexión).

### 5.2. CONFIGURAR_AMADEUS_FLIGHT_STATUS.md / otros docs de proveedor

Añadir una nota:
- “Los eventos creados o actualizados con esta API se marcarán como conectados a Amadeus. Si el usuario cambia manualmente la fecha/hora del vuelo, el evento se desconectará de Amadeus tras una confirmación explícita.”

### 5.3. REGISTRO_OBSERVACIONES_PRUEBAS.md

En “Cambios recientes”:
- Entrada para **T247 – Eventos conectados**:
  - Breve explicación del badge de conexión, el diálogo al editar y la lista de casos de prueba (`EVENT-CONN-001`…).

---

## 6. Pasos de implementación (resumen)

1. **Modelo**:
   - Extender `EventCommonPart` / `Event` para incluir `connection`.
   - Actualizar `fromFirestore` / `toFirestore`.

2. **Marcar eventos al crear/actualizar**:
   - T246 (Amadeus): al rellenar datos, establecer `connection` con provider `amadeus` y campos sincronizados.
   - (Futuro) T134/email: marcar eventos importados desde correo.

3. **UI**:
   - Badge en tarjetas del calendario.
   - Bloque “Evento conectado a …” en el modal de evento.

4. **Lógica de edición**:
   - Detectar cambios en campos listados en `connection.fields`.
   - Mostrar diálogo de desconexión.
   - Implementar las dos ramas: desconectar + mantener cambios, o revertir cambios.

5. **Testing y docs**:
   - Añadir casos `EVENT-CONN-001`…`005` a `TESTING_CHECKLIST.md`.
   - Actualizar `FLUJO_CRUD_EVENTOS.md` y `REGISTRO_OBSERVACIONES_PRUEBAS.md`.

