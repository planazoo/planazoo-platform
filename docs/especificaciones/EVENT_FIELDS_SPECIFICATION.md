# 📋 Especificación de Campos por Tipo de Evento

> Documento de especificación para T76: Campos dinámicos según tipo de evento

## 🎯 Objetivo

Definir qué campos de información personal aparecen para cada tipo de evento, permitiendo una experiencia de usuario contextual y relevante.

## 📝 Estructura Base

Todos los eventos tienen **campos comunes** (siempre visibles):
- **Notas personales** (texto libre)
- **Tarjeta obtenida** (checkbox)

Los **campos específicos** aparecen según el tipo de evento.

---

## 🚗 DESPLAZAMIENTO

### ✈️ Avión

#### 📋 Parte Común (editada por organizador)
- **Hora inicio embarque** (ej: "14:30")
- **Hora cierre puertas** (ej: "14:50")
- **Hora apertura equipaje** (ej: "16:05")
- **Hora cierre equipaje** (ej: "18:05")
- **Hora cierre facturación** (ej: "60 min antes salida")
- **Número de vuelo** (ej: "EZY2705")
- **Terminal salida** (ej: "Terminal 2C")
- **Terminal llegada** (ej: "Terminal 1")

#### 👤 Parte Personal (editada por cada participante)
- **Asiento** (ej: "21D", "21B")
- **Número de reserva** (ej: "K9ZMXCM")
- **Precio billete** (ej: "€386,94")
- **Tarifa** (ej: "Económica", "Premium", "Business")
- **Equipaje mano pequeño** (ej: "1 pieza, máx. 45x36x20cm")
- **Equipaje mano grande** (ej: "1 pieza, máx. 56x45x25cm")
- **Equipaje facturado** (ej: "2 maletas, 23kg cada una")
- **Aeropuerto salida** (ej: "Bristol")
- **Aeropuerto llegada** (ej: "Barcelona")
- **Gate** (ej: "Gate A12")
- **Menú** (ej: "Vegetariano", "Sin gluten")
- **Asistencia especial** (ej: "Sí", "No")
- **Alergia frutos secos** (ej: "Sí", "No")
- **Documento identidad** (ej: "Pasaporte", "DNI")

**Lógica:** Información común de embarque + datos personales específicos de cada pasajero.

### 🚂 Tren
**Campos específicos:**
- **Asiento** (ej: "Vagón 3, Asiento 25")
- **Número de reserva** (ej: "TRN789012")
- **Menú** (ej: "Comida vegetariana", "Snack")

**Lógica:** Trenes tienen vagón y asiento. Reserva importante. Menú para viajes largos.

### 🚌 Autobús
**Campos específicos:**
- **Asiento** (ej: "Asiento 15")
- **Número de reserva** (ej: "BUS456789")

**Lógica:** Asiento numerado y reserva básica.

### 🚕 Taxi
**Campos específicos:**
- **Número de reserva** (ej: "TAX123456")
- **Preferencias** (ej: "Coche grande", "Conductor que hable inglés")

**Lógica:** Reserva y preferencias específicas del servicio.

### 🚶 Caminar
**Campos específicos:**
- **Preferencias** (ej: "Ruta más corta", "Evitar escaleras")

**Lógica:** Solo preferencias de ruta.

---

## 🍽️ RESTAURACIÓN

### 🥐 Desayuno
**Campos específicos:**
- **Menú** (ej: "Continental", "Americano", "Sin gluten")
- **Preferencias** (ej: "Mesa cerca de la ventana", "Sin ruido")

**Lógica:** Menú específico del desayuno y preferencias de ubicación.

### 🍽️ Comida
**Campos específicos:**
- **Menú** (ej: "Menú del día", "Vegetariano", "Especialidad local")
- **Preferencias** (ej: "Mesa familiar", "Zona silenciosa")

**Lógica:** Menú principal y preferencias de ambiente.

### 🍽️ Cena
**Campos específicos:**
- **Menú** (ej: "Degustación", "Mariscos", "Vegetariano")
- **Preferencias** (ej: "Mesa romántica", "Vista panorámica")
- **Número de reserva** (ej: "RES789012")

**Lógica:** Menú especial, preferencias de ambiente y reserva importante.

### 🍿 Snack
**Campos específicos:**
- **Menú** (ej: "Fruta fresca", "Frutos secos", "Sin azúcar")

**Lógica:** Opciones saludables para snacks.

### 🥤 Bebida
**Campos específicos:**
- **Menú** (ej: "Café descafeinado", "Té verde", "Agua con gas")
- **Preferencias** (ej: "Sin hielo", "Temperatura ambiente")

**Lógica:** Opciones de bebida y preferencias de temperatura.

---

## 🎭 ACTIVIDAD

### 🏛️ Museo
**Campos específicos:**
- **Preferencias** (ej: "Audioguía", "Visita guiada", "Acceso rápido")
- **Número de reserva** (ej: "MUS123456")

**Lógica:** Preferencias de experiencia y reserva para evitar colas.

### 🏰 Monumento
**Campos específicos:**
- **Preferencias** (ej: "Visita guiada", "Acceso VIP", "Fotografía permitida")
- **Número de reserva** (ej: "MON456789")

