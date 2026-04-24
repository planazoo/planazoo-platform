# 🔔 Flujo de Invitaciones y Notificaciones

> Define el sistema de invitaciones a planes y notificaciones de cambios

**Relacionado con:** T104, T105, T110, T259  
**Versión:** 1.4  
**Fecha:** Abril 2026 (push de invitación desde acciones app + alcance Android)

---

## 🎯 Objetivo

Documentar el sistema completo de invitaciones a participantes y notificaciones de cambios en el plan, eventos y colaboración.

---

## 📊 TIPOS DE NOTIFICACIONES

| Tipo | Descripción | Prioridad | Canal | Cuándo |
|------|-------------|-----------|-------|--------|
| **Invitación** | Invitación a un plan nuevo | Alta | Email + Push | Al invitar |
| **Invitación cancelada** | El organizador cancela una invitación pendiente | Alta | Email + Push | Al cancelar |
| **Confirmación** | Participante acepta/rechaza → Organizador recibe notificación | Normal | Push | Al responder |
| **Cambio evento** | Modificación de evento | Variable | Variable | Al cambiar |
| **Cambio participante** | Añadir/eliminar participante | Alta | Email + Push | Al cambiar |
| **Estado plan** | Plan cambia de estado | Alta | Email + Push | Al cambiar |
| **Alarma** | Recordatorio de evento | Crítica | Push + SMS | Antes del evento |
| **Aviso** | Mensaje del organizador | Normal | Push | Al publicar |

---

## 📋 PROCESOS

### 1. INVITACIONES (T104)

#### 1.1 - Invitar por Email

**Flujo completo:**
```
Organizador → "Invitar por email"
  ↓
Formulario:
- Email: usuario@example.com
- Rol: Participante / Observador
- Mensaje personalizado: (opcional)
  ↓
Sistema genera link único con token (el link puede incluir el query param `?action=accept`; la app hace strip del param tras usarlo)
  ↓
Email enviado:
┌──────────────────────────────┐
│ Hola!                        │
│                              │
│ Juan Ramos te ha invitado al │
│ plan "Vacaciones Londres"    │
│                              │
│ [Ver Plan] [Aceptar] [Rechazar]
│                              │
│ Mensaje: "¡Espero verte!"    │
│                              │
│ Link válido hasta: 7 días    │
└──────────────────────────────┘
  ↓
Participante hace clic en link
  ↓
Si tiene app instalada:
- Abrir app
- Ir a pantalla de invitación
- Ver detalles del plan
- Botones: [Aceptar] / [Rechazar]

Si NO tiene app:
- Mostrar web con detalles plan
- Botones: [Descargar app] / [Aceptar sin app]
  ↓
Participante acepta
  ↓
Sistema:
- Crear cuenta automática (si no tiene)
- Crear participación con estado "Aceptada"
- Crear track del participante
- Asignar a eventos futuros (opcional)
  ↓
Notificar a organizador
Email: "[Nombre] ha aceptado tu invitación"
  ↓
Actualizar contador de participantes
```

#### 1.2 - Invitar desde la lista de usuarios (registrados)

**Implementado (Feb 2026):** El organizador puede invitar tanto **por email** (diálogo "Invitar por email") como **desde la lista de usuarios** (buscar usuario y pulsar "Invitar"). En ambos casos se crea una **invitación pendiente** (no se añade al plan directamente); el invitado recibe notificación y puede **aceptar o rechazar**. Tanto si acepta como si rechaza, **el organizador recibe una notificación** (tipo `invitationAccepted` o `invitationRejected`). En la página de Participantes, el organizador ve la sección **"Invitaciones"** con el **estado** de cada una: Pendiente, Aceptada, Rechazada, Cancelada, Expirada.

**Flujo (desde lista):**
```
Organizador → Participantes → "Invitar usuarios" (lista)
  ↓
Buscar usuario por nombre/email
  ↓
Pulsar "Invitar" en el usuario deseado
  ↓
Sistema crea plan_invitation / participación pending + notificación in-app al invitado
  ↓
App dispara push FCM (Cloud Function `sendInvitationPush`)
  ↓
Payload incluye:
- planId
- type = invitation
- tab = participants
  ↓
Invitado recibe notificación → abre → [Aceptar] / [Rechazar]
  ↓
Si acepta: participación creada; invitación → "accepted"; notificación al organizador
Si rechaza: invitación → "rejected"; notificación al organizador
  ↓
Organizador ve en "Invitaciones" el estado (Pendiente / Aceptada / Rechazada)
```

