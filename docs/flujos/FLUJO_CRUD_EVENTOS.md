# 📅 Flujo de Vida Completa de Eventos (CRUD)

> Define todo el ciclo de vida de un evento: crear, leer, actualizar y eliminar

**Relacionado con:** T121, T105, T110, T101, T102, T120  
**Versión:** 1.0  
**Fecha:** Enero 2025

---

## 🎯 Objetivo

Documentar todos los escenarios del ciclo de vida completo de un evento: desde su creación hasta su eliminación, incluyendo lectura, visualización, actualizaciones, importación y sincronización con proveedores.

---

## 📊 ESTADOS DE EVENTOS

| Estado | Descripción | Editable | Eliminable | Visible Para |
|--------|-------------|----------|------------|--------------|
| **Borrador** | Evento en creación | ✅ Todo | ✅ Sí | Solo creador |
| **Pendiente** | Evento creado, no confirmado | ✅ Casi todo | ✅ Sí | Asignados + organizador |
| **Confirmado** | Evento confirmado | ⚠️ Limitado | ⚠️ Con confirmación | Todos |
| **En Curso** | Evento ejecutándose | ⚠️ Solo urgente | ❌ No | Todos |
| **Completado** | Evento terminado | ❌ No | ❌ No | Todos |
| **Cancelado** | Evento cancelado | ❌ No | ❌ No | Todos |

---

## 📋 CICLO DE VIDA DE EVENTOS

### 1. CREAR EVENTO

#### 1.1 - Creación Manual (Durante Planificación)

**Cuándo:** Durante planificación normal del plan  
**Quién:** Organizador o participante con permisos

**Flujo completo:**
```
Usuario → "Añadir evento"
  ↓
Abrir formulario (T121)
  ↓
Completar campos:
- Título (requerido)
- Fecha (dentro del rango del plan)
- Hora inicio
- Duración
- Tipo (Desplazamiento/Restauración/Actividad/Alojamiento)
- Subtipo (Avión/Tren/Hotel/Restaurante/etc.)
- Participantes asignados
- Ubicación (opcional)
- Presupuesto si aplica (T101)
- Coste por persona o total (T101)
  ↓
Validaciones (T51):
- Título no vacío
- Fecha dentro del rango del plan
- Participantes existen
- No solapamientos (si no es borrador)
- Timezone válido
- Ubicación coherente con tipo
  ↓
Guardar evento
  ↓
Crear evento en calendario
Asignar a tracks de participantes
Detectar solapamientos
  ↓
Notificar a participantes asignados (T105)
Actualizar presupuesto (T101)
  ↓
Estado: "Pendiente" o "Confirmado"
```

#### 1.2 - Creación desde Importación JSON

**Cuándo:** Usuario importa eventos desde archivo JSON  
**Quién:** Organizador

**Flujo:**
```
Organizador → Plan → "Importar eventos"
  ↓
Seleccionar archivo JSON
  ↓
Validar formato JSON y versión:
{
  "formatVersion": "1.0",
  "events": [
    {
      "title": "Vuelo Madrid → Sydney",
      "type": "Desplazamiento",
      "subtype": "Avión",
      "date": "2025-10-22",
      "startTime": "20:00",
      "duration": 840,
      "timezone": "Europe/Madrid",
      "arrivalTimezone": "Australia/Sydney",
      "location": {...},
      "participants": ["user1"],
      "cost": 300.00
    }
  ]
}
  ↓
Preview de eventos a importar:
"Se importarán [N] eventos

1. Vuelo Madrid → Sydney (22/10)
2. Taxi al hotel (23/10)
..."
  ↓
Validar cada evento:
- Fecha en rango del plan
- Participantes existen en el plan
- Sin solapamientos con eventos existentes
- Ubicación válida
  ↓
Mostrar errores si los hay:
"⚠️ Errores detectados:
- Evento 3: Usuario 'x' no está en el plan
- Evento 5: Fecha fuera del rango

¿Importar eventos válidos?"
  ↓
Usuario selecciona [Importar todos] / [Solo válidos]
  ↓
Crear cada evento válido
  ↓
Mostrar resumen:
"✅ [N] eventos importados
⚠️ [M] eventos omitidos (errores)"
```

#### 1.3 - Creación con Sincronización de Proveedor

**Cuándo:** Usuario conecta evento con proveedor externo  
**Quién:** Usuario con el evento

**Flujo:**
```
Usuario → Evento → "Conectar con proveedor"
  ↓
Buscar proveedor en catálogo:
- Iberia (vuelos)
- Renfe (trenes)
- Hilton (hoteles)
- Restaurante X (restauración)
  ↓
Seleccionar proveedor
  ↓
Modal de autorización:
"Conectar evento con [Proveedor]?

El proveedor podrá actualizar automáticamente:
- Hora de salida/llegada
- Puerta/terminal
- Cancelaciones
- Otros cambios

¿Autorizar conexión?"
  ↓
Autorizar → Generar token de API
  ↓
Guardar configuración de API en evento
  ↓
Proveedor ahora puede actualizar evento
  ↓
Badge en evento: "✅ Actualizado por [Proveedor]"
```

