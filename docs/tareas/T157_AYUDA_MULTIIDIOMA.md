# T157 – Sistema de ayuda contextual multi-idioma

**Objetivo:** Definir e implementar un sistema de ayuda para el usuario que permita añadir idiomas, correcciones y actualizaciones sin publicar de nuevo la app; incluir apoyo explícito para personas invidentes (accesibilidad).

**Referencia en lista:** `docs/tareas/TASKS.md` (T157).  
**Relacionado:** T158 (sistema multi-idioma de la app), T192 (accesibilidad general).

---

## Alcance

### 1. Idea general

- **Textos de ayuda en base de datos** (p. ej. Firestore): contenido por idioma y por “contexto” de ayuda, para poder corregir, ampliar o añadir idiomas sin nueva versión en stores.
- **Icono “?”** en los puntos de la app donde haga falta ayuda contextual.
- Al **pulsar el “?”**: se abre un **modal** con una explicación breve y un **enlace a una página web** donde está la explicación más amplia (FAQ, guía, etc.).
- **Multi-idioma:** los textos se sirven en el idioma actual del usuario (alineado con el idioma de la app, T158).
- **Ayuda para personas invidentes:** el sistema debe ser usable con lectores de pantalla (VoiceOver, TalkBack) y seguir buenas prácticas de accesibilidad.

---

## 2. Componentes del sistema

| Componente | Descripción |
|------------|-------------|
| **Id de ayuda** | Identificador estable por contexto (ej. `plan_details.aviso`, `event_modal.duration`, `calendar.tracks`). La app solicita textos por este id. |
| **Base de datos** | Colección (ej. Firestore) con documentos por id de ayuda; campos por idioma (`es`, `en`, …): texto corto para el modal y opcionalmente `url` para “Más información”. |
| **Icono “?”** | Botón/icono accesible, colocado junto a títulos, secciones o controles que necesiten explicación. |
| **Modal** | Muestra el texto corto del idioma actual y un enlace “Más información” (abre la URL en navegador o WebView según criterio del proyecto). |
| **Fallback** | Si no hay red o no existe el documento, mostrar texto por defecto embebido o cache local (última versión descargada) para no dejar el contenido vacío. |

---

## 3. Accesibilidad (personas invidentes)

El sistema de ayuda debe integrar accesibilidad desde el diseño:

- **Semántica del botón “?”:** El icono de ayuda debe ser un control focusable (botón) con:
  - **Etiqueta accesible** (p. ej. `Semantics` / `semanticsLabel`) que describa la acción y el contexto: “Ayuda sobre [nombre del contexto]”, en el idioma del usuario.
  - **Hint opcional** (p. ej. `semanticsHint`): “Abre una explicación y un enlace a más información”.
- **Modal:** Al abrir el modal, el foco debe ir al contenido (o al título del modal) para que el lector de pantalla anuncie la explicación; el enlace “Más información” debe ser un enlace nativo o un widget con rol de enlace y texto descriptivo (no solo “Más información” si el contexto no es obvio; ej. “Más información sobre avisos del plan”).
- **Orden de lectura:** El contenido del modal (título, texto, enlace) debe tener un orden lógico para navegación por teclado y lectores de pantalla.
- **Cierre del modal:** El botón de cierre debe ser accesible (etiqueta “Cerrar” o similar) y devolver el foco al elemento que abrió el modal (el “?”) para no desorientar al usuario.
- **Contraste y tamaño:** El icono “?” y los controles del modal deben cumplir criterios de contraste y tamaño táctil (relacionado con T192).

Se recomienda probar con VoiceOver (iOS) y TalkBack (Android) al implementar.

---

## 4. Modelo de datos (ejemplo Firestore)

Ejemplo de estructura por documento (un doc por id de ayuda):

- `helpId`: string (ej. `plan_details.aviso`)
- `es`: string — texto corto para modal (español)
- `en`: string — texto corto (inglés)
- `url_es`: string (opcional) — URL de la página ampliada en español
- `url_en`: string (opcional) — URL de la página ampliada en inglés  
  (o un solo campo `url` si la página detecta idioma por sí misma)

Reglas de Firestore: lectura pública (solo lectura) para la colección de textos de ayuda si el contenido no es sensible.

---

## 5. Criterios de aceptación

1. Existe una colección (o equivalente) con textos de ayuda por id y por idioma, y opcionalmente URL.
2. En al menos dos pantallas/contextos hay un icono “?” que abre el modal con texto y enlace.
3. Los textos del modal se obtienen de la BD según idioma de la app; hay fallback si no hay datos o no hay red.
4. El botón “?” y el modal son accesibles: etiquetas para lector de pantalla, foco coherente al abrir/cerrar, enlace “Más información” descriptivo.
5. Documentación en el repo (este documento o anexo) con lista de ids de ayuda y cómo añadir nuevos.

---

## 6. Ids de ayuda definidos (implementación)

**Conexión ayuda ↔ código:** Los identificadores están definidos en **`lib/shared/constants/help_context_ids.dart`** (constantes como `HelpContextIds.planDetailsAviso`). Usar siempre esas constantes en `HelpIconButton(helpId: HelpContextIds.xxx)` para evitar strings mágicos. En el seed (JSON) y en Firestore se puede añadir el campo opcional **`context`** con una descripción corta (p. ej. "Info del plan, sección Avisos (wd_plan_data_screen)") para saber dónde se usa al editar.

