# LOGIN_PAGE

## Propósito
Primera página que ve el usuario al entrar en la aplicación. Permite al usuario autenticarse con sus credenciales.

## Layout General
- **Barra superior**: Fondo `AppColorScheme.color2`, texto "Planazoo" en blanco (izquierda), altura 60px
- **Formulario**: Recuadro (Card) centrado en la página con sombra y bordes redondeados
- **Ancho máximo**: 480px para el recuadro del formulario
- **Sin icono de app** en la barra superior

## Elementos de la Interfaz

### Barra Superior
- **Fondo**: `AppColorScheme.color2` (azul/verde principal)
- **Altura**: 60px
- **Texto**: "Planazoo" en blanco, 24px, bold
- **Posición**: Alineado a la izquierda con padding horizontal de 24px

### Logo y Branding (Dentro del recuadro)
- **Logo**: Contenedor circular con gradiente y sombra
  - **Tamaño**: 80x80px
  - **Gradiente**: De `AppColorScheme.color2` a `AppColorScheme.color2.withOpacity(0.8)`
  - **Sombra**: `AppColorScheme.color2.withOpacity(0.3)`, blur: 12px
  - **Icono**: `Icons.calendar_today_rounded`, 40px, blanco
- **Título**: "Iniciar Sesión" - 28px, w700
- **Subtítulo**: "Accede a tu cuenta" - 16px, gris

### Formulario de Login (En recuadro)
- **Contenedor**: Card con elevación 8, bordes redondeados (16px)
- **Ancho máximo**: 480px
- **Padding interno**: 32px
- **Posición**: Centrado en la página
- **Campos de entrada**:
  - **Email**: 
    - Fondo gris claro (`Colors.grey.shade50`)
    - Bordes redondeados (16px)
    - Validación visual en tiempo real
    - Icono que cambia de color según validación
  - **Contraseña**: 
    - Mismo estilo que email
    - Botón de mostrar/ocultar contraseña
    - Validación de longitud mínima
- **Enlaces**:
  - **Reenviar verificación**: TextButton naranja (izquierda)
    - Diálogo modal con email y contraseña
    - Validación de credenciales
    - SnackBar de confirmación al reenviar
  - **Recuperar contraseña**: TextButton azul (derecha)
    - Diálogo modal con validación de formulario
    - SnackBar de confirmación al enviar
- **Botón principal**:
  - **Texto**: "Iniciar Sesión" con icono
  - **Diseño**: Gradiente con sombra, 56px de altura
  - **Animación**: AnimatedSwitcher para estados de carga
- **Navegación**:
  - **Registrarse**: Contenedor con fondo gris claro y borde
    - TextButton con padding mejorado

## Flujo de Navegación
- **Login exitoso** → `PlansListPage` (página principal; ver `lib/app/app.dart`)
- **Registrarse** → `RegisterPage`
- **Recuperar contraseña** → Diálogo modal en la misma página

**Implementación actual:** `lib/features/auth/presentation/pages/login_page.dart`. Usa `AppTheme.darkTheme`, `Scaffold` con `backgroundColor: Colors.grey.shade900`, `SafeArea`, `GoogleFonts.poppins`.

## Estados de la Página
- **Estado inicial**: Campos vacíos, botón habilitado
- **Estado de carga**: Botón deshabilitado durante el proceso de login
- **Estado de error**: Mostrar mensaje de error si las credenciales son incorrectas
- **Estado de éxito**: Redirigir a HomePage

## Validaciones

### **Validación de Email:**
- **Formato**: Regex estricto `^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$`
- **Requerido**: Campo obligatorio
- **Feedback visual**: Icono cambia de color cuando es válido
- **Tiempo real**: Validación mientras el usuario escribe

### **Validación de Contraseña:**
- **Longitud mínima**: 6 caracteres
- **Requerido**: Campo obligatorio
- **Feedback visual**: Icono cambia de color cuando cumple requisitos
- **Tiempo real**: Validación mientras el usuario escribe

### **Validación de Formulario:**
- **Campos requeridos**: Ambos campos son obligatorios
- **Validación completa**: Se ejecuta al enviar el formulario
- **Mensajes de error**: Específicos para cada tipo de error

## 🎨 **Diseño Visual Actualizado**

