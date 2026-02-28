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

<span style="color:#888">* UI Standard — Definir la UI para los modales. Quiero que tengan una  barra superior en color verde con el titulo del modal y, si lo necesitan, botones o textos. → **T226**</span>

<span style="color:#888">* PAGINA DE REGISTRO — el campo nombre, debería ser nombre y apellidos. Decidir si es necesario añadir un control de campos rellenados. El recuadro que muestra si la contraseña cumple con los requisitos no me gusta. Ocupa toda la pantalla. Hay que mejorarla. → **T227**</span>

<span style="color:#888">* MAIL VERIFICACION NUEVO REGISTRO DE USUARIO — Está en inglés, debería estar en el idioma del usuario (dos versiones como mínimo). Subject "Verify your email for project-..." más adecuado. El mail ha de ir firmado como "Equipo planazoo". → **T228**</span>

<span style="color:#888">* MODAL CREAR PLAN — El estilo ha de seguir el de la app. No hace falta que aparezca el ID del plan. Justo al crear el plan, abrir Info del plan con la pestaña de inicio (no calendario). → **T229**</span>

<span style="color:#888">* PAGINA INFORMACION DEL PLAN — Revisar si el apartado "avisos" tiene sentido mantenerlo. → **T231**</span>

<span style="color:#888">* PERFIL USUARIO — Zonas horarias: añadir todas las del mundo con capitales. Visualizar la selección en el menú "Zona horaria". La zona horaria en la info del usuario en W6. El idioma seleccionado en el menú de idioma. → **T232**</span>

<span style="color:#888">* PAGINA PARTICIPANTES — Lista de participantes lo primero, más pequeña. Invitar a continuación. Revisar aceptar invitaciones. Eliminar botón "Aceptar/Rechazar por token" y código/doc. Eliminar icono X. Barra superior solo nombre de la página sin nombre del plan. → **T233**</span>

<span style="color:#888">* INVITACIONES — UB en lista con "pendiente de aceptar invitación". UA recibe notificación cuando UB acepta/rechaza. Icono "?" en enviar por mail para explicar tipos de usuario. → **T234**</span>

<span style="color:#888">* CARD DEL PLAN — Cuando está seleccionado el estado no se lee bien. Los colores no son los correctos. → **T235**</span>

<span style="color:#888">* NOTIFICACIONES — Círculo con número en W1 no debe tapar el icono. Estética botones aceptar/rechazar según estilo de la app. → **T236**</span>

<span style="color:#888">* PAGINA INFO DEL PLAN — Optimizar para ver más datos, estructura para móvil. Evaluar si Avisos es necesaria. Estado del plan en la barra superior verde. → **T237**</span>

<span style="color:#888">* MODAL CREAR EVENTO — Barra verde superior con título. ✅ (1) hecha. Mejorar visualización "General" y "Mi información". Evaluar texto "Puedes editar esta información". Muy rápido y fácil definir evento. Menú duración: opción hora concreta (T208). Orden de campos. → **T238**</span>

<span style="color:#888">* ALOJAMIENTO — Revisar el modal alojamiento para que cumpla con la UI Standard. → **T240**</span>

<span style="color:#888">* RESUMEN DEL PLAN — Añadir hora de inicio, duración, hora de final de los eventos. → **T241**</span>

<span style="color:#888">* PAGINA CALENDARIO — Quitar "perspectiva de usuario". ✅ Hecho. Agrupar opciones de la barra en menú categorizado. Menú filtros eventos: todos, borrador. → **T242**</span>

<span style="color:#888">* COPIAR EVENTOS Y PLANES — Revisar si ya existe tarea. Crear opción de copiar planes, eventos y alojamientos (eventos/alojamientos mismo plan). → **T243**</span>