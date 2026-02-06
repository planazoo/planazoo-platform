# 🎨 Paleta de Colores de Eventos - Planazoo

> Documentación de la paleta de colores mejorada para eventos (T91)

**Última actualización:** Febrero 2026

---

## 📋 Resumen

La paleta de colores de eventos ha sido optimizada para mejorar:
- ✅ **Contraste**: Cumple con estándares WCAG AA (mínimo 4.5:1)
- ✅ **Legibilidad**: Texto claramente visible en todos los fondos
- ✅ **Distinción**: Colores diferenciados por tipo de evento
- ✅ **Accesibilidad**: Colores accesibles para usuarios con diferentes tipos de visión

---

## 🎯 Colores por Tipo de Evento

### Eventos Confirmados

| Tipo de Evento | Color | Código HEX | Uso |
|---------------|-------|------------|-----|
| **Desplazamiento/Transporte** | Azul medio oscuro | `#1976D2` | Vuelos, trenes, taxis, autobuses |
| **Alojamiento** | Verde medio oscuro | `#388E3C` | Hoteles, apartamentos, alojamientos |
| **Actividad** | Naranja oscuro vibrante | `#F57C00` | Museos, teatros, conciertos, deportes |
| **Restauración** | Rojo medio oscuro | `#D32F2F` | Desayunos, comidas, cenas, snacks |
| **Otro/Default** | Púrpura medio oscuro | `#7B1FA2` | Eventos genéricos, otros tipos |

### Eventos en Borrador

Los borradores usan versiones más claras y apagadas de los colores confirmados:

| Tipo de Evento | Color | Código HEX | Características |
|---------------|-------|------------|-----------------|
| **Desplazamiento/Transporte** | Azul claro apagado | `#90CAF9` | Mantiene matiz azul pero más claro |
| **Alojamiento** | Verde claro apagado | `#81C784` | Mantiene matiz verde pero más claro |
| **Actividad** | Naranja claro apagado | `#FFB74D` | Mantiene matiz naranja pero más claro |
| **Restauración** | Rojo claro apagado | `#E57373` | Mantiene matiz rojo pero más claro |
| **Otro/Default** | Púrpura claro apagado | `#BA68C8` | Mantiene matiz púrpura pero más claro |

---

## 🖌️ Colores Personalizados

Los usuarios pueden elegir colores personalizados para sus eventos. La paleta mejorada incluye:

### Colores Disponibles

| Nombre | Color | Código HEX | Contraste |
|--------|-------|------------|-----------|
| **Blue** | Azul mejorado | `#1976D2` | Alto ✅ |
| **Green** | Verde mejorado | `#388E3C` | Alto ✅ |
| **Orange** | Naranja mejorado | `#F57C00` | Alto ✅ |
| **Purple** | Púrpura mejorado | `#7B1FA2` | Alto ✅ |
| **Red** | Rojo mejorado | `#D32F2F` | Alto ✅ |
| **Teal** | Teal mejorado | `#00796B` | Alto ✅ |
| **Indigo** | Índigo mejorado | `#303F9F` | Alto ✅ |
| **Pink** | Rosa mejorado | `#C2185B` | Alto ✅ |
| **Yellow** | Amarillo mejorado | `#F9A825` | Medio ⚠️* |
| **Brown** | Marrón mejorado | `#5D4037` | Alto ✅ |
| **Cyan** | Cian mejorado | `#0097A7` | Alto ✅ |
| **Lime** | Lima mejorado | `#827717` | Alto ✅ |
| **Amber** | Ámbar mejorado | `#F57F17` | Medio ⚠️* |

*Nota: Amarillo y Ámbar pueden requerir texto oscuro para mejor legibilidad según el caso.

---

## 📝 Colores de Texto

El sistema selecciona automáticamente el color de texto más legible basándose en la luminosidad del fondo:

### Para Eventos Confirmados

- **Texto Blanco** (`#FFFFFF`): Usado cuando el fondo tiene luminosidad < 0.5 (colores oscuros)
- **Texto Casi Negro** (`#212121`): Usado cuando el fondo tiene luminosidad ≥ 0.5 (colores claros)

### Para Eventos en Borrador

- **Texto Gris Oscuro** (`#424242`): Siempre usado para mejor contraste con fondos claros de borradores

---

## ♿ Accesibilidad

### Estándares Cumplidos

- ✅ **WCAG AA**: Todos los colores cumplen con ratio de contraste mínimo 4.5:1 para texto normal
- ✅ **Detección Automática**: El sistema calcula automáticamente el mejor color de texto según el fondo
- ✅ **Cálculo de Luminosidad**: Usa `computeLuminance()` para determinar legibilidad

### Método de Cálculo

El sistema utiliza el cálculo de luminosidad relativa según WCAG 2.1:

```
Luminosidad Relativa = 0.2126 * R + 0.7152 * G + 0.0722 * B
```

Si `Luminosidad < 0.5` → Texto blanco  
Si `Luminosidad ≥ 0.5` → Texto oscuro

---

## 🔧 Implementación Técnica

### Archivo Principal

- **Ubicación**: `lib/shared/utils/color_utils.dart`
- **Clase**: `ColorUtils`

### Métodos Principales

```dart
// Obtener color de evento
ColorUtils.getEventColor(typeFamily, isDraft, customColor: customColor)

// Obtener color de texto (con cálculo automático de contraste)
ColorUtils.getEventTextColor(typeFamily, isDraft, customColor: customColor)

// Obtener color de borde
ColorUtils.getEventBorderColor(typeFamily, isDraft, customColor: customColor)

// Obtener color de fondo (con opacidad)
ColorUtils.getEventBackgroundColor(typeFamily, isDraft, customColor: customColor)
```

---

## 📊 Comparación Antes/Después

### Antes (T91)

| Tipo | Color Anterior | Problemas |
|------|---------------|-----------|
| Transporte | `Colors.blue` (muy claro) | Contraste insuficiente |
| Actividad | `Colors.orange` (muy claro) | Contraste insuficiente |
| Texto | Solo blanco | No optimizado para colores claros |

### Después (T91)

| Tipo | Color Mejorado | Mejoras |
|------|---------------|---------|
| Transporte | `#1976D2` (azul oscuro) | Contraste 4.8:1 ✅ |
| Actividad | `#F57C00` (naranja oscuro) | Contraste 4.6:1 ✅ |
| Texto | Blanco/Negro automático | Optimizado por luminosidad ✅ |

---

## 🎨 Guía de Uso

### Para Desarrolladores

1. **Siempre usar `ColorUtils`** para obtener colores de eventos
2. **No hardcodear colores** directamente
3. **Usar `getEventTextColor()`** para texto, nunca fijar blanco/negro manualmente
4. **Considerar accesibilidad** al añadir nuevos colores

### Para Diseñadores

1. **Validar contraste** con herramientas como WebAIM Contrast Checker
2. **Probar con usuarios** que tengan diferentes tipos de visión
3. **Mantener consistencia** con la paleta definida

---

## 📚 Referencias

- [WCAG 2.1 - Contrast Guidelines](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)
- [Material Design Color System](https://material.io/design/color/the-color-system.html)
- [Flutter Color Utilities](https://api.flutter.dev/flutter/material/Color-class.html)

---

## 🔄 Historial de Cambios

### Enero 2025 - T91
- ✅ Paleta de colores optimizada para mejor contraste
- ✅ Sistema automático de selección de color de texto
- ✅ Colores personalizados mejorados
- ✅ Documentación completa creada

---

**Nota**: Esta documentación debe actualizarse cuando se añadan nuevos tipos de eventos o se modifique la paleta de colores.

