# Registro de observaciones durante las pruebas

> Documento para ir anotando lo que vas viendo mientras pruebas. Los huecos/errores que den lugar a tareas se pueden llevar también a la sección 19 y 20 del [Plan E2E tres usuarios](./PLAN_PRUEBAS_E2E_TRES_USUARIOS.md).  
> **La sección "MIS NOTAS" debe quedar siempre al final.** Ahí vas **tus cosas** (opiniones, ideas, observaciones personales), no el resultado formal de las pruebas (✅/❌ por paso va en el Plan E2E, sección 19 y 20).

---

## Datos de sesión (UA, UB, UC y plan smoke)

- **Contraseña:** no guardar en este documento (quedaría en el repo). Usar gestor de contraseñas o anotar solo en local. Misma para los tres.
- **Usuario UA:** username `cricla` / email `unplanazoo+cricla@gmail.com` — idioma **español**, misma zona horaria que UB (**Madrid (GMT+1)**).
- **Usuario UB:** email `unplanazoo+marbat@gmail.com` — idioma **español**, **misma zona horaria que UA** (**Madrid (GMT+1)**). Crear desde la app (registro) o Init Firestore; tras login: Perfil → idioma Español, Perfil → Configurar zona horaria = UA.
- **Usuario UC:** email `unplanazoo+emmcla@gmail.com` — idioma **inglés**, **otra zona horaria que UA/UB** (**Londres (GMT+0)**). Crear desde la app (registro) o Init Firestore; tras login: Perfil → English, Perfil → Configurar zona horaria = la deseada (ej. America/New_York).
- **Plan smoke:** **Egipto Semana Santa 2026**, del 28/03/2026 al 04/04/2026.
- **Plan E2E (ciclo tres usuarios):** **Buenos Aires Marzo 2026** — del **23/03/2026** al **29/03/2026**, zona horaria Buenos Aires (GMT-3), moneda Euros.
- **Estado:** UA, UB y UC creados; plan E2E creado; listos para invitaciones y resto del ciclo.

**Usuario UD (para más adelante):** No registrado inicialmente. Alias `matcla` / email `unplanazoo+matcla@gmail.com` — idioma **español**, zona horaria **Nueva York (GMT-5)**. Crear cuando se quiera probar un cuarto invitado (p. ej. flujo “invitar a no registrado” adicional); tras registro: Perfil → Español, Configurar zona horaria = America/New_York.

---

## Cambios recientes (documentación y funcionalidad)

- **Invitaciones:** Invitar **desde la lista de usuarios** (además de por email): se crea invitación pendiente, el invitado recibe notificación y puede aceptar/rechazar. **El organizador recibe notificación** cuando el invitado acepta o rechaza. En la página de Participantes, el organizador ve la sección **"Invitaciones"** con el estado de cada una (Pendiente, Aceptada, Rechazada, Cancelada, Expirada). Flujos: `FLUJO_INVITACIONES_NOTIFICACIONES.md` § 1.2, `FLUJO_GESTION_PARTICIPANTES.md` § 1.2.
- **Salir del plan:** Un participante (no organizador) puede **salir del plan** desde Info del plan o desde la pestaña Participantes; confirmación y eliminación de su participación. `FLUJO_GESTION_PARTICIPANTES.md` § 2.5. Casos de prueba: `TESTING_CHECKLIST.md` § 6.4 (PART-D-002, PART-LEAVE-001) y § 7.1.6 (INV-024, INV-024b, INV-024c).

---

## Acciones pendientes (revisar luego)

- [ ] **Borrado total de cuenta:** Al eliminar cuenta, falla con `permission-denied` (tras "Deleted 0 events"). Revisar: reglas Firestore para todas las estructuras que toca `UserService.deleteAllUserData` (p. ej. `plans/{planId}/userPreferences/{userId}` ya tenía regla añadida; confirmar despliegue de reglas y volver a probar USER-D-007). Ver `TESTING_CHECKLIST.md` § 3.5.1.
- [ ] **Espacio admin para gestionar toda la BD (RUD + huérfanos):** Panel admin para leer/actualizar/eliminar documentos (Firestore + Auth), eliminar usuario completo con relacionados, y **detectar documentos huérfanos** (referencias a usuarios/planes/eventos ya eliminados: p. ej. participations, events, event_participants, invitations con IDs inexistentes). Ver **T223** en `docs/tareas/TASKS.md` § Administración.

---

## MIS NOTAS
INSTRUCCIONES PARA EL PROMPT
Esta sección no es una tarea, es para dar contexto a la IA. Nno codigiques. dentro del documento @docs/testing/REGISTRO_OBSERVACIONES_PRUEBAS.md  hay una seccion con mis notas. De es lista crea las tareas necesarias. Hazme todas las preguntas que necesites en cada tarea para dejarla bien documentada. una vez creada la tarea, marca el texto dentro de MIS NOTAS añadiendo un "*" al principio de la frase y cambiandola de color. Así sabremos lo que has pasado a Tareas. 

*(Tus notas, opiniones e ideas — no el resultado formal de las pruebas.)*