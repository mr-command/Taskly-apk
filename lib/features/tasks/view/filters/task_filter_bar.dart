import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:the_best_todo/core/database/app_database.dart';
import 'package:the_best_todo/core/theme/taskly_colors.dart';
import 'package:the_best_todo/features/category/data/category_repository.dart';
import 'package:the_best_todo/features/category/model/category_palette.dart';
import 'package:the_best_todo/features/priority/model/priority.dart';
import 'package:the_best_todo/features/tasks/view_model/task_providers.dart';

/// Horizontal chip row: four priority dots + a category selector.
class TaskFilterBar extends ConsumerWidget {
  const TaskFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priorityFilter = ref.watch(taskPriorityFilterProvider);
    final categoryFilter = ref.watch(taskCategoryFilterProvider);
    final categories = ref.watch(watchCategoriesProvider).value ?? [];

    final selectedCategory = categoryFilter == null
        ? null
        : categories
            .cast<CategoryData?>()
            .firstWhere(
              (c) => c!.id == categoryFilter,
              orElse: () => null,
            );

    final theme = Theme.of(context);

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final priority in TaskPriority.values)
            _PriorityChip(
              label: priority.shortLabel,
              dotColor: priority.color(theme),
              selected: priorityFilter == priority,
              onTap: () =>
                  ref.read(taskPriorityFilterProvider.notifier).toggle(priority),
            ),
          const SizedBox(width: 4),
          _CategoryChip(
            selected: selectedCategory,
            onTap: () =>
                _pickCategory(context, ref, categories, categoryFilter),
          ),
        ],
      ),
    );
  }

  void _pickCategory(
    BuildContext context,
    WidgetRef ref,
    List<CategoryData> categories,
    int? selected,
  ) {
    // -1 means "tasks with no category".
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colors = theme.extension<TasklyColors>()!;

        Widget option({
          required String label,
          required bool active,
          required VoidCallback onTap,
          IconData? icon,
          Color? dotColor,
        }) {
          return InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 44,
              child: Row(
                children: [
                  if (icon != null)
                    Icon(icon, size: 18, color: colors.textSecondary)
                  else if (dotColor != null)
                    Container(
                      width: 9,
                      height: 9,
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, color: dotColor),
                    )
                  else
                    const SizedBox(width: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
                  if (active)
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Text(
                  'Filter by category',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              option(
                label: 'All categories',
                active: selected == null,
                onTap: () => _close(sheetContext, context, ref, null),
              ),
              option(
                label: 'No category',
                active: selected == -1,
                onTap: () => _close(sheetContext, context, ref, -1),
              ),
              for (final category in categories)
                option(
                  label: category.name,
                  icon: categoryIcon(category.icon),
                  active: selected == category.id,
                  onTap: () => _close(sheetContext, context, ref, category.id),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _close(
    BuildContext sheetContext,
    BuildContext screenContext,
    WidgetRef ref,
    int? value,
  ) {
    ref.read(taskCategoryFilterProvider.notifier).set(value);
    Navigator.pop(sheetContext);
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
    required this.label,
    required this.dotColor,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color dotColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<TasklyColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
          border: selected ? Border.all(color: colors.accent) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: selected
                    ? theme.colorScheme.onSurface
                    : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.selected, required this.onTap});

  final CategoryData? selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<TasklyColors>()!;
    final category = selected;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
          border: category == null ? Border.all(color: colors.border) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (category == null) ...[
              Icon(SolarIconsOutline.folder, size: 15, color: colors.textSecondary),
              const SizedBox(width: 6),
            ] else
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: category.color.categoryColor,
                ),
              ),
            const SizedBox(width: 6),
            Text(
              category == null ? 'Category' : category.name,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
