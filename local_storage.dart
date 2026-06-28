import 'package:hive_flutter/hive_flutter.dart';

/// Central place that opens every Hive box the app uses.
///
/// This is the seam where "local storage only" lives for now. When
/// Firebase/Firestore is added later, each feature's repository
/// implementation swaps from reading/writing a Hive box to
/// reading/writing Firestore — the domain layer (entities, repository
/// *interfaces*) doesn't change at all, because features only ever
/// depend on the interface, never on Hive directly. See
/// lib/features/expenses/domain/expense_repository.dart for the
/// interface this pattern protects.
class LocalStorage {
  LocalStorage._();

  static const String expensesBox = 'expenses_box';
  static const String authBox = 'auth_box';
  static const String settingsBox = 'settings_box';

  /// Call once, before runApp(). Registers adapters and opens every
  /// box the app needs up front, so features never have to worry
  /// about whether their box is open yet.
  static Future<void> init() async {
    await Hive.initFlutter();

    await Hive.openBox(expensesBox);
    await Hive.openBox(authBox);
    await Hive.openBox(settingsBox);
  }
}
