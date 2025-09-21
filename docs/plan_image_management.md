# 📸 Plan Image Management System

## 📋 **Descripción General**

Sistema completo de gestión de imágenes para planes en UNP Calendario, implementado con Firebase Storage y validaciones robustas.

## 🚀 **Características Principales**

### ✨ **Funcionalidades Implementadas**
- **Selección de imágenes** desde galería del dispositivo
- **Validación automática** de tamaño y formato
- **Compresión inteligente** para optimizar rendimiento
- **Almacenamiento seguro** en Firebase Storage
- **Previsualización en tiempo real** durante selección
- **Gestión de imágenes** en múltiples ubicaciones

### 🎯 **Ubicaciones de Visualización**
- **W5**: Foto circular del plan seleccionado
- **W28**: Lista de planes con imágenes pequeñas
- **Info del Plan**: Imagen grande con opción de edición

## 🔧 **Implementación Técnica**

### **Dependencias Añadidas**
```yaml
dependencies:
  firebase_storage: ^12.0.0
  image_picker: ^1.0.4
  cached_network_image: ^3.3.0
```

### **Servicios Creados**

#### **ImageService** (`lib/features/calendar/domain/services/image_service.dart`)
- **`pickImageFromGallery()`**: Selección de imagen desde galería
- **`validateImage()`**: Validación de tamaño y formato
- **`uploadPlanImage()`**: Subida a Firebase Storage
- **`deletePlanImage()`**: Eliminación de imagen
- **`compressImage()`**: Compresión automática
- **`isValidImageUrl()`**: Validación de URLs

### **Modelo Actualizado**

#### **Plan Model** (`lib/features/calendar/domain/models/plan.dart`)
```dart
class Plan {
  // ... campos existentes
  final String? imageUrl; // NUEVO CAMPO
  
  // Métodos actualizados:
  // - fromFirestore() incluye imageUrl
  // - toFirestore() incluye imageUrl
  // - copyWith() incluye imageUrl
  // - operator == incluye imageUrl
  // - hashCode incluye imageUrl
}
```

## 📐 **Especificaciones Técnicas**

### **Validaciones de Imagen**
- **Tamaño máximo**: 2MB
- **Formatos permitidos**: JPG, JPEG, PNG, WEBP
- **Dimensiones máximas**: 2048x2048px
- **Compresión automática**: 85% de calidad

### **Estructura de Firebase Storage**
```
plan_images/
├── {planId}_{timestamp}.jpg
├── {planId}_{timestamp}.png
└── {planId}_{timestamp}.webp
```

### **Nomenclatura de Archivos**
- **Formato**: `{planId}_{timestamp}.{extension}`
- **Ejemplo**: `plan123_1703123456789.jpg`
- **Ventajas**: Únicos, ordenables, asociados al plan

## 🎨 **Componentes UI Actualizados**

### **1. Formulario de Crear Plan** (`_CreatePlanModal`)
- **Selector de imagen** opcional
- **Previsualización** de imagen seleccionada
- **Validación en tiempo real**
- **Botón para quitar imagen**

```dart
Widget _buildImageSelector() {
  // Selector con previsualización
  // Validación automática
  // Botón de quitar imagen
}
```

### **2. W5 - Foto del Plan** (`_buildW5`)
- **Círculo responsive** que se adapta al tamaño
- **Imagen desde Firebase Storage**
- **Icono genérico** si no hay imagen
- **Carga con indicador** de progreso

```dart
Widget _buildPlanImage() {
  // CachedNetworkImage con fallback
  // Tamaño responsive
  // Indicador de carga
}
```

### **3. Info del Plan** (`PlanDataScreen`)
- **Imagen grande** (200px altura)
- **Botones de edición** (Añadir/Cambiar)
- **Gestión completa** de imagen
- **Eliminación automática** al borrar plan

```dart
Widget _buildPlanImageSection() {
  // Sección completa de gestión
  // Botones de acción
  // Previsualización grande
}
```

### **4. Lista de Planes** (`PlanCardWidget`)
- **Imagen pequeña** (50x50px)
- **Diseño horizontal** optimizado
- **Información compacta**
- **Indicador de selección**

```dart
Widget _buildPlanImage() {
  // Imagen pequeña en lista
  // Fallback a icono genérico
  // Carga optimizada
}
```