**Sincronización automática:**
```
Sistema verifica actualizaciones periódicamente
  ↓
Proveedor tiene cambios
  ↓
API del proveedor: GET /api/v1/event-updates/{eventId}
{
  "eventId": "abc123",
  "updatedAt": "2025-01-15T10:30:00Z",
  "changes": {
    "departureTime": "20:30",  // Era 20:00
    "gate": "A5"  // Era A3
  },
  "metadata": {
    "provider": "Iberia",
    "reservationNumber": "IBE123"
  }
}
  ↓
Mostrar al usuario:
"El evento 'Vuelo a Sydney' ha sido actualizado por Iberia

Cambios:
- Hora de salida: 20:00 → 20:30
- Puerta: A3 → A5

[Aceptar cambios] [Ver detalles] [Ignorar]"
  ↓
Si acepta: Actualizar evento
  ↓
Notificar a participantes (T105)
Actualizar alarmas (T110)
```

#### 1.4 - Creación de Evento Urgente (Durante Ejecución)

**Cuándo:** Durante ejecución del plan, decisión de último momento  
**Quién:** Solo organizador

**Flujo:**
```
Organizador → "Crear evento urgente"
  ↓
Modal de advertencia: "⚠️ CREAR EVENTO URGENTE

Este evento se ejecutará muy pronto.

¿Continuar?"
  ↓
Formulario simplificado:
- Título
- Hora (próximas 6h)
- Ubicación
- Participantes (auto-asignar a todos)
  ↓
Configurar alarma inmediata (T110)
  ↓
Guardar con estado "Confirmado"
  ↓
Notificar urgentemente a todos (T105)
  ↓
Aparece en calendario en tiempo real
```

---

### 2. LEER/VISUALIZAR EVENTO

#### 2.1 - Vista Detallada del Evento

**Flujo:**
```
Usuario hace click en evento
  ↓
Mostrar modal/detalle completo:
┌────────────────────────────────────┐
│ Vuelo Madrid → Sydney              │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                    │
│ 📅 Fecha: 22/10/2025               │
│ 🕐 Hora: 20:00h - 10:00h          │
│ 📍 Origen: Madrid (T4)           │
│ 📍 Destino: Sydney                │
│ 👥 Participantes:                 │
│    • Juan (organizador)           │
│    • María                        │
│    • Pedro                        │
│                                    │
│ 💰 Coste: €300 (€100/persona)     │
│ 🔄 Actualizado por: Iberia       │
│                                    │
│ [Editar] [Eliminar] [Ver historial]
└────────────────────────────────────┘
```

#### 2.2 - Información Contextual

**Campos mostrados:**
- Título, fecha, hora
- Duración y ruta (para desplazamientos)
- Ubicaciones (origen y destino)
- Participantes con roles
- Coste y presupuesto (T101)
- Estado del evento
- Historial de actualizaciones automáticas
- Próximo evento relacionado

---

### 3. ACTUALIZAR EVENTO

#### 3.1 - Actualizar Hora del Evento

**Escenarios según magnitud:**

##### Cambio Leve (<1h)
```
Editar hora: 20:00 → 20:30

Acción: Editar y guardar
Notificación: Email estándar
Reconfirmación: No requerida
```

##### Cambio Significativo (1-4h)
```
Editar hora: 20:00 → 22:00

Acción: Editar y guardar
Notificación: Email + Push urgente
Reconfirmación: Opcional
```

##### Cambio Drástico (>4h o cambio de día)
```
Editar: Lunes 20:00 → Martes 08:00

Acción: Modal de confirmación crítica
Notificación: Email + Push críticos
Reconfirmación: OBLIGATORIA
```

#### 3.2 - Actualizar Ubicación

**Escenarios según distancia:**
- Misma ubicación → Notificación baja
- Cercano (<2km) → Notificación normal
- Lejano (>2km) → Notificación alta
- Otra ciudad/país → Reconfirmación obligatoria

#### 3.3 - Actualizar Participantes

**Añadir participante:**
- Actualizar track
- Notificar participante añadido
- Notificar a otros (si límite de plazas)
- Recalcular presupuesto

**Eliminar participante:**
- Actualizar track
- Notificar participante eliminado
- Calcular reembolso si pagó (T102)

#### 3.4 - Actualizar Presupuesto

**Flujo:**
```
Editar coste del evento
  ↓
Actualizar presupuesto total (T101)
  ↓
Recalcular distribución (T102)
  ↓
Notificar si cambio >€50 o >20%
```

#### 3.5 - Actualización Automática desde Proveedor

```
Proveedor actualiza evento vía API
  ↓
Usuario ve notificación: "Cambios pendientes"
  ↓
Usuario acepta/rechaza cambios
  ↓
Si acepta: Actualizar evento
Notificar a participantes
Actualizar alarmas
```

---

### 4. ELIMINAR EVENTO

#### 4.1 - Eliminar durante Planificación (>7 días antes)

