/// Modelo para items en la cola de sincronización
/// 
/// Representa una operación pendiente de sincronizar con Firestore
class SyncQueueItem {
  final String id; // ID único del item
  final String operation; // 'create', 'update', 'delete'
  final String collection; // 'plans', 'events', 'participations', etc.
  final String documentId; // ID del documento en Firestore (null si es create)
  final Map<String, dynamic> data; // Datos a sincronizar
  final DateTime createdAt; // Cuándo se añadió a la cola
  final int retryCount; // Número de intentos fallidos
  final DateTime? lastRetryAt; // Último intento de sincronización
  final String? error; // Último error (si existe)

  const SyncQueueItem({
    required this.id,
    required this.operation,
    required this.collection,
    this.documentId = '',
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
    this.lastRetryAt,
    this.error,
  });

  /// Crea un item desde un Map (para Hive)
  factory SyncQueueItem.fromMap(Map<String, dynamic> map) {
    return SyncQueueItem(
      id: map['id'] as String,
      operation: map['operation'] as String,
      collection: map['collection'] as String,
      documentId: map['documentId'] as String? ?? '',
      data: Map<String, dynamic>.from(map['data'] as Map),
      createdAt: DateTime.parse(map['createdAt'] as String),
      retryCount: map['retryCount'] as int? ?? 0,
      lastRetryAt: map['lastRetryAt'] != null 
          ? DateTime.parse(map['lastRetryAt'] as String) 
          : null,
      error: map['error'] as String?,
    );
  }

  /// Convierte a Map (para Hive)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'operation': operation,
      'collection': collection,
      'documentId': documentId,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'lastRetryAt': lastRetryAt?.toIso8601String(),
      'error': error,
    };
  }

  /// Crea una copia con cambios
  SyncQueueItem copyWith({
    String? id,
    String? operation,
    String? collection,
    String? documentId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    int? retryCount,
    DateTime? lastRetryAt,
    String? error,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      collection: collection ?? this.collection,
      documentId: documentId ?? this.documentId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastRetryAt: lastRetryAt ?? this.lastRetryAt,
      error: error ?? this.error,
    );
  }

  /// Verifica si el item puede reintentarse
  /// Máximo 5 intentos, con backoff exponencial
  bool get canRetry {
    if (retryCount >= 5) return false;
    
    // Backoff exponencial: 1min, 2min, 4min, 8min, 16min
    if (lastRetryAt == null) return true;
    
    final minutesSinceLastRetry = DateTime.now().difference(lastRetryAt!).inMinutes;
    final backoffMinutes = [1, 2, 4, 8, 16][retryCount];
    
    return minutesSinceLastRetry >= backoffMinutes;
  }

  @override
  String toString() {
    return 'SyncQueueItem(id: $id, operation: $operation, collection: $collection, retryCount: $retryCount)';
  }
}

