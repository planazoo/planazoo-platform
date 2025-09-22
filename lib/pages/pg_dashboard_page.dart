import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_service.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';
import 'package:unp_calendario/features/auth/domain/services/user_service.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_participation_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/image_service.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

import 'package:unp_calendario/widgets/grid/wd_grid_painter.dart';
import 'package:unp_calendario/widgets/screens/wd_plan_data_screen.dart';
import 'package:unp_calendario/widgets/screens/wd_calendar_screen.dart';
import 'package:unp_calendario/widgets/plan/plan_list_widget.dart';
import 'package:unp_calendario/widgets/plan/wd_plan_search_widget.dart';
import 'package:unp_calendario/pages/pg_create_plan_page.dart';
import 'package:unp_calendario/pages/pg_profile_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  // Estado para el planazoo seleccionado
  String? selectedPlanId;
  Plan? selectedPlan;
  List<Plan> planazoos = [];
  List<Plan> filteredPlanazoos = [];
  bool isLoading = true;
  
  // NUEVO: Estado de navegación para W31
  String currentScreen = 'calendar'; // 'calendar', 'planData', 'participants', 'profile', etc.
  
  // NUEVO: Estado para trackear qué widget de W14-W25 está seleccionado
  String? selectedWidgetId; // 'W14', 'W15', 'W16', etc.
  String selectedFilter = 'todos'; // 'todos', 'estoy_in', 'pendientes', 'cerrados'
  
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
            
            // NUEVO: Seleccionar automáticamente el primer plan si no hay ninguno seleccionado
            if (selectedPlan == null && plans.isNotEmpty) {
              selectedPlanId = plans.first.id;
              selectedPlan = plans.first;
            }
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _CreatePlanModal(
          onPlanCreated: (plan) {
            // Actualizar la lista de planes (el modal ya se cierra automáticamente)
            setState(() {
              planazoos.add(plan);
              filteredPlanazoos = List.from(planazoos);
            });
          },
        );
      },
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
                painter: GridPainter(
                  cellWidth: columnWidth,
                  cellHeight: rowHeight,
                  daysPerWeek: 17, // Total de columnas en el dashboard
                ),
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
          color: AppColorScheme.color2, // Color de elementos interactivos de la app
          // Sin borderRadius - esquinas cuadradas
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Tooltip(
              message: AppLocalizations.of(context)!.profileTooltip,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    currentScreen = 'profile';
                  });
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24), // Icono redondo
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
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
          color: Colors.white, // Fondo blanco
          border: Border.all(color: Colors.white, width: 2), // Borde blanco
        ),
        child: Center(
          child: Text(
            'planazoo',
            style: AppTypography.mediumTitle.copyWith(
              color: AppColorScheme.color1, // Color 1
              fontSize: 18,
              fontWeight: FontWeight.bold,
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
          color: Colors.white, // Fondo blanco
          border: Border.all(color: Colors.white, width: 2), // Borde blanco
        ),
        child: Center(
          child: GestureDetector(
            onTap: () => _showCreatePlanDialog(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColorScheme.color3, // Fondo del botón color3
                borderRadius: BorderRadius.circular(20), // Redondo
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '+',
                  style: TextStyle(
                    color: AppColorScheme.color1, // "+" color1
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW4(double columnWidth, double rowHeight) {
    // W4: C5 (R1) - Por definir
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
          color: Colors.white, // Fondo blanco
          border: Border.all(color: Colors.white, width: 2), // Borde blanco
        ),
        // Sin contenido por el momento
      ),
    );
  }

  Widget _buildW5(double columnWidth, double rowHeight) {
    // W5: C6 (R1) - Foto del plan seleccionado
    final w5X = columnWidth * 5; // Empieza en la columna C6 (índice 5)
    final w5Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w5Width = columnWidth + 1; // Ancho de 1 columna + 1px para cubrir la línea
    final w5Height = rowHeight; // Alto de 1 fila (R1)
    
    // Calcular el tamaño del círculo (responsive)
    final circleSize = (w5Width < w5Height ? w5Width : w5Height) * 0.8;
    
    return Positioned(
      left: w5X,
      top: w5Y,
      child: Container(
        width: w5Width,
        height: w5Height,
        decoration: BoxDecoration(
          color: AppColorScheme.color2,
          // Sin borde - mismo color que el fondo
        ),
        child: Center(
          child: Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColorScheme.color2, width: 2),
            ),
            child: ClipOval(
              child: _buildPlanImage(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanImage() {
    if (selectedPlan?.imageUrl != null && ImageService.isValidImageUrl(selectedPlan!.imageUrl)) {
      return CachedNetworkImage(
        imageUrl: selectedPlan!.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColorScheme.color2.withOpacity(0.1),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildDefaultIcon(),
      );
    } else {
      return _buildDefaultIcon();
    }
  }

  Widget _buildDefaultIcon() {
    return Container(
      color: AppColorScheme.color2.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColorScheme.color1, // Cambiado a color1 para que sea visible
          size: 28,
        ),
      ),
    );
  }

  Widget _buildW6(double columnWidth, double rowHeight) {
    // W6: C7-C11 (R1) - Información del planazoo seleccionado
    final w6X = columnWidth * 6 - 1; // Empieza en la columna C7 (índice 6) - 1px para superponerse
    final w6Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w6Width = columnWidth * 5 + 1; // Ancho de 5 columnas + 1px para cubrir la línea
    final w6Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w6X,
      top: w6Y,
      child: Container(
        width: w6Width,
        height: w6Height,
        decoration: BoxDecoration(
          color: AppColorScheme.color2, // Fondo color2
          // Sin borde - mismo color que el fondo
        ),
        child: selectedPlan != null 
          ? _buildPlanInfoContent()
          : _buildNoPlanSelectedInfo(),
      ),
    );
  }

  /// Construye el contenido de información del plan seleccionado
  Widget _buildPlanInfoContent() {
    return Padding(
      padding: const EdgeInsets.all(4.0), // Reducido de 8.0 a 4.0
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Añadido para evitar overflow
        children: [
          // Nombre del plan (primera línea) - Más grande
          Text(
            selectedPlan!.name,
            style: TextStyle(
              fontSize: 14, // Aumentado de 12 a 14
              fontWeight: FontWeight.bold,
              color: AppColorScheme.color1, // Texto color1
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Fechas de inicio y fin (segunda línea, fuente más pequeña)
          Text(
            '${_formatDate(selectedPlan!.startDate)} - ${_formatDate(selectedPlan!.endDate)}',
            style: TextStyle(
              fontSize: 9,
              color: AppColorScheme.color1, // Texto color1
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          // Email del administrador del plan
          Text(
            'Admin: ${_getAdminEmail()}',
            style: TextStyle(
              fontSize: 7,
              color: AppColorScheme.color1.withOpacity(0.8), // Texto color1 con opacidad
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Construye el contenido cuando no hay plan seleccionado
  Widget _buildNoPlanSelectedInfo() {
    return Center(
      child: Text(
        'Selecciona un plan',
        style: TextStyle(
          fontSize: 10, // Reducido de 12 a 10
          color: AppColorScheme.color1.withOpacity(0.6), // Texto color1 con opacidad
        ),
      ),
    );
  }

  /// Formatea una fecha para mostrar
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Obtiene el email del administrador del plan
  String _getAdminEmail() {
    final currentUser = ref.read(currentUserProvider);
    return currentUser?.email ?? 'N/A';
  }

  Widget _buildW7(double columnWidth, double rowHeight) {
    // W7: C12 (R1) - Fondo color2, vacío
    final w7X = columnWidth * 11 - 1; // Empieza en la columna C12 (índice 11) - 1px para superponerse
    final w7Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w7Width = columnWidth + 1; // Ancho de 1 columna + 1px para cubrir la línea
    final w7Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w7X,
      top: w7Y,
      child: Container(
        width: w7Width,
        height: w7Height,
        decoration: BoxDecoration(
          color: AppColorScheme.color2, // Fondo color2
          // Sin borde
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW8(double columnWidth, double rowHeight) {
    // W8: C13 (R1) - Fondo color2, vacío
    final w8X = columnWidth * 12 - 1; // Empieza en la columna C13 (índice 12) - 1px para superponerse
    final w8Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w8Width = columnWidth + 1; // Ancho de 1 columna + 1px para cubrir la línea
    final w8Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w8X,
      top: w8Y,
      child: Container(
        width: w8Width,
        height: w8Height,
        decoration: BoxDecoration(
          color: AppColorScheme.color2, // Fondo color2
          // Sin borde
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW9(double columnWidth, double rowHeight) {
    // W9: C14 (R1) - Fondo color2, vacío
    final w9X = columnWidth * 13 - 1; // Empieza en la columna C14 (índice 13) - 1px para superponerse
    final w9Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w9Width = columnWidth + 1; // Ancho de 1 columna + 1px para cubrir la línea
    final w9Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w9X,
      top: w9Y,
      child: Container(
        width: w9Width,
        height: w9Height,
        decoration: BoxDecoration(
          color: AppColorScheme.color2, // Fondo color2
          // Sin borde
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW10(double columnWidth, double rowHeight) {
    // W10: C15 (R1) - Fondo color2, vacío
    final w10X = columnWidth * 14 - 1; // Empieza en la columna C15 (índice 14) - 1px para superponerse
    final w10Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w10Width = columnWidth + 1; // Ancho de 1 columna + 1px para cubrir la línea
    final w10Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w10X,
      top: w10Y,
      child: Container(
        width: w10Width,
        height: w10Height,
        decoration: BoxDecoration(
          color: AppColorScheme.color2, // Fondo color2
          // Sin borde
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW11(double columnWidth, double rowHeight) {
    // W11: C16 (R1) - Fondo color2, vacío
    final w11X = columnWidth * 15 - 1; // Empieza en la columna C16 (índice 15) - 1px para superponerse
    final w11Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w11Width = columnWidth + 1; // Ancho de 1 columna + 1px para cubrir la línea
    final w11Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w11X,
      top: w11Y,
      child: Container(
        width: w11Width,
        height: w11Height,
        decoration: BoxDecoration(
          color: AppColorScheme.color2, // Fondo color2
          // Sin borde
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW12(double columnWidth, double rowHeight) {
    // W12: C17 (R1) - Fondo color2, vacío
    final w12X = columnWidth * 16 - 1; // Empieza en la columna C17 (índice 16) - 1px para superponerse
    final w12Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w12Width = columnWidth + 1; // Ancho de 1 columna + 1px para cubrir la línea
    final w12Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w12X,
      top: w12Y,
      child: Container(
        width: w12Width,
        height: w12Height,
        decoration: BoxDecoration(
          color: AppColorScheme.color2, // Fondo color2
          // Sin borde
        ),
        // Sin contenido
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
    final iconColor = AppColorScheme.color2;
    final textColor = isSelected ? AppColorScheme.color2 : AppColorScheme.color1;
    
    return Positioned(
      left: w14X,
      top: w14Y,
      child: Container(
        width: w14Width,
        height: w14Height,
        decoration: BoxDecoration(
          color: backgroundColor,
          // Sin borde
          // Sin borderRadius (esquinas en ángulo recto)
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
                // Icono "i" color2
                Icon(
                  Icons.info,
                  color: iconColor,
                  size: 20,
                ),
                const SizedBox(height: 4),
                // Texto "planazoo" debajo del icono
                Text(
                  'planazoo',
                  style: AppTypography.caption.copyWith(
                    color: textColor,
                    fontSize: 6,
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
    final iconColor = AppColorScheme.color2;
    final textColor = isSelected ? AppColorScheme.color2 : AppColorScheme.color1;
    
    return Positioned(
      left: w15X,
      top: w15Y,
      child: Container(
        width: w15Width,
        height: w15Height,
        decoration: BoxDecoration(
          color: backgroundColor,
          // Sin borde
          // Sin borderRadius (esquinas en ángulo recto)
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
                // Icono calendario color2
                Icon(
                  Icons.calendar_today,
                  color: iconColor,
                  size: 20,
                ),
                const SizedBox(height: 4),
                // Texto "calendario" debajo del icono
                Text(
                  'calendario',
                  style: AppTypography.caption.copyWith(
                    color: textColor,
                    fontSize: 6,
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
    // W16: C8 (R2) - Participante del plan
    final w16X = columnWidth * 7; // Empieza en la columna C8 (índice 7)
    final w16Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w16Width = columnWidth; // Ancho de 1 columna (C8)
    final w16Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W16';
    final backgroundColor = isSelected ? AppColorScheme.color1 : AppColorScheme.color0;
    final iconColor = AppColorScheme.color2;
    final textColor = isSelected ? AppColorScheme.color2 : AppColorScheme.color1;
    
    return Positioned(
      left: w16X,
      top: w16Y,
      child: Container(
        width: w16Width,
        height: w16Height,
        decoration: BoxDecoration(
          color: backgroundColor,
          // Sin borde
          // Sin borderRadius (esquinas en ángulo recto)
        ),
        child: InkWell(
          onTap: () {
            _selectWidget('W16');
            _changeScreen('participants');
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono "formas de personas" color2
                Icon(
                  Icons.group,
                  color: iconColor,
                  size: 20,
                ),
                const SizedBox(height: 4),
                // Texto "in" debajo del icono
                Text(
                  'in',
                  style: AppTypography.caption.copyWith(
                    color: textColor,
                    fontSize: 6,
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
    // W17: C9 (R2) - Widget básico
    final w17X = columnWidth * 8; // Empieza en la columna C9 (índice 8)
    final w17Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w17Width = columnWidth; // Ancho de 1 columna (C9)
    final w17Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W17';
    final backgroundColor = isSelected ? AppColorScheme.color1 : AppColorScheme.color0;
    
    return Positioned(
      left: w17X,
      top: w17Y,
      child: Container(
        width: w17Width,
        height: w17Height,
        decoration: BoxDecoration(
          color: backgroundColor,
          // Sin borde
          // Sin borderRadius (esquinas en ángulo recto)
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW18(double columnWidth, double rowHeight) {
    // W18: C10 (R2) - Widget básico
    final w18X = columnWidth * 9; // Empieza en la columna C10 (índice 9)
    final w18Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w18Width = columnWidth; // Ancho de 1 columna (C10)
    final w18Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W18';
    final backgroundColor = isSelected ? AppColorScheme.color1 : AppColorScheme.color0;
    
    return Positioned(
      left: w18X,
      top: w18Y,
      child: Container(
        width: w18Width,
        height: w18Height,
        decoration: BoxDecoration(
          color: backgroundColor,
          // Sin borde
          // Sin borderRadius (esquinas en ángulo recto)
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW19(double columnWidth, double rowHeight) {
    // W19: C11 (R2) - Widget básico
    final w19X = columnWidth * 10; // Empieza en la columna C11 (índice 10)
    final w19Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w19Width = columnWidth; // Ancho de 1 columna (C11)
    final w19Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W19';
    final backgroundColor = isSelected ? AppColorScheme.color1 : AppColorScheme.color0;
    
    return Positioned(
      left: w19X,
      top: w19Y,
      child: Container(
        width: w19Width,
        height: w19Height,
        decoration: BoxDecoration(
          color: backgroundColor,
          // Sin borde
          // Sin borderRadius (esquinas en ángulo recto)
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW20(double columnWidth, double rowHeight) {
    // W20: C12 (R2) - Widget básico
    final w20X = columnWidth * 11; // Empieza en la columna C12 (índice 11)
    final w20Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w20Width = columnWidth; // Ancho de 1 columna (C12)
    final w20Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W20';
    final backgroundColor = isSelected ? AppColorScheme.color1 : AppColorScheme.color0;
    
    return Positioned(
      left: w20X,
      top: w20Y,
      child: Container(
        width: w20Width,
        height: w20Height,
        decoration: BoxDecoration(
          color: backgroundColor,
          // Sin borde
          // Sin borderRadius (esquinas en ángulo recto)
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW21(double columnWidth, double rowHeight) {
    // W21: C13 (R2) - Widget básico
    final w21X = columnWidth * 12; // Empieza en la columna C13 (índice 12)
    final w21Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w21Width = columnWidth; // Ancho de 1 columna (C13)
    final w21Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W21';
    final backgroundColor = isSelected ? AppColorScheme.color1 : AppColorScheme.color0;
    
    return Positioned(
      left: w21X,
      top: w21Y,
      child: Container(
        width: w21Width,
        height: w21Height,
        decoration: BoxDecoration(
          color: backgroundColor,
          // Sin borde
          // Sin borderRadius (esquinas en ángulo recto)
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW22(double columnWidth, double rowHeight) {
    // W22: C14 (R2) - Widget básico
    final w22X = columnWidth * 13; // Empieza en la columna C14 (índice 13)
    final w22Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w22Width = columnWidth; // Ancho de 1 columna (C14)
    final w22Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W22';
    final backgroundColor = isSelected ? AppColorScheme.color1 : AppColorScheme.color0;
    
    return Positioned(
      left: w22X,
      top: w22Y,
      child: Container(
        width: w22Width,
        height: w22Height,
        decoration: BoxDecoration(
          color: backgroundColor,
          // Sin borde
          // Sin borderRadius (esquinas en ángulo recto)
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW23(double columnWidth, double rowHeight) {
    // W23: C15 (R2) - Widget básico
    final w23X = columnWidth * 14; // Empieza en la columna C15 (índice 14)
    final w23Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w23Width = columnWidth; // Ancho de 1 columna (C15)
    final w23Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W23';
    final backgroundColor = isSelected ? AppColorScheme.color1 : AppColorScheme.color0;
    
    return Positioned(
      left: w23X,
      top: w23Y,
      child: Container(
        width: w23Width,
        height: w23Height,
        decoration: BoxDecoration(
          color: backgroundColor,
          // Sin borde
          // Sin borderRadius (esquinas en ángulo recto)
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW24(double columnWidth, double rowHeight) {
    // W24: C16 (R2) - Widget básico
    final w24X = columnWidth * 15; // Empieza en la columna C16 (índice 15)
    final w24Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w24Width = columnWidth; // Ancho de 1 columna (C16)
    final w24Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W24';
    final backgroundColor = isSelected ? AppColorScheme.color1 : AppColorScheme.color0;
    
    return Positioned(
      left: w24X,
      top: w24Y,
      child: Container(
        width: w24Width,
        height: w24Height,
        decoration: BoxDecoration(
          color: backgroundColor,
          // Sin borde
          // Sin borderRadius (esquinas en ángulo recto)
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW25(double columnWidth, double rowHeight) {
    // W25: C17 (R2) - Widget básico
    final w25X = columnWidth * 16; // Empieza en la columna C17 (índice 16)
    final w25Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w25Width = columnWidth; // Ancho de 1 columna (C17)
    final w25Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W25';
    final backgroundColor = isSelected ? AppColorScheme.color1 : AppColorScheme.color0;
    
    return Positioned(
      left: w25X,
      top: w25Y,
      child: Container(
        width: w25Width,
        height: w25Height,
        decoration: BoxDecoration(
          color: backgroundColor,
          // Sin borde
          // Sin borderRadius (esquinas en ángulo recto)
        ),
        // Sin contenido
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
          color: AppColorScheme.color0, // Fondo color0
          // Sin borde adicional (el TextField ya tiene sus propios bordes)
          // Sin borderRadius (el TextField maneja sus propios bordes redondeados)
        ),
        padding: const EdgeInsets.all(8), // Padding para el TextField
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
          color: AppColorScheme.color0, // Fondo color0
          // Sin borde adicional
          // Sin borderRadius (esquinas en ángulo recto)
        ),
        padding: const EdgeInsets.all(4), // Padding para los botones
        child: Row(
          children: [
            _buildFilterButton('todos', 'Todos', columnWidth, rowHeight),
            const SizedBox(width: 2),
            _buildFilterButton('estoy_in', 'Estoy in', columnWidth, rowHeight),
            const SizedBox(width: 2),
            _buildFilterButton('pendientes', 'Pendientes', columnWidth, rowHeight),
            const SizedBox(width: 2),
            _buildFilterButton('cerrados', 'Cerrados', columnWidth, rowHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String filterValue, String label, double columnWidth, double rowHeight) {
    final isSelected = selectedFilter == filterValue;
    final buttonWidth = (columnWidth * 4 - 6) / 4; // Ancho total menos espacios dividido entre 4 botones
    
    return Expanded(
      child: Container(
        height: rowHeight * 0.6, // Altura menor (60% de la altura de fila)
        margin: EdgeInsets.symmetric(vertical: rowHeight * 0.2), // Centrado vertical
        decoration: BoxDecoration(
          color: isSelected ? AppColorScheme.color2 : AppColorScheme.color0, // Fondo color2 si seleccionado, color0 si no
          border: Border.all(
            color: AppColorScheme.color2, // Borde color2
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12), // Esquinas más redondeadas
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              selectedFilter = filterValue;
            });
            // De momento no hacen nada (sin funcionalidad)
          },
          borderRadius: BorderRadius.circular(12), // Esquinas más redondeadas
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: AppColorScheme.color1, // Texto color1
                fontSize: 10, // Texto más grande
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW27(double columnWidth, double rowHeight) {
    // W27: C2-C5 (R4) - Auxiliar
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
          color: AppColorScheme.color0, // Fondo color0
          // Sin borde
          // Sin borderRadius (esquinas en ángulo recto)
        ),
        // Sin contenido
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
          color: AppColorScheme.color0, // Fondo blanco
          border: Border.all(color: AppColorScheme.color0, width: 1), // Bordes blancos
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
    // W30: C6-C17 (R13) - Pie de página informaciones app
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
          color: AppColorScheme.color2, // Fondo color2
          // Sin borde
          // Sin borderRadius (esquinas en ángulo recto)
        ),
        // Sin contenido
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
        child: (selectedPlanId == null && currentScreen != 'profile' && currentScreen != 'email')
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
      case 'profile':
        return _buildProfileScreen();
      case 'email':
        return _buildEmailScreen();
      case 'participants':
        return _buildParticipantsScreen();
      case 'calendar':
      default:
        return _buildCalendarWidget();
    }
  }

  // NUEVO: Pantalla de datos principales del plan
  Widget _buildPlanDataScreen() {
    if (selectedPlan == null) return const SizedBox.shrink();
    return PlanDataScreen(
      plan: selectedPlan!,
      onPlanDeleted: () {
        // Actualizar la lista de planes después de eliminar
        setState(() {
          planazoos.removeWhere((p) => p.id == selectedPlan!.id);
          filteredPlanazoos = List.from(planazoos);
          selectedPlan = null;
          selectedPlanId = null;
          currentScreen = 'calendar'; // Volver al calendario
        });
      },
    );
  }

  // NUEVO: Pantalla de perfil
  Widget _buildProfileScreen() {
    return const ProfilePage();
  }

  // NUEVO: Pantalla de email (temporal)
  Widget _buildEmailScreen() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Label
            Container(
              width: 81,
              height: 38,
              alignment: Alignment.centerLeft,
              child: Text(
                'email',
                style: AppTypography.bodyStyle.copyWith(
                  fontSize: 16,
                  color: AppColorScheme.color4,
                ),
              ),
            ),
            
            const SizedBox(width: 24), // Espaciado entre label y campo
            
            // Campo de texto
            Container(
              width: 320,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Introduce el mail',
                  hintStyle: AppTypography.interactiveStyle.copyWith(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                style: AppTypography.interactiveStyle.copyWith(
                  fontSize: 14,
                  color: AppColorScheme.color4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    return CalendarScreen(
      key: ValueKey(selectedPlan!.id), // Forzar rebuild cuando cambie el plan
      plan: selectedPlan!,
    );
  }



  Widget _buildW29(double columnWidth, double rowHeight) {
    // W29: C2-C5 (R13) - Pie de página publicitario
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
          color: AppColorScheme.color0, // Fondo color0
          border: Border(
            top: BorderSide(
              color: AppColorScheme.color1, // Borde superior color1
              width: 1,
            ),
          ),
          // Sin borderRadius (esquinas en ángulo recto)
        ),
        // Sin contenido
      ),
    );
  }

  // NUEVO: Pantalla de participantes del plan
  Widget _buildParticipantsScreen() {
    if (selectedPlan == null) {
      return const Center(
        child: Text(
          'Selecciona un plan para ver los participantes',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Participantes del Plan: ${selectedPlan!.name}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Funcionalidad en desarrollo',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              setState(() {
                currentScreen = 'calendar';
              });
            },
            child: const Text('Volver al Calendario'),
          ),
        ],
      ),
    );
  }
}

// Modal para crear plan con tamaño específico (R1-R17, C2-C3)
class _CreatePlanModal extends ConsumerStatefulWidget {
  final Function(Plan) onPlanCreated;

  const _CreatePlanModal({
    required this.onPlanCreated,
  });

  @override
  ConsumerState<_CreatePlanModal> createState() => _CreatePlanModalState();
}

class _CreatePlanModalState extends ConsumerState<_CreatePlanModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unpIdController = TextEditingController();
  final _planService = PlanService();
  final _userService = UserService();
  bool _isCreating = false;
  
  // Variables para fechas y duración
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 6));
  int _columnCount = 7;
  
  // Variables para participantes
  List<UserModel> _allUsers = [];
  List<UserModel> _selectedParticipants = [];
  bool _isLoadingUsers = true;
  
  // Variables para imagen
  XFile? _selectedImage;
  String? _imageUrl;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _updateColumnCount();
    _loadUsers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unpIdController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _userService.getAllUsers();
      setState(() {
        _allUsers = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar usuarios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateColumnCount() {
    final difference = _endDate.difference(_startDate).inDays;
    setState(() {
      _columnCount = difference + 1;
    });
  }

  Future<void> _createPlan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final now = DateTime.now();
      final currentUser = ref.read(currentUserProvider);
      final userId = currentUser?.id ?? '';
      
      // Subir imagen si hay una seleccionada
      String? uploadedImageUrl;
      if (_selectedImage != null) {
        setState(() {
          _isUploadingImage = true;
        });
        
        // Crear un plan temporal para obtener el ID
        final tempPlan = Plan(
          name: _nameController.text.trim(),
          unpId: _unpIdController.text.trim(),
          userId: userId,
          baseDate: _startDate,
          startDate: _startDate,
          endDate: _endDate,
          columnCount: _columnCount,
          createdAt: now,
          updatedAt: now,
          savedAt: now,
        );
        
        // Guardar plan temporal para obtener ID
        final tempSuccess = await _planService.savePlanByUnpId(tempPlan);
        if (!tempSuccess) {
          throw Exception('Error al crear plan temporal');
        }
        
        // Subir imagen con el ID del plan
        uploadedImageUrl = await ImageService.uploadPlanImage(_selectedImage!, tempPlan.id!);
        
        setState(() {
          _isUploadingImage = false;
        });
      }
      
      final plan = Plan(
        name: _nameController.text.trim(),
        unpId: _unpIdController.text.trim(),
        userId: userId,
        baseDate: _startDate,
        startDate: _startDate,
        endDate: _endDate,
        columnCount: _columnCount,
        imageUrl: uploadedImageUrl,
        createdAt: now,
        updatedAt: now,
        savedAt: now,
      );

      // Guardar el plan (con o sin imagen)
      final success = await _planService.savePlanByUnpId(plan);
      if (!success) {
        throw Exception('Error al guardar el plan');
      }

      // Si había imagen, actualizar el plan con la URL de la imagen
      if (_selectedImage != null && uploadedImageUrl != null) {
        final updatedPlan = plan.copyWith(id: plan.id, imageUrl: uploadedImageUrl);
        await _planService.updatePlan(updatedPlan);
      }

      if (success) {
        // Crear participaciones para el creador y los participantes seleccionados
        final planParticipationService = PlanParticipationService();
        
        // El creador siempre participa como organizador
        await planParticipationService.createParticipation(
          planId: plan.id!,
          userId: userId,
          role: 'organizer',
        );
        
        // Añadir participantes seleccionados
        for (final participant in _selectedParticipants) {
          await planParticipationService.createParticipation(
            planId: plan.id!,
            userId: participant.id,
            role: 'participant',
            invitedBy: userId,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Plan "${plan.name}" creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          // Cerrar el modal antes de actualizar la lista
          Navigator.of(context).pop();
          widget.onPlanCreated(plan);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Error al crear el plan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 6));
        }
        _updateColumnCount();
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 365)),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        _updateColumnCount();
      });
    }
  }

  void _toggleParticipant(UserModel user) {
    setState(() {
      if (_selectedParticipants.contains(user)) {
        _selectedParticipants.remove(user);
      } else {
        _selectedParticipants.add(user);
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await ImageService.pickImageFromGallery();
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
        
        // Validar imagen
        final validationError = await ImageService.validateImage(image);
        if (validationError != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(validationError),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        
        // Mostrar previsualización
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagen seleccionada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      _selectedImage = null;
      _imageUrl = null;
    });
  }

  Widget _buildImageSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.image, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Imagen del Plan (Opcional)',
                  style: AppTypography.bodyStyle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedImage == null)
            // Botón para seleccionar imagen
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploadingImage ? null : _pickImage,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Seleccionar Imagen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorScheme.color2,
                  foregroundColor: Colors.white,
                ),
              ),
            )
          else
            // Mostrar imagen seleccionada
            Column(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_selectedImage!.path),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.error, color: Colors.red),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Imagen seleccionada',
                      style: AppTypography.bodyStyle.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _removeImage,
                      icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                      label: const Text('Quitar', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gridWidth = constraints.maxWidth;
        final gridHeight = constraints.maxHeight;
        final columnWidth = gridWidth / 17;
        final rowHeight = gridHeight / 13;
        
        // Modal cubre R1-R17 (17 filas) y C2-C4 (3 columnas)
        final modalWidth = columnWidth * 3; // C2-C4 = 3 columnas
        final modalHeight = rowHeight * 17; // R1-R17 = 17 filas
        final modalX = columnWidth; // Empieza en C2 (índice 1)
        final modalY = 0.0; // Empieza en R1 (índice 0)
        
        return Stack(
          children: [
            // Fondo semitransparente
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.5),
            ),
            // Modal
            Positioned(
              left: modalX,
              top: modalY,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: modalWidth,
                  height: modalHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColorScheme.color2,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Crear Plan',
                            style: AppTypography.mediumTitle.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    // Contenido
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Campo nombre
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nombre del Plan',
                                    hintText: 'Ej: Plan Zoo 2024',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.edit),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Por favor ingresa un nombre';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                // Campo UNP ID
                                TextFormField(
                                  controller: _unpIdController,
                                  decoration: const InputDecoration(
                                    labelText: 'UNP ID',
                                    hintText: 'Ej: UNP001',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.tag),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Por favor ingresa un UNP ID';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                // Selector de imagen
                                _buildImageSelector(),
                                const SizedBox(height: 16),
                                // Selector fecha inicio
                                InkWell(
                                  onTap: _selectStartDate,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today, color: Colors.green),
                                        const SizedBox(width: 12),
                                        Text('Inicio: ${DateFormatter.formatDate(_startDate)}'),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Selector fecha fin
                                InkWell(
                                  onTap: _selectEndDate,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.event, color: Colors.blue),
                                        const SizedBox(width: 12),
                                        Text('Fin: ${DateFormatter.formatDate(_endDate)}'),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Duración
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    border: Border.all(color: Colors.blue.shade200),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Duración:'),
                                      Text(
                                        '$_columnCount día${_columnCount > 1 ? 's' : ''}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Selector de participantes
                                Text(
                                  'Participantes:',
                                  style: AppTypography.bodyStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_isLoadingUsers)
                                  const Center(child: CircularProgressIndicator())
                                else
                                  Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: ListView.builder(
                                      itemCount: _allUsers.length,
                                      itemBuilder: (context, index) {
                                        final user = _allUsers[index];
                                        final isSelected = _selectedParticipants.contains(user);
                                        return CheckboxListTile(
                                          title: Text(user.displayName ?? user.email),
                                          subtitle: Text(user.email),
                                          value: isSelected,
                                          onChanged: (value) => _toggleParticipant(user),
                                          dense: true,
                                        );
                                      },
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                // Botón crear
                                ElevatedButton(
                                  onPressed: _isCreating ? null : _createPlan,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColorScheme.color3,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: _isCreating
                                      ? const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text('Creando...'),
                                          ],
                                        )
                                      : const Text('Crear Plan'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

