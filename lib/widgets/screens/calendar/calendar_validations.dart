import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/participant_track.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_constants.dart';

/// Clase que maneja las validaciones del calendario
class CalendarValidations {
  /// Valida un plan
  static ValidationResult validatePlan(Plan plan) {
    final errors = <String>[];
    final warnings = <String>[];

    // Validaciones básicas
    if (plan.name.isEmpty) {
      errors.add('El nombre del plan no puede estar vacío');
    }

    if (plan.durationInDays <= 0) {
      errors.add('La duración del plan debe ser mayor a 0');
    }

    if (plan.durationInDays > 365) {
      warnings.add('El plan tiene más de 365 días, puede ser muy largo');
    }

    if (plan.participants == null || plan.participants! <= 0) {
      errors.add('El plan debe tener al menos un participante');
    }

    if (plan.participants! > 20) {
      warnings.add('El plan tiene muchos participantes, puede ser difícil de gestionar');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida un evento
  static ValidationResult validateEvent(Event event, Plan plan) {
    final errors = <String>[];
    final warnings = <String>[];

    // Validaciones básicas
    if (event.commonPart == null) {
      errors.add('El evento debe tener información común');
      return ValidationResult(isValid: false, errors: errors, warnings: warnings);
    }

    final commonPart = event.commonPart!;

    if (commonPart.description.isEmpty) {
      errors.add('La descripción del evento no puede estar vacía');
    }

    if (commonPart.description.length > 100) {
      warnings.add('La descripción del evento es muy larga');
    }

    if (commonPart.startHour < 0 || commonPart.startHour > 23) {
      errors.add('La hora de inicio debe estar entre 0 y 23');
    }

    if (commonPart.startMinute < 0 || commonPart.startMinute > 59) {
      errors.add('Los minutos de inicio deben estar entre 0 y 59');
    }

    if (commonPart.durationMinutes <= 0) {
      errors.add('La duración del evento debe ser mayor a 0');
    }

    if (commonPart.durationMinutes > 1440) { // 24 horas
      warnings.add('El evento dura más de 24 horas');
    }

    // Validaciones de fecha
    if (commonPart.date.day < 1 || commonPart.date.day > plan.durationInDays) {
      errors.add('El día del evento debe estar dentro del rango del plan');
    }

    // Validaciones de participantes
    if (commonPart.participantIds.isEmpty) {
      errors.add('El evento debe tener al menos un participante');
    }

    if (commonPart.participantIds.length > (plan.participants ?? 1)) {
      errors.add('El evento tiene más participantes que el plan');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida un alojamiento
  static ValidationResult validateAccommodation(Accommodation accommodation, Plan plan) {
    final errors = <String>[];
    final warnings = <String>[];

    // Validaciones básicas
    if (accommodation.hotelName.isEmpty) {
      errors.add('El nombre del hotel no puede estar vacío');
    }

    if (accommodation.hotelName.length > 50) {
      warnings.add('El nombre del hotel es muy largo');
    }

    // Validaciones de fechas
    if (accommodation.checkIn.isAfter(accommodation.checkOut)) {
      errors.add('La fecha de check-in debe ser anterior al check-out');
    }

    if (accommodation.checkIn.day < 1 || accommodation.checkIn.day > plan.durationInDays) {
      errors.add('La fecha de check-in debe estar dentro del rango del plan');
    }

    if (accommodation.checkOut.day < 1 || accommodation.checkOut.day > plan.durationInDays) {
      errors.add('La fecha de check-out debe estar dentro del rango del plan');
    }

    // Validaciones de duración
    final duration = accommodation.checkOut.difference(accommodation.checkIn).inDays;
    if (duration <= 0) {
      errors.add('La duración del alojamiento debe ser mayor a 0');
    }

    if (duration > 30) {
      warnings.add('El alojamiento dura más de 30 días');
    }

    // Validaciones de participantes
    if (accommodation.participantTrackIds.isEmpty) {
      errors.add('El alojamiento debe tener al menos un participante');
    }

    if (accommodation.participantTrackIds.length > (plan.participants ?? 1)) {
      errors.add('El alojamiento tiene más participantes que el plan');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida un track de participante
  static ValidationResult validateParticipantTrack(ParticipantTrack track, Plan plan) {
    final errors = <String>[];
    final warnings = <String>[];

    // Validaciones básicas
    if (track.participantId.isEmpty) {
      errors.add('El ID del participante no puede estar vacío');
    }

    if (track.participantName.isEmpty) {
      errors.add('El nombre del participante no puede estar vacío');
    }

    if (track.participantName.length > 30) {
      warnings.add('El nombre del participante es muy largo');
    }

    // Validaciones de posición
    if (track.position < 0) {
      errors.add('La posición del track debe ser mayor o igual a 0');
    }

    if (track.position >= (plan.participants ?? 1)) {
      errors.add('La posición del track debe ser menor al número de participantes');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida la configuración de días visibles
  static ValidationResult validateVisibleDays(int visibleDays, Plan plan) {
    final errors = <String>[];
    final warnings = <String>[];

    if (visibleDays < CalendarConstants.minVisibleDays) {
      errors.add('El número de días visibles debe ser al menos ${CalendarConstants.minVisibleDays}');
    }

    if (visibleDays > CalendarConstants.maxVisibleDays) {
      errors.add('El número de días visibles no puede ser mayor a ${CalendarConstants.maxVisibleDays}');
    }

    if (visibleDays > plan.durationInDays) {
      warnings.add('Los días visibles son más que la duración total del plan');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida el rango de días
  static ValidationResult validateDayRange(int startDay, int endDay, Plan plan) {
    final errors = <String>[];
    final warnings = <String>[];

    if (startDay < 1) {
      errors.add('El día de inicio debe ser mayor a 0');
    }

    if (endDay > plan.durationInDays) {
      errors.add('El día de fin no puede ser mayor a la duración del plan');
    }

    if (startDay > endDay) {
      errors.add('El día de inicio debe ser menor o igual al día de fin');
    }

    final range = endDay - startDay + 1;
    if (range > CalendarConstants.maxVisibleDays) {
      warnings.add('El rango de días es muy grande');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida la configuración general del calendario
  static ValidationResult validateCalendarConfiguration({
    required Plan plan,
    required int visibleDays,
    required int currentDayGroup,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    // Validar plan
    final planValidation = validatePlan(plan);
    errors.addAll(planValidation.errors);
    warnings.addAll(planValidation.warnings);

    // Validar días visibles
    final visibleDaysValidation = validateVisibleDays(visibleDays, plan);
    errors.addAll(visibleDaysValidation.errors);
    warnings.addAll(visibleDaysValidation.warnings);

    // Validar grupo actual
    if (currentDayGroup < 0) {
      errors.add('El grupo de días actual debe ser mayor o igual a 0');
    }

    final totalGroups = (plan.durationInDays / visibleDays).ceil();
    if (currentDayGroup >= totalGroups) {
      errors.add('El grupo de días actual debe ser menor al número total de grupos');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
}

/// Clase que representa el resultado de una validación
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  /// Obtiene el mensaje de error principal
  String? get primaryError {
    return errors.isNotEmpty ? errors.first : null;
  }

  /// Obtiene el mensaje de advertencia principal
  String? get primaryWarning {
    return warnings.isNotEmpty ? warnings.first : null;
  }

  /// Verifica si hay errores
  bool get hasErrors => errors.isNotEmpty;

  /// Verifica si hay advertencias
  bool get hasWarnings => warnings.isNotEmpty;

  /// Obtiene el número total de problemas
  int get totalIssues => errors.length + warnings.length;

  /// Obtiene una representación en texto
  String get summary {
    if (isValid && !hasWarnings) {
      return 'Válido';
    }
    
    final parts = <String>[];
    if (hasErrors) {
      parts.add('${errors.length} error${errors.length == 1 ? '' : 'es'}');
    }
    if (hasWarnings) {
      parts.add('${warnings.length} advertencia${warnings.length == 1 ? '' : 's'}');
    }
    
    return parts.join(', ');
  }
}
