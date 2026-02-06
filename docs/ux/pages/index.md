# ÍNDICE DE PÁGINAS - UNP CALENDARIO

## 📋 Descripción General
Este directorio contiene la documentación técnica y funcional de todas las páginas de la aplicación UNP Calendario. Cada documento incluye especificaciones detalladas de diseño, funcionalidad, validaciones y aspectos técnicos de implementación.

---

## 📄 Páginas Documentadas

### 🔐 **login_page.md** - Página de Inicio de Sesión
**Versión:** 2.2 | **Última actualización:** Diciembre 2024

**Descripción:** Primera página que ve el usuario al entrar en la aplicación. Permite la autenticación con credenciales de email y contraseña, incluyendo verificación obligatoria de email y funcionalidades de recuperación de contraseña.

**Características principales:**
- Layout con barra superior y formulario en recuadro centrado
- Validación en tiempo real de email y contraseña
- Verificación obligatoria de email antes del acceso
- Funcionalidad de recuperación de contraseña
- Botón de reenvío de verificación de email
- Manejo de errores con SnackBars flotantes
- Diseño responsivo y accesible

**Tecnologías:** Firebase Auth, Firestore, Riverpod, Flutter

---

### 📝 **register_page.md** - Página de Registro de Usuario
**Versión:** 1.0 | **Última actualización:** Diciembre 2024

**Descripción:** Página para crear una nueva cuenta de usuario. Incluye formulario completo con validaciones, verificación automática de email y redirección al login tras el registro exitoso.

**Características principales:**
- Formulario con 4 campos: nombre, email, contraseña y confirmación
- Validaciones en tiempo real para todos los campos
- Envío automático de email de verificación
- Cierre automático de sesión tras el registro
- Checkbox obligatorio de términos y condiciones
- Prevención de sugerencias de guardar contraseña
- Redirección automática al login con mensaje de confirmación

**Tecnologías:** Firebase Auth, Firestore, Riverpod, Flutter

---

### 👤 **profile_page.md** - Página de Perfil de Usuario
**Versión:** 2.0 | **Última actualización:** Diciembre 2024

**Descripción:** Página para visualizar y gestionar el perfil del usuario autenticado. Muestra información del usuario, foto de perfil, y acceso a opciones de configuración.

**Características principales:**
- Top bar con flecha de retroceso y @username
- Header con foto de perfil (80x80px) y datos del usuario
- Secciones de opciones organizadas en cards
- Acceso a configuración de cuenta y preferencias
- Diseño consistente con login/registro

**Tecnologías:** Firebase Auth, Firestore, Riverpod, Flutter

---

### 🎨 **Widgets del Dashboard (Web)**

#### **w1_sidebar.md** - Barra Lateral Izquierda
**Descripción:** Barra lateral izquierda del dashboard web con navegación y acceso a funcionalidades principales.

#### **w2_logo.md** - Logo de la Aplicación
**Descripción:** Widget del logo de Planazoo en el dashboard.

#### **w3_create_button.md** - Botón de Crear Plan
**Descripción:** Botón para crear nuevos planes desde el dashboard.

#### **w5_plan_image.md** - Imagen del Plan Seleccionado
**Descripción:** Widget circular que muestra la imagen del plan seleccionado (v1.6).

#### **w6_plan_info.md** - Información del Plan
**Descripción:** Widget que muestra información detallada del plan seleccionado.

#### **w13_plan_search.md** - Búsqueda de Planes
**Descripción:** Campo de búsqueda para filtrar planes en el dashboard.

#### **w14_plan_info_access.md** - Acceso a Información del Plan
**Descripción:** Widget de acceso rápido a la información del plan.

#### **w15_calendar_access.md** - Acceso al Calendario
**Descripción:** Widget de acceso rápido al calendario del plan.

#### **w16_participants_access.md** - Acceso a Participantes
**Descripción:** Widget de acceso rápido a la gestión de participantes.

#### **w26_filter_buttons.md** - Botones de Filtro
**Descripción:** Botones para filtrar planes por diferentes criterios.

