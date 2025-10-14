# 🧟 PLAN FRANKENSTEIN - Especificación de Testing

**Fecha de creación:** 8 de octubre de 2025  
**Versión:** 2.0  
**Última actualización:** 9 de octubre de 2025
**Propósito:** Plan de prueba completo que contiene todos los tipos de eventos, casos edge y complejidades implementadas en Planazoo.

---

## 📋 **Descripción General**

El plan **"🧟 Frankenstein"** es un plan artificial diseñado específicamente para testing. Como el monstruo de Frankenstein, está compuesto de muchas "partes" diferentes (tipos de eventos, solapamientos, casos edge) ensambladas en un solo plan.

**Características:**
- **Duración:** 7 días
- **ID:** FRANK001
- **Generación:** Automática via `DemoDataGenerator`
- **Disponibilidad:** Solo en modo debug (`kDebugMode`)
- **Regenerable:** Se puede eliminar y volver a generar

**⚠️ REGLAS DE NEGOCIO APLICADAS:**
- ✅ **Máximo 3 eventos simultáneos** en cualquier momento (validación activa)
- ✅ **Eventos máximo 24h** de duración
- ✅ **Sin emojis en nombres** de eventos (desde v2.0)

---

## 🎯 **Casos de Prueba Incluidos**

### **📅 DÍA 1 - Eventos Básicos (5 eventos)**

| Hora | Duración | Descripción | Tipo | Qué se prueba |
|------|----------|-------------|------|---------------|
| 09:00 | 30 min | ☕ Café rápido | Restauración/Bebida | Evento corto |
| 10:00 | 2h | 🏛️ Visita museo | Actividad/Museo | Evento mediano |
| 14:00 | 4h | 🏖️ Tarde en la playa | Actividad/Parque | Evento largo |
| 00:00 | 24h | 🎉 Festival de música | Actividad/Concierto | Evento todo el día |
| 20:00 | 2h | 🤔 Cena (por confirmar) | Restauración/Cena | **Evento borrador** |

**Objetivos:**
- ✅ Renderizado de eventos de diferentes duraciones
- ✅ Formato de horas en eventos cortos vs largos
- ✅ Visualización de eventos borrador (opacidad diferente)
- ✅ Colores personalizados (brown, purple, teal, pink, orange)

---

### **📅 DÍA 2 - Eventos Solapados (7 eventos)**

#### **Solapamiento Parcial:**
| Hora | Duración | Descripción | Qué se prueba |
|------|----------|-------------|---------------|
| 10:00-12:00 | 2h | 📚 Taller de fotografía | Solapamiento inicio |
| 11:00-12:30 | 1.5h | ☕ Coffee break | Solapamiento parcial |

#### **Solapamiento Completo (mismo horario):**
| Hora | Duración | Descripción | Qué se prueba |
|------|----------|-------------|---------------|
| 15:00-16:00 | 1h | 🎭 Obra de teatro A | 3 eventos |
| 15:00-16:00 | 1h | 🎬 Película B | simultáneos |
| 15:00-16:00 | 1h | 🎵 Concierto C | exactos |

#### **Evento Contenedor:**
| Hora | Duración | Descripción | Qué se prueba |
|------|----------|-------------|---------------|
| 18:00-21:00 | 3h | 🍽️ Cena con espectáculo | Evento padre |
| 19:00-20:00 | 1h | 🎸 Show en vivo | Evento hijo dentro |

**Objetivos:**
- ✅ Algoritmo de detección de solapamientos
- ✅ Renderizado lado a lado de eventos solapados
- ✅ División de ancho correcto (33%, 33%, 33%)
- ✅ Grupos de solapamiento (`OverlappingEventGroup`)

---

### **📅 DÍA 3-4 - Eventos que Cruzan Días (6 eventos)**

