# Prompt para iniciar un chat nuevo

Copia y pega el texto de la sección **"Texto para pegar"** al **inicio** de un chat nuevo cuando trabajes en el proyecto Planazoo. Así la IA carga el contexto y las normas desde el primer mensaje.

---

## Texto para pegar

```
Proyecto: unp_calendario (Planazoo) – app Flutter de calendario de planes (eventos, alojamientos, desplazamientos). Riverpod, Firebase, multi-plataforma (Web, iOS, Android).

Antes de proponer o implementar nada:
1. Lee y aplica las normas de docs/configuracion/CONTEXT.md.
2. Consulta docs/guias/PROMPT_BASE.md para metodología (reutilizar antes que crear, doc viva, no push sin confirmación, multi-idioma con AppLocalizations, GUIA_UI para componentes).
3. Revisa docs/tareas/TASKS.md por si hay tareas relacionadas.
4. Para UI: Estilo Base oscuro, AppColorScheme, docs/ux/estilos/ESTILO_SOFISTICADO.md y docs/guias/GUIA_UI.md.
5. Para flujos y decisiones: docs/flujos/, docs/especificaciones/, docs/arquitectura/ARCHITECTURE_DECISIONS.md según lo que vayamos a tocar.
6. Para **publicar iOS / TestFlight / IPA**: docs/configuracion/FASTLANE_IOS_APPSTORE.md y CONTEXT.md §10.1 (contraseña específica de apps: FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD si hay 2FA).

Convenciones: páginas pg_*, widgets wd_*, comunicación en castellano. No hagas git push sin mi confirmación explícita.
```

---

## Uso

- **Chat nuevo:** Pega el bloque anterior como primer mensaje (o justo después de abrir el chat). Luego escribe tu petición concreta (ej. “Añade un campo X al formulario de eventos”).
- **Recordatorio:** Si en medio del chat la IA no sigue las normas, escribe: **"Aplica el PROMPT_BASE"** (según PROMPT_BASE.md).

## Documentos relacionados

- **CONTEXT.md** – Normas del proyecto (idioma, git, UI, documentación, flujos).
- **PROMPT_BASE.md** – Metodología de trabajo y patrones de comunicación.
- **PROMPT_TRABAJO_AUTONOMO.md** – Prompt largo para sesiones de varias horas (revisión doc/código, limpieza, etc.).
