# Mejora de Alineación en PlanDataScreen

## Objetivo
Mejorar la alineación visual y la consistencia del layout en la pantalla de datos del plan (`PlanDataScreen`).

## Requisitos de Layout

### 1. Distribución de Columnas
- **Columna izquierda**: Ocupa **2/3** del ancho disponible
- **Columna derecha**: Ocupa **1/3** del ancho disponible
- Esta proporción se aplica a todas las filas de recuadros en modo de pantalla ancha (`isWide = true`)

### 2. Alineación Vertical de Recuadros en la Misma Fila
- Los recuadros que están en la misma fila horizontal deben:
  - **Alinearse en la parte superior** (top-aligned)
  - **Compartir la misma altura**, tomando como referencia el recuadro más alto de la fila
  - Esto significa que si el recuadro izquierdo tiene 400px de altura y el derecho tiene 200px, ambos deben tener 400px de altura

### 3. Alineación de Campos Dentro de los Recuadros
- Los campos (labels, inputs, dropdowns, etc.) dentro de cada recuadro deben:
  - Estar **alineados verticalmente** entre sí
  - Mantener **espaciado consistente** entre campos
  - Los labels deben estar alineados en la misma línea horizontal
  - Los inputs/controles deben estar alineados en la misma línea horizontal

## Secciones Afectadas

### Fila 1: Datos principales del plan y Gestión de Estado
- **Izquierda (2/3)**: `_buildPlanSummarySection()` - Nombre, descripción e imagen del plan (bloque de datos editables). *No incluye el resumen generado en texto (T193), que se abre en diálogo desde el botón "Resumen" de esta pantalla o en vista W31 desde la pestaña Calendario.*
- **Derecha (1/3)**: `_buildStateManagementSection()` - Gestión de estado del plan

### Fila 2: Información del Plan
- **Izquierda (2/3)**: `_buildInfoSection(showBaseInfo: true)` - Información principal (fechas, moneda, presupuesto, visibilidad, timezone)
- **Derecha (1/3)**: `_buildInfoSection(showBaseInfo: false)` - Información meta (UNP ID, ID interno, fecha de creación)

### Fila 3: Participantes y Anuncios
- **Izquierda (2/3)**: `_buildParticipantsSection()` - Lista de participantes
- **Derecha (1/3)**: `_buildAnnouncementsSection()` - Timeline de anuncios

## Implementación Técnica

### Cambios Necesarios

1. **Reemplazar `Expanded` y `SizedBox` con `Flex`**:
   - Usar `Flexible(flex: 2)` para la columna izquierda (2/3)
   - Usar `Flexible(flex: 1)` para la columna derecha (1/3)

2. **Aplicar `crossAxisAlignment: CrossAxisAlignment.stretch`**:
   - En los `Row` que contienen los recuadros, usar `crossAxisAlignment: CrossAxisAlignment.stretch` para que ambos recuadros tengan la misma altura

3. **Asegurar que los `Container`/`Card` usen `height: double.infinity` o `Expanded`**:
   - Los recuadros deben expandirse para ocupar toda la altura disponible de la fila

4. **Alineación interna de campos**:
   - Usar `Column` con `crossAxisAlignment: CrossAxisAlignment.start` para alinear campos verticalmente
   - Usar `Wrap` o `Row` con espaciado consistente para campos horizontales
   - Considerar usar `IntrinsicHeight` si es necesario para alinear campos de diferentes alturas

## Ejemplo Visual

```
┌─────────────────────────────────────┬─────────────┐
│  Datos principales (2/3)            │ Estado (1/3)│
│  - Nombre                           │ - Estado    │
│  - Descripción                      │ - Botones   │
│  - Imagen                           │             │
│                                     │             │
│                                     │             │
│                                     │             │
└─────────────────────────────────────┴─────────────┘
         ↑ Misma altura ↑

┌─────────────────────────────────────┬─────────────┐
│  Información Principal (2/3)         │ Meta (1/3)  │
│  - Fecha inicio                     │ - UNP ID    │
│  - Fecha fin                        │ - ID interno│
│  - Moneda                           │ - Creado    │
│  - Presupuesto                      │             │
│  - Visibilidad                      │             │
│  - Timezone                         │             │
│                                     │             │
└─────────────────────────────────────┴─────────────┘
         ↑ Misma altura ↑
```

## Notas Adicionales

- En modo compacto (pantalla pequeña), mantener el layout en columna vertical como está actualmente
- Los cambios solo aplican cuando `isWide = true` (pantalla >= 960px de ancho)
- Mantener el espaciado entre filas (`cardSpacing = 24`)

---

**Fecha de creación:** Enero 2025  
**Última actualización:** Febrero 2026  
**Estado:** Pendiente de implementación  

**Implementación actual:** En `wd_plan_data_screen.dart` no está aplicado el layout 2/3–1/3 con `Flexible(flex: 2)`/`Flexible(flex: 1)` ni `crossAxisAlignment: CrossAxisAlignment.stretch` en filas anchas; la mejora sigue pendiente.

