import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/services/logger_service.dart';
import '../models/kitty_contribution.dart';
import '../models/kitty_expense.dart';

/// T219: Servicio para bote común (aportaciones y gastos)
class KittyService {
  static const String _contributionsName = 'kitty_contributions';
  static const String _expensesName = 'kitty_expenses';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<KittyContribution>> getContributionsByPlanId(String planId) {
    return _firestore
        .collection(_contributionsName)
        .where('planId', isEqualTo: planId)
        .orderBy('contributionDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => KittyContribution.fromFirestore(doc))
            .toList());
  }

  Stream<List<KittyExpense>> getExpensesByPlanId(String planId) {
    return _firestore
        .collection(_expensesName)
        .where('planId', isEqualTo: planId)
        .orderBy('expenseDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => KittyExpense.fromFirestore(doc))
            .toList());
  }

  Future<List<KittyContribution>> getContributionsByPlanIdFirst(
    String planId,
  ) async {
    final list = await _firestore
        .collection(_contributionsName)
        .where('planId', isEqualTo: planId)
        .orderBy('contributionDate', descending: true)
        .get();
    return list.docs.map((doc) => KittyContribution.fromFirestore(doc)).toList();
  }

  Future<List<KittyExpense>> getExpensesByPlanIdFirst(String planId) async {
    final list = await _firestore
        .collection(_expensesName)
        .where('planId', isEqualTo: planId)
        .orderBy('expenseDate', descending: true)
        .get();
    return list.docs.map((doc) => KittyExpense.fromFirestore(doc)).toList();
  }

  Future<String?> createContribution(KittyContribution c) async {
    try {
      final now = DateTime.now();
      final toCreate = c.copyWith(createdAt: now, updatedAt: now);
      final ref = await _firestore
          .collection(_contributionsName)
          .add(toCreate.toFirestore());
      LoggerService.database(
        'Kitty contribution created: ${ref.id}',
        operation: 'CREATE',
      );
      return ref.id;
    } catch (e) {
      LoggerService.error(
        'Error creating kitty contribution',
        context: 'KittyService',
        error: e,
      );
      return null;
    }
  }

  Future<String?> createExpense(KittyExpense e) async {
    try {
      final now = DateTime.now();
      final toCreate = e.copyWith(createdAt: now, updatedAt: now);
      final ref = await _firestore
          .collection(_expensesName)
          .add(toCreate.toFirestore());
      LoggerService.database(
        'Kitty expense created: ${ref.id}',
        operation: 'CREATE',
      );
      return ref.id;
    } catch (err) {
      LoggerService.error(
        'Error creating kitty expense',
        context: 'KittyService',
        error: err,
      );
      return null;
    }
  }

  Future<bool> deleteContribution(String id) async {
    try {
      await _firestore.collection(_contributionsName).doc(id).delete();
      LoggerService.database('Kitty contribution deleted: $id', operation: 'DELETE');
      return true;
    } catch (e) {
      LoggerService.error(
        'Error deleting kitty contribution',
        context: 'KittyService',
        error: e,
      );
      return false;
    }
  }

  Future<bool> deleteExpense(String id) async {
    try {
      await _firestore.collection(_expensesName).doc(id).delete();
      LoggerService.database('Kitty expense deleted: $id', operation: 'DELETE');
      return true;
    } catch (e) {
      LoggerService.error(
        'Error deleting kitty expense',
        context: 'KittyService',
        error: e,
      );
      return false;
    }
  }
}
