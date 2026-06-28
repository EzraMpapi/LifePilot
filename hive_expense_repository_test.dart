import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:lifepilot/features/expenses/data/hive_expense_repository.dart';
import 'package:lifepilot/features/expenses/domain/expense_entry.dart';
import 'package:lifepilot/core/storage/local_storage.dart';

/// Tests against a *real* Hive box backed by a temp directory, rather
/// than a mock — Hive's box API is simple enough (and central enough
/// to this feature) that exercising the real thing is more valuable
/// here than mocking it. Uses `Hive.init()` (not `Hive.initFlutter()`,
/// which expects platform channels that don't exist in a plain
/// `flutter_test` unit test, only in a real running app or
/// `testWidgets`).
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('lifepilot_test_');
    Hive.init(tempDir.path);
    await Hive.openBox(LocalStorage.expensesBox);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('HiveExpenseRepository', () {
    test('getAll returns an empty list when nothing has been added', () async {
      final repo = HiveExpenseRepository();
      final result = await repo.getAll();
      expect(result, isEmpty);
    });

    test('add then getAll returns the added entry', () async {
      final repo = HiveExpenseRepository();
      final entry = ExpenseEntry(
        id: '1',
        amount: 2500,
        category: ExpenseCategory.food,
        type: TransactionType.expense,
        date: DateTime(2026, 6, 1),
      );

      await repo.add(entry);
      final result = await repo.getAll();

      expect(result, hasLength(1));
      expect(result.first, equals(entry));
    });

    test('getAll returns entries sorted most-recent-first', () async {
      final repo = HiveExpenseRepository();
      final older = ExpenseEntry(
        id: 'old',
        amount: 100,
        category: ExpenseCategory.food,
        type: TransactionType.expense,
        date: DateTime(2026, 1, 1),
      );
      final newer = ExpenseEntry(
        id: 'new',
        amount: 200,
        category: ExpenseCategory.food,
        type: TransactionType.expense,
        date: DateTime(2026, 6, 1),
      );

      // Add older first, to make sure sorting (not insertion order) is
      // what determines the result.
      await repo.add(older);
      await repo.add(newer);
      final result = await repo.getAll();

      expect(result.first.id, 'new');
      expect(result.last.id, 'old');
    });

    test('update overwrites an existing entry by id', () async {
      final repo = HiveExpenseRepository();
      final original = ExpenseEntry(
        id: '1',
        amount: 1000,
        category: ExpenseCategory.food,
        type: TransactionType.expense,
        date: DateTime(2026, 6, 1),
      );
      await repo.add(original);

      final updated = original.copyWith(amount: 9999);
      await repo.update(updated);

      final result = await repo.getAll();
      expect(result, hasLength(1));
      expect(result.first.amount, 9999);
    });

    test('delete removes the entry', () async {
      final repo = HiveExpenseRepository();
      final entry = ExpenseEntry(
        id: '1',
        amount: 500,
        category: ExpenseCategory.bills,
        type: TransactionType.expense,
        date: DateTime(2026, 6, 1),
      );
      await repo.add(entry);

      await repo.delete('1');
      final result = await repo.getAll();

      expect(result, isEmpty);
    });

    test('watchAll emits immediately, then again after a write', () async {
      final repo = HiveExpenseRepository();
      final emissions = <int>[];
      final subscription = repo.watchAll().listen((list) => emissions.add(list.length));

      // Let the first (immediate) emission land.
      await Future.delayed(const Duration(milliseconds: 50));
      expect(emissions, [0]);

      await repo.add(ExpenseEntry(
        id: '1',
        amount: 100,
        category: ExpenseCategory.other,
        type: TransactionType.expense,
        date: DateTime(2026, 6, 1),
      ));

      await Future.delayed(const Duration(milliseconds: 50));
      expect(emissions, [0, 1]);

      await subscription.cancel();
    });
  });
}
