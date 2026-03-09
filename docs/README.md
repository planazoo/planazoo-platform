# 📚 Documentación - Planazoo Platform

Bienvenido a la documentación completa de Planazoo, la plataforma de planificación de viajes y eventos.

## 📋 Índice de Documentación

### 🎯 [Guías](./guias/)
Guías transversales que aplican a todo el proyecto:
- [Guía de UI](./guias/GUIA_UI.md) - Sistema de diseño, colores, tipografía, componentes
- [Guía de Seguridad](./guias/GUIA_SEGURIDAD.md) - Seguridad, autenticación y protección de datos
- [Guía de Aspectos Legales](./guias/GUIA_ASPECTOS_LEGALES.md) - Términos, privacidad, cookies, GDPR
- [Guía del Patrón Común/Personal](./guias/GUIA_PATRON_COMUN_PERSONAL.md) - Patrón arquitectónico parte común/personal
- [Gestión de Timezones](./guias/GESTION_TIMEZONES.md) - Sistema completo de manejo de zonas horarias
- [Prompt Base](./guias/PROMPT_BASE.md) - Metodología de trabajo del equipo
- [Prompt inicio de chat](./guias/PROMPT_INICIO_CHAT.md) - Texto para pegar al abrir un chat nuevo (cargar contexto)
- [Prompt trabajo autónomo](./guias/PROMPT_TRABAJO_AUTONOMO.md) - Sesión de varias horas (sincronizar docs/código, limpieza)

### 🔄 [Flujos de Proceso](./flujos/)
Flujos específicos del ciclo de vida de la aplicación:
- [CRUD Planes](./flujos/FLUJO_CRUD_PLANES.md) - Crear, leer, actualizar y eliminar planes
- [CRUD Usuarios](./flujos/FLUJO_CRUD_USUARIOS.md) - Registro, login y gestión de usuarios
- [CRUD Eventos](./flujos/FLUJO_CRUD_EVENTOS.md) - Gestión completa de eventos
- [CRUD Alojamientos](./flujos/FLUJO_CRUD_ALOJAMIENTOS.md) - Gestión completa de alojamientos
- [Estados del Plan](./flujos/FLUJO_ESTADOS_PLAN.md) - Transiciones entre estados
- [Gestión de Participantes](./flujos/FLUJO_GESTION_PARTICIPANTES.md) - Invitaciones y gestión
- [Presupuesto y Pagos](./flujos/FLUJO_PRESUPUESTO_PAGOS.md) - Sistema financiero
- [Invitaciones y Notificaciones](./flujos/FLUJO_INVITACIONES_NOTIFICACIONES.md) - Comunicación
- [Validación](./flujos/FLUJO_VALIDACION.md) - Verificación y validación
- [Configuración App](./flujos/FLUJO_CONFIGURACION_APP.md) - Configuración de usuario y app

### 📦 [Producto](./producto/)
Decisiones de producto y especificaciones funcionales:
- [Posición del producto frente a la IA](./producto/POSICION_PRODUCTO_FRENTE_A_IA.md) – Por qué la app no es fácilmente sustituible; IA como aliado, no sustituto
- [Sistema de notificaciones – Especificación](./producto/NOTIFICACIONES_ESPECIFICACION.md) – Lista global (campana), W20 por plan, filtros, badge
- [Plan de codificación – Notificaciones](./producto/NOTIFICACIONES_PLAN_CODIFICACION.md) – Fases e implementación
- [Buzón unificado (evolución)](./producto/BUZON_UNIFICADO_NOTIFICACIONES.md) – Contexto histórico y enlace a la especificación

