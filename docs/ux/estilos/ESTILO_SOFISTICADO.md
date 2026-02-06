# 🎨 Estilo Base - Guía de Diseño

**Estado:** ✅ Aplicado  
**Versión:** 2.0  
**Fecha:** Diciembre 2025  
**Última actualización:** Febrero 2026  
**UI Principal:** Sí

**Implementación actual:** `AppTheme.darkTheme` y `AppColorScheme` en `lib/` (p. ej. `pg_dashboard_page.dart`, `pg_calendar_mobile_page.dart`, `pg_plan_detail_page.dart`, `wd_admin_insights_screen.dart`). Fondos `Colors.grey.shade800` y Poppins usados en dashboard y calendario.

---

## 🎯 Objetivo

El **Estilo Base** es la interfaz de usuario principal de la aplicación Planazoo. La app utiliza un diseño oscuro por defecto (no es un "modo oscuro" opcional, sino la UI estándar de la aplicación). Proporciona una experiencia visual premium con fondos oscuros elegantes y tipografía refinada.

**⚠️ IMPORTANTE:** Este no es un tema oscuro opcional. La aplicación Planazoo tiene una UI oscura por defecto. Todos los componentes deben seguir este estilo base.

---

## 🎨 Paleta de Colores

### Fondos
- **Fondo principal de pantalla (Estilo Base):** Color sólido `Colors.grey.shade800`
  - Sombra: `BoxShadow` con `color: Colors.black.withOpacity(0.3)`, `blurRadius: 8`, `offset: (0, 2)`
- **Fondo de cards/containers:** `Colors.grey.shade800` (color sólido, sin gradiente)
- **Sin bordes:** Los widgets no deben tener bordes

### Bordes
- **Sin bordes en widgets:** Los widgets del estilo base no tienen bordes
- **Borde de inputs (focused):** `AppColorScheme.color2`, width: `2.5` (solo cuando está enfocado)
- **Border radius:** `14px` para inputs, `18px` para cards

### Textos
- **Texto primario:** `Colors.white`
- **Texto secundario:** `Colors.grey.shade400`
- **Texto de hints/labels:** `Colors.grey.shade400` o `Colors.grey.shade500`
- **Texto de inputs:** `Colors.white`, `fontWeight: FontWeight.w500`

### Acentos
- **Color principal (botones, enlaces):** `AppColorScheme.color2`
- **Color de error:** `Colors.red.shade400` o `Colors.orange.shade400`
- **Color de éxito:** `Colors.green.shade600`

---

## 📝 Tipografía

### Fuente Principal
- **Familia:** `GoogleFonts.poppins`
- **Letter spacing:** `0.1` para títulos, `0.2-0.3` para botones

### Tamaños y Pesos
- **Títulos principales:** `fontSize: 32px`, `fontWeight: FontWeight.w600`
- **Títulos de sección:** `fontSize: 16-20px`, `fontWeight: FontWeight.w600`
- **Texto de cuerpo:** `fontSize: 14px`, `fontWeight: FontWeight.w500`
- **Labels de inputs:** `fontSize: 13px`, `fontWeight: FontWeight.w500`
- **Texto de botones:** `fontSize: 14-15px`, `fontWeight: FontWeight.w600`

---

## 🎴 Cards y Containers

### Estructura Base
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.grey.shade800, // Color sólido, sin gradiente
    borderRadius: BorderRadius.circular(18), // Opcional según el widget
    // Sin bordes
    // Sin sombras (boxShadow) - estilo minimalista
  ),
  child: // contenido
)
```

**Nota:** Los widgets básicos del dashboard (W1, W2, W3, W4, W29, W30, etc.) no tienen sombras para mantener un estilo limpio y minimalista. Las sombras solo se usan en elementos específicos como cards con contenido importante o botones interactivos.

---

## 📝 Campos de Entrada (Inputs)

### Estructura
Los inputs se envuelven en un Container con el gradiente y decoración, y el TextFormField tiene fondo transparente:

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.grey.shade800, // Color sólido, sin gradiente
    borderRadius: BorderRadius.circular(14),
    // Sin bordes
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.4),
        blurRadius: 12,
        offset: const Offset(0, 3),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 6,
        offset: const Offset(0, 1),
        spreadRadius: -2,
      ),
    ],
  ),
  child: TextFormField(
    style: GoogleFonts.poppins(
      fontSize: 14,
      color: Colors.white,
      fontWeight: FontWeight.w500,
    ),
    decoration: InputDecoration(
      labelText: 'Label',
      labelStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.grey.shade400,
        fontWeight: FontWeight.w500,
      ),
      hintText: 'Hint',
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.grey.shade500,
      ),
      prefixIcon: Icon(Icons.icon, color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.transparent,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColorScheme.color2,
          width: 2.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    ),
  ),
)
```

### Dropdowns
- **Background del menú:** `dropdownColor: Colors.grey.shade800`
- **Texto de opciones:** `GoogleFonts.poppins(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)`