### **Paleta de Colores:**
- **Fondo principal:** `AppColorScheme.color0` (blanco/crema)
- **Color primario:** `AppColorScheme.color2` (azul/verde principal)
- **Color de texto:** `AppColorScheme.color4` (gris oscuro)
- **Acentos:** Colores del sistema para estados (rojo para errores, verde para éxito)
- **Fondo de campos:** `Colors.grey.shade50` (gris muy claro)
- **Bordes:** `Colors.grey.shade200` (gris claro)

### **Tipografía:**
- **Título principal:** `AppTypography.titleStyle` - 36px, w800, letter-spacing: -0.5
- **Subtítulo:** `AppTypography.bodyStyle` - 16px, regular
- **Campos de entrada:** `AppTypography.bodyStyle` - 16px, regular
- **Botones:** `AppTypography.interactiveStyle` - 16px, w600
- **Enlaces:** `AppTypography.interactiveStyle` - 14-15px, w500-w600

## ✨ **Mejoras Implementadas**

### **UI/UX Mejoradas:**
- **Logo con gradiente y sombra:** Diseño más moderno con efectos visuales
- **Campos de entrada mejorados:** Fondo gris claro, bordes redondeados (16px), validación visual en tiempo real
- **Botón principal con gradiente:** Efecto visual atractivo con sombra y animaciones
- **SnackBars mejorados:** Diseño flotante con bordes redondeados
- **Diálogo de recuperación:** Diseño moderno con validación de formulario

### **Validaciones Mejoradas:**
- **Email:** Regex más estricto para validación de formato
- **Contraseña:** Validación de longitud mínima (6 caracteres)
- **Feedback visual:** Iconos cambian de color según validación
- **Validación en tiempo real:** Los campos se actualizan mientras el usuario escribe

### **Manejo de Errores Mejorado:**
- **Consistencia:** Solo SnackBars flotantes, sin páginas de error
- **Mensajes amigables:** Conversión de errores técnicos a mensajes claros
- **SnackBar mejorado:** Icono de error, botón cerrar, duración de 4 segundos
- **Auto-limpieza:** Estado de error se limpia automáticamente
- **Mensajes específicos:** "Contraseña incorrecta", "Email no encontrado", etc.

### **Funcionalidad de Recuperación:**
- **Diálogo completo:** Validación de email con formulario
- **Integración Firebase:** Envío real de emails de restablecimiento
- **Feedback visual:** SnackBar de éxito con icono
- **Manejo de errores:** Consistente con el resto de la aplicación

### **Verificación de Email Obligatoria:**
- **Control de acceso:** Solo usuarios con email verificado pueden acceder
- **Verificación automática:** Se valida en cada intento de login
- **Cierre automático:** Sesión se cierra si email no está verificado
- **Mensaje claro:** Instrucciones específicas para verificar email

### **Funcionalidad de Reenvío de Verificación:**
- **Botón dedicado:** "Reenviar verificación" en la página de login
- **Diálogo completo:** Formulario con email y contraseña
- **Validación de credenciales:** Solo usuarios válidos pueden reenviar
- **Login temporal:** Autenticación temporal para envío de email
- **Feedback visual:** SnackBar de confirmación con icono

### **Animaciones y Transiciones:**
- **AnimatedSwitcher:** Transición suave entre estados de carga
- **Hover effects:** Mejores estados de interacción
- **Loading states:** Indicadores de carga más elegantes

### **Accesibilidad:**
- **Contraste mejorado:** Mejor legibilidad de textos
- **Tamaños de toque:** Botones y enlaces con área de toque adecuada
- **Navegación por teclado:** Soporte completo para navegación con Tab

## Responsive
- **Desktop**: Formulario centrado con ancho fijo
- **Mobile**: Formulario adaptado al ancho de pantalla
- **Tablet**: Comportamiento intermedio

## Detalles Técnicos de Implementación

### Gestión de Estado
- **Provider**: `AuthNotifier` para manejar el estado de autenticación
- **Estado inicial**: `AuthStatus.initial`
- **Estados de carga**: `AuthStatus.loading` durante el proceso de login
- **Estados de error**: `AuthStatus.error` con mensaje específico
- **Estado de éxito**: `AuthStatus.authenticated` con datos del usuario

