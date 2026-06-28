import 'package:intl/intl.dart';

/// Centralized formatting so every screen displays money and dates
/// identically. Currency is hardcoded to a generic format for now —
/// per the spec's Settings section, a user-selectable currency belongs
/// here once Settings exists; this is the single seam to change when
/// that's added.
abstract class Formatters {
  static final _currency = NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0);
  static final _dayMonth = DateFormat('d MMM');
  static final _fullDate = DateFormat('EEEE, d MMMM y');
  static final _monthYear = DateFormat('MMMM y');

  static String currency(double amount) => _currency.format(amount);
  static String dayMonth(DateTime date) => _dayMonth.format(date);
  static String fullDate(DateTime date) => _fullDate.format(date);
  static String monthYear(DateTime date) => _monthYear.format(date);
}
