import 'package:flutter/material.dart';
import 'package:the_best_todo/core/theme/taskly_colors.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF111111),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF6E6E73),
    onSecondary: Color(0xFFFFFFFF),
    tertiary: Color(0xFFFF3737),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFFF3737),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF111111),
    surfaceContainer: Color(0xFFF5F5F5),
    outline: Color(0xFFE8E8E8),
  ),
  scaffoldBackgroundColor: const Color(0xFFFFFFFF),
  extensions: const [tasklyColorsLight],
);

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFF5F5F5),
    onPrimary: Color(0xFF111111),
    secondary: Color(0xFF9E9EA6),
    onSecondary: Color(0xFF111111),
    tertiary: Color(0xFFFF3737),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFFF3737),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFF1E1E1E),
    onSurface: Color(0xFFF5F5F5),
    surfaceContainer: Color(0xFF232323),
    outline: Color(0xFF2C2C2C),
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  extensions: const [tasklyColorsDark],
);
