# 💰 Sistema de Patrocinios y Monetización

**Estado:** Definición  
**Versión:** 1.0  
**Fecha:** Enero 2025  
**Última actualización:** Febrero 2026  
**Relacionado con:** T143  

*(Documento de definición de producto; no hay implementación en código aún.)*

---

## 🎯 Objetivos de Monetización

1. **Venta de datos anónimos** (principal)
2. **Cuotas de agencias de viajes** - Agencias pagan para cargar planes directamente en la app para sus clientes (ver T132)
3. **Patrocinios contextuales** por categoría/subcategoría
4. **Marketing de afiliados** (comisión por conversión)
5. **Ofertas exclusivas** de patrocinadores

---

## 📋 Tabla de Categorías y Patrocinadores

| Categoría | SubCategoría | Patrocinador Sugerido |
|-----------|--------------|----------------------|
| Restauración | Takeaway | Glovo |
| Restauración | Restaurantes | TripAdvisor |
| Juegos | - | - |
| Guias | Blogs | Viajeros callejeros |
| Redes Sociales | - | Instagram / TikTok |
| Agencias de viajes | - | CheckPoint Charly |
| Servicios de urgencias | Embajadas | - |
| Servicios de urgencias | Policía | - |
| Servicios de urgencias | Salud | - |
| Alojamientos | Hoteles | Booking |
| Alojamientos | Casas/apartamentos | Airbnb |
| Actividades | Tours | Free tours |
| Actividades | Escape Rooms | Civitatis |
| Documentación | Documentos identificativos | - |
| Documentación | Información plan | - |
| Deportes | - | - |
| Tienda | Adaptadores eléctricos | Amazon |
| Tienda | Guías de viajes | La casa del libro |
| Tienda | Detalles por ser invitado | La casa del libro |
| Desplazamientos | Vuelos | Edreams |
| Desplazamientos | Coches alquiler | Avis |
| Desplazamientos | Taxi | FreeNow |
| Desplazamientos | VTS | Uber |
| Parking | Parking privados | Promoparc |
| Tarjetas puntos | - | - |
| Mapas servicios | Bus | TMB |
| Mapas servicios | Metro | - |
| Conectividad | Tarjetas móviles | Holafly |
| Seguros | Seguros de viaje | Mondo |
| Pagos | Cambio de moneda | Revolut |

---

## 🎨 Propuesta de Integración Visual

### **Contexto 1: Creación de Evento/Alojamiento**
- Banner sutil con logo del patrocinador en la parte inferior del modal
- Mensaje: "Patrocinado por [Logo] - Ofertas exclusivas"
- Al hacer clic: abrir web del patrocinador con enlace de afiliado

### **Contexto 2: Visualización de Evento/Alojamiento**
- Badge pequeño con logo del patrocinador (si está patrocinado)
- Opcional: banner expandible con ofertas del patrocinador

### **Contexto 3: Resultados de Búsqueda/Listados**
- Cards de patrocinadores destacados (máx. 1-2 por vista)
- Claramente marcado como "Patrocinado"

---

## 🔐 Consideraciones de Privacidad

- **Datos anónimos:** Solo agregados, sin información personal identificable
- **Consentimiento:** Aceptación explícita de uso de datos para publicidad
- **GDPR compliant:** Cumplimiento de normativa de privacidad
- **Transparencia:** Usuario informado sobre qué datos se comparten

---

## 📊 Tracking y Analytics

- Clicks en patrocinadores (para afiliados)
- Conversiones (si es posible trackear)
- Impresiones de banners/logos
- Categorías más vistas (para targeting)

---

*Documento de referencia para T143*  
*Última actualización: Enero 2025*

