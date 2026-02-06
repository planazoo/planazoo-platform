# Evaluación documento a documento - docs/

> Revisión de cada .md: mantener, actualizar, eliminar, referencias.  
> **Fecha:** Febrero 2026

---

## Cómo leer esta evaluación

- **Mantener:** Documento útil y actual; no tocar salvo correcciones menores.
- **Actualizar:** Mantener pero hacer cambios (referencias, fechas, contenido desactualizado).
- **Eliminar:** Valor bajo o duplicado; considerar borrar o archivar.
- **Referencias:** Enlaces rotos o que apuntan a docs que no existen.

---

# 1. Raíz de docs/

## 1.1 `docs/README.md`
**Evaluación:** **Mantener.** Es el índice principal de la documentación.  
**Acción:** Ya está actualizado con Configuración ampliada, Admin, Design, Testing y DOCS_AUDIT. Opcional: actualizar "Última actualización" a Febrero 2026 si quieres.

---

# 2. configuracion/

## 2.1 `CONTEXT.md`
**Evaluación:** **Mantener.** Documento central de normas y colaboración.  
**Acción:** Ninguna crítica. Las rutas que usa (`docs/tareas/TASKS.md`, `docs/configuracion/...`) son correctas.

## 2.2 `INDICE_SISTEMA_PLANES.md`
**Evaluación:** **Actualizar.** Muy útil como mapa del sistema.  
**Acción:** Corregir referencias en la tabla "Guías de Referencia":  
- `./GUIA_SEGURIDAD.md` → `../guias/GUIA_SEGURIDAD.md`  
- `./GUIA_ASPECTOS_LEGALES.md` → `../guias/GUIA_ASPECTOS_LEGALES.md`  
(El archivo está en `configuracion/`, las guías en `guias/`.)

## 2.3 `TESTING_CHECKLIST.md`
**Evaluación:** **Mantener.** Checklist vivo, referenciado por CONTEXT y ONBOARDING.  
**Acción:** Ninguna. Actualizar cuando se cierren tareas (según sus propias instrucciones).

## 2.4 `DEPLOY_WEB_FIREBASE_HOSTING.md`
**Evaluación:** **Mantener.** Guía de despliegue web; fecha y URL actuales.  
**Acción:** Ninguna.

## 2.5 `FCM_FASE1_IMPLEMENTACION.md`
**Evaluación:** **Mantener.** Describe FCM implementado; estado y fecha correctos.  
**Acción:** Ninguna.

## 2.6 `ONBOARDING_IA.md`
**Evaluación:** **Mantener.** Esencial para que la IA se ponga al día.  
**Acción:** Opcional: actualizar "Última actualización" a Febrero 2026 si el estado del proyecto no ha cambiado mucho.

## 2.7 `USUARIOS_PRUEBA.md`
**Evaluación:** **Mantener.** Necesario para testing y T185 (seed).  
**Acción:** Ninguna.

## 2.8 `DEPLOY_INDICES_FIRESTORE.md`
**Evaluación:** **Mantener.** Guía operativa de despliegue de índices.  
**Acción:** Ninguna.

## 2.9 `DESPLEGAR_REGLAS_FIRESTORE.md`
**Evaluación:** **Mantener.** Corto y útil; menciona admins.  
**Acción:** Ninguna.

## 2.10 `FIRESTORE_COLLECTIONS_AUDIT.md`
**Evaluación:** **Mantener.** Auditoría de colecciones y reglas.  
**Acción:** Ninguna.

## 2.11 `FIRESTORE_INDEXES_AUDIT.md`
**Evaluación:** **Mantener.** Detalle de índices (T152).  
**Acción:** Revisar cuando se añadan/quiten índices en el proyecto.

## 2.12 `SERVICIO_EMAILS_INVITACIONES.md`
**Evaluación:** **Mantener.** Resumen del servicio; enlaza a EMAILS_CON_GMAIL_SMTP.  
**Acción:** El diagrama sigue diciendo "SendGrid API"; opcional: cambiar a "Gmail SMTP" para coherencia.

