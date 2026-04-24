# 🎨 Guía de Interfaz de Usuario (UI)

Documento canónico y único para definir reglas UI de Planazoo (web, iOS y Android).  
Incluye diseño visual, jerarquía, tokens y tokenización estricta.

**Versión:** 2.0  
**Fecha:** Abril 2026

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

- Fondo app: `#111827`
- Superficie/capa de contenido: `#1F2937`
- Acento principal: `AppColorScheme.color2`
- Texto principal: blanco
- Texto secundario: `white70` / `white60`
- Borde estándar: blanco con alpha `0.12`
- Radio estándar: `12`

## Tokenización estricta (obligatoria)

No se permiten colores o alphas "a ojo" dentro de una pantalla.  
Cada pantalla debe declarar y reutilizar un set mínimo de tokens.

### Tokens de color base

- `cPageBg = Color(0xFF111827)`
- `cSurfaceBg = Color(0xFF1F2937)`
- `cTextPrimary = Colors.white`
- `cTextSecondary = Colors.white70`
- `cTextTertiary = Colors.white60`
- `cAccent = AppColorScheme.color2`
- `cDanger = Colors.redAccent`

### Tokens de alpha

- `aBorderStrong = 0.12`
- `aBorderSoft = 0.10`
- `aBorderSubtle = 0.08`
- `aSurfaceMuted = 0.04`
- `aSurfaceChip = 0.06`
- `aAccentSelected = 0.32`

### Reglas de cumplimiento

1. No hardcodear `Colors.white.withValues(alpha: x)` en múltiples variantes.
2. No mezclar varios alpha para el mismo tipo de estado visual.
3. Cualquier color/alpha nuevo debe declararse como token y justificarse.

## Tipografía

- Familia base UI: `GoogleFonts.poppins`
- Escala recomendada:
  - Título de sección: `12` / `w600`
  - Subtítulo de sección: `11`
  - Control/label: `12`
  - Valor/contenido: `13-14`
  - App bar título: `16`

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

## Estructura obligatoria de formulario/dialog

1. Identidad (tipo/subtipo/color si aplica)
2. Datos generales
3. Campos específicos del caso
4. Participación y límites
5. Coste
6. Opciones avanzadas
7. Apariencia (si no se incluyó antes)

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

- `AlertDialog` y `Dialog`: usar superficie `cSurfaceBg`, radio `12` y borde sutil `aBorderStrong` (blanco alpha `0.12`).
- `showModalBottomSheet`: usar fondo de hoja en `cPageBg`; handle y separadores en texto terciario/borde sutil (`white24` / `aBorderStrong`).
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
