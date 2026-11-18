import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_best_todo/core/navigation/nav_state.dart';
import 'package:the_best_todo/features/tasks/view_model/task_providers.dart';

/// Navigates to the Tasks tab pre-filtered to one category.
void openCategoryTasks(BuildContext context, WidgetRef ref, int categoryId) {
  ref
      .read(taskCategoryFilterProvider.notifier)
      .set(categoryId);
  ref.read(selectedTabProvider.notifier).select(1);
}
