import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/hive_expense_repository.dart';
import '../domain/expense_entry.dart';
import '../domain/expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return HiveExpenseRepository();
});

/// The live list of every expense/income entry, most recent first.
/// UI should watch this rather than calling the repository directly.
final expenseListProvider = StreamProvider<List<ExpenseEntry>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchAll();
});

/// Write operations (add/update/delete) go through this controller
/// rather than the repository directly, so there's one place to add
/// cross-cutting behavior later (e.g. analytics, undo, validation)
/// without touching every screen that creates an entry.
final expenseControllerProvider = Provider<ExpenseController>((ref) {
  return ExpenseController(ref.watch(expenseRepositoryProvider));
});

class ExpenseController {
  final ExpenseRepository _repository;
  ExpenseController(this._repository);

  Future<void> add({
    required double amount,
    required ExpenseCategory category,
    required TransactionType type,
    required DateTime date,
    String? note,
  }) {
    return _repository.add(ExpenseEntry(
      id: const Uuid().v4(),
      amount: amount,
      category: category,
      type: type,
      date: date,
      note: note,
    ));
  }

  Future<void> edit(ExpenseEntry entry) => _repository.update(entry);

  Future<void> delete(String id) => _repository.delete(id);
}

/// Derived summary numbers for a given list of entries — kept as a
/// plain Dart class (not a provider) since it's pure computation over
/// data the UI already has via [expenseListProvider]. Screens that
/// need filtered summaries (e.g. "this month only") filter the list
/// first, then construct one of these.
class ExpenseSummary {
  final double totalIncome;
  final double totalExpense;
  final Map<ExpenseCategory, double> byCategory;

  const ExpenseSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.byCategory,
  });

  double get balance => totalIncome - totalExpense;

  factory ExpenseSummary.from(List<ExpenseEntry> entries) {
    double income = 0;
    double expense = 0;
    final byCategory = <ExpenseCategory, double>{};

    for (final entry in entries) {
      if (entry.type == TransactionType.income) {
        income += entry.amount;
      } else {
        expense += entry.amount;
        byCategory.update(
          entry.category,
          (value) => value + entry.amount,
          ifAbsent: () => entry.amount,
        );
      }
    }

    return ExpenseSummary(totalIncome: income, totalExpense: expense, byCategory: byCategory);
  }
}
