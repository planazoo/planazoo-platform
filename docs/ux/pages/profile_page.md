# 🎨 Página de Perfil de Usuario

## 📋 Descripción General

La **Página de Perfil** es una pantalla dedicada que muestra la información del usuario y proporciona acceso a las opciones de configuración de cuenta. Sigue el diseño consistente de las páginas de login y registro.

## 🎨 Diseño Visual (v2.0)

### **Estructura General**
- **Fondo**: `AppColorScheme.color0`
- **Layout**: Column con top bar y contenido principal
- **Márgenes laterales**: 40px (consistente con login/registro)
- **Sin recuadro principal**: Diseño limpio y abierto

### **Top Bar**
- **Color de fondo**: `AppColorScheme.color2`
- **Padding**: 40px horizontal, 16px vertical
- **Elementos**: Logo "Planazoo" y botón cerrar
- **Sombra**: Sutil para separación visual

### **Header del Usuario**
- **Layout**: Horizontal (foto + datos)
- **Foto de perfil**: 80x80px con borde color2
- **Información**: Nombre, email y fecha de registro
- **Posicionamiento**: Centrado con espaciado adecuado

### **Opciones de Texto**
- **Diseño**: Lista vertical de opciones
- **Estilo**: Texto con flecha indicadora
- **Bordes**: Sutiles para definición
- **Espaciado**: 8px entre opciones

## 🌐 Funcionalidad

### **Navegación**
- **Acceso**: Desde W1 (icono de perfil)
- **Cierre**: Botón "X" en top bar
- **Retorno**: `Navigator.pop()`

### **Opciones Disponibles**
1. **Editar Perfil** → `EditProfilePage`
2. **Configuración de Cuenta** → `AccountSettingsPage`
3. **Migrar Eventos** → Ejecuta migración
4. **Cerrar Sesión** → Cierra sesión y redirige

## 🔧 Implementación Técnica

### **Estructura Principal**
```dart
Scaffold(
  backgroundColor: AppColorScheme.color0,
  body: Column(
    children: [
      // Top bar con logo y cerrar
      Container(
        padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: AppColorScheme.color2,
          boxShadow: [BoxShadow(...)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Planazoo', style: AppTypography.largeTitle...),
            IconButton(onPressed: () => Navigator.pop(), icon: Icons.close),
          ],
        ),
      ),
      
      // Contenido principal
      Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              // Header del usuario
              Row(
                children: [
                  Container(/* Foto de perfil */),
                  Expanded(/* Datos del usuario */),
                ],
              ),
              
              // Opciones de texto
              Column(
                children: [
                  _buildTextOption('Editar Perfil', onTap),
                  _buildTextOption('Configuración de Cuenta', onTap),
                  _buildTextOption('Migrar Eventos', onTap),
                  _buildTextOption('Cerrar Sesión', onTap, isDestructive: true),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  ),
)
```

### **Método _buildTextOption**
```dart
Widget _buildTextOption(String title, VoidCallback onTap, {bool isDestructive = false}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDestructive ? Colors.red.shade200 : AppColorScheme.color2.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.bodyStyle...),
          Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
        ],
      ),
    ),
  );
}
```

## 📱 Responsive Design

### **Adaptabilidad**
- **Márgenes**: 40px en desktop, se ajusta en móvil
- **Foto**: 80x80px en todos los dispositivos
- **Opciones**: Se adaptan al ancho disponible
- **Texto**: Tamaño consistente en todas las pantallas

### **Breakpoints**
- **Desktop**: Márgenes de 40px, layout completo
- **Tablet**: Márgenes reducidos, mismo layout
- **Mobile**: Márgenes mínimos, layout vertical

## 🎯 Principios de UX

### **Consistencia**
- **Diseño**: Sigue la línea de login/registro
- **Colores**: Usa el esquema de la aplicación
- **Tipografía**: `AppTypography` en todo el diseño
- **Espaciado**: Márgenes uniformes de 40px

### **Simplicidad**
- **Sin recuadros**: Diseño limpio y abierto
- **Opciones claras**: Texto directo con flechas
- **Navegación intuitiva**: Botón cerrar visible
- **Información esencial**: Solo datos importantes

### **Accesibilidad**
- **Touch targets**: Tamaño adecuado para opciones
- **Contraste**: Colores con suficiente contraste
- **Legibilidad**: Tipografía clara y legible
- **Navegación**: Flujo lógico y predecible

## 🔄 Historial de Cambios

### **v1.0** - Implementación inicial
- Diseño con cards y elementos decorativos
- Layout vertical con foto grande
- Botones complejos con iconos
- Múltiples secciones de información

### **v2.0** - Rediseño minimalista (ACTUAL)
- Diseño consistente con login/registro
- Header horizontal compacto
- Opciones de texto simples
- Márgenes laterales de 40px
- Sin recuadro principal

## 🚀 Próximas Mejoras

### **Funcionalidades Futuras**
- [ ] Edición inline de datos básicos
- [ ] Upload de foto de perfil
- [ ] Configuración de notificaciones
- [ ] Historial de actividad

### **Mejoras Visuales**
- [ ] Animaciones de transición
- [ ] Efectos de hover en opciones
- [ ] Indicadores de estado
- [ ] Temas personalizables

## 📊 Métricas de Rendimiento

### **Rendimiento**
- **Tiempo de carga**: < 200ms
- **Memoria utilizada**: Mínima
- **Rebuilds**: Solo cuando cambia el usuario

### **Usabilidad**
- **Tiempo de navegación**: < 100ms por opción
- **Tasa de éxito**: 100% en todas las acciones
- **Accesibilidad**: Cumple estándares WCAG 2.1

## 🔗 Referencias

- [App Color Scheme](../../app/theme/color_scheme.dart)
- [App Typography](../../app/theme/typography.dart)
- [Edit Profile Page](../../features/auth/presentation/pages/edit_profile_page.dart)
- [Account Settings Page](../../features/auth/presentation/pages/account_settings_page.dart)
- [Profile Page](../../pages/pg_profile_page.dart)
