# Sistema de Especificación de Layout

> Sistema para definir la estructura de layout de pantallas para web y móvil

**Última actualización:** Diciembre 2024

---

## 🎯 Objetivo

Definir de forma clara y estructurada la organización visual de cada pantalla, permitiendo:
- Especificar qué elementos van en cada espacio
- Documentar la estructura de forma mantenible
- Facilitar la implementación y modificación
- Funcionar tanto para web como para móvil

---

## 📐 Estructura Básica

Cada pantalla se divide en tres áreas principales:

1. **Barra Superior (BS)** - Header/AppBar
2. **Contenido** - Área principal con filas y columnas
3. **Barra Inferior (BI)** - Footer/Bottom Navigation

### Contenido: Sistema de Filas y Columnas

El contenido se organiza en:
- **Filas (R)**: R1, R2, R3, R4...
- **Columnas (C)**: C1, C2 (máximo 2 columnas por fila)
- **Celdas**: Identificadas como `R:C` (ej: R1:C1, R1:C2, R2:C1)

### Recuadros (F)

Un grupo de celdas puede agruparse en un **Recuadro (F)** que:
- Agrupa múltiples celdas relacionadas
- Puede tener un título
- Facilita la organización visual

---

## 📋 Formato de Especificación

### Estructura JSON

```json
{
  "screen": "NombrePantalla",
  "platform": "web|mobile|both",
  "version": "1.0",
  "lastUpdated": "2024-12-XX",
  
  "layout": {
    "topBar": {
      "type": "appbar|header|custom",
      "height": "auto|number",
      "elements": [
        {
          "id": "element_id",
          "type": "title|button|icon|search|...",
          "position": "left|center|right",
          "properties": {}
        }
      ]
    },
    
    "content": {
      "rows": [
        {
          "id": "R1",
          "height": "auto|flex|number",
          "columns": [
            {
              "id": "C1",
              "width": "auto|flex|number|percentage",
              "element": {
                "type": "card|input|list|text|...",
                "properties": {}
              }
            },
            {
              "id": "C2",
              "width": "auto|flex|number|percentage",
              "element": {
                "type": "card|input|list|text|...",
                "properties": {}
              }
            }
          ]
        }
      ],
      
      "frames": [
        {
          "id": "F1",
          "title": "Título del Recuadro",
          "cells": ["R1:C1", "R1:C2", "R2:C1"],
          "properties": {
            "padding": {},
            "margin": {},
            "decoration": {}
          }
        }
      ]
    },
    
    "bottomBar": {
      "type": "navigation|footer|custom",
      "height": "auto|number",
      "elements": [
        {
          "id": "element_id",
          "type": "button|icon|text|...",
          "position": "left|center|right",
          "properties": {}
        }
      ]
    }
  },
  
  "styles": {
    "spacing": {
      "rowGap": 16,
      "columnGap": 16,
      "padding": {"top": 16, "bottom": 16, "left": 16, "right": 16}
    },
    "colors": {},
    "typography": {}
  }
}
```

---

## 📝 Ejemplo: PlanDataScreen Móvil

Ver: `docs/ux/layout/specs/plan_data_screen_mobile.json`

---

## 🔧 Tipos de Elementos

### Elementos de Barra
- `title` - Título de la pantalla
- `button` - Botón de acción
- `icon` - Icono
- `search` - Campo de búsqueda
- `menu` - Menú de opciones

### Elementos de Contenido
- `card` - Tarjeta/Recuadro con contenido
- `input` - Campo de entrada
- `list` - Lista de items
- `text` - Texto simple
- `image` - Imagen
- `form` - Formulario completo
- `empty` - Estado vacío

### Elementos de Barra Inferior
- `navigation` - Navegación inferior
- `button` - Botón de acción
- `icon` - Icono
- `text` - Texto

---

## 📐 Reglas de Layout

### Filas
- Cada fila puede tener 1 o 2 columnas
- Si tiene 1 columna, ocupa todo el ancho (C1 full width)
- Si tiene 2 columnas, se dividen el espacio (C1 y C2)

### Columnas
- **Ancho:** Puede ser `auto`, `flex`, número en px, o porcentaje
- **Flex:** Si ambas columnas son `flex`, se dividen el espacio equitativamente
- **Flex con ratio:** `flex:2` y `flex:1` = 2/3 y 1/3

### Recuadros
- Agrupan celdas contiguas
- Pueden tener título
- Aplican estilos comunes a todas las celdas agrupadas

---

## 🎨 Diferencias Web vs Móvil

### Web
- Más columnas posibles (puede tener 2 columnas más fácilmente)
- Más espacio horizontal
- Layouts más complejos

### Móvil
- Generalmente 1 columna por fila
- 2 columnas solo cuando tiene sentido (ej: botones lado a lado)
- Más vertical, menos horizontal

---

## 📚 Convenciones

### Nomenclatura
- **Filas:** R1, R2, R3... (siempre números)
- **Columnas:** C1, C2 (máximo 2)
- **Celdas:** R1:C1, R1:C2, R2:C1...
- **Recuadros:** F1, F2, F3...
- **Elementos:** IDs descriptivos (ej: `create_button`, `search_field`)

### Orden
- Filas de arriba a abajo (R1, R2, R3...)
- Columnas de izquierda a derecha (C1, C2)

---

## ✅ Checklist para Crear Spec

- [ ] Definir barra superior (elementos y posiciones)
- [ ] Definir filas del contenido (R1, R2, R3...)
- [ ] Definir columnas en cada fila (C1, C2)
- [ ] Especificar elemento en cada celda
- [ ] Agrupar celdas en recuadros (si aplica)
- [ ] Definir barra inferior
- [ ] Especificar estilos (espaciados, colores)
- [ ] Documentar diferencias web vs móvil (si aplica)

---

## 🔄 Proceso de Trabajo

1. **Crear spec inicial** basado en código actual
2. **Modificar spec** para reflejar cambios deseados
3. **Implementar** cambios en código según spec
4. **Actualizar spec** si hay ajustes durante implementación

---

**Próximos pasos:**
- [ ] Crear template base
- [ ] Crear ejemplo para PlanDataScreen móvil
- [ ] Crear ejemplo para Dashboard web
- [ ] Documentar proceso de uso

