# 🚀 Despliegue de la Aplicación Web en Firebase Hosting

Este documento describe el **primer** despliegue de Flutter web en Firebase Hosting (login CLI, `init hosting`).  
**Cada versión nueva:** [`PUBLICAR_APP.md`](./PUBLICAR_APP.md) (incluye `dart-define` y backend).

**Fecha de creación:** Enero 2025  
**Última actualización:** Sep 2026  
**URL canónica:** `https://app.planoon.com` (Hosting también en `https://planazoo.web.app`)

---

## 📋 Requisitos Previos

1. **Proyecto Firebase configurado**
   - Proyecto creado en Firebase Console
   - ID del proyecto conocido (en este caso: `planazoo`)

2. **Node.js y npm instalados**
   - Node.js versión 24.13.0 o superior
   - npm versión 11.6.2 o superior
   - Verificar con: `node --version` y `npm --version`

3. **Flutter configurado para web**
   - Flutter SDK instalado
   - Soporte web habilitado: `flutter config --enable-web`

---

## 🔧 Paso 1: Instalación de Node.js y npm

Si no tienes Node.js instalado:

1. Descargar desde: https://nodejs.org/
2. Instalar siguiendo el asistente
3. Verificar instalación:
   ```bash
   node --version
   npm --version
   ```

---

## 🔧 Paso 2: Instalación de Firebase CLI

**⚠️ Nota importante:** Para evitar problemas de permisos en macOS, usamos `npx` en lugar de instalar globalmente.

### Opción A: Usando npx (Recomendado - Sin instalación global)

No requiere instalación. Simplemente usar `npx firebase-tools@latest` en lugar de `firebase` en todos los comandos.

### Opción B: Instalación global (Puede requerir permisos)

```bash
npm install -g firebase-tools
```

**Si aparece error `EACCES` (permisos denegados):**
- Usar la Opción A (npx) en su lugar
- O instalar con `sudo npm install -g firebase-tools` (no recomendado)

---

## 🔧 Paso 3: Login en Firebase

Ejecutar desde cualquier directorio:

```bash
npx firebase-tools@latest login
```

- Se abrirá el navegador para autenticarse con tu cuenta de Google
- Confirmar permisos en el navegador
- Verificar que el login fue exitoso

---

## 🔧 Paso 4: Asociar el Proyecto Local con Firebase

1. **Listar proyectos disponibles:**
   ```bash
   npx firebase-tools@latest projects:list
   ```

2. **Asociar el proyecto (usar el ID del proyecto):**
   ```bash
   npx firebase-tools@latest use planazoo
   ```
   Reemplazar `planazoo` con el ID de tu proyecto si es diferente.

3. **Verificar asociación:**
   - Se creará/actualizará el archivo `.firebaserc` en la raíz del proyecto
   - Debe contener: `"default": "planazoo"`

---

## 🔧 Paso 5: Inicializar Firebase Hosting

Desde la raíz del proyecto (`unp_calendario`):

```bash
npx firebase-tools@latest init hosting
```

**Opciones durante la inicialización:**

1. **¿Qué directorio público usar?**
   - Respuesta: `build/web`
   - Este es el directorio donde Flutter genera los archivos web compilados

2. **¿Configurar como single-page app?**
   - Respuesta: `Yes` (Sí)
   - Necesario para que Flutter maneje las rutas correctamente

3. **¿Configurar GitHub para despliegues automáticos?**
   - Respuesta: `No` (por ahora)
   - Se puede configurar más adelante si se desea CI/CD

**Resultado:**
- Se crea `firebase.json` con la configuración de hosting
- Se actualiza `.firebaserc` si no existía

---

## 🔧 Paso 6: Compilar la Aplicación Flutter para Web

Desde la raíz del proyecto:

```bash
export PLACES_API_KEY  # valor: ACCESOS_Y_CUENTAS.md § Places
flutter build web --dart-define=PLACES_API_KEY="$PLACES_API_KEY"
```

