import 'package:flutter_test/flutter_test.dart';
import 'package:lifepilot/features/expenses/domain/expense_entry.dart';
import 'package:lifepilot/features/expenses/presentation/expense_providers.dart';

void main() {
  group('ExpenseSummary', () {
    test('empty list produces all-zero summary', () {
      final summary = ExpenseSummary.from([]);

      expect(summary.totalIncome, 0);
      expect(summary.totalExpense, 0);
      expect(summary.balance, 0);
      expect(summary.byCategory, isEmpty);
    });

    test('separates income and expense totals correctly', () {
      final entries = [
        _entry(amount: 50000, type: TransactionType.income, category: ExpenseCategory.salary),
        _entry(amount: 5000, type: TransactionType.expense, category: ExpenseCategory.food),
        _entry(amount: 3000, type: TransactionType.expense, category: ExpenseCategory.transport),
      ];

      final summary = ExpenseSummary.from(entries);

      expect(summary.totalIncome, 50000);
      expect(summary.totalExpense, 8000);
      expect(summary.balance, 42000);
    });

    test('groups expense totals by category, ignoring income', () {
      final entries = [
        _entry(amount: 50000, type: TransactionType.income, category: ExpenseCategory.salary),
        _entry(amount: 1000, type: TransactionType.expense, category: ExpenseCategory.food),
        _entry(amount: 2000, type: TransactionType.expense, category: ExpenseCategory.food),
        _entry(amount: 500, type: TransactionType.expense, category: ExpenseCategory.transport),
      ];

      final summary = ExpenseSummary.from(entries);

      // Income should not appear in the per-category expense breakdown.
      expect(summary.byCategory.containsKey(ExpenseCategory.salary), isFalse);
      expect(summary.byCategory[ExpenseCategory.food], 3000);
      expect(summary.byCategory[ExpenseCategory.transport], 500);
    });

    test('balance can be negative when expenses exceed income', () {
      final entries = [
        _entry(amount: 1000, type: TransactionType.income, category: ExpenseCategory.salary),
        _entry(amount: 5000, type: TransactionType.expense, category: ExpenseCategory.shopping),
      ];

      final summary = ExpenseSummary.from(entries);

      expect(summary.balance, -4000);
    });
  });
}

ExpenseEntry _entry({
  required double amount,
  required TransactionType type,
  required ExpenseCategory category,
}) {
  return ExpenseEntry(
    id: 'test-${DateTime.now().microsecondsSinceEpoch}-${amount.hashCode}',
    amount: amount,
    category: category,
    type: type,
    date: DateTime(2026, 6, 1),
  );
}