| Inicio | Fin | Duración | Descripción | Qué se prueba |
|--------|-----|----------|-------------|---------------|
| Día 3, 22:00 | Día 4, 06:00 | 8h | 🚂 Tren nocturno | Evento cruza medianoche |
| Día 3, 20:00 | Día 4, 01:00 | 5h | 🎭 Teatro + cena tardía | Termina día siguiente |
| Día 4, 02:00 | Día 4, 06:00 | 4h | 🌅 Excursión amanecer | Evento madrugada |
| Día 3, 09:00 | Día 3, 12:00 | 3h | 🥾 Senderismo | Actividad durante camping |
| Día 4, 07:00 | Día 4, 09:00 | 2h | 🎣 Pesca en lago | Actividad durante camping |
| Día 5, 21:00 | Día 5, 23:00 | 2h | 🔥 Fogata y cuentos | Actividad durante camping |

**Objetivos:**
- ✅ Eventos que cruzan medianoche (< 24h)
- ✅ Formato de hora de fin "Día siguiente"
- ✅ Posicionamiento correcto cuando cruza días
- ✅ Renderizado de "XX:XX - XX:XX" en continuación
- ✅ Eventos específicos durante alojamiento (camping)

**⚠️ REGLA DE NEGOCIO:**
> **Los eventos NO PUEDEN durar más de 24 horas.**
> 
> **Razón:** Los eventos son FASES del plan (actividades, desplazamientos, comidas), no bloques de tiempo genéricos.
> 
> **Si necesitas algo > 24h:**
> - 🏨 ¿Es donde duermes? → **ALOJAMIENTO**
> - 🎯 ¿Son actividades diferentes? → **EVENTOS SEPARADOS** por día
> - 🚢 ¿Es transporte largo (crucero, viaje)? → **EVENTOS POR TRAMO** (embarque, navegación, paradas, desembarque)
>
> **Ejemplo: Crucero de 5 días**
> - ❌ NO: 1 evento "Crucero" de 120 horas
> - ✅ SÍ: 1 alojamiento "Crucero" (5 días) + eventos específicos (embarque, parada Ibiza, parada Mallorca, desembarque)

---

### **📅 DÍA 4 - Todos los Tipos de Eventos (7 eventos)**

#### **Familia: Desplazamiento**
- 🚕 Taxi (08:00, 30min)
- ✈️ Avión (09:30, 2h)
- 🚌 Autobús (12:00, 45min)

#### **Familia: Restauración**
- 🍕 Comida italiana (13:30, 1.5h)
- 🍰 Merienda (17:00, 30min)

#### **Familia: Actividad**
- 🏛️ Sagrada Familia (18:00, 2h)
- 🎭 Teatro del Liceo (21:00, 2.5h)

**Objetivos:**
- ✅ Colores por tipo de familia
- ✅ Subtipos de eventos
- ✅ Iconos según familia (si se implementan)

---

### **📅 DÍA 5 - Casos Edge (9 eventos)**

| Hora | Duración | Descripción | Qué se prueba |
|------|----------|-------------|---------------|
| 00:00 | 1h | 🕛 Evento medianoche | Inicio del día |
| 23:45 | 30min | 🌙 Evento fin del día | **Cruza a día siguiente** |
| 10:00 | 15min | ⚡ Llamada rápida | **Evento muy corto** |
| 01:00 | 23h | 🏔️ Excursión completa | **Evento casi todo el día** |
| 14:00 | 15min | 🎯 Reunión 1 | **5 eventos** |
| 14:10 | 15min | 🎯 Reunión 2 | **en misma hora** |
| 14:20 | 15min | 🎯 Reunión 3 | **con minutos** |
| 14:30 | 15min | 🎯 Reunión 4 | **exactos** |
| 14:40 | 15min | 🎯 Reunión 5 | **(solapados)** |

**Objetivos:**
- ✅ Eventos en límites de día (00:00 y 23:59)
- ✅ Eventos que cruzan medianoche
- ✅ Eventos muy cortos (15 min)
- ✅ Eventos muy largos (23h)
- ✅ Múltiples eventos con minutos exactos
- ✅ Solapamientos complejos en una hora

---

### **🏨 Alojamientos (4 alojamientos)**

