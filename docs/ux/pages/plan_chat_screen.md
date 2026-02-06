# 💬 PlanChatScreen - Chat del plan

## 📋 Descripción General

**PlanChatScreen** es la pantalla de chat del plan tipo WhatsApp (T190). Permite a los participantes del plan enviar y recibir mensajes en tiempo real. Se muestra como pestaña dentro de **PlanDetailPage** (móvil) o como vista en el área W31 del **DashboardPage** (web) al pulsar W19 (botón Chat).

## 📍 Acceso

| Contexto | Cómo llegar |
|----------|-------------|
| **Móvil** | PlanDetailPage → pestaña **Chat** (barra de navegación inferior). |
| **Web** | DashboardPage → seleccionar un plan → botón **W19** (Chat) en la fila de accesos rápidos. |

Requiere tener un plan seleccionado; si no hay plan, se muestra el mensaje "Selecciona un plan para ver el chat".

## 🎨 Diseño y Funcionalidad

- **Contenido:** Lista de mensajes (`PlanMessage`) con burbujas diferenciadas (propios vs otros), campo de texto y botón enviar.
- **Estilo:** Consistente con el tema oscuro de la app; uso de `GoogleFonts.poppins`, `AppColorScheme`.
- **Datos:** Mensajes en Firestore (colección asociada al plan); carga de usuarios para mostrar nombre/avatar del remitente.
- **Acciones:** Enviar mensaje, scroll al final del hilo.

## 🔧 Implementación actual

- **Código:** `lib/widgets/screens/wd_plan_chat_screen.dart` → clase `PlanChatScreen`.
- **Props:** `planId`, `planName` (obligatorios).
- **Dependencias:** `lib/features/chat/` (modelos, providers), `wd_chat_message_bubble.dart`, `wd_chat_input.dart`, `UserService` para resolver nombres de usuario.

**Última actualización:** Febrero 2026
