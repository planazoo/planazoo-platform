# ✅ Flujo de Validación y Verificación

> Define cómo validar que el plan es coherente y completo antes y durante la ejecución

**Relacionado con:** T51 - Validación de formularios (✅), T113, T114, T107  
**Versión:** 1.1  
**Fecha:** Enero 2025 (Actualizado)

---

## 🎯 Objetivo

Documentar el sistema de validación automática del plan para detectar incoherencias, incompletitudes y problemas antes y durante la ejecución.

---

## 📊 TIPOS DE VALIDACIÓN

| Tipo | Descripción | Cuándo se ejecuta | Prioridad |
|------|-------------|-------------------|-----------|
| **Solapamientos** | Eventos en el mismo momento para una persona | Al crear/editar evento | Crítica |
| **Días vacíos** | Días sin actividades asignadas | Al confirmar plan | Media |
| **Participantes sin eventos** | Participantes sin asignación | Al confirmar plan | Alta |
| **Eventos fuera de rango** | Eventos fuera de fechas del plan | Al crear/editar evento | Alta |
| **Timezones inconsistentes** | Cambios de timezone no coherentes | Al actualizar timezone | Media |
| **Check-in/Check-out** | Desajustes entre llegadas y alojamientos | Al confirmar plan | Media |
| **Rutas optimizadas** | Sugerencias de optimización de ruta | Opcional, manual | Baja |

---

## 📋 PROCESOS DE VALIDACIÓN

### 1. VALIDACIÓN DE SOLAPAMIENTOS

#### 1.1 - Detectar Solapamientos

**Algoritmo:**
```
Para cada evento nuevo/editado:
  1. Obtener lista de participantes asignados
  2. Para cada participante:
     a. Obtener todos sus eventos
     b. Comparar hora inicio/fin del evento nuevo con eventos existentes
     c. Detectar si hay solapamiento
  
  Si hay solapamiento:
    - Mostrar alerta
    - Mostrar evento(s) que chocan
    - Ofrecer opciones: Cancelar / Aceptar de todas formas / Modificar
```

**Detalles técnicos:**
- Considerar timezones de eventos
- Considerar timezone del participante
- Regla por estado del plan/evento:
  - Borrador/Planificando: permitir con confirmación explícita
  - Confirmado: bloquear salvo excepción marcada
  - En Curso: bloquear, solo cambios urgentes por organizador
  - Finalizado/Cancelado: no aplican cambios

**UI de la alerta:**
```
⚠️ SOLAPAMIENTO DETECTADO

El evento "Cena en restaurante X" (15/11 20:00-22:00)
se solapa con:
- "Concierto en Palacio" (15/11 20:00-23:00)

Participantes afectados:
- Juan Ramos (ambos eventos)

Opciones:
[Cancelar creación] [Aceptar solapamiento] [Modificar horario]
```

#### 1.2 - Permitir Solapamiento (casos excepcionales)

**Casos válidos:**
- Evento en estado borrador/planificando con confirmación
- Actividades compatibles (definidas como "compatibles")
- Eventos con "asistencia opcional" (no obligatoria)

**Flujo:**
```
Detectar solapamiento
  ↓
Modal: "⚠️ SOLAPAMIENTO"
  ↓
Opciones:
- "Es un borrador, permitir"
- "Actividades compatibles, continuar"
- "Cancelar y cambiar horario"
  ↓
Si continúa: Marcar como "solapamiento permitido" y registrar razón
```

---

### 2. VALIDACIÓN DE COMPLETITUD

#### 2.1 - Detectar Días Vacíos

**Algoritmo:**
```
1. Obtener rango del plan (fecha inicio → fecha fin)
2. Para cada día en el rango:
   a. Contar eventos del día
   b. Si eventos = 0: Marcar como "día vacío"
3. Mostrar lista de días vacíos
```

**UI:**
```
⚠️ Días sin actividades detectados:
- 12/11/2025 (Día 2)
- 14/11/2025 (Día 4)
- 17/11/2025 (Día 7)

¿Añadir eventos para estos días?
[Añadir eventos] [Ignorar]
```

**Consideraciones:**
- Puede ser intencional (días de descanso)
- Mostrar solo como advertencia, no error
- Permitir ignorar

