# 🏗️ UX Architecture Diagram - UNP Calendario

## 📐 Diagrama del Grid 17×13

```
    C1   C2   C3   C4   C5   C6   C7   C8   C9   C10  C11  C12  C13  C14  C15  C16  C17
R1  ┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┐
    │ W1  │ W2  │     │ W3  │ W4  │ W5  │ W6  │     │     │     │     │ W7  │ W8  │ W9  │ W10 │ W11 │ W12 │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R2  ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │ W13 │     │     │     │ W14 │ W15 │ W16 │ W17 │ W18 │ W19 │ W20 │ W21 │ W22 │ W23 │ W24 │ W25 │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R3  ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │ W26 │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R4  ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │ W27 │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R5  ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │ W28 │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R6  ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R7  ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R8  ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R9  ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R10 ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R11 ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R12 ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
R13 └─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┘
    │ W29 │     │     │     │ W30 │     │     │     │     │     │     │     │     │     │     │     │     │
    │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │     │
```

## 🎯 Leyenda de Widgets

### **Header (R1)**
- **W1**: Barra lateral con perfil (C1, R1-R13) - **ACTUALIZADO v2.0** 🔵 Azul
- **W2**: Logo de la app (C2-C3, R1) - 🟢 Verde
- **W3**: Botón nuevo planazoo (C4, R1) - 🟠 Naranja
- **W4**: Espacio reservado (C5, R1) - 🟣 Púrpura - **ACTUALIZADO v1.2**
- **W5**: Imagen del plan seleccionado (C6, R1) - 🔵 Azul
- **W6**: Información del planazoo (C7-C11, R1) - 🔵 Cian
- **W7**: Info (C12, R1) - 🟡 Lima
- **W8**: Presupuesto (C13, R1) - 🟠 Naranja Oscuro
- **W9**: Contador participantes (C14, R1) - 🟣 Púrpura Oscuro
- **W10**: Mi estado en el planazoo (C15, R1) - 🔵 Gris Azulado
- **W11**: Libre (C16, R1) - 🟢 Verde Claro
- **W12**: Menú opciones (C17, R1) - ⚫ Gris

### **Barra de Herramientas (R2)**
- **W13**: Campo de búsqueda (C2-C5, R2) - 🔵 Teal
- **W14**: Acceso info planazoo (C6, R2) - 🔵 Azul Claro
- **W15**: Acceso calendario (C7, R2) - 🟢 Verde
- **W16**: Por definir (C8, R2) - 🟡 Amarillo
- **W17**: Por definir (C9, R2) - 🟠 Naranja
- **W18**: Por definir (C10, R2) - 🔴 Rojo
- **W19**: Por definir (C11, R2) - 🟣 Púrpura
- **W20**: Por definir (C12, R2) - 🔵 Índigo
- **W21**: Por definir (C13, R2) - 🔵 Teal
- **W22**: Por definir (C14, R2) - 🔵 Cian
- **W23**: Por definir (C15, R2) - 🟡 Ámbar
- **W24**: Icono notificaciones (C16, R2) - 🟠 Naranja Oscuro
- **W25**: Icono mensajes (C17, R2) - 🟣 Púrpura Oscuro

### **Área de Contenido (R3-R12)**
- **W26**: Filtros fijos (C2-C5, R3) - 🔵 Índigo
- **W27**: Espacio extra (C2-C5, R4) - 🟡 Ámbar
- **W28**: Lista de planazoos (C2-C5, R5-R12) - 🔴 Rojo
- **W31**: Pantalla principal (C6-C17, R3-R12) - 🔵 Azul

### **Footer (R13)**
- **W29**: Por definir (C2-C5, R13) - 🟤 Marrón
- **W30**: Por definir (C6-C17, R13) - 🟢 Verde Claro