### 📐 [Especificaciones](./especificaciones/)
Especificaciones técnicas detalladas:
- [Capacidades del Calendario](./especificaciones/CALENDAR_CAPABILITIES.md)
- [Campos de Planes](./especificaciones/PLAN_FORM_FIELDS.md) - Formularios de creación/edición
- [Campos de Eventos](./especificaciones/EVENT_FORM_FIELDS.md) - Incluye implementación técnica
- [Campos de Alojamientos](./especificaciones/ACCOMMODATION_FORM_FIELDS.md)
- [Plan Frankenstein](./especificaciones/FRANKENSTEIN_PLAN_SPEC.md)

### 🏗️ [Arquitectura](./arquitectura/)
Decisiones arquitectónicas y documentación técnica:
- [Decisiones Arquitectónicas](./arquitectura/ARCHITECTURE_DECISIONS.md)
- [Estrategia Multi-Plataforma](./arquitectura/PLATFORM_STRATEGY.md)

### 🎨 [UX](./ux/)
Documentación detallada de experiencia de usuario:
- [Gestión de Imágenes de Plan](./ux/plan_image_management.md)
- [Documentación de Widgets](./ux/pages/) - Componentes individuales

### ✅ [Tareas](./tareas/)
Gestión de tareas del proyecto:
- [Tareas Activas](./tareas/TASKS.md)
- [Tareas Completadas](./tareas/COMPLETED_TASKS.md)

### 🔧 [Admin](./admin/)
- [Lista blanca de administradores](./admin/ADMINS_WHITELIST.md)

### 🎨 [Design](./design/)
- [Paleta de colores de eventos](./design/EVENT_COLOR_PALETTE.md)

### 🧪 [Testing](./testing/)
- **[Inicio pruebas – Día 1](./testing/INICIO_PRUEBAS_DIA1.md)** – Por dónde empezar: arrancar app, usuarios, smoke manual, luego ciclo E2E
- [Sistema de pruebas lógicas (JSON + reportes)](./testing/SISTEMA_PRUEBAS_LOGICAS.md) - Casos por datos, evaluadores, reportes para IA
- [Sistema Nocturno de QA Distribuido](./testing/SISTEMA_QA_NOCTURNO_DISTRIBUIDO.md) - E2E automatizado nocturno (Playwright, multiusuario, RPi/Mac), capas A/B/C, alertas y fases de implementación
- [Plan E2E tres usuarios (manual)](./testing/PLAN_PRUEBAS_E2E_TRES_USUARIOS.md) - Flujo completo UA/UB/UC para pruebas manuales
- [Registro de observaciones de pruebas](./testing/REGISTRO_OBSERVACIONES_PRUEBAS.md) - Notas y observaciones durante pruebas manuales
- [Testing Offline First](./testing/TESTING_OFFLINE_FIRST.md)