## 2.13 `EMAILS_CON_GMAIL_SMTP.md`
**Evaluación:** **Mantener.** Guía paso a paso Gmail SMTP.  
**Acción:** Ninguna.

## 2.14 `GUIA_PASO_A_PASO_GMAIL_EN.md`
**Evaluación:** **Mantener.** Versión en inglés de la guía Gmail; útil si hay equipo EN.  
**Acción:** Ninguna. Si solo trabajas en castellano, podrías considerar fusionar con la versión ES o dejar como referencia.

## 2.15 `NOMENCLATURA_UI.md`
**Evaluación:** **Mantener.** Centraliza nombres de páginas y convención _web/_mobile/_shared.  
**Acción:** Revisar si coincide con PLATFORM_STRATEGY y con los nombres reales en `lib/` (ej. no todo tiene sufijo _web/_mobile aún). Si hay solapamiento con GUIA_UI, mantener ambos: NOMENCLATURA para nombres, GUIA_UI para diseño.

## 2.16 `MIGRACION_MAC_PLAYBOOK.md`
**Evaluación:** **Mantener.** Playbook completo para migrar a Mac.  
**Acción:** Ninguna. Muy largo; está bien como referencia ejecutable.

## 2.17 `MIGRACION_MAC_INSTRUCCIONES_BASICAS.md`
**Evaluación:** **Mantener.** Versión resumida; enlazada desde el playbook.  
**Acción:** Ninguna.

## 2.18 `SETUP_IOS_SIMULATOR.md`
**Evaluación:** **Mantener.** Guía para probar en iOS Simulator.  
**Acción:** Ninguna.

## 2.19 `CONFIGURAR_GOOGLE_SIGNIN.md`
**Evaluación:** **Mantener.** Configuración Google Sign-In (T164).  
**Acción:** Ninguna.

## 2.20 `INSTALAR_JAVA.md`
**Evaluación:** **Mantener.** Necesario para Android/Windows; en Mac suele venir con Android Studio.  
**Acción:** El estado "Mac: ✅ Se configurará automáticamente" está bien; dejarlo como está.

## 2.21 `TESTING_FEEDBACK_TEMPLATE.md`
**Evaluación:** **Mantener.** Plantilla para feedback de pruebas.  
**Acción:** Ninguna.

## 2.22 `DOCS_AUDIT.md`
**Evaluación:** **Mantener.** Resultado de la auditoría de docs (referencias rotas, estructura).  
**Acción:** Actualizar cuando se corrijan más referencias o se creen carpetas (legal, roadmap, etc.).

## 2.23 `DOCS_EVALUACION_UNO_A_UNO.md` (este archivo)
**Evaluación:** **Mantener.** Sirve como decisión documento a documento.  
**Acción:** Ir actualizando según apliques cambios.

---

# 3. admin/

## 3.1 `ADMINS_WHITELIST.md`
**Evaluación:** **Mantener.** Lista blanca de admins (T188, T191).  
**Acción:** Cuando crees el usuario admin en Firebase, completar UserId en la tabla (T191).

---

# 4. arquitectura/

## 4.1 `ARCHITECTURE_DECISIONS.md`
**Evaluación:** **Mantener.** Decisiones arquitectónicas fundamentales.  
**Acción:** Ninguna. Las referencias a TASKS, COMPLETED_TASKS, CALENDAR_CAPABILITIES, FRANKENSTEIN son correctas.

## 4.2 `PLATFORM_STRATEGY.md`
**Evaluación:** **Mantener.** Estrategia multi-plataforma (web/móvil).  
**Acción:** Ninguna. Ya enlazado desde docs/README.

---

# 5. guias/

## 5.1 `GUIA_UI.md`
**Evaluación:** **Mantener.** Sistema de diseño (colores, tipografía, grid).  
**Acción:** CONTEXT y ESTILO_SOFISTICADO indican que la UI es oscura por defecto; GUIA_UI muestra colores claros (color0 blanco, etc.). Opcional: añadir una nota al inicio indicando que el tema por defecto es el Estilo Base (oscuro) y que GUIA_UI documenta también la paleta legacy/clara para referencia.

