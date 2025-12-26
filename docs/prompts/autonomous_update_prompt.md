# Prompt para actualizaciones exhaustivas y onboarding

> **Documento para que la IA se ponga al día del proyecto después de un tiempo sin trabajar**

## 📋 INSTRUCCIONES PARA LA IA

**Cuando el usuario te pida que te pongas al día o actualices la documentación:**

1. **Lee primero `docs/configuracion/ONBOARDING_IA.md`** ⭐ **OBLIGATORIO**
   - Este documento contiene el estado actual del proyecto
   - Lista de funcionalidades implementadas y pendientes
   - Configuración técnica y normas importantes

2. **Lee los documentos esenciales:**
   - `docs/configuracion/CONTEXT.md` - Normas del proyecto
   - `docs/guias/PROMPT_BASE.md` - Metodología de trabajo
   - `docs/tareas/TASKS.md` - Estado de tareas

3. **Actualiza la documentación** siguiendo este orden de prioridad:
   1. `docs/configuracion/TESTING_CHECKLIST.md`
   2. `docs/tareas/` (TASKS y COMPLETED_TASKS)
   3. `docs/ux/` (pantallas involucradas)
   4. `docs/flujos/` relacionados con la funcionalidad modificada
   5. Otros docs técnicos o guías relevantes

4. **Informa al finalizar** qué se actualizó y qué queda pendiente

---

## 🔄 ACTUALIZACIÓN EXHAUSTIVA DE DOCUMENTACIÓN

```
Sigue trabajando en el proyecto y actualiza exhaustivamente toda la documentación y archivos necesarios sin pedirme confirmación, hasta que indiques que terminaste.

Tareas esperadas:
1. Revisar y alinear documentación en `docs/` (UX, flujos, configuración, tareas, checklists).
2. Actualizar changelogs internos, estados de tareas y checklist de pruebas cuando apliquen.
3. Verificar que los cambios de código estén reflejados en guías técnicas y UX.
4. Ejecutar ajustes menores de estilo o lint si quedan pendientes tras las modificaciones.
5. Comprobar que los documentos de flujo (`docs/flujos/`) describen fielmente el comportamiento actual y actualizarlos si no.
6. Actualizar `docs/configuracion/ONBOARDING_IA.md` si el estado del proyecto ha cambiado significativamente.
7. Informar al finalizar qué se actualizó y qué queda pendiente.

Ante dudas sobre prioridad de documentos o secciones, priorizar en este orden:
1. `docs/configuracion/ONBOARDING_IA.md` (si el estado del proyecto cambió)
2. `docs/configuracion/TESTING_CHECKLIST.md`
3. `docs/tareas/` (TASKS y COMPLETED_TASKS)
4. `docs/ux/` (pantallas involucradas)
5. `docs/flujos/` relacionados con la funcionalidad modificada
6. Otros docs técnicos o guías relevantes
