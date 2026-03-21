# Primer día de pruebas – Por dónde empezar

> Secuencia concreta para arrancar las pruebas de la primera versión estable. Sigue los pasos en orden.

**Idiomas:** Las pruebas deben cubrir **español e inglés**. Ver sección [Probar dos idiomas (ES + EN)](#probar-dos-idiomas-es--en) más abajo.

**Referencias:** [Plan E2E tres usuarios](./PLAN_PRUEBAS_E2E_TRES_USUARIOS.md) · [TESTING_CHECKLIST](../configuracion/TESTING_CHECKLIST.md) · [USUARIOS_PRUEBA](../configuracion/USUARIOS_PRUEBA.md)  
**Para anotar lo que vas viendo:** [Registro de observaciones durante las pruebas](./REGISTRO_OBSERVACIONES_PRUEBAS.md) (un solo documento donde ir añadiendo observaciones; los huecos/errores formales se llevan a la sección 19 y 20 del Plan E2E).

---

## Paso 1 – Arrancar la app (web)

En la raíz del proyecto:

```bash
flutter run -d chrome
```

Espera a que abra el navegador en `http://localhost:XXXX` (o la URL que muestre). Si usas otra configuración (ej. ya desplegada en Firebase), abre esa URL en el navegador.

---

## Paso 2 – Usuarios de prueba

**Opción A – Crear usuarios desde cero (registro en la app):**  
Si quieres crear UA, UB y UC tú mismo: [Crear usuarios desde cero](../configuracion/CREAR_USUARIOS_DESDE_CERO.md). Registro en la app con email+alias, username único y misma contraseña; verificar cada usuario por el enlace que llega al Gmail.

**Opción B – Init Firestore (si tienes dashboard):**  
Si tienes una pantalla de admin/dashboard con botón **"⚙️ Init Firestore"**, úsalo para crear los usuarios de prueba en Firebase Auth y Firestore.

**Opción C – Usuarios ya existentes:**  
Necesitas al menos **un organizador (UA)** y, para el ciclo completo, **dos participantes (UB, UC)**. Emails con alias Gmail (todos llegan a la misma cuenta), por ejemplo:

| Rol          | Email (ejemplo)           | Uso hoy      |
|-------------|---------------------------|--------------|
| **UA** (org)| unplanazoo+cricla@gmail.com | Smoke + E2E  |
| **UB**      | unplanazoo+marbat@gmail.com | E2E Fase 2+  |
| **UC**      | unplanazoo+emmcla@gmail.com | E2E Fase 2+  |

Contraseña la misma para todos. Más opciones en [USUARIOS_PRUEBA](../configuracion/USUARIOS_PRUEBA.md).

**Comprobar:** Con UA puedes hacer login y ves el dashboard (lista de planes o pantalla principal).

---

## Paso 3 – Smoke manual (una sola sesión, ~5–10 min)

**Objetivo:** Confirmar que lo básico funciona antes del ciclo largo. Todo con **UA** en **una** pestaña.

1. **Login:** Cerrar sesión si había una abierta. Ir a la URL de la app → Iniciar sesión con UA (email + contraseña o Google si lo usas).
2. **Manual de ayuda (público):** Desde login, abrir "Manual de ayuda" y verificar que carga la ruta `/help`.
3. **Dashboard:** Tras login, debe verse la pantalla principal (lista de planes vacía o con planes existentes).
4. **Ayuda dentro de app:** Abrir el acceso a ayuda desde dentro de la app y comprobar que también navega a `/help`.
5. **Crear plan:** Pulsar crear plan (o equivalente). Rellenar nombre y rango de fechas; guardar.
6. **Ver plan en lista:** El plan nuevo debe aparecer en la lista. Abrirlo y ver la vista del plan (calendario o pestañas).

**Anotar:** ¿Todo ✅ o algo ❌/⚠️? Si algo falla, anótalo y corrige antes de seguir al Paso 4.

---

## Paso 4 – Preparar 3 ventanas para el ciclo E2E (cuando vayas a Fase 0–1)

Para el [Plan E2E tres usuarios](./PLAN_PRUEBAS_E2E_TRES_USUARIOS.md) necesitas 3 sesiones a la vez:

- **Ventana 1:** Chrome normal → UA (unplanazoo+cricla o tu organizador).
- **Ventana 2:** Chrome incógnito (o Firefox) → UB.
- **Ventana 3:** Otra incógnito (o Edge) → UC.

Misma URL en las tres (localhost o la que uses). Opcional: poner en la pestaña "UA", "UB", "UC" para no confundir.

---

## Paso 5 – Ciclo E2E completo (cuando el smoke esté verde)

Abrir [Plan de pruebas E2E – Tres usuarios](./PLAN_PRUEBAS_E2E_TRES_USUARIOS.md) y seguir **en orden**. El ciclo incluye **prueba explícita del sistema de invitaciones** (enviar, email, aceptar/rechazar, re-invitar). Hay que probar **dos casos**:

- **UB = no registrado:** invitar por email a UB (Unplanazoo+marbat@gmail.com). UB **aún no tiene cuenta**; recibe el email de invitación, luego **se registra** con ese email, verifica si aplica y **acepta la invitación** (enlace del email o desde la app). Anotar si el flujo está claro.
- **UC = registrado:** invitar por email **o desde la lista de usuarios** a UC (Unplanazoo+emmcla@gmail.com). UC **ya tiene cuenta**; recibe la invitación (email y/o notificación en app) y puede **aceptar o rechazar** desde la app o desde el enlace del email. El organizador recibe notificación al aceptar/rechazar y ve el estado de invitaciones en Participantes. Opcional: probar también "Salir del plan" como participante (Info del plan o pestaña Participantes).

- **Fase 0** – Registro y contexto inicial.
- **Fase 1** – UA crea plan e **invita a UB (no registrado) y a UC (registrado)** (envío por email).
- **Fase 2** – **UC (registrado)** acepta desde la app o el enlace. **UB (no registrado)** se registra con el email de la invitación y luego acepta.
- **Fase 5** – Re-invitar a UC y asignar a eventos (re-invite tras rechazo o ausencia).
- **Fases 3–4, 6–11** – Eventos, notificaciones, chat, aprobar plan, durante el plan, UC sale/vuelve, cerrar plan.

En cada paso: marcar ✅ / ❌ / ⚠️ / 🔶 y anotar huecos en la **sección 19** del mismo documento.

---

## Probar dos idiomas (ES + EN)

Las pruebas deben incluir **español e inglés**. La app usa `AppLocalizations` con soporte **es (español)** y **en (inglés)**.

### Dónde cambiar el idioma

- **En login o registro:** icono de idioma (bandera/globo) en la cabecera → elegir **Español** o **English**.
- **Una vez dentro (dashboard):** **Perfil** (icono persona en la barra lateral izquierda) → en la página de perfil hay el selector de idioma; cambiar a Español o English. El cambio se aplica en toda la app.

### Cómo incluir los dos idiomas en las pruebas

Elige **una** de estas formas (detalle en el Plan E2E, [sección 5.5](./PLAN_PRUEBAS_E2E_TRES_USUARIOS.md#55-idiomas-incluir-otro-idioma-es--en)):

| Opción | Descripción |
|--------|-------------|
| **A. Una ejecución por idioma** | Hacer el flujo completo primero en español (todas las ventanas en ES) y luego repetir en inglés (todas en EN). Máxima cobertura; más tiempo. |
| **B. Usuarios en idiomas distintos** | **Recomendado:** UA y UB en español, UC en inglés. Cada ventana con su idioma desde el inicio. Una sola pasada; comprueba que varios usuarios pueden usar idiomas distintos en el mismo plan. |
| **C. Cambiar a mitad del flujo** | En una ventana (p. ej. UA), cambiar de ES a EN en una fase concreta (p. ej. tras Fase 5) y seguir el resto en inglés. Comprueba que el cambio de idioma no rompe el flujo. |

### Qué comprobar en ambos idiomas

- Botones y etiquetas de la pantalla principal (dashboard, filtros, "Crear plan").
- Formularios (registro, login, crear plan, crear evento).
- Mensajes de error y de éxito.
- Si algo sigue en el idioma equivocado o sin traducir, anotarlo en la **sección 19 (Huecos)** del Plan E2E.

En el Plan E2E, los pasos **0.9** y **0.10** (Fase 0) incluyen localizar el selector de idioma y, si usas B o C, configurar el idioma de cada ventana.

---

## Resumen "qué hago ahora"

1. ✅ Arrancar app (`flutter run -d chrome`).
2. ✅ Tener UA (y si quieres UB/UC) listos (Init Firestore o [crear desde cero](../configuracion/CREAR_USUARIOS_DESDE_CERO.md)).
3. ✅ Decidir cómo probar **español e inglés** (opción A, B o C en [Probar dos idiomas](#probar-dos-idiomas-es--en)).
4. ✅ Smoke manual con UA: login → dashboard → crear plan → ver en lista (y, si quieres, cambiar idioma en Perfil y comprobar que la UI cambia).
5. ✅ Si el smoke va bien, preparar 3 ventanas y empezar Fase 0 del Plan E2E (el ciclo incluye **sistema de invitaciones**: Fase 1 enviar, Fase 2 aceptar/rechazar, Fase 5 re-invitar).

Cuando termines el smoke o la Fase 0, puedes seguir con el resto de fases y luego usar el [TESTING_CHECKLIST](../configuracion/TESTING_CHECKLIST.md) por áreas para cubrir casos concretos. Incluir en las pruebas la **borrado total de usuario** ([USER-D-007](../configuracion/TESTING_CHECKLIST.md#351-borrado-total-de-usuario-eliminar-cuenta)): asegurarse de que "Eliminar cuenta" borra todos los datos sin errores de permisos.
