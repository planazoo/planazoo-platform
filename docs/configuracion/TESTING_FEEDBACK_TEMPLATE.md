# 📝 Template para Feedback de Testing

## 📋 Formato de Feedback

Usa este formato para proporcionar feedback de cada caso de prueba:

### Formato Simple (Recomendado)

```
ID: REG-001
Estado: ✅ Pasado | ❌ Fallido | ⚠️ Parcial | 🔄 Pendiente
Notas: [Comentarios opcionales]
```

### Formato Completo (Para casos con problemas)

```
ID: REG-001
Estado: ❌ Fallido
Descripción: [Qué pasó]
Pasos para reproducir: [Si aplica]
Error/Comportamiento: [Qué salió mal]
Screenshots: [Si aplica]
```

## 📤 Ejemplos

### Ejemplo 1: Caso que pasa
```
ID: REG-001
Estado: ✅ Pasado
```

### Ejemplo 2: Caso con problema menor
```
ID: REG-002
Estado: ⚠️ Parcial
Notas: El error aparece pero el mensaje no es muy claro
```

### Ejemplo 3: Caso que falla
```
ID: REG-003
Estado: ❌ Fallido
Descripción: La validación de contraseña no funciona
Pasos: Intenté crear cuenta con contraseña "123" y se creó sin error
Error: No muestra validación de contraseña débil
```

### Ejemplo 4: Caso pendiente
```
ID: REG-004
Estado: 🔄 Pendiente
Notas: No puedo probarlo porque falta funcionalidad X
```

## 📋 Procesamiento en Lote

Puedes proporcionar múltiples casos en un solo mensaje:

```
REG-001: ✅ Pasado
REG-002: ❌ Fallido - El mensaje de error no es claro
REG-003: ✅ Pasado
REG-004: ⚠️ Parcial - Funciona pero el feedback visual es lento
```

O por secciones:

```
## 1. AUTENTICACIÓN Y REGISTRO

### 1.1 Registro de Usuario
REG-001: ✅ Pasado
REG-002: ❌ Fallido - Ver descripción arriba
REG-003: ✅ Pasado
REG-004: ✅ Pasado
REG-005: ⚠️ Parcial

### 1.2 Inicio de Sesión
LOG-001: ✅ Pasado
LOG-002: ✅ Pasado
...
```

## 🎯 Ventajas de este Formato

1. **Fácil de procesar:** Puedo actualizar el checklist automáticamente
2. **Escalable:** Puedes hacerlo por secciones o todo junto
3. **Flexible:** Puedes añadir detalles cuando sea necesario
4. **Rastreable:** Cada ID se puede referenciar fácilmente

## 📝 Notas Importantes

- **IDs deben coincidir exactamente** con los del checklist (ej: `REG-001`, no `REG-1`)
- **Estados disponibles:**
  - ✅ Pasado
  - ❌ Fallido
  - ⚠️ Parcial
  - 🔄 Pendiente
- **Puedes omitir notas** si el caso pasa sin problemas
- **Para casos fallidos**, añade detalles para poder corregirlos

---

**Última actualización:** Enero 2025

