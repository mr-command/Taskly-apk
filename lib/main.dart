import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_best_todo/core/providers.dart';
import 'package:the_best_todo/screens/TodoScreen.dart';
import 'package:the_best_todo/themes/app_theme.dart';
// import 'hive_registrar.g.dart';

void main() async {
  try{

    runApp(ProviderScope(child: MyApp()));
  }

  catch (e){
    print("failed to init app : $e");
    
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context , WidgetRef ref) {
    ThemeMode themeMode = ref.watch(isDarkModeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: Todoscreen() ,
    );
  }
}
