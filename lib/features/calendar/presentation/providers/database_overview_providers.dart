import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/plan.dart';
import '../../domain/models/event.dart';
import '../../domain/models/accommodation.dart';
import '../../domain/services/plan_service.dart';
import '../../domain/services/event_service.dart';
import '../../domain/services/accommodation_service.dart';

/// Provider para PlanService
final planServiceProvider = Provider<PlanService>((ref) {
  return PlanService();
});

/// Provider para EventService
final eventServiceProvider = Provider<EventService>((ref) {
  return EventService();
});

/// Provider para AccommodationService
final accommodationServiceProvider = Provider<AccommodationService>((ref) {
  return AccommodationService();
});

/// Provider para obtener todos los planes
final allPlansProvider = StreamProvider<List<Plan>>((ref) {
  final planService = ref.read(planServiceProvider);
  return planService.getPlans();
});

/// Provider para obtener todos los eventos de todos los planes
final allEventsProvider = FutureProvider<List<Event>>((ref) async {
  final eventService = ref.read(eventServiceProvider);
  final plans = await ref.read(allPlansProvider.future);
  
  final allEvents = <Event>[];
  
  for (final plan in plans) {
    if (plan.id != null) {
      try {
        // Obtener eventos de este plan (usar userId vacío para obtener todos los eventos)
        final events = await eventService.getEventsByPlanId(plan.id!, '').first;
        allEvents.addAll(events);
      } catch (e) {
        // Continuar con el siguiente plan si hay error
        print('Error obteniendo eventos del plan ${plan.id}: $e');
        continue;
      }
    }
  }
  
  return allEvents;
});

/// Provider para obtener todos los alojamientos de todos los planes
final allAccommodationsProvider = FutureProvider<List<Accommodation>>((ref) async {
  final accommodationService = ref.read(accommodationServiceProvider);
  final plans = await ref.read(allPlansProvider.future);
  
  final allAccommodations = <Accommodation>[];
  
  for (final plan in plans) {
    if (plan.id != null) {
      try {
        // Obtener alojamientos de este plan
        final accommodations = await accommodationService.getAccommodations(plan.id!).first;
        allAccommodations.addAll(accommodations);
      } catch (e) {
        // Continuar con el siguiente plan si hay error
        print('Error obteniendo alojamientos del plan ${plan.id}: $e');
        continue;
      }
    }
  }
  
  return allAccommodations;
});

/// Provider para estadísticas de la base de datos
final databaseStatsProvider = Provider<DatabaseStats>((ref) {
  final plansAsync = ref.watch(allPlansProvider);
  final eventsAsync = ref.watch(allEventsProvider);
  final accommodationsAsync = ref.watch(allAccommodationsProvider);
  
  return DatabaseStats(
    totalPlans: plansAsync.when(
      data: (plans) => plans.length,
      loading: () => 0,
      error: (_, __) => 0,
    ),
    totalEvents: eventsAsync.when(
      data: (events) => events.length,
      loading: () => 0,
      error: (_, __) => 0,
    ),
    totalAccommodations: accommodationsAsync.when(
      data: (accommodations) => accommodations.length,
      loading: () => 0,
      error: (_, __) => 0,
    ),
    isLoading: plansAsync.isLoading || eventsAsync.isLoading || accommodationsAsync.isLoading,
    hasError: plansAsync.hasError || eventsAsync.hasError || accommodationsAsync.hasError,
  );
});

/// Estadísticas de la base de datos
class DatabaseStats {
  final int totalPlans;
  final int totalEvents;
  final int totalAccommodations;
  final bool isLoading;
  final bool hasError;
  
  const DatabaseStats({
    required this.totalPlans,
    required this.totalEvents,
    required this.totalAccommodations,
    required this.isLoading,
    required this.hasError,
  });
}

/// Provider para filtrar eventos por fecha
final filteredEventsProvider = Provider.family<List<Event>, DateTime?>((ref, date) {
  final eventsAsync = ref.watch(allEventsProvider);
  
  return eventsAsync.when(
    data: (events) {
      if (date == null) return events;
      
      return events.where((event) {
        final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
        final filterDate = DateTime(date.year, date.month, date.day);
        return eventDate.isAtSameMomentAs(filterDate);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider para filtrar alojamientos por fecha
final filteredAccommodationsProvider = Provider.family<List<Accommodation>, DateTime?>((ref, date) {
  final accommodationsAsync = ref.watch(allAccommodationsProvider);
  
  return accommodationsAsync.when(
    data: (accommodations) {
      if (date == null) return accommodations;
      
      return accommodations.where((accommodation) {
        final checkInDate = DateTime(accommodation.checkIn.year, accommodation.checkIn.month, accommodation.checkIn.day);
        final checkOutDate = DateTime(accommodation.checkOut.year, accommodation.checkOut.month, accommodation.checkOut.day);
        final filterDate = DateTime(date.year, date.month, date.day);
        
        return filterDate.isAfter(checkInDate.subtract(const Duration(days: 1))) &&
               filterDate.isBefore(checkOutDate.add(const Duration(days: 1)));
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider para búsqueda en toda la base de datos
final searchResultsProvider = Provider.family<SearchResults, String>((ref, query) {
  if (query.isEmpty) {
    return const SearchResults(
      plans: [],
      events: [],
      accommodations: [],
    );
  }
  
  final plansAsync = ref.watch(allPlansProvider);
  final eventsAsync = ref.watch(allEventsProvider);
  final accommodationsAsync = ref.watch(allAccommodationsProvider);
  
  return SearchResults(
    plans: plansAsync.when(
      data: (plans) => plans.where((plan) =>
        plan.name.toLowerCase().contains(query.toLowerCase()) ||
        plan.unpId.toLowerCase().contains(query.toLowerCase())
      ).toList(),
      loading: () => [],
      error: (_, __) => [],
    ),
    events: eventsAsync.when(
      data: (events) => events.where((event) =>
        event.description.toLowerCase().contains(query.toLowerCase())
      ).toList(),
      loading: () => [],
      error: (_, __) => [],
    ),
    accommodations: accommodationsAsync.when(
      data: (accommodations) => accommodations.where((accommodation) =>
        accommodation.hotelName.toLowerCase().contains(query.toLowerCase())
      ).toList(),
      loading: () => [],
      error: (_, __) => [],
    ),
  );
});

/// Resultados de búsqueda
class SearchResults {
  final List<Plan> plans;
  final List<Event> events;
  final List<Accommodation> accommodations;
  
  const SearchResults({
    required this.plans,
    required this.events,
    required this.accommodations,
  });
  
  int get totalResults => plans.length + events.length + accommodations.length;
}
