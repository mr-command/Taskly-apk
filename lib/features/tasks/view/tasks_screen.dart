import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:the_best_todo/core/animation/reveal.dart';
import 'package:the_best_todo/core/theme/taskly_colors.dart';
import 'package:the_best_todo/features/tasks/data/task_repository.dart';
import 'package:the_best_todo/features/tasks/view/components/task_card.dart';
import 'package:the_best_todo/features/tasks/view/filters/task_filter_bar.dart';
import 'package:the_best_todo/features/tasks/view_model/task_providers.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<TasklyColors>()!;
    final tasks = ref.watch(filteredTasksProvider);
    final allTasksCount = (ref.watch(watchTasksProvider).value ?? []).length;
    final sort = ref.watch(taskSortProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tasks',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        allTasksCount == 1
                            ? '1 task in total'
                            : '$allTasksCount tasks in total',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<TaskSort>(
                  tooltip: 'Sort',
                  initialValue: sort,
                  icon: Icon(
                    SolarIconsOutline.sortFromTopToBottom,
                    size: 20,
                    color: theme.colorScheme.onSurface,
                  ),
                  onSelected: (value) =>
                      ref.read(taskSortProvider.notifier).set(value),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                        value: TaskSort.priority, child: Text('Sort by priority')),
                    PopupMenuItem(
                        value: TaskSort.newest, child: Text('Sort by date')),
                    PopupMenuItem(
                        value: TaskSort.category, child: Text('Sort by category')),
                  ],
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _SegmentedControl(),
          const SizedBox(height: 8),
          const TaskFilterBar(),
          const SizedBox(height: 4),
          Expanded(
            child: tasks.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 24),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) => RevealOnMount(
                      index: index.clamp(0, 8),
                      staggerMs: 45,
                      child: TaskCard(task: tasks[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedControl extends ConsumerWidget {
  const _SegmentedControl();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<TasklyColors>()!;
    final current = ref.watch(taskSegmentProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final segment in TaskSegment.values) ...[
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => ref.read(taskSegmentProvider.notifier).select(segment),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: current == segment ? colors.accent : colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    segment.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: current == segment
                          ? colors.onAccent
                          : colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            if (segment != TaskSegment.values.last) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<TasklyColors>()!;
    final segment = ref.watch(taskSegmentProvider);
    final priorityFilter = ref.watch(taskPriorityFilterProvider);
    final categoryFilter = ref.watch(taskCategoryFilterProvider);
    final filtersActive = priorityFilter != null || categoryFilter != null;

    final message = segment == TaskSegment.done
        ? 'No completed tasks yet'
        : segment == TaskSegment.today
            ? 'Nothing added today'
            : 'No tasks yet';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              SolarIconsOutline.listCheck,
              size: 28,
              color: colors.textSecondary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            if (filtersActive) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  ref.read(taskPriorityFilterProvider.notifier).clear();
                  ref.read(taskCategoryFilterProvider.notifier).set(null);
                },
                icon: Icon(
                  SolarIconsOutline.closeCircle,
                  size: 16,
                  color: colors.textSecondary,
                ),
                label: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
