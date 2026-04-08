# 👥 Flujo de Gestión de Participantes

> Define cómo añadir, eliminar y gestionar participantes en un plan

**Relacionado con:** T51 - Validación de formularios (✅), T104, T117, T120, T123, T126 - Rate limiting (✅)  
**Ver CRUD completo:** `FLUJO_CRUD_PLANES.md`  
**Versión:** 1.3  
**Fecha:** Abril 2026 (revisión de coherencia documental con estado actual de invitaciones/notificaciones)

---

## 🎯 Objetivo

Documentar todos los escenarios de gestión de participantes: añadir, eliminar, cambiar roles, invitaciones, confirmaciones, y cómo cada acción afecta al plan.

---

## 📊 TIPOS DE PARTICIPANTES

| Rol | Descripción | Permisos | Puede Editar | Puede Ver |
|-----|-------------|----------|--------------|-----------|
| **Anfitrión** | Creador del plan | ✅ Total | Todo el plan | Todo |
| **Coorganizador** | Segundo al mando | ✅ Casi total | Casi todo excepto eliminar plan | Todo |
| **Participante** | Miembro activo | ✅ Activo | Solo su parte personal | Todo |
| **Invitado** | Pendiente de confirmar | ⚠️ Limitado | Nada | Solo estructura básica |
| **Observador** | Solo lectura | ❌ Ninguno | Nada | Plan completo |

---

## 📋 PROCESOS DE GESTIÓN

### 1. AÑADIR PARTICIPANTES

> Todas las acciones de invitación se ejecutan desde `ParticipantsScreen` (W16), accesible mediante el enlace “Gestionar participantes” en `PlanDataScreen`.

#### 1.1 - Invitar por Email (no tiene app)

**Flujo:**
```
Organizador → "Invitar por email"
  ↓
Sistema envía email con link único
  ↓
Link expira en 7 días
  ↓
Usuario hace clic en link
  ↓
Si tiene cuenta: Se añade automáticamente
Si NO tiene cuenta: Crea cuenta automática
  ↓
Participación creada con estado "Invitado"
  ↓
Participante confirma asistencia (T120)
  ↓
Estado cambia a "Participante"
```

**Campos necesarios:**
- Email del invitado
- Rol asignado (Participante, Observador)
- Timezone inicial
- Mensaje personalizado (opcional)

**Implementación (T104):**
- Generar link único con token
- Email HTML con botones "Aceptar" / "Rechazar"
- Redirección a app después de aceptar
- Expiración de link

#### 1.2 - Invitar desde la lista de usuarios (registrados)

**Implementado (Feb 2026):** Igual que invitar por email, se crea una **invitación** (no se añade al plan directamente). El invitado recibe notificación y puede aceptar o rechazar; el organizador recibe notificación al aceptar/rechazar. En Participantes, el organizador ve la sección "Invitaciones" con el estado de cada una (Pendiente, Aceptada, Rechazada, Cancelada, Expirada). Ver detalles en `FLUJO_INVITACIONES_NOTIFICACIONES.md` § 1.2.

**Flujo:**
```
Organizador → Participantes → "Invitar usuarios" (lista)
  ↓
Búsqueda por nombre/email
  ↓
Pulsar "Invitar" en el usuario
  ↓
Sistema crea invitación (pending) + notificación al invitado
  ↓
Invitado acepta/rechaza → notificación al organizador
  ↓
Si acepta: se crea participación; organizador ve estado en "Invitaciones"
```

**Campos necesarios:** Rol asignado (y opcionalmente timezone, mensaje). Usuario identificado por la lista.

#### 1.3 - Invitar Grupo Completo (T123)

**Flujo:**
```
Organizador → "Invitar grupo: Familia Ramos"
  ↓
Sistema muestra lista de miembros del grupo
  ↓
Organizador selecciona subconjunto (o todos)
  ↓
Sistema envía invitaciones a todos
  ↓
Cada miembro gestiona su invitación individualmente
  ↓
Estado por participante independiente
```

**Beneficios:**
- Invitar múltiples personas de una vez
- Reutilizar grupos entre planes
- Gestión centralizada de contactos frecuentes

---

### 2. CONFIRMAR ASISTENCIA

**Estados de invitación:**
- **Pendiente:** Invitación enviada, esperando respuesta
- **Aceptada:** Participante confirma que asistirá
- **Rechazada:** Participante rechaza invitación
- **Expirada:** Invitación sin respuesta >7 días