**Tiempo estimado:** 1-2 minutos

**Resultado:**
- Se genera el directorio `build/web/` con todos los archivos estáticos
- Incluye HTML, CSS, JavaScript y assets optimizados

**Notas:**
- Sin `PLACES_API_KEY` el mapa del plan no llama a Maps JavaScript.
- Advertencias WASM / `dart:html` (mapa web) son normales; el build JS sigue saliendo.
- Tree-shaking reduce el tamaño de los assets automáticamente

---

## 🔧 Paso 7: Desplegar a Firebase Hosting

Desde la raíz del proyecto:

```bash
npx firebase-tools@latest deploy --only hosting
```

**Proceso:**
1. Firebase sube los archivos de `build/web/`
2. Procesa y optimiza los archivos
3. Publica la nueva versión
4. Muestra las URLs de acceso

**Resultado esperado:**
```
✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/planazoo/overview
Hosting URL: https://planazoo.web.app
```

---

## ✅ Verificación Post-Despliegue

1. **Abrir la URL de producción:**
   - **`https://app.planoon.com`** (canónica)
   - `https://planazoo.web.app` (mismo Hosting)

2. **Probar funcionalidades básicas:**
   - Login con Google
   - Navegación entre páginas
   - Crear/editar eventos
   - Visualización de planes
   - Dashboard

3. **Verificar en diferentes navegadores:**
   - Chrome
   - Firefox
   - Safari
   - Edge

---

## 🔄 Actualizaciones Futuras

No uses esta guía para cada release. Ciclo: [`PUBLICAR_APP.md`](./PUBLICAR_APP.md).

---

## 🐛 Solución de Problemas

### Error: "firebase command not found"
**Solución:** Usar `npx firebase-tools@latest` en lugar de `firebase`

### Error: "EACCES: permission denied"
**Solución:** Usar `npx firebase-tools@latest` en lugar de instalar globalmente

### Error: "No Firebase project found"
**Solución:** 
1. Verificar que `.firebaserc` existe en la raíz del proyecto
2. Ejecutar: `npx firebase-tools@latest use planazoo`

### Error: "Directory build/web not found"
**Solución:** 
1. Ejecutar `flutter build web` primero
2. Verificar que `build/web/` existe antes de desplegar

### La aplicación no carga en producción
**Verificar:**
1. Consola del navegador (F12) para errores JavaScript
2. Firebase Console > Hosting > Ver logs de errores
3. Verificar que `firebase.json` tiene la configuración correcta:
   ```json
   {
     "hosting": {
       "public": "build/web",
       "ignore": [
         "firebase.json",
         "**/.*",
         "**/node_modules/**"
       ],
       "rewrites": [
         {
           "source": "**",
           "destination": "/index.html"
         }
       ]
     }
   }
   ```

---

## 📝 Archivos Generados

Después del proceso completo, estos archivos estarán en la raíz del proyecto:

- **`.firebaserc`**: Configuración del proyecto Firebase asociado
- **`firebase.json`**: Configuración de Firebase Hosting
- **`build/web/`**: Archivos compilados de la aplicación (no se sube a Git)

---

## 🔗 Referencias

- [Firebase Hosting Documentation](https://firebase.google.com/docs/hosting)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)

---

## 📌 Notas Importantes

1. **No subir `build/web/` a Git:** Este directorio se genera automáticamente y puede ser grande. Ya debería estar en `.gitignore`.

2. **Compilar antes de cada deploy:** Siempre ejecutar `flutter build web` antes de `deploy` para asegurar que los cambios están incluidos.

3. **URLs de producción:**
   - Canónica: `https://app.planoon.com`
   - Firebase: `https://planazoo.web.app` / `https://planazoo.firebaseapp.com`
   - Mismo Hosting. Guía dominio: [DOMINIO_PLANOON.md](./DOMINIO_PLANOON.md)

4. **Dominio personalizado:** **`app.planoon.com`** (app). Apex `planoon.com` reservado para comercial.
