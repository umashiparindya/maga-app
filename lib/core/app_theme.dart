import 'package:flutter/material.dart';

abstract final class MashiColors {
  static const canvas = Color(0xFFF7F5EF);
  static const surface = Color(0xFFFFFFFF);
  static const primary = Color(0xFF176B5B);
  static const onPrimary = Color(0xFFFFFFFF);
  static const warm = Color(0xFFC47752);
  static const ink = Color(0xFF1E2B28);
  static const muted = Color(0xFF596662);
  static const outline = Color(0xFFCDD5D0);
}

abstract final class MashiSpace {
  static const page = 24.0;
  static const section = 24.0;
  static const compact = 12.0;
}

abstract final class MashiTheme {
  static final light = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: MashiColors.primary,
      onPrimary: MashiColors.onPrimary,
      surface: MashiColors.surface,
      onSurface: MashiColors.ink,
      outline: MashiColors.outline,
    ),
    scaffoldBackgroundColor: MashiColors.canvas,
    appBarTheme: const AppBarTheme(
      backgroundColor: MashiColors.canvas,
      foregroundColor: MashiColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: MashiColors.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: MashiColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: MashiColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: MashiColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.redAccent, width: 2),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      side: const BorderSide(color: MashiColors.outline, width: 1.5),
      fillColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? MashiColors.primary
            : MashiColors.surface;
      }),
      checkColor: const WidgetStatePropertyAll(MashiColors.onPrimary),
    ),
    dividerTheme: const DividerThemeData(
      color: MashiColors.outline,
      thickness: 1,
      space: 1,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: MashiColors.ink,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        color: MashiColors.ink,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: MashiColors.ink, fontSize: 17, height: 1.45),
      bodyMedium: TextStyle(
        color: MashiColors.muted,
        fontSize: 15,
        height: 1.45,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: MashiColors.primary,
        foregroundColor: MashiColors.onPrimary,
        minimumSize: const Size.fromHeight(52),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: MashiColors.primary,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: MashiColors.outline),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ),
  );
}
