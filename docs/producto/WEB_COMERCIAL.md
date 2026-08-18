# Planoon — Web comercial: brief de producto y experiencia

**Estado:** Documento de trabajo (fuente de verdad de la landing)  
**Idioma:** castellano  
**Última actualización:** 16 ago 2026  
**Código de la web:** [`marketing/`](../../marketing/)  
**App:** raíz Flutter → [`https://app.planoon.com`](https://app.planoon.com)

**Origen:** brief de producto/experiencia (inglés, ago 2026), traducido y **gestionado aquí**. No duplicar ese texto fuera; si cambia la intención de la web, se edita **este** archivo.

**No prescribe:** framework, librerías de animación, hosting concreto ni estructura de código. Eso se decide al implementar. Hoy el esqueleto es HTML/CSS estático (ver [`marketing/README.md`](../../marketing/README.md) y [`MONOREPO.md`](../configuracion/MONOREPO.md)).

---

## Cómo usar este documento

1. **Intención de producto y relato** — qué debe entender y sentir el visitante (secciones 1–21).
2. **Capa de verdad** — cada pilar y cada bloque de homepage lleva un estado respecto a la **app real**. La web **no** puede afirmar como disponible lo que aún es visión.
3. **Contrato con la app** — lo que esta web cuenta como parte del producto **tiene que funcionar** en iOS / Android / web app antes del lanzamiento público. Ver [§ Contrato web → app](#contrato-web--app-sí-o-sí).
4. **Implementación** — `marketing/` consume este brief; cambios de marca/copy/relato se acuerdan aquí primero.

Leyenda de estado:

| Estado | Significado | En la web |
|--------|-------------|-----------|
| **Hoy** | Existe en la app de forma usable (aunque falte polish) | Se puede mostrar y afirmar |
| **Parcial** | Hay base, spec o implementación incompleta | Mostrar con cuidado; no vender como cerrado |
| **Visión** | Intención de producto, no lanzamiento | Relato aspiracional **solo** si se etiqueta como futuro, o se omite en v1 |
| **Abierto** | Hay que decidir; no cerrar en silencio al maquetar | Dejar explícito |

Timeline de launch: [`TIMELINE_LANZAMIENTO.md`](./TIMELINE_LANZAMIENTO.md) fase 4.  
Dominio: [`DOMINIO_PLANOON.md`](../configuracion/DOMINIO_PLANOON.md).

---

## 1. Propósito de la web

Tres objetivos, en este orden:

1. Explicar **qué es Planoon** en segundos.
2. Hacer entender **por qué es distinto** de cómo se organizan los planes hoy.
3. Convertir al visitante en **usuario**.

La web **no** es un catálogo de features. Debe **demostrar** cómo se crea un plan, cómo evoluciona, cómo lo viven distintos participantes y cómo puede acabar siendo algo que se recuerda y se comparte.

**El producto es el protagonista.** La interfaz (o una demo fiel) debe ocupar el peso visual, no fotos de lifestyle genéricas.

---

## 2. Qué es Planoon

Planoon es una plataforma colaborativa para organizar **cosas que la gente hace junta**.

Un Planoon puede ser: un viaje, un fin de semana, una cena, un cumpleaños, un festival, un viaje de esquí, una boda, un road trip, una actividad de grupo, un evento… **casi cualquier plan compartido**.

Por tanto **no es una app de viajes**, aunque el viaje sea uno de los casos de uso más naturales.

Tampoco es *solo*:

- un calendario
- un chat de grupo
- un gestor de tareas
- una app de gastos
- un itinerario de viaje
- un repositorio de documentos

Reúne esos aspectos alrededor de **un objeto fundamental: el plan**.

**En el proyecto hoy:** la app (históricamente Planazoo) está muy centrada en **viajes/eventos** (planes, calendario, alojamientos, invitaciones). El posicionamiento comercial es más amplio; el código aún no cubre todos esos tipos de plan con la misma profundidad. En la web se puede decir “planes juntos” sin fingir que ya es el producto para bodas/festivales de punta a punta.

---

## 3. Idea núcleo

Un grupo crea **un plan compartido**. Estar en el mismo plan **no** implica hacer todos lo mismo.

Planoon combina:

- **EL PLAN** — vista compartida de lo que hace el grupo.
- **MI PLAN** — vista personalizada de lo que hace cada participante.

Propuesta fundamental:

# Un plan compartido. Personal para cada uno.

Cada participante debe poder saber, sin reconstruirlo desde cinco apps:

- qué ocurre
- cuándo
- dónde
- si le afecta
- quién más participa
- qué necesita saber
- qué tiene que hacer

**En el proyecto hoy**

| Pieza | Estado | Referencia |
|-------|--------|------------|
| Plan compartido (CRUD, calendario, eventos, alojamientos) | **Hoy** | Flujos de plan/eventos; [`CALENDAR_CAPABILITIES.md`](../especificaciones/CALENDAR_CAPABILITIES.md) |
| Parte común / parte personal **por evento y alojamiento** | **Hoy** (patrón) | [`GUIA_PATRON_COMUN_PERSONAL.md`](../guias/GUIA_PATRON_COMUN_PERSONAL.md) |
| Vista **«Mi resumen» / itinerario del viajero** | **Parcial** | Spec [`T252`](../tareas/T252_PARTICIPANTES_USUARIOS_VS_PLANIFICADORES.md); no es aún el eje de la app |
| Confirmación de asistencia a eventos | **Hoy** (base) | T252 / registro en eventos |

En la homepage, **EL PLAN → MI PLAN** es el diferenciador a contar; las demos de “cambiar de participante y ver otro itinerario” deben ser honestas (demo ilustrativa vs pantalla real).

---

## 4. Filosofía de producto

Los planes de grupo complejos deben **sentirse simples**.

Transformación progresiva:

**ideas → un plan compartido → el plan de cada persona → la experiencia → un recuerdo que se puede compartir y reutilizar**

Ciclo conceptual (debe marcar el *storytelling*):

# PROPONER → DECIDIR → PLANIFICAR → VIVIR → RECORDAR → COMPARTIR → REUTILIZAR

**En el proyecto hoy:** el núcleo usable es **planificar + vivir** (invitar, calendario, avisos). **Recordar / compartir como historia / reutilizar** es sobre todo **visión**.

---

## 5. Gratis para participantes

Intención actual: Planoon **gratis para consumidores**.

La colaboración es el producto. Si alguien crea un Planoon e invita a siete personas, las siete deben poder participar **sin barrera de pago**.

En la web, de momento:

- **Gratis**, o
- **Crea un Planoon — es gratis**

**No** hay tabla de precios de consumidor.

El modelo de negocio a largo plazo puede venir de servicios alrededor del plan, integraciones, transacciones, comisiones y B2B — no de cortar la colaboración básica. **Sujeto a validación** ([`TIMELINE_LANZAMIENTO.md`](./TIMELINE_LANZAMIENTO.md): cobros reales = post / P3).

**Acordado en el repo:** sin pasarela de cobro en el MVP; pagos = **anotar y cuadrar** ([`PAGOS_MVP.md`](./PAGOS_MVP.md)).

---

## 6. Los nueve pilares

Cada pilar: intención comercial + estado en código. El peso visual de la homepage está en §8–9, no aquí.

### Pilar 1 — Planificación visual

El plan no debe sentirse como “rellenar formularios”. Interfaz tipo **línea de tiempo / tablero**: varios días, actividades por día, tiempos visibles; crear, mover, reordenar, cambiar de día, quizá duración; arrastrar propuestas al plan real.

Modelo útil: **IDEAS / PROPUESTAS → EL PLAN**.

La web debe **demostrarlo**, no solo describirlo.

| | |
|--|--|
| **Estado** | **Hoy (base fuerte):** calendario por días/horas, crear/editar, **drag & drop** de eventos, alojamientos por día. **Parcial:** bandeja de ideas que se arrastran al itinerario (no es el flujo principal). Formularios de evento siguen siendo parte real de la UX. |
| **Ref.** | [`CALENDAR_CAPABILITIES.md`](../especificaciones/CALENDAR_CAPABILITIES.md) |

### Pilar 2 — Planificar juntos

No es “un organizador monta el itinerario y el resto lo recibe”. Según permisos: proponer, listas, comentar, decidir, indicar asistencia, aportar información.

Principio:

# No planifiques *para* todos. Planifica *con* todos.

Ejemplo de relato: Laura propone **paseo en barco**, Pedro **bodega**, Ana **Es Trenc** → luego entran en el plan.

| | |
|--|--|
| **Estado** | **Hoy:** invitaciones (mail + app), roles (organizador / participante / observador), altas-bajas. **Parcial:** propuestas de eventos (borrador / T252). Chat del plan **parcial** (T190). |
| **Ref.** | [`DIAGRAMA_ALTAS_BAJAS_PLAN.md`](../flujos/DIAGRAMA_ALTAS_BAJAS_PLAN.md), T252, T190 |

### Pilar 3 — Planes personales

Cinco amigos en Mallorca: vuelos distintos, actividades distintas, cena juntos. Un **Mallorca 2027** compartido y varios **plan de Laura / Cristian / Pedro**.

El plan personal se **deriva** del Planoon compartido; no es un calendario independiente. Los cambios en eventos compartidos deben llegar a quien corresponda.

# Juntos no significa hacer todo juntos.  
# Un plan. El plan de cada uno.

| | |
|--|--|
| **Estado** | **Hoy:** participantes por evento; parte personal (asiento, habitación…). **Parcial / spec:** vista viajero T252. |

### Pilar 4 — Coordinación inteligente

El plan cambia. La gente adecuada se entera: evento movido, propuesta, algo se acerca, hace falta una decisión, tarea, conversación relevante, pago pendiente.

Avisos **contextuales y personalizados**: si solo cuatro van al barco, un cambio no tiene que avisar a todo el Planoon.

# La información correcta. A las personas correctas. En el momento correcto.

En la web: **un ejemplo**, no un recuadro “notificaciones”.

| | |
|--|--|
| **Estado** | **Hoy:** campana, push, correo; invitaciones; audiencias por fase en evolución (T275). **Parcial:** no todos los tipos del brief existen; personalización “solo afectados” no está cerrada en todos los casos. |
| **Ref.** | [`NOTIFICACIONES_ESPECIFICACION.md`](./NOTIFICACIONES_ESPECIFICACION.md) |

### Pilar 5 — Todo en contexto

Hoy un plan vive en WhatsApp + mail + calendarios + notas + hojas + PDFs + reservas + pagos. Planoon junta lo relevante **alrededor del plan**, en el objeto correcto.

Un evento (**paseo en barco**) puede llevar: fecha, hora, lugar, participantes, reserva, documentos, enlaces, chat, lista, tareas, coste previsto/real, notas. El evento es un **contenedor**, no solo un bloque de calendario.

# Cada cosa tiene su sitio.

| | |
|--|--|
| **Estado** | **Hoy:** eventos/alojamientos con muchos campos, participantes, costes, notas de plan (T262 fase 1), presupuesto. **Parcial:** chat por evento, documentos, listas genéricas. |
| **Ref.** | Specs de formularios; [`FLUJO_NOTAS_PLAN.md`](../flujos/FLUJO_NOTAS_PLAN.md) |

### Pilar 6 — Comunicación

Hay comunicación interna. **No** se vende como “el nuevo WhatsApp”. La ventaja es el **contexto**: conversación del Planoon, de un evento, de una propuesta, de una lista.

IA que extrae decisiones del chat: **visión**; no afirmarlo.

| | |
|--|--|
| **Estado** | **Parcial:** chat de plan (T190 / T253). Chat anclado a evento = no es el relato de lanzamiento. |

### Pilar 7 — Listas

Qué llevar, compras, restaurantes a valorar, tareas, preparación, participantes, actividades a considerar. Ítems asignables, completables, enlazados a evento o coste.

**No** es un diferenciador de marketing por sí solo; vale por estar **dentro** del Planoon.

| | |
|--|--|
| **Estado** | **Hoy / parcial:** lista **Preparación** en Notas (T262). Listas genéricas tipo “restaurantes a considerar” = **visión**. |

### Pilar 8 — Dinero

El dinero forma parte del plan, no un trámite después.

Progresión conceptual: **presupuesto → costes previstos → gastos reales → quién pagó → reparto → balance → pago**.

# Planifícalo. Gástalo. Repártelo.

**Cobro real (pasarela) solo cuando exista** técnica y legalmente.

| | |
|--|--|
| **Estado** | **Hoy (anotar/cuadrar, no cobrar):** presupuesto del plan (T101); pagos personales, balances, sugerencias (T102); garantía de reserva (T273). Paridad tipo Tricount y paridad móvil **parcial** ([`PAGOS_MVP.md`](./PAGOS_MVP.md), T222). **Visión:** pago in-app. |
| **Copy obligatorio** | La app **no procesa cobros**; solo anota y cuadra entre el grupo. |

### Pilar 9 — Importación inteligente

El usuario no debería reescribir lo que ya existe: reservas de vuelo/hotel/restaurante, entradas, PDFs, mails, enlaces, capturas. Planoon entiende y propone **dónde va**.

# No lo teclees. Compártelo.

| | |
|--|--|
| **Estado** | **Parcial / spec:** eventos desde correo reenviado (T134, [`CORREO_EVENTOS_SISTEMA_PARSEO.md`](./CORREO_EVENTOS_SISTEMA_PARSEO.md)); vuelo/tren por número (T246). Asistente por reglas (T266) sin implementar. Importar PDF/captura genérico = **visión**. |
| **Web v1** | **No** vender Smart Import como disponible salvo lo que esté en producción el día del deploy. |

---

## 7. Capacidades transversales

### Offline first — **sí o sí**

La información importante del plan debe estar **sin red** (itinerario, eventos, reservas, direcciones, documentos relevantes, listas). Al volver la red, se sincroniza.

Promesa de usuario (no slogan técnico):

# Tu plan va contigo.

| | |
|--|--|
| **Contrato** | En **iOS y Android**, con sesión ya abierta: sin red se ve el plan (eventos, horas, sitios). Un cambio hecho offline aparece al reconectar. Cold start offline no se queda en “Cargando…” si el plan ya estaba en el dispositivo. **Web app:** mejor esfuerzo; el sí-o-sí del contrato es **móvil** (viajar). |
| **Estado hoy** | **Parcial:** Firestore offline + réplica Hive (ítem 58 cerrado en docs). Cola propia / offline amplio = T56–T62, T265. No afirmar “todo, en todos los dispositivos”. |
| **Ref.** | [`TESTING_OFFLINE_FIRST.md`](../testing/TESTING_OFFLINE_FIRST.md) |

### Zonas horarias — **sí o sí**

Hora + lugar + participante + zona local (vuelos, viajes internacionales, gente remota). Se cuenta como **fiabilidad del plan**, no como feature aislada. Refuerza **MI PLAN**: el vuelo de Laura se lee en hora de **Londres**; el de Cristian, en hora de **Barcelona**; la llegada, en Palma.

| | |
|--|--|
| **Contrato** | Un desplazamiento con origen y destino en zonas distintas muestra **salida en hora local de origen** y **llegada en hora local de destino**. Dos participantes que vuelan desde ciudades distintas ven **su** vuelo bien. Cambiar de persona / perspectiva no desarma el calendario. |
| **Estado hoy** | **Hoy (núcleo):** [`GESTION_TIMEZONES.md`](../guias/GESTION_TIMEZONES.md), T40–T45. Pendiente: cierre formal / QA en dispositivo. |

### Participantes e invitados — **sí o sí** (invitar)

| Rol (brief) | En el producto hoy | Estado |
|-------------|-------------------|--------|
| **Participante** | `participant` / organizador: ve el plan, parte personal, según permisos propone, listas, gastos, avisos | **Hoy** |
| **Invitado / seguidor** | Rol **observador** (`observer`): lectura, sin organizar | **Hoy (base)** — el recorte “qué ve exactamente” sigue **abierto** |
| Invitación pendiente | `pending` — aún no es miembro | **Hoy** |

# Que puedan seguir el plan.

**Seguir un Planoon no implica GPS en tiempo real.** La ubicación es explícita y controlada por el usuario.

| | |
|--|--|
| **Contrato** | Desde la app se invita a **participante** o **observador**. El invitado recibe mail y/o enlace; puede aceptar o rechazar. Quien organiza ve el estado. Deep link iOS/Android/web: T259. |
| **Ref.** | [`ROLES_Y_TIPOS_USUARIO.md`](../configuracion/ROLES_Y_TIPOS_USUARIO.md), [`DIAGRAMA_ALTAS_BAJAS_PLAN.md`](../flujos/DIAGRAMA_ALTAS_BAJAS_PLAN.md) |

### Compartir un Planoon

Dos vías **distintas** (no mezclar con “copiar el Planoon” para reutilizarlo):

1. **Invitar / unirse** al Planoon original (app + mail + enlace) — **contrato, sí o sí**.
2. **Exportar el itinerario** (el mío o el del grupo) para mandarlo fuera de la app (PDF / imprimir / hoja de compartir) — **contrato, sí o sí**.
3. **Recibir una copia editable** independiente (plantilla, “copia este Planoon”) — **visión**, no es el contrato de lanzamiento.

| | |
|--|--|
| **Exportar — contrato** | Un participante exporta o imprime **su** itinerario. Un organizador (o quien tenga permiso) puede exportar el **plan**. El destinatario **no** tiene que tener Planoon instalado. Encaje con offline: poder generar desde datos locales en móvil. |
| **Estado hoy** | Invitar: **Hoy / QA** (T259). Exportar: **Pendiente** — T133, T252 §6. |
| **Ref.** | [`T252`](../tareas/T252_PARTICIPANTES_USUARIOS_VS_PLANIFICADORES.md), T133 |

### Copiar y reutilizar

Ej.: *Iceland Road Trip — 9 días* → **Copiar este Planoon** → editar fechas, gente, actividades. Base de plantillas, planes públicos, creadores, agencias, discovery. Estratégico a medio plazo (adquisición y monetización).

**Estado:** **Visión** (export PDF T133 = otra cosa).

### Después del plan — recordar

El Planoon terminado pasa de herramienta a **relato**: itinerario real, sitios, gente, fotos, notas, gastos finales, mapa, highlights.

# Los planes acaban. Los recuerdos no.  
# Tu Planoon es la historia de lo que hicisteis juntos.

Bucle: **PLANIFICAR → VIVIR → RECORDAR → COMPARTIR → NUEVO PLAN**.

**Estado:** **Visión** (estados de plan existen; “memorias” como producto no).

---

## Contrato web → app (sí o sí)

La landing **define** qué tiene que cumplir la app para poder decirlo en `planoon.com`. Si no pasa el criterio, o se quita de la web o no se lanza en público.

No sustituye el orden de dominios ([`ORDEN_POR_DOMINIOS.md`](../flujos/ORDEN_POR_DOMINIOS.md)); es una **capa de lanzamiento**. Timeline: [`TIMELINE_LANZAMIENTO.md`](./TIMELINE_LANZAMIENTO.md).

| ID | Promesa en la web | Criterio en la app | Refs | Estado |
|----|-------------------|--------------------|------|--------|
| **C1** | El plan va contigo sin red | iOS + Android: ver itinerario (eventos, horas, sitios) offline; cambios se sincronizan al reconectar; cold start con plan ya visto no se queda colgado | [`TESTING_OFFLINE_FIRST.md`](../testing/TESTING_OFFLINE_FIRST.md), T56–T62, T265 | Parcial (ítem 58) |
| **C2** | Las horas son las de cada sitio | Vuelo con dos zonas: salida en origen, llegada en destino; cada participante ve **su** desplazamiento; la perspectiva no rompe el calendario | [`GESTION_TIMEZONES.md`](../guias/GESTION_TIMEZONES.md), T40–T45 | Núcleo hoy · falta QA de cierre |
| **C3** | Invitar invitados desde la app | Invitar participante u observador; mail + enlace; aceptar/rechazar; el organizador ve el estado; deep link en iOS/Android/web | T259, altas-bajas, observador | En curso / QA |
| **C4** | Exportar el itinerario | Exportar/imprimir/compartir **mi** itinerario y, con permiso, el **plan**; el destinatario no necesita la app (PDF u equivalente) | T133, T252 §6 | Pendiente |

**No son este contrato** (siguen visión o refuerzo): copiar un Planoon para reutilizarlo, Smart Import, recuerdos, pasarela de cobro, GPS.

**Acordado (ago 2026):** C1–C4 **bloquean el lanzamiento público**. El soft launch en familia puede seguir sin C4 pulido; C1–C3 ya se exigen en cuanto haya usuarios reales fuera del equipo.

---

## 8. Relato de la homepage

**No** dar el mismo peso a todo. Una sola historia: **Mallorca 2027**.

Participantes de ejemplo (relato, no clientes reales): Laura, Cristian, Pedro, Ana, Sofía.

Actividades de ejemplo: vuelo a Palma, check-in hotel, Es Trenc, barco, bodega, cena, copas al atardecer.

El mismo Planoon reaparece en cada bloque.

### Narrativa (orden)

| # | Bloque | Qué debe pasar | En v1 de la web |
|---|--------|----------------|-----------------|
| 1 | **Hero** | Entender Planoon | **Sí** |
| 2 | **El problema** | Fragmentación → todo en Planoon | **Sí** |
| 3 | **Planificación visual** | Tablero, drag, propuestas → plan | **Sí** (demo; D&D real en app) |
| 4 | **Planificar juntos** | Varias personas construyen | **Sí** (invitar / proponer) |
| 5 | **Planes personales** | EL PLAN → MI PLAN | **Sí** (demo; T252 parcial) — bloque estrella |
| 6 | **Coordinación** | Cambia un evento → avisos a quien toca | **Sí** (ejemplo) |
| 7 | **Todo en contexto** | Abrir un evento: gente, chat, lista, reserva, coste | **Parcial** — mostrar lo que exista; no inventar chat-por-evento |
| 8 | **Importación inteligente** | Compartir una reserva → Mallorca 2027 | **Visión / omitir o “próximamente”** hasta T134 en prod |
| 9 | **Dinero** | Presupuesto, gastos, balances | **Sí**, con copy de no-cobro |
| 10 | **Siempre contigo** | Offline + zonas horarias (vuelos LHR / BCN → PMI) | **Sí** — contrato **C1** y **C2** |
| 11 | **Compartir** | Invitar (app + mail) y **exportar itinerario** | **Sí** — contrato **C3** y **C4** (export aún no está en la app) |
| 12 | **Copiar plan** | Copia editable independiente | **Visión** — no está en el contrato |
| 13 | **Recordar** | Plan activo → memoria | **Visión / omitir o suave** |
| 14 | **CTA final** | *¿Cuál es el plan?* Crear el primero. Gratis. | **Sí** → `app.planoon.com` |

**Maqueta** (`marketing/index.html`, ago 2026): hero → … → dinero, **offline + timezones**, **invitar + exportar itinerario**, CTA. **Omitidos a propósito:** importación inteligente, copiar plan, recuerdos.

---

## 9. Prioridades visuales

Máximo énfasis:

1. Planificación visual  
2. Planificar juntos  
3. Planes personales  
4. Todo en contexto  
5. Importación inteligente *(cuando sea verdad; si no, no forzar el 5.º puesto con humo)*

Refuerzo (sin ahogar): dinero, avisos, offline, zonas horarias, seguir, compartir, recuerdos.

---

## 10. Hero, navegación y principios visuales

### Hero (dirección actual — copy abierto)

# Haz planes. Juntos.

## Un plan compartido. Personal para cada uno.

Apoyo: **Planifica, organiza y vive cualquier cosa en grupo — de un fin de semana al viaje de vuestra vida.**

- CTA principal: **Crea un Planoon — es gratis** → `https://app.planoon.com` (hasta haber stores).
- CTA secundario: **Mira cómo funciona** (ancla al relato).

El hero muestra **producto**, no foto genérica.

### Navegación (provisional)

`planoon` · Cómo funciona · Funciones · Para empresas · Acerca de · **Entrar** · **Empezar a planificar**

Mínima. IA exacta **abierta**. En v1, “Para empresas” puede ser un ancla o página corta; no dominar la home.

### Principios visuales

Debe sentirse: simple, contemporáneo, de consumidor, social, optimista, internacional, sofisticado, intuitivo, **distintivo**.

**No:** software enterprise, project management, viaje corporativo, SaaS genérica.

Preferir: mucho aire, tipografía fuerte, jerarquía clara, color contenido, animación con propósito, demos grandes, relato continuo.

Evitar: grids de features, gradientes excesivos, glassmorphism de más, stock photos, **testimonios falsos, logos de clientes inventados, estadísticas inventadas**, animación decorativa.

La app hoy es **tema oscuro** ([`GUIA_UI.md`](../guias/GUIA_UI.md)). La landing actual es clara/verde. **Identidad visual final abierta** (§20); las demos de producto pueden usar UI oscura de la app sobre una web más editorial.

### Animación

Solo si **explica** el producto: arrastrar un evento de día; una idea que entra al plan; interruptor EL PLAN / MI PLAN; aviso tras un cambio; una reserva que se convierte en evento; un plan que pasa a recuerdo.

### Escritorio y móvil

Obligatorio ambos. Escritorio = demos inmersivas. Móvil **no** es el desktop encogido. Planoon se usará mucho en el teléfono.

---

## 11. Relación con la app (ya cerrado en infra)

La web comercial y la app son **productos de implementación distintos**.

| URL | Qué |
|-----|-----|
| `planoon.com` / `www` | Esta web (`marketing/`) |
| `app.planoon.com` | App Flutter (iOS / Android / web) |

Enlaces naturales: **Entrar**, **Crea un Planoon**, **Abrir Planoon**.

Auth de la app **no** tiene que vivir en la landing. **Abierto:** si el CTA “crear” exige cuenta ya en la app (hoy sí: registro en `app.`).

---

## 12. Demos vs prototipo real

Las demos de la web **pueden ser frontend** (drag, cambiar de participante, abrir evento, aviso simulado, import simulado) **sin** backend.

Objetivo: que se entienda cómo funciona Planoon.

**Abierto (no decidir en silencio):** si más adelante se reutilizan widgets Flutter o datos reales. v1 = estático / demo ligera en `marketing/`.

---

## 13. Veracidad (norma dura)

Distinguir siempre:

- lo **implementado**
- lo **en desarrollo**
- la **visión**

No inventar: clientes, testimonios, valoraciones, premios, número de usuarios, partners, prensa, integraciones.

Sobre todo en el primer lanzamiento.

---

## 14. Conversión

Principal: **Crea un Planoon.**

Secundarias (cuando existan): descargar la app, entrar, ver un Planoon compartido, copiar un Planoon, contacto B2B.

No saturar de CTAs competidores.

Hasta App Store / Play: el CTA principal apunta a **`app.planoon.com`**.

---

## 15. Dirección B2B (secundaria)

Posible: agencias, operadores, organizadores, hoteles, destinos, creadores, proveedores de actividades… Un Planoon completo en lugar de PDFs y mails.

**No** debe dominar la home de consumidor. “Para empresas” = camino secundario. Proposición B2B = **documento aparte, aún no escrito**.

---

## 16. Lenguaje de marca

Nombre: **planoon** / **Planoon**. Capitalización **abierta**.

Explorar el nombre como **el objeto**:

- Crea un Planoon.
- Comparte tu Planoon.
- Copia este Planoon.
- ¿Cuál es tu próximo Planoon?

Así se crea categoría propia, no “otro trip planner”.

En docs y app aún convive **Planazoo** (histórico). Hacia fuera: **Planoon**.

---

## 17. Qué debe recordar el visitante

Aunque olvide el resto, tres ideas:

1. **El plan se construye junto y de forma visual.**
2. **Hay un plan compartido, y cada persona tiene el suyo.**
3. **Todo lo del plan está en un solo sitio.**

Importación, dinero, avisos, offline, compartir y recuerdos **refuerzan** esas tres, no las sustituyen.

---

## 18. La experiencia núcleo (transformación)

**Antes de Planoon** — ideas e información dispersas.  
↓  
**Construyendo el Planoon** — se propone, se habla, se decide, se ordena en visual.  
↓  
**El Planoon** — un plan compartido coherente.  
↓  
**Mi plan** — cada uno sabe qué le aplica.  
↓  
**Durante** — información disponible, contextual, coordinada.  
↓  
**Después** — se recuerda, se comparte, se reutiliza.

---

## 19. Principio de implementación

Este documento define **intención**. El código de `marketing/` la sirve; no al revés.

Trabajo por pasos: no maquetar los 14 bloques de una vez. Orden sugerido:

1. Hero + problema + CTA (sustituir el esqueleto).
2. Planificación visual + planificar juntos + planes personales (el núcleo).
3. Contexto + coordinación + dinero (honesto).
4. Offline / timezones / invitar / exportar itinerario (contrato C1–C4; ya en maqueta).
5. Importación, copiar Planoon, recuerdos — cuando el producto lo aguante o como “próximamente” explícito.

---

## 20. Preguntas: abiertas vs ya cerradas en el repo

### Ya cerrado (no reabrir sin acuerdo)

| Tema | Decisión |
|------|----------|
| Dominio | `planoon.com` comercial; `app.planoon.com` app |
| Monorepo | `docs/` + `marketing/` + Flutter en la raíz |
| Stack web v1 | HTML/CSS estático; framework después *dentro* de `marketing/` |
| Precios consumidor | No hay tabla; es gratis para participar |
| Pagos en app | Cuadre/anotación, **no** pasarela |
| GPS al “seguir” | No automático |
| Testimonios / métricas falsas | Prohibido |
| Contrato C1–C4 | Offline móvil, zonas horarias, invitar, exportar itinerario = **sí o sí** antes de público |

### Siguen abiertas (no cerrar al implementar)

- Identidad visual final, logo, colores, tipografía de **marca** (la app tiene tokens oscuros; la landing aún no)
- Copy exacto del hero y de los CTA
- Términos Participante / Invitado / Seguidor / Observador (hoy **observador** en producto)
- Modelo fino de permisos y de compartir público/privado
- Si hay Planoons/plantillas **públicas** en el lanzamiento → **no** (visión)
- Alcance exacto de recuerdos, Smart Import y cobros en el día L
- Modelo de negocio y proposición B2B
- Relación landing ↔ auth de la app (hoy: cuenta en `app.`)
- Qué demos son interactivas vs capturas
- Qué es feature de lanzamiento vs roadmap (usar la tabla de §6–8 + timeline)

Legales de la web (T171, fase 1.5 del timeline): **pendiente**; footer actual = “próximamente”.

---

## 21. Test guía

Para cada sección, componente, animación o frase:

**¿Esto ayuda a entender por qué querría usar Planoon?**  
Si no, probablemente no va en la home.

Para la home entera:

**¿Alguien que no ha oído hablar de Planoon entiende el producto en menos de 30 segundos?**  
Si no, simplificar.

---

## Referencias rápidas

| Tema | Doc |
|------|-----|
| Launch / fase 4 | [`TIMELINE_LANZAMIENTO.md`](./TIMELINE_LANZAMIENTO.md) |
| Dominio y DNS | [`DOMINIO_PLANOON.md`](../configuracion/DOMINIO_PLANOON.md) |
| Monorepo | [`MONOREPO.md`](../configuracion/MONOREPO.md) |
| Calendario / D&D | [`CALENDAR_CAPABILITIES.md`](../especificaciones/CALENDAR_CAPABILITIES.md) |
| Común / personal | [`GUIA_PATRON_COMUN_PERSONAL.md`](../guias/GUIA_PATRON_COMUN_PERSONAL.md) |
| Mi resumen | [`T252`](../tareas/T252_PARTICIPANTES_USUARIOS_VS_PLANIFICADORES.md) |
| Roles | [`ROLES_Y_TIPOS_USUARIO.md`](../configuracion/ROLES_Y_TIPOS_USUARIO.md) |
| Avisos | [`NOTIFICACIONES_ESPECIFICACION.md`](./NOTIFICACIONES_ESPECIFICACION.md) |
| Pagos | [`PAGOS_MVP.md`](./PAGOS_MVP.md) |
| Import mail | [`CORREO_EVENTOS_SISTEMA_PARSEO.md`](./CORREO_EVENTOS_SISTEMA_PARSEO.md) |
| Notas / preparación | [`FLUJO_NOTAS_PLAN.md`](../flujos/FLUJO_NOTAS_PLAN.md) |
| UI app | [`GUIA_UI.md`](../guias/GUIA_UI.md) |
| Legal | [`GUIA_ASPECTOS_LEGALES.md`](../guias/GUIA_ASPECTOS_LEGALES.md) |
