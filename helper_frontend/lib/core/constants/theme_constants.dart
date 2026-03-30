import 'package:flutter/material.dart';
import 'package:helper_frontend/core/constants/theme_colors_constants.dart';

class ThemeConstants {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ThemeColorsConstants.backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ThemeColorsConstants.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: ThemeColorsConstants.infoBorderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: ThemeColorsConstants.primary,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ThemeColorsConstants.backgroundDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ThemeColorsConstants.primarySoft,
        brightness: Brightness.dark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ThemeColorsConstants.panelInnerDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: ThemeColorsConstants.infoBorderDark,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: ThemeColorsConstants.primarySoft,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}
