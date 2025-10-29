# 📋 Campos de Formularios de Alojamientos

> Documento para T121: Revisión y enriquecimiento de formularios de alojamientos

**Estado:** Borrador  
**Última actualización:** Enero 2025

> **Nota:** Los alojamientos son una entidad independiente de los eventos. Ver `docs/flujos/FLUJO_CRUD_ALOJAMIENTOS.md` para el flujo completo.

---

## 🎯 Objetivo

Definir todos los campos necesarios para formularios de alojamientos, basándonos en:
- Campos actuales del código
- Mejores prácticas de la industria
- Ejemplos de aplicaciones de reservas comerciales
- Necesidades específicas de viajes grupales

---

## 📊 Estructura de Navegación

1. [Campos Comunes](#campos-comunes)
2. [General (todos los alojamientos)](#general-todos-los-alojamientos)
3. [Hotel / Resort](#hotel--resort)
4. [Apartamento / Airbnb](#apartamento--airbnb)
5. [Hostal / Albergue](#hostal--albergue)
6. [Casa Rural / Chalet](#casa-rural--chalet)
7. [Camping / Glamping](#camping--glamping)

---

## 🔧 Campos Comunes

Estos campos son aplicables a TODOS los alojamientos:

### Información General
- **Nombre alojamiento** (texto + autocomplete)
- **Check-in** (date + time)
- **Check-out** (date + time)
- **Timezone** (IANA)
- **Tipo** (dropdown): "Hotel", "Apartamento", "Hostal", "Casa", "Glamping", "Casa rural"
- **Dirección completa** (texto + ubicación)
- **Color** (selector de color)

### Información de Contacto
- **Web** (url)
- **Teléfono contacto** (texto)
- **Email contacto** (email)

### Información de Reserva
- **Número reserva** (texto): Booking.com, Airbnb, etc.
- **Código reserva** (texto): Código de la plataforma
- **Día límite cancelación** (date): Último día para cancelar gratis
- **Cancelación gratuita** (checkbox): hasta el día límite

### Información Financiera
- **Precio total** (currency)
- **Precio por noche** (currency)
- **Depósito** (currency)
- **Depósito devuelto** (checkbox)

### Servicios y Horarios
- **Servicios incluidos** (multi-select): "WiFi", "AC", "Piscina", "Desayuno", "Pension completa", "Gym"
- **Servicios adicionales** (texto)
- **Check-in auto** (checkbox): Llavero codebox, app
- **Hora límite check-in** (time): "hasta 23:00"
- **Hora límite check-out** (time): "antes de 11:00"
- **Notas generales** (texto)

---

## 🏨 General (todos los alojamientos)

### Parte Común
- **Nombre alojamiento** (texto + autocomplete)
- **Tipo** (dropdown): "Hotel", "Apartamento", "Hostal", "Casa", "Glamping", "Casa rural"
- **Dirección completa** (texto + ubicación)
- **Check-in** (date + time)
- **Check-out** (date + time)
- **Timezone** (IANA)
- **Día límite cancelación** (date): Último día para cancelar gratis
- **Web** (url)
- **Teléfono contacto** (texto)
- **Email contacto** (email)
- **Número reserva** (texto): Booking.com, Airbnb, etc.
- **Código reserva** (texto): Código de la plataforma
- **Precio total** (currency)
- **Precio por noche** (currency)
- **Cancelación gratuita** (checkbox): hasta el día límite
- **Depósito** (currency)
- **Depósito devuelto** (checkbox)
- **Servicios incluidos** (multi-select): "WiFi", "AC", "Piscina", "Desayuno", "Pension completa", "Gym"
- **Servicios adicionales** (texto)
- **Check-in auto** (checkbox): Llavero codebox, app
- **Hora límite check-in** (time): "hasta 23:00"
- **Hora límite check-out** (time): "antes de 11:00"
- **Notas generales** (texto)

### Parte Personal
- **Habitación número** (texto): "205", "A5"
- **Tipo habitación** (texto): "Doble vista mar", "Apartamento con terraza"
- **Número personas** (número)
- **Camas** (texto): "1 cama matrimonial", "2 camas individuales"
- **Persona registro** (texto): Nombre quién hace check-in
- **Documentos confirmados** (checkbox): Documentos listos
- **Check-in completado** (checkbox)
- **Check-out completado** (checkbox)
- **Llaves devueltas** (checkbox)
- **Preferencias** (texto): "Vista", "Piso alto", "Silencio"
- **Alergias** (texto)
- **Niños** (número): "2"
- **Bebés** (número): "1"
- **Necesita cuna** (checkbox)
- **Necesita silla bebé** (checkbox)
- **Mascotas** (checkbox): "1 perro"
- **Maletas** (número): Total equipaje
- **Comentarios** (texto)
- **Valoración** (rating): 1-5 estrellas (después de estancia)

---

## 🏨 Hotel / Resort

### Campos específicos adicionales
- **Categoría** (dropdown): "1 estrella", "2 estrellas", "3 estrellas", "4 estrellas", "5 estrellas", "Lujo"
- **Cadena hotel** (texto)
- **Programa fidelización** (texto): "Bonvoy", "Hilton Honors"
- **Número fidelización** (texto)
- **Habitaciones reservadas** (número)
- **Suite** (checkbox)
- **Traslado hotel** (checkbox)
- **Traslado aeropuerto** (texto): Precio, horarios
- **Parking incluido** (checkbox)
- **Precio parking** (currency): Si no incluido
- **Tardeo** (checkbox)
- **Tardeo gratis** (checkbox)
- **Check-in tarde** (texto): "16:00 en lugar de 14:00"

### Parte Personal
- **Tipo habitación reservada** (dropdown): "Individual", "Doble", "Triple", "Suite"
- **Cama tipo** (dropdown): "King", "Queen", "2 individuales", "Sofa bed"
- **Vista** (dropdown): "Mar", "Jardín", "Ciudad", "Interior"
- **Piso preferido** (texto): "Alto", "Bajo"
- **Desayuno incluido** (checkbox)
- **Desayuno comprado** (checkbox)
- **Tipo pensión** (dropdown): "Solo alojamiento", "Desayuno", "Media pensión", "Pensión completa", "Todo incluido"
- **Limpieza diaria** (checkbox)
- **Toallas a piscina** (checkbox)
- **SPA** (checkbox): Acceso incluido o comprado
- **Gym** (checkbox)
- **Minibar** (checkbox): Bebidas incluidas
- **WiFi gratis** (checkbox)
- **WiFi premium** (checkbox)
- **Business center** (checkbox)
- **Room service** (checkbox)

---

## 🏠 Apartamento / Airbnb

### Campos específicos adicionales
- **Plataforma** (dropdown): "Airbnb", "Booking.com", "VRBO", "Directo"
- **Anfitrión** (texto): Nombre del anfitrión
- **Contacto anfitrión** (texto): Teléfono/WhatsApp
- **Código acceso** (texto): Para puerta/cajita llaves
- **Instrucciones acceso** (texto): Dónde está la cajita, código puerta
- **Código WiFi** (texto)
- **Habitaciones** (número)
- **Baños** (número)
- **Cocina** (checkbox)
- **Cocina equipada** (checkbox): Utensilios básicos
- **Lavadora** (checkbox)
- **Secadora** (checkbox)
- **Comedor** (checkbox)
- **Balcón** (checkbox)
- **Terraza** (checkbox)
- **Jardín** (checkbox)
- **Piscina compartida** (checkbox)
- **Piscina privada** (checkbox)
- **Parking incluido** (checkbox)
- **Garaje** (checkbox)
- **Internet alta velocidad** (checkbox)
- **TV** (checkbox)
- **AC** (checkbox)
- **Calefacción** (checkbox)
- **Chimenea** (checkbox)
- **Zona trabajo** (checkbox)
- **Mascotas permitidas** (checkbox)
- **Fumadores permitido** (checkbox)
- **Reglas casa** (texto)
- **Depósito seguridad** (currency)
- **Limpieza** (currency): Tasa de limpieza
- **Servicio** (currency): Tasa servicio plataforma
- **Tiempo respuesta anfitrión** (texto): "Respuesta en 1 hora"

---

## 🏨 Hostal / Albergue

### Campos específicos adicionales
- **Tipo habitación** (dropdown): "Dormitorio compartido", "Habitación privada", "Habitación doble"
- **Dormitorio género** (dropdown): "Mixto", "Solo mujeres", "Solo hombres"
- **Camas en litera** (checkbox)
- **Cama preferida** (dropdown): "Inferior", "Superior"
- **Lockers** (checkbox): Hay taquillas
- **Lockers gratis** (checkbox)
- **Cocina compartida** (checkbox)
- **Sala común** (checkbox)
- **Sala estar** (checkbox)
- **Terraza** (checkbox)
- **Lavandería** (checkbox): Servicio lavandería
- **Lavadora** (checkbox): Máquina usuarios
- **Estacionamiento** (checkbox)
- **Caja fuerte** (checkbox)
- **Check-in 24h** (checkbox)

---

## 🏠 Casa Rural / Chalet

### Campos específicos adicionales
- **Tipo propiedad** (dropdown): "Casa rural", "Chalet", "Villa", "Masía"
- **Habitaciones** (número)
- **Baños** (número)
- **Cocina** (checkbox)
- **Comedor** (checkbox)
- **Salón** (checkbox)
- **Chimenea** (checkbox)
- **Jardín** (checkbox)
- **Terraza** (checkbox)
- **Piscina** (checkbox): Privada
- **Barbacoa** (checkbox)
- **Parking** (checkbox)
- **WiFi** (checkbox)
- **Limpieza incluida** (checkbox)
- **Limpieza final** (currency)
- **Número invitados máximo** (número)
- **Perros permitidos** (checkbox)
- **Gatos permitidos** (checkbox)
- **Precio perro** (currency)
- **Precio gato** (currency)
- **Leña gratuita** (checkbox)
- **Leña incluida** (checkbox)
- **Contacto propietario** (texto)
- **Teléfono emergencias** (texto)

---

## 🏕️ Camping / Glamping

### Campos específicos adicionales
- **Tipo** (dropdown): "Camping", "Glamping", "Caravana", "Autocaravana"
- **Parcela** (texto): "A-15"
- **Tipo parcela** (dropdown): "Tienda", "Caravana", "Autocaravana", "Cabaña", "Yurta"
- **Electricidad** (checkbox)
- **Agua** (checkbox)
- **Ducha compartida** (checkbox)
- **WC compartido** (checkbox)
- **WC privado** (checkbox)
- **Basura** (checkbox): Contenedor cerca
- **Piscina camping** (checkbox)
- **Restaurante camping** (checkbox)
- **Tienda camping** (checkbox)
- **Limpieza incluida** (checkbox)
- **Basura incluida** (checkbox)
- **Traes tienda** (checkbox)
- **Alquilas tienda** (checkbox)
- **Precio alquiler tienda** (currency)

---

## 📋 PRÓXIMOS PASOS

1. **Revisar campos** con ejemplos del usuario
2. **Priorizar campos** obligatorios vs opcionales
3. **Diseñar UI** para campos dinámicos
4. **Implementar estructura** de datos flexible
5. **Testing** con casos reales

---

## 🤔 DECISIONES PENDIENTES

### Técnicas
- [ ] ¿Usamos estructura `AccommodationCommonPart` y `AccommodationPersonalPart` ya implementada?
- [ ] ¿Cómo validamos campos dinámicos?
- [ ] ¿Cómo mostramos UI según tipo de alojamiento?
- [ ] ¿Migramos alojamientos existentes o solo nuevos?

### UX
- [ ] ¿Agrupación de campos en secciones?
- [ ] ¿Campos condicionales? (ej: si "viaja con bebé" → mostrar "silla bebé")
- [ ] ¿Plantillas por tipo? (ej: plantilla "Hotel 5 estrellas")
- [ ] ¿Búsqueda autocompletar para direcciones?

### Datos
- [ ] ¿Integración con APIs externas? (Google Places, Booking.com, Airbnb, etc.)
- [ ] ¿Selector de mapa integrado? (Google Maps picker para ubicaciones)
- [ ] ¿Autocompletar direcciones? (Google Places Autocomplete)
- [ ] ¿Sincronización con servicios externos?
- [ ] ¿Exportación de datos? (PDF, Excel)

---

*Documento creado para T121 - Revisión y enriquecimiento de formularios*  
*Última actualización: Enero 2025*

