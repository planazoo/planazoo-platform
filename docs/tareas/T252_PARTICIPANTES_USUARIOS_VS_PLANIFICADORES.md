# T252 – Participantes "usuarios" vs "planificadores"

**Objetivo:** Definir y documentar soluciones de producto y UX para participantes del plan que usan la app más como viajeros que como organizadores, de modo que tengan una experiencia centrada en "qué me toca a mí" sin necesidad de actuar como planificadores.

**Referencia en lista:** `docs/tareas/TASKS.md` (T252).

---

## Alcance y exclusiones

- **Incluye:** Definición de vistas, flujos, resumen por participante, recordatorios, propuestas de eventos, confirmación de asistencia (ya implementada), exportación/imprimir (diseño), onboarding ligero. Documentación y, si aplica, tareas de implementación derivadas.
- **No incluye:**
  - Cambios en reglas de permisos ni roles (otra tarea).
  - Rediseño completo del calendario; en T252 solo vistas y resumen.
  - La implementación de exportación/imprimir y uso offline puede depender de las tareas de offline (T56–T62) cuando corresponda; en T252 se diseña.

---

## 1. Contenido de "Mi resumen" / "Mi itinerario"

- **Vista "hoy y mañana":** Pantalla donde el participante ve lo que tiene **hoy** y lo que tiene **mañana**, agrupado por día.
- **Vista lista cronológica:** Todo el plan en orden temporal (de inicio a fin del viaje), para ver el itinerario completo.
- **Accesos rápidos:** Bloques o enlaces directos a información clave:
  - "Mis vuelos" (y en el futuro, si aplica: trenes, reservas relevantes).
  - "Mi alojamiento".
- **Combinación:** Lista detallada + resumen por día; "hoy/mañana" y lista completa son dos formas de ver el mismo contenido.

---

## 2. Dónde vive "Mi resumen"

Las tres formas acordadas (todas):

- **A) Pestaña dentro del plan:** "Mi resumen" o "Mi itinerario" como pestaña más, junto a Calendario, Info del plan, Participantes, etc.
- **B) Acceso directo:** Botón o enlace tipo "Ver mi resumen" en la cabecera o en el menú del plan que lleve a una pantalla dedicada.
- **C) Vista por defecto para participantes:** Al abrir el plan, si el usuario es **participante** (no organizador), la primera vista es "Mi resumen"; desde ahí puede ir a Calendario, Info, etc.

---

## 3. Calendario vs resumen en la misma página

- La **misma página** que hoy es "Calendario" puede ofrecer al participante **dos modos** elegibles:
  - **Modo calendario:** Rejilla por días/horas (orientada a planificación; ver todo el plan).
  - **Modo resumen:** "Mi itinerario" (hoy/mañana, lista cronológica, accesos rápidos a vuelos/alojamiento).
- Un solo hueco en la navegación (p. ej. "Calendario" o "Itinerario") con **selector de vista**: "Ver como calendario" / "Ver mi resumen" (o "Vista planificador" / "Vista viajero"). El participante elige; el planificador usa sobre todo el calendario.

---

## 4. "Lo más importante del plan" + información personal (un pantallazo)

- **Vista de un pantallazo:** El participante ve en una sola pantalla:
  - **Lo más importante del plan:** Definido por el **sistema** (fechas del plan, alojamiento, vuelos/desplazamientos clave, y si aplica primer/último evento). El organizador no marca manualmente "destacados".
  - **Su parte personal:** Sus datos relevantes (asiento, puerta, menú, reservas, etc.) sin tener que abrir evento por evento.
- Este bloque puede ser la **parte superior** de "Mi resumen" o la **primera sección** al entrar: "Resumen del plan + mi información".

---

## 5. Recordatorios

- **Recordatorios automáticos** con reglas fijas (p. ej. 1 día antes y el mismo día), sin configuración por usuario por ahora.
- Ejemplo: "Mañana 10:00 – Vuelo IB6842", "Hoy 19:00 – Cena en…".

---

## 6. Exportar / imprimir

