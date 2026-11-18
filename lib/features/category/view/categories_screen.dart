import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:the_best_todo/core/animation/reveal.dart';
import 'package:the_best_todo/core/theme/taskly_colors.dart';
import 'package:the_best_todo/features/category/data/category_repository.dart';
import 'package:the_best_todo/features/category/model/category_palette.dart';
import 'package:the_best_todo/features/category/view/components/category_edit_sheet.dart';
import 'package:the_best_todo/features/category/view_model/category_navigation.dart';
import 'package:the_best_todo/features/category/view_model/category_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<TasklyColors>()!;
    final categories = ref.watch(watchCategoriesProvider).value ?? [];
    final counts = ref.watch(totalCountByCategoryProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categories',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Group tasks and track them independently',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => showCategoryEditSheet(context),
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: categories.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final count = counts[category.id] ?? 0;

                      return RevealOnMount(
                        index: index.clamp(0, 8),
                        staggerMs: 45,
                        child: _CategoryRow(
                          id: category.id,
                          name: category.name,
                          color: category.color.categoryColor,
                          iconKey: category.icon,
                          count: count,
                          onTap: () =>
                              openCategoryTasks(context, ref, category.id),
                          onEdit: () =>
                              showCategoryEditSheet(context, category: category),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.55);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(SolarIconsOutline.folder, size: 28, color: muted),
            const SizedBox(height: 12),
            Text(
              'No categories yet',
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: 4),
            Text(
              'Categories group related tasks and show their share in Insights.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(height: 1.4, color: muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.id,
    required this.name,
    required this.color,
    required this.iconKey,
    required this.count,
    required this.onTap,
    required this.onEdit,
  });

  final int id;
  final String name;
  final Color color;
  final String iconKey;
  final int count;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<TasklyColors>()!;
    final countLabel = count == 1 ? '1 task' : '$count tasks';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.border, width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(categoryIcon(iconKey), size: 17, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(name, style: theme.textTheme.bodyMedium)),
            Text(
              countLabel,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  SolarIconsBold.pen,
                  size: 18,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
