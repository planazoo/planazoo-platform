import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../features/calendar/domain/models/plan_participation.dart';
import 'local_storage_service.dart';
import 'hive_service.dart';

/// Servicio para almacenar PlanParticipations localmente (solo móviles)
class ParticipationLocalService extends LocalStorageService<PlanParticipation> {
  ParticipationLocalService() : super(HiveService.boxNameParticipations);

  @override
  Map<String, dynamic> toMap(PlanParticipation participation) {
    // Usamos toFirestore() pero convertimos Timestamps a ISO strings para Hive
    final firestoreMap = participation.toFirestore();
    
    // Función recursiva para convertir Timestamps a strings ISO
    dynamic _convertTimestamp(dynamic value) {
      if (value is Timestamp) {
        return value.toDate().toIso8601String();
      } else if (value is Map) {
        return value.map((key, val) => MapEntry(key, _convertTimestamp(val)));
      } else if (value is List) {
        return value.map((item) => _convertTimestamp(item)).toList();
      } else {
        return value;
      }
    }
    
    final hiveMap = <String, dynamic>{};
    for (var entry in firestoreMap.entries) {
      hiveMap[entry.key] = _convertTimestamp(entry.value);
    }
    
    // Añadimos el ID si existe
    if (participation.id != null) {
      hiveMap['_id'] = participation.id;
    }
    
    return hiveMap;
  }

  @override
  PlanParticipation fromMap(Map<String, dynamic> map) {
    // Helper para convertir fechas
    DateTime _parseDate(dynamic value) {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is Timestamp) {
        return value.toDate();
      }
      throw ArgumentError('Invalid date format: $value');
    }

    final data = map;
    
    return PlanParticipation(
      id: map['_id'] as String?,
      planId: data['planId'] ?? '',
      userId: data['userId'] ?? '',
      role: data['role'] ?? 'participant',
      personalTimezone: data['personalTimezone'],
      joinedAt: _parseDate(data['joinedAt']),
      isActive: data['isActive'] ?? true,
      invitedBy: data['invitedBy'],
      lastActiveAt: data['lastActiveAt'] != null 
          ? _parseDate(data['lastActiveAt']) 
          : null,
      status: data['status'],
      adminCreatedBy: data['_adminCreatedBy'],
    );
  }

  /// Obtiene todas las participaciones de un plan
  Future<List<PlanParticipation>> getParticipationsByPlanId(String planId) async {
    if (!isMobile) return [];
    
    final allParticipations = await getAll();
    return allParticipations.where((p) => p.planId == planId).toList();
  }

  /// Obtiene todas las participaciones de un usuario
  Future<List<PlanParticipation>> getParticipationsByUserId(String userId) async {
    if (!isMobile) return [];
    
    final allParticipations = await getAll();
    return allParticipations.where((p) => p.userId == userId).toList();
  }

  /// Obtiene una participación específica (plan + usuario)
  Future<PlanParticipation?> getParticipation(String planId, String userId) async {
    if (!isMobile) return null;
    
    final participations = await getParticipationsByPlanId(planId);
    try {
      return participations.firstWhere((p) => p.userId == userId);
    } catch (e) {
      return null;
    }
  }

  /// Guarda una participación (usa planId_userId como key)
  Future<void> saveParticipation(PlanParticipation participation) async {
    if (participation.id == null) {
      throw ArgumentError('PlanParticipation debe tener un ID para guardarse localmente');
    }
    await save(participation.id!, participation);
  }

  /// Elimina una participación
  Future<void> deleteParticipation(String participationId) async {
    await delete(participationId);
  }

  /// Elimina todas las participaciones de un plan
  Future<void> deleteParticipationsByPlanId(String planId) async {
    if (!isMobile) return;
    
    final participations = await getParticipationsByPlanId(planId);
    for (var participation in participations) {
      if (participation.id != null) {
        await delete(participation.id!);
      }
    }
  }

}