| Check-in | Check-out | Duración | Nombre | Tipo | Qué se prueba |
|----------|-----------|----------|--------|------|---------------|
| Día 1 | Día 3 | 2 noches | 🏨 Hotel Frankenstein Inn | Hotel | Alojamiento normal |
| Día 3 | Día 5 | 2 noches | 🏠 Apartamento Monster Place | Apartamento | **Overlap con hotel** |
| Día 5 | Día 7 | 2 noches | 🛏️ Hostal del Terror | Hostal | Alojamiento estándar |
| Día 7 | Día 8 | 1 noche | ⛺ Camping Salvaje | Camping | Alojamiento corto |

**Objetivos:**
- ✅ Renderizado de alojamientos
- ✅ Diferentes tipos (Hotel, Apartamento, Hostal, Camping)
- ✅ Colores personalizados (blue, green, orange, purple)
- ✅ Solapamiento de alojamientos (día 3)

---

## 🔮 **Futuras Adiciones (Cuando se Implementen)**

### **Día 6 - Participantes** (T46-T50)
```dart
// Cuando se implemente sistema de participantes:
- Evento para todos los participantes
- Evento solo para participante específico
- Evento para 2 de 3 participantes
- Evento personal (solo creador)
```

### **Día 7 - Timezones** (T40-T45)
```dart
// Cuando se implemente sistema de timezones:
- Evento Madrid (GMT+1)
- Evento Nueva York (GMT-5)
- Vuelo cross-timezone (Madrid → NY)
```

---

## 🚀 **Uso del Generador**

### **Generar Plan:**
1. Abrir app en modo debug
2. Click en botón flotante **"🧟 Frankenstein"** (esquina inferior derecha)
3. Esperar ~2-3 segundos
4. Plan aparecerá en lista de planes
5. Click en "Ver" en notificación para abrirlo

### **Regenerar Plan:**
- Click en botón Frankenstein → elimina el anterior y crea uno nuevo
- Útil después de hacer cambios en el código

### **Eliminar Plan:**
- Desde el dashboard → seleccionar plan → botón eliminar
- O regenerar (elimina automáticamente)

---

## ✅ **Checklist de Verificación**

Usar este checklist para verificar que todas las funcionalidades funcionan:

### **Renderizado:**
- [ ] Eventos cortos (< 1h) se ven correctamente
- [ ] Eventos medianos (1-3h) muestran título y horas
- [ ] Eventos largos (> 3h) tienen espacio suficiente
- [ ] Eventos todo-el-día se extienden por toda la columna
- [ ] Eventos borrador tienen opacidad reducida

### **Solapamientos:**
- [ ] 2 eventos solapados se dividen el ancho (50/50)
- [ ] 3 eventos solapados se dividen el ancho (33/33/33)
- [ ] Eventos completamente solapados se renderizan todos
- [ ] Eventos anidados (uno dentro de otro) funcionan

### **Multi-día:**
- [ ] Evento aparece en múltiples columnas de días
- [ ] Primera columna muestra hora de inicio
- [ ] Columnas siguientes muestran "00:00 - XX:XX"
- [ ] Último día muestra hora de fin correcta

### **Tipos:**
- [ ] Cada familia de evento tiene color correcto
- [ ] Subtipos se guardan y muestran
- [ ] Colores personalizados se aplican

### **Edge Cases:**
- [ ] Evento a las 00:00 funciona
- [ ] Evento a las 23:45 funciona
- [ ] Eventos de 15 min se renderizan
- [ ] 5 eventos en misma hora se ven todos

### **Alojamientos:**
- [ ] Alojamientos se muestran en fila superior
- [ ] Solapamiento de alojamientos funciona
- [ ] Colores se aplican correctamente
- [ ] Duración en días es correcta

### **Interacciones:**
- [ ] Click en evento abre diálogo de edición
- [ ] Doble click en celda vacía crea evento
- [ ] Drag & drop de eventos funciona
- [ ] Eliminar eventos funciona
- [ ] Click en alojamiento abre diálogo
- [ ] Doble click crea alojamiento

### **Auto-scroll:**
- [ ] Al abrir plan, scroll se posiciona en primer evento
- [ ] Si primer evento es todo-el-día, scroll va a 00:00
- [ ] Si no, scroll va 1 hora antes del primer evento

---

## 📊 **Estadísticas del Plan Frankenstein**

