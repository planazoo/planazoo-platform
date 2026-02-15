# CORS para Firebase Storage (subida de imágenes desde la web)

Si la subida de imágenes **se queda colgada** en web (en consola se ve hasta `putData` y no aparece "putData OK" ni error), el navegador está bloqueando la petición por **CORS**. Hay que configurar CORS en el bucket que usa la app.

**Documentación completa del tema imágenes (bucket, reglas, CORS, código):** [IMAGENES_PLAN_FIREBASE.md](./IMAGENES_PLAN_FIREBASE.md).

---

## Bucket del proyecto planazoo

En este proyecto el bucket de Storage es **`planazoo.firebasestorage.app`**. Debe coincidir con `storageBucket` en `lib/firebase_options.dart`.

---

## Aplicar CORS al bucket

### Opción A: Desde tu máquina (con `gcloud` y el repo)

En la **raíz del proyecto** (donde está `storage.cors.json`):

```bash
gcloud config set project planazoo
gcloud storage buckets update gs://planazoo.firebasestorage.app --cors-file=storage.cors.json
```

### Opción B: Desde Google Cloud Shell (sin el repo local)

1. Abre [Google Cloud Console](https://console.cloud.google.com) → proyecto **planazoo** → Cloud Shell (icono `>_`).
2. Crea el archivo CORS:
   ```bash
   cat > storage.cors.json << 'EOF'
   [
     {
       "origin": ["*"],
       "method": ["GET", "HEAD", "PUT", "POST", "OPTIONS", "DELETE"],
       "responseHeader": ["Content-Type", "Authorization", "x-goog-resumable", "x-goog-meta-*"],
       "maxAgeSeconds": 3600
     }
   ]
   EOF
   ```
3. Aplica CORS:
   ```bash
   gcloud storage buckets update gs://planazoo.firebasestorage.app --cors-file=storage.cors.json
   ```

---

## Si tu bucket tiene otro nombre

En Firebase Console → Storage verás la URL del bucket (ej. `gs://planazoo.firebasestorage.app`). Usa ese nombre en el comando:

```bash
gcloud storage buckets update gs://TU_NOMBRE_BUCKET --cors-file=storage.cors.json
```

Y asegúrate de que **`lib/firebase_options.dart`** tenga el mismo valor en `storageBucket`.

---

## Producción

Puedes restringir `origin` en `storage.cors.json` a tus dominios, por ejemplo:

```json
"origin": ["https://tudominio.com", "https://www.tudominio.com", "http://localhost:5000"]
```

---

## Referencia

- [Configuring CORS (Firebase)](https://firebase.google.com/docs/storage/web/download-files#cors)
- [CORS configuration (Google Cloud)](https://cloud.google.com/storage/docs/configuring-cors)
