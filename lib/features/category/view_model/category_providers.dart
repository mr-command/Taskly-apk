import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_best_todo/features/category/data/category_repository.dart';
import 'package:the_best_todo/features/tasks/data/task_repository.dart';

/// Open (not completed) task count per category id — the number every
/// category surface shows. Uncategorized tasks have categoryId null.
final openCountByCategoryProvider = Provider<Map<int, int>>((ref) {
  final categories = ref.watch(watchCategoriesProvider).value ?? [];
  final tasks = ref.watch(watchTasksProvider).value ?? [];

  return {
    for (final category in categories)
      category.id: tasks
          .where((t) => !t.isCompleted && t.categoryId == category.id)
          .length,
  };
});

/// All-task count per category (categories screen shows this one).
final totalCountByCategoryProvider = Provider<Map<int, int>>((ref) {
  final categories = ref.watch(watchCategoriesProvider).value ?? [];
  final tasks = ref.watch(watchTasksProvider).value ?? [];

  return {
    for (final category in categories)
      category.id: tasks.where((t) => t.categoryId == category.id).length,
  };
});
