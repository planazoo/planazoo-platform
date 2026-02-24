# Crear usuarios de prueba desde cero

> Registrar los usuarios UA, UB y UC (o los alias que uses) directamente en la app, sin Init Firestore ni Firebase Console.

**Requisito:** Una cuenta Gmail (p. ej. `unplanazoo@gmail.com`). Todos los emails con alias (`+ua`, `+ub`, etc.) llegan a esa misma cuenta.

---

## 1. Reglas del registro

- **Email:** cualquiera válido. Para pruebas con una sola cuenta Gmail, usa **alias:** `unplanazoo+ua@gmail.com`, `unplanazoo+ub@gmail.com`, `unplanazoo+uc@gmail.com` (todos llegan a `unplanazoo@gmail.com`).
- **Contraseña:** la que quieras; **usa la misma para los tres** para no liarte (p. ej. `test123456` si cumple las reglas de la app).
- **Username:** **obligatorio**, único en la app, 3–30 caracteres, solo `a-z`, `0-9` y `_`, en minúsculas. Si está ocupado, la app puede sugerir alternativas.
- **Nombre (displayName):** opcional.

Tras registrarte, la app envía un **email de verificación** y cierra sesión. Tienes que **abrir el enlace del email** para ese usuario antes de poder hacer login con él.

---

## 2. Datos sugeridos para el Plan E2E (tres usuarios)

Misma contraseña para los tres (ej. `test123456`). Ajusta el dominio si no usas `unplanazoo@gmail.com`.

| Usuario | Rol          | Email                         | Username (sugerido) | Nombre (opcional) | Idioma   | Zona horaria        |
|---------|--------------|-------------------------------|---------------------|--------------------|----------|---------------------|
| **UA**  | Organizador  | unplanazoo+cricla@gmail.com   | ua_org / cricla     | UA Org             | Español  | p. ej. Europe/Madrid |
| **UB**  | Participante | unplanazoo+marbat@gmail.com  | ub_part             | UB Part            | **Español** | **Misma que UA** (Europe/Madrid) |
| **UC**  | Participante | unplanazoo+emmcla@gmail.com  | uc_part             | UC Part            | **English** | **Otra que UA/UB** (p. ej. Europe/London) |
| **UD**  | (opcional, para más adelante) | unplanazoo+matcla@gmail.com   | ud_part (al registrarse) | UD Part            | **Español** | **Nueva York (GMT-5)** America/New_York |

*(El rol “organizador” o “participante” se asigna al **invitar al plan**, no en el registro. Cualquier usuario registrado puede ser organizador de un plan si crea el plan e invita a los demás.)*

**Configurar idioma y zona horaria tras el registro:** En la app, **Perfil** → "Idioma" / "Seleccionar idioma" → elegir Español o English. **Perfil** → "Configurar zona horaria" → elegir la zona (ej. Europe/Madrid para UA y UB, America/New_York para UC).

---

## 3. Orden recomendado (crear uno por uno)

### Usuario UA (organizador para el smoke y el E2E)

1. Abre la app → **Registrarse**.
2. Rellena:
   - Email: `unplanazoo+cricla@gmail.com` (o tu Gmail+alias).
   - Contraseña y repetir (ej. `test123456`).
   - **Username:** `ua_org` (o `cricla` si prefieres; debe ser único).
   - Nombre: opcional (ej. UA Org).
3. Acepta términos si los hay → **Registrarse**.
4. La app te saca de sesión y envía un email. Abre **tu bandeja de Gmail** (la de `unplanazoo@gmail.com`), busca el email de verificación y **haz clic en el enlace**.
5. Vuelve a la app → **Iniciar sesión** con `unplanazoo+cricla@gmail.com` y la contraseña. Comprueba que entras al dashboard.

### Usuario UB (participante, español, misma zona que UA)

1. **Cierra sesión** (o abre una ventana de incógnito / otro navegador).
2. **Registrarse** de nuevo.
3. Email: `unplanazoo+marbat@gmail.com`, misma contraseña, **Username:** `ub_part` (único), nombre opcional → Registrarse.
4. Revisa Gmail → clic en el **enlace de verificación** de ese email.
5. Iniciar sesión con UB y comprobar que entra.
6. **Perfil** → Idioma: **Español**. **Perfil** → Configurar zona horaria: **la misma que UA** (p. ej. Europe/Madrid).

### Usuario UC (participante, inglés, otra zona horaria)

1. Cierra sesión (o otra ventana incógnito / otro navegador).
2. **Registrarse** con `unplanazoo+emmcla@gmail.com`, misma contraseña, **Username:** `uc_part`, nombre opcional → Registrarse.
3. Gmail → clic en el enlace de verificación.
4. Iniciar sesión con UC y comprobar que entra.
5. **Perfil** → Language: **English**. **Perfil** → Configure timezone: **otra que UA/UB** (p. ej. Europe/London).

### Usuario UD (opcional, para más adelante — español, Nueva York GMT-5)

No es necesario para el ciclo E2E estándar (UA, UB, UC). Crear UD cuando se quiera probar un cuarto invitado (p. ej. otro “no registrado” que recibe invitación y se registra).

1. Cierra sesión (otra ventana incógnito).
2. **Registrarse** con `unplanazoo+matcla@gmail.com`, misma contraseña, **Username:** `ud_part` (único), nombre opcional → Registrarse.
3. Gmail → clic en el enlace de verificación.
4. Iniciar sesión con UD y comprobar que entra.
5. **Perfil** → Idioma: **Español**. **Perfil** → Configurar zona horaria: **America/New_York** (Nueva York, GMT-5).

---

## 4. Comprobar que están listos

- **UA:** login correcto, ves dashboard/lista de planes.
- **UB y UC:** login correcto cada uno en su sesión (otra pestaña o incógnito).

Cuando los tres puedan hacer login, puedes seguir con el [smoke manual y el Plan E2E](../testing/INICIO_PRUEBAS_DIA1.md) (Paso 3 y 4).

---

## 5. Si el username está ocupado

La app puede mostrar sugerencias (ej. `ua_org_2`, `ua_org_2025`). Elige una que sea única o inventa otra (misma regla: 3–30 caracteres, `a-z`, `0-9`, `_`).

---

## 6. Resumen

1. Tres registros en la app (UA, UB, UC), cada uno con email con alias y username único.
2. Tres verificaciones: abrir el email en Gmail y clic en el enlace para cada usuario.
3. Tres logins de prueba para confirmar que todos entran.
4. Después: smoke con UA y luego ciclo E2E con las tres sesiones.
5. **UD** (opcional): para pruebas futuras con un cuarto usuario; email `unplanazoo+matcla@gmail.com`, español, zona Nueva York (GMT-5). Ver sección 3.
