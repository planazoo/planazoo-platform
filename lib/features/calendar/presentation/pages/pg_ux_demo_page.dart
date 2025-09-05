import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_service.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';

import 'package:unp_calendario/features/calendar/presentation/widgets/grid/wd_grid_painter.dart';
import 'package:unp_calendario/features/calendar/presentation/widgets/screens/wd_plan_data_screen.dart';
import 'package:unp_calendario/features/calendar/presentation/widgets/screens/wd_calendar_screen.dart';
import 'package:unp_calendario/features/calendar/presentation/widgets/plan/plan_list_widget.dart';
import 'package:unp_calendario/features/calendar/presentation/widgets/plan/wd_plan_search_widget.dart';
import 'package:unp_calendario/features/calendar/presentation/pages/pg_create_plan_page.dart';
import 'package:unp_calendario/pages/ios_preview_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Estado para el planazoo seleccionado
  String? selectedPlanId;
  Plan? selectedPlan;
  List<Plan> planazoos = [];
  List<Plan> filteredPlanazoos = [];
  bool isLoading = true;
  
  // NUEVO: Estado de navegación para W31
  String currentScreen = 'calendar'; // 'calendar', 'planData', 'participants', etc.
  
  // NUEVO: Estado para trackear qué widget de W14-W25 está seleccionado
  String? selectedWidgetId; // 'W14', 'W15', 'W16', etc.
  
  // Servicio de planes
  final PlanService _planService = PlanService();

  @override
  void initState() {
    super.initState();
    _loadPlanazoos();
  }

  Future<void> _loadPlanazoos() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      // Cargar planazoos desde Firestore usando Stream
      _planService.getPlans().listen((plans) {
        if (mounted) {
          setState(() {
            planazoos = plans;
            filteredPlanazoos = List.from(plans);
            isLoading = false;
          });
        }
      }, onError: (error) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          LoggerService.error('Error loading planazoos', context: 'MAIN_PAGE', error: error);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error al cargar planazoos: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        LoggerService.error('Error in _loadPlanazoos', context: 'MAIN_PAGE', error: e);
      }
    }
  }

  void _showCreatePlanDialog() {
    // Navegar a la página dedicada de creación de planes
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreatePlanPage(),
      ),
    );
  }

  void _filterPlanazoos(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPlanazoos = List.from(planazoos);
      } else {
        filteredPlanazoos = planazoos.where((planazoo) {
          final name = planazoo.name.toLowerCase();
          final id = planazoo.id?.toLowerCase() ?? '';
          final unpId = planazoo.unpId.toLowerCase();
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) || 
                 id.contains(searchQuery) || 
                 unpId.contains(searchQuery);
        }).toList();
      }
    });
  }



  // NUEVO: Método para cambiar la pantalla mostrada en W31
  void _changeScreen(String screen) {
    setState(() {
      currentScreen = screen;
    });
  }
  
  // NUEVO: Método para seleccionar widgets de W14-W25
  void _selectWidget(String widgetId) {
    setState(() {
      selectedWidgetId = widgetId;
    });
  }

  void _selectPlanazoo(String planId) {
    setState(() {
      selectedPlanId = planId;
      // Buscar el plan completo en la lista
      try {
        selectedPlan = planazoos.firstWhere((p) => p.id == planId);
      } catch (e) {
        selectedPlan = null;
      }
      // NUEVO: Activar calendario por defecto al seleccionar plan
      currentScreen = 'calendar';
    });
  }
  
  Future<void> _deletePlanazoo(String planId) async {
    try {
      // Mostrar confirmación
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Estás seguro de que quieres eliminar este planazoo? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        // Eliminar de Firebase
        final success = await _planService.deletePlan(planId);
        
        if (success) {
          // Si el plan eliminado estaba seleccionado, limpiar la selección
          if (selectedPlanId == planId) {
            setState(() {
              selectedPlanId = null;
              selectedPlan = null;
            });
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Planazoo eliminado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('No se pudo eliminar el plan');
        }
      }
    } catch (e) {
      LoggerService.error('Error deleting planazoo', context: 'MAIN_PAGE', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al eliminar planazoo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildGrid(),
    );
  }



  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gridWidth = constraints.maxWidth;
        final gridHeight = constraints.maxHeight;
        final columnWidth = gridWidth / 17;
        final rowHeight = gridHeight / 13;
        
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColorScheme.color0,
          child: Stack(
            children: [
              // Grid de fondo
              CustomPaint(
                painter: GridPainter(),
              ),
              // W1: Barra lateral (C1, R1-R13)
              _buildW1(columnWidth, rowHeight, gridHeight),
              // W2: Logo de la app (C2-C3, R1)
              _buildW2(columnWidth, rowHeight),
              // W3: Botón nuevo planazoo (C4, R1)
              _buildW3(columnWidth, rowHeight),
              // W4: Menú de opciones (C5, R1)
              _buildW4(columnWidth, rowHeight),
              // W5: Icono planazoo seleccionado (C6, R1)
              _buildW5(columnWidth, rowHeight),
              // W6: Información del planazoo seleccionado (C7-C11, R1)
              _buildW6(columnWidth, rowHeight),
              // W7: Info (C12, R1)
              _buildW7(columnWidth, rowHeight),
              // W8: Presupuesto (C13, R1)
              _buildW8(columnWidth, rowHeight),
              // W9: Contador participantes (C14, R1)
              _buildW9(columnWidth, rowHeight),
              // W10: Mi estado en el planazoo (C15, R1)
              _buildW10(columnWidth, rowHeight),
              // W11: Libre (C16, R1)
              _buildW11(columnWidth, rowHeight),
              // W12: Menu opciones (C17, R1)
              _buildW12(columnWidth, rowHeight),
              // W13: Campo de búsqueda (C2-C5, R2)
              _buildW13(columnWidth, rowHeight),
              // W14: Acceso info planazoo (C6, R2)
              _buildW14(columnWidth, rowHeight),
              // W15: Acceso calendario (C7, R2)
              _buildW15(columnWidth, rowHeight),
              // W16: Por definir (C8, R2)
              _buildW16(columnWidth, rowHeight),
              // W17: Por definir (C9, R2)
              _buildW17(columnWidth, rowHeight),
              // W18: Por definir (C10, R2)
              _buildW18(columnWidth, rowHeight),
              // W19: Por definir (C11, R2)
              _buildW19(columnWidth, rowHeight),
              // W20: Por definir (C12, R2)
              _buildW20(columnWidth, rowHeight),
              // W21: Por definir (C13, R2)
              _buildW21(columnWidth, rowHeight),
              // W22: Por definir (C14, R2)
              _buildW22(columnWidth, rowHeight),
              // W23: Por definir (C15, R2)
              _buildW23(columnWidth, rowHeight),
              // W24: Icono notificaciones (C16, R2)
              _buildW24(columnWidth, rowHeight),
              // W25: Icono mensajes (C17, R2)
              _buildW25(columnWidth, rowHeight),
              // W26: Filtros fijos (C2-C5, R3)
              _buildW26(columnWidth, rowHeight),
              // W27: Espacio extra (C2-C5, R4)
              _buildW27(columnWidth, rowHeight),
              // W28: Lista de planazoos (C2-C5, R5-R12)
              _buildW28(columnWidth, rowHeight),
              // W29: Por definir (C2-C5, R13)
              _buildW29(columnWidth, rowHeight),
              // W30: Por definir (C6-C17, R13)
              _buildW30(columnWidth, rowHeight),
              // W31: Pantalla principal (C6-C17, R3-R12)
              _buildW31(columnWidth, rowHeight),
            ],
          ),
        );
      },
    );
  }

  Widget _buildW1(double columnWidth, double rowHeight, double gridHeight) {
    // W1: C1 (R1-R13) - Barra lateral izquierda
    final w1X = 0.0; // Empieza en la columna C1 (índice 0)
    final w1Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w1Width = columnWidth; // Ancho de 1 columna
    final w1Height = gridHeight; // Alto de todas las filas (R1-R13)
    
    return Positioned(
      left: w1X,
      top: w1Y,
      child: Container(
        width: w1Width,
        height: w1Height,
        decoration: BoxDecoration(
          color: AppColorScheme.color2.withValues(alpha: 0.7),
          border: Border.all(color: AppColorScheme.color2, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W1',
                style: AppTypography.mediumTitle.copyWith(
                  color: AppColorScheme.color4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'C1 (R1-R13)',
                style: AppTypography.smallBody.copyWith(
                  color: AppColorScheme.color4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Barra lateral',
                style: AppTypography.caption.copyWith(
                  color: AppColorScheme.color4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW2(double columnWidth, double rowHeight) {
    // W2: C2-C3 (R1) - Logo de la app
    final w2X = columnWidth; // Empieza en la columna C2 (índice 1)
    final w2Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w2Width = columnWidth * 2; // Ancho de 2 columnas (C2-C3)
    final w2Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w2X,
      top: w2Y,
      child: Container(
        width: w2Width,
        height: w2Height,
        decoration: BoxDecoration(
          color: AppColorScheme.color1.withValues(alpha: 0.7),
          border: Border.all(color: AppColorScheme.color2, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W2',
                style: AppTypography.mediumTitle.copyWith(
                  color: AppColorScheme.color4,
                ),
              ),
              Text(
                'C2-C3 (R1)',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColorScheme.color4,
                ),
              ),
              Text(
                'Logo app',
                style: AppTypography.caption.copyWith(
                  color: AppColorScheme.color4,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW3(double columnWidth, double rowHeight) {
    // W3: C4 (R1) - Botón nuevo planazoo
    final w3X = columnWidth * 3; // Empieza en la columna C4 (índice 3)
    final w3Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w3Width = columnWidth; // Ancho de 1 columna (C4)
    final w3Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w3X,
      top: w3Y,
      child: Container(
        width: w3Width,
        height: w3Height,
        decoration: BoxDecoration(
          color: AppColorScheme.color3.withValues(alpha: 0.2),
          border: Border.all(color: AppColorScheme.color3, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ElevatedButton.icon(
            onPressed: () => _showCreatePlanDialog(),
            icon: Icon(
              Icons.add,
              color: AppColorScheme.color0,
              size: 20,
            ),
            label: Text(
              'Nuevo',
              style: AppTypography.interactiveStyle.copyWith(
                color: AppColorScheme.color0,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorScheme.color3,
              foregroundColor: AppColorScheme.color0,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW4(double columnWidth, double rowHeight) {
    // W4: C5 (R1) - Menú de opciones
    final w4X = columnWidth * 4; // Empieza en la columna C5 (índice 4)
    final w4Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w4Width = columnWidth; // Ancho de 1 columna (C5)
    final w4Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w4X,
      top: w4Y,
      child: Container(
        width: w4Width,
        height: w4Height,
        decoration: BoxDecoration(
          color: Colors.purple.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.purple.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const IOSPreviewPage(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.phone_iphone,
                  color: Colors.purple.shade800,
                  size: 20,
                ),
                tooltip: 'iOS Preview',
              ),
              Text(
                'iOS',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.purple.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW5(double columnWidth, double rowHeight) {
    // W5: C6 (R1) - Icono planazoo seleccionado
    final w5X = columnWidth * 5; // Empieza en la columna C6 (índice 5)
    final w5Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w5Width = columnWidth; // Ancho de 1 columna (C6)
    final w5Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w5X,
      top: w5Y,
      child: Container(
        width: w5Width,
        height: w5Height,
        decoration: BoxDecoration(
          color: Colors.pink.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.pink.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W5',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink.shade800,
                ),
              ),
              Text(
                'C6 (R1)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.pink.shade700,
                ),
              ),
              Text(
                'Icono plan',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.pink.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW6(double columnWidth, double rowHeight) {
    // W6: C7-C11 (R1) - Información del planazoo seleccionado
    final w6X = columnWidth * 6; // Empieza en la columna C7 (índice 6)
    final w6Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w6Width = columnWidth * 5; // Ancho de 5 columnas (C7-C11)
    final w6Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w6X,
      top: w6Y,
      child: Container(
        width: w6Width,
        height: w6Height,
        decoration: BoxDecoration(
          color: Colors.cyan.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.cyan.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W6',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan.shade800,
                ),
              ),
              Text(
                'C7-C11 (R1)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.cyan.shade700,
                ),
              ),
              Text(
                'Info planazoo',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.cyan.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW7(double columnWidth, double rowHeight) {
    // W7: C12 (R1) - Info
    final w7X = columnWidth * 11; // Empieza en la columna C12 (índice 11)
    final w7Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w7Width = columnWidth; // Ancho de 1 columna (C12)
    final w7Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w7X,
      top: w7Y,
      child: Container(
        width: w7Width,
        height: w7Height,
        decoration: BoxDecoration(
          color: Colors.lime.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.lime.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W7',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.lime.shade800,
                ),
              ),
              Text(
                'C12 (R1)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.lime.shade700,
                ),
              ),
              Text(
                'Info',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.lime.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW8(double columnWidth, double rowHeight) {
    // W8: C13 (R1) - Presupuesto
    final w8X = columnWidth * 12; // Empieza en la columna C13 (índice 12)
    final w8Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w8Width = columnWidth; // Ancho de 1 columna (C13)
    final w8Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w8X,
      top: w8Y,
      child: Container(
        width: w8Width,
        height: w8Height,
        decoration: BoxDecoration(
          color: Colors.deepOrange.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.deepOrange.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W8',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange.shade800,
                ),
              ),
              Text(
                'C13 (R1)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.deepOrange.shade700,
                ),
              ),
              Text(
                'Presupuesto',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.deepOrange.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW9(double columnWidth, double rowHeight) {
    // W9: C14 (R1) - Contador participantes
    final w9X = columnWidth * 13; // Empieza en la columna C14 (índice 13)
    final w9Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w9Width = columnWidth; // Ancho de 1 columna (C14)
    final w9Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w9X,
      top: w9Y,
      child: Container(
        width: w9Width,
        height: w9Height,
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.deepPurple.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W9',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade800,
                ),
              ),
              Text(
                'C14 (R1)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.deepPurple.shade700,
                ),
              ),
              Text(
                'Participantes',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.deepPurple.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW10(double columnWidth, double rowHeight) {
    // W10: C15 (R1) - Mi estado en el planazoo
    final w10X = columnWidth * 14; // Empieza en la columna C15 (índice 14)
    final w10Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w10Width = columnWidth; // Ancho de 1 columna (C15)
    final w10Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w10X,
      top: w10Y,
      child: Container(
        width: w10Width,
        height: w10Height,
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.blueGrey.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W10',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade800,
                ),
              ),
              Text(
                'C15 (R1)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blueGrey.shade700,
                ),
              ),
              Text(
                'Mi estado',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.blueGrey.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW11(double columnWidth, double rowHeight) {
    // W11: C16 (R1) - Libre
    final w11X = columnWidth * 15; // Empieza en la columna C16 (índice 15)
    final w11Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w11Width = columnWidth; // Ancho de 1 columna (C16)
    final w11Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w11X,
      top: w11Y,
      child: Container(
        width: w11Width,
        height: w11Height,
        decoration: BoxDecoration(
          color: Colors.lightGreen.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.lightGreen.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W11',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightGreen.shade800,
                ),
              ),
              Text(
                'C16 (R1)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.lightGreen.shade700,
                ),
              ),
              Text(
                'Libre',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.lightGreen.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW12(double columnWidth, double rowHeight) {
    // W12: C17 (R1) - Menu opciones
    final w12X = columnWidth * 16; // Empieza en la columna C17 (índice 16)
    final w12Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w12Width = columnWidth; // Ancho de 1 columna (C17)
    final w12Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w12X,
      top: w12Y,
      child: Container(
        width: w12Width,
        height: w12Height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.grey.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W12',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Text(
                'C17 (R1)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                'Menu opc',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW14(double columnWidth, double rowHeight) {
    // W14: C6 (R2) - Acceso info planazoo
    final w14X = columnWidth * 5; // Empieza en la columna C6 (índice 5)
    final w14Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w14Width = columnWidth; // Ancho de 1 columna (C6)
    final w14Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W14';
    final backgroundColor = isSelected ? AppColorScheme.color1 : AppColorScheme.color0;
    final textColor = isSelected ? AppColorScheme.color2 : AppColorScheme.color1;
    
    return Positioned(
      left: w14X,
      top: w14Y,
      child: Container(
        width: w14Width,
        height: w14Height,
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.7),
          border: Border.all(color: AppColorScheme.color2, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: InkWell(
          onTap: () {
            _selectWidget('W14');
            _changeScreen('planData');
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'W14',
                  style: AppTypography.mediumTitle.copyWith(
                    color: textColor,
                  ),
                ),
                Text(
                  'C6 (R2)',
                  style: AppTypography.smallBody.copyWith(
                    color: textColor,
                  ),
                ),
                Text(
                  'Info plan',
                  style: AppTypography.caption.copyWith(
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW15(double columnWidth, double rowHeight) {
    // W15: C7 (R2) - Acceso calendario
    final w15X = columnWidth * 6; // Empieza en la columna C7 (índice 6)
    final w15Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w15Width = columnWidth; // Ancho de 1 columna (C7)
    final w15Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W15';
    final backgroundColor = isSelected ? AppColorScheme.color1 : AppColorScheme.color0;
    final textColor = isSelected ? AppColorScheme.color2 : AppColorScheme.color1;
    
    return Positioned(
      left: w15X,
      top: w15Y,
      child: Container(
        width: w15Width,
        height: w15Height,
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.7),
          border: Border.all(color: AppColorScheme.color2, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: InkWell(
          onTap: () {
            _selectWidget('W15');
            _changeScreen('calendar');
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'W15',
                  style: AppTypography.mediumTitle.copyWith(
                    color: textColor,
                  ),
                ),
                Text(
                  'C7 (R2)',
                  style: AppTypography.smallBody.copyWith(
                    color: textColor,
                  ),
                ),
                Text(
                  'Calendario',
                  style: AppTypography.caption.copyWith(
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW16(double columnWidth, double rowHeight) {
    // W16: C8 (R2) - Por definir
    final w16X = columnWidth * 7; // Empieza en la columna C8 (índice 7)
    final w16Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w16Width = columnWidth; // Ancho de 1 columna (C8)
    final w16Height = rowHeight; // Alto de 1 fila (R2)
    
    return Positioned(
      left: w16X,
      top: w16Y,
      child: Container(
        width: w16Width,
        height: w16Height,
        decoration: BoxDecoration(
          color: Colors.yellow.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.yellow.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W16',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow.shade800,
                ),
              ),
              Text(
                'C8 (R2)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.yellow.shade700,
                ),
              ),
              Text(
                'Por definir',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.yellow.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW17(double columnWidth, double rowHeight) {
    // W17: C9 (R2) - Por definir
    final w17X = columnWidth * 8; // Empieza en la columna C9 (índice 8)
    final w17Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w17Width = columnWidth; // Ancho de 1 columna (C9)
    final w17Height = rowHeight; // Alto de 1 fila (R2)
    
    return Positioned(
      left: w17X,
      top: w17Y,
      child: Container(
        width: w17Width,
        height: w17Height,
        decoration: BoxDecoration(
          color: Colors.orange.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.orange.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W17',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
              Text(
                'C9 (R2)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.orange.shade700,
                ),
              ),
              Text(
                'Por definir',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.orange.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW18(double columnWidth, double rowHeight) {
    // W18: C10 (R2) - Por definir
    final w18X = columnWidth * 9; // Empieza en la columna C10 (índice 9)
    final w18Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w18Width = columnWidth; // Ancho de 1 columna (C10)
    final w18Height = rowHeight; // Alto de 1 fila (R2)
    
    return Positioned(
      left: w18X,
      top: w18Y,
      child: Container(
        width: w18Width,
        height: w18Height,
        decoration: BoxDecoration(
          color: Colors.red.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.red.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W18',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
              Text(
                'C10 (R2)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red.shade700,
                ),
              ),
              Text(
                'Por definir',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.red.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW19(double columnWidth, double rowHeight) {
    // W19: C11 (R2) - Por definir
    final w19X = columnWidth * 10; // Empieza en la columna C11 (índice 10)
    final w19Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w19Width = columnWidth; // Ancho de 1 columna (C11)
    final w19Height = rowHeight; // Alto de 1 fila (R2)
    
    return Positioned(
      left: w19X,
      top: w19Y,
      child: Container(
        width: w19Width,
        height: w19Height,
        decoration: BoxDecoration(
          color: Colors.purple.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.purple.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W19',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade800,
                ),
              ),
              Text(
                'C11 (R2)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.purple.shade700,
                ),
              ),
              Text(
                'Por definir',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.purple.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW20(double columnWidth, double rowHeight) {
    // W20: C12 (R2) - Por definir
    final w20X = columnWidth * 11; // Empieza en la columna C12 (índice 11)
    final w20Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w20Width = columnWidth; // Ancho de 1 columna (C12)
    final w20Height = rowHeight; // Alto de 1 fila (R2)
    
    return Positioned(
      left: w20X,
      top: w20Y,
      child: Container(
        width: w20Width,
        height: w20Height,
        decoration: BoxDecoration(
          color: Colors.indigo.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.indigo.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W20',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade800,
                ),
              ),
              Text(
                'C12 (R2)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.indigo.shade700,
                ),
              ),
              Text(
                'Por definir',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.indigo.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW21(double columnWidth, double rowHeight) {
    // W21: C13 (R2) - Por definir
    final w21X = columnWidth * 12; // Empieza en la columna C13 (índice 12)
    final w21Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w21Width = columnWidth; // Ancho de 1 columna (C13)
    final w21Height = rowHeight; // Alto de 1 fila (R2)
    
    return Positioned(
      left: w21X,
      top: w21Y,
      child: Container(
        width: w21Width,
        height: w21Height,
        decoration: BoxDecoration(
          color: Colors.teal.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.teal.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W21',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
              ),
              Text(
                'C13 (R2)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.teal.shade700,
                ),
              ),
              Text(
                'Por definir',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.teal.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW22(double columnWidth, double rowHeight) {
    // W22: C14 (R2) - Por definir
    final w22X = columnWidth * 13; // Empieza en la columna C14 (índice 13)
    final w22Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w22Width = columnWidth; // Ancho de 1 columna (C14)
    final w22Height = rowHeight; // Alto de 1 fila (R2)
    
    return Positioned(
      left: w22X,
      top: w22Y,
      child: Container(
        width: w22Width,
        height: w22Height,
        decoration: BoxDecoration(
          color: Colors.cyan.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.cyan.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W22',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan.shade800,
                ),
              ),
              Text(
                'C14 (R2)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.cyan.shade700,
                ),
              ),
              Text(
                'Por definir',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.cyan.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW23(double columnWidth, double rowHeight) {
    // W23: C15 (R2) - Por definir
    final w23X = columnWidth * 14; // Empieza en la columna C15 (índice 14)
    final w23Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w23Width = columnWidth; // Ancho de 1 columna (C15)
    final w23Height = rowHeight; // Alto de 1 fila (R2)
    
    return Positioned(
      left: w23X,
      top: w23Y,
      child: Container(
        width: w23Width,
        height: w23Height,
        decoration: BoxDecoration(
          color: Colors.amber.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.amber.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W23',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
              Text(
                'C15 (R2)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.amber.shade700,
                ),
              ),
              Text(
                'Por definir',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.amber.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW24(double columnWidth, double rowHeight) {
    // W24: C16 (R2) - Icono notificaciones
    final w24X = columnWidth * 15; // Empieza en la columna C16 (índice 15)
    final w24Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w24Width = columnWidth; // Ancho de 1 columna (C16)
    final w24Height = rowHeight; // Alto de 1 fila (R2)
    
    return Positioned(
      left: w24X,
      top: w24Y,
      child: Container(
        width: w24Width,
        height: w24Height,
        decoration: BoxDecoration(
          color: Colors.deepOrange.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.deepOrange.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W24',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange.shade800,
                ),
              ),
              Text(
                'C16 (R2)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.deepOrange.shade600,
                ),
              ),
              Text(
                'Notific',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.deepOrange.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW25(double columnWidth, double rowHeight) {
    // W25: C17 (R2) - Icono mensajes
    final w25X = columnWidth * 16; // Empieza en la columna C17 (índice 16)
    final w25Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w25Width = columnWidth; // Ancho de 1 columna (C17)
    final w25Height = rowHeight; // Alto de 1 fila (R2)
    
    return Positioned(
      left: w25X,
      top: w25Y,
      child: Container(
        width: w25Width,
        height: w25Height,
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.deepPurple.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W25',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade800,
                ),
              ),
              Text(
                'C17 (R2)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.deepPurple.shade700,
                ),
              ),
              Text(
                'Mensajes',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.deepPurple.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW13(double columnWidth, double rowHeight) {
    // W13: C2-C5 (R2) - Campo de búsqueda
    final w13X = columnWidth; // Empieza en la columna C2 (índice 1)
    final w13Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w13Width = columnWidth * 4; // Ancho de 4 columnas (C2-C5)
    final w13Height = rowHeight; // Alto de 1 fila (R2)
    
    return Positioned(
      left: w13X,
      top: w13Y,
      child: Container(
        width: w13Width,
        height: w13Height,
        decoration: BoxDecoration(
          color: Colors.teal.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.teal.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: PlanSearchWidget(onSearchChanged: _filterPlanazoos),
      ),
    );
  }

  Widget _buildW26(double columnWidth, double rowHeight) {
    // W26: C2-C5 (R3) - Filtros fijos de la lista de planazoos
    final w26X = columnWidth; // Empieza en la columna C2 (índice 1)
    final w26Y = rowHeight * 2; // Empieza en la fila R3 (índice 2)
    final w26Width = columnWidth * 4; // Ancho de 4 columnas (C2-C5)
    final w26Height = rowHeight; // Alto de 1 fila (R3)
    
    return Positioned(
      left: w26X,
      top: w26Y,
      child: Container(
        width: w26Width,
        height: w26Height,
        decoration: BoxDecoration(
          color: Colors.indigo.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.indigo.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W26',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade800,
                ),
              ),
              Text(
                'C2-C5 (R3)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.indigo.shade700,
                ),
              ),
              Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.indigo.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW27(double columnWidth, double rowHeight) {
    // W27: C2-C5 (R4) - Espacio extra no definido
    final w27X = columnWidth; // Empieza en la columna C2 (índice 1)
    final w27Y = rowHeight * 3; // Empieza en la fila R4 (índice 3)
    final w27Width = columnWidth * 4; // Ancho de 4 columnas (C2-C5)
    final w27Height = rowHeight; // Alto de 1 fila (R4)
    
    return Positioned(
      left: w27X,
      top: w27Y,
      child: Container(
        width: w27Width,
        height: w27Height,
        decoration: BoxDecoration(
          color: Colors.amber.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.amber.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W27',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
              Text(
                'C2-C5 (R4)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.amber.shade700,
                ),
              ),
              Text(
                'Espacio',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.amber.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW28(double columnWidth, double rowHeight) {
    // W28: C2-C5 (R5-R12) - Lista de planazoos con imagen, información e iconos
    final w28X = columnWidth; // Empieza en la columna C2 (índice 1)
    final w28Y = rowHeight * 4; // Empieza en la fila R5 (índice 4)
    final w28Width = columnWidth * 4; // Ancho de 4 columnas (C2-C5)
    final w28Height = rowHeight * 8; // Alto de 8 filas (R5-R12)
    
    return Positioned(
      left: w28X,
      top: w28Y,
      child: Container(
        width: w28Width,
        height: w28Height,
        decoration: BoxDecoration(
          color: AppColorScheme.color1.withValues(alpha: 0.7),
          border: Border.all(color: AppColorScheme.color2, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: PlanListWidget(
          plans: filteredPlanazoos,
          selectedPlanId: selectedPlanId,
          isLoading: isLoading,
          onPlanSelected: _selectPlanazoo,
          onPlanDeleted: _deletePlanazoo,
        ),
      ),
    );
  }

  Widget _buildW30(double columnWidth, double rowHeight) {
    // W30: C6-C17 (R13) - Por definir
    final w30X = columnWidth * 5; // Empieza en la columna C6 (índice 5)
    final w30Y = rowHeight * 12; // Empieza en la fila R13 (índice 12)
    final w30Width = columnWidth * 12; // Ancho de 12 columnas (C6-C17)
    final w30Height = rowHeight; // Alto de 1 fila (R13)
    
    return Positioned(
      left: w30X,
      top: w30Y,
      child: Container(
        width: w30Width,
        height: w30Height,
        decoration: BoxDecoration(
          color: Colors.lightGreen.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.lightGreen.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W30',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightGreen.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'C6-C17 (R13)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.lightGreen.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Por definir',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.lightGreen.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

    Widget _buildW31(double columnWidth, double rowHeight) {
    // W31: C6-C17 (R3-R12) - Pantalla principal con navegación
    final w31X = columnWidth * 5;
    final w31Y = rowHeight * 2;
    final w31Width = columnWidth * 12;
    final w31Height = rowHeight * 10;
    
    return Positioned(
      left: w31X,
      top: w31Y,
      child: Container(
        width: w31Width,
        height: w31Height,
        decoration: BoxDecoration(
          color: AppColorScheme.color0.withValues(alpha: 0.7),
          border: Border.all(color: AppColorScheme.color2, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: selectedPlanId == null
          ? _buildNoPlanSelected()
          : _buildScreenContent(),
      ),
    );
  }

  // NUEVO: Método para mostrar contenido según la pantalla seleccionada
  Widget _buildScreenContent() {
    switch (currentScreen) {
      case 'planData':
        return _buildPlanDataScreen();
      case 'calendar':
      default:
        return _buildCalendarWidget();
    }
  }

  // NUEVO: Pantalla de datos principales del plan
  Widget _buildPlanDataScreen() {
    if (selectedPlan == null) return const SizedBox.shrink();
    return PlanDataScreen(plan: selectedPlan!);
  }

  // NUEVO: Método para mostrar mensaje cuando no hay plan seleccionado
  Widget _buildNoPlanSelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: AppColorScheme.color2,
          ),
          const SizedBox(height: 16),
          Text(
            'Selecciona un Planazoo',
            style: AppTypography.titleStyle.copyWith(
              color: AppColorScheme.color4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Haz clic en un planazoo de la lista\nderecha para ver su calendario',
            style: AppTypography.bodyStyle.copyWith(
              color: AppColorScheme.color4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }



  // Nuevo método para mostrar el calendario
  Widget _buildCalendarWidget() {
    if (selectedPlan == null) return const SizedBox.shrink();
    return CalendarScreen(plan: selectedPlan!);
  }



  Widget _buildW29(double columnWidth, double rowHeight) {
    // W29: C2-C5 (R13) - Por definir
    final w29X = columnWidth; // Empieza en la columna C2 (índice 1)
    final w29Y = rowHeight * 12; // Empieza en la fila R13 (índice 12)
    final w29Width = columnWidth * 4; // Ancho de 4 columnas (C2-C5)
    final w29Height = rowHeight; // Alto de 1 fila (R13)
    
    return Positioned(
      left: w29X,
      top: w29Y,
      child: Container(
        width: w29Width,
        height: w29Height,
        decoration: BoxDecoration(
          color: Colors.brown.shade200.withValues(alpha: 0.7),
          border: Border.all(color: Colors.brown.shade600, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'W29',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade800,
                ),
              ),
              Text(
                'C2-C5 (R13)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.brown.shade700,
                ),
              ),
              Text(
                'Por definir',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.brown.shade600,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

