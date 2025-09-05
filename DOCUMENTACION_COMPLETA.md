# 📋 DOCUMENTACIÓN COMPLETA - APLICACIÓN PLANAZOO

## 🎯 **DESCRIPCIÓN GENERAL**
Aplicación Flutter para gestionar "planazoos" (planes de zoo) con calendario interactivo, eventos y persistencia en Firestore.

## 🏗️ **ARQUITECTURA Y ESTRUCTURA**

### **Estructura de Directorios:**
```
lib/
├── main.dart
├── firebase_options.dart
├── app/
│   └── app.dart
├── shared/
│   ├── utils/
│   │   ├── constants.dart
│   │   └── date_formatter.dart
│   └── widgets/
│       └── fixed_table/
│           └── fixed_table.dart
└── features/
    └── calendar/
        ├── domain/
        │   ├── models/
        │   │   ├── plan.dart
        │   │   └── event.dart
        │   └── services/
        │       ├── plan_service.dart
        │       ├── event_service.dart
        │       └── date_service.dart
        └── presentation/
            ├── pages/
            │   ├── home_page.dart
            │   ├── create_plan_page.dart
            │   └── calendar_page.dart
            └── widgets/
                ├── date_selector.dart
                ├── event_dialog.dart
                └── event_cell.dart
```

## 🔧 **CONFIGURACIÓN INICIAL**

### **1. Dependencias (pubspec.yaml):**
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  cloud_firestore: ^4.13.6
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

### **2. Configuración Firebase (firebase_options.dart):**
```dart
import 'package:firebase_core/firebase_core.dart';

const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyDZRoRTxbsiaN-IXGII3ZjcgTUa-ETR-48",
  authDomain: "planazoo.firebaseapp.com",
  projectId: "planazoo",
  storageBucket: "planazoo.appspot.com",
  messagingSenderId: "794752310537",
  appId: "1:794752310537:web:b41738317fbb8238a687d8",
  measurementId: "G-F1JP3LCC35"
);
```

### **3. Inicialización Firebase (main.dart):**
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const App());
}
```

## 📊 **MODELOS DE DATOS**

### **1. Modelo Plan (plan.dart):**
```dart
class Plan {
  final String? id;
  final String name;
  final String unpId;
  final DateTime baseDate;
  final int columnCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime savedAt;
  
