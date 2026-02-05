# 🔧 Corregir Credenciales de Gmail SMTP

## ❌ Error Actual

```
Error: Invalid login: 535-5.7.8 Username and Password not accepted
```

## ✅ Solución

### Paso 1: Verificar configuración actual

```bash
npx firebase-tools functions:config:get
```

Verifica que:
- `gmail.user` = tu email correcto
- `gmail.password` = App Password correcta (16 caracteres, sin espacios extra)
- `gmail.from` = tu email correcto

### Paso 2: Verificar App Password

1. Ve a: https://myaccount.google.com/apppasswords
2. Verifica que la App Password "Firebase Functions" existe
3. Si no existe o fue eliminada, genera una nueva

### Paso 3: Regenerar App Password (si es necesario)

1. Ve a: https://myaccount.google.com/apppasswords
2. Elimina la App Password antigua (si existe)
3. Genera una nueva:
   - App: "Mail"
   - Device: "Other (Custom name)" → "Firebase Functions"
4. **Copia la nueva contraseña** (16 caracteres)

### Paso 4: Actualizar configuración

```bash
# Actualizar App Password (reemplaza con la nueva)
npx firebase-tools functions:config:set gmail.password="NUEVA_APP_PASSWORD_AQUI"

# Verificar que se actualizó
npx firebase-tools functions:config:get
```

### Paso 5: Redesplegar la función

```bash
npx firebase-tools deploy --only functions:sendInvitationEmail
```

### Paso 6: Probar de nuevo

1. Crea una nueva invitación desde la app
2. Verifica los logs:
   ```bash
   npx firebase-tools functions:log --only sendInvitationEmail
   ```
3. Deberías ver: `Invitation email sent via Gmail SMTP to...`

---

## ⚠️ Notas Importantes

- La App Password debe tener **exactamente 16 caracteres**
- Puede tener espacios (ej: `wnyn yinh uefh dwcf`) o no tenerlos (ej: `wnynyinhuefhdwcf`)
- Si copias con espacios, asegúrate de copiar TODOS los espacios correctamente
- Si la App Password no funciona, genera una nueva

---

## 🔍 Verificar que la App Password es correcta

La App Password debe verse así:
- Con espacios: `wnyn yinh uefh dwcf` (4 grupos de 4 caracteres)
- Sin espacios: `wnynyinhuefhdwcf` (16 caracteres seguidos)

Ambas formas deberían funcionar, pero asegúrate de copiarla exactamente como aparece.
