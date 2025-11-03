/// T102: Resumen de pagos y balances por participante
class PaymentSummary {
  final String planId;
  final Map<String, ParticipantBalance> balancesByParticipant; // userId -> balance

  const PaymentSummary({
    required this.planId,
    required this.balancesByParticipant,
  });

  // Getters útiles
  double get totalCost => balancesByParticipant.values
      .fold<double>(0.0, (sum, balance) => sum + balance.totalCost);
  
  double get totalPaid => balancesByParticipant.values
      .fold<double>(0.0, (sum, balance) => sum + balance.totalPaid);
  
  int get totalParticipants => balancesByParticipant.length;
  
  List<ParticipantBalance> get creditors => balancesByParticipant.values
      .where((b) => b.balance > 0)
      .toList()
    ..sort((a, b) => b.balance.compareTo(a.balance));
  
  List<ParticipantBalance> get debtors => balancesByParticipant.values
      .where((b) => b.balance < 0)
      .toList()
    ..sort((a, b) => a.balance.compareTo(b.balance));
  
  double get totalToReceive => creditors.fold<double>(0.0, (sum, b) => sum + b.balance);
  double get totalToPay => debtors.fold<double>(0.0, (sum, b) => sum + b.balance.abs());
}

/// Balance individual de un participante
class ParticipantBalance {
  final String userId;
  final String userName; // Nombre para mostrar
  final double totalCost; // Coste total asignado
  final double totalPaid; // Total pagado
  final double balance; // balance = totalPaid - totalCost
  final List<PaymentItem> payments; // Lista de pagos
  final PaymentStatus status; // Estado del pago

  const ParticipantBalance({
    required this.userId,
    required this.userName,
    required this.totalCost,
    required this.totalPaid,
    required this.balance,
    required this.payments,
    required this.status,
  });

  // Getters útiles
  bool get isCreditor => balance > 0;
  bool get isDebtor => balance < 0;
  bool get isSettled => balance == 0;
  double get pendingAmount => balance < 0 ? balance.abs() : 0.0;
  double get toReceiveAmount => balance > 0 ? balance : 0.0;
}

/// Item de pago individual
class PaymentItem {
  final String paymentId;
  final String? eventId;
  final String? eventDescription;
  final double amount;
  final DateTime paymentDate;
  final String? paymentMethod;
  final String? concept;

  const PaymentItem({
    required this.paymentId,
    this.eventId,
    this.eventDescription,
    required this.amount,
    required this.paymentDate,
    this.paymentMethod,
    this.concept,
  });
}

/// Estado de pago de un participante
enum PaymentStatus {
  pending, // No ha pagado nada o muy poco
  partial, // Ha pagado parcialmente
  settled, // Está al día (balance = 0)
  overpaid, // Ha pagado de más (acreedor)
}