### ⚙️ [Configuración](./configuracion/)
Configuración y contexto del proyecto:
- [Contexto del Proyecto](./configuracion/CONTEXT.md) - Normas y reglas de colaboración
- [Índice del Sistema de Planes](./configuracion/INDICE_SISTEMA_PLANES.md) - Visión general del sistema
- [Despliegue Web en Firebase Hosting](./configuracion/DEPLOY_WEB_FIREBASE_HOSTING.md) - Guía completa de despliegue
- [Desplegar índices Firestore](./configuracion/DEPLOY_INDICES_FIRESTORE.md) - Índices compuestos
- [Desplegar reglas Firestore](./configuracion/DESPLEGAR_REGLAS_FIRESTORE.md) - Reglas de seguridad
- [Imágenes de plan (Firebase Storage)](./configuracion/IMAGENES_PLAN_FIREBASE.md) - Bucket, reglas, CORS, código y troubleshooting
- [CORS Storage (subida web)](./configuracion/STORAGE_CORS.md) - Configurar CORS para subir imágenes desde la web
- [Testing Checklist](./configuracion/TESTING_CHECKLIST.md) - Checklist de pruebas (actualizar tras cada tarea)
- [FCM Fase 1](./configuracion/FCM_FASE1_IMPLEMENTACION.md) - Notificaciones push
- [Onboarding IA](./configuracion/ONBOARDING_IA.md) - Contexto para asistentes IA
- [Usuarios de prueba](./configuracion/USUARIOS_PRUEBA.md) - Datos semilla y pruebas
- [Nomenclatura UI](./configuracion/NOMENCLATURA_UI.md) - Páginas, menús y modales
- [Auditoría colecciones Firestore](./configuracion/FIRESTORE_COLLECTIONS_AUDIT.md) - Colecciones en uso y reglas
- [Auditoría de docs](./configuracion/DOCS_AUDIT.md) - Revisión mantener/actualizar/eliminar y referencias
- [Propuesta optimización y sincronización](./PROPUESTA_OPTIMIZACION_Y_SINCRONIZACION.md) - Código y documentación (ítems a implementar)
- [Configurar Google Sign-In](./configuracion/CONFIGURAR_GOOGLE_SIGNIN.md) - Login con Google
- [Migración Mac / iOS](./configuracion/MIGRACION_MAC_PLAYBOOK.md) - Playbook para desarrollo en Mac
- [Evaluación primeras pruebas con familia](./configuracion/EVALUACION_PRIMERAS_PRUEBAS_FAMILIA.md) - Checklist y estado (listo para invitar a familia)
- [Revisión iOS vs Web (TestFlight)](./configuracion/REVISION_IOS_VS_WEB.md) - Diferencias web/iOS, checklist pre-TestFlight

---

## 🚀 Inicio Rápido

### Para Desarrolladores
1. Lee [Contexto del Proyecto](./configuracion/CONTEXT.md) para entender las normas
2. Consulta [Prompt Base](./guias/PROMPT_BASE.md) para la metodología de trabajo
3. Revisa [Guía de UI](./guias/GUIA_UI.md) para componentes, estilos y grid 17×13
4. Explora los [Flujos de Proceso](./flujos/) para entender funcionalidades

### Para Diseñadores
1. Consulta [Guía de UI](./guias/GUIA_UI.md) para el sistema de diseño y grid 17×13
2. Revisa [Documentación UX](./ux/) para entender la interfaz
3. Explora [Especificaciones](./especificaciones/) para detalles técnicos

### Para Product Managers
1. Lee el [Índice del Sistema de Planes](./configuracion/INDICE_SISTEMA_PLANES.md)
2. Revisa [Estado de Tareas](./tareas/TASKS.md)
3. Consulta los flujos en [Flujos de Proceso](./flujos/)

### Para quien ejecuta pruebas
1. Abre [Testing Checklist](./configuracion/TESTING_CHECKLIST.md) (incluye sección "Antes de empezar esta serie de pruebas")
2. Ten a mano [Usuarios de prueba](./configuracion/USUARIOS_PRUEBA.md) (emails, roles, contraseñas)
3. Usa el [Checklist](./configuracion/TESTING_CHECKLIST.md) por área y marca estado (✅/❌/⚠️)
4. Si pruebas offline: [Testing Offline First](./testing/TESTING_OFFLINE_FIRST.md)
5. Para diseño de E2E automatizado nocturno: [Sistema Nocturno de QA Distribuido](./testing/SISTEMA_QA_NOCTURNO_DISTRIBUIDO.md)

---

## 📊 Estado del Proyecto

**Última actualización:** Marzo 2026

### Completado ✅

**Sistema Core:**
- ✅ CRUD completo de planes, eventos y alojamientos
- ✅ Resumen del plan en texto (T193) — card e Info: icono/botón abre diálogo con copiar; pestaña Calendario: "Ver resumen" en barra muestra vista resumen en W31, "Calendario" vuelve
- ✅ Sistema de tracks (multi-participante)
- ✅ Eventos multi-día (hasta 24h) con EventSegment
- ✅ Drag & Drop con magnetismo
- ✅ Parte común + parte personal por participante
- ✅ Detección de eventos solapados (máximo 3 simultáneos)
- ✅ Estados del plan con bloqueos funcionales (T109)
- ✅ Actualización dinámica de duración del plan (T107)