#### 1.3 - Invitar Grupo (T123)

**Flujo:**
```
Organizador → "Invitar grupo"
  ↓
Seleccionar grupo: "Familia Ramos"
  ↓
Mostrar miembros:
- Juan Ramos ✅ (activo)
- María Ramos ✅ (activa)
- Pedro Ramos ❓ (inactivo)
- Ana Ramos ❓ (no tiene app)
  ↓
Organizador selecciona a quién invitar
  ↓
Enviar invitaciones:
- A usuarios activos: Push
- A usuarios inactivos: Email
  ↓
Cada miembro gestiona individualmente
  ↓
Estados independientes por miembro
```

#### 1.4 - Recordatorios de Invitaciones Pendientes

**Sistema automático:**
```
Invitación enviada
  ↓
Esperar 2 días sin respuesta
  ↓
Enviar recordatorio 1 (suave):
"Te enviamos una invitación hace 2 días.
¿Puedes responder?"
  ↓
Esperar 3 días más sin respuesta
  ↓
Enviar recordatorio 2 (más insistente):
"[Nombre], te invitamos hace 5 días.
Por favor, confirma tu asistencia para poder organizar el plan."
  ↓
Esperar 2 días más sin respuesta
  ↓
Marcar como "Expirada"
  ↓
Notificar a organizador:
"[Nombre] no ha respondido a tu invitación.
Puedes re-enviar la invitación o eliminarla."
```

#### 1.5 - Cancelación de Invitación (Owner/Admin)

**Flujo completo:**
```
Organizador → Participantes → Invitaciones pendientes → "Cancelar"
  ↓
Confirmación:
"¿Seguro que deseas cancelar esta invitación para [email]?"
  ↓
Sistema:
- Cambia `status` → "cancelled"
- Estampa `respondedAt`
  ↓
Notificaciones:
- Email al invitado:
  Asunto: "Se ha cancelado tu invitación al plan [Nombre]"
  Contenido: "El organizador ha cancelado la invitación. No necesitas realizar ninguna acción."
- Push (si el invitado tiene cuenta/app): "Tu invitación a [Nombre] ha sido cancelada"
- Email al organizador (opcional) o snackbar de confirmación en la app
  ↓
UI:
- La invitación desaparece de la lista de pendientes
- El contador de invitaciones pendientes se actualiza
```

**Reglas y seguridad:**
- Solo el owner del plan o un admin pueden cancelar invitaciones (ver `firestore.rules` `plan_invitations.update` con `status: 'cancelled'`).
- No se permiten cambios de otros campos al cancelar (solo `status` y `respondedAt`).

#### 1.6 - Aceptar/Rechazar Invitación (Usuario Invitado)

**Flujo completo:**
```
Usuario invitado recibe invitación (email o en app)
  ↓
Usuario hace clic en link o abre invitación en app
  ↓
Sistema verifica:
- Token válido (si es link)
- Invitación no expirada (7 días)
- Estado de invitación es "pending"
  ↓
Usuario acepta o rechaza
  ↓
Si ACEPTA:
- Sistema crea `PlanParticipation` con estado "accepted"
- Sistema actualiza `plan_invitations.status` → "accepted" y `respondedAt` (en cliente y/o vía **Cloud Function `markInvitationAccepted`** para garantizar permisos en Firestore)
- Usuario es añadido al plan
- Notificar al organizador
  ↓
Si RECHAZA:
- Sistema actualiza `plan_invitations.status` → "rejected"
- Sistema estampa `plan_invitations.respondedAt`
- Usuario NO es añadido al plan
- Notificar al organizador
```

**Reglas y seguridad:**
- **Solo el usuario invitado puede aceptar/rechazar su propia invitación** (ver `firestore.rules` `plan_invitations.update`).
- La verificación del email se hace de dos formas:
  1. Primero verifica el email del token de Firebase Auth (`request.auth.token.email`)
  2. Si no coincide, verifica el email del documento de usuario en Firestore (`users/{userId}.email`)