**Flujo (T120):**
```
Participante recibe notificación
  ↓
Abre plan
  ↓
Ve modal "¿Asistes al plan [nombre]?"
  ↓
Opción 1: "Sí, asistiré"
  ↓
Crear track del participante
Asignar a eventos futuros (opcional)
Actualizar contador participantes
  ↓
Opción 2: "No puedo asistir"
  ↓
Mantener en plan como "Rechazado"
NO crear track
NO asignar a eventos
  ↓
Opción 3: Cerrar sin responder
  ↓
Recordatorio automático en 2 días
```

**Acciones disponibles según estado:**
- **Pendiente:** Botón "Aceptar" / "Rechazar", Recordatorio automático
- **Aceptada:** Editar parte personal, ver plan completo, participar
- **Rechazada:** Ver plan básico, re-aceptar invitación, dejar comentario
- **Expirada:** Re-enviar invitación, Eliminar de plan

---

### 2.5 SALIR DEL PLAN (VOLUNTARIO)

**Implementado (Feb 2026):** Un **participante** (no organizador) puede abandonar el plan por su cuenta desde dos sitios:

1. **Info del plan (PlanDataScreen):** Botón "Salir del plan" en la zona de acciones.
2. **Pestaña Participantes (ParticipantsScreen):** Sección "Salir del plan" con botón y confirmación.

**Flujo:**
```
Participante (no owner) → "Salir del plan"
  ↓
Diálogo de confirmación: "¿Seguro que quieres salir del plan [nombre]?"
  ↓
Confirmar
  ↓
Sistema: PlanParticipationService.removeParticipation(planId, userId)
- Se elimina su documento en plan_participations
- Se invalidan providers y se cierra/redirige la vista del plan
  ↓
Usuario deja de ver el plan en su lista; ya no es participante
```

**Reglas:** Solo el propio usuario puede borrar su participación (`resource.data.userId == request.auth.uid` en Firestore). El organizador no puede "salir" del plan (debe eliminarlo o transferir ownership si se implementa).

---

### 3. ELIMINAR PARTICIPANTES

#### 3.1 - Eliminar durante Planificación

**Flujo:**
```
Organizador → ParticipantsScreen → “Eliminar participante”
  ↓
Confirmación: "¿Eliminar [nombre] del plan?"
  ↓
Sistema:
- Eliminar de lista de participantes
- Eliminar tracks del participante
- Eliminar de eventos futuros solo suyos
- Mantener eventos con otros participantes
- Recalcular presupuesto (T101)
  ↓
Notificar al participante eliminado (T105)
Notificar a otros participantes
  ↓
Si eventos pagados: Calcular reembolsos (T102)
```

**Impacto:**
- Track del participante: Eliminado
- Eventos futuros solo suyos: Eliminados
- Eventos con otros participantes: Mantenidos, sin su participación
- Presupuesto: Recalculado por persona
- Permisos: Perdidos inmediatamente

#### 3.2 - Eliminar durante Ejecución (Urgente)

**Flujo:**
```
Organizador → ParticipantsScreen → “Eliminar participante” (con confirmación crítica)
  ↓
Modal de advertencia:
"⚠️ ELIMINAR PARTICIPANTE DURANTE PLAN EN CURSO

Se eliminará:
- Eventos futuros solo de [nombre]
- Track del participante
- Asignaciones a eventos

Se mantendrá:
- Eventos ya ejecutados
- Histórico de participación

¿Estás seguro?"

[Sí, eliminar] / [Cancelar]
  ↓
Sistema:
- Eliminar solo eventos futuros
- Mantener eventos pasados/histórico
- Recalcular presupuesto (T101)
- Calcular reembolsos completos (T102)
  ↓
Notificar urgente al participante (T105)
Notificar a otros participantes
  ↓
Actualizar calendario en tiempo real
```

**Restricciones:**
- Solo permitido para organizador/coorganizador
- Requiere confirmación crítica
- No reversible (participante eliminado)
- Reembolsos calculados automáticamente

---

### 4. CAMBIAR ROL DE PARTICIPANTE

#### 4.1 - De Participante a Observador

