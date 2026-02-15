# Eventos desde correo: reglas anti-spam y decisiones

> Documento para discutir y fijar criterios del flujo "usuario reenvía confirmación a una dirección de la plataforma → evento en buzón → asignación a plan".  
> **Tarea relacionada:** T134 (Eventos desde correo reenviado a dirección plataforma).

---

## 1. Regla principal: solo correos desde usuario registrado

- **Criterio:** Solo se aceptan y procesan correos cuyo **remitente (From)** coincida con un email de un **usuario registrado** en la plataforma (cuenta existente y verificada, según política actual).
- **Objetivo:** Evitar spam y uso anónimo; solo el propio usuario puede crear eventos vía correo con su identidad.
- **Decisión:** Solo se acepta el **email principal** del usuario registrado (T216 completada). No se aceptan alias (ej. Gmail `usuario+alias@gmail.com`).
  - Correos con `From` no registrado: no procesar; **no se envía respuesta** (para no revelar la dirección).
  - **Registro:** sí, se guardan datos de intentos rechazados para depuración (sección 5).

---

## 2. Rate limiting por usuario

- **Objetivo:** Evitar abuso (envío masivo) y controlar costes (parsing/IA, almacenamiento).
- **Decisión:** **50 correos por día** por usuario. Al superar el límite: **rechazar ese correo y avisar al usuario** (por app o email).

---

## 3. Lista blanca (opcional, fase beta)

- **Objetivo:** Limitar el uso del flujo a un conjunto de usuarios (beta) hasta validar comportamiento y costes.
- **Decisión:** **No** se usa lista blanca; cualquier usuario registrado puede usar la dirección de reenvío (sujeto a rate limit).

---

## 4. Qué hacer con correos no aceptados

- **From no registrado:** No procesar; **no se responde** al remitente.
- **From registrado pero superado rate limit:** No procesar ese correo; **avisar al usuario** (app o email).

---

## 5. Registro de intentos rechazados

- **Decisión:** **Sí** se registran datos de los intentos rechazados (From no registrado, rate limit superado, etc.) **para depuración**.

---

## 6. Resumen de decisiones (cerradas)

| Tema | Decisión |
|------|----------|
| Verificación de From | **Solo email principal** del usuario registrado (T216). No alias. |
| Rate limit | **50 correos/día** por usuario. Al superar: rechazar y **avisar al usuario**. |
| Lista blanca beta | **No.** Cualquier usuario registrado puede usar el reenvío (con rate limit). |
| Respuesta a From no registrado | **No se responde** (no revelar dirección). |
| Registro de intentos rechazados | **Sí**, datos para **depuración**. |

Actualizar criterios de aceptación de T134 con estas reglas.
