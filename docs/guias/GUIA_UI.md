# 🎨 Guía de Interfaz de Usuario (UI)

Documento canónico y único para definir reglas UI de Planazoo (web, iOS y Android).  
Incluye diseño visual, jerarquía, tokens y tokenización estricta.

**Versión:** 2.1  
**Fecha:** Agosto 2026

## Objetivo

Definir un sistema visual único para toda la app, de forma que:

- Las pantallas nuevas nazcan alineadas al estándar.
- Las pantallas existentes se migren sin romper funcionalidad.
- Las decisiones UI sean consistentes y auditables.

## Principios de diseño

1. Consistencia por encima de creatividad aislada.
2. Jerarquía visual clara antes que decoración.
3. UI y lógica separadas: cambios visuales no alteran comportamiento.
4. Misma identidad en web y móvil (cambia layout, no lenguaje visual).

## Tokens visuales obligatorios

### App / pantallas generales
- Fondo app: `#000000` (iOS `systemGroupedBackground` dark) — migrando desde `#111827`
- Superficie agrupada: `#1C1C1E` (iOS `secondarySystemGroupedBackground`)
- Superficie campo (legacy editable): `#1F2937` / `#2C2C2E`
- Acento principal: `AppColorScheme.color2`
- Texto principal: `#FFFFFF` (label)
- Texto secundario: `#EBEBF5` @ 60% (`secondaryLabel`)
- Texto terciario: `#EBEBF5` @ 30% (`tertiaryLabel`)
- Separador: `#545458` @ ~60%
- Peligro: `#FF453A` (systemRed dark)
- Radio agrupado: `12`

### Implementación canónica
- Tokens y bloques: `lib/widgets/common/ios_grouped_form.dart` (`IosFormColors`, `IosGroupedCard`, `IosSettingsRow`, `IosFormEditBar`, `IosHeroHeader`, …)
- Pantallas de referencia: Info del plan (`wd_plan_data_screen.dart`), evento (`wd_event_dialog.dart`), alojamiento (`wd_accommodation_dialog.dart`)

## Tokenización estricta (obligatoria)

No se permiten colores o alphas "a ojo" dentro de una pantalla.  
Cada pantalla debe declarar y reutilizar un set mínimo de tokens.

### Tokens de color base (formularios iOS / patrón D)

- `cPageBg = Color(0xFF000000)` — `IosFormColors.pageBg`
- `cSurfaceBg = Color(0xFF1C1C1E)` — `IosFormColors.groupedBg`
- `cTextPrimary = Color(0xFFFFFFFF)`
- `cTextSecondary = Color(0x99EBEBF5)`
- `cTextTertiary = Color(0x4DEBEBF5)`
- `cSeparator = Color(0x99545458)`
- `cAccent = AppColorScheme.color2`
- `cDanger = Color(0xFFFF453A)`

### Tokens legacy (pantallas aún no migradas)

- `cPageBgLegacy = Color(0xFF111827)`
- `cSurfaceBgLegacy = Color(0xFF1F2937)`
- `cTextPrimary = Colors.white`
- `cTextSecondary = Colors.white70`
- `cTextTertiary = Colors.white60`

### Tokens de alpha

- `aBorderStrong = 0.12` (evitar en formularios D: preferir separadores internos sin borde de card)
- `aBorderSoft = 0.10`
- `aBorderSubtle = 0.08`
- `aSurfaceMuted = 0.04`
- `aSurfaceChip = 0.06`
- `aAccentSelected = 0.32`

### Reglas de cumplimiento

1. No hardcodear `Colors.white.withValues(alpha: x)` en múltiples variantes.
2. No mezclar varios alpha para el mismo tipo de estado visual.
3. Cualquier color/alpha nuevo debe declararse como token y justificarse.
4. Formularios de ficha (plan / evento / alojamiento): usar `IosFormColors` y el patrón view/edit (sección siguiente).

## Tipografía

