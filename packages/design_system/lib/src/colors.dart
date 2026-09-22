import 'package:flutter/material.dart';

abstract final class TerraResinColors {
  // TerraResin Brand
  static const primary = Color(0xFFEB5827);
  static const primaryLight = Color(0xFFEF702D);
  static const accent = Color(0xFFF2A03A);

  // TerraResin Brand Gradient
  static const brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, primaryLight, accent],
  );

  // Common Colors
  static const background = Color(0xFFF7F8F7);
  static const darkBackground = Color(0xFF101412);

  static const textPrimary = Color(0xFF17201C);
  static const textSecondary = Color(0xFF66736D);

  static const border = Color(0xFFE0E5E2);

  static const white = Colors.white;
}