---

## 🔘 Botones

### Botón Principal (ElevatedButton con color sólido)
```dart
Container(
  decoration: BoxDecoration(
    color: AppColorScheme.color2, // Color sólido, sin gradiente
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: AppColorScheme.color2.withOpacity(0.4),
        blurRadius: 16,
        offset: const Offset(0, 6),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
        spreadRadius: -2,
      ),
    ],
  ),
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 0,
    ),
    child: Text(
      'Texto',
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    ),
  ),
)
```

### Botón Secundario (OutlinedButton)
```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    side: BorderSide(
      color: Colors.grey.shade700.withOpacity(0.5),
      width: 1.5,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    backgroundColor: Colors.transparent,
  ),
  child: Text(
    'Texto',
    style: GoogleFonts.poppins(
      fontSize: 14,
      color: Colors.white,
      fontWeight: FontWeight.w500,
    ),
  ),
)
```

---

## 🎭 Scaffold y AppBar

### Scaffold
El fondo principal debe usar color sólido:

```dart
Theme(
  data: AppTheme.darkTheme,
  child: Scaffold(
    body: Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800, // Color sólido, sin gradiente
        // Sin bordes
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: // contenido
    ),
  ),
)
```

**Nota:** Si el Scaffold contiene un Stack o layout complejo, aplicar el gradiente al Container más externo.

### AppBar (si se usa)
```dart
AppBar(
  backgroundColor: Colors.grey.shade800, // Color sólido, sin gradiente
  foregroundColor: Colors.white,
  elevation: 0,
  // Sin flexibleSpace con gradiente
  title: Text(
    'Título',
    style: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 0.1,
    ),
  ),
)
```

---

## 📱 SafeArea

Para evitar superposiciones con la barra de estado del sistema:

```dart
body: SafeArea(
  child: // contenido
)
```

---

## 🎨 Sombras

### Sombras de Cards (2 capas)
- **Capa 1:** `color: Colors.black.withOpacity(0.4)`, `blurRadius: 24`, `offset: (0, 6)`
- **Capa 2:** `color: Colors.black.withOpacity(0.2)`, `blurRadius: 12`, `offset: (0, 2)`, `spreadRadius: -4`

### Sombras de Inputs (2 capas)
- **Capa 1:** `color: Colors.black.withOpacity(0.4)`, `blurRadius: 12`, `offset: (0, 3)`
- **Capa 2:** `color: Colors.black.withOpacity(0.2)`, `blurRadius: 6`, `offset: (0, 1)`, `spreadRadius: -2`

### Sombras de Botones (2 capas)
- **Capa 1:** `color: AppColorScheme.color2.withOpacity(0.4)`, `blurRadius: 16`, `offset: (0, 6)`
- **Capa 2:** `color: Colors.black.withOpacity(0.3)`, `blurRadius: 8`, `offset: (0, 2)`, `spreadRadius: -2`

---

## 📐 Espaciado

- **Padding de cards:** `32px` (all)
- **Padding de inputs:** `18px` horizontal, `18px` vertical
- **Espaciado entre elementos:** `16-24px` (SizedBox height)
- **Padding de pantalla:** `24px` (all)

---

## ✅ Checklist de Aplicación

Al aplicar el **Estilo Base** a una página, verificar:

- [ ] Fondo de Scaffold: Color sólido `Colors.grey.shade800` (sin gradiente)
- [ ] Theme: `AppTheme.darkTheme`
- [ ] SafeArea aplicado si es necesario
- [ ] Widgets básicos: Color sólido, sin gradiente, sin bordes, sin sombras
- [ ] Cards con contenido: Color sólido, sin gradiente, sin bordes (sombras opcionales según necesidad)
- [ ] Inputs envueltos en Container con color sólido (sin gradiente, sin bordes)
- [ ] Textos usando `GoogleFonts.poppins`
- [ ] Colores de texto: blanco/gris claro
- [ ] Botones con color sólido (sin gradiente, sombras opcionales)
- [ ] Border radius consistente (14px inputs, 18px cards, o según diseño)
- [ ] Sin bordes en widgets básicos (excepto inputs cuando están enfocados)
- [ ] Sin sombras en widgets básicos del dashboard (estilo minimalista)

---

## 📚 Páginas con Estilo Aplicado

- ✅ `LoginPage` - Aplicado
- ✅ `PlansListPage` - Aplicado
- ✅ `PlanDataScreen` - Aplicado
- ⏳ `RegisterPage` - Pendiente
- ⏳ `ProfilePage` - Pendiente
- ⏳ `EditProfilePage` - Pendiente

---

**Última actualización:** Febrero 2026

---

## 📝 Notas sobre AppColorScheme

Los colores definidos en `AppColorScheme` (color0, color1, color2, etc.) se utilizan en el contexto de la UI oscura base. Estos colores proporcionan acentos y elementos interactivos que contrastan adecuadamente con los fondos oscuros de la aplicación.