### Validaciones Técnicas
- **Email**: 
  - Regex: `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
  - Validación en tiempo real (onChanged)
  - Mensaje de error: "Formato de email inválido"
- **Contraseña**:
  - Longitud mínima: 6 caracteres
  - Campo requerido
  - Mostrar/ocultar contraseña con icono de ojo
- **Validación general**:
  - Ambos campos obligatorios antes de habilitar botón
  - Trim automático de espacios en blanco

### Componentes Técnicos
- **Widget principal**: `LoginPage` (ConsumerStatefulWidget)
- **Controladores**: 
  - `TextEditingController` para email
  - `TextEditingController` para contraseña
- **Formulario**: `Form` con `GlobalKey<FormState>`
- **Campos de texto**: `TextFormField` con validaciones
- **Botón**: `ElevatedButton` con estados dinámicos

### Manejo de Errores
- **Errores de red**: "Error de conexión. Inténtalo de nuevo"
- **Credenciales incorrectas**: "Email o contraseña incorrectos"
- **Usuario no encontrado**: "No existe una cuenta con este email"
- **Contraseña incorrecta**: "Contraseña incorrecta"
- **Demasiados intentos**: "Demasiados intentos. Intenta más tarde"
- **Errores genéricos**: "Error inesperado. Inténtalo de nuevo"

### Estados de la UI
- **Estado inicial**:
  - Campos vacíos
  - Botón habilitado
  - Sin mensajes de error
- **Estado de carga**:
  - Botón deshabilitado
  - Indicador de carga (CircularProgressIndicator)
  - Texto del botón: "Iniciando sesión..."
- **Estado de error**:
  - Botón habilitado
  - Mensaje de error visible
  - Campos mantienen valores
- **Estado de éxito**:
  - Redirección automática a HomePage
  - Limpieza de campos

### Navegación Técnica
- **Login exitoso**: `Navigator.pushReplacement` a HomePage
- **Registrarse**: `Navigator.push` a RegisterPage
- **Recuperar contraseña**: `Navigator.push` a ForgotPasswordPage
- **Redirección automática**: Si ya está autenticado, ir directo a HomePage

### Responsive Design
- **Desktop (≥1200px)**:
  - Ancho del formulario: 400px
  - Padding horizontal: 20px
  - Centrado vertical y horizontal
- **Tablet (768px-1199px)**:
  - Ancho del formulario: 350px
  - Padding horizontal: 16px
- **Mobile (<768px)**:
  - Ancho del formulario: 90% del ancho de pantalla
  - Padding horizontal: 16px
  - Padding vertical: 20px

### Accesibilidad
- **Labels**: Cada campo debe tener un label asociado
- **Focus**: Navegación con teclado (Tab)
- **Screen readers**: Textos descriptivos para lectores de pantalla
- **Contraste**: Cumplir con WCAG 2.1 AA
- **Tamaño de fuente**: Mínimo 16px para evitar zoom en iOS

### Seguridad
- **HTTPS**: Todas las comunicaciones encriptadas
- **Validación cliente**: Validación básica en el frontend
- **Validación servidor**: Validación completa en el backend
- **Rate limiting**: Límite de intentos de login
- **Logs de seguridad**: Registrar intentos de login fallidos

### Performance
- **Lazy loading**: Cargar AuthNotifier solo cuando sea necesario
- **Debounce**: Validación de email con debounce de 300ms
- **Caching**: Cachear estado de autenticación
- **Optimización**: Evitar rebuilds innecesarios

### Testing
- **Unit tests**: Validaciones de email y contraseña
- **Widget tests**: Comportamiento de la UI
- **Integration tests**: Flujo completo de login
- **Error scenarios**: Pruebas de todos los estados de error

### Dependencias
- **flutter_riverpod**: Para gestión de estado
- **firebase_auth**: Para autenticación
- **form_field_validator**: Para validaciones (opcional)
- **go_router**: Para navegación (si se implementa)

### Código de Ejemplo
```dart
class LoginPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColorScheme.color1,
        title: Text('Planazoo', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                validator: _validateEmail,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: _passwordController,
                validator: _validatePassword,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Contraseña'),
              ),
              ElevatedButton(
                onPressed: authState.isLoading ? null : _handleLogin,
                child: authState.isLoading 
                  ? CircularProgressIndicator() 
                  : Text('Vamos a tus planazoos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---
*Última actualización: Febrero 2026*
*Versión: 2.2 - Actualizada con verificación de email obligatoria y funcionalidad de reenvío*