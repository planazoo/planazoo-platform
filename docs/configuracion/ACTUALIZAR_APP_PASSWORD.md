# 🔧 Actualizar App Password de Gmail

## Nueva App Password

```
xnyk tzxj kgda zfge
```

## Comandos para ejecutar

```bash
# 1. Actualizar App Password
npx firebase-tools functions:config:set gmail.password="xnyk tzxj kgda zfge"

# 2. Verificar configuración
npx firebase-tools functions:config:get

# 3. Redesplegar la función
npx firebase-tools deploy --only functions:sendInvitationEmail

# 4. Probar creando una nueva invitación y luego verificar logs
npx firebase-tools functions:log --only sendInvitationEmail
```
