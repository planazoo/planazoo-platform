# 🔧 Configurar Gmail SMTP - Pasos Corregidos

## ⚠️ Importante

Firebase está deprecando `functions.config()`. Tenemos dos opciones:
- **Opción A (Rápida)**: Habilitar comandos legacy temporalmente
- **Opción B (Recomendada)**: Migrar a `params` (más moderno)

Vamos con la **Opción A** primero para que funcione rápido.

---

## 📋 Paso 1: Ir al directorio del proyecto

```bash
cd /Users/emmclaraso/development/unp_calendario
```

## 📋 Paso 2: Configurar proyecto de Firebase

```bash
# Ver proyectos disponibles
npx firebase-tools projects:list

# Seleccionar tu proyecto (reemplaza con tu project ID)
npx firebase-tools use TU_PROJECT_ID
```

O si no sabes el project ID, puedes iniciar sesión primero:

```bash
npx firebase-tools login
npx firebase-tools projects:list
```

## 📋 Paso 3: Habilitar comandos legacy temporalmente

```bash
npx firebase-tools experiments:enable legacyRuntimeConfigCommands
```

## 📋 Paso 4: Configurar Gmail SMTP

Ahora ejecuta estos comandos **uno por uno**:

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

---

## ✅ Verificación

Si todo está bien, deberías ver:

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

---

## 🔄 Alternativa: Usar params (Recomendado a largo plazo)

Si prefieres usar el nuevo sistema `params` (más moderno), podemos migrar después. Por ahora, la opción legacy funciona perfectamente.

---

**Ejecuta estos pasos y avísame cuando termines para continuar con el Paso 3 (instalar dependencias).**
