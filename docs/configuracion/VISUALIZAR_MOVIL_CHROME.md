# 📱 Visualizar App en Móvil con Chrome DevTools

## 🎯 Objetivo

Ver la app Flutter web como si estuviera en un dispositivo móvil **sin necesidad de emulador Android/iOS**, usando solo Chrome DevTools.

## ✅ Ventajas

- ✅ **Sin instalación adicional**: Solo Chrome
- ✅ **Rápido**: No requiere emulador pesado
- ✅ **Hot reload**: Funciona con Flutter hot reload
- ✅ **Múltiples dispositivos**: Puedes probar diferentes tamaños
- ✅ **Sin consumo de recursos**: No requiere RAM/CPU extra

## 🚀 Pasos

### 1. Ejecutar Flutter Web

```bash
flutter run -d chrome
```

O si ya tienes la app corriendo, simplemente abre Chrome.

### 2. Abrir Chrome DevTools

**Opción A: Atajo de teclado**
- Presiona `F12` o `Ctrl+Shift+I` (Windows/Linux)
- Presiona `Cmd+Option+I` (Mac)

**Opción B: Menú**
- Click derecho → "Inspeccionar"
- Menú Chrome → Más herramientas → Herramientas de desarrollador

### 3. Activar Modo Dispositivo

**Opción A: Toggle Device Toolbar**
- Presiona `Ctrl+Shift+M` (Windows/Linux)
- Presiona `Cmd+Shift+M` (Mac)
- O haz click en el ícono de dispositivo móvil (📱) en la barra de herramientas

**Opción B: Menú**
- En DevTools, busca el botón "Toggle device toolbar" (icono de móvil/tablet)

### 4. Seleccionar Dispositivo

En la barra superior de DevTools, verás un dropdown con dispositivos predefinidos:

- **iPhone 12 Pro** (390 x 844)
- **iPhone SE** (375 x 667)
- **Samsung Galaxy S20** (360 x 800)
- **iPad Pro** (1024 x 1366)
- **Pixel 5** (393 x 851)
- **Custom...** (tamaño personalizado)

### 5. Rotar Pantalla (Opcional)

- Click en el botón de rotación (↻) para cambiar entre portrait y landscape

## 📐 Tamaños de Dispositivos Comunes

| Dispositivo | Ancho | Alto | Orientación |
|------------|-------|------|-------------|
| iPhone 14 Pro | 393 | 852 | Portrait |
| iPhone SE | 375 | 667 | Portrait |
| Samsung Galaxy S21 | 360 | 800 | Portrait |
| iPad Air | 820 | 1180 | Portrait |
| Pixel 7 | 412 | 915 | Portrait |

## 🎨 Características del Modo Dispositivo

### ✅ Lo que simula:
- ✅ Tamaño de pantalla exacto
- ✅ Viewport responsive
- ✅ Touch events (clicks se convierten en touch)
- ✅ Throttling de CPU (opcional)
- ✅ Geolocalización (opcional)
- ✅ Orientación (portrait/landscape)

### ❌ Lo que NO simula:
- ❌ Gestos táctiles complejos (pinch, swipe, etc.)
- ❌ Rendimiento real del dispositivo
- ❌ APIs nativas (cámara, notificaciones push, etc.)
- ❌ Sensores del dispositivo (acelerómetro, etc.)

## 🔧 Configuración Avanzada

### Throttling de CPU (Simular dispositivo lento)

1. En DevTools, ve a la pestaña "Performance" o "Network"
2. Activa "CPU throttling" desde el dropdown
3. Selecciona "6x slowdown" o "4x slowdown" para simular dispositivo más lento

### Throttling de Red (Simular conexión lenta)

1. En DevTools, ve a la pestaña "Network"
2. En el dropdown de throttling, selecciona:
   - **Slow 3G**: Para simular conexión lenta
   - **Fast 3G**: Para simular conexión móvil normal
   - **Offline**: Para probar modo offline

### Tamaño Personalizado

1. En el dropdown de dispositivos, selecciona "Edit..."
2. Click en "Add custom device"
3. Define:
   - Nombre del dispositivo
   - Ancho y alto
   - DPR (Device Pixel Ratio) - generalmente 2 o 3 para móviles modernos
   - User agent (opcional)

## 💡 Tips

### Hot Reload
- El modo dispositivo **funciona perfectamente** con hot reload de Flutter
- Los cambios se reflejan inmediatamente en la vista móvil

### Guardar Configuración
- Chrome guarda automáticamente el último dispositivo seleccionado
- Al recargar, mantendrá el mismo dispositivo

### Comparar Desktop vs Mobile
- Puedes tener dos ventanas de Chrome abiertas
- Una en modo desktop, otra en modo móvil
- Comparar visualmente las diferencias

### Testing Responsive
- Cambia el tamaño de la ventana manualmente
- O usa el modo "Responsive" en el dropdown
- Útil para probar breakpoints

## 🐛 Troubleshooting

### La app no se ve bien en móvil

**Problema**: Faltan meta tags de viewport
**Solución**: Verificar que `web/index.html` tenga:
```html
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

### Los eventos táctiles no funcionan

**Problema**: Chrome simula touch, pero puede que necesites ajustes en Flutter
**Solución**: Verificar que los widgets usen `GestureDetector` o `InkWell` correctamente

### El rendimiento no se parece al real

**Problema**: El modo dispositivo no simula el rendimiento real
**Solución**: Para testing real, usar dispositivo físico o emulador completo

## 📝 Notas

- Este método es **perfecto para desarrollo rápido** y testing visual
- Para testing funcional completo (gestos, APIs nativas), usar dispositivo físico o emulador
- El modo dispositivo es más ligero y rápido que emuladores completos
- Ideal para verificar responsive design y UI en diferentes tamaños

## 🔗 Referencias

- [Chrome DevTools Device Mode](https://developer.chrome.com/docs/devtools/device-mode/)
- [Flutter Web Performance](https://docs.flutter.dev/platform-integration/web)
- [Responsive Design Guidelines](https://docs.flutter.dev/development/ui/layout/responsive)

---

**Última actualización**: Enero 2025  
**Versión**: 1.0