**Sistema de Participantes:**
- ✅ Gestión de participantes con roles (organizer, coorganizer, participant, observer)
- ✅ Sistema de permisos granulares
- ✅ Grupos de participantes (T123)
- ✅ Sistema de invitaciones por email con tokens (T104)
- ✅ Aceptación/rechazo de invitaciones (incl. aceptación vía Cloud Function `markInvitationAccepted` y link con token / `?action=accept`)
- ✅ Validación de permisos y prevención de duplicados

**Sistema de Comunicación:**
- ✅ Sistema de avisos del plan (T105)
- ✅ Sistema de chat bidireccional tipo WhatsApp (T190)
- ✅ Notificaciones in-app
- ✅ Cloud Function para envío de emails de invitación (Gmail SMTP)

**Sistema Financiero:**
- ✅ Sistema de presupuesto (T101) — costes por evento/alojamiento, total, desglose; se ve en **Estadísticas (W17)** → `PlanStatsPage`
- ✅ Sistema de pagos personales (T102) — balances, quién debe a quién, sugerencias de transferencias; se ve en **Pagos (W18)** → `PaymentSummaryPage`
- ✅ Pagos MVP (T217–T221): permisos por rol (organizador/participante), bote común (aportaciones y gastos), aviso legal "no procesamos cobros", misma experiencia web y móvil
- ✅ Sistema multi-moneda (EUR, USD, GBP, JPY) (T153)

**Sistema de Análisis:**
- ✅ Estadísticas del plan (T113)
- ✅ Visualización de timezones (T100)
- ✅ Indicador de días restantes (T112)

**Sistema de Usuarios:**
- ✅ Registro y login (email/password y Google Sign-In)
- ✅ Username obligatorio y único (T163)
- ✅ Gestión de perfil
- ✅ Sistema de administradores (`isAdmin`)
- ✅ Validación unificada de contraseñas (T175)

**Seguridad:**
- ✅ Firestore Security Rules completas (T125)
- ✅ Rate Limiting y protección contra ataques (T126)
- ✅ Sanitización y validación de input (T127)
- ✅ Validación de formularios (T51-T53)

**Timezones:**
- ✅ Soporte de timezones por plan
- ✅ Conversión automática por participante
- ✅ Visualización de timezones en calendario
- ✅ Preferencia de timezone del usuario (T177)
- ✅ Aviso de cambio de timezone del dispositivo (T178)

**UI/UX:**
- ✅ Sistema de diseño consistente
- ✅ Multi-idioma (Español/Inglés) - ~65% completado
- ✅ Responsive design
- ✅ Gestión de imágenes de planes (Firebase Storage)

**Infraestructura:**
- ✅ Optimización de índices de Firestore (T152)
- ✅ Sistema de logging estructurado
- ✅ Gestión de imágenes con Firebase Storage

### En Progreso ⚠️
- Sistema Offline First (T56-T62) - Infraestructura base pendiente
- Formularios enriquecidos - Mejoras incrementales
- Notificaciones push (FCM) - Fase 1 completada, push pendiente

### Pendiente ❌
- Sistema de alarmas y recordatorios
- Validación avanzada (algunas reglas específicas)
- Exportación profesional de planes (PDF/Email)
- Importación desde email
- Sincronización con calendarios externos
- Sistema de agencias de viajes
- Documentos legales (Términos, Privacidad, GDPR completo)

---

## 🤝 Contribuir

Cuando trabajes en una nueva funcionalidad:
1. Consulta los flujos relevantes en `docs/flujos/`
2. Sigue la [Guía de UI](./guias/GUIA_UI.md)
3. Actualiza la documentación correspondiente
4. Refiere al [Prompt Base](./guias/PROMPT_BASE.md)

---

*Documentación viva del proyecto Planazoo*

