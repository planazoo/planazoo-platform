import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/accommodation.dart';
import '../../domain/services/accommodation_service.dart';

// Provider para el servicio de alojamientos
final accommodationServiceProvider = Provider<AccommodationService>((ref) {
  return AccommodationService();
});

// Provider para los parámetros del estado de alojamientos
class AccommodationNotifierParams {
  final String planId;
  
  const AccommodationNotifierParams({
    required this.planId,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccommodationNotifierParams && other.planId == planId;
  }
  
  @override
  int get hashCode => planId.hashCode;
}

// Estado de los alojamientos
class AccommodationState {
  final List<Accommodation> accommodations;
  final bool isLoading;
  final String? error;
  final bool hasUnsavedChanges;
  
  const AccommodationState({
    this.accommodations = const [],
    this.isLoading = false,
    this.error,
    this.hasUnsavedChanges = false,
  });
  
  AccommodationState copyWith({
    List<Accommodation>? accommodations,
    bool? isLoading,
    String? error,
    bool? hasUnsavedChanges,
  }) {
    return AccommodationState(
      accommodations: accommodations ?? this.accommodations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

// Notifier para gestionar el estado de los alojamientos
class AccommodationNotifier extends StateNotifier<AccommodationState> {
  final AccommodationService _accommodationService;
  final String _planId;
  
  AccommodationNotifier(this._accommodationService, this._planId)
      : super(const AccommodationState()) {
    _loadAccommodations();
  }
  
  /// Cargar alojamientos desde Firestore
  Future<void> _loadAccommodations() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await for (final accommodations in _accommodationService.getAccommodations(_planId)) {
        state = state.copyWith(
          accommodations: accommodations,
          isLoading: false,
          hasUnsavedChanges: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar alojamientos: $e',
      );
    }
  }
  
  /// Crear o actualizar un alojamiento
  Future<bool> saveAccommodation(Accommodation accommodation) async {
    try {
      final success = await _accommodationService.saveAccommodation(accommodation);
      if (success) {
        // Recargar alojamientos para obtener el estado actualizado
        await _loadAccommodations();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: 'Error al guardar alojamiento: $e');
      return false;
    }
  }
  
  /// Eliminar un alojamiento
  Future<bool> deleteAccommodation(String accommodationId) async {
    try {
      final success = await _accommodationService.deleteAccommodation(accommodationId);
      if (success) {
        // Recargar alojamientos para obtener el estado actualizado
        await _loadAccommodations();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: 'Error al eliminar alojamiento: $e');
      return false;
    }
  }
  
  /// Mover un alojamiento a nuevas fechas
  Future<bool> moveAccommodation(Accommodation accommodation, DateTime newCheckIn, DateTime newCheckOut) async {
    try {
      final success = await _accommodationService.moveAccommodation(accommodation, newCheckIn, newCheckOut);
      if (success) {
        // Recargar alojamientos para obtener el estado actualizado
        await _loadAccommodations();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: 'Error al mover alojamiento: $e');
      return false;
    }
  }
  
  /// Limpiar errores
  void clearError() {
    state = state.copyWith(error: null);
  }
  
  /// Recargar alojamientos manualmente
  Future<void> refresh() async {
    await _loadAccommodations();
  }
}

// Provider para el notifier de alojamientos
final accommodationNotifierProvider = StateNotifierProvider.family<AccommodationNotifier, AccommodationState, AccommodationNotifierParams>((ref, params) {
  final accommodationService = ref.watch(accommodationServiceProvider);
  return AccommodationNotifier(accommodationService, params.planId);
});

// Provider para obtener el estado de alojamientos
final accommodationStateProvider = Provider.family<AccommodationState, AccommodationNotifierParams>((ref, params) {
  return ref.watch(accommodationNotifierProvider(params));
});

// Provider para obtener la lista de alojamientos
final accommodationsProvider = Provider.family<List<Accommodation>, AccommodationNotifierParams>((ref, params) {
  final state = ref.watch(accommodationStateProvider(params));
  return state.accommodations;
});

// Provider para obtener alojamientos por fecha
final accommodationsByDateProvider = Provider.family<Map<DateTime, List<Accommodation>>, AccommodationNotifierParams>((ref, params) {
  final accommodations = ref.watch(accommodationsProvider(params));
  
  final Map<DateTime, List<Accommodation>> accommodationsByDate = {};
  
  for (final accommodation in accommodations) {
    // Crear entradas para cada día del rango de alojamiento
    final startDate = DateTime(accommodation.checkIn.year, accommodation.checkIn.month, accommodation.checkIn.day);
    final endDate = DateTime(accommodation.checkOut.year, accommodation.checkOut.month, accommodation.checkOut.day);
    
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final normalizedDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
      accommodationsByDate.putIfAbsent(normalizedDate, () => []).add(accommodation);
      currentDate = currentDate.add(const Duration(days: 1));
    }
  }
  
  return accommodationsByDate;
});