- Esta doble verificación asegura que funcione incluso si el email del token no coincide exactamente con el email de la invitación.
- Solo se pueden actualizar los campos `status` y `respondedAt` (no se pueden modificar `planId`, `email`, `token`, `createdAt`, `expiresAt`, `role`).
- Solo se puede cambiar el estado de "pending" a "accepted" o "rejected".
- **Solo el organizador del plan puede eliminar invitaciones** (ver `firestore.rules` `plan_invitations.delete`).

**Notas importantes:**
- Si la actualización del estado de la invitación falla por permisos, pero la participación se crea correctamente, el sistema continúa funcionando (la participación es lo más importante).
- El estado de la invitación a "accepted" se actualiza desde el cliente y/o mediante la **Cloud Function `markInvitationAccepted`** para evitar problemas de permisos en Firestore. El link de invitación puede llevar `?action=accept`; la app puede eliminar este param de la URL tras procesarlo para evitar reenvíos.

---

### 2. NOTIFICACIONES DE CAMBIOS (T105)

#### 2.1 - Sistema de Avisos Unidireccionales

**Concepto:** Sistema de mensajes del organizador a participantes (NO es chat)

**Flujo:**
```
Organizador → "Publicar aviso"
  ↓
Modal de publicación:
"Escribe tu aviso para [nombre del plan]:"

[Aviso:                              ]
[                                     ]
[                                     ]

[Añadir foto] [Añadir ubicación] [Publicar]

  ↓
Publicar aviso
  ↓
Sistema:
- Guardar aviso en plan
- Notificar a todos los participantes (T105)
- Mostrar timestamp y autor
  ↓
Participantes reciben notificación push
  ↓
Abrir notificación
  ↓
Ver aviso en timeline del plan
  ↓
Listo (no se puede responder)
```

**Campos del aviso:**
- Autor (usuario que publica)
- Mensaje (texto)
- Timestamp
- Tipo: "Información" / "Urgente" / "Importante" (`PlanAnnouncement.type`: info, urgent, important)
- *(Pendiente en código: foto adjunta, ubicación)*

**Historial de avisos:**
```
Timeline del plan:
───────────────────────────
Hace 2 horas
Aviso de Juan Ramos:
"Recordatorio: El vuelo sale mañana
 a las 08:00h. Llegar al aeropuerto a las 6:00h."
───────────────────────────
Hace 1 día
Aviso de Juan Ramos:
"Actualización: El restaurante ha cambiado
 a uno más cercano al hotel."
───────────────────────────
Hace 3 días
Aviso de Juan Ramos:
"Bienvenidos al plan Londres 2025! 🎉"
───────────────────────────
```

#### 2.2 - Notificaciones Automáticas de Cambios

**Tipos de cambios que generan notificación:**

**Cambio de Estado del Plan:**
```
Plan cambia de "Planificando" → "Confirmado"
  ↓
Notificar a todos los participantes
  ↓
Email + Push:
"El plan 'Vacaciones Londres' ha sido confirmado.

Está listo para ejecutarse el 15/11/2025."
```

**Cambio de Evento (por magnitud):**
```
Cambiar hora de evento <1h:
- Notificar con prioridad baja

Cambiar hora de evento 1-4h:
- Notificar con prioridad alta

Cambiar hora de evento >4h:
- Notificar con prioridad crítica
- Requiere reconfirmación (T120)
```

**Cambio de Participantes:**
```
Añadir participante:
"María García se ha unido al plan 'Vacaciones Londres'"

Eliminar participante:
"Pedro Martínez ha sido eliminado del plan.
Si tenías eventos asignados con Pedro, serán actualizados."
```

#### 2.3 - Notificaciones de Alarmas (T110)

**Concepto:** Recordatorios automáticos antes de eventos

**Configuración de alarma:**
```
Crear/editar evento
  ↓
"Recordatorios"
  ↓
Configurar:
- Recordatorio 1: 24h antes
- Recordatorio 2: 2h antes
- Recordatorio 3: 30min antes
  ↓
Guardar
```

