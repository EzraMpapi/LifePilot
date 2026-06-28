import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// LifePilot's type system.
///
/// Pairing: Fraunces (a warm, slightly humanist serif with real
/// character at display sizes) for headings and the dashboard's date
/// header, paired with Inter (a clean, highly legible grotesque) for
/// body text and UI labels. This mirrors the "planner, not SaaS tool"
/// design intent — a serif date heading reads like the top of a daily
/// page in a notebook, not a dashboard metric tile.
///
/// google_fonts bundles these at build time when used like this, so
/// there's no extra runtime network fetch in the shipped web build.
abstract class AppTypography {
  static TextTheme textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? Typography.whiteMountainView
        : Typography.blackMountainView;

    return base
        .copyWith(
          displayLarge: GoogleFonts.fraunces(
            fontSize: 40,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
          displayMedium: GoogleFonts.fraunces(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
          displaySmall: GoogleFonts.fraunces(
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
          headlineLarge: GoogleFonts.fraunces(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
          headlineMedium: GoogleFonts.fraunces(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: GoogleFonts.fraunces(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
          bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
          bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400),
          labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
          labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        );
  }
}
