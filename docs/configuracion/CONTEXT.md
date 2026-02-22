## 📘 Documento de Contexto y Normas de Colaboración

Este documento fija criterios estables para trabajar juntos sin olvidar pasos clave, manteniendo consistencia entre código, documentación y comunicación.

### 🧭 Fundamentos del proyecto

Las decisiones del proyecto (diseño, implementación, testing, documentación, flujos) han de seguir, **entre otros criterios**, estos principios:

- **Máxima participación de IA y herramientas:** Buscar la altísima participación de la IA y de herramientas de software y la menor participación humana posible en todo lo automatizable; priorizar opciones que maximicen uso de IA/herramientas y minimicen la intervención manual.
- **Valor incremental antes que big-bang:** Priorizar entregar valor verificable en cada paso antes que invertir todo en la parte más compleja; preferir opciones que den feedback pronto frente a soluciones “todo o nada”.
- **Reutilizar y comprobar antes de crear:** Comprobar si ya existe algo equivalente (código, tareas, modelos, documentación) antes de añadir funcionalidad o artefactos nuevos; priorizar reutilizar, adaptar o extender sobre duplicar o crear de cero.
- **Documentación viva:** La documentación es parte del producto y evoluciona con él; cualquier cambio relevante debe reflejarse en los documentos correspondientes; la documentación obsoleta es deuda.

**📋 DOCUMENTOS COMPLEMENTARIOS:**
- `docs/guias/PROMPT_BASE.md` - Metodología de trabajo general y patrones de comunicación
- `docs/guias/GESTION_TIMEZONES.md` - Sistema de gestión de timezones (T40)
- `docs/configuracion/INDICE_SISTEMA_PLANES.md` - Índice y visión general del sistema de planes
- `docs/configuracion/TESTING_CHECKLIST.md` - Checklist exhaustivo de pruebas (actualizar tras cada tarea)
- `docs/flujos/` - Flujos específicos de procesos (estados, participantes, eventos, etc.)

---

### 1) Idioma y Estilo de Comunicación
- Toda la comunicación es en castellano.
- Respuestas concisas y accionables; detalles técnicos cuando aporten valor.
- Evitar bloquear por confirmaciones innecesarias; preguntar solo si hay ambigüedad real.
- No mostrar código en propuestas: aplicar directamente y describir el cambio a alto nivel.
- **⚠️ REVISAR ANTES DE PROPUESTA/IMPLEMENTACIÓN**: Siempre buscar si ya existe funcionalidad similar antes de proponer o implementar (código, TASKS.md, Firestore, documentación).

### 2) Flujo de Trabajo de Tareas
- Las tareas activas se gestionan en `docs/tareas/TASKS.md`.
- **Confirmación del usuario antes de marcar tareas como completadas.**
- Al completar una tarea:
  - Actualizar estado en `docs/tareas/TASKS.md`.
  - Mover la tarea a `docs/tareas/COMPLETED_TASKS.md` con fecha, criterios y archivos modificados.
  - Ajustar contadores/resúmenes si aplica.

### 3) Control de Código y Commits
- No realizar `git push` sin confirmación explícita del usuario.
- Commits deben ser atómicos y descriptivos (prefijo con código de tarea si aplica, p. ej. `T73:`).
- Evitar dejar `print()` o logs ruidosos en producción; usar logger si se necesita.

### 4) Persistencia y Decisiones de Datos
- Persistencia local solo para prototipos rápidos; versión final debe ser global (Firestore) salvo indicación contraria.
- Identificadores estables (p. ej., `participantId`) para persistir orden/configuración; evitar IDs efímeros.

### 5) UI/UX y Calidad
- **⚠️ Estilo Base:** La aplicación Planazoo utiliza una UI oscura por defecto. No es un "modo oscuro" opcional, sino el diseño estándar de la app. Consultar `docs/ux/estilos/ESTILO_SOFISTICADO.md` (renombrado a "Estilo Base") para detalles.
- Mantener UI consistente: tamaños, tipografías, colores según `AppColorScheme` y el Estilo Base.
- Evitar regresiones de interacción (tap, drag&drop, dobles clics).
- Revisar lints tras cada cambio en archivos modificados.
- Al cerrar una tarea: eliminar `print()`, debugs y código temporal que ya no sea necesario.
- **⚠️ Verificar multi-idioma:** Antes de cerrar una tarea, verificar que todos los textos nuevos usan `AppLocalizations.of(context)!.key` y no están hardcodeados.

### 6) Documentación
- Actualizar `docs/especificaciones/CALENDAR_CAPABILITIES.md` cuando cambie el comportamiento del calendario.
- Añadir notas breves en `docs/arquitectura/ARCHITECTURE_DECISIONS.md` para decisiones relevantes (p. ej., persistencia).
- Mantener `CONTEXT.md` como referencia viva de normas.
- **⚠️ Multi-idioma (OBLIGATORIO):** 
  - **NUNCA hardcodear textos en español** directamente en el código (Text('Hola'), SnackBar(content: Text('Error')), etc.)
  - **SIEMPRE usar AppLocalizations:** Todos los textos visibles al usuario deben usar `AppLocalizations.of(context)!.key`
  - **Archivos de traducción:** Añadir nuevas claves en `lib/l10n/app_es.arb` y `lib/l10n/app_en.arb`
  - **Al crear nueva funcionalidad:** Añadir las traducciones necesarias ANTES de implementar la UI
  - **Excepciones:** Solo se permite hardcodear textos técnicos/debug que nunca se muestran al usuario
  - **Ver T158:** Sistema multi-idioma en progreso (~65% completado). Consultar `docs/tareas/TASKS.md` para estado actual