## 5.2 `GUIA_SEGURIDAD.md`
**Evaluación:** **Mantener.** Referencia de seguridad.  
**Acción:** Ninguna.

## 5.3 `GUIA_ASPECTOS_LEGALES.md`
**Evaluación:** **Mantener.** Referencia legal; apunta a docs/legal/ (aún no creados).  
**Acción:** Cuando existan, crear `docs/legal/` y los archivos (terms_of_service, privacy_policy, etc.). Mientras tanto, las "Ubicación: docs/legal/..." son correctas como planificación.

## 5.4 `GUIA_PATRON_COMUN_PERSONAL.md`
**Evaluación:** **Mantener.** Patrón común/personal para eventos y alojamientos.  
**Acción:** Ninguna.

## 5.5 `GESTION_TIMEZONES.md`
**Evaluación:** **Mantener.** Sistema de timezones (T40, etc.).  
**Acción:** Ninguna.

## 5.6 `PROMPT_BASE.md`
**Evaluación:** **Mantener.** Metodología para la IA.  
**Acción:** Ya corregido: `docs/CONTEXT.md` → `docs/configuracion/CONTEXT.md`.

---

# 6. flujos/

Todos los flujos (CRUD planes, eventos, alojamientos, estados, participantes, presupuesto/pagos, invitaciones/notificaciones, validación, configuración app, usuarios) están referenciados en README e INDICE_SISTEMA_PLANES.

## 6.1–6.10 `FLUJO_CRUD_PLANES.md`, `FLUJO_CRUD_EVENTOS.md`, `FLUJO_CRUD_ALOJAMIENTOS.md`, `FLUJO_ESTADOS_PLAN.md`, `FLUJO_GESTION_PARTICIPANTES.md`, `FLUJO_PRESUPUESTO_PAGOS.md`, `FLUJO_INVITACIONES_NOTIFICACIONES.md`, `FLUJO_VALIDACION.md`, `FLUJO_CRUD_USUARIOS.md`, `FLUJO_CONFIGURACION_APP.md`
**Evaluación:** **Mantener.** Son el mapa de procesos del sistema.  
**Acción:** Revisar cuando cambie el comportamiento de la app; actualizar fechas/versiones si toca. FLUJO_CRUD_USUARIOS menciona "Ver TASKS.md para lista de pruebas" (correcto).

---

# 7. especificaciones/

## 7.1 `CALENDAR_CAPABILITIES.md`
**Evaluación:** **Mantener.** Capacidades funcionales del calendario (sin código).  
**Acción:** Actualizar cuando cambien comportamientos o capacidades del calendario (CONTEXT lo indica).

## 7.2 `PLAN_FORM_FIELDS.md`
**Evaluación:** **Mantener.** Campos de formularios de planes.  
**Acción:** Ninguna.

## 7.3 `EVENT_FORM_FIELDS.md`
**Evaluación:** **Mantener.** Campos de eventos e implementación técnica.  
**Acción:** Ninguna.

## 7.4 `ACCOMMODATION_FORM_FIELDS.md`
**Evaluación:** **Mantener.** Campos de alojamientos.  
**Acción:** Ninguna.

## 7.5 `FRANKENSTEIN_PLAN_SPEC.md`
**Evaluación:** **Mantener.** Plan de pruebas y casos edge.  
**Acción:** Revisar con demo_data_generator cuando añadas funcionalidad (CONTEXT).

## 7.6 `PATROCINIOS_Y_MONETIZACION.md`
**Evaluación:** **Mantener.** Definición de monetización y patrocinios (T143, T132).  
**Acción:** Ninguna. Es documento de producto futuro.

---

# 8. ux/

## 8.1 `plan_image_management.md`
**Evaluación:** **Mantener.** Gestión de imágenes de planes (W5, W28, ImageService).  
**Acción:** Ninguna.

