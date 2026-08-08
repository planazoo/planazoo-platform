# T272 — Colores de tipos de evento a nivel de plan (carril/borde)

**Estado:** Implementado (MVP 2026-08). Decisiones de producto cerradas.  
**Relacionado:** T91 (paleta), T250 / `EVENT_FORM_FIELDS.md`, T270 (catálogo tipos), UI-ST carril semántico en calendario, Info del plan (`wd_plan_data_screen.dart`).

### Implementación
- Modelo: `Plan.eventAccentBaseColor`, `Plan.eventTypeAccentColors`
- Resolución: `PlanEventAccentColors`
- Propagación: `EventService.updateAccentColorForTypeFamilies`
- UI: sección en Info del plan (organizador)
- Alta evento: color desde config al crear / al cambiar familia


---

## 1. Objetivo

Permitir definir en la **Info del plan** el color del **carril/borde** de los eventos por **familia de tipo**, con un **color base del plan**. Al crear eventos se usa esa config; al cambiar un color se **propagan** a todos los eventos existentes de ese tipo en el plan.

Por defecto (planes sin tocar la config) todos se ven iguales (color base = `color2` / W1), que es el comportamiento actual deseado.

---

## 2. Decisiones cerradas

| # | Decisión |
|---|----------|
| 1 | Granularidad: **familia** (Desplazamiento, Restauración, Actividad, Acción, Otro). No subtipos en MVP. |
| 2 | Override por evento: **no se respeta** al propagar (opción A). Cambiar el color de una familia pisa el color de todos los eventos de esa familia. |
| 3 | Afecta solo **carril/borde** (acento UI-ST), no el fondo de la tarjeta. |
| 4 | Familia **Otro** (y eventos sin tipo tratado como base/Otro): **sí** tienen fila en la config. |
| 5 | **Alojamientos fuera** de este sistema (siguen su color propio). |
| 6 | Edición de la paleta: **solo organizador** (o rol equivalente que ya gestione Info del plan). |
| 7 | Tipos nuevos (T270): si aparece una familia nueva, usar **color base** hasta que se configure. |
| 8 | Migración: planes viejos **sin** mapa de colores → color base implícito `color2`; sin reescritura masiva hasta que el usuario guarde la config. |
| 9 | Existe un **color base del plan** en la config (default de todos los tipos y de eventos sin mapeo). |

---

## 3. Modelo de datos (propuesta)

En `Plan` (Firestore), campos nuevos opcionales:

```text
eventAccentBaseColor: String   // p. ej. "color2"
eventTypeAccentColors: Map<String, String>
  // claves = typeFamily canónicas: Desplazamiento, Restauración, Actividad, Acción, Otro
  // valores = nombres de paleta ColorUtils (blue, green, color2, …)
```

Resolución al pintar / al crear:

1. Si hay entrada para `typeFamily` en `eventTypeAccentColors` → ese color.  
2. Si no → `eventAccentBaseColor` (o `color2` si falta).  
3. Alojamientos: sin cambio.

Al **guardar** un cambio de color de familia (o del base, si se decide propagar base): actualizar `customColor` / campo de color de acento de **todos** los eventos del plan con esa `typeFamily`.

Al **crear** evento: inicializar color del evento desde la resolución anterior (no dejar vacío si la config tiene valor).

---

## 4. UX

### Info del plan (organizador)
Sección **“Colores del calendario”** (o similar, l10n):
- Fila **Color base del plan** + swatch.
- Filas por familia (icono + nombre + swatch).
- Opcional: “Restaurar defaults” → todas las familias = color base.
- Al cambiar un swatch y confirmar: mensaje *“Se actualizarán N eventos de {familia}”* (o actualización directa con snackbar de N).

### Calendario
El carril usa el color del evento (ya propagado / asignado al crear). Sin lógica especial de “tema en runtime” más allá de leer el color del evento; la fuente de verdad de defaults futuros es el Plan.

### Diálogo de evento
Selector de color del evento: en MVP puede permanecer, pero al **cambiar la config del plan** se pisa (decisión 2). Fase 2: ocultar o marcar “viene del plan”.

---

## 5. Criterios de aceptación

- [ ] Info del plan muestra color base + colores por familia (solo organizador edita).  
- [ ] Plan nuevo / sin config: todos los carriles con color base (`color2`).  
- [ ] Crear evento de familia X → color = config de X (o base).  
- [ ] Cambiar color de familia X → todos los eventos X del plan actualizan color; N coherente.  
- [ ] Cambiar color base: definir UX — o bien solo afecta tipos sin override de familia / nuevos, o propaga a familias que aún apuntaban al base anterior (documentar en implementación; preferencia: **actualizar familias cuyo color era igual al base anterior + eventos de esas familias**).  
- [ ] Alojamientos no cambian.  
- [ ] Participantes no organizadores ven la sección en solo lectura (o no la ven).  
- [ ] Tests: resolución de color; propagación por familia.

---

## 6. Notas técnicas

- Reutilizar paleta `ColorUtils.colorFromName` / swatches del diálogo de evento.  
- Carril: `accentColor` en `wd_calendar_screen` / mobile a partir del color del evento.  
- Batch update Firestore (chunks si N grande) + invalidar providers de eventos.  
- Alinear con T270: claves de familia estables (persistidas ES hoy).  
- Documentar en `EVENT_COLOR_PALETTE.md` o anexo corto.

---

## 7. Fuera de alcance (MVP)

- Color por subtipo.  
- Respetar overrides manuales por evento.  
- Colorear fondo de tarjeta.  
- Alojamientos.  
- Aplicar paleta global de usuario entre planes.
