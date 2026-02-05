# 🔧 Comandos para Configurar Gmail SMTP

## 📋 Ejecuta estos comandos en tu terminal

**Opción 1: Usar `npx` (recomendado - no requiere instalación global)**

Copia y pega estos comandos **uno por uno** en tu terminal:

```bash
# 1. Configurar email de Gmail
npx firebase-tools functions:config:set gmail.user="unplanazoo@gmail.com"

# 2. Configurar App Password
npx firebase-tools functions:config:set gmail.password="wnyn yinh uefh dwcf"

# 3. Configurar email remitente
npx firebase-tools functions:config:set gmail.from="unplanazoo@gmail.com"

# 4. Configurar URL base para desarrollo local
npx firebase-tools functions:config:set app.base_url="http://localhost:60508"

# 5. Verificar la configuración
npx firebase-tools functions:config:get
```

**Opción 2: Si prefieres instalar globalmente con sudo (menos recomendado)**

```bash
sudo npm install -g firebase-tools
firebase login
```

Luego ejecuta los comandos con `firebase` en lugar de `npx firebase-tools`:

```bash
firebase functions:config:set gmail.user="unplanazoo@gmail.com"
firebase functions:config:set gmail.password="wnyn yinh uefh dwcf"
firebase functions:config:set gmail.from="unplanazoo@gmail.com"
firebase functions:config:set app.base_url="http://localhost:60508"
firebase functions:config:get
```

## ✅ Después de ejecutar estos comandos

Si todo está bien, deberías ver algo como:

```json
{
  "gmail": {
    "user": "unplanazoo@gmail.com",
    "password": "wnyn yinh uefh dwcf",
    "from": "unplanazoo@gmail.com"
  },
  "app": {
    "base_url": "http://localhost:60508"
  }
}
```

## 🔐 Si te pide login

Si al ejecutar los comandos te pide hacer login, ejecuta:

```bash
npx firebase-tools login
```

O si usas la opción 2:

```bash
firebase login
```

---

**Una vez que hayas ejecutado estos comandos y veas la configuración correcta, avísame y continuamos con el Paso 3 (instalar dependencias).**
