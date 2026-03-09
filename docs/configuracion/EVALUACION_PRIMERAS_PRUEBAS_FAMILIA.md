# Evaluación: primeras pruebas con usuarios reales (familia)

**Objetivo:** Tener claro qué debe estar listo antes de invitar a la familia a probar Planazoo (web e iOS).  
**Fecha:** Marzo 2026

---

## 1. Criterios mínimos para “listo para familia”

Para que las primeras pruebas con familia sean útiles y no frustrantes:

| Criterio | Descripción |
|----------|-------------|
| **Flujo completo sin roturas** | Crear plan → invitar → aceptar invitación → ver plan → eventos básicos → chat. Sin pasos que fallen de forma sistemática. |
| **Mensajes entendibles** | Textos en la app (y en emails de invitación) en el idioma del usuario; evitar errores técnicos en pantalla. |
| **Estabilidad razonable** | No hace falta cero bugs, pero sí que los flujos principales no caigan (crash, pantalla en blanco, “Error: null”). |
| **Experiencia coherente** | En web y en móvil la misma lógica (mensajes del chat se ven en ambos, invitación funciona en ambos). |
| **Onboarding mínimo** | La familia puede registrarse, recibir un link de invitación y entrar al plan sin que tengas que explicar cada clic. |
| **Timezones correctos** | Plan y eventos en la zona del destino (ej. Egipto); participantes con zona personal (ej. Londres). Cada uno ve las horas en su contexto y los vuelos/desplazamientos muestran salida y llegada en sus timezones. |

**Escenario de prueba real:** Primer viaje a **Egipto**; una participante viene desde **Londres**. La app debe mostrar bien: plan en hora de Egipto (Africa/Cairo), su vista en hora de Londres (Europe/London), y eventos que crucen timezones (ej. vuelo Londres–El Cairo) con salida/llegada en cada zona.

No es necesario para esta fase: pagos, estadísticas avanzadas, offline completo, deep links en iOS, notificaciones push perfectas.

---

## 2. Lo que ya está en buen estado

- **Auth:** Login, registro, verificación de email, recuperación de contraseña.
- **Planes:** Crear, editar, ver lista (web: dashboard; iOS: lista de planes).
- **Detalle del plan (iOS):** PlanDetailPage con pestañas (Info, Mi resumen, Calendario, Participantes, Chat, Stats, Pagos).
- **Chat:** Mensajes en tiempo real entre web e iOS; reacciones; lectura correcta desde servidor.
- **Invitaciones:** Envío por email, aceptar/rechazar por token (`/invitation/{token}`).
- **Eventos y alojamientos:** CRUD básico; calendario (web e iOS).
- **Participantes:** Ver participantes, invitaciones, estados del plan.
- **Multi-idioma:** AppLocalizations (ES/EN) en gran parte de la app; algunos huecos en páginas móviles (ver abajo).
- **Firestore:** Reglas y colecciones para planes, mensajes, invitaciones, eventos, participantes.
- **Timezones:** `TimezoneService` (UTC ↔ local), `PerspectiveService` (perspectiva por usuario), eventos con `timezone` y `arrivalTimezone`, participaciones con `personalTimezone`. Londres y **Egipto (Africa/Cairo)** en listas comunes, nombres de ciudad y offsets; listo para escenario Egipto + Londres.

---

## 3. Qué conviene tener cerrado antes de las pruebas con familia

### 3.1 Prioridad alta (evitar frustración el primer día)

| # | Ítem | Dónde | Acción |
|---|------|--------|--------|
| 1 | **Textos hardcodeados en español** | `pg_plans_list_page.dart`, `pg_invitation_page.dart` | **Hecho.** Sustituidos por AppLocalizations (claves en `app_es.arb` / `app_en.arb`). Incluye: “No tienes planes aún”, “Invitación a Plan”, “Iniciar sesión”, “Rechazar invitación”, SnackBars, etc. Ver `REVISION_IOS_VS_WEB.md` § 2.1. |
| 2 | **Tras aceptar invitación en móvil: ir al plan** | `pg_invitation_page.dart` | **Hecho.** Tras aceptar, en móvil se navega a PlanDetailPage(plan); en web al dashboard. |
| 3 | **Safe area en PlanDetailPage (iOS)** | `pg_plan_detail_page.dart` | **Hecho.** Body envuelto en SafeArea. Revisar en dispositivo por si hubiera que afinar. |
| 4 | **Timezones: Egipto + Londres** | TimezoneService, mapas de ciudad | Asegurar que **Africa/Cairo** (Egipto) esté en timezones comunes, en nombres legibles y en offsets; que el calendario y “Mi resumen” muestren bien eventos en hora local del plan y en la hora personal del participante (ej. Londres). Verificar vuelos/desplazamientos con salida/llegada en timezones distintas. Ver `GESTION_TIMEZONES.md`. |

### 3.2 Prioridad media (mejoran mucho la experiencia)

