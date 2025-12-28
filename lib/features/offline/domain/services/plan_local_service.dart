import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../features/calendar/domain/models/plan.dart';
import 'local_storage_service.dart';
import 'hive_service.dart';

/// Servicio para almacenar Planes localmente (solo móviles)
class PlanLocalService extends LocalStorageService<Plan> {
  PlanLocalService() : super(HiveService.boxNamePlans);

  @override
  Map<String, dynamic> toMap(Plan plan) {
    // Usamos toFirestore() pero convertimos Timestamps a ISO strings para Hive
    final firestoreMap = plan.toFirestore();
    final hiveMap = <String, dynamic>{};
    
    for (var entry in firestoreMap.entries) {
      if (entry.value is Timestamp) {
        hiveMap[entry.key] = (entry.value as Timestamp).toDate().toIso8601String();
      } else {
        hiveMap[entry.key] = entry.value;
      }
    }
    
    // Añadimos el ID si existe
    if (plan.id != null) {
      hiveMap['_id'] = plan.id;
    }
    
    return hiveMap;
  }

  @override
  Plan fromMap(Map<String, dynamic> map) {
    // Convertimos ISO strings a DateTime directamente
    final baseDate = map['baseDate'] is String 
        ? DateTime.parse(map['baseDate'] as String)
        : (map['baseDate'] as Timestamp).toDate();
    
    final columnCount = map['columnCount'] ?? 1;
    final startDate = baseDate;
    final endDate = baseDate.add(Duration(days: columnCount - 1));
    
    return Plan(
      id: map['_id'] as String?,
      name: map['name'] ?? '',
      unpId: map['unpId'] ?? '',
      userId: map['userId'] ?? '',
      baseDate: baseDate,
      startDate: startDate,
      endDate: endDate,
      columnCount: columnCount,
      accommodation: map['accommodation'] as String?,
      description: map['description'] as String?,
      budget: map['budget']?.toDouble(),
      participants: map['participants'] as int?,
      imageUrl: map['imageUrl'] as String?,
      state: map['state'] ?? 'borrador',
      visibility: map['visibility'] ?? 'private',
      timezone: map['timezone'] as String?,
      currency: map['currency'] ?? 'EUR',
      createdAt: map['createdAt'] is String 
          ? DateTime.parse(map['createdAt'] as String)
          : (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] is String 
          ? DateTime.parse(map['updatedAt'] as String)
          : (map['updatedAt'] as Timestamp).toDate(),
      savedAt: map['savedAt'] is String 
          ? DateTime.parse(map['savedAt'] as String)
          : (map['savedAt'] as Timestamp).toDate(),
    );
  }

  /// Obtiene todos los planes de un usuario
  Future<List<Plan>> getPlansByUserId(String userId) async {
    if (!isMobile) return [];
    
    final allPlans = await getAll();
    return allPlans.where((plan) => plan.userId == userId).toList();
  }

  /// Obtiene un plan por ID
  Future<Plan?> getPlanById(String planId) async {
    return await get(planId);
  }

  /// Guarda un plan (usa el ID como key)
  Future<void> savePlan(Plan plan) async {
    if (plan.id == null) {
      throw ArgumentError('Plan debe tener un ID para guardarse localmente');
    }
    await save(plan.id!, plan);
  }

  /// Elimina un plan
  Future<void> deletePlan(String planId) async {
    await delete(planId);
  }

}