**Lógica:** Preferencias de visita y reserva para acceso especial.

### 🌳 Parque
**Campos específicos:**
- **Preferencias** (ej: "Ruta senderismo", "Zona picnic", "Acceso fácil")

**Lógica:** Preferencias de actividad en el parque.

### 🎭 Teatro
**Campos específicos:**
- **Asiento** (ej: "Fila 5, Asiento 12", "Palco A")
- **Número de reserva** (ej: "TEA789012")
- **Preferencias** (ej: "Cerca del escenario", "Acceso fácil")

**Lógica:** Asiento específico, reserva importante y preferencias de ubicación.

### 🎵 Concierto
**Campos específicos:**
- **Asiento** (ej: "Fila 8, Asiento 15", "Zona VIP")
- **Número de reserva** (ej: "CON123456")
- **Preferencias** (ej: "Cerca del escenario", "Zona de pie")

**Lógica:** Asiento específico, reserva crítica y preferencias de experiencia.

### ⚽ Deporte
**Campos específicos:**
- **Asiento** (ej: "Tribuna Norte, Fila 10")
- **Número de reserva** (ej: "DEP456789")
- **Preferencias** (ej: "Zona familiar", "Cerca de salida")

**Lógica:** Asiento específico, reserva importante y preferencias de ubicación.

---

## 🏨 ALOJAMIENTO

### 🏨 Hotel
**Campos específicos:**
- **Número de reserva** (ej: "HOT123456")
- **Preferencias** (ej: "Habitación alta", "Vista al mar", "Sin ruido")
- **Menú** (ej: "Desayuno incluido", "Media pensión")

**Lógica:** Reserva crítica, preferencias de habitación y opciones de comida.

### 🏠 Apartamento
**Campos específicos:**
- **Número de reserva** (ej: "APT789012")
- **Preferencias** (ej: "Con cocina", "Terraza", "Parking incluido")

**Lógica:** Reserva importante y preferencias de comodidades.

### 🏨 Hostal
**Campos específicos:**
- **Número de reserva** (ej: "HOS456789")
- **Preferencias** (ej: "Habitación privada", "Baño compartido")

**Lógica:** Reserva básica y preferencias de privacidad.

### 🏠 Casa
**Campos específicos:**
- **Número de reserva** (ej: "CAS123456")
- **Preferencias** (ej: "Con jardín", "Piscina", "Mascotas permitidas")

**Lógica:** Reserva importante y preferencias de espacio.

---

## 🔧 OTRO

### 🛒 Compra
**Campos específicos:**
- **Preferencias** (ej: "Presupuesto máximo", "Marcas preferidas")
- **Número de reserva** (ej: "COM789012") *[solo si aplicable]*

**Lógica:** Preferencias de compra. Reserva solo para compras especiales.

### 👥 Reunión
**Campos específicos:**
- **Preferencias** (ej: "Sala silenciosa", "Proyector", "Catering")
- **Número de reserva** (ej: "REU456789")

**Lógica:** Preferencias de espacio y servicios. Reserva importante.

### 💼 Trabajo
**Campos específicos:**
- **Preferencias** (ej: "WiFi rápido", "Mesa amplia", "Silencio")

**Lógica:** Preferencias de productividad.

### 👤 Personal
**Campos específicos:**
- **Preferencias** (ej: "Privacidad", "Acceso fácil")

**Lógica:** Preferencias básicas para actividades personales.

---

## 🎨 IMPLEMENTACIÓN TÉCNICA

### Estructura de Datos
```dart
class EventFieldSpec {
  final String fieldKey;        // 'asiento', 'menu', etc.
  final String displayName;     // 'Asiento', 'Menú', etc.
  final String hintText;        // 'Ej: 12A, Ventana'
  final IconData icon;          // Icons.chair, Icons.restaurant, etc.
  final FieldType type;         // text, number, boolean, select
  final bool required;          // true/false
  final List<String>? options;   // Para campos select
}

enum FieldType { text, number, boolean, select }
```

### Configuración por Tipo
```dart
Map<String, List<EventFieldSpec>> eventFieldsByType = {
  'Desplazamiento': {
    'Avión': [
      EventFieldSpec('asiento', 'Asiento', 'Ej: 12A', Icons.chair, FieldType.text, true),
      EventFieldSpec('numeroReserva', 'Número de reserva', 'Ej: ABC123456', Icons.confirmation_number, FieldType.text, true),
      EventFieldSpec('gate', 'Gate', 'Ej: Gate A12', Icons.door_front_door, FieldType.text, true),
      EventFieldSpec('menu', 'Menú', 'Ej: Vegetariano', Icons.restaurant, FieldType.text, false),
    ],
    // ... más subtipos
  },
  // ... más familias
};
```

---

## 📋 PRÓXIMOS PASOS

1. **Revisar especificación** - ¿Faltan campos? ¿Algún tipo necesita ajustes?
2. **Implementar estructura** - Crear `EventFieldSpec` y configuración
3. **Actualizar UI** - Hacer campos dinámicos en EventDialog
4. **Migrar datos** - Actualizar eventos existentes con nueva estructura
5. **Testing** - Probar con Plan Frankenstein

---

*Documento creado para T76 - Campos dinámicos según tipo de evento*
