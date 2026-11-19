import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_best_todo/features/category/data/category_repository.dart';
import 'package:the_best_todo/features/tasks/data/task_repository.dart';
import 'package:the_best_todo/features/tasks/view_model/task_providers.dart';

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

/// A bucket of completions for one calendar day.
class DayBucket {
  const DayBucket({required this.day, required this.count});
  final DateTime day;
  final int count;
}

/// (completedThisWeek, createdThisWeek, percentCompleted)
final weeklyProgressProvider = Provider<(int, int, int)>((ref) {
  final now = DateTime.now();
  final weekStart = _startOfDay(now.subtract(const Duration(days: 6)));

  final tasks = ref.watch(watchTasksProvider).value ?? [];
  final createdThisWeek = tasks
      .where(
        (t) =>
            DateTime.fromMillisecondsSinceEpoch(t.createdAt).isAfter(weekStart),
      )
      .length;
  final completedThisWeek = tasks
      .where(
        (t) =>
            t.completedAt != null &&
            DateTime.fromMillisecondsSinceEpoch(
              t.completedAt!,
            ).isAfter(weekStart),
      )
      .length;

  final percent = createdThisWeek == 0
      ? 0
      : (completedThisWeek * 100 / createdThisWeek).round();

  return (completedThisWeek, createdThisWeek, percent);
});

/// Every day that has at least one completed task, keyed by local date.
/// Backed by the task stream, so completing a task immediately lights up
/// its square in the contribution graph.
final completionHeatmapProvider = Provider<Map<DateTime, int>>((ref) {
  final tasks = ref.watch(watchTasksProvider).value ?? [];
  final counts = <DateTime, int>{};

  for (final task in tasks) {
    if (task.completedAt == null) continue;
    final day = _startOfDay(
      DateTime.fromMillisecondsSinceEpoch(task.completedAt!),
    );
    counts[day] = (counts[day] ?? 0) + 1;
  }

  return counts;
});

/// Completions grouped per day for the last 7 days (oldest first).
final dailyCompletionsProvider = Provider<List<DayBucket>>((ref) {
  final tasks = ref.watch(watchTasksProvider).value ?? [];
  final today = _startOfDay(DateTime.now());

  final buckets = [
    for (var i = 6; i >= 0; i--)
      DayBucket(day: today.subtract(Duration(days: i)), count: 0),
  ];

  for (final task in tasks) {
    if (task.completedAt == null) continue;
    final day = _startOfDay(
      DateTime.fromMillisecondsSinceEpoch(task.completedAt!),
    );
    final index = day.difference(today).inDays;
    if (index < -6 || index > 0) continue;
    buckets[index + 6] = DayBucket(
      day: buckets[index + 6].day,
      count: buckets[index + 6].count + 1,
    );
  }

  return buckets;
});

/// Completion delta: this week's completions minus last week's.
final weeklyTrendDeltaProvider = Provider<int>((ref) {
  final buckets = ref.watch(dailyCompletionsProvider);
  final thisWeek = buckets.fold<int>(0, (sum, b) => sum + b.count);

  final tasks = ref.watch(watchTasksProvider).value ?? [];
  final lastWeekStart = _startOfDay(
    DateTime.now().subtract(const Duration(days: 13)),
  );
  final lastWeekEnd = lastWeekStart.add(const Duration(days: 6, hours: 23));
  final lastWeek = tasks.where((t) {
    if (t.completedAt == null) return false;
    final d = DateTime.fromMillisecondsSinceEpoch(t.completedAt!);
    return d.isAfter(lastWeekStart) && d.isBefore(lastWeekEnd);
  }).length;

  return thisWeek - lastWeek;
});

/// (id, name, color, openCount) sorted descending, only used categories.
final categoryDistributionProvider = Provider<List<(int, String, int, int)>>((
  ref,
) {
  final categories = ref.watch(watchCategoriesProvider).value ?? [];
  final open = ref.watch(openTasksProvider);

  final rows = <(int, String, int, int)>[
    for (final category in categories)
      if (open.where((t) => t.categoryId == category.id).isNotEmpty)
        (
          category.id,
          category.name,
          category.color,
          open.where((t) => t.categoryId == category.id).length,
        ),
  ];

  rows.sort((a, b) => b.$4.compareTo(a.$4));
  return rows;
});

/// (completed, open) lifetime totals.
final statusTotalsProvider = Provider<(int, int)>((ref) {
  final tasks = ref.watch(watchTasksProvider).value ?? [];
  final completed = tasks.where((t) => t.isCompleted).length;
  return (completed, tasks.length - completed);
});