**Flujo de alarma:**
```
Hora del evento: 15/11/2025 a las 10:00h
  ↓
[24h antes] 14/11/2025 a las 10:00h
Enviar notificación: "Mañana tienes [Evento] a las 10:00h"
  ↓
[2h antes] 15/11/2025 a las 08:00h
Enviar notificación: "En 2h: [Evento]"
  ↓
[30min antes] 15/11/2025 a las 09:30h
Enviar notificación PUSH urgente + SMS:
"⚠️ En 30 minutos: [Evento]
Ubicación: [Dirección]"
```

**Configuración por usuario:**
```
Ajustes personales → Notificaciones
  ↓
Configurar:
- Alarmas: Activadas
- Horarios silencio: 22:00h - 08:00h
- Snooze: 5 minutos / 30 minutos / 1 hora
  ↓
Guardar
```

---

### 3. SISTEMA DE CONFIRMACIÓN DE EVENTOS (T120)

#### 3.1 - Eventos que Requieren Confirmación

**Configuración:**
```
Crear evento
  ↓
Configuración avanzada
  ↓
Checkbox: "Requiere confirmación de asistencia"
- Activar
  ↓
Configurar límite opcional:
- "Máximo 10 personas" (opcional)
  ↓
Guardar
```

**Flujo de confirmación:**
```
Evento creado con "requiere confirmación"
  ↓
Participantes asignados reciben notificación:
"Invitación a evento: [Nombre evento]
Fecha: [Fecha del evento]
Ubicación: [Ubicación]
Límite: 10 personas (7 confirmadas)"

[Confirmar asistencia] [No puedo asistir]
  ↓
Participante confirma
  ↓
Sistema:
- Actualizar contador confirmaciones
- Mostrar "quién confirmó" en UI
- Notificar a otros si hay lista de espera
  ↓
Si se alcanza límite:
- Cerrar confirmaciones
- Crear lista de espera
```

**UI del evento:**
```
┌──────────────────────────────┐
│ Cena Grupal                   │
│ 📍 Restaurant X              │
│ 📅 15/11/2025 - 20:00h      │
│ 👥 8 de 10 personas          │
│                              │
│ Confirmados (8):             │
│ ✅ Juan                      │
│ ✅ María                     │
│ ✅ Pedro                     │
│ ✅ Ana                       │
│ ✅ Luis                      │
│ ✅ Laura                     │
│ ✅ Miguel                    │
│ ✅ Carmen                    │
│                              │
│ Lista de espera (2):        │
│ ⏳ Rosa                      │
│ ⏳ Carlos                    │
└──────────────────────────────┘
```

---

## 📊 DIAGRAMA DE FLUJO DE NOTIFICACIONES

```mermaid
graph TD
    Start([Cambio en Plan]) --> Type{¿Tipo de Cambio?}
    
    Type -->|Estado| StateChange[Cambio de estado del plan]
    Type -->|Evento| EventChange[Cambio de evento]
    Type -->|Participante| PartChange[Cambio de participante]
    Type -->|Aviso| Aviso[Publicar aviso]
    
    StateChange --> CheckImpact{¿Impacto?}
    EventChange --> CheckImpact
    PartChange --> CheckImpact
    Aviso --> HighPrio[Prioridad: Normal]
    
    CheckImpact -->|Crítico| HighPrio[Prioridad: Crítica]
    CheckImpact -->|Alto| MedPrio[Prioridad: Alta]
    CheckImpact -->|Normal| NormalPrio[Prioridad: Normal]
    
    HighPrio --> NotifyAll[Notificar a todos]
    MedPrio --> NotifyAll
    NormalPrio --> NotifyAll
    
    NotifyAll --> Channel{¿Canal?}
    
    Channel -->|Crítica| MultiChannel[Email + Push + SMS]
    Channel -->|Alta| EmailPush[Email + Push]
    Channel -->|Normal| EmailOnly[Email]
    
    MultiChannel --> Wait{¿Confirmación requ.?}
    EmailPush --> Wait
    EmailOnly --> Wait
    
    Wait -->|Sí| Reconflujo[Sistema reconfirmación T120]
    Wait -->|No| End([Finalizar])
    
    Reconflujo --> CollectConfirm[Recopilar confirmaciones]
    CollectConfirm --> CheckThreshold{¿>80% confirmado?}
    
    CheckThreshold -->|Sí| AutoConfirm[Confirmar cambio]
    CheckThreshold -->|No| Remind[Enviar recordatorio]
    
    AutoConfirm --> End
    Remind --> CollectConfirm
    
    style Type fill:#e1f5ff
    style CheckImpact fill:#fff4e1
    style Channel fill:#ffe1f5
    style Wait fill:#e1ffe1
    style CheckThreshold fill:#ffeb3b
```

