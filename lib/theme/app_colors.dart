import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary Palette - Civic Blue/Purple
  static const Color primary = Color(0xFF5B4FE9); // Deep Purple-Blue
  static const Color primaryDark = Color(0xFF3D2FB8);
  static const Color primaryLight = Color(0xFF8B7FF5);

  // Secondary Palette - Civic Green/Teal
  static const Color secondary = Color(0xFF00D9B5); // Vibrant Teal
  static const Color secondaryDark = Color(0xFF00A88C);
  static const Color secondaryLight = Color(0xFF4DFFDB);

  // Accent - Warm Orange for CTAs
  static const Color accent = Color(0xFFFF6B35); // Energetic Orange
  static const Color accentLight = Color(0xFFFF9770);

  // Neutral Palette (Dark Theme)
  static const Color background = Color(0xFF0F0F1E); // Deep Navy
  static const Color surface = Color(0xFF1A1A2E); // Slightly lighter
  static const Color surfaceHover = Color(0xFF252542);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B8D1);
  static const Color textDisabled = Color(0xFF6E6E8A);

  // Status Colors
  static const Color success = Color(0xFF00D9B5);
  static const Color error = Color(0xFFFF5370);
  static const Color warning = Color(0xFFFFB84D);
  static const Color info = Color(0xFF5B9FFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFFFF8F5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
