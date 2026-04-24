# Prompt Base para Desarrollo

**⚠️ RECORDATORIO OBLIGATORIO: Si no estás aplicando este PROMPT_BASE correctamente, el usuario te recordará escribiendo: "Aplica el PROMPT_BASE"**

**📋 DOCUMENTOS COMPLEMENTARIOS:**
- `docs/configuracion/CONTEXT.md` - Normas específicas del proyecto (Plan Frankenstein, Firestore, tests manuales)
- `docs/guias/GUIA_UI.md` - Sistema de diseño, componentes y patrones de UI
- `docs/guias/GESTION_TIMEZONES.md` - Sistema de gestión de timezones
- `docs/configuracion/INDICE_SISTEMA_PLANES.md` - Índice del sistema de planes
- `docs/configuracion/TESTING_CHECKLIST.md` - Checklist exhaustivo de pruebas (actualizar tras cada tarea)

## 📋 Metodología de Trabajo

- **Enfoque directo**: Dar opiniones honestas, no ser complaciente
- **Implementación condicional**: Para cambios sencillos aplicar directamente, para cambios complejos proponer y pedir confirmación
- **Evitar cambios masivos**: No usar reemplazos masivos, hacer cambios paso a paso aunque tardemos más
- **Proponer GIT antes de cambios masivos**: Sugerir commit antes de modificaciones extensas
- **Testing incremental**: Crear entornos de prueba controlados para validar cambios
- **Documentación viva**: Mantener documentación actualizada con cada cambio importante (en castellano)
- **⚠️ REVISAR ANTES DE PROPUESTA/IMPLEMENTACIÓN**: Siempre, antes de proponer o implementar cualquier funcionalidad:
  1. Buscar si ya existe funcionalidad similar en el código
  2. Revisar TASKS.md para ver si hay tareas relacionadas o pendientes
  3. Verificar si existe en la base de datos (Firestore) o modelos
  4. Consultar documentación (flujos, CONTEXT.md, guías) para asegurarse de no duplicar
  5. Proponer reutilizar/adaptar/extender antes de crear de cero
- **Idioma del código**: Todo el código, variables, métodos, comentarios técnicos en inglés
- **Comunicación**: Documentación y comunicación entre nosotros en castellano
- **⚠️ Multi-idioma (OBLIGATORIO)**: 
  - **NUNCA hardcodear textos en español** en el código (Text('Hola'), SnackBar, AlertDialog, tooltips, etc.)
  - **SIEMPRE usar AppLocalizations:** `AppLocalizations.of(context)!.key` para todos los textos visibles
  - **Añadir traducciones:** Al crear nueva funcionalidad, añadir claves en `lib/l10n/app_es.arb` y `app_en.arb` ANTES de implementar
  - **Verificar antes de commit:** Revisar que no hay textos hardcodeados en español antes de hacer commit
  - **Estado actual:** T158 en progreso (~65%). Consultar `docs/tareas/TASKS.md` para detalles
- **Multi-plataforma**: Verificar compatibilidad Web/iOS/Android antes de usar plugins o APIs. Priorizar soluciones cross-platform.
- **Offline-First**: Se implementará cuando empecemos con versiones iOS y Android. Por ahora en web no es prioridad.
- **⚠️ CONSISTENCIA DE UI**: Siempre consultar `docs/guias/GUIA_UI.md` antes de crear componentes visuales. Aplicar tokens y tokenización estricta definidos en esa guía. NO crear componentes sin seguir el sistema de diseño canónico.
- **Actualización de tareas**: Pedir confirmación antes de actualizar tareas. Usar sistema `TASKS.md` para tracking de progreso y completar tareas. Seguir reglas del documento TASKS.md (numeración, prioridades, estados). Actualizar al completar, crear nuevas tareas o cambiar estado.
- **Actualización de Testing Checklist**: Tras completar una tarea, actualizar `docs/configuracion/TESTING_CHECKLIST.md`:
  - Marcar funcionalidades nuevas como probadas (✅) o pendientes (🔄)
  - Añadir nuevos casos de prueba si aplica
  - Actualizar casos relacionados afectados
  - Ver instrucciones detalladas en el propio documento
- **⚠️ Actualización GIT**: NUNCA hacer `git add/commit/push` sin confirmación explícita del usuario. Pedir confirmación SIEMPRE antes de hacer commits. Hacer commit de cambios al finalizar fases importantes solo tras confirmación. Repositorio: C:\Users\cclaraso\unp_calendario
- **Ruta Flutter**: Flutter instalado en: C:\Users\cclaraso\Downloads\flutter

## 📋 Patrones de Comunicación

- **Decisiones arquitectónicas**: Justificar cambios importantes con contexto
- **Preguntas clarificadoras**: Una pregunta a la vez, esperar respuesta antes de continuar
- **Sin mostrar código**: No mostrar código en soluciones o propuestas, solo implementar directamente

## 📋 Gestión de Código

- **Limpieza proactiva**: Eliminar código innecesario, logs de debug, comentarios obsoletos - siempre al dar una acción o fase por finalizada
- **Consistencia**: Verificar que código y documentación estén alineados - siempre al dar una acción o fase por finalizada
- **Refactoring**: Identificar y corregir inconsistencias arquitectónicas - siempre al dar una acción o fase por finalizada
- **Tracking**: Usar herramientas de seguimiento para tareas complejas - siempre al dar una acción o fase por finalizada

## 📋 Fundamentos del proyecto

- **Máxima participación de IA y herramientas**: Priorizar la altísima participación de la IA y del software (y la menor participación humana posible); elegir opciones que maximicen automatización y uso de herramientas y minimicen la intervención manual.
- **Valor incremental antes que big-bang**: Priorizar entregar valor verificable en cada paso antes que invertir todo en la parte más compleja; preferir opciones que den feedback pronto frente a soluciones “todo o nada”.
- **Reutilizar y comprobar antes de crear**: Comprobar si ya existe algo equivalente (código, tareas, modelos, docs) antes de añadir funcionalidad o artefactos; priorizar reutilizar, adaptar o extender sobre duplicar o crear de cero.
- **Documentación viva**: La documentación es parte del producto y evoluciona con él; cualquier cambio relevante debe reflejarse en los documentos correspondientes; la documentación obsoleta es deuda.

## 📋 Principios Técnicos

- **Simplicidad**: Preferir soluciones simples y mantenibles
- **Separación de responsabilidades**: Mantener lógica clara entre componentes
- **Testing**: Validar cambios antes de considerar completos
- **Escalabilidad**: Considerar impacto en funcionalidades futuras

## 📋 Flujo de Trabajo

- **Análisis primero**: Entender el problema antes de implementar
- **Referencia a flujos**: Consultar flujos en `docs/flujos/` y `docs/configuracion/INDICE_SISTEMA_PLANES.md` antes de implementar
- **Implementación incremental**: Cambios pequeños y validables
- **Verificación**: Confirmar que los cambios funcionan como esperado
- **Documentación**: Actualizar docs cuando sea necesario
- **Actualizar flujos**: Al implementar funcionalidades nuevas: revisar y actualizar flujos en `docs/flujos/` si procede

## 📋 Uso del Prompt Base

- **Referencia obligatoria**: Siempre consultar este documento antes de responder
- **Aplicación consistente**: Seguir todos los principios establecidos en cada interacción
- **Actualización continua**: Revisar y actualizar el prompt base cuando sea necesario

---

**Última actualización**: Febrero 2026  
**Versión**: 1.1  
**Autor**: UNP Calendario Team