---

## 📱 ACCESO A NOTIFICACIONES EN LA APP (CAMPANA VS W20)

La especificación de producto está en **`docs/producto/NOTIFICACIONES_ESPECIFICACION.md`**. Resumen de acceso:

| Entrada | Contenido |
|--------|-----------|
| **Campana** (icono notificaciones) | **Lista global:** todas las notificaciones (invitaciones, avisos, eventos desde correo, cambios en eventos, etc.), ordenadas por fecha (más reciente primero). Filtro por **acción:** "Pendientes de acción" / "Solo informativas". Badge con total de no leídas. |
| **W20** (pestaña "Notificaciones" del dashboard) | **Notificaciones del plan seleccionado.** W20 forma parte de W14–W25 (siempre hay un plan seleccionado). Contenido: (1) notificaciones con `planId` = plan seleccionado (invitaciones a ese plan, avisos del plan, cambios en eventos del plan); (2) sección "Eventos desde correo pendientes" para asignar a este plan o descartar. |

- La lista global agrega todas las fuentes (plan_invitations, pending_email_events, users/.../notifications, event_notifications si aplica).
- W20 filtra por plan y añade la sección de eventos desde correo pendientes.

---

## 📋 TAREAS RELACIONADAS

**Pendientes:**
- T104: Sistema completo de invitaciones (email, username, grupos)
- T105: Sistema completo de notificaciones (push, email, avisos)
- T110: Sistema de alarmas y recordatorios
- T120: Sistema de confirmación de eventos
- Integración con Firebase Cloud Messaging (FCM)
- Configuración de preferencias de notificación por usuario

**Completas ✅:**
- Invitaciones por email con token (T104), avisos del plan (T105 base), confirmación de asistencia a eventos (T120 Fase 2 base). Véase sección "Implementación actual" más abajo.

---

## ✅ IMPLEMENTACIÓN ACTUAL

**Estado:** ⚠️ Parcialmente implementado (base invitaciones/notificaciones operativa; pendiente cierre paridad Android end-to-end)

**Lo que está implementado:**
- ✅ Sistema de avisos unidireccionales - Base (T105)
  - ✅ Modelo `PlanAnnouncement` con tipos (info, urgent, important)
  - ✅ Publicación de avisos con validación y sanitización
  - ✅ Timeline cronológica de avisos
  - ✅ Eliminación de avisos (autor u organizador)
  - ✅ Integración en pantalla de datos del plan
  - ✅ Firestore rules y providers Riverpod

**Lo que falta:**
- ✅ Sistema de invitaciones por email/usuario - COMPLETADO (T104):
  - ✅ Modelo PlanInvitation con token único y expiración (7 días)
  - ✅ InvitationService para gestionar invitaciones
  - ✅ Búsqueda de usuario por email (si existe, requiere aceptación explícita)
  - ✅ Generación de links únicos con token
  - ✅ Página InvitationPage para procesar links (/invitation/{token})
  - ✅ Email HTML con botones "Aceptar" / "Rechazar" (Firebase Functions + Gmail SMTP)
  - ✅ Template HTML responsive con información del plan
  - ✅ Firestore rules para plan_invitations con verificación de email mejorada (token + fallback a documento usuario)
  - ✅ Campo status en PlanParticipation (pending, accepted, rejected, expired)
  - ✅ Métodos acceptInvitationByToken y rejectInvitationByToken en servicio
  - ✅ UI diálogo para aceptar/rechazar invitaciones por token en app
  - ✅ Integración en ParticipantsScreen y DashboardPage para mostrar invitaciones pendientes
  - ✅ Validación de email antes de crear invitación
  - ✅ Prevención de invitaciones duplicadas (detecta invitaciones pendientes existentes)
  - ✅ Prevención de invitar usuarios que ya son participantes
  - ✅ Gestión de invitaciones canceladas por organizador
  - ✅ Verificación de permisos: solo el usuario invitado puede aceptar/rechazar su propia invitación
  - ✅ Verificación de permisos: solo el organizador puede eliminar invitaciones
  - ✅ Manejo de errores cuando la actualización del estado falla pero la participación se crea correctamente
  - ✅ Cloud Function **markInvitationAccepted** para actualizar el estado de la invitación a "accepted" (evita problemas de permisos en Firestore)
  - ✅ Link de invitación puede incluir `?action=accept`; la app hace strip del param tras usarlo
  - ⚠️ Pendiente: Invitaciones por username/nickname (T104 - parte opcional)