| Métrica | Valor |
|---------|-------|
| **Duración** | 7 días |
| **Total eventos** | 34 eventos (todos ≤ 24h) |
| **Total alojamientos** | 4 alojamientos |
| **Eventos solapados** | 7 grupos |
| **Eventos multi-día** | 3 eventos |
| **Eventos borrador** | 1 evento |
| **Tipos de familia** | 3 (Desplazamiento, Restauración, Actividad) |
| **Colores únicos** | 8 colores |
| **Casos edge** | 9 casos |

---

## 🔧 **Mantenimiento**

### **Actualizar el Plan:**
Cuando se implemente una nueva funcionalidad, añadir casos al generador:

```dart
// En lib/features/testing/demo_data_generator.dart

static Future<void> _generateNewFeature(Plan plan, String userId) async {
  debugPrint('📅 Generando nueva funcionalidad...');
  // Añadir eventos de prueba aquí
}

// Y llamarlo en generateFrankensteinPlan():
await _generateNewFeature(plan, userId);
```

### **Versiones:**
- **v1.0:** Eventos básicos, solapados, multi-día, tipos, edge cases, alojamientos
- **v2.0:** (Futuro) Participantes específicos por evento
- **v3.0:** (Futuro) Timezones y eventos cross-timezone

---

## 🐛 **Casos de Prueba Específicos**

### **Auto-scroll:**
- Primer evento del plan: 00:00 (Festival todo el día)
- **Esperado:** Scroll se posiciona en 00:00 (evento todo-el-día)

### **Solapamientos:**
- Día 2, 15:00: 3 eventos completamente solapados
- **Esperado:** 3 eventos lado a lado, cada uno ocupa ~33% del ancho

### **Multi-día:**
- Día 3-7: Festival Internacional (5 días)
- **Esperado:** Aparece en 5 columnas, mostrando continuación en cada día

### **Edge Cases:**
- Día 5, 23:45: Evento de 30 min que cruza a día 6
- **Esperado:** Se renderiza correctamente sin errores

---

## 📝 **Notas para Desarrolladores**

### **Código Generador:**
- Ubicación: `lib/features/testing/demo_data_generator.dart`
- Método principal: `generateFrankensteinPlan(userId)`
- Método de limpieza: `deleteFrankensteinPlan()`

### **Botón UI:**
- Ubicación: `lib/pages/pg_dashboard_page.dart`
- Tipo: `FloatingActionButton.extended`
- Visibilidad: Solo `kDebugMode`
- Icono: 🧟 (Science icon)

### **Testing Manual:**
1. Generar plan Frankenstein
2. Abrir calendario del plan
3. Revisar checklist de verificación
4. Reportar bugs encontrados
5. Regenerar después de fixes

---

## 🎨 **Visual Esperado**

```
DÍA 1          DÍA 2          DÍA 3          DÍA 4          DÍA 5
═══════════════════════════════════════════════════════════════

00:00  🎉 Festival────────────────────────────┐  🕛 Medianoche
       (todo el día)                          │
                                              │
09:00  ☕ Café    📚 Taller───┐  🎪 Festival   │  ⚡ Llamada
                              │  (5 días)     │
10:00  🏛️ Museo  ☕ Break    │  ⛺ Camping   │  
                  ├────────┘  (3 días)      │  🏔️ Excursión
11:00                                        │  (23h)
                  🎭🎬🎵                      │
14:00  🏖️ Playa  (3 solapados)               │  🎯🎯🎯🎯🎯
       (4h)                                   │  (5 reuniones)
       ...                                    │
20:00  🤔 Cena   🍽️ Cena────┐                │
       [BORRADOR] 🎸 Show  │                 │
                  └────────┘                 │
23:00                                        │  🌙 Fin día
                                             │  (cruza día 6)
```

---

## 🔍 **Debugging**

Si algo falla durante la generación:

1. **Revisar consola:** Los `debugPrint` muestran progreso
2. **Verificar Firebase:** Comprobar que los datos se guardaron
3. **Regenerar:** Click en botón Frankenstein de nuevo
4. **Logs:** Buscar errores en `LoggerService`

---

**Última actualización:** 8 de octubre de 2025  
**Mantenedor:** Sistema de testing de Planazoo

