# 🚀 Documento de Onboarding para IA - Planazoo

> **Documento para que la IA se ponga al día del proyecto**: Cuando trabajes en este proyecto por primera vez o después de un tiempo, lee este documento completo antes de empezar.

**Fecha de creación:** Noviembre 2025  
**Proyecto:** Planazoo (unp_calendario)  
**Última actualización:** Noviembre 2025

---

## 📋 INSTRUCCIONES PARA LA IA

**Cuando el usuario te comparta este documento:**

1. **Lee este documento completo** antes de empezar cualquier tarea
2. **Lee los documentos complementarios** mencionados en la sección "Documentos Esenciales"
3. **Revisa el estado actual** del proyecto en la sección "Estado Actual del Proyecto"
4. **Consulta las tareas pendientes** en `docs/tareas/TASKS.md`
5. **Pregunta al usuario** si hay algo que no entiendas o necesites aclarar

**Formato de trabajo:**
- Siempre consultar `docs/configuracion/CONTEXT.md` para normas del proyecto
- Siempre consultar `docs/guias/PROMPT_BASE.md` para metodología de trabajo
- Actualizar documentación cuando implementes cambios
- Pedir confirmación antes de hacer commits o cambios masivos

---

## 🎯 RESUMEN DEL PROYECTO

**Nombre:** Planazoo  
**Tipo:** Aplicación Flutter para planificación de viajes colaborativa  
**Plataformas:** Web, iOS, Android  
**Backend:** Firebase (Firestore, Auth, Functions)  
**Arquitectura:** Offline First (pendiente de implementación completa)

**Características principales:**
- 📅 Calendario inteligente con eventos multi-día
- 🏨 Gestión de alojamientos
- 👥 Sistema de colaboración con roles y permisos
- 🌍 Soporte de timezones
- 💰 Sistema de presupuesto y pagos
- 🔔 Sistema de invitaciones y notificaciones
- 📊 Estadísticas y análisis

---

## 📚 DOCUMENTOS ESENCIALES (LEER EN ESTE ORDEN)

### 1. Documentos de Configuración y Normas
- **`docs/configuracion/CONTEXT.md`** ⭐ **OBLIGATORIO** - Normas del proyecto, flujo de trabajo, reglas de código
- **`docs/guias/PROMPT_BASE.md`** ⭐ **OBLIGATORIO** - Metodología de trabajo, patrones de comunicación
- **`docs/configuracion/TESTING_CHECKLIST.md`** - Checklist exhaustivo de pruebas

### 2. Documentos de Arquitectura
- **`docs/arquitectura/ARCHITECTURE_DECISIONS.md`** - Decisiones arquitectónicas fundamentales
- **`docs/especificaciones/CALENDAR_CAPABILITIES.md`** - Capacidades y reglas del calendario

### 3. Documentos de Flujos
- **`docs/flujos/FLUJO_CRUD_PLANES.md`** - CRUD completo de planes
- **`docs/flujos/FLUJO_CRUD_EVENTOS.md`** - CRUD completo de eventos
- **`docs/flujos/FLUJO_CRUD_ALOJAMIENTOS.md`** - CRUD completo de alojamientos
- **`docs/flujos/FLUJO_INVITACIONES_NOTIFICACIONES.md`** - Sistema de invitaciones
- **`docs/flujos/FLUJO_GESTION_PARTICIPANTES.md`** - Gestión de participantes
- **`docs/flujos/FLUJO_PRESUPUESTO_PAGOS.md`** - Sistema financiero
- **`docs/flujos/FLUJO_CRUD_USUARIOS.md`** - Registro y gestión de usuarios

### 4. Documentos de Tareas
- **`docs/tareas/TASKS.md`** ⭐ **OBLIGATORIO** - Lista de tareas pendientes y completadas
- **`docs/tareas/COMPLETED_TASKS.md`** - Historial de tareas completadas

### 5. Documentos de Guías
- **`docs/guias/GUIA_UI.md`** - Sistema de diseño y componentes UI
- **`docs/guias/GUIA_SEGURIDAD.md`** - Seguridad y validación
- **`docs/guias/GESTION_TIMEZONES.md`** - Sistema de timezones

---

## 📊 ESTADO ACTUAL DEL PROYECTO

### ✅ Funcionalidades Implementadas

**Sistema de Planes:**
- ✅ CRUD completo de planes
- ✅ Estados de planes (borrador, planificando, confirmado, etc.)
- ✅ Gestión de participantes con roles
- ✅ Sistema de permisos granulares
- ✅ Eliminación en cascada de datos relacionados

**Sistema de Eventos:**
- ✅ CRUD completo de eventos
- ✅ Eventos multi-día (hasta 24h)
- ✅ Detección de eventos solapados
- ✅ Drag & Drop con magnetismo
- ✅ Parte común + parte personal por participante