  // Constructor, fromFirestore, toFirestore, copyWith, toString, ==, hashCode
}
```

### **2. Modelo Event (event.dart):**
```dart
class Event {
  final String? id;
  final String planId;
  final DateTime date;
  final int hour;
  final int duration; // Duración en horas (1-8)
  final String description;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Constructor, fromFirestore, toFirestore, copyWith, toString, ==, hashCode
}
```

## 🗄️ **SERVICIOS DE BASE DE DATOS**

### **1. PlanService (plan_service.dart):**
- `getPlans()`: Stream de todos los planes
- `getPlanById(String id)`: Obtener plan por ID
- `getPlanByUnpId(String unpId)`: Obtener plan por UNP ID
- `createPlan(Plan plan)`: Crear nuevo plan
- `updatePlan(Plan plan)`: Actualizar plan existente
- `deletePlan(String id)`: Eliminar plan
- `savePlan(Plan plan)`: Guardar (crear o actualizar)
- `savePlanByUnpId(Plan plan)`: Guardar por UNP ID (sobrescribir si existe)

### **2. EventService (event_service.dart):**
- `getEventsByPlanId(String planId)`: Stream de eventos de un plan
- `getEventsByPlanIdAndDate(String planId, DateTime date)`: Eventos por fecha
- `getEventById(String eventId)`: Obtener evento por ID
- `createEvent(Event event)`: Crear nuevo evento
- `updateEvent(Event event)`: Actualizar evento
- `deleteEvent(String eventId)`: Eliminar evento
- `saveEvent(Event event)`: Guardar evento
- `deleteEventsByPlanId(String planId)`: Eliminar todos los eventos de un plan

## 🎨 **INTERFAZ DE USUARIO**

### **1. Páginas Principales:**

#### **HomePage (home_page.dart):**
- Lista todos los planazoos guardados
- StreamBuilder para actualización en tiempo real
- FloatingActionButton para crear nuevo plan
- Navegación a CalendarPage al hacer clic en un plan

#### **CreatePlanPage (create_plan_page.dart):**
- Formulario para crear nuevo plan
- Campos: Nombre del Plan, UNP ID
- Validación con TextFormField
- Navegación automática a CalendarPage tras crear

#### **CalendarPage (calendar_page.dart):**
- Tabla de calendario principal
- Gestión de columnas (días) y fecha base
- Integración con eventos
- Navegación de vuelta a HomePage

### **2. Widgets Especializados:**

#### **FixedTable (fixed_table.dart):**
- Tabla con primera columna y fila fijas
- Scroll sincronizado horizontal y vertical
- Soporte para mouse drag
- Builders personalizables para celdas, headers y columna fija

#### **EventCell (event_cell.dart):**
- Celda interactiva para eventos
- Clic para crear/editar evento
- Long press para eliminar evento
- Visualización de descripción y duración
- Colores de fondo según color del evento

#### **EventDialog (event_dialog.dart):**
- Diálogo para crear/editar eventos
- Campos: Descripción, Duración (1-8 horas), Color
- Validación automática
- Guardado en Firestore

#### **DateSelector (date_selector.dart):**
- Selector de fecha en AppBar
- Integración con showDatePicker
- Actualización automática de headers de tabla

## ⚙️ **CONSTANTES Y UTILIDADES**

### **1. AppConstants (constants.dart):**
```dart
class AppConstants {
  static const int defaultRowCount = 24; // Horas (0-23)
  static const int defaultColumnCount = 1; // Días mínimo
  static const double cellWidth = 120.0;
  static const double cellHeight = 60.0;
}
```

### **2. DateFormatter (date_formatter.dart):**
- `formatDate(DateTime date)`: "DD/MM/YYYY"
- `formatDateShort(DateTime date)`: "DD/MM"
- `formatTime(int hour)`: "HH:00"
- `formatDateTime(DateTime dateTime)`: "DD/MM/YYYY HH:MM:SS"
- `formatSavedAt(DateTime dateTime)`: "Guardado: DD/MM/YYYY HH:MM"

### **3. DateService (date_service.dart):**
- `getDateForColumn(DateTime baseDate, int column)`: Calcula fecha para columna
- Lógica para fechas consecutivas basadas en fecha base

## 🔄 **FLUJO DE DATOS**

### **1. Creación de Plan:**
1. Usuario crea plan en CreatePlanPage
2. PlanService.savePlan() → Firestore
3. Navegación automática a CalendarPage
4. CalendarPage carga eventos del plan

### **2. Gestión de Eventos:**
1. Usuario hace clic en celda → EventDialog
2. Usuario define descripción, duración, color
3. EventService.saveEvent() → Firestore
4. Stream actualiza UI automáticamente
5. Evento aparece en múltiples celdas según duración

### **3. Mapeo de Eventos:**
```dart
Event? _getEventForCell(int row, int col) {
  final date = DateService.getDateForColumn(selectedDate, col);
  final hour = row;
  
  return _events.where((event) {
    final sameDate = event.date.year == date.date.year &&
                    event.date.month == date.date.month &&
                    event.date.day == date.date.day;
    
    if (!sameDate) return false;
    
    final eventStartHour = event.hour;
    final eventEndHour = event.hour + event.duration - 1;
    
    return hour >= eventStartHour && hour <= eventEndHour;
  }).firstOrNull;
}
```

## 🎯 **FUNCIONALIDADES PRINCIPALES**

### **1. Gestión de Planazos:**
- ✅ Crear planazoo con nombre y UNP ID
- ✅ Listar todos los planazoos
- ✅ Abrir planazoo existente
- ✅ Navegación entre páginas

### **2. Calendario Interactivo:**
- ✅ Tabla 24xN (horas × días)
- ✅ Primera columna fija (horas)
- ✅ Primera fila fija (fechas)
- ✅ Scroll sincronizado
- ✅ Añadir/eliminar columnas (días)
- ✅ Cambiar fecha base

### **3. Sistema de Eventos:**
- ✅ Crear eventos con descripción
- ✅ Duración configurable (1-8 horas)
- ✅ Colores personalizables (7 opciones)
- ✅ Editar eventos existentes
- ✅ Eliminar eventos
- ✅ Visualización en múltiples celdas
- ✅ Persistencia en Firestore

### **4. Interacciones:**
- ✅ Clic en celda vacía → Crear evento
- ✅ Clic en celda con evento → Editar evento
- ✅ Long press en celda con evento → Eliminar evento
- ✅ Mouse drag para scroll
- ✅ Validación de formularios

## 🔥 **CONFIGURACIÓN FIRESTORE**

### **1. Colecciones:**
- **`plans`**: Planazoos
- **`events`**: Eventos de los planazoos

### **2. Índices Requeridos:**
```javascript
// Índice compuesto para events
Collection: events
Fields:
- planId (Ascending)
- date (Ascending)
- hour (Ascending)
```

### **3. Reglas de Seguridad (opcional):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /plans/{document} {
      allow read, write: if true;
    }
    match /events/{document} {
      allow read, write: if true;
    }
  }
}
```

## 🚀 **COMANDOS DE DESPLIEGUE**

### **1. Desarrollo:**
```bash
flutter pub get
flutter run -d chrome
```

### **2. Build Web:**
```bash
flutter build web
```

### **3. Dependencias:**
```bash
flutter pub add firebase_core cloud_firestore
flutter pub add --dev flutter_lints
```

## 🐛 **SOLUCIÓN DE PROBLEMAS**

### **1. Error de Índice Firestore:**
- Crear índice compuesto en Firebase Console
- Enlace directo proporcionado en error
- Tiempo de creación: 1-5 minutos

### **2. Errores de TextField en Web:**
- Actualizar Flutter a versión estable
- Usar TextFormField en lugar de TextField
- Verificar compatibilidad del navegador

### **3. Problemas de Scroll:**
- Verificar sincronización de ScrollControllers
- Asegurar que cada ScrollView tiene su propio controller
- Comprobar GestureDetector para mouse drag

## 📝 **NOTAS DE IMPLEMENTACIÓN**

### **1. Decisiones de Diseño:**
- Arquitectura modular con separación de concerns
- Streams para actualización en tiempo real
- Widgets reutilizables y personalizables
- Validación automática en formularios

### **2. Optimizaciones:**
- Lazy loading de eventos por plan
- Índices optimizados en Firestore
- Reutilización de widgets
- Gestión eficiente de estado

### **3. Escalabilidad:**
- Estructura preparada para múltiples usuarios
- Servicios independientes y reutilizables
- Modelos extensibles
- UI responsive y adaptable

---

## 🎉 **ESTADO ACTUAL**
✅ **FUNCIONALIDAD COMPLETA**
- Sistema de planazoos operativo
- Calendario interactivo funcional
- Eventos con duración implementados
- Persistencia en Firestore
- UI/UX optimizada

**Última actualización:** Sistema de eventos con duración implementado y funcional. 