import 'package:flutter/material.dart';




final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,

    primary: Color.fromARGB(255, 240, 240, 240),
    onPrimary: Color.fromARGB(255, 0, 0, 0),

    surfaceContainer: Color.fromARGB(255, 255, 255, 255),


    secondaryContainer: Color.fromARGB(255, 0, 0, 0),
    onSecondaryContainer: Color.fromARGB(255, 255, 255, 255),

    secondary: Color.fromARGB(255, 0, 0, 0),
    onSecondary: Color.fromARGB(255, 255, 255, 255),

    tertiary: Color(0xFFFF3737),
    onTertiary: Color(0xFFFFFFFF),

    error: Color(0xFFFF3737),
    onError: Color(0xFFFFFFFF),

    surface: Color(0xFF1A1A1A),
    onSurface: Color.fromARGB(255, 255, 255, 255),
  ),

  scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
);

// final lightTheme = ThemeData(
//   useMaterial3: true,
//   colorScheme: ColorScheme.fromSeed(
//     seedColor: Color(0xFF408A71)
//     )
// );

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,

    primary: Color(0xFF1A1A1A),
    onPrimary: Color.fromARGB(255, 255, 255, 255),

    surfaceContainer: Color(0xFF2A2A2A),


    secondaryContainer: Color.fromARGB(255, 0, 0, 0),
    onSecondaryContainer: Color(0xFFFF5555),

    secondary: Color(0xFFFFC193),
    onSecondary: Color(0xFF1A1A1A),

    tertiary: Color(0xFFFF3737),
    onTertiary: Color(0xFFFFFFFF),

    error: Color(0xFFFF3737),
    onError: Color(0xFFFFFFFF),

    surface: Color(0xFF2A2A2A),
    onSurface: Color(0xFFF5F5F5),

    
  ),

  scaffoldBackgroundColor: const Color(0xFF121212),
);