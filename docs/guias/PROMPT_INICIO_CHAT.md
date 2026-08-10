# Prompt para iniciar un chat nuevo

Copia y pega el texto de la sección **"Texto para pegar"** al **inicio** de un chat nuevo cuando trabajes en el proyecto Planazoo. Así la IA carga el contexto y las normas desde el primer mensaje.

---

## Texto para pegar

```
Proyecto: unp_calendario (Planazoo) – app Flutter de calendario de planes (eventos, alojamientos, desplazamientos). Riverpod, Firebase, multi-plataforma (Web, iOS, Android).

Antes de proponer o implementar nada:
1. Lee y aplica docs/configuracion/CONTEXT.md.
2. Abre docs/flujos/MAPA_FLUJOS.md (sistema de procesos): proceso → trabajo → prueba → referencia. Elige dominio y su contrato vivo.
3. Consulta docs/guias/PROMPT_BASE.md (reutilizar, doc viva, multi-idioma, GUIA_UI).
4. Revisa docs/tareas/TASKS.md solo para el dominio activo (WIP: 1 dominio).
5. Hallazgos de prueba: docs/testing/LISTA_PUNTOS_CORREGIR_APP.md.
6. No uses docs/flujos/archivo/ como verdad viva (solo histórico).
7. UI: Estilo Base oscuro, AppColorScheme, GUIA_UI / ESTILO_SOFISTICADO.
8. iOS / TestFlight: FASTLANE_IOS_APPSTORE.md y CONTEXT §10.1.
9. Notas del plan (T262): T262_*.md + FLUJO_NOTAS_PLAN.md.
10. Reserva/cancelación (T273): docs/tareas/T273_RESERVA_CANCELACION_DEPOSITO.md.

Convenciones: páginas pg_*, widgets wd_*, comunicación en castellano. No hagas git push sin mi confirmación explícita.
```

---

## Uso

- **Chat nuevo:** Pega el bloque anterior como primer mensaje. Luego la petición concreta (ideal: «dominio X según MAPA_FLUJOS»).
- **Recordatorio:** Si la IA no sigue las normas: **"Aplica el PROMPT_BASE"** o **"Sigue MAPA_FLUJOS"**.

## Documentos relacionados

- **MAPA_FLUJOS.md** – Jerarquía y mapa de dominios.
- **CONTEXT.md** – Normas del proyecto.
- **PROMPT_BASE.md** – Metodología.
- **PROMPT_TRABAJO_AUTONOMO.md** – Sesiones largas.
