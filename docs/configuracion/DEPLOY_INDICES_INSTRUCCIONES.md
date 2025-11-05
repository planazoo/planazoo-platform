# 🚀 Instrucciones para Desplegar Índices de Firestore

> **Objetivo:** Desplegar los 25 índices nuevos y eliminar los obsoletos

---

## 📋 Paso 1: Desplegar Índices Nuevos

### Opción A: Usando Firebase CLI (Terminal)

```bash
# Asegúrate de estar en el directorio del proyecto
cd C:\Users\cclaraso\unp_calendario

# Desplegar solo los índices
firebase deploy --only firestore:indexes
```

**Si no tienes Firebase CLI instalado:**
```bash
# Instalar Firebase CLI globalmente
npm install -g firebase-tools

# Luego hacer login
firebase login

# Finalmente desplegar
firebase deploy --only firestore:indexes
```

### Opción B: Desde Firebase Console (Web) ⭐ **RECOMENDADO SI NO TIENES CLI**

**Ver guía detallada paso a paso:** `DEPLOY_INDICES_FIREBASE_CONSOLE.md`

**Resumen rápido:**

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Firestore Database** → **Indexes**
4. Sigue la guía detallada en `DEPLOY_INDICES_FIREBASE_CONSOLE.md` para crear los 25 índices uno por uno

**⚠️ NOTA:** La opción A (CLI) es más rápida porque despliega todos los índices de una vez. La opción B requiere crear cada índice manualmente pero no requiere instalar nada.

---

## 🗑️ Paso 2: Eliminar Índices Obsoletos

Los índices obsoletos son aquellos que:
- Están en Firebase pero NO están en `firestore.indexes.json`
- No tienen queries asociadas en el código actual

### Cómo Identificar Índices Obsoletos

#### Método 1: Comparar Manualmente

1. **En Firebase Console:**
   - Ve a **Firestore Database** → **Indexes**
   - Lista todos los índices existentes

2. **En el proyecto:**
   - Abre `firestore.indexes.json`
   - Compara: si un índice está en Firebase pero NO en el archivo → es obsoleto

#### Método 2: Usando Firebase CLI

```bash
# Listar índices actuales en Firebase
firebase firestore:indexes

# Comparar con el archivo local
# Los que aparezcan en Firebase pero no en firestore.indexes.json son obsoletos
```

### Eliminar Índices Obsoletos

**Desde Firebase Console:**

1. Ve a **Firestore Database** → **Indexes**
2. Para cada índice obsoleto:
   - Haz clic en el índice
   - Haz clic en **"Delete Index"** o **"Eliminar"**
   - Confirma la eliminación

**⚠️ PRECAUCIÓN:**
- Asegúrate de que el índice realmente no se usa antes de eliminarlo
- Si no estás seguro, déjalo (los índices no usados no consumen recursos activos, solo ocupan espacio en la lista)
- Si lo eliminas por error, se puede recrear fácilmente

---

## 📊 Estado Actual de Índices

### Índices Definidos en `firestore.indexes.json` (25 totales)

**Después del deploy, estos serán los únicos índices activos en Firebase:**

1. **plans** (2 índices)
2. **events** (3 índices)
3. **plan_participations** (5 índices)
4. **planInvitations** (4 índices)
5. **event_participants** (5 índices)
6. **personal_payments** (3 índices)
7. **participant_groups** (1 índice)
8. **users** (2 índices)

### Índices que PODRÍAN estar obsoletos (verificar antes de eliminar)

Si encuentras alguno de estos en Firebase y NO está en la lista de arriba, probablemente es obsoleto:

- Índices antiguos de versiones anteriores del código
- Índices creados manualmente en Firebase Console que ya no se usan
- Índices de colecciones que ya no existen

**Recomendación:** Revisa manualmente cada índice en Firebase Console antes de eliminarlo.

---

## ✅ Checklist Post-Deploy

- [ ] Índices desplegados correctamente (25 índices en total)
- [ ] Verificar en Firebase Console que todos los índices están "Building" o "Enabled"
- [ ] Revisar índices obsoletos en Firebase Console
- [ ] Eliminar índices obsoletos (solo si estás seguro de que no se usan)
- [ ] Probar la app para verificar que no hay errores de "missing index"
- [ ] Verificar logs de la app para asegurar que las queries funcionan correctamente

---

## 🔍 Verificar que los Índices Funcionan

### Después del deploy, prueba estas funcionalidades:

1. **Calendario:**
   - Abrir un plan y ver eventos → Usa índice de `events`
   - Ver alojamientos → Usa índice de alojamientos

2. **Dashboard:**
   - Listar planes del usuario → Usa índice de `plan_participations`
   - Ver planes ordenados por fecha → Usa índice de `plans`

3. **Participantes:**
   - Ver lista de participantes → Usa índices de `plan_participations`
   - Ver participantes de eventos → Usa índices de `event_participants`

4. **Pagos:**
   - Ver resumen de pagos → Usa índices de `personal_payments`

Si alguna de estas funcionalidades da error "missing index", revisa que el índice correspondiente se haya desplegado correctamente.

---

## 📝 Notas Importantes

1. **Tiempo de creación:** Los índices pueden tardar varios minutos en crearse. Firebase los crea en background.

2. **Estado de índices:** En Firebase Console puedes ver el estado:
   - **Building** → Se está creando, espera
   - **Enabled** → Listo para usar ✅
   - **Error** → Hay un problema, revisa la configuración

3. **No eliminar índices en uso:** Si eliminas un índice que se está usando, las queries fallarán inmediatamente.

4. **Backup:** Antes de eliminar índices, toma nota de cuáles eliminas por si necesitas recrearlos.

---

**Nota:** La instalación de Firebase CLI y actualización de índices se realizará durante la migración a Mac/iOS (T155, T156). Ver TASKS.md para más detalles.

**Fecha de creación:** Enero 2025  
**Relacionado con:** T152, T154, T155, T156

