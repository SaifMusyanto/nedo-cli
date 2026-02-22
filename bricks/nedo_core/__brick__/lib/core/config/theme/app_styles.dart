import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized text styles for the application.
///
/// This file defines the color-agnostic typography scale. The colors are
/// applied later by the `ThemeData` in `app_theme.dart` using the `.apply()` method.
/// This ensures that text styles automatically adapt to light/dark themes.
class AppStyles {
  AppStyles._();

  // This is the main text theme, created from Google Fonts.
  // We use this as a base and then customize individual styles below.
  static final _baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

  // To create our final TextTheme, we copy the base theme and override
  // specific styles with our custom sizes and weights.
  static final TextTheme textTheme = _baseTextTheme.copyWith(
    displayLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    displayMedium: const TextStyle(fontSize: 19, fontWeight: FontWeight.w300),
    displaySmall: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
    headlineMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
    headlineSmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
    labelLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    labelSmall: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 0),
  ).apply(
    fontFamily: GoogleFonts.workSans().fontFamily,
  );
}