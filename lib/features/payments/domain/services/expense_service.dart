import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/services/logger_service.dart';
import '../models/plan_expense.dart';

/// Gastos tipo Tricount por plan: quién pagó, importe, reparto entre participantes.
class ExpenseService {
  static const String _collectionName = 'plan_expenses';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<PlanExpense>> getExpensesByPlanId(String planId) {
    return _firestore
        .collection(_collectionName)
        .where('planId', isEqualTo: planId)
        .orderBy('expenseDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PlanExpense.fromFirestore(doc))
            .toList());
  }

  Future<List<PlanExpense>> getExpensesByPlanIdFirst(String planId) async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('planId', isEqualTo: planId)
        .orderBy('expenseDate', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => PlanExpense.fromFirestore(doc))
        .toList();
  }

  Future<String?> createExpense(PlanExpense expense, {String? registeredBy}) async {
    try {
      final now = DateTime.now();
      final toCreate = expense.copyWith(
        createdAt: now,
        updatedAt: now,
        registeredBy: registeredBy ?? expense.registeredBy,
      );
      final ref = await _firestore
          .collection(_collectionName)
          .add(toCreate.toFirestore());
      LoggerService.database(
        'Plan expense created: ${ref.id}',
        operation: 'CREATE',
      );
      return ref.id;
    } catch (e) {
      LoggerService.error(
        'Error creating plan expense',
        context: 'ExpenseService',
        error: e,
      );
      return null;
    }
  }

  Future<bool> updateExpense(PlanExpense expense) async {
    if (expense.id == null) return false;
    try {
      await _firestore
          .collection(_collectionName)
          .doc(expense.id!)
          .update(expense.copyWith(updatedAt: DateTime.now()).toFirestore());
      LoggerService.database(
        'Plan expense updated: ${expense.id}',
        operation: 'UPDATE',
      );
      return true;
    } catch (e) {
      LoggerService.error(
        'Error updating plan expense',
        context: 'ExpenseService',
        error: e,
      );
      return false;
    }
  }

  Future<bool> deleteExpense(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
      LoggerService.database(
        'Plan expense deleted: $id',
        operation: 'DELETE',
      );
      return true;
    } catch (e) {
      LoggerService.error(
        'Error deleting plan expense',
        context: 'ExpenseService',
        error: e,
      );
      return false;
    }
  }
}