#### 2.2 - Detectar Participantes sin Eventos

**Algoritmo:**
```
1. Obtener todos los participantes del plan
2. Para cada participante:
   a. Contar eventos asignados
   b. Si eventos = 0: Marcar como "sin asignación"
3. Mostrar lista de participantes sin eventos
```

**UI:**
```
⚠️ Participantes sin eventos asignados:
- Ana Martínez (0 eventos)
- Luis García (0 eventos)

¿Asignar automáticamente a eventos futuros?
[Asignar a todos] [Ver detalles] [Ignorar]
```

#### 2.3 - Detectar Eventos sin Participantes

**Algoritmo:**
```
1. Obtener todos los eventos del plan
2. Para cada evento:
   a. Contar participantes asignados
   b. Si participantes = 0: Marcar como "sin participantes"
3. Mostrar lista de eventos sin participantes
```

**UI:**
```
⚠️ Eventos sin participantes asignados:
- "Cena en Restaurante X" (15/11 20:00h)
- "Visita al Museo" (16/11 14:00h)

Estos eventos no se mostrarán en los calendarios de los participantes.
¿Asignar a todos los participantes?
[Asignar a todos] [Ver detalles] [Eliminar] [Ignorar]
```

---

### 3. VALIDACIÓN DE RANGO DEL PLAN

#### 3.1 - Evento Fuera del Rango del Plan

**Detección:**
```
Crear evento con fecha anterior a fecha inicio del plan
  ↓
Validación falla
  ↓
Alertar:
"❌ FECHA FUERA DE RANGO

Este evento está programado para el [fecha],
pero el plan comienza el [fecha inicio].

¿Quieres:
- Ajustar la fecha del evento a [fecha inicio]?
- Cambiar la fecha inicio del plan?
- Cancelar?"
```

**Solución automática (T107):**
```
Si evento sale fuera del rango:
1. Ofertar: "¿Expandir el plan?"
2. Si acepta: Actualizar fecha inicio/fin del plan
3. Recalcular columnCount
4. Notificar a todos los participantes
```

#### 3.2 - Evento que Termina Después de la Fecha Fin

**Detección:**
```
Evento multi-día termina después de fecha fin del plan
Ejemplo: 
- Fecha fin del plan: 20/11/2025
- Evento: Check-out hotel 21/11/2025
  ↓
Validación falla
  ↓
Alertar:
"⚠️ EVENTO FUERA DE RANGO

El check-out del hotel es el 21/11,
pero el plan termina el 20/11.

¿Expandir el plan 1 día más?"
```

---

### 4. VALIDACIÓN DE TIMEZONES

#### 4.1 - Incoherencias de Timezone

**Detección:**
```
Participante viaja de Madrid a Sydney
  ↓
Sistema actualiza timezone a Sydney
  ↓
Validar:
- Eventos futuros del participante se recalculan correctamente
- No hay eventos que queden "en el pasado" por cambio de timezone
- Eventos multi-timezone siguen siendo coherentes
```

**Si detecta incoherencia:**
```
Alertar:
"⚠️ INCOHERENCIA DE TIMEZONE DETECTADA

El evento 'Vuelo a Sydney' tiene problemas con tu timezone actual.

¿Quieres:
- Recalcular automáticamente?
- Ver detalles?
- Ignorar?"
```

#### 4.2 - Validar Eventos Multi-Timezone

**Detección:**
```
Evento con timezone salida ≠ timezone llegada
Ejemplo: Vuelo Madrid → Sydney
- Timezone salida: Europe/Madrid
- Timezone llegada: Australia/Sydney
  ↓
Validar que:
- Duración del evento es correcta
- Llegada es posterior a salida
- Evento se muestra correctamente en calendario
```

---

### 5. VALIDACIÓN DE ALOJAMIENTOS

#### 5.1 - Verificar Check-in se Alinea con Llegadas

**Algoritmo:**
```
1. Obtener alojamientos del plan
2. Para cada alojamiento:
   a. Check-in: 15/11 14:00h
   b. Buscar eventos DESPLAZAMIENTO que lleguen cerca de esa fecha
   c. Verificar que hay evento de llegada antes/alrededor del check-in
```