- Familia base UI: sistema / `TextStyle` iOS en fichas; `GoogleFonts.poppins` aceptable en pantallas legacy.
- Escala fichas (patrón D):
  - Título hero: `28` / `w700`
  - Label fila Settings: `17`
  - Valor fila: `17` (secundario)
  - Label de campo en edición: `13` / secundario
  - Sección (`GENERAL`, `NOTAS`): `13` / terciario / uppercase
  - App bar / Edit bar: `17`

## Espaciado base

- `4`: micro separación
- `8`: elementos directos
- `10`: dentro de bloques compactos
- `12`: separación estándar entre controles
- `16`: separación entre secciones
- `24`: separación mayor entre zonas

## Estructura obligatoria de página

1. Cabecera de contexto (título + acción principal).
2. Cuerpo por bloques funcionales (cards/secciones).
3. Jerarquía de acciones clara (primaria, secundaria, destructiva).

## Formularios tipo ficha (patrón D · obligatorio en plan / evento / alojamiento)

> **Fuente de verdad:** layout y densidad de **iOS / Android**. Web reutiliza los mismos widgets; solo cambia el marco (fullscreen vs diálogo centrado).

### Evento y alojamiento (acordado)

1. **Un solo formulario** al abrir (crear o editar): siempre editable si hay permiso; **sin** modo vista/edición separado.
2. **Barra** `IosFormEditBar`: siempre `Cancelar` + `Guardar`/`Crear` (si no hay permiso: solo cerrar; campos bloqueados).
3. **Cancelar**: cierra el diálogo (descarta cambios locales).
4. **Hero**: título editable + subtítulo + chips (fecha/duración o estancia/noches).
5. **Estado** (Confirmado / Borrador): chip a la derecha de duración (evento) o noches (alojamiento); verde confirmado / naranja borrador (`ColorUtils.confirmedColors`).
6. **Cards** `IosGroupedCard` sin borde duro; separadores `IosRowSeparator`.
7. **Destructivas** (eliminar): abajo, `IosDestructiveTile`.
8. **Sin permiso**: misma UI; edición bloqueada; Maps/URL seguibles si aplica.

### Sistema de campos Settings-only (acordado 2026-08-26)

Un solo lenguaje visual en ficha evento/alojamiento. Prohibido mezclar estilos legacy.

**Anatomía**

```
[ Hero ]
[ IosGroupedCard … ]
[ IosDestructiveTile ]
```

- Página: `IosFormColors.pageBg`
- Card: `IosFormColors.groupedBg`
- **Prohibido** en General (evento) y formulario alojamiento: `_buildLabelOnBorderField`, `_buildLoginStyleDecoration`, `_standardFieldDecoration` (salvo migración pendiente de transporte/vuelo).

**Solo 3 tipos de fila**

| Tipo | Widget | Uso |
|------|--------|-----|
| Picker | `IosSettingsRow` + chevron | Tipo, timezone, color, moneda, fechas… |
| Texto | `IosEditField` | URL, notas, nº vuelo, coste… |
| Toggle / lista | Checkbox/lista en card | “Para todos”, participantes |

**Títulos de sección**

- ≥ 2 filas en la card → `IosSectionLabel` arriba.
- 1 sola fila → **sin** `IosSectionLabel`; el label vive solo en la fila.

**Tipografía**

- Fila raíz (`nestLevel: 0`): label `textPrimary`, valor `textSecondary`.
- Fila anidada (`nestLevel ≥ 1`): label `textSecondary`, valor `textPrimary`.
- Captions de card: `textTertiary`, mayúsculas (`IosGroupedCardCaption`).
- Tokens: solo `IosFormColors` (no tipografías ad hoc por campo).

**Secciones colapsables — jerarquía en árbol (`nestLevel`)** *(estándar 2026-08-26)*

Cuando una card se expande (`IosCollapsibleHeader`) o un control despliega hijos (switch «Para todos», tramo de cancelación…), los campos hijos deben leerse claramente como **pertenecientes** a esa sección:

