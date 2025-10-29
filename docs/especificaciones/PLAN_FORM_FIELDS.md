# 📋 Campos de Formularios de Planes

> Documento para T121: Revisión y enriquecimiento de formularios de planes

**Estado:** Borrador  
**Última actualización:** Enero 2025

> **Nota:** Los planes son la entidad principal que contiene eventos y alojamientos. Ver `docs/flujos/FLUJO_CRUD_PLANES.md` para el flujo completo.

---

## 🎯 Objetivo

Definir todos los campos necesarios para formularios de creación y edición de planes, basándonos en:
- Campos actuales del código
- Estados del plan (Borrador, Planificando, Confirmado, En Curso, Finalizado, Cancelado)
- Mejores prácticas de planificación de viajes
- Necesidades específicas de coordinación grupal

---

## 📊 Estructura de Navegación

1. [Información Básica](#información-básica)
2. [Fechas y Duración](#fechas-y-duración)
3. [Configuración](#configuración)
4. [Presupuesto](#presupuesto)
5. [Participantes](#participantes)
6. [Metadatos](#metadatos)
7. [Estados y Transiciones](#estados-y-transiciones)

---

## 🔧 Campos Básicos

### Información Básica

#### Nombre del Plan
- **Campo**: `name` (requerido)
- **Tipo**: Texto
- **Validación**: Mínimo 3 caracteres, máximo 100 caracteres
- **Ejemplo**: "Vacaciones Londres 2025"
- **Cuando se edita**: Siempre que el plan no esté "Finalizado" o "Cancelado"
- **Permisos**: Solo organizador/coorganizadores

#### Descripción
- **Campo**: `description` (opcional)
- **Tipo**: Texto multilínea
- **Validación**: Máximo 1000 caracteres
- **Ejemplo**: "Viaje familiar de una semana a Londres con visitas culturales y turísticas"
- **Cuando se edita**: Siempre que el plan no esté "Finalizado" o "Cancelado"
- **Permisos**: Solo organizador/coorganizadores

#### Imagen del Plan
- **Campo**: `imageUrl` (opcional)
- **Tipo**: URL de imagen subida a Firebase Storage
- **Validación**: Máximo 5MB, formatos: JPG, JPEG, PNG, WEBP
- **Ejemplo**: `gs://planazoo-fd.../plans/plan123.jpg`
- **Cuando se edita**: Siempre (excepto estados bloqueados)
- **Permisos**: Solo organizador/coorganizadores
- **Ver**: `docs/ux/plan_image_management.md` para detalles técnicos

---

## 📅 Fechas y Duración

### Fecha de Inicio
- **Campo**: `startDate` (requerido)
- **Tipo**: DateTime
- **Validación**: Debe ser futura o presente, antes de `endDate`
- **Ejemplo**: `2025-11-15 00:00:00`
- **Cuando se edita**: 
  - Antes de "Confirmado": Libre
  - Durante "Confirmado" (<7 días): Requiere confirmación crítica
  - Durante "En Curso": Solo ajustes mayores (ej: extender plan)
  - Después de "Finalizado": No editable
- **Permisos**: Solo organizador/coorganizadores

### Fecha de Fin
- **Campo**: `endDate` (requerido)
- **Tipo**: DateTime
- **Validación**: Posterior a `startDate`
- **Ejemplo**: `2025-11-21 23:59:59`
- **Cuando se edita**: Mismas reglas que `startDate`
- **Permisos**: Solo organizador/coorganizadores

### Duración
- **Campo**: Calculado automáticamente
- **Tipo**: Número de días
- **Cálculo**: `endDate - startDate + 1`
- **Ejemplo**: `7 días`
- **Visualización**: "15/11/2025 - 21/11/2025 (7 días)"
- **No editable**: Se deriva de fechas

### Timezone
- **Campo**: `timezone` (opcional)
- **Tipo**: String (IANA timezone)
- **Default**: Auto-detectada del organizador (ej: "Europe/Madrid")
- **Validación**: Formato IANA válido
- **Ejemplo**: "Europe/London", "America/New_York"
- **Cuando se edita**: Cualquier estado antes de "Finalizado"
- **Permisos**: Solo organizador/coorganizadores

---

## ⚙️ Configuración

### Visibilidad
- **Campo**: `visibility` (requerido)
- **Tipo**: Enum
- **Opciones**: 
  - "private" (Privado) - Solo participantes
  - "public" (Público) - Visible para todos
- **Default**: "private"
- **Cuando se edita**: 
  - Cambio a público: Requiere confirmación crítica
  - Cambio a privado: Notificar a todos los participantes
- **Permisos**: Solo organizador

### Estado del Plan
- **Campo**: `status` (requerido)
- **Tipo**: Enum
- **Opciones**: 
  - "borrador" (Borrador)
  - "planificando" (Planificando)
  - "confirmado" (Confirmado)
  - "en_curso" (En Curso)
  - "finalizado" (Finalizado)
  - "cancelado" (Cancelado)
- **Default**: "borrador"
- **Auto-avance**: 
  - "Borrador" → "Planificando": Cuando cumple validaciones (eventos, participantes)
  - "Planificando" → "Confirmado": Manual del organizador
  - "Confirmado" → "En Curso": Inicio automático en `startDate`
  - "En Curso" → "Finalizado": Final automático en `endDate`
- **Ver**: `docs/flujos/FLUJO_ESTADOS_PLAN.md` para detalles completos

---

## 💰 Presupuesto

### Presupuesto Total
- **Campo**: `budget` (opcional)
- **Tipo**: Double (currency)
- **Validación**: Valor positivo o null
- **Ejemplo**: `3500.00`
- **Formato visual**: "€3,500.00"
- **Cuando se edita**: Siempre (excepto estados bloqueados)
- **Permisos**: Solo organizador/coorganizadores

### Distribución del Presupuesto
- **Campo**: Calculado automáticamente
- **Fuente**: Suma de costes de eventos y alojamientos
- **Visualización**:
  - Presupuesto total: €3,500
  - Distribuido: €2,800
  - Restante: €700
- **No editable**: Se calcula automáticamente

**Ver**: `docs/flujos/FLUJO_PRESUPUESTO_PAGOS.md` para detalles completos

---

## 👥 Participantes

### Organizador
- **Campo**: `userId` (automático)
- **Tipo**: String (userId del creador)
- **Asignación**: Automática al crear el plan
- **Cambio**: Solo mediante asignación de coorganizador
- **Permisos especiales**: Todos los permisos de escritura

### Lista de Participantes
- **Campo**: Viene de colección `plan_participations`
- **Tipo**: Array de referencias a usuarios
- **Gestión**: A través de sistema de invitaciones (T104)
- **Roles disponibles**:
  - **organizer** (Organizador)
  - **coorganizer** (Coorganizador)
  - **participant** (Participante)
  - **observer** (Observador)

### Coorganizadores
- **Asignación**: Por el organizador original
- **Permisos**: Casi todos los permisos del organizador
- **Excepciones**: 
  - No puede eliminar el plan
  - No puede quitar al organizador original

**Ver**: `docs/flujos/FLUJO_GESTION_PARTICIPANTES.md` para detalles completos

---

## 📊 Metadatos

### ID del Plan
- **Campo**: `id` (automático)
- **Tipo**: String
- **Generación**: Auto-generado por Firestore
- **Editable**: No (inmutable)

### UNP ID
- **Campo**: `unpId` (automático)
- **Tipo**: String
- **Propósito**: Identificador interno de UNP Calendar
- **Editable**: No

### Fecha de Creación
- **Campo**: `createdAt` (automático)
- **Tipo**: DateTime (Timestamp)
- **Asignación**: Al crear el plan
- **Editable**: No (inmutable)

### Fecha de Última Actualización
- **Campo**: `updatedAt` (automático)
- **Tipo**: DateTime (Timestamp)
- **Actualización**: Automática en cada cambio
- **Editable**: No (automático)

### Fecha de Guardado
- **Campo**: `savedAt` (automático)
- **Tipo**: DateTime (Timestamp)
- **Actualización**: Último guardado manual del organizador
- **Propósito**: Tracking de actividad del organizador

### Contador de Columnas
- **Campo**: `columnCount` (calculado)
- **Tipo**: Int
- **Cálculo**: Duración en días (`endDate - startDate + 1`)
- **Propósito**: Número de columnas del calendario
- **Editable**: No (se deriva de fechas)

---

## 🔄 Estados y Transiciones

### Estado: Borrador
- **Editable**: Todo
- **Visible para**: Solo creador
- **Eliminable**: Sí
- **Validaciones**: Ninguna
- **Próximo estado**: "Planificando" (automático al cumplir validaciones)

### Estado: Planificando
- **Editable**: Casi todo
- **Visible para**: Solo participantes
- **Eliminable**: Sí
- **Validaciones mínimas**: 
  - Al menos 1 evento
  - Al menos 1 participante además del organizador
  - Fechas coherentes
- **Próximo estado**: "Confirmado" (manual del organizador)

### Estado: Confirmado
- **Editable**: Ajustes menores
- **Visible para**: Todos
- **Eliminable**: Con confirmación crítica
- **Cambios permitidos**:
  - Descripción
  - Imagen
  - Presupuesto
  - Participantes (añadir)
- **Cambios bloqueados**:
  - Nombre del plan
  - Fechas (sin confirmación crítica)
  - Visibilidad a público (sin confirmación crítica)
- **Próximo estado**: "En Curso" (automático en `startDate`)

### Estado: En Curso
- **Editable**: Solo urgencias
- **Visible para**: Todos
- **Eliminable**: No (solo cancelar)
- **Editable**:
  - Añadir eventos urgentes
  - Ajustar presupuesto (registro de gastos extra)
- **Próximo estado**: "Finalizado" (automático en `endDate`)

### Estado: Finalizado
- **Editable**: No
- **Visible para**: Todos
- **Eliminable**: No
- **Acciones permitidas**: Solo lectura, export, archivar

### Estado: Cancelado
- **Editable**: No
- **Visible para**: Todos
- **Eliminable**: No
- **Proceso**: Reembolsos automáticos si hay pagos

**Ver detalles completos**: `docs/flujos/FLUJO_ESTADOS_PLAN.md`

---

## 📝 Validaciones de Creación

### Validaciones Mínimas
Un plan debe tener:
- ✅ Nombre no vacío (3-100 caracteres)
- ✅ Fecha inicio presente/futura
- ✅ Fecha fin posterior a inicio
- ✅ Organizador asignado
- ✅ Duración mínima: 1 día
- ✅ Duración máxima: 365 días

### Validaciones para Estado "Planificando"
Un plan pasa a "Planificando" cuando tiene:
- ✅ Al menos 1 evento creado
- ✅ Al menos 1 participante además del organizador
- ✅ Fechas coherentes con eventos
- ✅ Timezone configurado

### Validaciones para Estado "Confirmado"
El organizador puede marcar "Confirmado" cuando:
- ✅ Al menos 3 eventos en el plan (recomendado)
- ✅ Todos los participantes confirmaron asistencia
- ✅ Presupuesto inicial estimado
- ✅ Al menos 2 participantes total

---

## 🎨 Campos Visuales

### Imagen del Plan
**Gestión**: Ver `docs/ux/plan_image_management.md` para implementación completa

#### Especificaciones
- **Tamaño máximo**: 5MB
- **Formatos**: JPG, JPEG, PNG, WEBP
- **Almacenamiento**: Firebase Storage
- **Ruta**: `gs://.../plans/{planId}/{timestamp}.{ext}`

#### Proceso de carga
1. Usuario selecciona imagen desde galería
2. Validación automática de tamaño y formato
3. Compresión inteligente (si >2MB)
4. Subida a Firebase Storage
5. Actualización de `imageUrl` en Firestore
6. Previsualización inmediata

#### Ubicaciones de visualización
- **Dashboard (W5)**: Foto circular del plan seleccionado
- **Lista de planes (W28)**: Imagen pequeña en card
- **Info del plan**: Imagen grande con opción de edición

---

## 🤔 DECISIONES PENDIENTES

### Técnicas
- [ ] ¿Implementar versiones/backups automáticos del plan?
- [ ] ¿Sistema de historial de cambios para planes?
- [ ] ¿Campos personalizados por tipo de plan (vacaciones, boda, trabajo)?
- [ ] ¿Límite de planes por usuario?

### UX
- [ ] ¿Plantillas predefinidas por categoría?
- [ ] ¿Asistente de creación paso a paso?
- [ ] ¿Búsqueda de planes similares?
- [ ] ¿Exportar plan completo (PDF, Excel, JSON)?

### Datos
- [ ] ¿Integración con Google Calendar para sincronización?
- [ ] ¿Sistema de backup en cloud del usuario?
- [ ] ¿Alertas proactivas de cambios importantes?
- [ ] ¿Estadísticas de uso del plan?

---

*Documento creado para T121 - Revisión y enriquecimiento de formularios*  
*Última actualización: Enero 2025*


