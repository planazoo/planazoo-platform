# 🔔 FCM Fase 1: Implementación Básica

> **Fecha:** Enero 2025  
> **Última actualización:** Abril 2026  
> **Estado:** ✅ Infra base completada (operación en validación iOS real)  
> **Objetivo:** Documentar la base técnica FCM (arquitectura y piezas).  
> **Checklist operativa A1/A2:** `docs/configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md` (fuente de verdad para pruebas).

---

## 📋 Alcance de este documento

Este documento describe la **arquitectura técnica** de FCM (servicio, provider, bootstrap, Cloud Function, reglas).

Para ejecutar pruebas manuales y cerrar el punto 109:
- usar `CHECKLIST_IOS_PUSH_DEEPLINKS.md` (sección A1 y ejecución guiada),
- registrar estado en `docs/testing/ACCIONES_PENDIENTES_APP.md`.

---

## 📋 Resumen técnico

Se ha implementado la infraestructura básica de FCM que permite:
- ✅ Obtener y registrar tokens FCM de dispositivos
- ✅ Guardar tokens en Firestore (`users/{userId}/fcmTokens/{tokenId}`)
- ✅ Actualizar tokens automáticamente cuando cambian
- ✅ Enviar notificaciones push desde Cloud Functions
- ✅ Manejar notificaciones recibidas (primer plano, segundo plano, terminada)

---

## 🏗️ Componentes Implementados

### 1. **Servicio FCM (`lib/shared/services/fcm_service.dart`)**

Servicio centralizado para gestionar FCM:

**Funcionalidades:**
- `initialize(userId)`: Inicializa FCM y solicita permisos (iOS/Android)
- `_getAndSaveToken()`: Obtiene el token FCM y lo guarda en Firestore
- `_saveTokenToFirestore(token)`: Guarda/actualiza el token en Firestore
- `cleanup()`: Limpia tokens cuando el usuario cierra sesión
- `getInitialMessage()`: Maneja notificaciones que abrieron la app desde estado terminado

**Estructura de datos en Firestore:**
```
users/{userId}/fcmTokens/{tokenId}
  - token: string (ID del documento = token)
  - deviceInfo: map
    - platform: "ios" | "android"
    - osVersion: string
  - createdAt: timestamp
  - updatedAt: timestamp
```

### 2. **Provider FCM (`lib/shared/providers/fcm_providers.dart`)**

Provider Riverpod que inicializa FCM automáticamente cuando el usuario se autentica:

```dart
fcmInitializerProvider: Observa el estado de autenticación y:
  - Si el usuario está autenticado → Inicializa FCM
  - Si el usuario cierra sesión → Limpia tokens
```

### 3. **Integración en App (`lib/app/app.dart`)**

- Se inicializa FCM automáticamente cuando el usuario se autentica
- Se verifica si hay notificaciones que abrieron la app al iniciar
- Se registra callback central para tap en push (`setNotificationTapHandler`) y navegación por `planId`.

### 3.1 **Bootstrap en main (`lib/main.dart`)**

- Registro de handler top-level de mensajes en background:
  - `FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler)`
- Este handler inicializa Firebase en isolate de background y deja log básico del payload.

### 4. **Cloud Function (`functions/index.js`)**

Función `sendPushNotification` para enviar notificaciones push:

**Parámetros:**
- `userId` (requerido): ID del usuario que recibirá la notificación
- `title` (requerido): Título de la notificación
- `body` (requerido): Cuerpo del mensaje
- `data` (opcional): Datos adicionales para la app

**Funcionalidades:**
- Obtiene todos los tokens FCM del usuario
- Envía notificación a todos los dispositivos del usuario
- Elimina tokens inválidos automáticamente
- Retorna estadísticas de envío (enviados, fallidos, total)

**Ejemplo de uso:**
```javascript
const sendPushNotification = functions.httpsCallable('sendPushNotification');
await sendPushNotification({
  userId: 'user123',
  title: 'Nuevo aviso',
  body: 'Hay un nuevo aviso en el plan',
  data: { planId: 'plan456', type: 'announcement' }
});
```

### 5. **Firestore Rules (`firestore.rules`)**

Reglas de seguridad para `users/{userId}/fcmTokens/{tokenId}`:

- **Crear**: Solo el propio usuario puede crear su token
- **Leer**: Solo el propio usuario puede leer sus tokens
- **Actualizar**: Solo el propio usuario puede actualizar su token
- **Eliminar**: Solo el propio usuario puede eliminar su token

### 6. **Configuración de Plataformas**

**iOS (`ios/Runner/Info.plist`):**
- `FirebaseAppDelegateProxyEnabled = false` (configuración manual)

**Android:**
- No requiere configuración adicional (usa `google-services.json`)

---

## 🚀 Próximos Pasos (Fases Futuras)

### Fase 2: Notificaciones Automáticas
- Notificaciones automáticas cuando se crea un aviso
- Notificaciones cuando cambia el estado de un plan
- Notificaciones cuando se crea/modifica un evento

### Fase 3: Preferencias de Usuario
- Configuración de tipos de notificaciones
- Horarios de silencio
- Silenciar notificaciones por plan

### Fase 4: Alarmas y Recordatorios
- Notificaciones programadas antes de eventos
- Recordatorios personalizables

---

## 📝 Notas Técnicas

### Tokens Múltiples
- Un usuario puede tener múltiples tokens (uno por dispositivo)
- Los tokens se identifican por su valor (token = ID del documento)
- Los tokens inválidos se eliminan automáticamente

### Permisos iOS
- Se solicitan permisos explícitamente al inicializar FCM
- Si el usuario deniega permisos, FCM no se inicializa

### Web
- FCM no está disponible en web
- El servicio detecta web y retorna `false` sin errores

### Limpieza de Tokens
- Los tokens se eliminan cuando el usuario cierra sesión
- Los tokens inválidos se eliminan automáticamente por la Cloud Function

---

## 🔧 Comandos Útiles

### Instalar dependencias Flutter
```bash
flutter pub get
```

### Desplegar Cloud Functions
```bash
cd functions
npm install
npx firebase-tools@latest deploy --only functions
```

### Ver logs de Cloud Functions
```bash
npx firebase-tools@latest functions:log
```

---

## 📚 Referencias

- [Firebase Cloud Messaging - Flutter](https://firebase.flutter.dev/docs/messaging/overview)
- [Firebase Admin SDK - Messaging](https://firebase.google.com/docs/cloud-messaging/admin/send-messages)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
