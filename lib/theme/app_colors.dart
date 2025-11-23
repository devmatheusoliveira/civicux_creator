import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF6C63FF); // Vibrant Purple
  static const Color primaryDark = Color(0xFF4B45B2);
  static const Color primaryLight = Color(0xFFAEA9FF);

  // Secondary Palette
  static const Color secondary = Color(0xFF00E5FF); // Cyan Neon
  static const Color secondaryDark = Color(0xFF00B2CC);
  static const Color secondaryLight = Color(0xFF80F2FF);

  // Neutral Palette (Dark Theme)
  static const Color background = Color(0xFF121212); // Very Dark Grey
  static const Color surface = Color(0xFF1E1E1E); // Slightly lighter for cards
  static const Color surfaceHover = Color(0xFF2C2C2C);
  
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textDisabled = Color(0xFF6E6E6E);

  // Status Colors
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFAB40);
  static const Color info = Color(0xFF448AFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