**Si detecta problema:**
```
Alertar:
"⚠️ CHECK-IN SIN LLEGADA CONFIRMADA

El check-in del Hotel X es el 15/11 a las 14:00h,
pero no hay evento de llegada a esa ubicación
en esa fecha/hora.

¿Añadir evento de traslado al hotel?"
```

#### 5.2 - Verificar Check-out se Alinea con Salidas

**Similar al check-in:**
```
Detectar si check-out se alinea con salida posterior
Ejemplo:
- Check-out: 18/11 11:00h
- Vuelo: 18/11 20:00h
  ↓
Validar que hay tiempo suficiente
Alertar si check-out muy tarde vs vuelo temprano
```

---

### 6. SUGERENCIAS DE OPTIMIZACIÓN (AVANZADO)

#### 6.1 - Optimizar Ruta de Eventos (T114)

**Concepto:** Detectar si hay eventos en ubicaciones muy lejanas sin tiempo de traslado

**Algoritmo (básico):**
```
1. Obtener todos los eventos con ubicación
2. Calcular distancias entre eventos consecutivos del día
3. Comparar con tiempo de traslado estimado
4. Si distancia > tiempo disponible: Alertar
```

**UI:**
```
💡 OPTIMIZACIÓN DE RUTA SUGERIDA

El día 15/11 tienes:
- 10:00h Museo en centro (2h)
- 14:00h Restaurante en periferia (30min)
Distancia: 20km
Tiempo disponible: 2h

¿Ajustar timing o sugerir ubicaciones más cercanas?
```

#### 6.2 - Detectar Tiempo Insuficiente entre Eventos

**Algoritmo:**
```
Para cada par de eventos consecutivos del día:
1. Calcular tiempo entre fin evento 1 e inicio evento 2
2. Calcular tiempo de traslado estimado (ubicación A → ubicación B)
3. Comparar
4. Si tiempo disponible < tiempo traslado: Alertar
```

**UI:**
```
⚠️ TIEMPO INSUFICIENTE ENTRE EVENTOS

Cena (Restaurant X): 20:00-22:00h
Concierto (Palacio Y): 22:00h
Ubicaciones: 15km de distancia
Tiempo disponible: 0 minutos
Tiempo traslado estimado: 25 minutos

Sugerencias:
- Empezar cena 30 minutos antes
- Aplazar concierto 30 minutos
- Buscar restaurante más cercano
```

---

### 7. ESTADÍSTICAS Y RESUMEN (T113)

#### 7.1 - Resumen de Actividades

**Flujo:**
```
Plan confirmado / En curso / Finalizado
  ↓
Generar resumen automático:
```

**Campos del resumen:**
```
📊 RESUMEN DEL PLAN

Eventos:
- Total: 15
- Desplazamientos: 4
- Alojamientos: 3
- Restauración: 4
- Actividades: 4

Participantes:
- Total: 6
- Activos: 5
- Observadores: 1

Presupuesto (T101):
- Estimado: €2,500
- Actual: €2,800
- Diferencia: +12%

Duración:
- Del 12/11 al 19/11 (8 días)
- Días más activos: 13/11, 16/11
- Días más tranquilos: 15/11, 18/11
```

#### 7.2 - Gráfico de Distribución Temporal

**Concepto:** Mostrar carga de actividades por día

**UI:**
```
Carga de actividades por día:

12/11 ████ 3 eventos
13/11 ████████ 6 eventos (máximo)
14/11 ████ 3 eventos
15/11 ██ 1 evento (tranquilo)
16/11 ████████ 6 eventos (máximo)
17/11 ████ 3 eventos
18/11 ██ 1 evento (tranquilo)
19/11 ███ 2 eventos
```

#### 7.3 - Análisis de Presupuesto (T101 + T113)

**Incluir en resumen:**
```
Análisis de presupuesto:

Por tipo de evento:
- Vuelos:      €1,200 (43%)
- Hoteles:      €800  (29%)
- Comidas:      €400  (14%)
- Actividades:  €200  (7%)
- Transporte:  €180  (7%)

Por participante:
- Promedio:     €700
- Máximo:       €950 (Juan)
- Mínimo:       €450 (Ana)

Tendencia:
- Presupuesto inicial: €2,500
- Presupuesto actual:  €2,800 (+€300)
```

---

