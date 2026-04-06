# Tarea pendiente: agente de revisión `input.md` → `output.md`

**Estado:** no implementado — backlog para ejecutar cuando se decida.

---

## Objetivo

Agente (script ejecutable de forma periódica, p. ej. cada 30–60 min) que:

1. Lee el estado previo desde un fichero JSON.
2. Lee `input/input.md`.
3. Detecta si hubo cambios (hash del contenido actual).
4. Si no hay cambios: termina sin tocar salida ni estado (salvo opcionalmente timestamp de “último chequeo”).
5. Si hay cambios: identifica **solo el contenido nuevo** (delta), lo procesa según una lógica configurable y **acumula** el resultado en `output/output.md`.
6. Actualiza el estado para no reprocesar lo ya tratado (idempotencia, sin duplicados por ejecuciones repetidas).

---

## Estructura sugerida en el repo

Evitar el nombre genérico `project/` en la raíz; mejor un directorio explícito, por ejemplo:

```text
agent_md/
  input/input.md          # editable (móvil GitHub, desktop, etc.)
  output/output.md        # resultado acumulado
  state/state.json        # estado local (valorar .gitignore)
  scripts/main.py         # entrada del agente
  README.md               # cómo ejecutar y limitaciones
```

Opcional: `requirements.txt` si se añaden dependencias; con stdlib puede no hacer falta.

---

## Formato de `state.json` (propuesta)

```json
{
  "last_hash": "<sha256 del input completo en la última ejecución que procesó>",
  "last_processed_at": "<ISO-8601>",
  "last_length": 1234,
  "prefix_hash": "<sha256 de los bytes input[:last_length] al cerrar el procesamiento>"
}
```

- **Primera ejecución:** si no existe `state.json`, crear estado inicial coherente (p. ej. longitud 0 y `prefix_hash` del prefijo vacío).
- **Delta por append:** si el fichero solo crece por el final, verificar que el prefijo de longitud `last_length` sigue coincidiendo con `prefix_hash`; entonces `delta = contenido[last_length:]`.
- **Edición en medio o borrado:** el prefijo deja de coincidir; documentar política (p. ej. advertencia en log, tratar todo el archivo como nuevo una vez, o variable de entorno para resetear salida). Evitar duplicar salida sin criterio claro.

La spec original hablaba solo de hash y longitud; **añadir `prefix_hash`** reduce falsos positivos y aclara el modelo append-only frente a reescrituras.

---

## Reglas de producto

- No reprocesar contenido ya incorporado al flujo de salida.
- Ejecuciones repetidas sin cambios en `input.md` no deben duplicar bloques en `output.md`.
- Logging básico (stdout o fichero): sin cambios / delta detectado / error / resync.

---

## Lógica de procesamiento (placeholder)

Definir una función clara, por ejemplo `process_delta(delta: str) -> str`, que hoy puede ser:

- añadir marca temporal y el texto tal cual, o
- resumen / extracción de tareas / estructuración (ampliar después).

El resultado se **añade** a `output.md` (append) salvo política explícita de rewrite en resync.

---

## Automatización (Cursor u otro)

- **Cursor Automation** (u otro scheduler): tipo programado, cada 30–60 min, comando del estilo:

  `python3 agent_md/scripts/main.py`

- Alternativas futuras: webhook en lugar de polling, integración Notion/Docs, clasificación, etc. (solo mencionado en README cuando exista).

---

## Criterios de hecho (checklist)

- [ ] Árbol `agent_md/` con `input`, `output`, `state`, `scripts`.
- [ ] `main.py` con hash SHA-256, lectura/escritura de estado, manejo de estado inexistente.
- [ ] Detección de delta con modelo append + manejo documentado cuando el prefijo no coincide.
- [ ] Append idempotente a `output.md` en el caso nominal (solo crecimiento al final del input).
- [ ] README con instrucciones de ejecución y limitaciones.
- [ ] Decisión sobre si `state.json` va en `.gitignore` (recomendado para no mezclar estado local con el repo compartido).

---

## Notas (revisión respecto al borrador de otra IA)

- MD5 es suficiente para detección casual; **SHA-256** es preferible y está en stdlib Python.
- Solo `last_length` sin verificar el prefijo puede marcar mal el delta si alguien edita el principio del archivo.
- La automatización en Cursor hay que configurarla en el producto; el repo solo aporta el script y la documentación.