## 🔄 **Flujo de Trabajo**

### **Crear Plan con Imagen**
1. **Usuario selecciona** imagen en formulario
2. **Sistema valida** tamaño y formato
3. **Plan se crea** temporalmente para obtener ID
4. **Imagen se sube** a Firebase Storage
5. **Plan se actualiza** con URL de imagen
6. **Participaciones se crean**

### **Editar Imagen de Plan**
1. **Usuario hace clic** en "Cambiar imagen"
2. **Sistema abre** selector de galería
3. **Nueva imagen se valida** y sube
4. **Imagen anterior se elimina** (si existe)
5. **Plan se actualiza** con nueva URL

### **Eliminar Plan**
1. **Imagen se elimina** de Firebase Storage
2. **Eventos se eliminan** de Firestore
3. **Plan se elimina** de Firestore
4. **Participaciones se eliminan** automáticamente

## 🛡️ **Seguridad y Validaciones**

### **Validaciones del Cliente**
- **Tamaño de archivo** antes de subir
- **Formato de archivo** permitido
- **Dimensiones máximas** para evitar problemas de memoria
- **URLs válidas** antes de mostrar imagen

### **Firebase Storage Rules** (Recomendadas)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /plan_images/{allPaths=**} {
      allow read: if true; // Público para lectura
      allow write: if request.auth != null; // Solo usuarios autenticados
    }
  }
}
```

## 📊 **Rendimiento y Optimización**

### **Caching**
- **CachedNetworkImage** para imágenes de red
- **Cache automático** en dispositivo
- **Placeholder** durante carga
- **Error handling** con fallback

### **Compresión**
- **Reducción automática** de calidad (85%)
- **Resize automático** a 2048x2048px máximo
- **Formato optimizado** según tipo de imagen

### **Lazy Loading**
- **Carga bajo demanda** en listas
- **Placeholder** mientras carga
- **Error recovery** automático

## 🧪 **Testing y Validación**

### **Casos de Prueba**
- ✅ **Selección de imagen válida**
- ✅ **Validación de tamaño excesivo**
- ✅ **Validación de formato incorrecto**
- ✅ **Subida exitosa a Firebase**
- ✅ **Eliminación de imagen**
- ✅ **Fallback a icono genérico**
- ✅ **Carga en múltiples ubicaciones**

### **Escenarios de Error**
- ✅ **Sin conexión a internet**
- ✅ **Firebase Storage no disponible**
- ✅ **Imagen corrupta o dañada**
- ✅ **Permisos de galería denegados**

## 📱 **Experiencia de Usuario**

### **Feedback Visual**
- **Indicadores de carga** durante subida
- **Mensajes de éxito/error** claros
- **Previsualización inmediata** de selección
- **Estados de carga** en todas las imágenes

### **Accesibilidad**
- **Botones con tamaño adecuado** (48x48px mínimo)
- **Contraste adecuado** en iconos
- **Texto descriptivo** en botones
- **Feedback táctil** en interacciones

## 🔮 **Funcionalidades Futuras**

### **Mejoras Planeadas**
- **Compresión avanzada** con flutter_image_compress
- **Múltiples formatos** de salida (WebP automático)
- **Redimensionamiento inteligente** según ubicación
- **Batch upload** para múltiples imágenes
- **Integración con cámara** (no solo galería)

### **Optimizaciones**
- **CDN integration** para carga más rápida
- **Progressive loading** para imágenes grandes
- **Thumbnail generation** automático
- **Metadata extraction** (EXIF, etc.)

## 📝 **Notas de Desarrollo**

### **Consideraciones Técnicas**
- **Firebase Storage** requiere configuración de reglas
- **Permisos de galería** necesarios en dispositivos
- **Tamaño de bundle** aumentado por dependencias
- **Manejo de estados** complejo en múltiples widgets

### **Limitaciones Actuales**
- **Solo galería** (no cámara)
- **Una imagen por plan** (no múltiples)
- **Sin edición de imagen** (crop, filters, etc.)
- **Compresión básica** (no avanzada)

---

**Última actualización**: Diciembre 2024  
**Versión**: 1.0  
**Estado**: Implementación completa funcional