| Nivel | Sangría (`IosFormColors.nestPaddingLeft`) | Tipografía | Uso |
|-------|------------------------------------------|------------|-----|
| `0` | 16 px | label primario | Cabecera colapsable, filas raíz del formulario |
| `1` | 28 px | label secundario, valor primario | Campos bajo sección expandida; captions/footers alineados |
| `2` | 40 px | idem | Nietos (p. ej. Límite / Porcentaje bajo «Tramo 1») |

**Widgets con `nestLevel`:** `IosSettingsRow`, `IosSwitchRow`, `IosCheckRow` (`indented` ≡ nivel 1), `IosRowSeparator`, `IosGroupedCardCaption`, `IosFormFooter`.

**Reglas**

- Tras expandir: primer separador a ancho completo (`nestLevel: 0`); el resto del bloque hijo en nivel 1.
- Sub-bloques en card aparte (p. ej. tramos de cancelación): `Padding(left: 8)` + filas con `nestLevel: 1`.
- No mezclar filas anidadas sin `nestLevel` junto a cabeceras colapsables.
- Referencia implementada: `ReservationCancellationFormSection`, participantes («Para todos» + lista).

**Excepciones**

- Hero (título grande + chips)
- Rejilla de tipo/subtipo al expandir el picker
- Bloques muy específicos (Amadeus, sponsor) **dentro** de card, sin otro estilo de input

**Migración evento (orden)**

1. ~~URL, notas, coste, color, “para todos”~~
2. ~~Localización / adjuntos~~
3. ~~Transporte / vuelo / transfer / alquiler~~ (`_buildLabelOnBorderField` retirado del General)
4. ~~Pestaña “Mi info” (evento y alojamiento)~~ → Settings. ~~Info de Otros (admin)~~ → Settings. ~~Participantes~~ / ~~Reserva·cancelación~~ → Settings + `nestLevel`.

**General evento:** tipografía y cards unificadas a Settings/`IosFormColors` (incl. vuelo, transporte, transfer, alquiler, sponsor). Places/Amadeus siguen como widgets específicos **dentro** de cards Settings.

**Pagos:** `AddExpenseDialog` permite vincular evento **o** alojamiento; resumen del plan muestra ambos enlaces.

**Aparcado (futuro): Opciones avanzadas del evento**

- UI retirada del formulario General (2026-08-26): límite de aforo (`maxParticipants`) y «Requiere confirmación» (`requiresConfirmation`).
- Modelo/servicio siguen vigentes; al guardar se **preservan** los valores del evento existente (no se editan desde la ficha).
- Reintroducir con `IosCollapsibleHeader` + `nestLevel` cuando haga falta; l10n: `eventAdvancedOptionsTitle` / `eventAdvancedOptionsSubtitle`.

### Info del plan

Alineado a evento/alojamiento (2026-08-27): **formulario siempre editable** si hay permiso (`Cancelar` descarta / `Guardar` persiste; sin modo vista intermedio). Solo lectura cuando `forceReadOnly` o el estado del plan lo bloquea. Cards Settings + `IosFormEditBar` (local o hosteada en detalle del plan).

## Estructura obligatoria de formulario/dialog (contenido en edición)

1. Identidad (tipo/subtipo/color si aplica)
2. Datos generales
3. Campos específicos del caso
4. Participación y límites
5. Coste
6. Apariencia (color; si no se incluyó antes)

*(Opciones avanzadas — aforo / confirmación explícita: aparcadas; ver Settings-only § Aparcado.)*

## Reglas de componentes

- Inputs: mismo radio, borde y focus en `cAccent`.
- Chips: seleccionado en acento, no seleccionado con fondo tenue.
- Tabs/segmentos: variante plana, sin gradientes agresivos.
- Botón primario: `cAccent`, texto blanco, radio 12.
- Botón secundario: contraste medio.
- Botón destructivo: rojo semántico.
- Chips de acceso rápido (resumen): fondo tenue (`aSurfaceMuted`) + borde sutil (`aBorderStrong`); estado activo con acento.
- Chips de enlace (maps/web): contenedor compacto oscuro con borde de acento semitransparente; icono en `cAccent`.
- Chat (burbujas y reacciones): burbuja propia en `cAccent`, resto en `cSurfaceBg`; metadatos en texto secundario; reacciones como chips compactos de bajo contraste.

