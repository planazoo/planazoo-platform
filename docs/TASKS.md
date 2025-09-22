# 📋 Lista de Tareas - Planazoo

**Siguiente código de tarea: T25**

## 📋 Reglas del Sistema de Tareas

1. **Códigos únicos**: Cada tarea tiene un código único (T1, T2, T3...)
2. **Orden de prioridad**: La posición en el documento indica el orden de trabajo (no el código)
3. **Códigos no reutilizables**: Al eliminar una tarea, su código no se reutiliza para evitar confusiones
4. **Trabajo iterativo**: Cada vez que acabemos una tarea, vemos cuál es la siguiente y decidimos si continuar
5. **Gestión dinámica**: Añadir y eliminar tareas según aparezcan nuevas o se finalicen
6. **Seguimiento de códigos**: La primera fila indica el siguiente código a asignar
7. **Estados de tarea**: Pendiente → En progreso → Completada
8. **Criterios claros**: Cada tarea debe tener criterios de aceptación definidos
9. **Aprobación requerida**: Antes de marcar una tarea como completada, se debe pedir aprobación explícita del usuario. Solo se marca como completada después de recibir confirmación.
10. **Archivo de completadas**: Las tareas completadas se mueven a `docs/COMPLETED_TASKS.md` para mantener este archivo limpio


---

## T16 - Duración exacta de eventos
**Estado:** Pendiente  
**Descripción:** Hasta ahora los eventos tenían una duración de hora completa. Esto no es correcto. Deberíamos permitir poner la duración exacta. Eso implica modificar la página de evento y su visualización. Se que este cambio es importante así que lo hemos de hacer con mucho cuidado.  
**Criterios de aceptación:** 
- Permitir duración exacta de eventos (no solo horas completas)
- Modificar página de evento
- Modificar visualización de eventos
- Implementación cuidadosa y bien planificada

---

## T18 - Página de administración de Firebase
**Estado:** Pendiente  
**Descripción:** Página de administración de Firebase: Quiero crear una página para poder administrar los datos que tenemos en firebase. El acceso será...  
**Criterios de aceptación:** 
- Página de administración de Firebase
- Acceso a datos de Firebase
- Funcionalidades de administración

---

## T19 - Valorar mouse hover en widgets W14-W25
**Estado:** Pendiente  
**Descripción:** Valorar si activamos el mouse hover en los widgets W14 a W25. Evaluar si añadir efectos visuales cuando el usuario pasa el mouse por encima de estos widgets mejoraría la experiencia de usuario.  
**Criterios de aceptación:** 
- Evaluar la experiencia actual sin hover
- Probar efectos de hover (cambio de color, escala, sombra, etc.)
- Considerar consistencia con el resto de la aplicación
- Decidir si implementar hover basado en pruebas de usabilidad
- Implementar hover si se decide que mejora la UX

---

## T20 - Página de miembros del plan
**Estado:** Pendiente  
**Descripción:** Crear la página de miembros del plan. Es una página que ha de mostrar los miembros del plan actuales, permitir eliminar y añadir miembros. Hay que definir las acciones de añadir, editar, eliminar participantes. Hemos de actualizar toda la documentación relacionada con la página.  
**Criterios de aceptación:** 
- Página completa de gestión de miembros del plan
- Mostrar lista de miembros actuales del plan
- Funcionalidad para añadir nuevos miembros
- Funcionalidad para eliminar miembros existentes
- Funcionalidad para editar información de miembros
- Interfaz de usuario intuitiva y consistente
- Integración con el sistema de participación existente
- Documentación completa actualizada
- Pruebas de funcionalidad

---

## T22 - Definir sistema de IDs de planes
**Estado:** Pendiente  
**Descripción:** Definir cómo se generan los IDs de cada plan. Hay que tener en cuenta que en un momento dado, muchos usuarios pueden crear planes casi simultáneamente. Analizar problemas y riesgos, y proponer una solución robusta.  
**Criterios de aceptación:** 
- Analizar problemas de concurrencia en generación de IDs
- Identificar riesgos de colisiones de IDs
- Proponer sistema robusto de generación de IDs
- Implementar la solución elegida
- Documentar el sistema de IDs

---

## T23 - Mejorar modal para crear plan
**Estado:** Pendiente  
**Descripción:** Mejorar el modal para crear plan. El título ha de ser "nuevo plan". El campo ID ha de obtener el valor del sistema definido. La lista de participantes hay que mejorarla.  
**Criterios de aceptación:** 
- Cambiar título del modal a "nuevo plan"
- Integrar sistema de IDs automático
- Mejorar interfaz de selección de participantes
- Optimizar experiencia de usuario del modal
- Documentar mejoras implementadas

---

## T24 - Discutir mobile first para iOS y Android
**Estado:** Pendiente  
**Descripción:** Discutir cómo pasar la app a mobile first en iOS y Android. Hay que modificar la app para que trabaje en modo mobile first en las versiones para iOS y Android.  
**Criterios de aceptación:** 
- Analizar requerimientos para mobile first
- Discutir estrategia de adaptación
- Planificar modificaciones necesarias
- Implementar cambios para mobile first
- Documentar proceso de migración


## 📝 Notas
- Las tareas están ordenadas por prioridad (posición en el documento)
- Los códigos de tarea no se reutilizan al eliminar tareas
- Cada tarea completada debe marcarse como "Completada" y actualizarse la fecha
- Las tareas completadas se han movido a `docs/COMPLETED_TASKS.md`