**Flujo simple:**
```
Seleccionar evento
"Eliminar evento"
  ↓
Confirmación
  ↓
Eliminar de calendario
Eliminar de tracks
Recalcular presupuesto
  ↓
Notificar participantes
```

#### 4.2 - Eliminar cercano a ejecución (1-7 días)

**Flujo con advertencia:**
```
Seleccionar evento cercano
  ↓
Modal de advertencia:
"⚠️ ELIMINAR EVENTO CERCANO

Quedan [X] días.

¿Estás seguro?"

Razón (opcional)
  ↓
Eliminar + Notificar urgente
Calcular reembolsos
```

#### 4.3 - Cancelar evento inminente (<24h)

**NO se puede eliminar, solo cancelar:**
```
Seleccionar evento <24h
"Eliminar" → BLOQUEADO
  ↓
Mostrar opción: "Cancelar evento"
  ↓
Modal crítico:
"🚨 CANCELAR EVENTO INMINENTE

Este evento empieza en [X] horas.

Motivo de cancelación: [obligatorio]

¿Cancelar?"
  ↓
Marcar como "Cancelado" (no eliminar)
Notificar críticamente
Calcular reembolsos inmediatos
```

#### 4.4 - Evento pasado (no se puede eliminar)

```
Intento eliminar evento pasado
  ↓
Mostrar opciones alternativas:
- Marcar como "no realizado"
- Añadir nota post-evento
- Añadir foto
```

---

### 5. HISTORIAL Y AUDITORÍA

#### 5.1 - Ver Historial de Cambios

**Sistema de auditoría:**
```
Abrir evento
  ↓
"Ver historial de cambios"
  ↓
Timeline:
- [Hace 2 días] Juan cambió hora: 20:00 → 20:30
- [Hace 1 semana] María añadió participante Pedro
- [Hace 3 días] Sistema actualizó desde Iberia: puerta A3 → A5
- [Hace 2 semanas] Juan creó el evento
```

**Información registrada:**
- Quién hizo el cambio (usuario o proveedor)
- Cuándo (timestamp)
- Qué cambió (campo)
- De/ A (valores)
- Motivo (opcional)

---

## 🔔 NOTIFICACIONES POR TIPO DE CAMBIO

| Tipo de Cambio | Prioridad | Notificación | Canal |
|----------------|-----------|--------------|-------|
| Crear evento (planificación) | Normal | ✅ Email | Email estándar |
| Crear evento (urgente) | Alta | ✅ Sí | Email + Push urgente |
| Cambio hora <1h | Baja | ⚠️ Opcional | Email + Push opcional |
| Cambio hora 1-4h | Alta | ✅ Sí | Email + Push |
| Cambio hora >4h | Crítica | ✅ Sí urgente | Email + Push urgente |
| Cambio día | Crítica | ✅ Sí urgente | Email + Push urgente |
| Cambio ubicación cercana | Normal | ✅ Email | Email estándar |
| Cambio ubicación lejana | Alta | ✅ Urgente | Email + Push |
| Cambio ciudad/país | Crítica | ✅ Crítico | Email + Push + SMS |
| Añadir participante | Normal | ✅ Sí | Email + Push |
| Eliminar participante | Alta | ✅ Sí urgente | Email + Push |
| Eliminar evento >7 días | Normal | ✅ Email | Email estándar |
| Eliminar evento 1-7 días | Crítica | ✅ Urgente | Email + Push urgente |
| Cancelar evento <24h | Crítico | ✅ Crítico | Email + Push + SMS |
| Actualización automática proveedor | Normal | ⚠️ Pendiente aprobación | Notificación en app |

---

## 📋 TAREAS RELACIONADAS

**Pendientes:**
- T121: Formularios enriquecidos para eventos
- T105: Sistema de notificaciones
- T110: Sistema de alarmas
- T120: Sistema de reconfirmación
- T51: Validación de formularios
- T101: Integración con presupuesto
- T102: Integración con pagos
- Historial de cambios/auditoría
- Importación JSON
- API de sincronización con proveedores

**Completas ✅:**
- Crear eventos básicos
- Modificar eventos básicos
- Sistema de tracks
- Timezone-aware

---

## ✅ IMPLEMENTACIÓN ACTUAL

**Estado:** ⚠️ Básico implementado

**Lo que ya funciona:**
- ✅ Crear eventos básicos
- ✅ Editar título, fecha, hora, duración
- ✅ Asignar participantes
- ✅ Gestionar timezones
- ✅ Sistema de tracks

**Lo que falta (CRÍTICO):**
- ❌ Formularios específicos por tipo (T121)
- ❌ Estados de evento (Pendiente, Confirmado, etc.)
- ❌ Reconfirmación para cambios drásticos (T120)
- ❌ Notificaciones automáticas (T105)
- ❌ Sistema de alarmas (T110)
- ❌ Historial de cambios
- ❌ Integración presupuesto/pagos (T101/T102)
- ❌ Importación JSON
- ❌ API de sincronización con proveedores

---

*Documento de flujo CRUD completo de eventos*  
*Última actualización: Enero 2025*