## 8.2 `estilos/ESTILO_SOFISTICADO.md`
**Evaluación:** **Mantener.** Estilo base (UI oscura). CONTEXT lo cita.  
**Acción:** Ninguna.

## 8.3 `layout/README.md`, `layout/LAYOUT_SPEC_SYSTEM.md`
**Evaluación:** **Mantener.** Especificaciones de layout y grid.  
**Acción:** Ninguna.

## 8.4 `mejoras/PLANDATASCREEN_ALINEACION.md`
**Evaluación:** **Mantener.** Mejora concreta de alineación.  
**Acción:** Ninguna.

## 8.5 `pages/index.md`
**Evaluación:** **Mantener.** Índice de documentación de páginas/widgets.  
**Acción:** Ninguna. Lista w1–w30, login, register, profile y pendientes.

## 8.6 `pages/*.md` (login_page, register_page, profile_page, w1_sidebar, w2_logo, …, w30_app_info_footer)
**Evaluación:** **Mantener.** Documentación por página/widget.  
**Acción:** Revisar cuando cambie una pantalla; actualizar "Próximas páginas a documentar" en index.md si se documentan más.

---

# 9. design/

## 9.1 `EVENT_COLOR_PALETTE.md`
**Evaluación:** **Mantener.** Paleta de colores de eventos (T91).  
**Acción:** Ninguna. Ya enlazado desde docs/README.

---

# 10. testing/

## 10.1 `TESTING_OFFLINE_FIRST.md`
**Evaluación:** **Mantener.** Guía de pruebas offline (móvil).  
**Acción:** Ninguna. Ya enlazado desde docs/README.

---

# 11. tareas/

## 11.1 `TASKS.md`
**Evaluación:** **Mantener.** Lista maestra de tareas.  
**Acción:** Ya corregido: `docs/CONTEXT.md` → `docs/configuracion/CONTEXT.md` y `docs/COMPLETED_TASKS.md` → `docs/tareas/COMPLETED_TASKS.md`. Contiene muchas referencias a documentos que aún no existen (legal, estrategia, riesgos, roadmap, algunos flujos); ver DOCS_AUDIT. Opción: en cada tarea con referencia a doc inexistente, poner "(pendiente: crear …)" o dejar como está hasta que se creen.

## 11.2 `COMPLETED_TASKS.md`
**Evaluación:** **Mantener.** Historial de tareas completadas.  
**Acción:** Ninguna.

## 11.3 `CURRENCY_SYSTEM_PROPOSAL.md`
**Evaluación:** **Mantener.** Propuesta multi-moneda (T153 ya implementado).  
**Acción:** Opcional: añadir una línea al inicio tipo "Estado: Implementado (T153). Este doc describe la propuesta original."

## 11.4 `T96_REFACTORING_PLAN.md`
**Evaluación:** **Mantener.** Plan de refactor de CalendarScreen.  
**Acción:** Actualizar estado de componentes (CalendarEvents, CalendarInteractions) cuando avance T96.

---

# 12. Resumen de acciones recomendadas

| Prioridad | Acción |
|-----------|--------|
| Alta | Corregir en `INDICE_SISTEMA_PLANES.md` las rutas a GUIA_SEGURIDAD y GUIA_ASPECTOS_LEGALES (../guias/...). |
| Media | Opcional: nota en GUIA_UI sobre Estilo Base (oscuro) vs paleta legacy. |
| Media | Opcional: en SERVICIO_EMAILS_INVITACIONES, cambiar "SendGrid API" en diagrama por "Gmail SMTP". |
| Baja | CURRENCY_SYSTEM_PROPOSAL: añadir "Estado: implementado (T153)". |
| Baja | Actualizar "Última actualización" en README y ONBOARDING_IA si lo deseas. |

**No eliminar** ningún documento de esta lista; todos tienen un rol claro (operativo, referencia o planificación futura).

---

*Evaluación documento a documento. Actualizar este archivo cuando cambie el criterio sobre algún doc.*
