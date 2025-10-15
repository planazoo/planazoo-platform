// Archivo de barril para centralizar todos los exports del calendario
// Esto resuelve problemas de resolución de imports y dependencias circulares

// Domain Models
export 'domain/models/calendar_state.dart';
export 'domain/models/event.dart';
export 'domain/models/plan.dart';
export 'domain/models/event_segment.dart';
export 'domain/models/overlapping_segment_group.dart';
export 'domain/models/calendar_date.dart';
export 'domain/models/accommodation.dart';
export 'domain/models/participant_track.dart';

// Domain Services
export 'domain/services/event_service.dart';
export 'domain/services/plan_service.dart';
export 'domain/services/date_service.dart';
export 'domain/services/accommodation_service.dart';
export 'domain/services/track_service.dart';

// Presentation Notifiers
export 'presentation/notifiers/calendar_notifier.dart';

// Presentation Providers
export 'presentation/providers/calendar_providers.dart';
export 'presentation/providers/accommodation_providers.dart';

// Presentation Widgets (widgets actualmente en uso)
export '../../widgets/wd_event_dialog.dart';
export '../../widgets/wd_accommodation_dialog.dart';
export '../../widgets/wd_date_selector.dart';

// Presentation Pages
export '../../pages/pg_dashboard_page.dart';
