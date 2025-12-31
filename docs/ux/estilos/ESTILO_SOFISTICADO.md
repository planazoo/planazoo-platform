# 🎨 Estilo "Sofisticado" - Guía de Diseño

**Estado:** ✅ Aplicado  
**Versión:** 1.0  
**Fecha:** Diciembre 2024  
**Look Principal:** Sí

---

## 🎯 Objetivo

El estilo "Sofisticado" es el look principal de la aplicación Planazoo. Proporciona una experiencia visual premium con un diseño oscuro elegante, gradientes sutiles y tipografía refinada.

---

## 🎨 Paleta de Colores

### Fondos
- **Fondo principal de pantalla:** `Colors.grey.shade900`
- **Fondo de cards/containers (inicio):** `Colors.grey.shade800`
- **Fondo de cards/containers (fin):** `Color(0xFF2C2C2C)`
- **Gradiente de cards:** `LinearGradient` de `Colors.grey.shade800` → `Color(0xFF2C2C2C)`

### Bordes
- **Borde de cards:** `Colors.grey.shade700.withOpacity(0.5)`, width: `1`
- **Borde de inputs (focused):** `AppColorScheme.color2`, width: `2.5`
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
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.grey.shade800,
        const Color(0xFF2C2C2C),
      ],
    ),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: Colors.grey.shade700.withOpacity(0.5),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.4),
        blurRadius: 24,
        offset: const Offset(0, 6),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 12,
        offset: const Offset(0, 2),
        spreadRadius: -4,
      ),
    ],
  ),
  child: // contenido
)
```

---

## 📝 Campos de Entrada (Inputs)

### Estructura
Los inputs se envuelven en un Container con el gradiente y decoración, y el TextFormField tiene fondo transparente:

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.grey.shade800,
        const Color(0xFF2C2C2C),
      ],
    ),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: Colors.grey.shade700.withOpacity(0.5),
      width: 1,
    ),
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

### Botón Principal (ElevatedButton con gradiente)
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColorScheme.color2,
        AppColorScheme.color2.withOpacity(0.85),
      ],
    ),
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
```dart
Theme(
  data: AppTheme.darkTheme,
  child: Scaffold(
    backgroundColor: Colors.grey.shade900,
    // ...
  ),
)
```

### AppBar (si se usa)
```dart
AppBar(
  backgroundColor: Colors.grey.shade800,
  foregroundColor: Colors.white,
  elevation: 0,
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.grey.shade800,
          const Color(0xFF2C2C2C),
        ],
      ),
    ),
  ),
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

Al aplicar el estilo "Sofisticado" a una página, verificar:

- [ ] Fondo de Scaffold: `Colors.grey.shade900`
- [ ] Theme: `AppTheme.darkTheme`
- [ ] SafeArea aplicado si es necesario
- [ ] Cards con gradiente y sombras correctas
- [ ] Inputs envueltos en Container con gradiente
- [ ] Textos usando `GoogleFonts.poppins`
- [ ] Colores de texto: blanco/gris claro
- [ ] Botones con gradiente y sombras
- [ ] Border radius consistente (14px inputs, 18px cards)
- [ ] Sombras de 2 capas aplicadas

---

## 📚 Páginas con Estilo Aplicado

- ✅ `LoginPage` - Aplicado
- ✅ `PlansListPage` - Aplicado
- ✅ `PlanDataScreen` - Aplicado
- ⏳ `RegisterPage` - Pendiente
- ⏳ `ProfilePage` - Pendiente
- ⏳ `EditProfilePage` - Pendiente

---

**Última actualización:** Diciembre 2024