| # | Ítem | Dónde | Acción |
|---|------|--------|--------|
| 5 | **Barra de pestañas del plan en móvil** | `PlanNavigationBar` | En pantallas estrechas (iPhone SE, etc.) las 7 pestañas pueden quedar muy comprimidas. Probar y, si molesta, valorar: solo iconos en móvil o agrupar en “Más”. Ver `REVISION_IOS_VS_WEB.md` § 2.5. |
| 6 | **FCM / notificaciones push en iOS** | `Info.plist`, Firebase | Si quieres que la familia reciba notificaciones en el móvil: `UIBackgroundModes` → `remote-notification`, GoogleService-Info.plist, APNs en Firebase. Ver `REVISION_IOS_VS_WEB.md` § 2.7. |
| 7 | **Deep link invitación en iOS** | App + servidor | Si la invitación se abre por link (ej. desde el correo), en iOS hace falta Universal Links o URL scheme para que abra la app en la pantalla de invitación. Opcional para primera ronda si les pasas el link y lo abren desde Safari/Chrome y luego entran a la app ya logueados. |

### 3.3 Prioridad baja (pueden esperar)

- ~~Quitar `import 'dart:io'` de `pg_plans_list_page.dart`~~ ✅ Hecho.
- Descripciones de uso cámara/fotos en Info.plist si la app usa selector de fotos o cámara.
- Refinar copy de emails de invitación (asunto, idioma, firma “Equipo Planazoo”) — T228.

---

## 4. Checklist rápido “Día 1 con familia”

Ejecutar tú mismo antes de invitarles:

- [ ] **Registro:** Crear una cuenta nueva (email + username + contraseña) en web y en iOS.
- [ ] **Login:** Iniciar sesión en web y en iOS.
- [ ] **Crear plan:** Un plan de prueba con nombre, fechas y al menos un evento.
- [ ] **Invitación:** Enviar invitación por email a otro usuario (ej. otro email de la familia).
- [ ] **Aceptar invitación (web):** Abrir el link de invitación en el navegador, aceptar y comprobar que se llega al plan o al dashboard con el plan visible.
- [ ] **Aceptar invitación (móvil):** Abrir el link en el móvil (o entrar ya logueado); aceptar y comprobar que se entra directamente al plan (PlanDetailPage).
- [ ] **Chat:** En el mismo plan, enviar un mensaje desde web y verlo en iOS (y al revés); opcional: reacción a un mensaje.
- [ ] **Calendario:** Ver el evento en la pestaña Calendario en web y en móvil.
- [ ] **Idioma:** Cambiar idioma de la app (ES/EN) y comprobar que no queden textos en español hardcodeados en pantallas clave (lista de planes, invitación, login).
- [ ] **Timezones (Egipto + Londres):** Plan con destino Egipto (Africa/Cairo); participante con zona Londres (Europe/London). Crear evento en hora de El Cairo y comprobar que la participante en Londres lo ve en su hora; si hay vuelo Londres–El Cairo, comprobar que se muestran salida y llegada en cada timezone.

Si algo de lo anterior falla, corregirlo antes de ampliar a más familiares.

---

## 5. Orden recomendado de trabajo

1. ~~Timezones: Africa/Cairo (Egipto) en la app~~ Hecho.
2. **Navegación a PlanDetailPage tras aceptar invitación en móvil** (3.1.2) — cierra el ciclo “recibo link → acepto → estoy dentro del plan”.
3. **Multi-idioma en `pg_plans_list_page` y `pg_invitation_page`** (3.1.1) — evita que la primera impresión sea “medio en inglés, medio en español”.
4. **Safe area en PlanDetailPage** (3.1.3) — una sola pasada en simulador/dispositivo.
5. Ejecutar el **checklist “Día 1 con familia”** (sección 4), incluyendo la prueba de timezones Egipto + Londres.
6. Si va bien, invitar a 2–3 personas y repetir el flujo invitación → aceptar → plan → chat con ellos.
7. Opcional para siguiente iteración: FCM en iOS, barra de pestañas, deep link.

---

## 6. Repaso – Estado actual (Marzo 2026)

| Área | En código | Por probar tú mismo |
|------|-----------|----------------------|
| **Alta prioridad (3.1)** | Ítems 1–4 implementados | Checklist §4: registro, login, crear plan, invitación, aceptar web+móvil, chat, calendario, idioma, timezones Egipto+Londres. |
| **Móvil tras aceptar** | En móvil → PlanDetailPage(plan); web → / | Abrir link invitación en iOS, aceptar, comprobar que entras al plan. |
| **Safe area** | SafeArea en body de PlanDetailPage | Simulador/dispositivo con notch: que nada quede tapado. |
| **Timezones** | Africa/Cairo en TimezoneService, perspective, calendar, flight | Plan Egipto; participante Londres; evento/vuelo y comprobar horas. |
| **Idioma** | Lista de planes e invitación con AppLocalizations | Cambiar idioma (ES/EN) en lista de planes + pantalla invitación. |

**Siguiente paso:** Ejecutar el checklist de la sección 4 en web y en iOS. Anotar fallos o textos raros antes de invitar a la familia.

---

## 7. Referencias

- **Revisión iOS vs Web (TestFlight / pruebas):** `docs/configuracion/REVISION_IOS_VS_WEB.md`
- **Checklist exhaustivo de pruebas:** `docs/configuracion/TESTING_CHECKLIST.md`
- **Plan E2E tres usuarios (flujo completo):** `docs/testing/PLAN_PRUEBAS_E2E_TRES_USUARIOS.md`
- **Usuarios de prueba:** `docs/configuracion/USUARIOS_PRUEBA.md`
- **Contexto y normas:** `docs/configuracion/CONTEXT.md`
- **Timezones (arquitectura y buenas prácticas):** `docs/guias/GESTION_TIMEZONES.md`
