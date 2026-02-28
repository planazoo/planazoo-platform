# Configuración profesional: Google Places API (T225)

Guía paso a paso para comprobar si ya tienes una API key, habilitar Places API y configurar el proyecto de forma segura y profesional.

**Relacionado con:** T225 – Búsqueda de lugar para alojamientos y eventos  
**Proyecto Firebase:** `planazoo` (mismo proyecto de Google Cloud)

---

## 1. ¿Tengo ya una API key? Cómo comprobarlo

### 1.1 Entrar en Google Cloud Console

1. Abre **[Google Cloud Console](https://console.cloud.google.com/)** e inicia sesión con la cuenta que usa el proyecto **planazoo** (la misma de Firebase).
2. En el **selector de proyecto** (arriba, junto al logo de Google Cloud), haz clic y selecciona **planazoo**.  
   - Si no ves "planazoo", usa el mismo proyecto que aparece en [Firebase Console](https://console.firebase.google.com/) para este app.

### 1.2 Ver las credenciales (API keys) existentes

1. En el menú de la izquierda: **APIs y servicios** → **Credenciales**  
   - Enlace directo: [Credenciales - planazoo](https://console.cloud.google.com/apis/credentials?project=planazoo)
2. En la sección **"Claves de API"** verás una tabla con todas las claves del proyecto.
   - Suele haber al menos una clave **"Clave de API de la Web"** o similar, usada por Firebase (la que está en `lib/firebase_options.dart` como `apiKey`).
   - Anota si ves alguna clave con nombre tipo "Places", "Maps" o "Restricción por aplicación".  
   **Conclusión:** Si hay filas en "Claves de API", **sí tienes al menos una API key**. Esa key puede ser la de Firebase; para Places hace falta que además esté habilitada la API (paso 1.3).

### 1.3 Comprobar si Places API está habilitada

1. En el menú: **APIs y servicios** → **Biblioteca**  
   - Enlace: [Biblioteca de APIs](https://console.cloud.google.com/apis/library?project=planazoo)
2. En el buscador escribe **"Places"**.
3. Revisa:
   - **Places API** (clásica) – si pone "Habilitada", ya está activa.
   - **Places API (New)** – recomendada por Google para nuevos desarrollos; si está "Habilitada", puedes usarla.
   - **Maps JavaScript API** – a veces se usa junto con Places en web; no es obligatoria para solo autocompletado desde Flutter.

**Resumen:**

| Qué comprobar | Dónde | Cómo saber si está listo |
|---------------|--------|---------------------------|
| ¿Existe una API key? | APIs y servicios → Credenciales | Hay al menos una fila en "Claves de API" |
| ¿Places está habilitada? | APIs y servicios → Bibliotecas → buscar "Places" | "Places API" o "Places API (New)" en estado "Habilitada" |
| ¿Facturación activa? | Facturación (menú ☰) | Proyecto vinculado a una cuenta de facturación (Places requiere facturación; hay crédito gratis mensual) |

Si **no** tienes clave, o **no** está habilitada Places, o **no** tienes facturación, sigue la sección 2.

### 1.4 Si ya tienes claves "auto created by Firebase"

Es normal ver algo como:

- **Browser key** – suele ser la que usa la app web (la de `firebase_options.dart`).
- **Android key** / **iOS key** – para las apps nativas.

Para usar **Places** puedes:

- **Opción A (rápida):** Habilitar **Places API** o **Places API (New)** en la Biblioteca (sección 2.2). Luego usar la **Browser key** para web: al hacer clic en ella verás la cadena de la clave; esa misma key puede usarse para Places si la API está habilitada en el proyecto.
- **Opción B (recomendada a medio plazo):** Crear una **clave nueva solo para Places** (sección 2.3), con restricciones por API (solo Places) y por aplicación (referrers web / Android / iOS). Así no expones la clave de Firebase y puedes rotar la de Places sin tocar Auth ni el resto.

Mientras tanto, con **Opción A** puedes desarrollar y probar; cuando quieras endurecer la seguridad, sigue la Opción B.

---

## 2. Configuración desde cero (paso a paso)

### 2.1 Vincular facturación al proyecto (necesario para Places)

Places API requiere que el proyecto tenga una **cuenta de facturación** vinculada. Google ofrece crédito gratuito mensual para Maps Platform; sin facturación las llamadas a Places no funcionan.

#### Opción A: Desde la consola de Facturación

1. Abre **[Facturación – Gestionar cuentas de facturación](https://console.cloud.google.com/billing)**.
2. Pestaña **"Mis proyectos"** (o "My projects").
3. En la tabla verás tus proyectos. Busca **planazoo** (o el ID de tu proyecto).
4. En la columna **"Cuenta de facturación"**:
   - Si pone **"Facturación desactivada"** o está vacía:
     - En la fila del proyecto, abre el **menú de acciones** (⋮ o los tres puntos).
     - Elige **"Cambiar cuenta de facturación"** / **"Change billing"**.
     - Selecciona una **cuenta de facturación** existente (si tienes alguna).
     - Pulsa **"Establecer cuenta"** / **"Set account"**.
   - Si **no tienes ninguna cuenta de facturación**:
     - Ve a **[Crear cuenta de facturación](https://console.cloud.google.com/billing/create)**.
     - Sigue los pasos: país, aceptar términos, añadir método de pago (tarjeta). Google no cobra por el crédito gratuito que regala cada mes; solo cobra si superas el umbral.
     - Una vez creada la cuenta, vuelve a "Mis proyectos", localiza **planazoo** y vincula la cuenta con **"Cambiar cuenta de facturación"** → elegir la nueva cuenta → **"Establecer cuenta"**.

#### Opción B: Desde el propio proyecto

1. Asegúrate de tener seleccionado el proyecto **planazoo** (selector de proyecto arriba).
2. Menú ☰ → **Facturación** → **"Vincular una cuenta de facturación"** o **"Link a billing account"** (si aparece).
3. Elige la cuenta de facturación y confirma.

Comprobación: en **Facturación → Mis proyectos**, la fila de **planazoo** debe mostrar el nombre de una cuenta de facturación (no "Facturación desactivada").

### 2.5 API key para el proxy (Cloud Functions)

La **Browser key** suele estar restringida a "Referentes HTTP" (solo peticiones desde el navegador). Las Cloud Functions hacen la petición **desde el servidor**, por eso Google devuelve **403 Forbidden** si usas esa misma key en el proxy.

**Solución:** Crear una **segunda API key** solo para el servidor:

1. En [Credenciales](https://console.cloud.google.com/apis/credentials?project=planazoo) → **"+ Crear credenciales"** → **"Clave de API"**.
2. Edita la nueva clave:
   - **Restricciones de aplicación:** elige **"Ninguna"** (o "Direcciones IP" si quieres limitar a las IP de Cloud Functions; para desarrollo "Ninguna" es más simple).
   - **Restricciones de API:** "Restringir clave" y marca solo **Places API (New)** (y Places API si usas la clásica).
3. Copia la nueva key y configúrala en Firebase:
   ```bash
   npx firebase functions:config:set places.api_key="LA_NUEVA_KEY_AQUI"
   ```
4. Vuelve a desplegar la function (o ya está desplegada; la config se lee en cada ejecución):
   ```bash
   npx firebase deploy --only functions:placesAutocomplete,functions:placesDetails
   ```

Así la **Browser key** sigue solo en el cliente (si la usas en móvil) y la **nueva key** solo en el servidor; no la expongas en el front.

### 2.6 Proxy en Cloud Functions (necesario para Flutter web)

La API REST de Places **no permite CORS** desde el navegador, por eso las peticiones directas desde Flutter web fallan. La app usa **Cloud Functions** como proxy cuando se ejecuta en web. Usa una **API key de servidor** (ver § 2.5), no la Browser key.

1. **Configurar la API key en las functions** (key de servidor, § 2.5):
   ```bash
   npx firebase functions:config:set places.api_key="TU_KEY_DE_SERVIDOR_AQUI"
   ```
2. **Desplegar las functions** que hacen de proxy (`placesAutocomplete` y `placesDetails`):
   ```bash
   npx firebase deploy --only functions:placesAutocomplete,functions:placesDetails
   ```
   (O desplegar todas: `npx firebase deploy --only functions`.)

En la app, en **web** se llama a estas functions (el usuario debe estar **logueado**). En **móvil** (iOS/Android) se puede seguir usando la API directa con `--dart-define=PLACES_API_KEY=...` si se desea.

### 2.2 Habilitar las APIs necesarias

1. **APIs y servicios** → **Biblioteca**.
2. Busca **"Places API (New)"** (recomendada) o **"Places API"** (clásica).
3. Entra en la API y pulsa **"Habilitar"**.
4. (Opcional para web) Si usas componentes de mapa en web más adelante: busca **"Maps JavaScript API"** y habilítala también.

**Nota:** Tras habilitar Places API (New), la consola puede mostrar una larga lista de otras APIs (calidad del aire, solar, etc.). **No hace falta activar ninguna de esas** para autocompletado y detalles de lugar; solo necesitas "Places API (New)" (o "Places API" clásica) habilitada.

### 2.3 Crear una API key solo para Places (recomendado)

Usar una clave **dedicada** para Places (y Maps) permite restringirla y rotarla sin afectar Firebase.

1. **APIs y servicios** → **Credenciales**.
2. **"+ Crear credenciales"** → **"Clave de API"**.
3. Se crea la clave. **Cópiala** y guárdala en un lugar seguro (no la subas a Git).
4. Para **restringir la clave** (buena práctica):
   - Haz clic en el nombre de la clave recién creada (o en el lápiz).
   - **Restricciones de aplicación:**
     - **Web:** "Referentes HTTP" y añade los orígenes, por ejemplo:
       - `https://tu-dominio.com/*`
       - `http://localhost:*` (desarrollo)
       - Para Flutter web en debug: `http://localhost:*`
     - **Android:** "Aplicaciones Android" y añade nombre del paquete + huella SHA-1 si usas Android.
     - **iOS:** "Aplicaciones iOS" y añade el ID de paquete si usas iOS.
   - **Restricciones de API:** elige "Restringir clave" y marca solo:
     - **Places API (New)** y/o **Places API**
     - (Opcional) **Maps JavaScript API** si la usas.
5. Guarda los cambios.

### 2.4 Uso de la clave en la app (sin subirla a Git)

- **No** poner la clave en `firebase_options.dart` ni en ningún archivo versionado.
- La app lee la clave con `String.fromEnvironment('PLACES_API_KEY', defaultValue: '')`. Para inyectarla:

  **Al ejecutar o compilar**, pasa la clave con `--dart-define`:

  ```bash
  flutter run --dart-define=PLACES_API_KEY=TU_BROWSER_KEY_AQUI
  ```

  Para **web** (producción):

  ```bash
  flutter build web --dart-define=PLACES_API_KEY=TU_BROWSER_KEY_AQUI
  ```

  Si no pasas `PLACES_API_KEY`, el campo de búsqueda de lugar se muestra pero no se envían peticiones (no habrá autocompletado). Así puedes desarrollar sin clave; para probar Places, usa la Browser key con `--dart-define`.

---

## 3. Resumen: estado actual de tu proyecto

Tras seguir la sección 1 puedes rellenar:

| Comprobación | Estado (marca cuando lo compruebes) |
|--------------|-------------------------------------|
| Proyecto Google Cloud usado: **planazoo** | ☐ |
| Hay al menos una API key en Credenciales | ☐ Sí  ☐ No |
| Places API (o Places API (New)) habilitada | ☐ Sí  ☐ No |
| Facturación vinculada al proyecto | ☐ Sí  ☐ No |
| Clave dedicada para Places creada y restringida | ☐ Sí  ☐ No  ☐ No aplica |

Si todas las casillas están en "Sí" (o "No aplica" donde corresponda), puedes pasar a la parte de implementación en el código (Fase 1 de `docs/tareas/T225_GOOGLE_PLACES_PLAN.md`).

---

## 4. Enlaces útiles

- [Credenciales (API keys) – Google Cloud](https://console.cloud.google.com/apis/credentials?project=planazoo)
- [Biblioteca de APIs](https://console.cloud.google.com/apis/library?project=planazoo)
- [Places API (New) – Documentación](https://developers.google.com/maps/documentation/places/web-service/overview)
- [Restricción de API keys](https://cloud.google.com/docs/authentication/api-keys#adding_api_restrictions)
- [Facturación y crédito gratis – Maps Platform](https://developers.google.com/maps/billing-and-pricing)

---

*Última actualización: Febrero 2026*
