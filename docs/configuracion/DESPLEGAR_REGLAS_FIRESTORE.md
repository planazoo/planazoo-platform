# 🔧 Desplegar Reglas de Firestore

## Cambio realizado

Se actualizaron las reglas de `plan_invitations` para permitir lectura pública de invitaciones pendientes, permitiendo que usuarios no autenticados puedan ver su invitación usando el token del email.

## Desplegar

Ejecuta este comando:

```bash
npx firebase-tools deploy --only firestore:rules
```

## Verificar

Después de desplegar, prueba de nuevo:
1. Copia el token del link del email
2. Navega a: `http://localhost:TU_PUERTO/invitation/TOKEN`
3. Deberías poder ver la invitación
