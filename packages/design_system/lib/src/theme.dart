import 'package:flutter/material.dart';

import 'colors.dart';

abstract final class TerraResinTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: TerraResinColors.background,
      colorScheme: const ColorScheme.light(
        primary: TerraResinColors.primary,
        onPrimary: TerraResinColors.white,
        secondary: TerraResinColors.accent,
        onSecondary: TerraResinColors.textPrimary,
        surface: TerraResinColors.white,
        onSurface: TerraResinColors.textPrimary,
        outline: TerraResinColors.border,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: TerraResinColors.white,
        foregroundColor: TerraResinColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: TerraResinColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: TerraResinColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: TerraResinColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: TerraResinColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: TerraResinColors.textPrimary),
        bodyMedium: TextStyle(color: TerraResinColors.textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TerraResinColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: TerraResinColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: TerraResinColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: TerraResinColors.primary,
            width: 2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TerraResinColors.primary,
          foregroundColor: TerraResinColors.white,
          elevation: 0,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: TerraResinColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: TerraResinColors.border),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: TerraResinColors.background,
        selectedColor: TerraResinColors.primary.withValues(alpha: 0.12),
        labelStyle: const TextStyle(
          color: TerraResinColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: TerraResinColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      dividerTheme: const DividerThemeData(
        color: TerraResinColors.border,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: TerraResinColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TerraResinColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: TerraResinColors.primaryLight,
        onPrimary: TerraResinColors.white,
        secondary: TerraResinColors.accent,
        onSecondary: TerraResinColors.textPrimary,
        surface: Color(0xFF171C19),
        onSurface: TerraResinColors.white,
        outline: Color(0xFF38413D),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: TerraResinColors.darkBackground,
        foregroundColor: TerraResinColors.white,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: TerraResinColors.white,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: TerraResinColors.white,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: TerraResinColors.white,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: TerraResinColors.white,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: TerraResinColors.white),
        bodyMedium: TextStyle(color: Color(0xFFB5BDB9)),
      ),
    );
  }
}
