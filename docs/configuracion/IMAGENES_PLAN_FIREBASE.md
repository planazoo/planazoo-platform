# Imágenes de perfil de plan – Firebase Storage (configuración y troubleshooting)

Documentación para desarrolladores: dónde se guardan las imágenes, cómo está implementada la subida (web y móvil), y qué configurar (reglas, CORS, bucket).

---

## 1. Resumen

- **Dónde se guardan:** Firebase Storage, carpeta `plan_images/`. Nombre de archivo: `{planId}_{timestamp}.{ext}` (ej. `abc123_1771157362173.webp`).
- **Dónde se guarda la URL:** Firestore, documento del plan, campo `imageUrl`.
- **Dónde se sube en la app:** Pantalla de datos del plan (W14) → botón de cámara / "Cambiar imagen".

---

## 2. Configuración en el proyecto

### 2.1 Bucket de Storage (`lib/firebase_options.dart`)

El campo **`storageBucket`** debe coincidir con el bucket que aparece en Firebase Console → Storage.

- En este proyecto: **`planazoo.firebasestorage.app`**.
- Si en la consola ves otro (ej. `planazoo.appspot.com`), usa ese mismo valor en `firebase_options.dart`.

Si el bucket en la app no coincide con el de la consola (y con el que tiene CORS), la subida en web puede quedarse colgada sin error claro.

### 2.2 Reglas de Storage (`storage.rules`)

Las reglas permiten:

- **Lectura** de `plan_images/`: pública (para que las URLs de imagen carguen en la UI).
- **Escritura** en `plan_images/`: solo usuarios autenticados (`request.auth != null`).

Desplegar reglas:

```bash
npx firebase deploy --only storage
```

El proyecto ya tiene `storage.rules` y está referenciado en `firebase.json`.

### 2.3 CORS (solo para subida desde **web**)

En web, el navegador hace la petición a Storage. Si el bucket no tiene CORS configurado, la subida puede **quedarse colgada** en `putData()` (ni éxito ni excepción).

**Síntoma:** En consola se ve hasta "llamando ref.putData()..." y no aparece "putData OK" ni error.

**Solución:** Configurar CORS en el **mismo bucket** que usa la app (el de `firebase_options.dart`).

- Archivo de ejemplo en el repo: **`storage.cors.json`** (raíz del proyecto).
- Guía paso a paso: **`docs/configuracion/STORAGE_CORS.md`**.
- Comando (sustituir por tu bucket si es distinto):

```bash
gcloud config set project planazoo
gcloud storage buckets update gs://planazoo.firebasestorage.app --cors-file=storage.cors.json
```

CORS se aplica por bucket; si cambias de bucket en `firebase_options.dart`, hay que aplicar CORS también a ese bucket.

---

## 3. Implementación en código

### 3.1 Servicio: `lib/features/calendar/domain/services/image_service.dart`

- **Selección:** `pickImageFromGallery()` (galería en móvil, selector de archivos en web).
- **Validación:** tamaño máximo 2 MB, formatos JPG/JPEG/PNG/WEBP.
- **Subida:** `uploadPlanImage(XFile, planId)`:
  - Usa **bytes** (`readAsBytes()`) y **`putData()`**, no `File` ni `putFile()`, para funcionar en **web** (sin `dart:io`).
  - Content-Type según extensión (image/jpeg, image/png, image/webp).
- **Eliminación:** `deletePlanImage(imageUrl)` para borrar en Storage cuando se quita la imagen o se elimina el plan.

### 3.2 UI: pantalla del plan

- **`lib/widgets/screens/wd_plan_data_screen.dart`**:
  - Vista previa: si hay imagen seleccionada reciente se usa **`Image.memory(bytes)`** (compatible con web); si no, **`CachedNetworkImage`** con `plan.imageUrl`.
  - Al elegir imagen: validar → subir con `ImageService.uploadPlanImage` → actualizar plan con `planService.updatePlan(plan.copyWith(imageUrl: ...))`.
  - Estado de carga y errores con SnackBar.

### 3.3 Dónde se muestra la imagen del plan

- **W5** (header del dashboard): `wd_dashboard_header_bar.dart`.
- **Lista de planes (W28):** `wd_plan_card_widget.dart`.
- **Pantalla de datos del plan (W14):** `wd_plan_data_screen.dart` (imagen grande + botón subir/cambiar).

Todos usan `plan.imageUrl` con `CachedNetworkImage` (y `ImageService.isValidImageUrl` cuando aplica).

---

## 4. Checklist para un entorno nuevo o nuevo bucket

1. **Firebase Console → Storage:** crear bucket si no existe; anotar nombre (ej. `planazoo.firebasestorage.app`).
2. **`lib/firebase_options.dart`:** `storageBucket` = ese nombre.
3. **Reglas:** tener `storage.rules` con `plan_images/` (read público, write autenticado) y desplegar con `firebase deploy --only storage`.
4. **CORS (solo web):** aplicar `storage.cors.json` al mismo bucket con `gcloud storage buckets update gs://TU_BUCKET --cors-file=storage.cors.json`.
5. **Probar:** subir una imagen desde la app web; si se cuelga en `putData`, revisar bucket y CORS.

---

## 5. Referencias rápidas

| Tema        | Archivo / Ubicación |
|------------|----------------------|
| Bucket     | `lib/firebase_options.dart` → `storageBucket` |
| Reglas     | `storage.rules` |
| CORS       | `storage.cors.json`, `docs/configuracion/STORAGE_CORS.md` |
| Lógica     | `lib/features/calendar/domain/services/image_service.dart` |
| UI subida  | `lib/widgets/screens/wd_plan_data_screen.dart` (_pickImage, _buildPlanImage) |
| Modelo     | `lib/features/calendar/domain/models/plan.dart` → `imageUrl` |

Documento de producto/UX: `docs/ux/plan_image_management.md`.
