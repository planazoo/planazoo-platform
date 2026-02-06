# 🖼️ W5 - Imagen del Plan

## 📋 Descripción General

El widget **W5** es un contenedor circular que muestra la imagen del plan seleccionado en la interfaz de usuario de Planazoo. Está diseñado para proporcionar una representación visual rápida del plan actualmente seleccionado.

## 📍 Ubicación y Dimensiones

- **Posición en el Grid**: C6 (Columna 6), R1 (Fila 1)
- **Dimensiones**: 1 columna de ancho, 1 fila de alto
- **Coordenadas**:
  - `w5X = columnWidth * 5` (Empieza en la columna C6, índice 5)
  - `w5Y = 0.0` (Empieza en la fila R1, índice 0)
  - `w5Width = columnWidth` (Ancho de 1 columna)
  - `w5Height = rowHeight` (Alto de 1 fila)

## 🎨 Diseño Visual (v1.4)

- **Color de Fondo**: Color2 (`AppColorScheme.color2`)
- **Borde**: Sin borde (mismo color que el fondo)
- **Forma**: Rectangular con esquinas cuadradas (sin `borderRadius`)
- **Contenido**: Imagen circular del plan centrada

### Imagen del Plan:
- **Forma**: Circular (`BoxShape.circle`)
- **Tamaño**: 80% del contenedor más pequeño (responsive)
- **Borde**: Color2 de 2px
- **Comportamiento**: 
  - Si hay imagen válida: `CachedNetworkImage` con `BoxFit.cover`
  - Si no hay imagen: Icono genérico `Icons.image`

## 🎯 Funcionalidad

### Estado de Imagen:
1. **Con Imagen**: Muestra la imagen del plan desde Firebase Storage
2. **Sin Imagen**: Muestra icono genérico con color2 tenue
3. **Cargando**: Muestra `CircularProgressIndicator` durante la carga
4. **Error**: Muestra icono genérico si falla la carga

### Integración:
- **Se actualiza automáticamente** cuando se selecciona un plan diferente
- **Responsive**: Se adapta al tamaño del contenedor
- **Caché**: Usa `CachedNetworkImage` para optimización

## 🔧 Implementación Técnica

**Implementación actual:** `lib/pages/pg_dashboard_page.dart`, método `_buildW5`. Imagen vía `ImageService.isValidImageUrl` y `CachedNetworkImage`; fallback a icono. **Última actualización:** Febrero 2026

El widget `_buildW5` se implementa en `lib/pages/pg_dashboard_page.dart`:

```dart
Widget _buildW5(double columnWidth, double rowHeight) {
  // W5: C6 (R1) - Foto del plan seleccionado
  final w5X = columnWidth * 5; // Empieza en la columna C6 (índice 5)
  final w5Y = 0.0; // Empieza en la fila R1 (índice 0)
  final w5Width = columnWidth; // Ancho de 1 columna (C6)
  final w5Height = rowHeight; // Alto de 1 fila (R1)
  
  // Calcular el tamaño del círculo (responsive)
  final circleSize = (w5Width < w5Height ? w5Width : w5Height) * 0.8;
  
  return Positioned(
    left: w5X,
    top: w5Y,
    child: Container(
      width: w5Width,
      height: w5Height,
      decoration: BoxDecoration(
        color: AppColorScheme.color2, // Fondo color2
        // Sin borde - mismo color que el fondo
      ),
      child: Center(
        child: Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColorScheme.color2, width: 2),
          ),
          child: ClipOval(
            child: _buildPlanImage(),
          ),
        ),
      ),
    ),
  );
}
```

### Métodos Auxiliares:

#### `_buildPlanImage()`:
```dart
Widget _buildPlanImage() {
  if (selectedPlan?.imageUrl != null && ImageService.isValidImageUrl(selectedPlan!.imageUrl)) {
    return CachedNetworkImage(
      imageUrl: selectedPlan!.imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColorScheme.color2.withOpacity(0.1),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (context, url, error) => _buildDefaultIcon(),
    );
  } else {
    return _buildDefaultIcon();
  }
}
```

#### `_buildDefaultIcon()`:
```dart
Widget _buildDefaultIcon() {
  return Container(
    color: AppColorScheme.color2.withOpacity(0.1),
    child: Center(
      child: Icon(
        Icons.image,
        color: AppColorScheme.color2.withOpacity(0.5),
        size: 24,
      ),
    ),
  );
}
```

## 📋 Historial de Cambios

- **v1.0**: Creación inicial como contenedor blanco con imagen circular
- **v1.1**: Implementación de `CachedNetworkImage` para optimización
- **v1.2**: Integración con sistema de gestión de imágenes de Firebase Storage
- **v1.3**: Cambio de fondo de blanco a color1 para mejor integración visual
- **v1.4**: Cambio de fondo de color1 a color2 para consistencia con el esquema de colores
- **v1.5**: Eliminación del borde del contenedor (mismo color que el fondo)
- **v1.6**: Selección automática del primer plan al cargar la página y mejora del icono por defecto
  - **Problema resuelto**: W5 no mostraba imagen por defecto porque no había plan seleccionado automáticamente
  - **Solución**: Selección automática del primer plan si no hay ninguno seleccionado
  - **Mejora**: Icono por defecto más visible y apropiado (`Icons.image_outlined`, tamaño 28, mejor contraste)

## 🎨 Consideraciones de UX

### Visual:
- **Contraste**: El fondo color2 proporciona buen contraste con la imagen circular
- **Consistencia**: Mantiene la paleta de colores de la aplicación (color2 para elementos interactivos)
- **Identificación**: Permite identificar rápidamente el plan seleccionado

### Interacción:
- **Feedback Visual**: Muestra estados de carga y error claramente
- **Responsive**: Se adapta a diferentes tamaños de pantalla
- **Performance**: Caché de imágenes para carga rápida

## 🔗 Dependencias

- `CachedNetworkImage`: Para carga optimizada de imágenes
- `ImageService`: Para validación y gestión de URLs de imagen
- `AppColorScheme`: Para colores consistentes
- `selectedPlan`: Estado del plan seleccionado desde el dashboard

## 🚀 Funcionalidades Futuras

Posibles mejoras consideradas:
- **Zoom**: Permitir hacer clic para ver imagen en tamaño completo
- **Animaciones**: Transiciones suaves entre cambios de imagen
- **Filtros**: Aplicar filtros visuales a las imágenes
- **Galería**: Mostrar múltiples imágenes por plan