## 🏗️ Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           UXDemoPage (StatefulWidget)                      │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    AppBar (Actions)                               │   │
│  │  ┌─────────────┐  ┌─────────────┐                                │   │
│  │  │   Refresh   │  │    Info     │                                │   │
│  │  │   Button    │  │   Button    │                                │   │
│  │  └─────────────┘  └─────────────┘                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    LayoutBuilder                                   │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │                    Container                                 │   │   │
│  │  │  ┌─────────────────────────────────────────────────────┐   │   │   │
│  │  │  │                      Stack                          │   │   │   │
│  │  │  │  ┌─────────────────────────────────────────────┐   │   │   │   │
│  │  │  │  │              CustomPaint                     │   │   │   │   │
│  │  │  │  │            (GridPainter)                     │   │   │   │   │
│  │  │  │  └─────────────────────────────────────────────┘   │   │   │   │
│  │  │  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐   │   │   │   │
│  │  │  │  │   W1    │ │   W2    │ │   W3    │ │   W4    │   │   │   │   │
│  │  │  │  │Positioned│ │Positioned│ │Positioned│ │Positioned│   │   │   │   │
│  │  │  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘   │   │   │   │
│  │  │  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐   │   │   │   │
│  │  │  │  │   W5    │ │   W6    │ │   W7    │ │   W8    │   │   │   │   │
│  │  │  │  │Positioned│ │Positioned│ │Positioned│ │Positioned│   │   │   │   │   │
│  │  │  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘   │   │   │   │
│  │  │  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐   │   │   │   │
│  │  │  │  │   W9    │ │   W10   │ │   W11   │ │   W12   │   │   │   │   │   │
│  │  │  │  │Positioned│ │Positioned│ │Positioned│ │Positioned│   │   │   │   │   │
│  │  │  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘   │   │   │   │
│  │  │  │  ┌─────────────────────────────────────────────┐   │   │   │   │
│  │  │  │  │                    W13                      │   │   │   │   │   │
│  │  │  │  │                 Positioned                  │   │   │   │   │   │
│  │  │  │  │              (C2-C5, R2)                    │   │   │   │   │   │
│  │  │  │  └─────────────────────────────────────────────┘   │   │   │   │
│  │  │  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐   │   │   │   │
│  │  │  │  │   W14   │ │   W15   │ │   W16   │ │   W17   │   │   │   │   │   │
│  │  │  │  │Positioned│ │Positioned│ │Positioned│ │Positioned│   │   │   │   │   │
│  │  │  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘   │   │   │   │
│  │  │  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐   │   │   │   │
│  │  │  │  │   W18   │ │   W19   │ │   W20   │ │   W21   │   │   │   │   │   │
│  │  │  │  │Positioned│ │Positioned│ │Positioned│ │Positioned│   │   │   │   │   │
│  │  │  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘   │   │   │   │
│  │  │  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐   │   │   │   │
│  │  │  │  │   W22   │ │   W23   │ │   W24   │ │   W25   │   │   │   │   │   │
│  │  │  │  │Positioned│ │Positioned│ │Positioned│ │Positioned│   │   │   │   │   │
│  │  │  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘   │   │   │   │
│  │  │  │  ┌─────────────────────────────────────────────┐   │   │   │   │
│  │  │  │  │                    W26                      │   │   │   │   │   │
│  │  │  │  │                 Positioned                  │   │   │   │   │   │
│  │  │  │  │              (C2-C5, R3)                    │   │   │   │   │   │
│  │  │  │  └─────────────────────────────────────────────┘   │   │   │   │
│  │  │  │  ┌─────────────────────────────────────────────┐   │   │   │   │
│  │  │  │  │                    W27                      │   │   │   │   │   │
│  │  │  │  │                 Positioned                  │   │   │   │   │   │
│  │  │  │  │              (C2-C5, R4)                    │   │   │   │   │   │
│  │  │  │  └─────────────────────────────────────────────┘   │   │   │   │
│  │  │  │  ┌─────────────────────────────────────────────┐   │   │   │   │
│  │  │  │  │                    W28                      │   │   │   │   │   │
│  │  │  │  │                 Positioned                  │   │   │   │   │   │
│  │  │  │  │            (C2-C5, R5-R12)                  │   │   │   │   │   │
│  │  │  │  └─────────────────────────────────────────────┘   │   │   │   │
│  │  │  │  ┌─────────────────────────────────────────────┐   │   │   │   │
│  │  │  │  │                    W31                      │   │   │   │   │   │
│  │  │  │  │                 Positioned                  │   │   │   │   │   │
│  │  │  │  │            (C6-C17, R3-R12)                 │   │   │   │   │   │
│  │  │  │  └─────────────────────────────────────────────┘   │   │   │   │
│  │  │  │  ┌─────────────────────────────────────────────┐   │   │   │   │
│  │  │  │  │                    W29                      │   │   │   │   │   │
│  │  │  │  │                 Positioned                  │   │   │   │   │   │
│  │  │  │  │              (C2-C5, R13)                   │   │   │   │   │   │
│  │  │  │  └─────────────────────────────────────────────┘   │   │   │   │
│  │  │  │  ┌─────────────────────────────────────────────┐   │   │   │   │
│  │  │  │  │                    W30                      │   │   │   │   │   │
│  │  │  │  │                 Positioned                  │   │   │   │   │   │
│  │  │  │  │             (C6-C17, R13)                   │   │   │   │   │   │
│  │  │  │  └─────────────────────────────────────────────┘   │   │   │   │
│  │  │  └─────────────────────────────────────────────────────┘   │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 🔄 Flujo de Datos

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   UXDemoPage    │    │ UXJsonGenerator  │    │ JSON Files      │
│                 │    │                  │    │                 │
│ ┌─────────────┐ │    │ ┌──────────────┐ │    │ ┌─────────────┐ │
│ │   Widgets   │ │    │ │  generateUX  │ │    │ │ assets/     │ │
│ │             │ │    │ │Specification │ │    │ │ ux_spec.json│ │
│ │ 31 Widgets  │ │    │ │              │ │    │ │             │ │
│ │             │ │    │ │  saveUX      │ │    │ └─────────────┘ │
│ └─────────────┘ │    │ │Specification │ │    │ ┌─────────────┐ │
│                 │    │ └──────────────┘ │    │ │ docs/       │ │
│ ┌─────────────┐ │    │ ┌──────────────┐ │    │ │ ux_spec.json│ │
│ │   AppBar    │ │    │ │ _generate    │ │    │ │             │ │
│ │             │ │    │ │ LayoutPx     │ │    │ └─────────────┘ │
│ │ Refresh     │ │    │ └──────────────┘ │    │ ┌─────────────┐ │
│ │ Info        │ │    └──────────────────┘    │ │ UX_README   │ │
│ └─────────────┘ │                            │ │ .md         │ │
└─────────────────┘                            │ └─────────────┘ │
         │                                      │ ┌─────────────┐ │
         │                                      │ │ UX_TECHNICAL│ │
         │                                      │ │ _DOC.md     │ │
         │                                      │ └─────────────┘ │
         │                                      │ ┌─────────────┐ │
         │                                      │ │ UX_ARCH    │ │
         │                                      │ │ _DIAGRAM.md│ │
         │                                      │ └─────────────┘ │
         │                                      └─────────────────┘
         │
         ▼