#### **w27_auxiliary_widget.md** - Widget Auxiliar
**Descripción:** Widget auxiliar del dashboard con funcionalidades adicionales.

#### **w28_plan_list.md** - Lista de Planes
**Descripción:** Lista de planes del usuario con cards interactivas.

#### **w29_advertising_footer.md** - Pie de Publicidad
**Descripción:** Footer con publicidad o información promocional.

#### **w30_app_info_footer.md** - Pie de Información de la App
**Descripción:** Footer con información sobre la aplicación.

---

## 🏗️ **Estructura de Documentación**

Cada documento de página sigue un formato estándar que incluye:

### **Secciones Comunes:**
- **Propósito**: Descripción del objetivo de la página
- **Layout General**: Estructura visual y disposición de elementos
- **Elementos de la Interfaz**: Detalles específicos de cada componente
- **Flujo de Navegación**: Rutas y transiciones entre páginas
- **Estados de la Página**: Diferentes estados y comportamientos
- **Validaciones**: Reglas de validación de formularios
- **Diseño Visual**: Paleta de colores, tipografía y estilos
- **Funcionalidades Implementadas**: Características y mejoras
- **Detalles Técnicos**: Implementación, servicios y arquitectura
- **Código de Ejemplo**: Fragmentos clave de implementación

### **Especificaciones Técnicas:**
- **Colores**: Códigos exactos de la paleta de la aplicación
- **Tipografía**: Tamaños, pesos y estilos de fuente
- **Espaciado**: Padding, márgenes y dimensiones
- **Animaciones**: Transiciones y efectos visuales
- **Responsive**: Comportamiento en diferentes dispositivos

---

## 🎯 **Objetivos de la Documentación**

### **Para Desarrolladores:**
- Guía completa para implementar o modificar páginas
- Especificaciones técnicas detalladas
- Código de ejemplo para referencia
- Patrones de diseño y arquitectura

### **Para Diseñadores:**
- Especificaciones visuales exactas
- Paleta de colores y tipografía
- Layout y disposición de elementos
- Guías de UX y accesibilidad

### **Para QA/Testing:**
- Casos de validación documentados
- Flujos de navegación esperados
- Estados y comportamientos de la aplicación
- Criterios de aceptación claros

---

## 📚 **Convenciones de Documentación**

### **Nomenclatura:**
- **Archivos**: `nombre_pagina.md` (snake_case)
- **Versiones**: Formato `vX.Y` (semver)
- **Actualizaciones**: Fecha en formato `[Mes Año]`

### **Estructura:**
- **Headers**: Nivel 1 para títulos principales
- **Subheaders**: Nivel 2-3 para secciones
- **Código**: Bloques de código con sintaxis highlighting
- **Listas**: Bullet points para características y especificaciones

### **Mantenimiento:**
- **Actualización**: Documentar cambios en cada modificación
- **Versionado**: Incrementar versión en cambios significativos
- **Consistencia**: Mantener formato estándar en todos los documentos

---

## 🔄 **Próximas Páginas a Documentar**

### **Páginas Pendientes:**
- [ ] **main_page.md** - Página principal de la aplicación
- [ ] **edit_profile_page.md** - Página de edición de perfil
- [ ] ~~**account_settings_page.md**~~ - No existe; configuración integrada en perfil/preferencias
- [ ] **calendar_page.md** - Página del calendario principal
- [ ] **create_plan_page.md** - Página de creación de planes
- [ ] **plan_details_page.md** - Página de detalles de plan
- [ ] **event_dialog.md** - Diálogo de creación/edición de eventos

### **Criterios de Prioridad:**
1. **Alta**: Páginas principales de funcionalidad
2. **Media**: Páginas de configuración y perfil
3. **Baja**: Diálogos y componentes auxiliares

---

## 📞 **Contacto y Contribución**

Para sugerencias, correcciones o nuevas páginas a documentar, contactar con el equipo de desarrollo.

**Mantenedor:** Equipo de Desarrollo UNP Calendario  
**Última actualización del índice:** Febrero 2026

---

*Este índice se actualiza automáticamente con cada nueva página documentada.*
