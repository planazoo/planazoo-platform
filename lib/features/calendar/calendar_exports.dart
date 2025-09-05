// Archivo de barril para centralizar todos los exports del calendario
// Esto resuelve problemas de resolución de imports y dependencias circulares

// Domain Models
export 'domain/models/calendar_state.dart';
export 'domain/models/event.dart';
export 'domain/models/plan.dart';
export 'domain/models/overlapping_event_group.dart';
export 'domain/models/calendar_date.dart';
export 'domain/models/accommodation.dart';

// Domain Services
export 'domain/services/event_service.dart';
export 'domain/services/plan_service.dart';
export 'domain/services/date_service.dart';
export 'domain/services/accommodation_service.dart';

// Presentation Notifiers
export 'presentation/notifiers/calendar_notifier.dart';

// Presentation Providers
export 'presentation/providers/calendar_providers.dart';
export 'presentation/providers/accommodation_providers.dart';

// Presentation Widgets
export 'presentation/widgets/calendar_loading_states.dart';
export 'presentation/widgets/calendar_error_handler.dart';
export 'presentation/widgets/event_cell.dart';
export 'presentation/widgets/event_dialog.dart';
export 'presentation/widgets/overlapping_events_cell.dart';

export 'presentation/widgets/accommodation_dialog.dart';
export 'presentation/widgets/date_selector.dart';
export 'presentation/widgets/overlap_indicator.dart';
// export 'presentation/widgets/event_continuation_indicator.dart'; // Archivo no existe

// Presentation Pages
export 'presentation/pages/calendar_page.dart';
export 'presentation/pages/home_page.dart';
export 'presentation/pages/create_plan_page.dart';