- El participante debe poder **exportar o imprimir** su itinerario ("Mi itinerario") y, si aplica, el **plan completo** (para el organizador o quien tenga permiso).
- **Estrategia offline-first:** Diseñar la funcionalidad para que encaje con la estrategia ya en marcha (p. ej. generar desde datos locales cuando no haya red). La implementación puede enlazar con el grupo Offline (T56–T62) cuando corresponda.

---

## 7. Onboarding / primera vez como participante

- **Solo un tooltip o hint** la primera vez que el participante esté en "Mi resumen" (ej. "Esta es tu vista como participante").
- Sin onboarding largo ni tutorial paso a paso.

---

## 8. Proponer eventos

- El participante puede **proponer** eventos; el organizador **acepta o rechaza**.
- **Notificación al organizador:** Push y/o entrada en el buzón de notificaciones cuando un participante propone un evento.
- **Lista de propuestas en el plan:** Pestaña o sección "Propuestas pendientes" en el plan para que el organizador las revise al entrar.

---

## 9. Confirmar asistencia por evento

- **Por evento:** El participante puede marcar "Voy" / "No voy" (o "Asistiré" / "No asistiré") en cada evento.
- **Estado en código:** Ya implementado (T120): `Event.requiresConfirmation`, `EventParticipant.confirmationStatus` (`pending` | `confirmed` | `declined`), `EventParticipantService.confirmAttendance()` / `declineAttendance()`, `EventParticipantRegistrationWidget` en el modal de evento.
- **En T252:** Asegurar que esta confirmación esté bien integrada en la vista "Mi resumen" y en el flujo del participante, y documentarlo. No reimplementar la lógica.

---

## 10. Resumen de decisiones (checklist para documento de diseño)

| Tema | Decisión |
|------|----------|
| Contenido Mi resumen | Hoy/mañana + lista cronológica + accesos rápidos (vuelos, alojamiento) |
| Dónde vive | Pestaña + botón "Ver mi resumen" + landing por defecto para participantes |
| Calendario vs resumen | Misma página, dos modos: calendario o mi resumen |
| Lo más importante | Sale del sistema (fechas, alojamiento, vuelos, etc.); no lo marca el organizador |
| Pantallazo | Resumen del plan + mi información personal en una sola vista |
| Recordatorios | Automáticos, reglas fijas (ej. 1 día antes, mismo día) |
| Exportar/imprimir | Sí: mi itinerario y plan completo; diseño offline-first |
| Onboarding | Solo tooltip/hint la primera vez en "Mi resumen" |
| Proponer eventos | Sí; notificación al organizador + lista "Propuestas pendientes" |
| Confirmar asistencia | Por evento; ya implementado; integrar en Mi resumen y documentar |
| Exclusiones | No permisos/roles; no rediseño completo del calendario; export/offline se diseñan aquí, implementación según T56–T62 |

---

## Próximos pasos (cuando se implemente)

1. Redactar o actualizar flujos en `docs/flujos/` (participante: ver mi resumen, proponer evento, confirmar asistencia).
2. Definir wireframes o maquetas de "Mi resumen" (hoy/mañana, lista, accesos rápidos, pantallazo).
3. Derivar tareas de implementación (p. ej. nueva pestaña, providers, notificaciones de propuestas, export).
4. Revisar integración de confirmación de asistencia en "Mi resumen" y en listados de eventos del participante.

---

## Estado de implementación

| Ítem | Estado |
|------|--------|
| Pestaña "Mi resumen" + pantalla (hoy/mañana, cronológica, accesos rápidos, pantallazo) | Hecho |
| Landing por defecto para participantes + tooltip primera vez | Hecho |
| **Selector Calendario / Mi resumen en pestaña Calendario** | **Hecho** (segmentos "Calendario" \| "Mi resumen") |
| **Proponer eventos** (participante propone como borrador → notificación al organizador; ver propuestas en calendario + filtro "Solo propuestas" en menú Filtro de eventos; sin pestaña dedicada) | **Hecho** |
| **Prueba de proponer eventos** (flujo participante → notificación → organizador acepta/rechaza) | **Pendiente** |
| Recordatorios automáticos (reglas fijas) | Pendiente |
| Exportar/imprimir (mi itinerario y plan completo) | Pendiente |
| **Botón "Ver mi resumen" en cabecera** (opcional) | **Hecho** (icono en AppBar PlanDetailPage + enlace en header dashboard W6) |
