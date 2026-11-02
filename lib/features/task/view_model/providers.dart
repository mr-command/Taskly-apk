import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:the_best_todo/features/task/model/models.dart';
import 'package:the_best_todo/features/task/view/screens/AllTasks.dart';
import 'package:the_best_todo/features/task/view/screens/DoneTasks.dart';
import 'package:the_best_todo/features/task/view/screens/NoteScreen.dart';
import 'package:the_best_todo/features/task/view/screens/PendedTasks.dart';



final isDarkModeProvider = StateProvider<ThemeMode>(
  (ref) => ThemeMode.system
);

final dbProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// final taskListProvider = StateProvider<List<dynamic>>(
//   (ref) => []
// );

final tasksProvider = StreamProvider<List<TaskData>>((ref) {
  final db = ref.watch(dbProvider);

  return db.selectTasks();
});


final notesProvider = StreamProvider<List<NoteData>>((ref) {
  final db = ref.watch(dbProvider);

  return db.selectNotes();
});

final completedTasksProvider = Provider((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  return tasks.where((t) => t.isCompleted).toList();
});

final pendingTasksProvider = Provider((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  return tasks.where((t) => !t.isCompleted).toList();
});


final indexingScreens = StateProvider<int>(
  (ref) => 0
);

final screensListProvider = Provider(
  (ref) => [
      Pended(),
      All(),
      Done(),
      Notescreen(),
    ]
);