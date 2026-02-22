# Sistema Nocturno de QA Distribuido para Planazoo (v4)

> Objetivo: pruebas automatizadas nocturnas, robustas y escalables para detectar roturas funcionales, validar sincronización multiusuario y regresiones de rendimiento, con mínimo ruido y mantenibles a largo plazo. GitHub como fuente única de verdad.

**Versión:** 4 (optimizado)  
**Última actualización:** Febrero 2026  
**Relación con otras docs:** complementa el [Plan E2E manual tres usuarios](./PLAN_PRUEBAS_E2E_TRES_USUARIOS.md) (flujo UA/UB/UC); el smoke y multiusuario automatizados pueden reflejar Fase 0 / Fase 1 de ese plan.

---

## Índice

1. [Objetivo](#1-objetivo)
2. [Arquitectura general](#2-arquitectura-general)
3. [Filosofía: sistema en 3 capas](#3-filosofía-sistema-en-3-capas)
4. [Gestión de datos de test (QA Space)](#4-gestión-de-datos-de-test-qa-space)
5. [Política de alertas](#5-política-de-alertas)
6. [Estrategias por plataforma](#6-estrategias-por-plataforma)
7. [Flaky management y métricas](#7-flaky-management-y-métricas)
8. [Ejecución nocturna](#8-ejecución-nocturna)
9. [Recomendaciones de implementación](#9-recomendaciones-de-implementación)
10. [Próximos pasos y orden recomendado](#10-próximos-pasos-y-orden-recomendado)
11. [Qué cubre y qué no](#11-qué-cubre-y-qué-no)

---

## 1. Objetivo

El sistema debe:

- Detectar roturas funcionales antes que usuarios reales.
- Validar sincronización multiusuario (app tipo red social).
- Detectar regresiones claras de rendimiento.
- Minimizar falsos positivos.
- Ser mantenible a largo plazo.
- Usar GitHub como fuente única de verdad.

---

## 2. Arquitectura general

### Infraestructura

| Nodo   | Responsabilidad                                      | Ejecución        |
|--------|------------------------------------------------------|------------------|
| **Raspberry Pi** | Web E2E (Playwright, multiusuario concurrente), Android `integration_test` (dispositivo físico) | Nocturna automática |
| **Mac**         | iOS `integration_test` (iPhone físico)               | Nocturna automática |

Ambos:

- Hacen `git pull` antes de ejecutar.
- No se comunican entre sí.
- Generan reportes y métricas de forma independiente.

**Nota:** Playwright + Chrome en Raspberry (ARM) puede dar sorpresas; conviene un spike corto (instalar Playwright en el RPi y ejecutar un smoke mínimo) antes de comprometer toda la estrategia web en ese nodo.

---

## 3. Filosofía: sistema en 3 capas

Para reducir fragilidad y mejorar señal/ruido.

### Capa A – Smoke E2E (UI real, mínimo indispensable)

**Objetivo:** “¿La app funciona y es usable?”

- **Web:** carga home → login → navegación principal → acción mínima (crear/editar entidad simple) → logout.
- **Android:** launch → login → navegación principal → acción mínima.
- **iOS (iPhone físico):** launch → login → navegación principal → acción mínima.

**Duración total objetivo:** &lt; 30 minutos global.

### Capa B – Multiusuario concurrente (solo Web)

**Objetivo:** validar sincronización social y permisos.

- 2–4 usuarios simultáneos con **BrowserContexts** aislados.
- Escenarios: propagación (A crea → B ve), interacción (A publica → B comenta → A ve), permisos (A invita → B acepta → ambos acceden), sincronización cuantificada (`T_publish_to_visible_ms`, `T_comment_to_visible_ms`, `consistency_pass`).
- No simular más de 6 usuarios simultáneos en Raspberry.

### Capa C – Tests sin UI (futuro)

**Objetivo:** validar backend sin depender del navegador.

- Checks de APIs, endpoints críticos, carga ligera (p. ej. k6 opcional).

---

## 4. Gestión de datos de test (QA Space)

- **Espacio lógico:** todas las entidades creadas por tests llevan prefijo `QA_` + timestamp (ej. `QA_post_2025_01_12_0203`).
- **Limpieza:** cleanup automático al final del run **o** job nocturno que borre entidades `QA_` con antigüedad &gt; 7 días.
- **Firebase/Firestore:** definir si se usa proyecto de test o el mismo proyecto con convención `QA_`; las reglas deben permitir a los usuarios de prueba crear/leer estos datos. Ver [USUARIOS_PRUEBA](../configuracion/USUARIOS_PRUEBA.md).

---

## 5. Política de alertas

### 🔴 Rojas (siempre notificar)

Fallo funcional, `console.error`, HTTP 5xx, crash móvil, elemento crítico ausente, sincronización inconsistente. Generar: screenshot, trace, logs y notificación inmediata (canal a definir: email, Slack, GitHub Issue, etc.).

### 🟠 Ámbar

Tiempo &gt; +30% respecto a mediana últimos 7 días, login &gt; 6 s, sincronización lenta pero funcional, 4xx inesperados recurrentes. **Regla:** 1 vez → registrar; 2 noches consecutivas → notificar.

### 🟢 Verde

Variaciones menores, warnings no críticos. Solo en reporte.

---

## 6. Estrategias por plataforma

### Web (Playwright)

- 2–4 BrowserContexts concurrentes.
- `storageState` persistente por usuario.
- Reintento controlado (1 retry máximo para flakiness).
- Métricas de convergencia de estado.

### Android

- Dispositivo físico por USB, `integration_test`.
- Captura `logcat` en fallo.
- Multiusuario secuencial (A → logout → B). Objetivo: crashes reales y problemas móviles específicos.

### iOS

- Mac + iPhone físico conectado y desbloqueado, `integration_test`.
- Captura logs de Xcode. Simulador solo para desarrollo, no como validación nocturna principal.

---

## 7. Flaky management y métricas

- **Flaky:** 1 retry automático en timeouts no críticos; tests inestables en “quarantine”; baseline dinámico de rendimiento (mediana 7 días); no alertar por una única anomalía menor.
- **Métricas por run:** timestamp, commit hash, resultado por test, duración total y por paso, errores consola, HTTP fallidas, latencia A→B, consistencia final.
- **Almacenamiento:** JSON o SQLite en carpeta `/reports/YYYY-MM-DD/`. Definir dónde se agregan los reportes de RPi y Mac (artifacts GitHub, servidor, carpeta compartida) para tener un solo lugar cada mañana.

---

## 8. Ejecución nocturna

- **02:00** → Raspberry (Web + Android): `git pull` → ejecutar suite → generar reportes.
- **02:30** → Mac (iOS): `git pull` → ejecutar suite → generar reportes.

Opcional (futuro): mini canary cada 4 h (web smoke mínimo, 2–3 pasos) para detectar caída en producción antes del nightly.

---

## 9. Recomendaciones de implementación

Alineado con el estado actual del proyecto (plan E2E manual, sin `integration_test` ni Playwright aún):

1. **Orden de valor:** Primero tener **algo estable que corra cada noche y deje reporte**, antes de montar multiusuario y hardware.
2. **Fase 0 (actual):** Mantener el plan manual [PLAN_PRUEBAS_E2E_TRES_USUARIOS.md](./PLAN_PRUEBAS_E2E_TRES_USUARIOS.md) como criterio de qué debe cubrir el sistema.
3. **Fase 1 – “Una cosa que corra”:**  
   - Estructura de carpetas y scripts (RPi y/o Mac).  
   - Un solo smoke E2E (p. ej. Playwright: login + dashboard + una acción mínima), aunque sea solo en máquina local.  
   - Reporte mínimo (HTML o JSON en `reports/YYYY-MM-DD/`) y, si se desea, un job que haga `git pull` + run a las 02:00 en PC o RPi.
4. **Fase 2:** Añadir multiusuario (template con 2 usuarios, propagación A→B) y concretar canal de notificaciones rojas.
5. **Fase 3:** Android/iOS en dispositivo físico cuando el smoke web nocturno sea estable.
6. **Puntos a concretar pronto:**  
   - Dónde viven los reportes agregados (RPi + Mac).  
   - Canal concreto para “notificación inmediata” (rojas).

---

## 10. Próximos pasos y orden recomendado

| Orden | Paso | Descripción |
|-------|------|-------------|
| **1** | Estructura + smoke | Estructura exacta de carpetas y scripts para Raspberry y Mac; **incluir un smoke mínimo de Playwright** (login + navegación + una acción). |
| **2** | Reporte | Diseño del sistema de reporte final: HTML simple + resumen diario; dónde se guardan/agregan reportes. |
| **3** | Multiusuario | Template concreto de test multiusuario con métricas (2 usuarios, propagación, tiempos). |

Así se obtiene algo estable y visible antes de invertir en la parte más compleja (multiusuario y hardware nocturno).

---

## 11. Qué cubre y qué no

**Cubre:**

- E2E real con UI.
- Multiusuario concurrente (web).
- Validación móvil real (Android/iOS en dispositivo).
- Regresiones funcionales y de rendimiento claras.

**No cubre:**

- Stress testing masivo de backend.

---

## Resultado esperado del sistema

Cada mañana poder responder:

- ¿Web estable?
- ¿Multiusuario sincroniza?
- ¿Android estable?
- ¿iOS físico estable?
- ¿Hay regresiones claras?
- ¿Backend responde correctamente?

Con mínimo ruido, evidencias claras, datos históricos, entorno limpio (QA Space) y escalabilidad futura.

---

*Documento integrado en la documentación del proyecto Planazoo. Ver también: [TESTING_CHECKLIST](../configuracion/TESTING_CHECKLIST.md), [PLAN_PRUEBAS_E2E_TRES_USUARIOS](./PLAN_PRUEBAS_E2E_TRES_USUARIOS.md), [USUARIOS_PRUEBA](../configuracion/USUARIOS_PRUEBA.md).*
