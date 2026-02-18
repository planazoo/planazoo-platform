# Plan de pruebas E2E exhaustivo – Tres usuarios (UA, UB, UC)

> Prueba sistemática del flujo completo de la app: creación del plan, durante el plan y finalización.  
> **Objetivo:** validar el flujo real con mínimo 3 usuarios que interactúan en todo el ciclo.  
> **Enfoque:** flujo completo > control de errores. Incluir anotación de situaciones no contempladas como tareas.  
> **Ámbito:** solo **web** (por ahora no incluye app móvil). **Local = 1 ordenador** (tres sesiones en el mismo equipo). **Idiomas:** las pruebas deben incluir **al menos dos idiomas** (p. ej. español e inglés).

**Versión:** 1.3  
**Última actualización:** Febrero 2026

---

## Índice

1. [Resumen y enfoque](#1-resumen-y-enfoque)
2. [Usuarios de prueba](#2-usuarios-de-prueba)
3. [Estados del plan (referencia técnica)](#3-estados-del-plan-referencia-técnica)
4. [Permisos por estado (referencia)](#4-permisos-por-estado-referencia)
5. [Pre-requisitos y preparación](#5-pre-requisitos-y-preparación) (incl. [5.5 Idiomas](#55-idiomas-incluir-otro-idioma-es--en))
6. [Fase 0 – Registro y contexto inicial](#6-fase-0--registro-y-contexto-inicial)
7. [Fase 1 – Creación del plan e invitaciones](#7-fase-1--creación-del-plan-e-invitaciones-solo-ua)
8. [Fase 2 – Aceptar / rechazar invitaciones](#8-fase-2--aceptar--rechazar-invitaciones)
9. [Fase 3 – Eventos en borrador, timezones y participación](#9-fase-3--eventos-en-borrador-timezones-y-participación)
10. [Fase 4 – Notificaciones y apuntarse a eventos (UB)](#10-fase-4--notificaciones-y-apuntarse-a-eventos-ub)
11. [Fase 5 – Re-invitar a UC y asignar a eventos](#11-fase-5--re-invitar-a-uc-y-asignar-a-eventos)
11.5. [Fase: Pagos (registro y balances)](#115-fase-pagos-registro-y-balances)
12. [Fase 6 – Chat durante la creación del plan](#12-fase-6--chat-durante-la-creación-del-plan)
13. [Fase 7 – Aprobar / confirmar el plan](#13-fase-7--aprobar--confirmar-el-plan-ua)
14. [Fase 8 – Durante el plan: chat y propuestas](#14-fase-8--durante-el-plan-chat-y-propuestas)
15. [Fase 9 – UC deja el plan](#15-fase-9--uc-deja-el-plan)
16. [Fase 10 – UC vuelve al plan](#16-fase-10--uc-vuelve-al-plan)
17. [Fase 11 – Cerrar el plan](#17-fase-11--cerrar-el-plan)
18. [Casos adicionales exhaustivos](#18-casos-adicionales-exhaustivos)
19. [Huecos / Situaciones no contempladas](#19-huecos--situaciones-no-contempladas) · [19.1 Estrategia: documentar vs arreglar](#191-estrategia-documentar-errores-vs-arreglar-al-vuelo)
20. [Registro de ejecución](#20-registro-de-ejecución)
21. [Reset y re-ejecución](#21-reset-y-re-ejecución)

---

## 1. Resumen y enfoque

- **Usuarios:** UA (organizador), UB, UC (participantes). Emails en sección 2.
- **Ciclo:** Registro → Crear plan (sin eventos) → Invitar → Aceptar/Rechazar → Eventos (borrador, timezones, apuntarse) → Notificaciones → Re-invitar → Asignar a eventos → Chat → Aprobar plan → Durante el plan (chat, proponer/modificar) → UC deja → UC vuelve → Cerrar plan.
- **Criterios:** Cada paso con resultado esperado; **Resultado** = ✅ / ❌ / ⚠️ Bloqueado / 🔶 No implementado; anotar huecos en sección 19.
- **Idiomas:** Ejecutar el flujo (o partes clave) en **español** y en **inglés**; comprobar que la UI, mensajes y estados se ven correctamente en ambos (ver sección 5.5).

**Referencias:**  
- `docs/configuracion/USUARIOS_PRUEBA.md`  
- `docs/configuracion/TESTING_CHECKLIST.md`  
- `docs/testing/SISTEMA_PRUEBAS_LOGICAS.md`

---

## 2. Usuarios de prueba

| Id  | Email                      | Rol inicial | Contraseña (ejemplo) | Timezone (ejemplo) |
|-----|----------------------------|-------------|----------------------|--------------------|
| **UA** | Unplanazoo+cricla@gmail.com  | Organizador | (tu contraseña)      | Europe/Madrid      |
| **UB** | Unplanazoo+marbat@gmail.com  | Participante| (tu contraseña)      | Europe/Madrid      |
| **UC** | Unplanazoo+emmcla@gmail.com  | Participante| (tu contraseña)      | America/New_York   |

- **Precondición:** Solo UA registrado al inicio.
- **Timezone:** UA y UB mismo huso; UC distinto (comprobar conversión en eventos y calendario).

---

## 3. Estados del plan (referencia técnica)

Transiciones válidas (`PlanStateService`):

| Estado actual | Puede pasar a |
|---------------|----------------|
| borrador | planificando, cancelado |
| planificando | confirmado, cancelado |
| confirmado | en_curso, cancelado, planificando |
| en_curso | finalizado |
| finalizado | — (terminal) |
| cancelado | — (terminal) |

**Nombres en UI (pueden variar):** Borrador, Planificando, Confirmado / Aprobado, En curso, Finalizado / Cerrado, Cancelado.

---

## 4. Permisos por estado (referencia)

Resumen según `PlanStatePermissions` (solo lectura en finalizado/cancelado):

| Acción | borrador | planificando | confirmado | en_curso | finalizado / cancelado |
|--------|----------|--------------|------------|----------|------------------------|
| Modificar fechas plan | ✅ | ✅ | ❌ | ❌ | ❌ |
| Añadir eventos | ✅ | ✅ | ✅ | ✅* | ❌ |
| Eliminar eventos | ✅ | ✅ | ✅ | ✅* | ❌ |
| Modificar eventos | ✅ | ✅ | ✅ | ✅* | ❌ |
| Añadir participantes | ✅ | ✅ | ✅ | ❌ | ❌ |
| Eliminar participantes | ✅ | ✅ | ✅ | ❌ | ❌ |
| Modificar presupuesto | ✅ | ✅ | ✅ | ❌ | ❌ |
| Editar info básica | ✅ | ✅ | ✅ | ✅ | ❌ |

\* En `en_curso` hay restricciones (eventos futuros, cambios urgentes). Probar y anotar si el mensaje de bloqueo es claro.

---

## 5. Pre-requisitos y preparación

### 5.0 Setup: 3 navegadores en 1 ordenador (solo web, local)

Estas pruebas son **solo para web**. Si ejecutas la app en **local** (localhost), solo puedes usar **1 ordenador**: las tres sesiones (UA, UB, UC) van en ese mismo equipo, en **3 ventanas o 3 navegadores distintos**.

**Configuración recomendada (1 ordenador):**

| Ventana / Navegador | Usuario | Cómo tener sesión separada |
|--------------------|--------|----------------------------|
| 1 | **UA** (Unplanazoo+cricla) | P. ej. Chrome ventana normal |
| 2 | **UB** (Unplanazoo+marbat) | Chrome ventana incógnito, o Firefox, o otro perfil Chrome |
| 3 | **UC** (Unplanazoo+emmcla) | Otra ventana incógnito, o Edge, o tercer perfil |

- **Misma URL en los tres:** `http://localhost:XXXX` (o la URL que uses para la web en local).
- **No compartir sesión:** cada ventana/navegador = una sola cuenta; las ventanas incógnito no comparten cookies con la ventana normal ni entre sí (si abres dos incógnito en Chrome, cada una es una sesión distinta).
- **Identificar ventanas:** poner nombre a la pestaña si el navegador lo permite (ej. "Planazoo – UA") o colocar las 3 ventanas en paralelo para no confundirte.

**Si más adelante pruebas en un entorno desplegado** (staging/producción con URL accesible desde varios dispositivos), entonces sí podrías usar 2 ordenadores (p. ej. UA+UB en uno, UC en otro); el documento sigue siendo válido, solo cambia el reparto de ventanas.

### 5.1 Entorno

- [ ] App **web** en ejecución en local (p. ej. `flutter run -d chrome` o servidor web en `http://localhost:XXXX`).
- [ ] Firebase (Auth, Firestore, Functions si aplica) accesible desde tu equipo (local usa los mismos proyectos que configures).
- [ ] Tres ventanas o tres navegadores en **el mismo ordenador**, cada una con una sesión distinta: UA, UB, UC (sin compartir cookies entre ellas).

### 5.2 Cuentas

- [ ] UA ya registrado y email verificado (revisar spam si no llega verificación).
- [ ] UB y UC: cuentas inexistentes o limpias para esta prueba (si existen, anotar y decidir si borrar datos de prueba o usar planes de prueba aislados).

### 5.3 Documentación durante la prueba

- [ ] Este documento abierto; sección **19. Huecos** lista para rellenar.
- [ ] Opcional: hoja de cálculo o tabla aparte para pegar resultados por paso (copiar filas de las tablas).

### 5.4 Checklist rápido pre-ejecución

- [ ] **Setup:** 3 ventanas o 3 navegadores en **1 ordenador** (solo web), uno por usuario (UA, UB, UC); ventanas identificadas (ej. "UA", "UB", "UC").
- [ ] Emails UA, UB, UC y contraseña definidos.
- [ ] Timezones: UA/UB Europe/Madrid, UC America/New_York (o las que uses) configuradas en perfil o plan.
- [ ] **Idiomas:** Decidido cómo probar el segundo idioma (ver 5.5): misma sesión cambiando idioma, o una ejecución completa por idioma, o un usuario en ES y otro en EN.
- [ ] Referencia a `TESTING_CHECKLIST.md` y `USUARIOS_PRUEBA.md` a mano.

### 5.5 Idiomas: incluir otro idioma (ES + EN)

Las pruebas deben cubrir **al menos dos idiomas**. La app usa `AppLocalizations` con soporte para **español (es)** e **inglés (en)**.

**Cómo cambiar el idioma en la app:**  
Buscar en la UI el selector de idioma (p. ej. en menú de perfil, ajustes o cabecera): "Seleccionar idioma" / "Select language", y elegir Español o English. El cambio suele aplicarse de inmediato en toda la pantalla.

**Opciones para incluir el segundo idioma en las E2E:**

| Opción | Descripción | Cuándo usarla |
|--------|-------------|----------------|
| **A. Una ejecución por idioma** | Hacer el flujo completo primero en español (todas las ventanas en ES) y luego repetir en inglés (todas en EN). | Máxima cobertura de traducciones; más tiempo. |
| **B. Usuarios en idiomas distintos** | UA en español, UB en inglés, UC en inglés (o UA en EN y UB/UC en ES). Cada ventana con su idioma desde el inicio. | Comprueba que varios usuarios pueden usar idiomas distintos en el mismo plan; una sola pasada. |
| **C. Cambiar idioma a mitad del flujo** | En una o dos ventanas (p. ej. UA), cambiar de ES a EN en una fase concreta (p. ej. tras Fase 5) y seguir el resto en EN. | Comprueba persistencia del idioma y que no se rompe el flujo al cambiar. |

**Textos clave a comprobar en ambos idiomas (anotar ✅/❌ en cada uno):**

| Área | ES | EN | Resultado ES | Resultado EN |
|------|----|----|--------------|--------------|
| Filtros dashboard (Todos, Estoy in, Pendientes, Cerrados) | | | | |
| Vista Lista / Calendario | | | | |
| Botón/acción "Invitar" o "Añadir por email" | | | | |
| Estados del plan (Borrador, Confirmado, Finalizado) | | | | |
| Mensajes de éxito/error (invitación enviada, plan creado) | | | | |
| Chat (placeholder, enviar) | | | | |
| Notificaciones (W29, textos de invitación) | | | | |
| Selector de idioma ("Seleccionar idioma" / "Select language") | | | | |

Si algún texto aparece en el idioma equivocado o sin traducir, anotarlo en la sección **19. Huecos**.

---

## 6. Fase 0 – Registro y contexto inicial

**Objetivo:** Verificar que solo UA puede acceder y que el dashboard responde bien.

**Precondición:** Ninguna (primera ejecución).

| # | Actor | Acción detallada | Resultado esperado | Verificación concreta | Resultado | Notas |
|---|--------|-------------------|--------------------|------------------------|-----------|--------|
| 0.1 | UA | Abrir app → Iniciar sesión con Unplanazoo+cricla@gmail.com y contraseña | Login correcto | Redirección a dashboard; sin mensaje de error | | |
| 0.2 | UA | Tras login, observar dashboard (header W4, búsqueda W13, filtros W26/W27, área W28) | Todos los widgets visibles | W4 con icono; W13 con campo búsqueda; W26 con botones Todos/Estoy in/Pendientes/Cerrados; W27 Lista/Calendario; W28 con lista o calendario de planes | | |
| 0.3 | UA | Activar filtro "Todos" (si no está por defecto) | Lista de planes (vacía o con datos) | No error; lista vacía o con cards de planes | | |
| 0.4 | UA | Cambiar a vista "Calendario" (W27) | Vista calendario de planes | Grid o lista mensual visible sin crash | | |
| 0.5 | UA | Volver a "Lista" | Vista lista de planes | Misma lista que en 0.3 | | |
| 0.6 | — | En otra ventana del mismo ordenador (segunda sesión): intentar login con UB (Unplanazoo+marbat@gmail.com) | No debe haber sesión activa de UA | Si la cuenta no existe: registro o error "usuario no encontrado"; si existe: login correcto (anotar) | | |
| 0.7 | — | En la tercera ventana: intentar login con UC (Unplanazoo+emmcla@gmail.com) | Igual que 0.6 | Anotar si UC existe o no al inicio | | |
| 0.8 | UA | Cerrar sesión (si hay opción en menú/perfil) y volver a iniciar sesión con UA | Login de nuevo correcto | Dashboard visible de nuevo | | |
| 0.9 | UA | Localizar el selector de idioma (perfil, ajustes o cabecera) y comprobar que hay al menos Español e Inglés | Selector visible con ES y EN | Opción "Seleccionar idioma" o similar; al elegir EN, la UI cambia a inglés | | |
| 0.10 | UA | *(Si usas opción B o C de 5.5)* En la ventana de UA, cambiar idioma a English (o dejar en ES y usar UB/UC en EN) | Idioma aplicado | Textos de dashboard (filtros, títulos) en el idioma elegido; anotar si algo sigue en otro idioma | | |

**Postcondición:** UA logueado; estado de UB/UC anotado; idioma de cada ventana decidido (todas ES, todas EN, o reparto según 5.5).

---

## 7. Fase 1 – Creación del plan e invitaciones (solo UA)

**Objetivo:** Plan en borrador sin eventos; dos invitaciones enviadas (UB, UC).

**Precondición:** UA logueado (Fase 0).

| # | Actor | Acción detallada | Resultado esperado | Verificación concreta | Resultado | Notas |
|---|--------|-------------------|--------------------|------------------------|-----------|--------|
| 1.1 | UA | En dashboard, pulsar botón/acción "Nuevo plan" (o equivalente) | Se abre modal o pantalla de creación de plan | Modal/pantalla con campos (nombre, fechas opcionales, etc.) | | |
| 1.2 | UA | Rellenar nombre del plan (ej. "Viaje E2E 2026") | Nombre aceptado | Campo nombre rellenado sin error de validación | | |
| 1.3 | UA | Dejar fechas vacías o rellenar inicio/fin (según diseño "se puede rellenar más adelante") | Guardado o aviso claro | No bloqueo; mensaje opcional de fechas posteriores | | |
| 1.4 | UA | Guardar/crear plan | Plan creado | Mensaje de éxito; vuelta al dashboard o al detalle del plan | | |
| 1.5 | UA | Comprobar que el plan aparece en la lista (W28) | Plan visible en lista | Card del plan con nombre correcto; filtro "Todos" o "Estoy in" lo muestra | | |
| 1.6 | UA | Abrir el plan (clic en card o doble clic) | Entra al detalle del plan | Pantalla con pestañas o secciones (Info plan, Calendario, Participantes, Chat, etc.) | | |
| 1.7 | UA | Ir a "Info plan" (o equivalente) y comprobar estado | Estado "Borrador" o "Es borrador" | Badge o texto que indique borrador | | |
| 1.8 | UA | No crear eventos aún; ir a pestaña/sección "Participantes" | Lista de participantes visible | Solo UA como organizador (o lista vacía según implementación); opción "Invitar" visible | | |
| 1.9 | UA | Pulsar "Invitar" o "Añadir por email" | Se abre diálogo o campo para introducir email | Campo email y botón Enviar/Invitar | | |
| 1.10 | UA | Introducir Unplanazoo+marbat@gmail.com (UB) y enviar invitación | Invitación enviada | Mensaje de éxito (SnackBar o similar); sin error de red/Firestore | | |
| 1.11 | UA | Repetir con Unplanazoo+emmcla@gmail.com (UC) | Segunda invitación enviada | Mensaje de éxito | | |
| 1.12 | UA | Comprobar lista de invitaciones pendientes (si existe en UI) | UB y UC aparecen como pendientes | Tabla o lista con 2 invitaciones en estado "pendiente" o "enviada" | | |
| 1.13 | UA | Comprobar que no hay eventos en el plan (pestaña Calendario) | Calendario sin eventos o vacío | Vista calendario sin bloques de evento; o mensaje "Sin eventos" | | |

**Postcondición:** 1 plan en borrador; 2 invitaciones pendientes (UB, UC). Anotar ID o nombre exacto del plan para siguientes fases.

---

## 8. Fase 2 – Aceptar / rechazar invitaciones

**Objetivo:** UB acepta y pasa a ser participante; UC no acepta (ignora o rechaza).

**Precondición:** Fase 1 completada; invitaciones enviadas a UB y UC.

| # | Actor | Acción detallada | Resultado esperado | Verificación concreta | Resultado | Notas |
|---|--------|-------------------|--------------------|------------------------|-----------|--------|
| 2.1 | UB | Si no tiene cuenta: Registrarse con Unplanazoo+marbat@gmail.com y contraseña | Cuenta creada | Pantalla de registro; verificación por email si aplica (revisar spam) | | |
| 2.2 | UB | Completar verificación de email si es necesaria | Cuenta verificada | Puede iniciar sesión sin límite "verifica tu email" | | |
| 2.3 | UB | Iniciar sesión con UB | Login correcto | Dashboard visible | | |
| 2.4 | UB | Buscar invitación: centro de notificaciones (W29) o email recibido | Invitación visible | Mensaje tipo "Te han invitado al plan [nombre]" con opciones Aceptar / Rechazar (o enlace al plan) | | |
| 2.5 | UB | Aceptar invitación (botón o enlace) | Aceptación registrada | Mensaje de éxito; plan pasa a estar en "mis planes" o "Estoy in" | | |
| 2.6 | UB | En dashboard, filtrar por "Estoy in" (o equivalente) | Plan del UA visible | Card del plan creado por UA visible en lista de UB | | |
| 2.7 | UB | Abrir el plan desde dashboard de UB | Acceso al plan como participante | Pantalla del plan con permisos de participante (sin opción de cambiar estado del plan, por ejemplo) | | |
| 2.8 | UC | No aceptar: no registrar cuenta aún, o registrar y no aceptar invitación, o rechazar explícitamente si hay botón | UC no es participante | Si UC tiene cuenta: invitación sigue en "pendiente" o "rechazada"; si no tiene cuenta: invitación sigue pendiente para cuando se registre | | |
| 2.9 | UA | Con UA, abrir el plan → Participantes | Estado de invitaciones actualizado | UB aparece como participante (rol participante); UC aparece como "pendiente" o "invitación enviada" (no participante) | | |
| 2.10 | UA | Comprobar número de participantes (si se muestra) | 2 personas (UA + UB) | Contador o lista: organizador + 1 participante | | |

**Postcondición:** UB participante del plan; UC no participante (invitación pendiente o rechazada). UA ve 2 miembros (él + UB).

---

## 9. Fase 3 – Eventos en borrador, timezones y participación

**Objetivo:** Plan con 3 eventos: uno borrador en timezone UA, otro en otra timezone, otro con "solicitar que se apunten" (requiresConfirmation o similar). Verificar visualización en calendario y opción de apuntarse.

**Precondición:** Fase 2; plan en borrador con UA y UB.

| # | Actor | Acción detallada | Resultado esperado | Verificación concreta | Resultado | Notas |
|---|--------|-------------------|--------------------|------------------------|-----------|--------|
| 3.1 | UA | Abrir plan → Info plan (o Perfil/Configuración). Buscar timezone del plan o del usuario | Timezone configurable | Campo o selector "Zona horaria" (ej. Europe/Madrid); guardar si se cambia | | |
| 3.2 | UA | Asegurar timezone UA = Europe/Madrid (perfil o plan) | Guardado | Valor persistido; sin error | | |
| 3.3 | UA | Ir a Calendario del plan. Pulsar "Nuevo evento" o doble clic en un día | Se abre diálogo/pantalla de creación de evento | Campos: título, fecha, hora, opción borrador, timezone si aplica | | |
| 3.4 | UA | Crear Evento 1: título "Cena Día 1", día 1 del plan, hora 20:00, timezone Europe/Madrid, marcar como borrador si hay checkbox | Evento guardado como borrador | Mensaje éxito; evento visible en calendario con indicador "borrador" (opacidad o badge) | | |
| 3.5 | UA | Crear Evento 2: título "Tour mañana", día 2, hora 10:00, timezone America/New_York (u otra distinta a UA) | Evento guardado; timezone guardada | En calendario de UA se muestra en hora local correcta (ej. 16:00 Madrid si 10:00 NY, según conversión); anotar hora mostrada | | |
| 3.6 | UA | Crear Evento 3: título "Actividad opcional", día 3, activar opción "Solicitar confirmación / que los usuarios se apunten" (requiresConfirmation o equivalente) | Evento con solicitud de confirmación/apuntarse | Evento guardado; en detalle del evento o en lista se indica que requiere confirmación/inscripción | | |
| 3.7 | UA | Guardar todos los eventos y cerrar diálogos | Tres eventos visibles en calendario | Calendario muestra 3 eventos; borrador con estilo diferenciado si aplica | | |
| 3.8 | UA | Abrir Evento 1 (editar) y comprobar que se puede editar (plan en borrador) | Edición permitida | Cambiar título o hora; guardar; cambio persistido | | |
| 3.9 | UB | Con UB, abrir el plan y ir a Calendario | Ve los eventos según permisos | UB ve los 3 eventos (o los que no sean solo borrador para organizador); anotar qué ve UB | | |
| 3.10 | UB | Abrir Evento 3 (el de "apuntarse") | Opción de apuntarse/confirmar visible si está implementado | Botón "Apuntarme" / "Confirmar asistencia" o similar; si no existe, anotar en Huecos | | |
| 3.11 | UA | Comprobar en calendario que Evento 2 muestra hora correcta para UA (Madrid) | Conversión timezone correcta | Ej.: si evento es 10:00 NY, en Madrid puede mostrarse 16:00 (o 15:00 según DST); anotar valor mostrado | | |

**Postcondición:** Plan con 3 eventos (1 borrador, 1 con otra timezone, 1 con solicitud de participación). UA y UB pueden ver el calendario. Anotar IDs o títulos de los 3 eventos para Fase 4.

**Tabla de verificación timezone (rellenar durante la prueba):**

| Evento | Hora guardada (timezone del evento) | Hora mostrada para UA (Madrid) | Hora mostrada para UC (NY) cuando UC esté en el plan |
|--------|-------------------------------------|---------------------------------|--------------------------------------------------------|
| Evento 1 | 20:00 Madrid | 20:00 | (rellenar en Fase 5) |
| Evento 2 | 10:00 NY | (ej. 16:00) | 10:00 |
| Evento 3 | (ej. 12:00 Madrid) | 12:00 | (rellenar en Fase 5) |

---

## 10. Fase 4 – Notificaciones y apuntarse a eventos (UB)

**Objetivo:** UB recibe notificación de eventos a los que puede apuntarse; se apunta a uno y no a otro; UA ve la participación.

**Precondición:** Fase 3; plan con 3 eventos; UB participante.

| # | Actor | Acción detallada | Resultado esperado | Verificación concreta | Resultado | Notas |
|---|--------|-------------------|--------------------|------------------------|-----------|--------|
| 4.1 | UB | En dashboard, revisar centro de notificaciones (W29) o icono de notificaciones | Notificación de evento(s) a los que puede apuntarse | Al menos un mensaje tipo "Nuevo evento: [nombre]" o "Puedes apuntarte a [evento]"; enlace o botón al plan/evento | | |
| 4.2 | UB | Abrir notificación (clic o "Ver notificaciones") | Navegación al plan o al evento | Se abre el plan o el detalle del evento sin error | | |
| 4.3 | UB | Ir a Calendario del plan. Identificar eventos con opción "Apuntarme" / "Confirmar" | Lista de eventos con inscripción | Evento 3 (y los que tengan requiresConfirmation o inscripción) muestran botón; Evento 1 y 2 según implementación | | |
| 4.4 | UB | Apuntarse al Evento 3 (o al primero que permita apuntarse) | Inscripción registrada | Mensaje de éxito; en el evento aparece UB como participante o "Confirmado" | | |
| 4.5 | UB | No apuntarse a otro evento (ej. Evento 1 o 2 si permiten inscripción) | Sin cambio | El evento sigue mostrando "Apuntarme" o sin UB en la lista de confirmados | | |
| 4.6 | UA | Con UA, abrir el plan → Calendario; abrir Evento 3 | Participación de UB visible | Lista de participantes del evento incluye a UB; o estado "Confirmado" para UB | | |
| 4.7 | UA | Abrir Evento 1 (y Evento 2 si aplica); comprobar que UB no está apuntado | UB no figura en esos eventos | Lista de participantes sin UB (o sin confirmación de UB) | | |
| 4.8 | UB | Volver a abrir Evento 3 y comprobar que puede "Cancelar mi participación" o similar (si existe) | Opción de desapuntarse | Botón o enlace para cancelar; al usarlo, UB deja de estar apuntado (opcional probar y deshacer para seguir con el flujo) | | |

**Postcondición:** UB apuntado al menos a un evento (Evento 3); UA ve la participación correcta. Notificaciones han sido recibidas por UB (anotar si llegaron por push, solo en app, o email).

---

## 11. Fase 5 – Re-invitar a UC y asignar a eventos

**Objetivo:** UA re-invita a UC; UC acepta; UA asigna a UC a eventos existentes; UC ve plan y eventos en su timezone.

**Precondición:** Fase 4; UC aún no participante.

| # | Actor | Acción detallada | Resultado esperado | Verificación concreta | Resultado | Notas |
|---|--------|-------------------|--------------------|------------------------|-----------|--------|
| 5.1 | UA | En el plan → Participantes, pulsar de nuevo "Invitar" e introducir Unplanazoo+emmcla@gmail.com | Nueva invitación enviada | Mensaje de éxito; si ya había invitación pendiente, puede mostrarse "Reenviada" o duplicado (anotar comportamiento) | | |
| 5.2 | UC | Si no tiene cuenta: Registrarse con Unplanazoo+emmcla@gmail.com | Cuenta creada | Verificación email si aplica (revisar spam) | | |
| 5.3 | UC | Aceptar invitación (desde notificación W29 o email) | UC pasa a ser participante | Plan visible en dashboard de UC (filtro "Estoy in") | | |
| 5.4 | UC | Abrir el plan desde dashboard de UC | Acceso al plan | Pantalla del plan con Calendario, Chat, Participantes, etc. | | |
| 5.5 | UA | En el plan, asignar a UC a eventos: abrir Evento 1 y Evento 2 (o diálogo de asignación de participante a eventos) | UC asignado a esos eventos | Si existe "Añadir participante al evento" o "Asignar UC a evento": UC aparece como participante de Evento 1 y 2; si no existe flujo, anotar en Huecos y simular con "invitación al evento" o anotar "solo organizador puede añadir a evento" | | |
| 5.6 | UC | Configurar timezone de UC = America/New_York (perfil o plan) | Timezone guardada | Selector timezone; valor persistido | | |
| 5.7 | UC | Abrir Calendario del plan | Eventos visibles en hora local de UC | Evento 2 (10:00 NY) se muestra 10:00 para UC; Evento 1 y 3 (Madrid) se muestran en hora NY (ej. 14:00 NY = 20:00 Madrid); rellenar tabla de Fase 3 si no se hizo | | |
| 5.8 | UA | Ver lista de participantes del plan | Tres miembros: UA, UB, UC | Lista con 3 personas; roles correctos (UA organizador, UB y UC participantes) | | |
| 5.9 | UA | Abrir Evento 1 y Evento 2 y comprobar que UC figura como participante (si se asignó en 5.5) | UC en lista de participantes del evento | Cada evento muestra a UC en participantes o en "asignados" | | |

**Postcondición:** UC participante del plan; asignado a al menos un evento (según implementación). UC ve calendario con horas en su timezone. Tres usuarios en el plan.

---

## 11.5 Fase: Pagos (registro y balances)

**Objetivo:** Validar registro de pagos, cálculo de balances y vista de resumen para los tres usuarios. Forma parte del alcance Pagos MVP (ver `docs/producto/PAGOS_MVP.md`).

**Precondición:** Fase 5 completada; plan con UA, UB, UC y al menos un evento con coste (para que haya coste por participante y balance tenga sentido).

| # | Actor | Acción detallada | Resultado esperado | Verificación concreta | Resultado | Notas |
|---|--------|-------------------|--------------------|------------------------|-----------|--------|
| P.1 | UA | Abrir el plan → pestaña "Pagos" (W18 en dashboard web) | Resumen de pagos visible | PaymentSummaryPage con balances por participante (o mensaje "Sin pagos aún"); moneda del plan; sin error | | |
| P.2 | UA | Registrar un pago: "UB pagó 50 €" (concepto ej. "Cena día 1", evento asociado si aplica) | Pago guardado | Diálogo o formulario de pago; mensaje de éxito; el pago aparece en la lista de pagos de UB | | |
| P.3 | UA | Comprobar balance de UB en el resumen | Balance actualizado | UB muestra "pagado" o balance positivo según lógica (total pagado − coste asignado); sugerencias de transferencia si aplican | | |
| P.4 | UB | Con UB, abrir el plan → Pagos | Ve el resumen y su balance | Mismo resumen que UA (o vista participante); UB ve su propio balance y el pago registrado por UA | | |
| P.5 | UC | Con UC, abrir el plan → Pagos | Ve el resumen del plan | UC ve balances de todos (o solo el suyo según permisos); sin crash; montos en moneda del plan | | |
| P.6 | UB | (Si la decisión de producto lo permite) Registrar "yo pagué X" desde UB: p. ej. 20 € por "Taxi" | Pago propio registrado | Mensaje de éxito; el pago aparece asociado a UB; balance de UB se actualiza | | |
| P.7 | UA | Volver a Pagos y comprobar sugerencias de transferencia (si hay deudas/créditos) | Sugerencias coherentes | Texto tipo "X debe Y € a Z"; coherente con costes y pagos registrados | | |

**Postcondición:** Al menos un pago registrado; los tres usuarios han abierto la pestaña Pagos y ven resumen coherente. Anotar en Huecos si algo no cuadra con las decisiones de `PAGOS_MVP.md` (permisos, bote común, etc.).

---

## 12. Fase 6 – Chat durante la creación del plan

**Objetivo:** UA, UB y UC envían mensajes en el chat del plan; orden y visibilidad correctos.

**Precondición:** Fase 5; los tres son participantes.

| # | Actor | Acción detallada | Resultado esperado | Verificación concreta | Resultado | Notas |
|---|--------|-------------------|--------------------|------------------------|-----------|--------|
| 6.1 | UA | Abrir el plan → pestaña/sección "Chat" (o W29 si el chat del plan está ahí) | Chat del plan visible | Lista de mensajes (vacía o con historial); campo de texto y botón Enviar | | |
| 6.2 | UA | Escribir mensaje: "Hola, bienvenidos al plan. Vamos a definir los eventos." y enviar | Mensaje enviado | Mensaje aparece en la lista con nombre/avatar de UA y timestamp | | |
| 6.3 | UB | En su sesión, abrir el mismo plan → Chat | Ve el mensaje de UA | Mensaje de UA visible; orden correcto (el más reciente abajo o arriba según diseño) | | |
| 6.4 | UB | Responder: "Gracias, ya me apunté al evento del día 3." y enviar | Mensaje enviado | Mensaje de UB visible para UB; sin error | | |
| 6.5 | UC | Abrir el plan → Chat | Ve mensajes de UA y UB | Ambos mensajes visibles en orden; sin duplicados | | |
| 6.6 | UC | Escribir: "Yo estaré en NY hasta el día 2, luego me uno." y enviar | Mensaje enviado | Mensaje de UC visible para UC | | |
| 6.7 | UA | Refrescar o reabrir Chat | Ve los 3 mensajes (UA, UB, UC) | Tres mensajes en orden cronológico; sin faltantes | | |
| 6.8 | UA | Enviar otro mensaje: "Perfecto, entonces el evento del día 2 lo vemos en NY." | Cuarto mensaje en el hilo | Cuatro mensajes en total; orden correcto | | |
| 6.9 | UB | Enviar mensaje sin cerrar sesión | Mensaje entregado | UA y UC ven el mensaje de UB al abrir el chat (o en tiempo real si hay WebSocket) | | |
| 6.10 | Cualquiera | Enviar 2–3 mensajes más en orden aleatorio (UA, UC, UB) | Sin errores; orden correcto | Secuencia final de mensajes coherente; sin duplicados ni pérdidas | | |

**Postcondición:** Chat con al menos 6–7 mensajes; los tres usuarios han enviado y visto mensajes. Anotar si la actualización es en tiempo real o al reabrir/refrescar.

---

## 13. Fase 7 – Aprobar / confirmar el plan (UA)

**Objetivo:** Cambiar estado del plan de borrador a confirmado (o planificando → confirmado); todos ven el nuevo estado.

**Precondición:** Plan en borrador o planificando; UA organizador.

| # | Actor | Acción detallada | Resultado esperado | Verificación concreta | Resultado | Notas |
|---|--------|-------------------|--------------------|------------------------|-----------|--------|
| 7.1 | UA | Abrir plan → Info plan (o pantalla de datos del plan) | Sección de estado visible | Selector o botón "Cambiar estado" / "Estado del plan" (si existe) | | |
| 7.2 | UA | Si el estado actual es "borrador", comprobar transición permitida a "planificando" o "confirmado" según implementación | Transición permitida | Lista desplegable o botones con estados permitidos; borrador → confirmado o borrador → planificando → confirmado | | |
| 7.3 | UA | Cambiar estado a "Confirmado" (o "Aprobado" / "Planificando" según UI) | Estado actualizado | Mensaje de éxito; badge o texto del plan muestra "Confirmado" (o equivalente) | | |
| 7.4 | UA | Recargar o reabrir Info plan | Estado persistido | Sigue mostrando Confirmado; no vuelve a Borrador | | |
| 7.5 | UB | Abrir el plan en su dashboard | Ve estado "Confirmado" | En cabecera o card del plan se indica estado confirmado | | |
| 7.6 | UC | Abrir el plan | Ve estado "Confirmado" | Mismo comportamiento que UB | | |
| 7.7 | UA | Intentar editar un evento (cambiar título o hora) | Según permisos: en confirmado suele permitirse editar eventos | Evento se puede editar y guardar; si no, anotar mensaje de bloqueo y comprobar con PlanStatePermissions | | |
| 7.8 | UB | Intentar cambiar el estado del plan (si hay UI para ello) | No permitido | Botón oculto o deshabilitado; o mensaje "Solo el organizador puede cambiar el estado" | | |

**Postcondición:** Plan en estado "confirmado" (o el que use la app). UA, UB y UC ven el mismo estado.

---

## 14. Fase 8 – Durante el plan: chat y propuestas

**Objetivo:** Intercambio de mensajes en el chat; intentar proponer nuevo evento o modificar uno (según permisos); plan estable en "en_curso" o "confirmado".

**Precondición:** Plan confirmado (Fase 7).

| # | Actor | Acción detallada | Resultado esperado | Verificación concreta | Resultado | Notas |
|---|--------|-------------------|--------------------|------------------------|-----------|--------|
| 8.1 | UA | Si la app tiene transición confirmado → en_curso (manual o por fecha), cambiar a "En curso" si aplica | Estado "En curso" | Badge o texto "En curso"; si no existe transición, dejar en Confirmado y seguir | | |
| 8.2 | UB | Abrir Chat del plan y enviar: "¿Quedamos a las 20:00 el día 1?" | Mensaje enviado | Mensaje visible en el hilo | | |
| 8.3 | UC | Responder en el chat: "Sí, bien para mí." | Mensaje enviado | Mensaje visible para UA y UB | | |
| 8.4 | UA | Enviar: "Confirmado, cena a las 20:00." | Mensaje enviado | Tres mensajes nuevos en orden | | |
| 8.5 | UB o UC | Buscar opción "Proponer evento" / "Sugerir evento" / "Nuevo evento" (como participante) | Si existe: flujo de propuesta; si no: anotar en Huecos | Botón o menú; si existe, crear propuesta "Desayuno día 2" y enviar; si no, anotar "No hay propuestas de eventos por participantes" | | |
| 8.6 | UA | Si hay propuestas: ver lista de propuestas y aprobar o rechazar "Desayuno día 2" | Propuesta aprobada o rechazada; en caso aprobada, evento creado | Evento nuevo visible en calendario o mensaje claro de rechazo | | |
| 8.7 | UA | Editar un evento existente (ej. cambiar hora del Evento 1 de 20:00 a 20:30) | Cambio guardado | Evento actualizado en calendario; UB y UC ven la nueva hora al abrir el plan | | |
| 8.8 | UB | Intentar eliminar un evento (si tiene opción) | No permitido (solo organizador) | Botón eliminar oculto o deshabilitado; o mensaje de permisos | | |
| 8.9 | UA | Comprobar estado del plan tras las ediciones | Sigue "Confirmado" o "En curso" | No ha vuelto a Borrador sin acción explícita | | |

**Postcondición:** Chat con más mensajes; al menos un intento de propuesta de evento (o hueco anotado); permisos de edición/eliminación verificados.

---

## 15. Fase 9 – UC deja el plan

**Objetivo:** UC deja de ser participante (por botón "Dejar plan" o porque UA lo remueve); UA y UB ven la lista actualizada; UC ya no ve el plan (o ve mensaje "Ya no participas").

**Precondición:** Plan en confirmado o en_curso; UC participante.

| # | Actor | Acción detallada | Resultado esperado | Verificación concreta | Resultado | Notas |
|---|--------|-------------------|--------------------|------------------------|-----------|--------|
| 9.1 | UC | Buscar opción "Dejar plan" / "Abandonar plan" / "Salir del plan" (en menú del plan, Participantes o Configuración) | Si existe: confirmación y salida; si no: anotar en Huecos | Botón o enlace; al pulsar, diálogo de confirmación; al confirmar, UC deja de ser participante | | |
| 9.2 | Si no existe 9.1 | UA abre Participantes → selecciona UC → "Remover" / "Eliminar del plan" | UC removido por organizador | Confirmación; UC desaparece de la lista de participantes | | |
| 9.3 | UA | Ver lista de participantes del plan | Solo UA y UB | Contador o lista: 2 participantes (UA, UB) | | |
| 9.4 | UB | Abrir Participantes o Chat | UC no figura como participante activo | Lista de participantes sin UC; en chat, mensajes antiguos de UC pueden seguir visibles pero UC no está en la lista de miembros | | |
| 9.5 | UC | En dashboard de UC, filtrar por "Estoy in" o abrir "Mis planes" | Plan no aparece (o aparece con estado "Ya no participas") | Plan desaparece de la lista o mensaje claro de que ya no participa | | |
| 9.6 | UC | Si queda enlace directo al plan (URL o notificación antigua), intentar abrir el plan | Acceso denegado o solo lectura | Redirección a dashboard o mensaje "No tienes acceso"; no debe poder editar ni ver datos sensibles | | |
| 9.7 | UA | Comprobar que los eventos del plan siguen intactos (UC no debe haber borrado nada al salir) | Eventos y participantes de eventos correctos | Eventos 1, 2, 3 siguen existiendo; UB sigue apuntado donde corresponda | | |

**Postcondición:** UC no es participante. UA y UB siguen en el plan. Anotar en Huecos si "Dejar plan" lo hace el participante o solo el organizador.

---

## 16. Fase 10 – UC vuelve al plan

**Objetivo:** UA re-invita a UC; UC acepta; UC ve de nuevo el plan, calendario y chat; UA y UB ven a UC en participantes.

**Precondición:** Fase 9; UC no participante.

| # | Actor | Acción detallada | Resultado esperado | Verificación concreta | Resultado | Notas |
|---|--------|-------------------|--------------------|------------------------|-----------|--------|
| 10.1 | UA | En el plan → Participantes → Invitar de nuevo a Unplanazoo+emmcla@gmail.com | Invitación enviada | Mensaje de éxito; si el sistema no permite re-invitar a alguien que ya estuvo, anotar en Huecos | | |
| 10.2 | UC | Recibir invitación (W29 o email) y aceptar | UC vuelve a ser participante | Plan visible de nuevo en "Estoy in" de UC | | |
| 10.3 | UC | Abrir el plan → Calendario | Eventos actuales visibles | Mismos eventos que antes (incluidos los creados en Fase 8 si hubo propuesta); horas en timezone de UC | | |
| 10.4 | UC | Abrir Chat | Historial de mensajes visible | Mensajes anteriores (incluidos los de cuando UC estaba) visibles; sin corrupción ni duplicados | | |
| 10.5 | UA | Ver Participantes | UC de nuevo en la lista | Tres miembros: UA, UB, UC | | |
| 10.6 | UB | Ver Participantes o Chat | UC visible como participante | UC en la lista; puede enviar mensaje y UB lo ve | | |
| 10.7 | UC | Enviar mensaje en el chat: "He vuelto, gracias por re-invitarme." | Mensaje entregado | UA y UB ven el mensaje | | |

**Postcondición:** UC de nuevo participante; calendario y chat coherentes. Tres usuarios en el plan.

---

## 17. Fase 11 – Cerrar el plan

**Objetivo:** UA cambia estado a "Finalizado" / "Cerrado"; todos ven el plan en filtro "Cerrados"; no se pueden hacer ediciones.

**Precondición:** Plan en confirmado o en_curso; UA, UB, UC participantes.

| # | Actor | Acción detallada | Resultado esperado | Verificación concreta | Resultado | Notas |
|---|--------|-------------------|--------------------|------------------------|-----------|--------|
| 11.1 | UA | Info plan → Cambiar estado a "Finalizado" (o "Cerrado") | Transición permitida | Selector o botón "Finalizar plan"; confirmación si la hay; estado actualizado a "Finalizado" | | |
| 11.2 | UA | Recargar la pantalla del plan | Estado persistido | Sigue "Finalizado"; no vuelve a En curso | | |
| 11.3 | UA | En dashboard, activar filtro "Cerrados" (o "Finalizados") | Plan aparece en la lista | Card del plan visible en la pestaña/filtro de cerrados | | |
| 11.4 | UB y UC | En su dashboard, filtrar "Cerrados" | Plan aparece | Mismo plan en su lista de planes cerrados | | |
| 11.5 | UA | Abrir el plan (solo lectura) | Vista limitada | No hay botón "Editar" o "Cambiar estado"; eventos y datos visibles pero no editables | | |
| 11.6 | UA | Intentar editar un evento (si hay botón visible) | No permitido | Botón deshabilitado o mensaje "Este plan está finalizado. Solo se permite visualización." (según getBlockedReason) | | |
| 11.7 | UB | Intentar añadir participante o cambiar estado | No permitido | Opciones no visibles o deshabilitadas | | |
| 11.8 | Cualquiera | Ver lista de participantes y de eventos | Solo lectura | Datos visibles; sin opción de eliminar o modificar | | |

**Postcondición:** Plan en estado "finalizado"; todos los usuarios ven el plan en "Cerrados" y en solo lectura.

---

## 18. Casos adicionales exhaustivos

Ejecutar según tiempo; anotar resultado y huecos.

### 18.1 Timezone cruzado

| # | Acción | Verificación | Resultado | Notas |
|---|--------|--------------|-----------|--------|
| TZ.1 | UA crea evento 15:00 Madrid (día 1) | UC (NY) lo ve en hora local (ej. 9:00 EST) | | |
| TZ.2 | UC crea evento 18:00 NY (si participante puede crear) | UA (Madrid) lo ve en hora local (ej. 0:00+1 día o 23:00 según DST) | | |
| TZ.3 | Cambiar timezone de UC a Europe/London y reabrir calendario | Eventos se recalculan en hora London | | |

### 18.2 Notificaciones

| # | Acción | Verificación | Resultado | Notas |
|---|--------|--------------|-----------|--------|
| N.1 | UB cierra la app; UA envía nueva invitación o crea evento; UB abre la app más tarde | UB ve notificación pendiente en W29 o icono de notificaciones | | |
| N.2 | UC tiene la app en segundo plano; UA envía mensaje en el chat | UC recibe notificación push o al abrir la app ve el mensaje nuevo | | |
| N.3 | Contenido de la notificación: texto claro (nombre del plan, tipo de evento: invitación / nuevo evento / mensaje chat) | Mensaje legible y enlace o acción clara | | |

### 18.3 Múltiples planes

| # | Acción | Verificación | Resultado | Notas |
|---|--------|--------------|-----------|--------|
| M.1 | UA crea un segundo plan "Plan B" e invita solo a UB | UB tiene 2 planes (este + Plan E2E); UC solo 1 | | |
| M.2 | UA en dashboard: filtro "Estoy in" | Ve ambos planes | | |
| M.3 | UB: filtro "Estoy in" | Ve ambos planes | | |
| M.4 | UC: filtro "Estoy in" | Ve solo Plan E2E | | |
| M.5 | Filtro "Pendientes" (invitaciones no aceptadas) | Quien tenga invitaciones pendientes las ve | | |
| M.6 | Filtro "Cerrados" | Solo planes en estado finalizado | | |

### 18.4 Permisos por rol

| # | Acción (actor) | Resultado esperado | Resultado | Notas |
|---|----------------|-------------------|-----------|--------|
| P.1 | UB intenta cambiar estado del plan | No permitido | | |
| P.2 | UB intenta eliminar un evento | No permitido | | |
| P.3 | UB intenta remover a UC de participantes | No permitido | | |
| P.4 | UC intenta invitar a otro usuario por email | No permitido (o permitido si hay rol coorganizador; anotar) | | |
| P.5 | UA remueve a UB del plan (tras Fase 11, no se puede; probar en plan confirmado) | En confirmado/en_curso: según PlanStatePermissions puede estar bloqueado; anotar mensaje | | |

### 18.5 Datos y consistencia

| # | Acción | Verificación | Resultado | Notas |
|---|--------|--------------|-----------|--------|
| D.1 | Tras Fase 11, anotar número total de mensajes en el chat | Mismo número para UA, UB y UC al abrir el plan | | |
| D.2 | Número de eventos del plan | Mismo para los tres (ej. 3 o 4 si hubo propuesta aprobada) | | |
| D.3 | Lista de participantes del Evento 3 (el de apuntarse) | UB y posiblemente UC; coherente con pasos de apuntarse/asignar | | |
| D.4 | Al reabrir el plan cerrado, no deben aparecer opciones de edición ni botones de estado | UI consistente con solo lectura | | |

### 18.6 Offline (si aplica)

| # | Acción | Verificación | Resultado | Notas |
|---|--------|--------------|-----------|--------|
| O.1 | Con conexión: abrir plan y cargar calendario. Activar modo avión. Intentar editar un evento | Error controlado o cola de sincronización; no crash | | |
| O.2 | Desactivar modo avión | Cambios pendientes se sincronizan o mensaje claro de conflicto | | |

### 18.7 Errores y bordes (anotar, no bloquear flujo)

| # | Situación | Qué anotar |
|---|-----------|------------|
| E.1 | Email de invitación con typo (ej. unplanazoo+marat@gmail.com) | ¿Mensaje de error? ¿Se puede corregir? |
| E.2 | Invitar al mismo email dos veces seguidas | ¿Error "ya invitado" o "reenviado"? |
| E.3 | Aceptar invitación con sesión de otro usuario | ¿Qué pasa? ¿Se asocia al usuario logueado? |
| E.4 | Crear evento con fecha anterior a "hoy" | ¿Permitido en borrador? ¿Mensaje de aviso? |
| E.5 | Mensaje de chat vacío o solo espacios | ¿Se puede enviar? ¿Validación? |
| E.6 | Plan sin nombre (si la UI lo permite) | ¿Validación al guardar? |

---

## 19. Huecos / Situaciones no contempladas → Tareas

Durante la prueba, anotar aquí todo lo que **no está implementado**, **es ambiguo** o **obliga a cambiar diseño**. Después, crear tarea en `docs/tareas/TASKS.md` con código T2xx y enlazar aquí.

| # | Descripción del hueco o comportamiento inesperado | Dónde ocurrió (fase/paso) | Severidad | Acción (Tarea / Issue) |
|---|-----------------------------------------------------|---------------------------|-----------|--------------------------|
| 1 | *(ejemplo)* No existe "Dejar plan" por parte del participante; solo organizador puede remover | Fase 9 | Media | TXXX: Permitir que participante abandone el plan |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |
| 5 | | | | |
| 6 | | | | |
| 7 | | | | |
| 8 | | | | |
| 9 | | | | |
| 10 | | | | |

**Sugerencias de qué buscar (no implementado o confuso):**

- Participante puede "dejar el plan" sin que le elimine el organizador.
- Re-invitar a un usuario que ya rechazó o que dejó el plan (mensaje claro, no duplicados).
- Propuestas de eventos por participantes (crear sugerencia que el organizador apruebe/rechace).
- Notificaciones push cuando hay nuevo mensaje en el chat o nuevo evento.
- Asignar participante a un evento desde la vista del organizador (asignar UC a evento concreto).
- Diferenciación clara en UI entre "evento requiere confirmación" y "evento para todos".
- Mensaje de bloqueo claro cuando una acción no está permitida por el estado del plan (ej. "En curso: no se pueden eliminar participantes").
- Plan finalizado: qué puede hacer cada rol (solo lectura para todos; exportar PDF si existe).
- Timezone del evento vs timezone del plan vs timezone del usuario (documentación o tooltip).
- Límite de invitaciones pendientes o de participantes por plan (si existe límite, que esté documentado y con mensaje claro).
- **Idiomas:** texto que sigue en un idioma al cambiar a otro; clave de traducción faltante en ES o EN; mensaje de error en inglés cuando la app está en español (o al revés).

**Instrucción:** No borrar filas; añadir filas nuevas. Al final de la sesión, crear tareas y poner el código en la columna "Acción".

---

## 19.1 Estrategia: documentar errores vs arreglar al vuelo

**Recomendación:** **Documentar todo y arreglar en paquete**, con una excepción: si un error **bloquea** el flujo (no puedes seguir con las pruebas), arreglarlo en el momento para poder continuar.

| Enfoque | Ventajas | Cuándo usarlo |
|---------|----------|----------------|
| **Documentar y arreglar en paquete** | No pierdes el ritmo de la prueba; ves el panorama completo; puedes priorizar y agrupar fixes (p. ej. todos los de idiomas); evitas arreglar A y luego encontrar B que invalida A. | Errores que no impiden seguir (UI, textos, permisos en casos secundarios, etc.). |
| **Arreglar uno a uno** | Cada fix se verifica enseguida; la lista no se hace enorme. | Solo para **bloqueantes**: crash, pantalla en blanco, botón que no responde y es imprescindible para la siguiente fase. |

**Flujo sugerido:**

1. **Durante la prueba:** anotar en la tabla de Huecos (sección 19) cada error o comportamiento raro; si algo **bloquea** (no puedes pasar de fase), arreglarlo ya y volver a ejecutar ese paso.
2. **Al terminar la sesión:** revisar la lista, agrupar por tipo (idiomas, permisos, UI, etc.) y crear tareas en `TASKS.md`; luego hacer **un paquete de fixes** (por prioridad) y un solo ciclo de revisión/commit.
3. **Opcional:** después del paquete, re-ejecutar solo las fases o pasos afectados para regresión, sin repetir todo el E2E.

Así mantienes las pruebas como fuente de verdad y evitas mezclar “probar” y “programar” más de lo necesario.

---

## 20. Registro de ejecución (resumen por fase)

**Idioma(s) de esta ejecución:** ES / EN / ambos (marcar según opción A, B o C de 5.5).

| Fase | Fecha ejecución | Ejecutor | Idioma(s) | Resultado global | Comentarios |
|------|------------------|----------|-----------|------------------|-------------|
| 0. Registro e inicial | | | | ✅ / ❌ / ⚠️ | |
| 1. Creación plan e invitaciones | | | | | |
| 2. Aceptar / rechazar | | | | |
| 3. Eventos borrador/timezones | | | | |
| 4. Notificaciones y apuntarse | | | | |
| 5. Re-invitar UC y asignar | | | | |
| 5.5 Pagos (registro y balances) | | | | |
| 6. Chat durante creación | | | | |
| 7. Aprobar plan | | | | |
| 8. Durante plan: chat y cambios | | | | |
| 9. UC deja el plan | | | | |
| 10. UC vuelve | | | | |
| 11. Cerrar plan | | | | |
| 18. Casos adicionales (resumen) | | | | |

**Resultado global de la sesión:** ✅ Aprobado / ❌ No aprobado / ⚠️ Aprobado con reservas (detallar en comentarios y en sección 19).  
**Idiomas probados:** anotar si se ejecutó en ES, EN o ambos y si hubo textos sin traducir (sección 19).

---

## 21. Reset y re-ejecución

Para volver a ejecutar el flujo desde cero:

1. **Cuentas:** Decidir si se borran los usuarios UB y UC en Firebase Auth (o se usan los mismos y se borran solo sus datos de participación en el plan de prueba).
2. **Planes:** Eliminar el plan "Viaje E2E 2026" (o el nombre usado) desde la app con UA, o desde Firebase Console (colección `plans` y documentos relacionados: `plan_participations`, `plan_invitations`, `events`, `event_participants`, mensajes de chat si están en una subcolección).
3. **Invitaciones:** Al borrar el plan, las invitaciones asociadas deben desaparecer o quedar obsoletas (comprobar comportamiento).
4. **Este documento:** Dejar las columnas "Resultado" y "Notas" en blanco para la nueva ejecución, o copiar el documento y renombrar (ej. `PLAN_PRUEBAS_E2E_TRES_USUARIOS_2026-02-XX.md`).

**Tiempo estimado (una pasada completa):** 2–4 horas según profundidad (incluyendo casos adicionales y anotación de huecos).