**Flujo:**
```
Organizador → ParticipantsScreen → menú “Cambiar rol” → Participante → Observador
  ↓
Confirmación:
"¿Cambiar [nombre] a Observador?

Cambios:
- Perderá acceso a eventos futuros
- Ya no podrá editar su parte personal
- Solo lectura del plan

¿Continuar?"
  ↓
Sistema:
- Cambiar rol en participación
- Actualizar permisos
- Eliminar de eventos futuros
- Mantener histórico
  ↓
Notificar al participante (T105)
```

**Impacto:**
- Acceso a eventos futuros: PERDIDO
- Edición de parte personal: BLOQUEADA
- Histórico de eventos pasados: MANTENIDO
- Track: Si tenía, se mantiene (solo lectura)

#### 4.2 - De Observador a Participante

**Flujo:**
```
Organizador → ParticipantsScreen → menú “Cambiar rol” → Observador → Participante
  ↓
Confirmación:
"¿Cambiar [nombre] a Participante?

Cambios:
- Obtendrá acceso a eventos futuros
- Podrá editar su parte personal
- Se asignará a eventos futuros disponibles

¿Continuar?"
  ↓
Sistema:
- Cambiar rol en participación
- Actualizar permisos
- Crear/activar track del participante
- Asignar a eventos futuros (opcional)
  ↓
Notificar al participante (T105)
```

**Impacto:**
- Acceso a eventos futuros: OBTENIDO
- Edición de parte personal: PERMITIDA
- Track: Creado/activado
- Asignación a eventos: Opcional (preguntar o no)

#### 4.3 - A Coorganizador

**Flujo:**
```
Organizador → ParticipantsScreen → menú “Cambiar rol” → Organizador
  ↓
Confirmación:
"¿Añadir [nombre] como Coorganizador?

Nuevos permisos:
- Podrá modificar casi todo el plan
- Podrá añadir/eliminar eventos
- Podrá invitar participantes
- NO podrá eliminar el plan
- NO podrá eliminar al organizador original

¿Continuar?"
  ↓
Sistema:
- Cambiar rol a "Coorganizador"
- Actualizar permisos
- Notificar al participante
```

**Impacto:**
- Permisos ampliados significativamente
- Puede gestionar plan casi como organizador
- Excepciones: Eliminar plan, eliminar organizador original

---

### 5. GESTIÓN DE TIMEZONES

#### 5.1 - Configuración Inicial de Timezone

**Cuándo:** Al añadir participante  
**Valor por defecto:** Timezone del plan o timezone del usuario

**Flujo:**
```
Añadir participante
  ↓
Seleccionar timezone inicial
  ↓
Ejemplo:
- Participante: Madrid (Europe/Madrid)
- Plan: Londres (Europe/London)
- Usar timezone inicial del participante
  ↓
Guardar timezone en PlanParticipation
```

**Campos en PlanParticipation:**
- `personalTimezone`: Timezone actual del participante
- `initialTimezone`: Timezone desde donde empezó el plan

#### 5.2 - Actualizar Timezone durante Ejecución

**Escenario:** Participante viaja y cambia de timezone

**UI soporte:** Desde el perfil del usuario → Seguridad y acceso → **Configurar zona horaria** (actualiza `plan_participations.personalTimezone` para todas las participaciones activas).

**Flujo:**
```
Participante llega a Sydney (antes estaba en Madrid)
  ↓
Sistema detecta cambio de timezone
  ↓
Actualizar `personalTimezone` del participante
  ↓
Recalcular eventos del participante
  ↓
Actualizar visualización en calendario
  ↓
Notificar a otros participantes (opcional)
```

**Implementación actual:** ✅ Ya implementado

**Casos de uso:**
- Vuelos internacionales
- Cambios de hora por DST (horario verano)
- Participantes en diferentes ubicaciones

---

### 6. GRUPOS DE PARTICIPANTES (T123)

#### 6.1 - Crear Grupo

**Flujo:**
```
Usuario → "Mis Grupos" → "Crear grupo"
  ↓
Campos del grupo:
- Nombre: "Familia Ramos"
- Descripción: "Familia directa"
- Icono: 👨‍👩‍👧‍👦
- Color: Azul
  ↓
Añadir miembros:
- Seleccionar de contactos
- Buscar por username
- Invitar por email
- Importar desde plan anterior
  ↓
Guardar grupo
```

**Almacenamiento:**
- Base de datos: `participant_groups`
- Vinculado al usuario propietario
- Lista de `memberUserIds` y `memberEmails`

#### 6.2 - Invitar Grupo Completo