- **Multi-plataforma:** App soporta Web + iOS + Android. Verificar compatibilidad de plugins/APIs en las 3 plataformas antes de usar. Priorizar soluciones cross-platform. Consultar `docs/arquitectura/PLATFORM_STRATEGY.md` para estrategia de desarrollo multi-plataforma.
- **Offline-First:** Se implementará cuando empecemos con versiones iOS y Android. Por ahora en web no es prioridad.
- **UI/UX:** Consultar `docs/guias/GUIA_UI.md` antes de crear componentes visuales. Usar siempre `AppColors`, `AppTypography`, `AppSpacing`, `AppIcons` para mantener consistencia. Documentar componentes nuevos en la guía.
- **Seguridad:** Consultar `docs/guias/GUIA_SEGURIDAD.md` antes de implementar funcionalidades y verificar: validación de inputs, permisos, Firestore Rules, logging sin datos sensibles. Nunca hardcodear secrets, API keys o passwords en código.
- **Patrón Común/Personal:** Consultar `docs/guias/GUIA_PATRON_COMUN_PERSONAL.md` para implementar eventos y alojamientos con información compartida e individual por participante. Usar EventCommonPart/EventPersonalPart y AccommodationCommonPart/AccommodationPersonalPart.
- **Flujos de Proceso:** Consular flujos en `docs/flujos/` antes de tomar decisiones o implementar funcionalidades:
  - `FLUJO_CRUD_PLANES.md` - 🆕 Ciclo de vida completo CRUD de planes
  - `FLUJO_ESTADOS_PLAN.md` - Estados y transiciones
  - `FLUJO_GESTION_PARTICIPANTES.md` - Invitaciones y gestión de participantes
  - `FLUJO_CRUD_EVENTOS.md` - Ciclo de vida completo de eventos
  - `FLUJO_CRUD_ALOJAMIENTOS.md` - 🆕 Ciclo de vida completo de alojamientos
  - `FLUJO_PRESUPUESTO_PAGOS.md` - Sistema financiero
  - `FLUJO_INVITACIONES_NOTIFICACIONES.md` - Comunicación
  - `FLUJO_VALIDACION.md` - Validación y verificación
  - `FLUJO_CRUD_USUARIOS.md` - Registro, login y gestión de usuarios
  - `FLUJO_CONFIGURACION_APP.md` - Configuración de usuario, app y planes
- **Guías de Referencia:**
  - `GUIA_SEGURIDAD.md` - Seguridad, autenticación y protección de datos
  - `GUIA_ASPECTOS_LEGALES.md` - Términos, privacidad, cookies y cumplimiento legal
- Al implementar una funcionalidad completa: revisar si debe actualizarse el flujo correspondiente en `docs/flujos/`.
- **Testing Checklist:** Actualizar `docs/configuracion/TESTING_CHECKLIST.md` después de completar cada tarea:
  - Marcar como probadas las funcionalidades nuevas
  - Añadir nuevos casos de prueba si aplica
  - Actualizar casos relacionados que puedan afectarse
- **Pruebas lógicas (JSON):** Al implementar o cambiar lógica probable por datos (validaciones, auth, reglas de eventos, etc.), actualizar el sistema de pruebas lógicas: ver `docs/testing/SISTEMA_PRUEBAS_LOGICAS.md` (casos en `tests/*_cases.json`, evaluadores en `lib/testing/*_logic.dart`, tests en `test/features/...`).
  - Ver sección "INSTRUCCIONES DE MANTENIMIENTO" del checklist para detalles

### 7) Plan Frankenstein (revisión tras cambios)
- Tras aprobar cambios funcionales, evaluar si deben incorporarse al Plan Frankenstein.
- Si aplica, actualizar:
  - `docs/especificaciones/FRANKENSTEIN_PLAN_SPEC.md` (escenarios y checklist)
  - `lib/features/testing/demo_data_generator.dart` (datos de demo/casos)
  - Notas breves en `docs/especificaciones/CALENDAR_CAPABILITIES.md` si afecta a capacidades visibles

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
- **Ruta de Flutter (Windows)**: `C:\Users\cclaraso\Downloads\flutter`
- **Ruta de Flutter (macOS)**: `/Users/emmclaraso/development/flutter`
- Usar la ruta correspondiente a tu sistema; actualizar si tu instalación está en otra ubicación.
- Añadir al PATH del sistema si es necesario para ejecutar comandos `flutter`.

---

### Pendiente de aprobación del usuario
- **Ninguno** (revisión doc/código y sincronización resumen T193 completada). Cuando haya ítems que requieran decisión explícita, se listarán aquí.

**Opcional (sin urgencia):** Si no se va a usar en el futuro el callback "abrir resumen en panel" desde la card, se pueden eliminar los parámetros `onSummaryInPanel` de `PlanListWidget` y `PlanCardWidget` y `onShowInPanel` de `PlanSummaryButton` para simplificar. Hoy la card solo abre el diálogo y el resumen en W31 solo se accede desde la pestaña Calendario.

---

Mantenemos este documento corto y de alto impacto. Cualquier nueva norma estable se añade aquí.

*Última actualización: Febrero 2026*

