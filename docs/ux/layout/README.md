# Sistema de Especificación de Layout

> Sistema para definir y documentar la estructura de layout de pantallas

**Última actualización:** Diciembre 2024

---

## 📋 Descripción

Este sistema permite definir de forma estructurada la organización visual de cada pantalla, especificando:
- Qué elementos van en cada espacio
- Cómo se organizan (filas, columnas, recuadros)
- Estilos y propiedades de cada elemento
- Diferencias entre web y móvil

---

## 📁 Estructura de Archivos

```
docs/ux/layout/
├── README.md                    # Este archivo
├── LAYOUT_SPEC_SYSTEM.md        # Documentación del sistema
├── specs/
│   ├── TEMPLATE_LAYOUT_SPEC.json    # Template base
│   ├── plans_list_page_mobile.json  # Ejemplo: Lista de planes móvil
│   ├── plan_data_screen_mobile.json # Ejemplo: Datos del plan móvil
│   └── dashboard_web.json           # Ejemplo: Dashboard web
```

---

## 🎯 Conceptos Clave

### Estructura Básica
- **BS (Barra Superior)**: Header/AppBar
- **Contenido**: Área principal con filas y columnas
- **BI (Barra Inferior)**: Footer/Bottom Navigation

### Sistema de Filas y Columnas
- **Filas (R)**: R1, R2, R3, R4...
- **Columnas (C)**: C1, C2 (máximo 2 por fila)
- **Celdas**: Identificadas como `R:C` (ej: R1:C1, R1:C2)

### Recuadros (F)
- Agrupan múltiples celdas relacionadas
- Pueden tener título
- Aplican estilos comunes

---

## 📖 Cómo Usar

### 1. Crear Nueva Spec

1. Copiar `TEMPLATE_LAYOUT_SPEC.json`
2. Renombrar: `[nombre_pantalla]_[plataforma].json`
3. Completar según la estructura de la pantalla

### 2. Definir Layout

1. **Barra Superior**: Elementos y posiciones
2. **Filas del Contenido**: R1, R2, R3...
3. **Columnas en cada fila**: C1, C2
4. **Elementos en cada celda**: Tipo y propiedades
5. **Recuadros**: Agrupar celdas relacionadas
6. **Barra Inferior**: Elementos y posiciones

### 3. Especificar Estilos

- Espaciados (padding, margin, gap)
- Colores
- Tipografía
- Decoraciones (bordes, sombras)

### 4. Documentar Diferencias

- Si aplica a web y móvil, documentar diferencias
- Especificar comportamientos responsive

---

## 📝 Ejemplos

### Móvil: PlansListPage
Ver: `specs/plans_list_page_mobile.json`

**Estructura:**
- BS: Título + botón crear
- R1: Campo de búsqueda
- R2: Botones de filtro
- R3: Lista de planes (flex)
- BI: Botón de perfil

### Móvil: PlanDataScreen
Ver: `specs/plan_data_screen_mobile.json`

**Estructura:**
- BS: Nombre del plan
- R1: Resumen del plan (F1)
- R2: Estado del plan (F2)
- R3: Información (F3)
- R4: Información Meta (F4)
- R5: Participantes (F5)
- R6: Anuncios (F6)
- R7: Botón eliminar

### Web: DashboardPage
Ver: `specs/dashboard_web.json`

**Estructura:**
- Grid 17x13
- Widgets posicionados en celdas específicas
- Ver `assets/ux_specification.json` para detalles completos

---

## 🔄 Proceso de Trabajo

1. **Analizar pantalla actual:**
   - Identificar elementos
   - Mapear a estructura R:C
   - Identificar recuadros

2. **Crear spec inicial:**
   - Basado en código actual
   - Documentar estructura existente

3. **Modificar spec:**
   - Ajustar layout según necesidades
   - Cambiar elementos, posiciones, estilos

4. **Implementar cambios:**
   - Aplicar modificaciones en código
   - Verificar que coincide con spec

5. **Actualizar spec:**
   - Reflejar cambios finales
   - Mantener documentación sincronizada

---

## ✅ Checklist para Nueva Spec

- [ ] Barra superior definida
- [ ] Filas del contenido identificadas (R1, R2, R3...)
- [ ] Columnas en cada fila especificadas (C1, C2)
- [ ] Elementos en cada celda documentados
- [ ] Recuadros identificados y agrupados
- [ ] Barra inferior definida
- [ ] Estilos especificados (espaciados, colores, tipografía)
- [ ] Diferencias web/móvil documentadas (si aplica)
- [ ] Notas y consideraciones añadidas

---

## 📚 Referencias

- **Sistema completo:** `LAYOUT_SPEC_SYSTEM.md`
- **Template:** `specs/TEMPLATE_LAYOUT_SPEC.json`
- **Ejemplos:** Ver archivos en `specs/`

---

**Próximos pasos:**
- [ ] Crear specs para todas las pantallas principales
- [ ] Mantener specs actualizadas con código
- [ ] Usar specs como referencia para modificaciones

