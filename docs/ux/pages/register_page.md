# REGISTER_PAGE

## Propósito
Página para crear una nueva cuenta de usuario. Permite el registro con email, contraseña y nombre, incluyendo verificación de email automática.

## Layout General
- **Barra superior**: Fondo `AppColorScheme.color2`, texto "Planazoo" en blanco (izquierda), altura 60px
- **Formulario**: Recuadro (Card) centrado en la página con sombra y bordes redondeados
- **Ancho máximo**: 480px para el recuadro del formulario
- **Botón de retroceso**: En la barra superior para volver al login

## Elementos de la Interfaz

### Barra Superior
- **Fondo**: `AppColorScheme.color2` (azul/verde principal)
- **Altura**: 60px
- **Texto**: "Planazoo" en blanco, 24px, bold
- **Botón retroceso**: Icono de flecha izquierda, blanco
- **Posición**: Alineado a la izquierda con padding horizontal de 24px

### Logo y Branding (Dentro del recuadro)
- **Logo**: Contenedor circular con gradiente y sombra
  - **Tamaño**: 80x80px
  - **Gradiente**: De `AppColorScheme.color2` a `AppColorScheme.color2.withOpacity(0.8)`
  - **Sombra**: `AppColorScheme.color2.withOpacity(0.3)`, blur: 12px
  - **Icono**: `Icons.person_add_rounded`, 40px, blanco
- **Título**: "Crear Cuenta" - 28px, w700
- **Subtítulo**: "Únete a Planazoo y comienza a planificar" - 16px, gris

### Formulario de Registro (En recuadro)
- **Contenedor**: Card con elevación 8, bordes redondeados (16px)
- **Ancho máximo**: 480px
- **Padding interno**: 32px
- **Posición**: Centrado en la página
- **Campos de entrada**:
  - **Nombre**: 
    - Fondo gris claro (`Colors.grey.shade50`)
    - Bordes redondeados (16px)
    - Validación de longitud mínima
    - Icono `Icons.person_outline`
  - **Email**: 
    - Mismo estilo que nombre
    - Validación de formato de email
    - Icono `Icons.email_outlined`
  - **Contraseña**: 
    - Mismo estilo que email
    - Botón de mostrar/ocultar contraseña
    - Checklist de requisitos con `PasswordRulesChecklist` (8+ caracteres, mayúscula, minúscula, número, símbolo)
    - `autofillHints: [AutofillHints.newPassword]`
    - Icono `Icons.lock_outlined`
  - **Confirmar contraseña**: 
    - Mismo estilo que contraseña
    - Validación de coincidencia con contraseña
    - `autofillHints: [AutofillHints.newPassword]`
    - Icono `Icons.lock_outlined`
- **Checkbox de términos**:
  - Aceptación de términos y condiciones
  - Requerido para continuar
  - Texto: "Acepto los términos y condiciones"
- **Botón principal**:
  - **Texto**: "Crear Cuenta" con icono
  - **Diseño**: Gradiente con sombra, 56px de altura
  - **Animación**: AnimatedSwitcher para estados de carga
  - **Validación**: Solo habilitado si formulario válido y términos aceptados
- **Navegación**:
  - **Iniciar sesión**: Contenedor con fondo gris claro y borde
    - TextButton con padding mejorado
    - Texto: "¿Ya tienes cuenta? Iniciar sesión"

## Flujo de Navegación
- **Registro exitoso** → SnackBar de confirmación → Redirección a LoginPage
- **Iniciar sesión** → LoginPage
- **Botón retroceso** → LoginPage

## Estados de la Página
- **Estado inicial**: Campos vacíos, botón deshabilitado
- **Estado de carga**: Botón deshabilitado durante el proceso de registro
- **Estado de error**: Mostrar mensaje de error si hay problemas
- **Estado de éxito**: Mostrar confirmación y redirigir al login

## Validaciones

### **Validación de Nombre:**
- **Requerido**: Campo obligatorio
- **Longitud mínima**: 2 caracteres
- **Feedback visual**: Icono cambia de color cuando es válido
- **Tiempo real**: Validación mientras el usuario escribe

### **Validación de Email:**
- **Formato**: Regex estricto `^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$`
- **Requerido**: Campo obligatorio
- **Feedback visual**: Icono cambia de color cuando es válido
- **Tiempo real**: Validación mientras el usuario escribe