┌─────────────────┐
│   User Action   │
│                 │
│ Click Refresh   │
│ Click Info      │
└─────────────────┘
```

## 🎨 **W1 - Barra Lateral (ACTUALIZADO v2.0)**

### **📍 Especificaciones Técnicas**
- **Posición**: C1 (R1-R13) - Columna completa, 13 filas
- **Color**: `AppColorScheme.color2` (azul de la app)
- **Forma**: Rectángulo con esquinas cuadradas
- **Contenido**: Solo icono de perfil redondo

### **🎯 Funcionalidad**
- **Navegación**: Tap → Cambia a pantalla de perfil
- **Tooltip**: Multidioma (ES: "Ver perfil", EN: "View profile")
- **Posicionamiento**: Icono centrado en la parte inferior
- **Accesibilidad**: Tamaño de touch target 48x48px

### **🔧 Implementación**
```dart
// Contenedor principal sin borderRadius
Container(
  decoration: BoxDecoration(color: AppColorScheme.color2),
  child: Align(
    alignment: Alignment.bottomCenter,
    child: Tooltip(
      message: AppLocalizations.of(context)!.profileTooltip,
      child: GestureDetector(
        onTap: () => setState(() => currentScreen = 'profile'),
        child: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24), // Redondo
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 24),
        ),
      ),
    ),
  ),
)
```

## 🎨 **W4 - Espacio Reservado (ACTUALIZADO v1.2)**

### **📍 Especificaciones Técnicas**
- **Posición**: C5 (R1) - Columna 5, Fila 1
- **Color**: `Colors.white` (blanco)
- **Forma**: Rectángulo con esquinas cuadradas
- **Contenido**: Vacío (espacio reservado)

### **🎯 Funcionalidad**
- **Estado**: Sin funcionalidad actual
- **Propósito**: Mantener estructura visual del grid
- **Interactividad**: Ninguna
- **Futuro**: Espacio reservado para funcionalidades futuras

### **🔧 Implementación**
```dart
// Container simple para mantener estructura
Container(
  width: w4Width,
  height: w4Height,
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(color: Colors.white, width: 2),
  ),
  // Sin contenido por el momento
)
```

### **📋 Historial de Cambios**
- **v1.0**: Creación inicial como espacio reservado
- **v1.1**: Simplificación a container blanco vacío
- **v1.2**: Eliminación de botón iPhone simulator

## 🖼️ **W5 - Imagen del Plan (ACTUALIZADO v1.3)**

### **📍 Especificaciones Técnicas**
- **Posición**: C6 (R1) - Columna 6, Fila 1
- **Color**: `AppColorScheme.color1` (azul)
- **Forma**: Rectángulo con imagen circular centrada
- **Contenido**: Imagen del plan seleccionado

### **🎯 Funcionalidad**
- **Estado**: Funcional - muestra imagen del plan seleccionado
- **Propósito**: Representación visual del plan actual
- **Responsive**: Se adapta al tamaño del contenedor

### **🔧 Implementación**
```dart
Container(
  decoration: BoxDecoration(
    color: AppColorScheme.color1,
    border: Border.all(color: AppColorScheme.color1, width: 2),
  ),
  child: Center(
    child: Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColorScheme.color2, width: 2),
      ),
      child: ClipOval(child: _buildPlanImage()),
    ),
  ),
)
```

### **📋 Historial de Cambios**
- **v1.0**: Creación inicial con fondo blanco
- **v1.1**: Implementación de imagen circular
- **v1.2**: Integración con Firebase Storage
- **v1.3**: Cambio de fondo a color1

### **🚀 Funcionalidades Futuras Consideradas**
- Menú de opciones adicionales
- Selector de vista del calendario
- Filtros de eventos
- Configuraciones rápidas
- Accesos directos

## 🎨 Sistema de Colores Detallado

### **Colores Primarios**
- 🔵 **Azul**: W1, W31 (Elementos principales)
- 🟢 **Verde**: W2, W15 (Acciones positivas)
- 🟠 **Naranja**: W3, W17 (Acciones de creación)
- 🟣 **Púrpura**: W4, W19 (Configuración)

### **Colores Secundarios**
- 🔵 **Azul**: W5 (Imagen del plan)
- 🔵 **Cian**: W6, W22 (Información)
- 🟡 **Lima**: W7 (Información general)
- 🟠 **Naranja Oscuro**: W8, W24 (Alertas)

### **Colores Terciarios**
- 🟣 **Púrpura Oscuro**: W9, W25 (Comunicación)
- 🔵 **Gris Azulado**: W10 (Estado personal)
- 🟢 **Verde Claro**: W11, W30 (Disponibilidad)
- ⚫ **Gris**: W12 (Opciones)

### **Colores Especiales**
- 🔵 **Teal**: W13, W21 (Búsqueda y filtros)
- 🔵 **Azul Claro**: W14 (Acceso a información)
- 🟡 **Amarillo**: W16 (Atención)
- 🔴 **Rojo**: W18, W28 (Listas y contenido)
- 🔵 **Índigo**: W20, W26 (Filtros y herramientas)
- 🟡 **Ámbar**: W23, W27 (Espacios temporales)
- 🟤 **Marrón**: W29 (Footer)

## 📱 Responsive Design

### **Breakpoints**
```
Desktop (1920x1080): 100% del tamaño
Tablet (1728x1026):  90% del tamaño
Mobile (1344x972):   70% del tamaño
```

### **Adaptación Automática**
- **LayoutBuilder**: Detecta dimensiones del dispositivo
- **Cálculo Dinámico**: columnWidth y rowHeight se adaptan
- **Proporciones**: Mantiene relaciones de aspecto del grid
- **Escalado**: Widgets se redimensionan proporcionalmente

## 🔧 Implementación Técnica

### **Clases Principales**
```dart
class UXDemoPage extends StatefulWidget
class _UXDemoPageState extends State<UXDemoPage>
class GridPainter extends CustomPainter
class UXJsonGenerator
```

### **Métodos Clave**
```dart
Widget _buildGrid()
Widget _buildW1() ... Widget _buildW31()
void _showJsonInfo(BuildContext context)
Map<String, dynamic> generateUXSpecification()
Future<void> saveUXSpecification()
```

### **Dependencias**
```yaml
flutter:
  sdk: flutter
dart:convert
dart:io
```

---

**Diagrama generado automáticamente**  
**Última actualización**: ${DateTime.now().toString()}  
**Versión**: 2.0