### Header de sección (SectionTitleBar)

Componente estándar para titular cada sección principal dentro de una pantalla de plan.

- **Uso:** encima del contenido de cada pestaña/sección principal (`Info`, `Calendario`, `Participantes`, `Chat`, etc.).
- **Altura fija:** `48`.
- **Fondo:** `cPageBg`.
- **Separador inferior:** borde `aBorderSoft` (blanco semitransparente).
- **Título:** `GoogleFonts.poppins`, `16`, `w600`, color `cTextPrimary`.
- **Alineación:** título a la izquierda, centrado vertical.
- **Padding horizontal:** `20`.

#### Acciones en header (iconos/botones)

- Se permiten acciones a la derecha (iconos, chips compactos o botón secundario).
- Mantener prioridad visual del título: máximo 1-3 acciones compactas (excepción válida en vistas densas como "Mi resumen").
- Iconografía por defecto en `cTextSecondary`; estado activo en `cAccent`.
- Si hay acción destructiva, usar color semántico (`cDanger`) solo en esa acción.
- Evitar CTA primario grande en este header; el primario debe vivir en el contenido o barra de acciones.
- Si hay chips de modo/filtro en el header, alinear a la derecha y usar variante compacta: fondo de superficie oscura en estado normal, acento tenue en estado activo, borde sutil constante.

### Modales y hojas inferiores (norma)

- `AlertDialog` y `Dialog` de ficha (evento / alojamiento / info): fondo `IosFormColors.pageBg` (`#000`), sin borde duro en móvil (full-bleed); en desktop radio `12–18`.
- Patrón ficha evento/alojamiento/info plan: ver § **Formularios tipo ficha (patrón D)** (formulario único editable con permiso).
- `showModalBottomSheet`: usar fondo de hoja en `cPageBg`; handle y separadores en texto terciario/borde sutil.
- Bloques informativos internos (info/warning/success): mantener fondo tenue con alpha bajo y borde semántico semitransparente, sin volver a paletas legacy claras.
- En diálogos con filtros/chips, estado activo en `cAccent`; inactivo en superficie oscura con borde sutil.

### Componentes financieros UI-SP (añadido)

- **Card de balance expandible:** usar `ExpansionTile` dentro de card de superficie con borde sutil y estado por color semántico (acreedor/deudor/equilibrado).
- **Badge de importe en borde:** permitir etiqueta flotante superior (importe) con fondo `cPageBg`, borde semántico y tipografía compacta.
- **Fila de transferencia sugerida:** contenedor de superficie tenue (`aSurfaceMuted`) con borde acento y jerarquía `origen -> importe -> destino`.
- **Aviso legal financiero:** bloque informativo en `cSurfaceBg` con borde semántico (warning) y texto secundario; no usar estilos legacy fuera de tokens.

## Estados de interfaz obligatorios

Toda pantalla nueva debe contemplar:

- Empty state
- Loading state
- Error state
- Success feedback (SnackBar)

## Consistencia web/móvil

- Mismo sistema visual, distinta densidad/layout.
- No introducir variantes de color por plataforma sin decisión documentada.
- No mezclar estilos legacy y actuales en una misma pantalla.

## Internacionalización UI

- Todo texto visible al usuario debe salir de `AppLocalizations`.
- No hardcodear cadenas en pantallas de producción.

## Proceso de aplicación (demo -> real)

1. Pasada 1: tokens visuales.
2. Pasada 2: orden/jerarquía de secciones.
3. Pasada 3: ajuste fino (densidad, contraste, microespaciado).
4. Verificación final: sin regresión funcional y linter limpio.

## Definition of Done UI

Una tarea UI está cerrada cuando:

- Cumple tokens y jerarquía del estándar.
- Es consistente en web y móvil.
- Muestra estados empty/loading/error de forma clara.
- Mantiene la lógica funcional intacta.
- Pasa revisión visual y linter.
