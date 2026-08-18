# T275 – Audiencias configurables de avisos por fase del plan

**Objetivo:** Permitir que el organizador defina **quién recibe avisos** durante la fase de **planificación** y durante la fase de **ejecución** del plan.

**Relacionado con:** T105 (avisos), T224 (reenviar), T268 (recordatorios), T267 (push Android), T261 (cancelación plan), dominio participantes/notificaciones.

---

## Contexto

- Actualmente la lógica de avisos no siempre distingue claramente audiencia por fase.
- En planificación puede interesar notificar a un grupo más amplio/operativo; en ejecución, a quienes están realmente involucrados.
- Debemos mantener permisos claros para evitar ruido y sobre-notificación.

## Alcance funcional (MVP)

1. Configuración por plan de audiencias para dos fases:
   - `planning`
   - `execution`
2. Aplicación de esa configuración en canales:
   - Notificación in-app (campana)
   - Push FCM
   - Email (cuando aplique)
3. Permisos de edición: solo organizador (y/o rol autorizado, a confirmar en contrato).
4. Fallback para planes existentes sin configuración.

## Modelo propuesto (alto nivel)

- Configuración de avisos por plan con:
  - fase (`planning` / `execution`)
  - audiencia (`organizers`, `participants`, `observers`, `customSelection`)
  - selección manual opcional (`userIds`) cuando sea modo custom
  - flags por canal (in-app / push / email), si se decide granularidad por canal en MVP

> Detalle final del modelo se aterriza al implementar (Firestore + reglas).

## Matriz funcional a definir

Antes de implementar, cerrar una matriz:

- tipo de aviso x fase x audiencia x canal

Ejemplos de tipos:
- cambios importantes de planificación
- cambios operativos durante ejecución
- avisos de participación/invitación
- cancelación de plan

## UX esperada

- Sección de configuración en el plan para “Avisos por fase”.
- Controles simples (presets + opción avanzada si hace falta).
- Copy claro para evitar ambiguedad en quién recibe qué.

## Entregables

- [ ] Definición de matriz tipo de aviso x fase x audiencia.
- [ ] Modelo de configuración por plan y lectura/escritura.
- [ ] UI de configuración de audiencias por fase.
- [ ] Aplicación efectiva en campana/push/email.
- [ ] Fallback para planes sin configuración (comportamiento legacy controlado).
- [ ] Pruebas E2E web+iOS+Android en escenarios de planificación y ejecución.
- [ ] Actualización de contrato/documentación (`DIAGRAMA_ALTAS_BAJAS_PLAN.md` + spec de notificaciones).

## Criterios de aceptación

- El organizador puede configurar audiencias distintas por fase.
- Los avisos respetan la configuración en los canales incluidos.
- Planes legacy mantienen comportamiento seguro mediante fallback.
- No hay envíos a usuarios fuera de audiencia configurada.

## Riesgos / decisiones abiertas

- Si la granularidad por canal entra en MVP o en fase posterior.
- Cómo se determina el cambio de fase (manual por estado de plan u otra señal).
- Carga UX: evitar una configuración compleja si no aporta valor inmediato.