**Flujo:**
```
Crear plan → Añadir participantes → "Invitar grupo"
  ↓
Seleccionar grupo: "Familia Ramos"
  ↓
Mostrar lista de miembros:
- Juan Ramos (aceptará)
- María Ramos (pendiente)
- Pedro Ramos (rechazará)
  ↓
Sistema envía invitaciones a todos
  ↓
Cada miembro gestiona individualmente
```

**Ventajas:**
- Invitar múltiples personas de una vez
- Reutilizar grupos entre planes
- Ahorro de tiempo para el organizador

---

## 🔔 NOTIFICACIONES PARA PARTICIPANTES

**Situaciones que requieren notificación (T105):**

1. ✅ Invitación recibida
2. ✅ Invitación aceptada por otro participante
3. ✅ Participante eliminado del plan
4. ✅ Rol de participante cambiado
5. ✅ Recordatorio de invitación pendiente (>3 días)
6. ✅ Cambio de timezone detectado (opcional)
7. ✅ Plan cambió de estado (Confirmado, En Curso, Finalizado)

**Timing de notificaciones:**
- Inmediato: Invitaciones, eliminar participante, cambio de rol
- Diario: Recordatorios de invitaciones pendientes
- Según cambio de estado: Cambio de estado del plan

---

## 📊 DIAGRAMA DE FLUJO PRINCIPAL

```mermaid
graph TD
    Start([Gestionar Participantes]) --> Add{¿Añadir Participante?}
    
    Add -->|Sí| InvMethod{¿Cómo invitar?}
    InvMethod -->|Email| Email[Añadir email]
    InvMethod -->|Username| Username[Buscar usuario]
    InvMethod -->|Grupo| Group[Seleccionar grupo T123]
    
    Email --> Invite[Enviar invitación T104]
    Username --> Push[Enviar notif push T105]
    Group --> MultiInvite[Enviar múltiples invitaciones]
    
    Invite --> Wait[Esperar confirmación]
    Push --> Wait
    MultiInvite --> Wait
    
    Wait --> Conf{¿Confirmado?}
    Conf -->|Sí| Accepted[Crear track + Asignar eventos]
    Conf -->|No| Rejected[Estado: Rechazado]
    Conf -->|Esperando| Reminder[Recordatorio en 2 días]
    Reminder --> Wait
    
    Accepted --> Continue[Seguir con plan]
    Rejected --> Archive[Archivar o re-enviar]
    
    Add -->|No| Manage{¿Gestionar Existente?}
    
    Manage -->|Cambiar rol| ChangeRole[Seleccionar nuevo rol]
    ChangeRole --> UpdatePerms[Actualizar permisos]
    UpdatePerms --> Notify[Notificar participante T105]
    
    Manage -->|Eliminar| Confirm{¿Confirmación?}
    Confirm -->|Sí| Delete[Eliminar de plan]
    Confirm -->|No| Cancel[Cancelar]
    
    Delete --> Recalc[Recalcular presupuesto T101]
    Recalc --> Reimburse[Calcular reembolsos T102]
    Reimburse --> NotifyOthers[Notificar a otros T105]
    
    Manage -->|Cambiar timezone| UpdateTZ[Actualizar timezone]
    UpdateTZ --> RecalcEvents[Recalcular eventos]
    
    Continue --> End([Finalizar])
    Notify --> End
    NotifyOthers --> End
    Archive --> End
    RecalcEvents --> End
    
    style Email fill:#e1f5ff
    style Username fill:#fff4e1
    style Group fill:#ffe1f5
    style Accepted fill:#e1ffe1
    style Delete fill:#ffe1e1
    style Reimburse fill:#ffeb3b
```

---

## 🎯 MATRIZ DE ACCIONES POR ROL

| Acción | Organizador | Coorganizador | Participante | Observador |
|--------|-------------|---------------|--------------|------------|
| **Invitar participantes** | ✅ Sí | ✅ Sí | ❌ No | ❌ No |
| **Eliminar participantes** | ✅ Sí | ⚠️ Solo no-organizadores | ❌ No | ❌ No |
| **Cambiar rol de participante** | ✅ Sí | ⚠️ Solo a Participante/Observador | ❌ No | ❌ No |
| **Editar parte personal** | ✅ Sí | ✅ Sí | ✅ Sí | ❌ No |
| **Ver plan completo** | ✅ Sí | ✅ Sí | ✅ Sí | ✅ Sí |
| **Aceptar invitación** | N/A | ✅ Sí | ✅ Sí | ✅ Sí |
| **Rechazar invitación** | N/A | ✅ Sí | ✅ Sí | ✅ Sí |
| **Actualizar timezone** | ✅ Sí | ✅ Sí | ✅ Sí | ❌ No |