### **Validación de Contraseña:**
- **Checklist dinámica**: `PasswordRulesChecklist` muestra en tiempo real el cumplimiento de cada regla
- **Reglas**:
  - 8 caracteres mínimo
  - 1 letra minúscula
  - 1 letra mayúscula
  - 1 número
  - 1 carácter especial (!@#…)
- **Requerido**: Campo obligatorio
- **Feedback visual**: Icono y checklist se actualizan mientras escribe
- **Autofill**: Configurado para evitar sugerencias de guardar

### **Validación de Confirmar Contraseña:**
- **Coincidencia**: Debe coincidir con la contraseña
- **Requerido**: Campo obligatorio
- **Feedback visual**: Icono cambia de color cuando coincide
- **Tiempo real**: Validación mientras el usuario escribe

### **Validación de Términos:**
- **Aceptación obligatoria**: Checkbox debe estar marcado
- **Validación de formulario**: Se ejecuta al enviar el formulario

## 🎨 **Diseño Visual**

### **Paleta de Colores:**
- **Fondo principal:** `AppColorScheme.color0` (blanco/crema)
- **Color primario:** `AppColorScheme.color2` (azul/verde principal)
- **Color de texto:** `AppColorScheme.color4` (gris oscuro)
- **Acentos:** Colores del sistema para estados (rojo para errores, verde para éxito)
- **Fondo de campos:** `Colors.grey.shade50` (gris muy claro)
- **Bordes:** `Colors.grey.shade200` (gris claro)
- **Botón reenvío:** `Colors.orange.shade600` (naranja)

### **Tipografía:**
- **Título principal:** `AppTypography.titleStyle` - 28px, w700
- **Subtítulo:** `AppTypography.bodyStyle` - 16px, regular
- **Campos de entrada:** `AppTypography.bodyStyle` - 16px, regular
- **Botones:** `AppTypography.interactiveStyle` - 16px, w600
- **Enlaces:** `AppTypography.interactiveStyle` - 14-15px, w500-w600

## ✨ **Funcionalidades Implementadas**

### **UI/UX Mejoradas:**
- **Logo con gradiente y sombra:** Diseño más moderno con efectos visuales
- **Campos de entrada mejorados:** Fondo gris claro, bordes redondeados (16px), validación visual en tiempo real
- **Botón principal con gradiente:** Efecto visual atractivo con sombra y animaciones
- **SnackBars mejorados:** Diseño flotante con bordes redondeados
- **Layout responsivo:** Adaptado para diferentes tamaños de pantalla

### **Validaciones Mejoradas:**
- **Email:** Regex más estricto para validación de formato
- **Contraseña:** Reglas reforzadas (8+ caracteres, mix de tipos) con checklist compartido
- **Confirmación:** Validación de coincidencia de contraseñas
- **Feedback visual:** Iconos y checklist cambian según validación
- **Validación en tiempo real:** Los campos se actualizan mientras el usuario escribe

### **Seguridad y Privacidad:**
- **Autofill deshabilitado:** No se sugiere guardar contraseñas
- **Verificación de email:** Envío automático de email de verificación
- **Términos obligatorios:** Aceptación requerida para continuar
- **Cierre automático:** Sesión se cierra después del registro

### **Animaciones y Transiciones:**
- **AnimatedSwitcher:** Transición suave entre estados de carga
- **Hover effects:** Mejores estados de interacción
- **Loading states:** Indicadores de carga más elegantes

### **Accesibilidad:**
- **Contraste mejorado:** Mejor legibilidad de textos
- **Tamaños de toque:** Botones y enlaces con área de toque adecuada
- **Navegación por teclado:** Soporte completo para navegación con Tab
- **Validación clara:** Mensajes de error específicos y útiles

## Responsive
- **Desktop**: Formulario centrado con ancho fijo
- **Mobile**: Formulario adaptado al ancho de pantalla
- **Tablet**: Comportamiento intermedio

## Detalles Técnicos de Implementación

### Gestión de Estado
- **Provider**: `AuthNotifier` para manejar el estado de autenticación
- **Estado inicial**: `AuthStatus.initial`
- **Estados**: `initial`, `loading`, `registrationSuccess`, `error`
- **Manejo de errores**: Los errores se capturan en el `AuthNotifier` y se propagan a la UI a través del `AuthState`. La UI escucha estos cambios y muestra `SnackBars` con mensajes amigables.

### Autenticación
- **Firebase Authentication**: Utilizado para el registro y verificación de email.
- **`AuthService`**: Encapsula las interacciones con Firebase Auth.
- **`AuthNotifier`**: Gestiona el estado de autenticación y la lógica de negocio.

### Verificación de Email
- **Envío automático**: Email de verificación se envía inmediatamente después del registro
- **Cierre de sesión**: Usuario se desautentica automáticamente después del registro
- **Redirección**: Usuario es redirigido al login para verificar su email

### Persistencia de Datos
- **Firestore**: Utilizado para almacenar datos adicionales del usuario (`UserModel`).
- **`UserService`**: Encapsula las interacciones con Firestore para los usuarios.

### Estructura de Archivos
- `lib/features/auth/domain/models/user_model.dart`: Modelo de datos del usuario.
- `lib/features/auth/domain/models/auth_state.dart`: Modelo para el estado de autenticación.
- `lib/features/auth/domain/services/auth_service.dart`: Servicio para Firebase Auth.
- `lib/features/auth/domain/services/user_service.dart`: Servicio para Firestore (usuarios).
- `lib/features/auth/presentation/notifiers/auth_notifier.dart`: Notifier para la lógica de autenticación.
- `lib/features/auth/presentation/pages/register_page.dart`: La página de registro.
- `lib/features/auth/presentation/widgets/auth_guard.dart`: Widget para proteger rutas.

### Código de Ejemplo (Fragmentos clave)

```dart
// lib/features/auth/presentation/pages/register_page.dart (Manejo de errores con SnackBar)
ref.listen<AuthState>(authNotifierProvider, (previous, next) {
  if (next.hasError) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getUserFriendlyErrorMessage(next.errorMessage!),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  } else if (next.isRegistrationSuccess) {
    // Mostrar mensaje de éxito y redirigir
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                '¡Cuenta creada! Revisa tu email para verificar tu cuenta.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
    
    // Redirigir a la página de login después de un breve delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }
});

// lib/features/auth/presentation/pages/register_page.dart (_getUserFriendlyErrorMessage)
String _getUserFriendlyErrorMessage(String errorMessage) {
  if (errorMessage.contains('email-already-in-use')) {
    return 'Ya existe una cuenta con este email';
  } else if (errorMessage.contains('weak-password')) {
    return 'La contraseña es muy débil. Usa al menos 6 caracteres';
  } else if (errorMessage.contains('invalid-email')) {
    return 'El formato del email no es válido';
  } else if (errorMessage.contains('operation-not-allowed')) {
    return 'El registro no está permitido en este momento';
  } else if (errorMessage.contains('network-request-failed')) {
    return 'Error de conexión. Verifica tu internet';
  } else if (errorMessage.contains('too-many-requests')) {
    return 'Demasiados intentos. Intenta más tarde';
  } else {
    return 'Error al crear la cuenta. Intenta de nuevo';
  }
}

// lib/features/auth/presentation/notifiers/auth_notifier.dart (Proceso de registro)
Future<void> registerWithEmailAndPassword(String email, String password, {String? displayName}) async {
  try {
    _isRegistering = true; // Marcar que estamos registrando
    state = state.copyWith(status: AuthStatus.loading);
    
    await _authService.registerWithEmailAndPassword(email, password);
    
    // Actualizar displayName si se proporciona
    if (displayName != null && displayName.isNotEmpty) {
      await _authService.updateDisplayName(displayName);
    }
    
    // Crear usuario en Firestore después del registro exitoso
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      final userModel = UserModel.fromFirebaseAuth(currentUser);
      await _userService.createUser(userModel);
      
      // Enviar email de verificación
      await _authService.sendEmailVerification();
      
      // Cerrar sesión inmediatamente después del registro
      await _authService.signOut();
      
      // Emitir estado de éxito de registro
      state = AuthState(
        status: AuthStatus.registrationSuccess,
        user: userModel,
      );
    }
    
    _isRegistering = false; // Marcar que terminamos de registrar
  } catch (e) {
    _isRegistering = false; // Marcar que terminamos de registrar
    state = AuthState(
      status: AuthStatus.error,
      errorMessage: e.toString(),
    );
  }
}
```

---
*Última actualización: [Fecha actual]*
*Versión: 1.0 - Documentación inicial completa*
