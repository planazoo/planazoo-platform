import 'package:unp_calendario/features/calendar/domain/models/plan.dart';

/// T112: Utilidades para calcular días restantes hasta el inicio de un plan
class DaysRemainingUtils {
  /// Calcula los días restantes hasta el inicio del plan
  /// Retorna null si el plan ya inició
  static int? calculateDaysRemaining(Plan plan) {
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(
      plan.startDate.year,
      plan.startDate.month,
      plan.startDate.day,
    );
    
    final difference = startDate.difference(today).inDays;
    
    // Si ya pasó la fecha de inicio, retornar null (no mostrar indicador)
    if (difference < 0) return null;
    
    return difference;
  }

  /// Calcula los días pasados desde el inicio del plan
  /// Retorna null si el plan no ha iniciado aún
  static int? calculateDaysPassed(Plan plan) {
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(
      plan.startDate.year,
      plan.startDate.month,
      plan.startDate.day,
    );
    
    final difference = today.difference(startDate).inDays;
    
    // Si todavía no ha empezado, retornar null
    if (difference < 0) return null;
    
    return difference;
  }

  /// Verifica si el plan debe mostrar el indicador de días restantes
  /// Solo para planes en estado "confirmado"
  static bool shouldShowDaysRemaining(Plan plan) {
    // Solo mostrar si el estado es "confirmado"
    if (plan.state != 'confirmado') return false;
    
    // Verificar que aún no haya empezado
    final daysRemaining = calculateDaysRemaining(plan);
    return daysRemaining != null && daysRemaining >= 0;
  }

  /// Verifica si el plan debe mostrar el badge "Inicia pronto"
  /// Cuando quedan menos de 7 días
  static bool shouldShowStartingSoon(Plan plan) {
    if (!shouldShowDaysRemaining(plan)) return false;
    
    final daysRemaining = calculateDaysRemaining(plan);
    return daysRemaining != null && daysRemaining < 7 && daysRemaining >= 0;
  }

  /// Obtiene el texto para mostrar los días restantes
  static String getDaysRemainingText(int? daysRemaining) {
    if (daysRemaining == null) return '';
    
    if (daysRemaining == 0) {
      return 'Inicia hoy';
    } else if (daysRemaining == 1) {
      return 'Queda 1 día';
    } else {
      return 'Quedan $daysRemaining días';
    }
  }

  /// Obtiene el texto para mostrar los días pasados (opcional)
  static String getDaysPassedText(int? daysPassed) {
    if (daysPassed == null) return '';
    
    if (daysPassed == 0) {
      return 'Inició hoy';
    } else if (daysPassed == 1) {
      return 'Hace 1 día';
    } else {
      return 'Hace $daysPassed días';
    }
  }
}

