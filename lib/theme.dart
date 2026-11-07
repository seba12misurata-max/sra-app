import 'package:flutter/material.dart';

/// نظام الألوان والتصميم الخاص بـ SRA - متناسق مع واجهة الويب
/// (خلفية رمادية دافئة قريبة من السواد + لون كهرماني مميز).
class SraColors {
  static const background = Color(0xFF14161C);
  static const panel = Color(0xFF1C1F27);
  static const panelAlt = Color(0xFF23272F);
  static const border = Color(0xFF2C303A);
  static const text = Color(0xFFECEDF1);
  static const textMuted = Color(0xFF8B909C);
  static const accent = Color(0xFFE8A33D);
  static const accentDim = Color(0xFF8A5E20);
  static const danger = Color(0xFFE07A7A);
  static const success = Color(0xFF6FCF97);
}

ThemeData buildSraTheme() {
  final base = ThemeData.dark(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: SraColors.background,
    colorScheme: base.colorScheme.copyWith(
      primary: SraColors.accent,
      secondary: SraColors.accentDim,
      surface: SraColors.panel,
      error: SraColors.danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: SraColors.panel,
      foregroundColor: SraColors.text,
      elevation: 0,
    ),
    cardColor: SraColors.panel,
    dividerColor: SraColors.border,
    textTheme: base.textTheme.apply(
      bodyColor: SraColors.text,
      displayColor: SraColors.text,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SraColors.panelAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: SraColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: SraColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: SraColors.accent),
      ),
      hintStyle: const TextStyle(color: SraColors.textMuted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SraColors.accent,
        foregroundColor: const Color(0xFF1A1208),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: SraColors.panel,
      selectedIconTheme: const IconThemeData(color: SraColors.accent),
      selectedLabelTextStyle: const TextStyle(color: SraColors.accent),
      unselectedIconTheme: const IconThemeData(color: SraColors.textMuted),
      unselectedLabelTextStyle: const TextStyle(color: SraColors.textMuted),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: SraColors.panel,
      indicatorColor: SraColors.accentDim.withOpacity(0.4),
    ),
  );
}
