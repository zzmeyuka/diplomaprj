import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Design tokens from SmartFly UI mockup.
class AppColors {
  static const primary = Color(0xFF1E3A8A);
  static const primaryBright = Color(0xFF3B82F6);
  static const lightBg = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF3F4F6);
  static const darkBg = Color(0xFF0B2545);
  static const darkSurface = Color(0xFF132F52);
  static const darkCard = Color(0xFF1A3A5C);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textOnDark = Color(0xFFF9FAFB);
  static const textMutedDark = Color(0xFF9CA3AF);
  static const success = Color(0xFF10B981);
  static const borderLight = Color(0xFFE5E7EB);

  static const buttonGradient = [Color(0xFF2563EB), Color(0xFF1E3A8A)];
  static const buttonGradientDark = [Color(0xFF3B82F6), Color(0xFF2563EB)];
}

class AppRadius {
  static const card = 20.0;
  static const button = 16.0;
  static const input = 16.0;
  static const chip = 24.0;
}

class AppTheme {
  static TextTheme _text(Brightness b) {
    final primary = b == Brightness.light ? AppColors.textPrimary : AppColors.textOnDark;
    final secondary = b == Brightness.light ? AppColors.textSecondary : AppColors.textMutedDark;
    return TextTheme(
      displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: primary, height: 1.2),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: primary),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
      bodyLarge: TextStyle(fontSize: 15, color: secondary, height: 1.45),
      bodyMedium: TextStyle(fontSize: 14, color: secondary),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: primary),
    );
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryBright,
        surface: AppColors.lightBg,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.lightSurface,
      ),
      textTheme: _text(Brightness.light),
      dividerColor: AppColors.borderLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBg,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.borderLight),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.primaryBright, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: AppColors.lightBg,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
              fontSize: 11,
              fontWeight: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
              color: s.contains(WidgetState.selected) ? AppColors.primary : AppColors.textSecondary,
            )),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.selected)) return AppColors.primary;
            return AppColors.lightSurface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.selected)) return Colors.white;
            return AppColors.textSecondary;
          }),
        ),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBright,
        onPrimary: Colors.white,
        surface: AppColors.darkBg,
        onSurface: AppColors.textOnDark,
        surfaceContainerHighest: AppColors.darkSurface,
      ),
      textTheme: _text(Brightness.dark),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBg,
        foregroundColor: AppColors.textOnDark,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.primaryBright, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textMutedDark),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.primaryBright.withValues(alpha: 0.2),
      ),
    );
  }
}
