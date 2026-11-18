import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Kept for compatibility with the existing app shell toggle.
final isDarkModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
