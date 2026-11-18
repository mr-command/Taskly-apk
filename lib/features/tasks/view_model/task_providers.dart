import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_best_todo/core/database/app_database.dart';
import 'package:the_best_todo/features/priority/model/priority.dart';
import 'package:the_best_todo/features/tasks/data/task_repository.dart';

/// Which slice of the list is visible on the Tasks screen.
enum TaskSegment {
  all,
  today,
  done;

  String get label => switch (this) {
        all => 'All',
        today => 'Today',
        done => 'Done',
      };
}

/// How the list is ordered within the selected segment.
enum TaskSort { priority, newest, category }

class TaskSegmentNotifier extends Notifier<TaskSegment> {
  @override
  TaskSegment build() => TaskSegment.all;

  void select(TaskSegment segment) => state = segment;
}

class TaskPriorityFilterNotifier extends Notifier<TaskPriority?> {
  @override
  TaskPriority? build() => null;

  /// Same chip tapped twice clears the filter.
  void toggle(TaskPriority priority) =>
      state = state == priority ? null : priority;

  void clear() => state = null;
}

class TaskCategoryFilterNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void set(int? categoryId) => state = categoryId;
}

class TaskSortNotifier extends Notifier<TaskSort> {
  @override
  TaskSort build() => TaskSort.priority;

  void set(TaskSort sort) => state = sort;
}

final taskSegmentProvider =
    NotifierProvider<TaskSegmentNotifier, TaskSegment>(TaskSegmentNotifier.new);

final taskPriorityFilterProvider =
    NotifierProvider<TaskPriorityFilterNotifier, TaskPriority?>(
        TaskPriorityFilterNotifier.new);

final taskCategoryFilterProvider =
    NotifierProvider<TaskCategoryFilterNotifier, int?>(
        TaskCategoryFilterNotifier.new);

final taskSortProvider =
    NotifierProvider<TaskSortNotifier, TaskSort>(TaskSortNotifier.new);

/// The single, derived list the Tasks screen renders: segment + filters +
/// sort all applied in one place so "Today", priority chips and category
/// chips can never disagree with each other.
final filteredTasksProvider = Provider<List<TaskData>>((ref) {
  final tasks = ref.watch(watchTasksProvider).value ?? [];
  final segment = ref.watch(taskSegmentProvider);
  final priority = ref.watch(taskPriorityFilterProvider);
  final categoryId = ref.watch(taskCategoryFilterProvider);
  final sort = ref.watch(taskSortProvider);

  Iterable<TaskData> result = tasks;

  result = switch (segment) {
    TaskSegment.all => result,
    TaskSegment.today => result.where((t) {
        final live = DateTime.fromMillisecondsSinceEpoch(t.createdAt);
        final now = DateTime.now();
        return live.year == now.year &&
            live.month == now.month &&
            live.day == now.day;
      }),
    TaskSegment.done => result.where((t) => t.isCompleted),
  };

  if (priority != null) {
    result = result.where(
      (t) => TaskPriority.fromIndex(t.priority) == priority,
    );
  }
  if (categoryId != null) {
    result = result.where((t) => t.categoryId == categoryId);
  }

  final list = result.toList();
  list.sort(_comparator(sort, segment));
  return list;
});

int _rankPriority(int rawPriority) => rawPriority.clamp(0, 3);

/// Open (not completed) tasks — shared by Home and Insights.
final openTasksProvider = Provider<List<TaskData>>((ref) {
  final tasks = ref.watch(watchTasksProvider).value ?? [];
  return tasks.where((t) => !t.isCompleted).toList();
});

Comparator<TaskData> _comparator(TaskSort sort, TaskSegment segment) {
  return switch (sort) {
    TaskSort.priority => (a, b) {
        final byPriority =
            _rankPriority(a.priority).compareTo(_rankPriority(b.priority));
        if (byPriority != 0) return byPriority;
        return b.createdAt.compareTo(a.createdAt);
      },
    TaskSort.newest => (a, b) => b.createdAt.compareTo(a.createdAt),
    TaskSort.category => (a, b) {
        final aId = a.categoryId ?? -1;
        final bId = b.categoryId ?? -1;
        if (aId != bId) return aId.compareTo(bId);
        final aIdx = _rankPriority(a.priority);
        final bIdx = _rankPriority(b.priority);
        if (aIdx != bIdx) return aIdx.compareTo(bIdx);
        return b.createdAt.compareTo(a.createdAt);
      },
  };
}
