import 'package:flutter/material.dart';

/// LifePilot's color tokens.
///
/// Design intent: this is a personal life *operating system*, not a
/// corporate SaaS dashboard — it should feel calm, organized, and a
/// little analog (like a well-kept planner), not like another blue
/// "productivity app." The seed color is a deep ink/slate rather than
/// Material's default blue, and amber stands in for the "warmth" of
/// progress and highlights instead of a generic green checkmark color.
///
/// These are named so every other file in the app reads
/// `AppColors.ink` / `AppColors.amber` instead of a raw hex value —
/// the palette is a single source of truth, not scattered literals.
abstract class AppColors {
  // Primary — deep ink/slate, used for the seed color and dark surfaces.
  static const Color ink = Color(0xFF1C2330);
  static const Color inkLight = Color(0xFF2E3A4F);

  // Accent — warm amber, used for highlights, progress, and the
  // "signature" date-header treatment on the dashboard.
  static const Color amber = Color(0xFFE8A33D);
  static const Color amberDeep = Color(0xFFC97F1E);

  // Status colors — used consistently across expenses, goals, habits.
  static const Color success = Color(0xFF3F8F5F);
  static const Color warning = Color(0xFFD9A23B);
  static const Color danger = Color(0xFFC2483D);
  static const Color info = Color(0xFF3D6FB4);

  // Neutrals — warm-grey rather than blue-grey, to match the ink/amber
  // palette instead of clashing with a cooler Material grey scale.
  static const Color paperLight = Color(0xFFFAF8F4);
  static const Color paperDark = Color(0xFF14181F);
  static const Color lineLight = Color(0xFFE3DED3);
  static const Color lineDark = Color(0xFF2A3140);

  // Category colors for expenses/habits — distinct, low-saturation hues
  // that stay legible in both light and dark mode.
  static const Color catFood = Color(0xFFD9714E);
  static const Color catTransport = Color(0xFF4E8FD9);
  static const Color catBills = Color(0xFF8A5FB0);
  static const Color catShopping = Color(0xFFD94E91);
  static const Color catBusiness = Color(0xFF3F8F5F);
  static const Color catSalary = Color(0xFF2E9E8F);
  static const Color catSavings = Color(0xFFC97F1E);
  static const Color catHealthcare = Color(0xFFD94E4E);
  static const Color catEntertainment = Color(0xFF7B6FD9);
  static const Color catEducation = Color(0xFF4EA8D9);
  static const Color catOther = Color(0xFF8A8F98);
}
