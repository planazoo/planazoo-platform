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

### 🎨 [UX](./ux/)
Documentación detallada de experiencia de usuario:
- [Gestión de Imágenes de Plan](./ux/plan_image_management.md)
- [Documentación de Widgets](./ux/pages/) - Componentes individuales

### ✅ [Tareas](./tareas/)
Gestión de tareas del proyecto:
- [Tareas Activas](./tareas/TASKS.md)
- [Tareas Completadas](./tareas/COMPLETED_TASKS.md)

### ⚙️ [Configuración](./configuracion/)
Configuración y contexto del proyecto:
- [Contexto del Proyecto](./configuracion/CONTEXT.md) - Normas y reglas de colaboración
- [Índice del Sistema de Planes](./configuracion/INDICE_SISTEMA_PLANES.md) - Visión general del sistema

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

---

## 📊 Estado del Proyecto

**Última actualización:** Enero 2025

### Completado ✅
- Sistema de tracks
- Gestión básica de eventos
- Timezone dinámica
- Sistema de solapamientos básico
- Estados del plan

### En Progreso ⚠️
- Sistema de validación
- Formularios enriquecidos

### Pendiente ❌
- Invitaciones y notificaciones (Base completada, pendiente push)
- Validación avanzada
- Sistema de alarmas

### Completado Recientemente ✅
- Sistema de presupuesto (T101)
- Sistema de pagos (T102)
- Sistema multi-moneda (T153)
- Visualización de timezones (T100)
- Estadísticas del plan (T113)
- Grupos de participantes (T123)
- Estados del plan con bloqueos funcionales (T109)

---

## 🤝 Contribuir

Cuando trabajes en una nueva funcionalidad:
1. Consulta los flujos relevantes en `docs/flujos/`
2. Sigue la [Guía de UI](./guias/GUIA_UI.md)
3. Actualiza la documentación correspondiente
4. Refiere al [Prompt Base](./guias/PROMPT_BASE.md)

---

*Documentación viva del proyecto Planazoo*