**Sistema de Alojamientos:**
- ✅ CRUD completo de alojamientos
- ✅ Control de check-in/check-out
- ✅ Tipos predefinidos (Hotel, Apartamento, etc.)

**Sistema de Participantes:**
- ✅ Gestión de participantes con roles (organizer, participant, observer)
- ✅ Sistema de invitaciones por email
- ✅ Aceptación/rechazo de invitaciones
- ✅ Validación de permisos

**Sistema de Presupuesto:**
- ✅ Gestión de presupuesto por plan
- ✅ Sistema de pagos personales
- ✅ Multi-moneda (EUR, USD, GBP, JPY, etc.)

**Sistema de Usuarios:**
- ✅ Registro y login (email/password y Google)
- ✅ Gestión de perfil
- ✅ Sistema de administradores (`isAdmin`)

**Sistema de Timezones:**
- ✅ Soporte de timezones por plan
- ✅ Conversión automática por participante
- ✅ Visualización de timezones

**UI/UX:**
- ✅ Sistema de diseño consistente (`AppColors`, `AppTypography`, etc.)
- ✅ Multi-idioma (Español/Inglés) - ~65% completado
- ✅ Responsive design

### ⚠️ Funcionalidades Parcialmente Implementadas

**Sistema Administrativo (T188):**
- ✅ Campo `isAdmin` en usuarios
- ✅ Reglas de Firestore para admins
- ⚠️ Campo `_adminCreatedBy` en algunos modelos (parcial)
- ⏳ Scripts administrativos (pendiente)
- ⏳ Pantalla administrativa en app (pendiente)

**Sistema de Invitaciones:**
- ✅ Invitaciones por email con token
- ✅ Aceptación/rechazo de invitaciones
- ✅ Validación y prevención de duplicados
- ⚠️ Cloud Function para envío de emails (pendiente)
- ⏳ Invitaciones por username (pendiente)
- ⏳ Invitaciones a grupos (pendiente)

**Sistema de Notificaciones:**
- ✅ Base de sistema de avisos
- ⏳ Notificaciones push (Firebase Cloud Messaging) - pendiente
- ⏳ Sistema de alarmas - pendiente

### ❌ Funcionalidades Pendientes

**Infraestructura Offline (GRUPO 4 - T56-T62):**
- ⏳ Base de datos local (SQLite/Hive)
- ⏳ Cache de eventos offline
- ⏳ Cola de sincronización
- ⏳ Indicadores de estado offline
- ⏳ Resolución de conflictos
- ⏳ Testing exhaustivo offline

**Funcionalidades Avanzadas (GRUPO 6 - T77-T90):**
- ⏳ Exportación profesional de planes (PDF/Email)
- ⏳ Importación desde email
- ⏳ Sincronización con calendarios externos
- ⏳ Sistema de agencias de viajes
- ⏳ Y más...

**Seguridad Avanzada (T166-T172):**
- ⏳ Rate limiting avanzado
- ⏳ Auditoría de acciones
- ⏳ Gestión de cookies y tracking
- ⏳ Documentos legales (Términos, Privacidad)

---

## 🔧 CONFIGURACIÓN TÉCNICA

### Stack Tecnológico
- **Framework:** Flutter (última versión estable)
- **Lenguaje:** Dart
- **Estado:** Riverpod
- **Backend:** Firebase (Firestore, Auth, Functions, Storage)
- **Base de datos local:** Pendiente (SQLite/Hive para Offline First)
- **Autenticación:** Firebase Auth (email/password, Google Sign-In)

### Estructura del Proyecto
```
lib/
├── features/          # Features principales
│   ├── auth/         # Autenticación
│   ├── calendar/     # Calendario, eventos, planes
│   └── payments/     # Presupuesto y pagos
├── shared/           # Código compartido
│   ├── models/      # Modelos compartidos
│   ├── services/     # Servicios compartidos
│   └── widgets/     # Widgets compartidos
├── pages/            # Páginas principales
├── widgets/          # Widgets de UI
└── l10n/             # Localización (español/inglés)
```

### Configuración de Desarrollo
- **Ruta Flutter (Windows):** `C:\Users\cclaraso\Downloads\flutter`
- **Ruta Flutter (Mac):** `~/development/flutter` (configurar según instalación)
- **Repositorio Git:** GitHub (clonar desde repositorio remoto)

### Firebase
- **Proyecto:** Configurado en Firebase Console
- **Colecciones principales:**
  - `plans` - Planes
  - `events` - Eventos
  - `plan_participations` - Participaciones en planes
  - `plan_invitations` - Invitaciones a planes
  - `users` - Usuarios
  - `plan_permissions` - Permisos granulares
  - Y más...

