import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_best_todo/core/database/app_database.dart';
import 'package:the_best_todo/features/category/view_model/category_providers.dart';
import 'package:the_best_todo/features/notes/data/note_repository.dart';
import 'package:the_best_todo/features/tasks/data/task_repository.dart';
import 'package:the_best_todo/features/tasks/view_model/task_providers.dart';

/// (completed, total) across all tracked tasks.
final overallProgressProvider = Provider<(int, int)>((ref) {
  final tasks = ref.watch(watchTasksProvider).value ?? [];
  final completed = tasks.where((t) => t.isCompleted).length;
  return (completed, tasks.length);
});

/// Open Critical / High tasks — the Home "Needs attention" section.
/// Most urgent first, newest first inside a level, capped to 3 rows.
final importantTasksProvider = Provider<List<TaskData>>((ref) {
  final open = ref.watch(openTasksProvider);

  final urgent =
      open.where((t) => t.priority <= 1).toList()
        ..sort((a, b) {
          final byPriority = a.priority.compareTo(b.priority);
          if (byPriority != 0) return byPriority;
          return b.createdAt.compareTo(a.createdAt);
        });

  return urgent.take(3).toList();
});

/// Notes, newest first (ids grow with inserts).
final recentNotesProvider = Provider<List<NoteData>>((ref) {
  final notes = ref.watch(watchNotesProvider).value ?? [];
  return [...notes]..sort((a, b) => b.id.compareTo(a.id));
});

/// Completions across the last 7 days (for the Home overview chip).
final weekCompletionsProvider = Provider<int>((ref) {
  final tasks = ref.watch(watchTasksProvider).value ?? [];
  final cutoff = DateTime.now().subtract(const Duration(days: 6));
  final start = DateTime(cutoff.year, cutoff.month, cutoff.day);

  return tasks
      .where(
        (t) =>
            t.completedAt != null &&
            DateTime.fromMillisecondsSinceEpoch(t.completedAt!).isAfter(start),
      )
      .length;
});

String greetingForNow() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

/// Open count per category for the Home strip (re-exported for brevity at
/// the call sites).
final homeCategoryStripProvider = openCountByCategoryProvider;
