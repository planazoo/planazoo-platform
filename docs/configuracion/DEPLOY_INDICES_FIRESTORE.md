# 🚀 Desplegar Índices de Firestore

> **Objetivo:** Desplegar los índices necesarios para que las queries de Firestore funcionen correctamente

---

## 📋 Método Recomendado: Firebase CLI (Terminal)

### Paso 1: Verificar Firebase CLI

```bash
# Verificar si está instalado
npx firebase-tools --version

# Si no está instalado, hacer login primero
npx firebase-tools login
```

### Paso 2: Seleccionar Proyecto

```bash
# Ver proyectos disponibles
npx firebase-tools projects:list

# Seleccionar tu proyecto
npx firebase-tools use planazoo
```

### Paso 3: Desplegar Índices

```bash
# Desde la raíz del proyecto
npx firebase-tools deploy --only firestore:indexes
```

**Resultado esperado:**
```
✔  firestore: deployed indexes in firestore.indexes.json successfully
```

### Paso 4: Verificar Despliegue

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Firestore Database** → **Indexes**
4. Verifica que los índices aparecen con estado "Building" o "Enabled"

---

## 📋 Método Alternativo: Firebase Console (Manual)

Si prefieres crear los índices manualmente desde la web:

### Paso 1: Abrir Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. En el menú lateral, ve a **Firestore Database**
4. Haz clic en la pestaña **Indexes**

### Paso 2: Crear Índices Manualmente

Para cada índice en `firestore.indexes.json`:

1. Haz clic en **"Add Index"** o **"Crear índice"**
2. Ingresa la **Collection ID**
3. Añade los campos según la configuración del índice
4. Haz clic en **"Create"**

**Nota:** Este método es más lento pero no requiere Firebase CLI instalado.

---

## 🗑️ Eliminar Índices Obsoletos

Firebase puede mostrar índices que ya no se usan. Para eliminarlos:

### Desde Firebase Console

1. Ve a **Firestore Database** → **Indexes**
2. Para cada índice obsoleto:
   - Haz clic en el índice
   - Haz clic en **"Delete Index"** o **"Eliminar"**
   - Confirma la eliminación

**⚠️ PRECAUCIÓN:**
- Asegúrate de que el índice realmente no se usa antes de eliminarlo
- Si no estás seguro, déjalo (los índices no usados no consumen recursos activos)

---

## 📊 Índices Definidos

Los índices están definidos en `firestore.indexes.json` y cubren:

- **plans**: Ordenamiento por fecha y usuario
- **events**: Búsquedas por plan, fecha, tipo
- **plan_participations**: Participaciones por usuario y plan
- **plan_invitations**: Invitaciones por email y estado
- **event_participants**: Participantes de eventos
- **personal_payments**: Pagos por plan y fecha
- **kitty_contributions**: Aportaciones al bote por plan y fecha (T219)
- **kitty_expenses**: Gastos del bote por plan y fecha (T219)
- **participant_groups**: Grupos de participantes
- **users**: Usuarios activos

---

## ✅ Verificar que Funcionan

Después del deploy, prueba estas funcionalidades:

1. **Calendario:** Abrir un plan y ver eventos
2. **Dashboard:** Listar planes del usuario
3. **Participantes:** Ver lista de participantes
4. **Pagos:** Ver resumen de pagos

Si alguna funcionalidad da error "missing index", revisa que el índice correspondiente se haya desplegado correctamente.

---

## 📝 Notas Importantes

1. **Tiempo de creación:** Los índices pueden tardar varios minutos en crearse
2. **Estado de índices:**
   - **Building** → Se está creando, espera
   - **Enabled** → Listo para usar ✅
   - **Error** → Hay un problema, revisa la configuración
3. **No eliminar índices en uso:** Si eliminas un índice que se está usando, las queries fallarán inmediatamente

---

*Última actualización: Febrero 2026*