---

## 🚨 CASOS ESPECIALES

### Máximo de Participantes por Plan

**Límite por defecto:** 50 participantes  
**Configuración:** Organizador puede aumentar hasta 200

**Motivos de límite:**
- Rendimiento de UI (calendario con >50 tracks es caótico)
- Rendimiento de Firestore
- UX: Difícil gestionar >50 personas visualmente

**Si se alcanza el límite:**
- Deshabilitar "Añadir participante"
- Mostrar mensaje: "Límite de participantes alcanzado"
- Opción: "Contactar soporte para aumentar límite"

### Desincronización de Timezones

**Problema:** Participante cambió de timezone pero eventos no se actualizan correctamente

**Solución:**
1. Detectar cambio de timezone
2. Forzar recálculo de TODOS los eventos del participante
3. Actualizar visualización en calendario
4. Notificar al participante "Hemos actualizado tus eventos según tu nueva timezone"

---

## 📋 TAREAS RELACIONADAS

### Pendientes (T104, T117, T120, T123):
- T104: Sistema completo de invitaciones por email/usuario
- T117: Sistema de registro de participación por evento
- T120: Sistema de confirmación de asistencia a eventos
- T123: Sistema de grupos de participantes reutilizables

### Completo ✅:
- Timezone dinámica de participantes
- Tracks de participantes
- Estados de participación básicos

---

## ✅ IMPLEMENTACIÓN ACTUAL

**Estado:** ✅ Core implementado, mejoras pendientes

**Lo que ya funciona:**
- ✅ Añadir participantes en creación de plan
- ✅ Invitación por email con validación (email regex)
- ✅ Rate limiting de invitaciones (T126): 50 invitaciones/día/usuario
- ✅ Remover participantes de un plan
- ✅ Roles básicos (organizador, participante, observador)
- ✅ Timezone inicial y actualización dinámica
- ✅ Tracks de participantes
- ✅ Sistema de participación (PlanParticipation) con Firestore
- ✅ Validación de email antes de invitar
- ✅ Manejo de errores y límites de rate limiting
- ✅ Sistema de registro de participantes por evento - Base (T117):
  - ✅ Modelo EventParticipant y servicio completo
  - ✅ Campo maxParticipants en Event
  - ✅ Botón "Apuntarse/Cancelar" en EventDialog
  - ✅ Lista de participantes apuntados con contador
  - ✅ Indicadores visuales de evento completo
  - ⚠️ Notificaciones cuando alguien se apunta (pendiente)

**Lo que falta (PENDIENTE):**
- ✅ Invitaciones por email completas (T104) - COMPLETADO:
  - ✅ Validación de email y rate limiting implementados
  - ✅ Búsqueda de usuario por email para obtener ID real
  - ✅ Generación de link único con token
  - ✅ Email HTML con botones "Aceptar" / "Rechazar" (Firebase Functions + Gmail SMTP)
  - ✅ Expiración de link (7 días)
  - ✅ Página InvitationPage para procesar links
  - ✅ Gmail SMTP configurado y Cloud Functions desplegadas (ver docs/configuracion/EMAILS_CON_GMAIL_SMTP.md)
- ❌ Invitaciones por username/nickname (T104)
- ✅ Grupos de participantes (T123) - **COMPLETADA**
- ✅ Sistema de confirmación de asistencia - Base (T120 Fase 1):
  - ✅ Campo status en PlanParticipation (pending, accepted, rejected, expired)
  - ✅ Métodos acceptInvitation y rejectInvitation
  - ✅ UI diálogo para aceptar/rechazar invitaciones
  - ✅ Links de invitación por email con token (InvitationPage, acceptInvitationByToken, rejectInvitationByToken)
  - ❌ Notificaciones push de invitaciones
- ❌ Sistema de confirmación de asistencia a eventos (T120 Fase 2)
- ❌ Historial de cambios de participantes
- ❌ Notificaciones automáticas de invitaciones (T105)

---

*Documento de flujo de gestión de participantes*  
*Última actualización: Abril 2026 (revisión sincronizada con código y documentación operativa vigente)*

