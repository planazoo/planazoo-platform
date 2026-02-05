# 🔧 Desplegar Reglas de Firestore para Planes

## Cambio realizado

Se actualizaron las reglas de `plans` para permitir lectura pública, permitiendo que usuarios no autenticados puedan ver los detalles del plan cuando acceden desde una invitación.

## Desplegar

Ejecuta este comando:

```bash
npx firebase-tools deploy --only firestore:rules
```

## Verificar

Después de desplegar, prueba de nuevo:
1. Copia el token del link del email
2. Navega a: `http://localhost:TU_PUERTO/invitation/TOKEN`
3. Deberías poder ver la invitación Y los detalles del plan
