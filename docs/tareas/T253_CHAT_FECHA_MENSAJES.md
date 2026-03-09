# T253 – Mostrar fecha en el chat del plan

**Objetivo:** Mostrar la fecha (y, si se decide, la hora) de los mensajes del chat del plan de forma clara y usable.

**Referencia en lista:** `docs/tareas/TASKS.md` (T253). Relacionado con T190 (sistema de chat del plan).

---

## Opciones consideradas

### Opción A: Separador de fecha al cambiar de día (estilo WhatsApp)

- Se inserta una **línea o franja con la fecha** entre el último mensaje de un día y el primero del siguiente.
- Ejemplo: `———  Martes, 4 de marzo  ———`
- Los mensajes no llevan fecha visible en el texto; la hora puede mostrarse en cada burbuja (ej. "14:32") para precisión sin saturar.

**Ventajas:** Interfaz limpia, patrón muy conocido, menos ruido visual.  
**Inconvenientes:** Si solo se muestra hora en la burbuja, al scroll largo puede costar saber “qué día es” sin mirar el separador más cercano.

---

### Opción B: Fecha y hora en cada mensaje

- Cada mensaje muestra **fecha y hora** (ej. "4 mar 2025, 14:32" o "Hoy 14:32" / "Ayer 09:15").
- No hay separadores entre días.

**Ventajas:** Información explícita en cada mensaje.  
**Inconvenientes:** Más repetición visual y más espacio; en conversaciones largas puede resultar pesado.

---

## Recomendación

**Opción A (separador de día + hora en burbuja):**

1. **Separador de fecha** al cambiar de día: una línea con la fecha formateada (localizada: "Martes, 4 de marzo" o "Hoy", "Ayer" cuando aplique).
2. **Hora en cada burbuja** (ej. debajo del texto o en una esquina): así se mantiene la precisión sin duplicar la fecha en cada mensaje.
3. Es el patrón que la mayoría de usuarios ya conoce (WhatsApp, Telegram, etc.) y mantiene el chat legible en planes con mucho historial.

Si en pruebas se ve que falta contexto de fecha en algún caso, se puede complementar mostrando fecha abreviada en la primera burbuja del día (ej. "4 mar · 14:32") además del separador.

---

## Alcance de la tarea

- **Incluye:** Implementar la opción elegida (A o B) en la UI del chat del plan: modelo de mensaje ya tiene `createdAt`; falta presentación (separadores y/o fecha/hora por mensaje), con formato localizado y timezone del usuario/plan si aplica.
- **No incluye:** Cambios en el modelo de datos del mensaje ni en la lógica de envío/recepción (salvo que se necesite algo mínimo para agrupar por día).

---

## Criterios de aceptación (si se elige Opción A)

- [ ] Al cambiar de día entre mensajes consecutivos, se muestra un separador con la fecha (formato localizado; "Hoy"/"Ayer" cuando corresponda).
- [ ] Cada burbuja de mensaje muestra la hora (formato corto, ej. 14:32).
- [ ] Separador y hora respetan la zona horaria del plan o del usuario (definir criterio y documentar).
