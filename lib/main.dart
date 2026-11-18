import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_best_todo/core/navigation/app_shell.dart';
import 'package:the_best_todo/core/themes/app_theme.dart';
import 'package:the_best_todo/core/theme/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: TasklyApp()));
}

class TasklyApp extends ConsumerWidget {
  const TasklyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(isDarkModeProvider);

    return MaterialApp(
      title: 'Taskly',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: const AppShell(),
    );
  }
}