- ✅ Notificaciones push iOS (estado 2026-04): flujo foreground/background estabilizado; cierre QA del ítem 109.
- ✅ Push de invitación desde acción app (usuario registrado): al invitar se crea notificación in-app y se llama a Cloud Function `sendInvitationPush` (valida que el llamador sea `invitedBy` de la participación pending) con `type=invitation` + `tab=participants`.
- ⚠️ Android: pendiente validación operativa completa del mismo flujo en dispositivo Android físico (T267).
- ✅ **Sistema unificado de notificaciones** (Feb 2026): Implementado según `docs/producto/NOTIFICACIONES_ESPECIFICACION.md`. Campana = lista global (GlobalNotificationsService + globalNotificationsListProvider, filtro por acción, badge con globalUnreadCountProvider). W20 = WdPlanNotificationsScreen(plan) con notificaciones del plan (planId) + sección eventos desde correo pendientes. Modelo UnifiedNotification; widget reutilizable UnifiedNotificationItem.
- ✅ Sistema de confirmación de asistencia a eventos - Base (T120 Fase 2):
  - ✅ Campo requiresConfirmation en Event
  - ✅ Campo confirmationStatus en EventParticipant
  - ✅ Checkbox en EventDialog para organizador
  - ✅ Creación automática de confirmaciones pendientes
  - ✅ Botones confirmar/no asistir para participantes
  - ✅ Indicadores visuales de estado (confirmado, pendiente, declinado)
  - ✅ Estadísticas y listas por estado
  - ✅ Integración con límites de participantes
  - ⚠️ Notificaciones push (pendiente FCM)
- ❌ Sistema de alarmas antes de eventos
- ❌ Configuración de preferencias de notificación
- ❌ Recordatorios automáticos

---

*Documento de flujo de invitaciones y notificaciones*  
*Última actualización: Abril 2026 (push invitación app + estado iOS cerrado + seguimiento Android T267)*

**Cambios recientes (v1.3):**
- ✅ Implementación del sistema unificado: campana con lista global + filtro + badge; W20 con notificaciones del plan + eventos desde correo.
- ✅ Estado push actualizado: FCM con tap handler central en `App`, contrato de payload documentado y background handler en `main.dart`; validación final en dispositivo iOS físico pendiente.
- ✅ Referencia operativa para cierre iOS: `docs/configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md` y seguimiento en `docs/testing/ACCIONES_PENDIENTES_APP.md`.

**Cambios recientes (v1.4):**
- ✅ Invitación desde acción app ahora dispara push FCM (Cloud Function `sendInvitationPush`) con navegación a pestaña `participants`.
- ✅ Documentado control de permisos server-side para evitar envío arbitrario de push.
- ⚠️ Añadido seguimiento explícito Android (T267) para validar paridad del flujo.

**Cambios recientes (v1.2):**
- ✅ Añadida sección "Acceso a notificaciones en la app (campana vs W20)" y referencia a `NOTIFICACIONES_ESPECIFICACION.md`.

**Cambios recientes (v1.1):**
- ✅ Aclarado que solo el usuario invitado puede aceptar/rechazar su propia invitación
- ✅ Aclarado que solo el organizador puede eliminar invitaciones
- ✅ Documentada la verificación de email mejorada (token + fallback a documento usuario)
- ✅ Documentado el manejo de errores cuando la actualización del estado falla pero la participación se crea correctamente
- ✅ Actualizada la sección de implementación con todos los detalles completados
- ✅ Documentada Cloud Function **markInvitationAccepted** y link con `?action=accept` (Feb 2026)

