# Terminales de desarrollo (web / iOS / Android)

Fuente de verdad para **recrear las 3 terminales** de `flutter run` en paralelo.

**Cómo usarlo:** al abrir Cursor (o cuando falten las pestañas), di al agente:  
**«recrea las terminales»** / **«arranca web iOS Android»**.

El agente debe:
1. Leer este archivo.
2. Ejecutar `flutter devices` (y `adb devices` si Android no aparece).
3. Lanzar **las 3** sesiones en la raíz del repo, en paralelo, en background.
4. Si un device ID no está en `flutter devices`, usar el ID actual del mismo tipo (iPhone / Android / chrome) y avisar.

Detalle de usuarios de prueba y cables: [`USUARIOS_PRUEBA.md`](./USUARIOS_PRUEBA.md).  
Setup Android: [`SETUP_ANDROID_LOCAL.md`](./SETUP_ANDROID_LOCAL.md).  
Setup iOS: [`SETUP_IOS_SIMULATOR.md`](./SETUP_IOS_SIMULATOR.md).

---

## Sesiones

| Nombre | Plataforma | Comando |
|--------|------------|---------|
| `web` | Chrome | `flutter run -d chrome` |
| `iOS` | iPhone físico | `flutter run -d 00008030-001869E83699402E` |
| `Android` | Android físico | `flutter run -d RZ8NC11FRPJ` |

### Comandos (copiar / ejecutar)

```bash
# cwd: raíz del repo (unp_calendario)

# web
flutter run -d chrome

# iOS — iPhone físico (actualizar ID si cambia en `flutter devices`)
flutter run -d 00008030-001869E83699402E

# Android — físico (ej. SM A715F; actualizar ID si cambia)
flutter run -d RZ8NC11FRPJ
```

---

## Notas

- Cada plataforma en **su** terminal; no encadenar los tres en una sola.
- Si un dispositivo no está conectado, **no** sustituir por simulador/emulador salvo que el usuario lo pida.
- Tras recrear, los `flutter run` suelen necesitar hot restart / relanzado aunque Cursor restaure pestañas vacías.
- Actualiza los device IDs en esta tabla cuando cambien de forma estable.
