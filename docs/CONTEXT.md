## 📘 Documento de Contexto y Normas de Colaboración

Este documento fija criterios estables para trabajar juntos sin olvidar pasos clave, manteniendo consistencia entre código, documentación y comunicación.

**📋 DOCUMENTOS COMPLEMENTARIOS:**
- `docs/PROMPT_BASE.md` - Metodología de trabajo general y patrones de comunicación
- `docs/GESTION_TIMEZONES.md` - Sistema de gestión de timezones (T40)
- `docs/FLUJO_CREACION_PLAN.md` - Índice y visión general del sistema de planes
- `docs/flujos/` - Flujos específicos de procesos (estados, participantes, eventos, etc.)

---

### 1) Idioma y Estilo de Comunicación
- Toda la comunicación es en castellano.
- Respuestas concisas y accionables; detalles técnicos cuando aporten valor.
- Evitar bloquear por confirmaciones innecesarias; preguntar solo si hay ambigüedad real.
- No mostrar código en propuestas: aplicar directamente y describir el cambio a alto nivel.

### 2) Flujo de Trabajo de Tareas
- Las tareas activas se gestionan en `docs/TASKS.md`.
- **Confirmación del usuario antes de marcar tareas como completadas.**
- Al completar una tarea:
  - Actualizar estado en `docs/TASKS.md`.
  - Mover la tarea a `docs/COMPLETED_TASKS.md` con fecha, criterios y archivos modificados.
  - Ajustar contadores/resúmenes si aplica.

### 3) Control de Código y Commits
- No realizar `git push` sin confirmación explícita del usuario.
- Commits deben ser atómicos y descriptivos (prefijo con código de tarea si aplica, p. ej. `T73:`).
- Evitar dejar `print()` o logs ruidosos en producción; usar logger si se necesita.

### 4) Persistencia y Decisiones de Datos
- Persistencia local solo para prototipos rápidos; versión final debe ser global (Firestore) salvo indicación contraria.
- Identificadores estables (p. ej., `participantId`) para persistir orden/configuración; evitar IDs efímeros.

### 5) UI/UX y Calidad
- Mantener UI consistente: tamaños, tipografías, colores según `AppColorScheme`.
- Evitar regresiones de interacción (tap, drag&drop, dobles clics).
- Revisar lints tras cada cambio en archivos modificados.
- Al cerrar una tarea: eliminar `print()`, debugs y código temporal que ya no sea necesario.

### 6) Documentación
- Actualizar `docs/CALENDAR_CAPABILITIES.md` cuando cambie el comportamiento del calendario.
- Añadir notas breves en `ARCHITECTURE_DECISIONS.md` para decisiones relevantes (p. ej., persistencia).
- Mantener `CONTEXT.md` como referencia viva de normas.
- **Flujos de Proceso:** Consular flujos en `docs/flujos/` antes de tomar decisiones o implementar funcionalidades:
  - `FLUJO_ESTADOS_PLAN.md` - Estados y transiciones
  - `FLUJO_GESTION_PARTICIPANTES.md` - Invitaciones y gestión de participantes
  - `FLUJO_MODIFICAR_EVENTOS.md` - CRUD de eventos
  - `FLUJO_PRESUPUESTO_PAGOS.md` - Sistema financiero
  - `FLUJO_INVITACIONES_NOTIFICACIONES.md` - Comunicación
  - `FLUJO_VALIDACION.md` - Validación y verificación
  - `FLUJO_GESTION_USUARIOS.md` - Registro, login y gestión de usuarios
- Al implementar una funcionalidad completa: revisar si debe actualizarse el flujo correspondiente en `docs/flujos/`.

### 7) Plan Frankenstein (revisión tras cambios)
- Tras aprobar cambios funcionales, evaluar si deben incorporarse al Plan Frankenstein.
- Si aplica, actualizar:
  - `docs/FRANKENSTEIN_PLAN_SPEC.md` (escenarios y checklist)
  - `lib/features/testing/demo_data_generator.dart` (datos de demo/casos)
  - Notas breves en `CALENDAR_CAPABILITIES.md` si afecta a capacidades visibles

### 8) Tests Manuales Rápidos (checklist mínimo)
- Crear/editar/eliminar evento y ver refresco inmediato.
- Arrastrar evento vertical/horizontal (magnetismo y límites).
- Alojamientos: crear/editar; ver check-in/out.
- Filtros: Plan Completo / Mi Agenda / Personalizada (aplicar refresca al instante).
- Reordenación de tracks: abrir modal (AppBar/doble click), arrastrar, guardar y comprobar persistencia.

### 9) Seguridad y Permisos (futuro cercano)
- Respetar roles (admin/participante/observador) cuando estén activos.
- No exponer acciones no permitidas en UI.

### 10) Configuración del Entorno de Desarrollo
- **Ruta de Flutter**: `C:\Users\cclaraso\Downloads\flutter`
- Usar esta ruta para ejecutar comandos `flutter` cuando sea necesario.
- Añadir al PATH del sistema si es necesario para desarrollo futuro.

---

Mantenemos este documento corto y de alto impacto. Cualquier nueva norma estable se añade aquí.


