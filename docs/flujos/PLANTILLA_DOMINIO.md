# Plantilla de dominio (proceso → trabajo → prueba → referencia)

Usar esta plantilla para abrir o mantener cualquier dominio del sistema de procesos.

---

## 1) Identidad del dominio

- **Nombre del dominio:** `<dominio>`
- **Estado:** `WIP` / `activo sin WIP` / `cerrado`
- **Contrato vivo principal:** `<ruta md en docs/flujos/>`
- **Stubs/índices de apoyo:** `<rutas FLUJO_*.md>`

## 2) Proceso (fuente de verdad)

- **Contrato actual (qué manda):** `<ruta>`
- **Decisiones Acordado vigentes:** `<checklist corto o link>`
- **Fuera de alcance actual:** `<límites para no abrir frente extra>`

## 3) Trabajo (tareas)

- **Tareas activas del dominio (TASKS):** `Txxx, Tyyy...`
- **Tarea foco (si hay WIP):** `Txxx`
- **Specs de tarea (si aplica):** `docs/tareas/Txxx_*.md`

## 4) Prueba (QA/hallazgos)

- **Tabla viva de hallazgos:** `docs/testing/LISTA_PUNTOS_CORREGIR_APP.md`
- **Checklist operativo asociado:** `<ruta checklist>`
- **Casos mínimos a validar al cerrar ciclo:** `<3-6 bullets>`

## 5) Referencias

- **Producto:** `<docs/producto/...>`
- **Especificaciones técnicas:** `<docs/especificaciones/...>`
- **Config/permisos/roles:** `<docs/configuracion/...>`

## 6) Flujo de ejecución del dominio

1. Revisar contrato vivo.
2. Tocar solo tareas del dominio.
3. Implementar.
4. Validar y registrar hallazgos en LISTA.
5. Si cambió comportamiento, actualizar contrato.
6. Cerrar tarea en TASKS solo con confirmación del usuario.

## 7) Regla de archivo

- Cualquier ruta con `/archivo/` es histórica (**NO fuente viva**).