## 📊 MAPA DEL PLAN (T114)

### 7.1 - Visualización de Eventos en Mapa

**Flujo:**
```
Acceder al mapa del plan
  ↓
Mapa muestra:
- Todos los eventos con ubicación
- Orden cronológico por día
- Rutas entre eventos del mismo día
  ↓
Opción: "Ver ruta optimizada"
  ↓
Sistema sugiere orden optimizado
Distancia total reducida
Tiempo en transporte optimizado
```

**Funcionalidad:**
- Pines en mapa por evento
- Líneas entre eventos consecutivos
- Popup con info al clic en pin
- Zoom automático a área relevante
- Vista satélite y vista mapa

### 7.2 - Indicadores de "Lugares Lejanos"

**Concepto:** Alertar si eventos están muy distantes

```
Si distancia entre eventos > X km:
  Alertar: "⚠️ LUGARES MUY LEJANOS

El evento 'Restaurante en X' (15/11 13:00h)
está a 45km del evento 'Visita museo Y' (15/11 11:00h).

Asegúrate de tener tiempo suficiente para el traslado."
```

---

## 🔄 VALIDACIÓN CONTINUA

**Cuándo se ejecuta:**
1. Al crear/editar evento
2. Al añadir/eliminar participante
3. Al confirmar el plan
4. Antes de cambiar estado a "En curso"
5. Manualmente: Botón "Validar plan"

**Resultados:**
- Resumen de validaciones
- Warnings (no críticos)
- Errors (críticos, bloquean confirmación)
- Sugerencias (mejoras opcionales)

---

## 📋 TAREAS RELACIONADAS

**Pendientes:**
- T114: Mapa del plan con rutas
- Validación check-in/check-out automatizada
- Sugerencias de optimización automáticas
- Integración con Google Maps (coste vs beneficio)

**Completas ✅:**
- T107: Auto-expansión de rango del plan (`PlanService.expandPlan`, `ExpandPlanDialog`, `plan_range_utils`)
- T113: Sistema de estadísticas (`PlanStatsService`, `PlanStatsPage`)
- Detección de solapamientos (con timezones, límite de 3; `OverlappingSegmentGroup`, `calendar_validations`)
- Validación de días vacíos (`PlanValidationService.detectEmptyDays`, `PlanValidationDialog`)
- Validación de participantes sin eventos (`PlanValidationService.detectParticipantsWithoutEvents`)
- Sistema de tracks (eventos por participante)

---

## ✅ IMPLEMENTACIÓN ACTUAL

**Estado:** ✅ Core implementado, mejoras pendientes

**Lo que ya funciona:**
- ✅ Detección completa de solapamientos con timezones
- ✅ Validación de conflictos de participantes (no pueden solaparse)
- ✅ Validación de límite de 3 eventos solapados en mismo horario
- ✅ Sistema de tracks
- ✅ Tiempo real de eventos
- ✅ Validaciones de formularios (T51):
  - ✅ Validaciones de longitud y obligatoriedad en formularios de evento
  - ✅ Validaciones de longitud en campos personales del evento
  - ✅ Validación de email de invitación en participación
- ✅ Formulario de eventos con `Form` y validaciones
- ✅ Rate limiting de creación (T126)
- ✅ Sanitización de inputs (T127)
- ✅ Manejo de borradores (pueden solaparse)

**Estado por funcionalidad (✅ implementado, ❌ pendiente):**
- ✅ Detección automática de días vacíos al confirmar (`PlanValidationService.detectEmptyDays`, usado en `PlanValidationDialog`)
- ✅ Detección automática de participantes sin eventos (`PlanValidationService.detectParticipantsWithoutEvents`)
- ❌ Validación check-in/check-out automatizada
- ✅ Sistema de estadísticas y análisis (T113: `PlanStatsService`, `PlanStatsPage`)
- ❌ Mapa del plan con visualización (T114)
- ✅ Auto-expansión de rango (T107: `expandPlan`, `ExpandPlanDialog`, validación en `wd_event_dialog`)
- ❌ Sugerencias de optimización automáticas

---

*Documento de flujo de validación y verificación*  
*Última actualización: Febrero 2026 (revisión sincronizada con código: T107, T113, PlanValidationService, CalendarValidations)*