| helpId (constante) | Uso | Pantalla / contexto |
|--------------------|-----|----------------------|
| `planDetailsAviso` → `plan_details.aviso` | Sección Avisos | Info del plan (wd_plan_data_screen) |
| `planDetailsInfo` → `plan_details.info` | Fechas, moneda, presupuesto, visibilidad, zona horaria | Info del plan |
| `planDetailsParticipants` → `plan_details.participants` | Participantes del plan | Info del plan |
| `planDetailsLeave` → `plan_details.leave` | Salir del plan | Info del plan |
| `planDetailsHeader` → `plan_details.header` | Barra superior Info del plan | Info del plan |
| `createPlanGeneral` → `create_plan.general` | Modal Crear plan | wd_create_plan_modal |
| `dashboardTabs` → `dashboard.tabs` | Pestañas del dashboard | Dashboard |
| `dashboardPlanList` → `dashboard.plan_list` | Lista de planes | Dashboard |
| `calendarView` → `calendar.view` | Vista calendario | Calendario del plan |
| `mySummary` → `my_summary` | Mi resumen | Mi resumen del plan |
| `chatPlan` → `chat.plan` | Chat del plan | Chat |
| `notifications` → `notifications` | Notificaciones | Centro de notificaciones |
| `profileTimezone` → `profile.timezone` | Zona horaria | Perfil |
| `adminUpdateHelp` → `admin.update_help` | Actualizar ayuda | Página Admin |
| `adminUiShowcase` → `admin.ui_showcase` | UI Showcase | Página Admin |

Para añadir un nuevo contexto: (1) añadir la constante en `help_context_ids.dart` con comentario de pantalla; (2) crear documento en Firestore `help_texts/{helpId}` con `es`, `en`, `url` y opcionalmente `context`; (3) usar `<HelpIconButton helpId: HelpContextIds.xxx ... />` en la UI; (4) añadir la entrada al seed (assets + docs) con campo `context`.

---

## 6.1. Mantener ayudas al día (la IA y tú)

**Archivo semilla en el repo:** `docs/tareas/T157_AYUDA_TEXTOS_SEED.json`

Ese JSON es la **lista de textos de ayuda** (por `helpId`) con `es`, `en` y `url`. La IA lo actualizará cuando:

- Añada un nuevo `HelpIconButton` (nuevo `helpId` y textos en el seed).
- Cambie el copy de una ayuda existente (actualiza el seed y el `defaultBody` en código).

**Qué hacer tú:**

1. **Al codificar / revisar:** No hace falta tocar Firestore; la app usa el `defaultBody` del código si no hay doc en Firestore.
2. **Para publicar cambios de ayuda sin nueva versión de la app:** Copia el contenido del seed a Firestore (colección `help_texts`, documento = `helpId`, campos `es`, `en`, `url`). Puedes hacerlo a mano en la consola de Firebase o con un script que lea el JSON y escriba en Firestore.

Así las ayudas se mantienen en el repo y la IA puede actualizarlas al mismo tiempo que el código.

**Botón "Actualizar ayuda" en W1 (solo cuando lo activas):**

- **Activar el botón:** Long-press (pulsación larga) en el logo "planazoo" en la barra superior. Vuelve a hacer long-press para ocultarlo.
- **Dónde aparece:** En la barra lateral izquierda (W1), entre el chat y el perfil. Solo lo ven usuarios **admin** y solo si el botón está activado.
- **Qué hace:** Al pulsarlo, la app lee `assets/help_texts_seed.json`, sube todos los textos a Firestore (colección `help_texts`) y muestra un mensaje con el número de textos actualizados. Solo usuarios admin pueden escribir en `help_texts` (reglas de Firestore).
- **Mantener el seed:** La IA debe actualizar **también** `assets/help_texts_seed.json` (además de `docs/tareas/T157_AYUDA_TEXTOS_SEED.json`) cuando cambie o añada ayudas, para que al pulsar el botón se suba la versión correcta.

---

## 7. Fases sugeridas (para implementación)

1. **Diseño:** Definir lista inicial de ids de ayuda y redactar textos (ES/EN) y URLs; crear documentos en Firestore.
2. **Código:** Servicio/repositorio que lea textos por id e idioma; widget reutilizable “?” + modal; integración en 1–2 pantallas piloto.
3. **Accesibilidad:** Añadir semántica, orden de foco y pruebas con VoiceOver/TalkBack; ajustar según T192.
4. **Extensión:** Ir añadiendo “?” en el resto de contextos acordados.

---

## 8. Crear documento de ejemplo en Firestore (piloto)

Para que el texto de ayuda de "Avisos" se cargue desde Firestore (y se cachee para offline), crea en la consola de Firebase un documento:

- **Colección:** `help_texts`
- **ID del documento:** `plan_details.aviso`
- **Campos:**
  - `es` (string): "Mensajes del organizador y participantes visibles para todos en el plan. Aquí puedes publicar avisos y ver el historial."
  - `en` (string): "Messages from the organizer and participants visible to everyone in the plan. You can post announcements and see the history here."
  - `url` (string, opcional): URL de una página con más información (ej. FAQ o guía).

Si no existe el documento, la app muestra el texto por defecto (embebido en la app) y no falla.

---

## Referencias

- T158: sistema multi-idioma de la app (AppLocalizations).
- T192: adaptar la app a personas con discapacidad (accesibilidad).
- Flutter: [Semantics](https://api.flutter.dev/flutter/widgets/Semantics-class.html), [ExcludeSemantics](https://api.flutter.dev/flutter/widgets/ExcludeSemantics-class.html), [Accessibility (Flutter)](https://docs.flutter.dev/development/accessibility-and-localization/accessibility).
