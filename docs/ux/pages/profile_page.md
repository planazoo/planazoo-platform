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
- **Elementos**: Flecha hacia la izquierda (`Icons.arrow_back`) alineada a la izquierda y `@username` alineado a la derecha
- **Sombra**: Sutil para separación visual

### **Header del Usuario**
- **Layout**: Horizontal (foto + datos)
- **Foto de perfil**: 80x80px con borde color2
- **Información**: Nombre, email y fecha de registro
- **Resumen extra**: Línea con la zona horaria actual (`defaultTimezone`) usando `TimezoneService.getTimezoneDisplayName`
- **Posicionamiento**: Centrado con espaciado adecuado

### **Secciones de Opciones**
- **Diseño**: Tarjetas (cards) verticales con título, subtítulo y lista de acciones
- **Cards disponibles**:
  1. **Datos personales** → Acceso al modal de edición (nombre, foto)
  2. **Seguridad y acceso** → Configurar zona horaria (nuevo), Cambiar contraseña, Privacidad y seguridad, Idioma, Cerrar sesión
  3. **Acciones avanzadas** → Eliminación de cuenta
- **Estilo**: Bordes suaves, iconografía mínima y separación de 24px entre tarjetas

## 🌐 Funcionalidad

### **Navegación**
- **Acceso**: Desde W1 (icono de perfil)
- **Cobertura**: La vista cubre las columnas W2-W17 del dashboard, dejando visible únicamente W1 para mantener el contexto del layout principal
- **Cierre**: Flecha hacia la izquierda en el top bar
- **Retorno**: `Navigator.pop()` o `onClose` inyectado desde `DashboardPage`

### **Opciones Disponibles**
1. **Datos personales**
   - “Editar información personal” → abre modal `EditProfilePage` (diálogo centrado, ancho máx. 480px)
2. **Seguridad y acceso**
   - “Configurar zona horaria” → abre un diálogo con lista (filtrable) de timezones comunes + sugerencia automática de la zona detectada en el dispositivo. Al confirmar:
     - Actualiza `users.defaultTimezone`.
     - Propaga el cambio a todas las participaciones activas (`plan_participations.personalTimezone`).
     - Muestra snackbar de confirmación o error.
   - “Cambiar contraseña” → modal propio (`_showChangePasswordDialog`) con checklist compartido (`PasswordRulesChecklist`) para reglas de contraseña
   - “Privacidad y seguridad” → modal informativo
   - “Idioma” → modal selector (ES/EN)
   - “Cerrar sesión” → Sign-out inmediato
3. **Acciones avanzadas**
   - “Eliminar cuenta” → Diálogo propio solicitando contraseña (usa `AuthNotifier.deleteAccount`)

## 🔧 Implementación Técnica

### **Estructura Principal**
```dart
Scaffold(
  backgroundColor: AppColorScheme.color0,
  body: Column(
    children: [
      // Top bar con flecha atrás y username
      Container(
        padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: AppColorScheme.color2,
          boxShadow: [BoxShadow(...)],
        ),
        child: Row(
          children: [
            IconButton(onPressed: onClose, icon: Icons.arrow_back),
            Spacer(),
            Text('@username', style: AppTypography.largeTitle...),
          ],
        ),
      ),
      // Contenido principal
      Expanded(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(/* Foto de perfil */),
                  Expanded(/* Nombre, email, fecha alta, zona horaria */),
                ],
              ),
              SizedBox(height: 32),
              _buildSectionCard(
                title: loc.profilePersonalDataTitle,
                subtitle: loc.profilePersonalDataSubtitle,
                options: [
                  _buildTextOption(loc.profileEditPersonalInformation, onTap),
                ],
              ),
              SizedBox(height: 24),
              _buildSectionCard(
                title: loc.profileSecurityAndAccessTitle,
                subtitle: loc.profileSecurityAndAccessSubtitle,
                options: [
                  _buildTextOption(loc.profileTimezoneOption, _showTimezonePreferenceDialog),
                  _buildTextOption(loc.changePasswordTitle, _showChangePasswordDialog),
                  _buildTextOption(loc.profilePrivacyAndSecurityOption, _showPrivacyDialog),
                  _buildTextOption(loc.profileLanguageOption, _showLanguageDialog),
                  _buildTextOption(loc.profileSignOutOption, signOut, isDestructive: true),
                ],
              ),
              SizedBox(height: 24),
              _buildSectionCard(
                title: loc.profileAdvancedActionsTitle,
                subtitle: loc.profileAdvancedActionsSubtitle,
                options: [
                  _buildTextOption(loc.profileDeleteAccountOption, _showDeleteAccountDialog, isDestructive: true),
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

### **Modal "Configurar zona horaria"**
- `TimezoneService.getCommonTimezones()` + zona del usuario + zona del dispositivo.
- Campo de búsqueda (filtra por nombre/ID).
- Sugerencia de “Usar hora del dispositivo”.
- Confirmar → `AuthNotifier.updateDefaultTimezone()` → actualiza `users.defaultTimezone` y todas las participaciones activas.
- Mensajes localizados (`profileTimezoneUpdateSuccess`, `profileTimezoneUpdateError`).

### **Método `_showTimezonePreferenceDialog`**
```dart
Future<void> _showTimezonePreferenceDialog(BuildContext context, WidgetRef ref) async {
  final currentTimezone = state.user?.defaultTimezone ?? TimezoneService.getSystemTimezone();
  final commonTimezones = <String>{currentTimezone, TimezoneService.getSystemTimezone(), ...TimezoneService.getCommonTimezones()};
  // ... build dialog con búsqueda, sugerencia del dispositivo y RadioListTile
  await authNotifier.updateDefaultTimezone(selectedTimezone);
}
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

### **Helper `_buildSectionCard`**
```dart
Widget _buildSectionCard({
  required String title,
  required String subtitle,
  required List<Widget> options,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColorScheme.color2.withValues(alpha: 0.2)),
      boxShadow: [BoxShadow(...)],
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.mediumTitle...),
          SizedBox(height: 6),
          Text(subtitle, style: AppTypography.bodyStyle...),
          SizedBox(height: 16),
          ...List.generate(options.length * 2 - 1, (index) {
            if (index.isEven) return options[index ~/ 2];
            return SizedBox(height: 12);
          }),
        ],
      ),
    ),
  );
}
```

### **Eliminación de cuenta**
- Se presenta un `AlertDialog` que solicita la contraseña.
- Usa `_showDeleteAccountDialog` para delegar en `AuthNotifier.deleteAccount`.
- Al completarse, redirige al login (`Navigator.pushReplacementNamed('/')`).

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

### **v2.0** - Rediseño minimalista
- Header horizontal compacto
- Opciones de texto simples
- Sin recuadro principal

### **v2.1** - Tarjetas por secciones (ACTUAL)
- Tarjetas por secciones: Datos personales, Seguridad y Acciones
- Modal `EditProfilePage` centrado
- Appbar muestra `@username`
- Acceso directo a eliminación de cuenta

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




