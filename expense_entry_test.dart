import 'package:flutter_test/flutter_test.dart';
import 'package:lifepilot/features/expenses/domain/expense_entry.dart';

void main() {
  group('ExpenseEntry', () {
    test('toMap/fromMap round-trip preserves all fields', () {
      final original = ExpenseEntry(
        id: 'abc-123',
        amount: 4500.5,
        category: ExpenseCategory.transport,
        type: TransactionType.expense,
        date: DateTime(2026, 6, 15, 9, 30),
        note: 'Bus fare',
      );

      final restored = ExpenseEntry.fromMap(original.toMap());

      expect(restored, equals(original));
      expect(restored.amount, 4500.5);
      expect(restored.category, ExpenseCategory.transport);
      expect(restored.type, TransactionType.expense);
      expect(restored.note, 'Bus fare');
    });

    test('toMap/fromMap round-trip works with a null note', () {
      final original = ExpenseEntry(
        id: 'def-456',
        amount: 12000,
        category: ExpenseCategory.salary,
        type: TransactionType.income,
        date: DateTime(2026, 6, 1),
      );

      final restored = ExpenseEntry.fromMap(original.toMap());

      expect(restored, equals(original));
      expect(restored.note, isNull);
    });

    test('copyWith only changes the specified fields', () {
      final original = ExpenseEntry(
        id: 'ghi-789',
        amount: 1000,
        category: ExpenseCategory.food,
        type: TransactionType.expense,
        date: DateTime(2026, 1, 1),
      );

      final updated = original.copyWith(amount: 2000);

      expect(updated.amount, 2000);
      expect(updated.id, original.id);
      expect(updated.category, original.category);
      expect(updated.type, original.type);
      expect(updated.date, original.date);
    });

    test('every ExpenseCategory has a non-empty label', () {
      for (final category in ExpenseCategory.values) {
        expect(category.label, isNotEmpty, reason: '$category should have a label');
      }
    });
  });
}