---

## 📋 REGLAS Y NORMAS IMPORTANTES

### Comunicación
- ✅ **Idioma:** Castellano para comunicación y documentación
- ✅ **Código:** Inglés para código, variables, métodos, comentarios técnicos
- ✅ **No mostrar código en propuestas:** Aplicar directamente y describir a alto nivel

### Código
- ✅ **Multi-idioma obligatorio:** NUNCA hardcodear textos en español, SIEMPRE usar `AppLocalizations`
- ✅ **Limpieza:** Eliminar `print()`, debugs y código temporal al cerrar tareas
- ✅ **Linting:** Revisar lints tras cada cambio
- ✅ **Consistencia UI:** Usar siempre `AppColors`, `AppTypography`, `AppSpacing`, `AppIcons`

### Git
- ⚠️ **NUNCA hacer push sin confirmación explícita del usuario**
- ✅ Commits atómicos y descriptivos (prefijo con código de tarea si aplica)
- ✅ No hacer commits masivos sin confirmación

### Documentación
- ✅ Actualizar `TESTING_CHECKLIST.md` tras completar tareas
- ✅ Actualizar flujos en `docs/flujos/` cuando se implementen funcionalidades
- ✅ Actualizar `TASKS.md` al completar/crear tareas
- ✅ Mover tareas completadas a `COMPLETED_TASKS.md`

### Testing
- ✅ Probar funcionalidades antes de considerar completas
- ✅ Actualizar Plan Frankenstein si se añaden nuevas funcionalidades al calendario
- ✅ Seguir checklist de pruebas manuales rápidas

---

## 🚀 PRIMEROS PASOS AL TRABAJAR EN EL PROYECTO

### 1. Verificar Entorno
```bash
# Verificar Flutter
flutter doctor -v

# Verificar dependencias
flutter pub get

# Verificar análisis
flutter analyze
```

### 2. Revisar Estado del Repositorio
```bash
git status
git branch
git log --oneline -10
```

### 3. Consultar Tareas Pendientes
- Abrir `docs/tareas/TASKS.md`
- Revisar tareas en progreso
- Identificar siguiente tarea a trabajar

### 4. Leer Documentación Relevante
- Si trabajas en una feature específica, leer el flujo correspondiente en `docs/flujos/`
- Consultar `docs/configuracion/CONTEXT.md` para normas
- Consultar `docs/guias/PROMPT_BASE.md` para metodología

### 5. Preguntar al Usuario
- Si hay dudas sobre prioridades
- Si hay ambigüedades en los requisitos
- Si necesitas aclaraciones sobre el estado actual

---

## 📝 NOTAS IMPORTANTES

### Estado de Migración a Mac
- ⚠️ **Pendiente:** El proyecto está actualmente en Windows
- 📋 **Ver:** `docs/configuracion/MIGRACION_MAC_PLAYBOOK.md` para instrucciones de migración

### Sistema de Tareas
- **Siguiente código:** T190
- **Total:** 146 tareas documentadas (70 completadas, 76 pendientes)
- **Ver:** `docs/tareas/TASKS.md` para lista completa

### Sistema Multi-idioma
- **Estado:** ~65% completado (T158)
- **Idiomas:** Español (completo), Inglés (parcial)
- **Regla:** NUNCA hardcodear textos, SIEMPRE usar `AppLocalizations`

### Offline First
- **Estado:** Pendiente de implementación (T56-T62)
- **Prioridad:** Alta después de migración a Mac
- **Ver:** `docs/arquitectura/ARCHITECTURE_DECISIONS.md` - Sección "Offline First"

---

## 🔄 ACTUALIZACIÓN DE ESTE DOCUMENTO

Este documento debe actualizarse cuando:
- Se completen funcionalidades importantes
- Se añadan nuevas características principales
- Cambie el estado del proyecto significativamente
- Se migre a Mac (actualizar configuración técnica)

**Última actualización:** Noviembre 2025  
**Próxima revisión:** Después de migración a Mac

---

## ✅ CHECKLIST PARA LA IA

Antes de empezar a trabajar, verifica:

- [ ] He leído este documento completo
- [ ] He leído `docs/configuracion/CONTEXT.md`
- [ ] He leído `docs/guias/PROMPT_BASE.md`
- [ ] He revisado `docs/tareas/TASKS.md` para ver tareas pendientes
- [ ] He verificado el estado del repositorio Git
- [ ] He entendido las normas del proyecto
- [ ] He preguntado al usuario si hay algo que no entiendo

**Si todo está claro, ¡puedes empezar a trabajar!** 🚀

---

**Fin del Documento de Onboarding**

