import 'package:cloud_firestore/cloud_firestore.dart';

/// Tramo de política de cancelación (T273).
/// [refundPercent] = porcentaje del depósito que **se recupera** si cancelas antes de [deadlineAt].
class CancellationTier {
  final DateTime deadlineAt;
  final double refundPercent;

  const CancellationTier({
    required this.deadlineAt,
    required this.refundPercent,
  });

  factory CancellationTier.fromMap(Map<String, dynamic> map) {
    final raw = map['deadlineAt'];
    final DateTime deadline;
    if (raw is Timestamp) {
      deadline = raw.toDate();
    } else if (raw is DateTime) {
      deadline = raw;
    } else {
      deadline = DateTime.now();
    }
    return CancellationTier(
      deadlineAt: deadline,
      refundPercent: (map['refundPercent'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'deadlineAt': Timestamp.fromDate(deadlineAt),
        'refundPercent': refundPercent,
      };

  CancellationTier copyWith({
    DateTime? deadlineAt,
    double? refundPercent,
  }) {
    return CancellationTier(
      deadlineAt: deadlineAt ?? this.deadlineAt,
      refundPercent: refundPercent ?? this.refundPercent,
    );
  }
}

/// Presets de aviso al organizador (T273).
class CancellationReminderPreset {
  static const none = 'none';
  static const day = 'day';
  static const h24 = 'h24';
  static const h24Day = 'h24_day';
  static const h48 = 'h48';
  static const h48Day = 'h48_day';
  static const h168 = 'h168';
  static const h168Day = 'h168_day';

  static const defaultPreset = h48Day;

  static const all = <String>[
    none,
    day,
    h24,
    h24Day,
    h48,
    h48Day,
    h168,
    h168Day,
  ];
}

/// Garantía de reserva + política de cancelación (T273).
/// Se usa igual en eventos y alojamientos.
class ReservationCancellation {
  /// Importe de la garantía / depósito (moneda del plan).
  final double? guaranteeAmount;

  /// Usuario que adelantó el dinero (un solo pagador en v1).
  final String? guaranteePayerUserId;

  /// `pending` | `paid` | `refunded` | `retained`
  final String guaranteeStatus;

  final String? guaranteeNote;

  /// Hasta 2 tramos; puede estar vacío o tener 1.
  final List<CancellationTier> tiers;

  /// Cargo fijo opcional al cancelar dentro de ventanas con reembolso (p. ej. 5 €).
  final double? cancellationFixedFee;

  /// IANA timezone del ítem para interpretar/mostrar deadlines.
  final String? timezone;

  /// Horas antes del deadline para el aviso anticipado.
  /// `null` = sin aviso por antelación (puede quedar solo el día).
  /// Por defecto efectivo (docs sin campo): 48.
  final int? reminderLeadHours;

  /// Si true, también avisa el día civil del límite.
  final bool reminderAlsoOnDay;

  const ReservationCancellation({
    this.guaranteeAmount,
    this.guaranteePayerUserId,
    this.guaranteeStatus = 'pending',
    this.guaranteeNote,
    this.tiers = const [],
    this.cancellationFixedFee,
    this.timezone,
    this.reminderLeadHours = 48,
    this.reminderAlsoOnDay = true,
  });

  bool get hasGuarantee =>
      guaranteeAmount != null && guaranteeAmount! > 0;

  bool get hasPolicy =>
      tiers.isNotEmpty ||
      (cancellationFixedFee != null && cancellationFixedFee! > 0);

  bool get hasReminder =>
      (reminderLeadHours != null && reminderLeadHours! > 0) ||
      reminderAlsoOnDay;

  bool get isEmpty =>
      !hasGuarantee &&
      tiers.isEmpty &&
      (cancellationFixedFee == null || cancellationFixedFee! <= 0) &&
      (guaranteeNote == null || guaranteeNote!.trim().isEmpty) &&
      (guaranteePayerUserId == null || guaranteePayerUserId!.isEmpty);

  /// Preset de UI a partir de lead + día.
  String get reminderPreset {
    final lead = reminderLeadHours;
    if (lead == null || lead <= 0) {
      return reminderAlsoOnDay
          ? CancellationReminderPreset.day
          : CancellationReminderPreset.none;
    }
    if (lead == 24) {
      return reminderAlsoOnDay
          ? CancellationReminderPreset.h24Day
          : CancellationReminderPreset.h24;
    }
    if (lead == 168) {
      return reminderAlsoOnDay
          ? CancellationReminderPreset.h168Day
          : CancellationReminderPreset.h168;
    }
    // 48 u otro valor → mostrar como 48h (+ día si aplica)
    return reminderAlsoOnDay
        ? CancellationReminderPreset.h48Day
        : CancellationReminderPreset.h48;
  }

  /// Parsea un preset de selector a (leadHours, alsoOnDay).
  static ({int? leadHours, bool alsoOnDay}) parseReminderPreset(String preset) {
    switch (preset) {
      case CancellationReminderPreset.none:
        return (leadHours: null, alsoOnDay: false);
      case CancellationReminderPreset.day:
        return (leadHours: null, alsoOnDay: true);
      case CancellationReminderPreset.h24:
        return (leadHours: 24, alsoOnDay: false);
      case CancellationReminderPreset.h24Day:
        return (leadHours: 24, alsoOnDay: true);
      case CancellationReminderPreset.h48:
        return (leadHours: 48, alsoOnDay: false);
      case CancellationReminderPreset.h168:
        return (leadHours: 168, alsoOnDay: false);
      case CancellationReminderPreset.h168Day:
        return (leadHours: 168, alsoOnDay: true);
      case CancellationReminderPreset.h48Day:
      default:
        return (leadHours: 48, alsoOnDay: true);
    }
  }

  /// Fases activas ahora para un [deadline] según la config de aviso.
  List<String> activeReminderPhases(DateTime now, DateTime deadline) {
    if (!deadline.isAfter(now) || !hasReminder) return const [];
    final phases = <String>[];
    final lead = reminderLeadHours;
    if (lead != null && lead > 0) {
      final until = now.add(Duration(hours: lead));
      if (!deadline.isAfter(until)) {
        phases.add('h$lead');
      }
    }
    if (reminderAlsoOnDay) {
      final la = now.toLocal();
      final lb = deadline.toLocal();
      if (la.year == lb.year && la.month == lb.month && la.day == lb.day) {
        phases.add('day');
      }
    }
    return phases;
  }

  /// Próximo deadline futuro (ordenados por fecha).
  DateTime? get nextDeadline {
    final now = DateTime.now();
    final upcoming = tiers
        .map((t) => t.deadlineAt)
        .where((d) => d.isAfter(now))
        .toList()
      ..sort();
    return upcoming.isEmpty ? null : upcoming.first;
  }

  /// Hay límite de cancelación en las próximas [within] (por defecto 7 días).
  bool hasUpcomingDeadline({Duration within = const Duration(days: 7)}) {
    final next = nextDeadline;
    if (next == null) return false;
    return !next.isAfter(DateTime.now().add(within));
  }

  /// Tramo cuyo deadline es el próximo futuro.
  CancellationTier? get nextTier {
    final next = nextDeadline;
    if (next == null) return null;
    for (final t in tiers) {
      if (t.deadlineAt == next) return t;
    }
    return null;
  }

  factory ReservationCancellation.fromMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) {
      return const ReservationCancellation();
    }
    final rawTiers = map['tiers'] as List<dynamic>? ?? [];
    final tiers = rawTiers
        .whereType<Map>()
        .map((e) => CancellationTier.fromMap(Map<String, dynamic>.from(e)))
        .take(2)
        .toList();

    // Compat docs antiguos sin campos de aviso → 48h + día.
    final hasLeadField = map.containsKey('reminderLeadHours');
    final hasDayField = map.containsKey('reminderAlsoOnDay');
    final leadRaw = map['reminderLeadHours'];
    final int? leadHours;
    if (!hasLeadField) {
      leadHours = 48;
    } else if (leadRaw == null) {
      leadHours = null;
    } else {
      leadHours = (leadRaw as num).toInt();
    }
    final alsoOnDay =
        hasDayField ? (map['reminderAlsoOnDay'] as bool? ?? false) : true;

    return ReservationCancellation(
      guaranteeAmount: map['guaranteeAmount'] != null
          ? (map['guaranteeAmount'] as num).toDouble()
          : null,
      guaranteePayerUserId: map['guaranteePayerUserId'] as String?,
      guaranteeStatus: (map['guaranteeStatus'] as String?) ?? 'pending',
      guaranteeNote: map['guaranteeNote'] as String?,
      tiers: tiers,
      cancellationFixedFee: map['cancellationFixedFee'] != null
          ? (map['cancellationFixedFee'] as num).toDouble()
          : null,
      timezone: map['timezone'] as String?,
      reminderLeadHours: leadHours,
      reminderAlsoOnDay: alsoOnDay,
    );
  }

  Map<String, dynamic>? toMap() {
    if (isEmpty) return null;
    return {
      if (guaranteeAmount != null) 'guaranteeAmount': guaranteeAmount,
      if (guaranteePayerUserId != null && guaranteePayerUserId!.isNotEmpty)
        'guaranteePayerUserId': guaranteePayerUserId,
      'guaranteeStatus': guaranteeStatus,
      if (guaranteeNote != null && guaranteeNote!.trim().isNotEmpty)
        'guaranteeNote': guaranteeNote!.trim(),
      if (tiers.isNotEmpty) 'tiers': tiers.map((t) => t.toMap()).toList(),
      if (cancellationFixedFee != null)
        'cancellationFixedFee': cancellationFixedFee,
      if (timezone != null && timezone!.isNotEmpty) 'timezone': timezone,
      // Siempre persistir preferencia de aviso (null = sin antelación).
      'reminderLeadHours': reminderLeadHours,
      'reminderAlsoOnDay': reminderAlsoOnDay,
    };
  }

  ReservationCancellation copyWith({
    double? guaranteeAmount,
    String? guaranteePayerUserId,
    String? guaranteeStatus,
    String? guaranteeNote,
    List<CancellationTier>? tiers,
    double? cancellationFixedFee,
    String? timezone,
    int? reminderLeadHours,
    bool? reminderAlsoOnDay,
    bool clearGuaranteeAmount = false,
    bool clearPayer = false,
    bool clearFixedFee = false,
    bool clearNote = false,
    bool clearReminderLead = false,
  }) {
    return ReservationCancellation(
      guaranteeAmount: clearGuaranteeAmount
          ? null
          : (guaranteeAmount ?? this.guaranteeAmount),
      guaranteePayerUserId: clearPayer
          ? null
          : (guaranteePayerUserId ?? this.guaranteePayerUserId),
      guaranteeStatus: guaranteeStatus ?? this.guaranteeStatus,
      guaranteeNote: clearNote ? null : (guaranteeNote ?? this.guaranteeNote),
      tiers: tiers ?? this.tiers,
      cancellationFixedFee: clearFixedFee
          ? null
          : (cancellationFixedFee ?? this.cancellationFixedFee),
      timezone: timezone ?? this.timezone,
      reminderLeadHours: clearReminderLead
          ? null
          : (reminderLeadHours ?? this.reminderLeadHours),
      reminderAlsoOnDay: reminderAlsoOnDay ?? this.reminderAlsoOnDay,
    );
  }
}
