# 📋 Campos de Formularios de Eventos y Alojamientos

> Documento para T121: Revisión y enriquecimiento de formularios

**Estado:** Borrador  
**Última actualización:** Enero 2025

---

## 🎯 Objetivo

Definir todos los campos necesarios para formularios de eventos y alojamientos, basándonos en:
- Campos actuales del código
- Mejores prácticas de la industria
- Ejemplos de aplicaciones de reservas comerciales
- Necesidades específicas de viajes grupales

---

## 📊 Estructura de Navegación

1. [Campos Comunes](#campos-comunes)
2. [Desplazamiento](#desplazamiento)
3. [Restauración](#restauración)
4. [Actividades](#actividades)
5. [Alojamientos](#alojamientos)
6. [Eventos Especiales](#eventos-especiales)
7. [Otros](#otros)

---

## 🔧 Campos Comunes

Estos campos son aplicables a TODOS los eventos y alojamientos:

### Información General
- **Título/Descripción** (texto)
- **Fecha inicio** (fecha y hora)
- **Fecha fin** (fecha y hora, nullable para eventos instantáneos)
- **Timezone inicio** (dropdown IANA)
- **Timezone fin** (dropdown IANA, nullable)
- **Ubicación/Localización** (texto + mapa/coordenadas) - **NUEVO**
- **Dirección completa** (texto + autocompletar) - **NUEVO**
- **Coordenadas GPS** (lat, lon) - **NUEVO**
- **Punto de encuentro** (texto) - **NUEVO**, específico para eventos
- **Participantes** (multi-select)
- **Color** (selector de color)
- **Notas generales** (texto largo, nullable)

### Estado y Metadata
- **Es borrador** (checkbox) - Ya implementado
- **Creado por** (userId, automático)
- **Creado en** (timestamp, automático)
- **Actualizado en** (timestamp, automático)

### Partes Personal (por participante)
- **Notas personales** (texto largo, nullable)
- **Tarjeta obtenida** (checkbox) - Ya implementado
- **Otros campos personalizados** (Map<String, dynamic>, según tipo)

---

## 🚗 DESPLAZAMIENTO

### ✈️ Avión

#### Parte Común
- **Nombre vuelo/Descripción** (texto): "Vuelo Madrid → Sydney"
- **Fecha hora salida** (date + time)
- **Fecha hora llegada** (date + time)
- **Timezone salida** (IANA)
- **Timezone llegada** (IANA)
- **Aerolínea** (texto): "Iberia", "Qantas"
- **Código vuelo** (texto): "EZY2705", "BA118"
- **Terminal/Puerta salida** (texto): "Terminal 2C, Gate A12"
- **Terminal/Puerta llegada** (texto): "Terminal 1, Gate 45"
- **Tipo avión** (texto): "Boeing 787", "Airbus A350"
- **Duración vuelo** (time): "21:30" (horas:minutos)
- **Equipaje incluido** (texto): "1 maleta 23kg, 1 equipaje mano"
- **Comida incluida** (checkbox)
- **WiFi disponible** (checkbox)
- **Necesita visa** (checkbox)
- **Horarios importantes** (mapa de texto):
  - Hora inicio embarque
  - Hora cierre puertas
  - Hora apertura equipaje
  - Hora cierre equipaje
  - Hora cierre facturación
- **Notas técnicas** (texto): Instrucciones, contacto, etc.

#### Parte Personal
- **Asiento** (texto): "21D", "12A", "Fila 8"
- **Número reserva** (texto): "K9ZMXCM", "H6J8Q2"
- **Código PNR/Booking** (texto): Código de reserva del sistema
- **Precio billete** (número/currency): €386.94
- **Tarifa** (dropdown): "Económica", "Premium Economy", "Business", "Primera"
- **Check-in realizado** (checkbox)
- **Pase embarque generado** (checkbox)
- **Equipaje mano** (texto): "1 pieza, máx. 45x36x20cm"
- **Equipaje facturado** (texto): "2 maletas, 23kg cada una"
- **Servicio de asistencia** (checkbox): Requiere ayuda especial
- **Silla de bebé** (checkbox)
- **Animal de servicio** (checkbox)
- **Menú especial** (dropdown): "Estándar", "Vegetariano", "Vegano", "Sin gluten", "Halal", "Kosher"
- **Asistencia especial** (checkbox)
- **Alergias alimentarias** (texto): Especialmente frutos secos
- **Documento identidad** (dropdown): "Pasaporte", "DNI", "NIE"
- **Numero documento** (texto, encriptado)
- **Visa/ESTA necesaria** (checkbox)
- **Visa obtenida** (checkbox)
- **Notas personales** (texto): Preferencias, contactos, etc.

---

### 🚂 Tren

#### Parte Común
- **Estación salida** (texto + autocomplete): "Estación Central Madrid"
- **Estación llegada** (texto + autocomplete): "Gare de Lyon, París"
- **Tipo tren** (dropdown): "AVE", "TGV", "Eurostar", "Regional"
- **Número tren** (texto): "AVE 9850"
- **Vagón club** (texto): "Coche 8"
- **Clase** (dropdown): "Turista", "Preferente", "Primera"
- **Duración** (time)
- **Comida disponible** (checkbox)
- **WiFi** (checkbox)
- **Red eléctrica** (checkbox)
- **Notas ruta** (texto): Cruces, escalas

#### Parte Personal
- **Vagón** (texto): "Coche 8"
- **Asiento** (texto): "Asiento 12A", "12B"
- **Número reserva** (texto): "TRN789012"
- **Código billete** (texto): Código electrónico
- **Precio billete** (currency)
- **Menú** (dropdown): "Menú completo", "Bocadillo", "Sin comida"
- **Descuento** (texto): "Euro <26", "Abono Premium"
- **Necesidades especiales** (texto)

---

### 🚌 Autobús

#### Parte Común
- **Parada/Estación salida** (texto + autocomplete)
- **Parada/Estación llegada** (texto + autocomplete)
- **Línea/Compañía** (texto): "Flixbus", "Alsa"
- **Número ruta** (texto): "435"
- **Tipo autobús** (dropdown): "Estandar", "Planta baja", "Cama"
- **Duración** (time)
- **Servicios** (multi-select): "WiFi", "Enchufes", "Aseo", "AC"
- **Wifi disponible** (checkbox)
- **Enchufes** (checkbox)
- **Asientos reclinables** (checkbox)

#### Parte Personal
- **Asiento** (texto): "Asiento 15", "Ventana"
- **Número reserva** (texto): "BUS456789"
- **Planta** (dropdown): "Planta baja", "Planta alta" (si aplica)
- **Lado** (dropdown): "Ventana", "Pasillo"
- **Precio billete** (currency)
- **Maleta facturada** (checkbox)
- **Notas** (texto)

---

### 🚕 Taxi / Transfer

#### Parte Común
- **Origen** (texto + ubicación): "Aeropuerto Barajas T4"
- **Destino** (texto + ubicación): "Hotel XYZ, Calle Mayor 1"
- **Tipo servicio** (dropdown): "Taxi", "Transfer privado", "Shuttle compartido"
- **Compañía** (texto): "Uber", "Taxi oficial", "Transfer.com"
- **Distancia estimada** (texto): "15 km"
- **Duración estimada** (texto): "25 minutos"
- **Precio estimado** (currency)

#### Parte Personal
- **Número reserva** (texto): "TAX123456"
- **Referencia pickup** (texto): "Luigi en Mercedes negro"
- **Confirmado** (checkbox)
- **Tipo vehículo** (dropdown): "Sedán", "SUV", "Van", "Minivan"
- **Asientos necesarios** (número): "4"
- **Maletas** (número): "4"
- **Luggage pesado** (checkbox): Equipaje de ski, bicis, etc.
- **Niños sillas** (número): "2"
- **Asistencia al aeropuerto** (checkbox): Necesita ayuda en aeropuerto
- **Notas conductor** (texto): "Habla inglés", "Codigo pickup ABC123"
- **Precio final** (currency)

---

### 🚗 Coche / Rental

#### Parte Común
- **Ubicación recogida** (texto + ubicación)
- **Ubicación devolución** (texto + ubicación)
- **Compañía rental** (texto): "Hertz", "Europcar", "Sixt"
- **Oficina rental** (texto): "Aeropuerto Barajas"
- **Tipo vehículo** (dropdown): "Económico", "Mediano", "SUV", "Van"
- **Seguro incluido** (checkbox)
- **Combustible incluido** (checkbox)
- **GPS incluido** (checkbox)
- **Silla niño incluida** (checkbox)
- **Precio total** (currency)

#### Parte Personal
- **Número reserva** (texto)
- **Conductores adicionales** (número): "2"
- **Conductores con licencia** (checkbox)
- **Licencia válida** (checkbox)
- **Necesitas GPS** (checkbox)
- **Necesitas silla niño** (checkbox)
- **Combustible al recoger** (dropdown): "Lleno", "3/4", "1/2"
- **Combustible al devolver** (texto, revisión)
- **Precio final** (currency)

---

### 🚢 Barco / Ferry

#### Parte Común
- **Puerto salida** (texto): "Puerto Barcelona"
- **Puerto llegada** (texto): "Palma, Mallorca"
- **Compañía** (texto): "Baleària", "Trasmediterránea"
- **Tipo barco** (texto): "Fast Ferry", "Conventional"
- **Ruta** (texto): "Barcelona-Mallorca"
- **Duración** (time)
- **Servicios** (multi-select): "WiFi", "Restaurante", "Camarotes", "Deck"

#### Parte Personal
- **Número reserva** (texto)
- **Asiento/Cabina** (texto): "Exterior, Ventana", "Cabina interior"
- **Tipo plaza** (dropdown): "Asiento", "Sillón", "Camarote interior", "Camarote exterior"
- **Coche embarcado** (checkbox)
- **Motocicleta embarcada** (checkbox)
- **Bicicleta embarcada** (checkbox)
- **Precio billete** (currency)

---

### 🚶 Caminar / Andando

#### Parte Común
- **Origen** (texto + ubicación)
- **Destino** (texto + ubicación)
- **Distancia estimada** (texto): "2.5 km"
- **Duración estimada** (texto): "30 minutos"
- **Tipo ruta** (dropdown): "Directo", "Tranquilo", "Turístico", "Accesible"
- **Elevación** (texto): "Plano", "Subida moderada", "Escaleras"

#### Parte Personal
- **Necesita mapas offline** (checkbox)
- **Preferencias ruta** (texto): "Evitar escaleras", "Zona turística"
- **Notas** (texto)

---

### 🚲 Bicicleta

#### Parte Común
- **Origen** (texto + ubicación)
- **Destino** (texto + ubicación)
- **Tipo bicicleta** (dropdown): "E-bike", "Normal", "Tándem"
- **Distancia** (texto)
- **Duración estimada** (texto)
- **Servicio alquiler** (texto): "Bike sharing", "Alquiler privado"

#### Parte Personal
- **Hora recogida bici** (texto): Antes de salir
- **Hora devolución** (texto)
- **Necesita casco** (checkbox)
- **He confirmado ruta** (checkbox)
- **Notas** (texto)

---

## 🍽️ RESTAURACIÓN

### General (todos los tipos de restauración)

#### Parte Común
- **Nombre restaurante** (texto + autocomplete)
- **Dirección completa** (texto + ubicación)
- **Tipo cocina** (dropdown): "Local", "Internacional", "Italiana", "Asiática", "Vegetariana"
- **Nivel precio** (dropdown): "€", "€€", "€€€"
- **Telefono** (texto)
- **Web/Reservas** (url)
- **Menú disponible** (url)
- **Reserva confirmada** (checkbox)
- **Hora reserva** (time)
- **Notas** (texto): Recomendaciones, especialidades

#### Parte Personal
- **Asiento/Mesa** (texto): "Mesa 12", "Barra"
- **Número personas** (número)
- **Menú** (dropdown): "Estándar", "Vegetariano", "Sin gluten", etc.
- **Alergias** (texto): Lista de alergias alimentarias
- **Preferencias** (texto): "Sin picante", "Sin marisco"
- **Bebida preferida** (texto)
- **Comentarios** (texto)

---

### 🥐 Desayuno

#### Campos específicos adicionales
- **Tipo desayuno** (dropdown): "Continentál", "Americano", "Bué", "A la carta"
- **Hora servicio** (texto): "07:00 - 10:00"
- **Incluido en alojamiento** (checkbox)

---

### 🍽️ Comida

#### Campos específicos adicionales
- **Menú del día** (checkbox)
- **Menú degustación** (checkbox)
- **Carta completa** (checkbox)
- **Especialidad del día** (texto)

---

### 🍽️ Cena

#### Campos específicos adicionales
- **Ambiente** (dropdown): "Casual", "Formal", "Romántico"
- **Código promocional** (texto)
- **Cena especial** (checkbox): Aniversario, celebración
- **Postre especial** (checkbox)

---

### 🍿 Snack / Merienda

#### Campos específicos adicionales
- **Tipo snack** (dropdown): "Fruta", "Dulce", "Salado", "Bebida"
- **Ubicación** (texto): "Kiosko", "Café", "Carrito"
- **Para llevar** (checkbox)

---

### 🥤 Bebida

#### Campos específicos adicionales
- **Tipo** (dropdown): "Café", "Té", "Bebida fría", "Alcohol", "Agua"
- **Cantidad** (número): "1", "2"
- **Para llevar** (checkbox)
- **Temperatura** (dropdown): "Caliente", "Frío", "Ambiente"

---

### 🍺 Ruta gastronómica / Tapes

#### Parte Común
- **Número paradas** (número): "4"
- **Itinerario** (texto): Lista de lugares
- **Guía incluido** (checkbox)
- **Precio por persona** (currency)

#### Parte Personal
- **Número personas** (número)
- **Incluye bebidas** (checkbox)
- **Vegetariano** (checkbox)

---

## 🎭 ACTIVIDADES

### General (todas las actividades)

#### Parte Común
- **Nombre actividad** (texto + autocomplete)
- **Dirección** (texto + ubicación)
- **Tipo actividad** (dropdown): Ver subtipos abajo
- **Duración estimada** (time)
- **Web/Info** (url)
- **Precio general** (currency): Precio entrada estándar
- **Niños gratis hasta** (número): "hasta 3 años", "hasta 12 años"
- **Accesibilidad** (multi-select): "Silla ruedas", "Coches bebé", "Ascensores"
- **Temporada alta/baja** (checkbox)
- **Horarios** (texto): "09:00-18:00"
- **Escanear código QR** (checkbox): Tickets digitales
- **Notas** (texto): Mejor hora para visitar, trucos

#### Parte Personal
- **Numero entrada/ticket** (texto)
- **Precio pagado** (currency)
- **Audioguía** (checkbox)
- **Guía** (checkbox): Visita guiada
- **Acceso prioritario** (checkbox)
- **Código QR/App** (texto): Para escanear en entrada
- **Comentarios** (texto)

---

### 🏛️ Museos

#### Campos específicos adicionales
- **Tipo museo** (dropdown): "Arte", "Historia", "Ciencia", "Especializado"
- **Colección destacada** (texto)
- **Exposición temporal** (texto)
- **Visita guiada** (checkbox)
- **Audioguía** (checkbox): Idioma disponible
- **Fotografía permitida** (checkbox)
- **Duración recomendada** (texto): "2 horas"

---

### 🏰 Monumentos

#### Campos específicos adicionales
- **Tipo monumento** (dropdown): "Ruinas", "Palacio", "Catedral", "Estatua"
- **Era histórica** (texto)
- **Altura/Escaleras** (texto): "200 escalones"
- **Mejor hora visitar** (texto): "Al amanecer"
- **Entrada restringida** (checkbox): Solo exterior
- **Subir a la torre** (checkbox)
- **Visitado** (checkbox): Ya se visitó anteriormente

---

### 🌳 Parques / Naturaleza

#### Campos específicos adicionales
- **Tipo parque** (dropdown): "Nacional", "Botánico", "Arquitectónico", "Zoológico"
- **Entrada gratuita** (checkbox)
- **Punto picnic** (checkbox)
- **Punto información** (checkbox)
- **Actividades** (multi-select): "Senderismo", "Ciclismo", "Observación aves", "Fotografía"
- **Dificultad** (dropdown): "Fácil", "Moderado", "Difícil"
- **Duración ruta** (texto): "5 km, 2 horas"
- **Equipamiento necesario** (texto): "Zapatos cómodos", "Agua", "Crema solar"

---

### 🎭 Teatro

#### Campos específicos adicionales
- **Obra/Espectáculo** (texto)
- **Compañía teatral** (texto)
- **Idioma** (dropdown): "Original", "Subtitulado", "Traducido"
- **Duración obra** (texto): "2h 30min"
- **Entreacto** (checkbox): "20 min"
- **Edad recomendada** (texto): "Para +12"
- **Producción** (texto): "Grande", "Íntima", "Experimental"

---

### 🎵 Conciertos / Música

#### Campos específicos adicionales
- **Artista/Grupo** (texto)
- **Género** (dropdown): "Rock", "Pop", "Clásica", "Electrónica", "Jazz"
- **Tipo evento** (dropdown): "Concierto", "Festival", "DJ Set", "Clase magistral"
- **Apertura antes** (texto): "Doors open: 19:00"
- **Solo asistencia** (checkbox): Sin mesa, solo música
- **Restricción edad** (texto): "+18", "Todos públicos"

---

### ⚽ Deporte (Eventos)

#### Campos específicos adicionales
- **Equipos** (texto): "Barcelona FC vs Real Madrid"
- **Tipo deporte** (dropdown): "Fútbol", "Tenis", "Básquet", "Fórmula 1"
- **Competición** (texto): "Liga Española", "Wimbledon"
- **Tipo entrada** (dropdown): "Tribuna General", "VIP", "Palco"
- **Fila** (texto)
- **Asiento** (texto)

---

### 🏊 Actividades Acuáticas

#### Campos específicos adicionales
- **Tipo actividad** (dropdown): "Snorkel", "Buceo", "Kayak", "Paddle surf", "Rafting"
- **Nivel** (dropdown): "Principiante", "Intermedio", "Avanzado"
- **Incluye material** (checkbox)
- **Material necesario** (texto): "Traje neopreno", "Aletas"
- **Seguro incluido** (checkbox)
- **Código operador** (texto)

#### Parte Personal
- **Nivel experiencia** (dropdown)
- **Certificado buceo** (checkbox): Si aplica
- **Sabes nadar** (checkbox)
- **Alergias** (texto)
- **Notas** (texto)

---

### 🏔️ Actividades de Montaña

#### Campos específicos adicionales
- **Tipo** (dropdown): "Senderismo", "Escalada", "Ciclismo montaña", "Esquí", "Snowboard"
- **Dificultad** (dropdown): "Fácil", "Moderado", "Difícil", "Experto"
- **Duración** (time)
- **Distancia** (texto): "12 km"
- **Elevación ganada** (texto): "+800m"
- **Guía incluido** (checkbox)
- **Material incluido** (checkbox)
- **Material necesario** (texto)
- **Condiciones** (texto): "Requiere buen clima"

#### Parte Personal
- **Nivel experiencia** (dropdown)
- **Condición física** (dropdown): "Excelente", "Buena", "Regular"
- **Traes material** (checkbox)
- **Alergias** (texto)
- **Notas** (texto)

---

### 🎨 Actividades Creativas

#### Campos específicos adicionales
- **Tipo** (dropdown): "Taller", "Clase magistral", "Curso", "Workshop"
- **Duracion** (time)
- **Material incluido** (checkbox)
- **Material necesario** (texto)
- **Instructor** (texto): Nombre del instructor
- **Nivel requerido** (dropdown): "Principiante", "Intermedio", "Avanzado"
- **Certificado** (checkbox): Se emite certificado
- **Máximo participantes** (número)

#### Parte Personal
- **Nivel experiencia**
- **Tienes material** (checkbox)
- **Necesitas material** (texto)
- **Objetivo** (texto): Qué quieres aprender

---

### 🏋️ Actividades Fitness / Gimnasio

#### Campos específicos adicionales
- **Tipo** (dropdown): "Yoga", "Spinning", "Crossfit", "Pilates", "Zumba"
- **Nivel** (dropdown): "Principiante", "Intermedio", "Avanzado"
- **Duración clase** (time): "1 hora"
- **Instrucciones** (texto)
- **Grupo máximo** (número)

#### Parte Personal
- **Nivel experiencia**
- **Necesitas esterilla** (checkbox)
- **Alergias** (texto)
- **Notas** (texto)

---

## 🏨 ALOJAMIENTOS

### General (todos los alojamientos)

#### Parte Común
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

#### Parte Personal
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

### 🏨 Hotel / Resort

#### Campos específicos adicionales
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

#### Parte Personal
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

### 🏠 Apartamento / Airbnb

#### Campos específicos adicionales
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

### 🏨 Hostal / Albergue

#### Campos específicos adicionales
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

### 🏠 Casa Rural / Chalet

#### Campos específicos adicionales
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

### 🏕️ Camping / Glamping

#### Campos específicos adicionales
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

## 🎉 EVENTOS ESPECIALES

### General (todos los eventos especiales)

#### Parte Común
- **Tipo evento** (dropdown): Ver abajo
- **Nombre evento** (texto)
- **Dress code** (dropdown): "Casual", "Smart casual", "Formal", "Elegante", "Fiesta"
- **Numero personas esperadas** (número)
- **Confirmación necesaria** (checkbox)
- **Tope asistentes** (número)
- **Número confirman** (número): Actuallizar con confirmaciones

---

### 🎂 Cumpleaños / Celebraciones

#### Campos específicos adicionales
- **Celebran** (texto): A quién
- **Edad** (número)
- **Tipo fiesta** (dropdown): "Sorpresa", "Normal", "Temática"
- **Tema** (texto)
- **Regalo común** (checkbox): Todos ponen para un regalo
- **Mensaje grupo** (texto)
- **Café/Cena** (checkbox)

---

### 💑 Boda

#### Campos específicos adicionales
- **Novios** (texto)
- **Ceremonia** (texto + ubicación)
- **Recepción** (texto + ubicación)
- **Código dress code** (dropdown): "Formal", "Semiformal", "Casual elegante"
- **Colores boda** (texto)
- **Mesa asignada** (texto): "Mesa 5"
- **Confirmación asistencia** (checkbox)
- **Regalo** (checkbox)
- **Lista boda** (url)
- **Comida** (dropdown): "Vegetariano", "Sin gluten", etc.
- **Alergias** (texto)
- **Transporte incluido** (checkbox)
- **Hotel recomendado** (texto)
- **Bloqueo habitaciones** (checkbox)

---

### 💼 Evento Corporativo

#### Campos específicos adicionales
- **Empresa** (texto)
- **Nombre evento** (texto): "Annual Meeting"
- **Tipo** (dropdown): "Conferencia", "Networking", "Team building", "Lanzamiento"
- **Agenda disponible** (url)
- **Materiales** (texto)
- **Catering incluido** (checkbox)
- **Ponentes** (texto)
- **Networking** (checkbox)
- **Codigo vestimenta** (dropdown)

---

### 🎪 Festival

#### Campos específicos adicionales
- **Nombre festival** (texto)
- **Tipo** (dropdown): "Música", "Cine", "Comida", "Cultura"
- **Duración** (texto): "3 días"
- **Entrada día** (dropdown): "1 día", "Pas de días", "VIP"
- **Autocamping** (checkbox)
- **Glamping** (checkbox)
- **Autocaravana** (checkbox)
- **Entradas transferibles** (checkbox)
- **Checklist** (texto): Qué llevar

---

## 🛒 OTROS

### 🛒 Compra / Shopping

#### Campos adicionales
- **Tipo** (dropdown): "Souvenir", "Regalo", "Necesidades", "Moda", "Tecnología"
- **Lugar** (texto + ubicación)
- **Presupuesto** (currency)
- **Lista compra** (texto): Qué buscar
- **Ofertas relevantes** (texto)
- **Opening hours** (texto)
- **Tax-free** (checkbox)

#### Parte Personal
- **Para quien** (texto): "Para mi", "Para mi hermana"
- **Presupuesto personal** (currency)
- **Comprado** (checkbox)
- **Gastado** (currency)

---

### 👥 Reunión Social

#### Campos adicionales
- **Lugar** (texto + ubicación)
- **Tipo** (dropdown): "Café", "Cena", "Picnic", "Ruta", "Juego"
- **Asistentes esperados** (número)
- **Confirmación** (checkbox): Necesitas confirmar
- **Traer** (texto): "Trae un plato", "Trae bebidas"
- **Notas** (texto)

#### Parte Personal
- **Voy** (checkbox)
- **Voy +1** (checkbox)
- **Traigo** (texto)

---

### 💼 Trabajo / Negocio

#### Campos adicionales
- **Tipo** (dropdown): "Reunión", "Cliente", "Presentación", "Entrevista"
- **Clientes** (texto)
- **Lugar** (texto + ubicación)
- **Materiales necesarios** (texto)
- **Host** (texto)
- **VIP** (checkbox)

---

### 👤 Personal / Médico

#### Campos adicionales
- **Tipo** (dropdown): "Doctor", "Dentista", "Fisioterapia", "Psicólogo", "Farmàcia", "Personal"
- **Profesional** (texto)
- **Clínica** (texto + ubicación)
- **Motivo** (texto)
- **Resultados** (checkbox): Esperando resultados
- **Recetas** (checkbox): Recoger recetas
- **Seguimiento** (checkbox): Es seguimiento

---

### 🎫 Validación / Ticket

#### Campos adicionales
- **Tipo** (dropdown): "Museo", "Evento", "Transporte", "Otro"
- **Escanear QR** (checkbox)
- **App necesario** (texto)
- **Documentos** (texto): Qué documentos traer
- **Confirmado** (checkbox)

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
- [ ] ¿Usamos estructura `Map<String, dynamic>` para campos flexibles?
- [ ] ¿Cómo validamos campos dinámicos?
- [ ] ¿Cómo mostramos UI según tipo de evento?
- [ ] ¿Migramos eventos existentes o solo nuevos?

### UX
- [ ] ¿Agrupación de campos en secciones?
- [ ] ¿Campos condicionales? (ej: si "viaja con bebé" → mostrar "silla bebé")
- [ ] ¿Plantillas por tipo? (ej: plantilla "Vuelo largo")
- [ ] ¿Búsqueda autocompletar para lugares?

### Datos
- [ ] ¿Integración con APIs externas? (Google Places, Booking.com, etc.)
- [ ] ¿Selector de mapa integrado? (Google Maps picker para ubicaciones)
- [ ] ¿Autocompletar direcciones? (Google Places Autocomplete)
- [ ] ¿Sincronización con servicios externos?
- [ ] ¿Exportación de datos? (PDF, Excel)

---

*Documento creado para T121 - Revisión y enriquecimiento de formularios*  
*Última actualización: Enero 2025*

