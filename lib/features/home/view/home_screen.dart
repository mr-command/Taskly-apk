import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:the_best_todo/core/animation/reveal.dart';
import 'package:the_best_todo/core/database/app_database.dart';
import 'package:the_best_todo/core/navigation/nav_state.dart';
import 'package:the_best_todo/core/theme/taskly_colors.dart';
import 'package:the_best_todo/core/theme/theme_provider.dart';
import 'package:the_best_todo/features/category/data/category_repository.dart';
import 'package:the_best_todo/features/category/model/category_palette.dart';
import 'package:the_best_todo/features/category/view_model/category_navigation.dart';
import 'package:the_best_todo/features/category/view_model/category_providers.dart';
import 'package:the_best_todo/features/home/view_model/home_providers.dart';
import 'package:the_best_todo/features/notes/view/components/note_views.dart';
import 'package:the_best_todo/features/priority/model/priority.dart';
import 'package:the_best_todo/features/tasks/data/task_repository.dart';
import 'package:the_best_todo/features/tasks/view/components/priority_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (completed, total) = ref.watch(overallProgressProvider);
    final percent = total == 0 ? 0 : (completed * 100 / total).round();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 0, 24),
        children: [
          const _Header(),
          const SizedBox(height: 16),
          RevealOnMount(
            index: 0,
            child: _OverviewSection(
              completed: completed,
              total: total,
              percent: percent,
            ),
          ),
          const SizedBox(height: 20),
          const RevealOnMount(index: 1, child: _AttentionSection()),
          const SizedBox(height: 16),
          const RevealOnMount(index: 2, child: _CategoryStrip()),
          const SizedBox(height: 16),
          const RevealOnMount(index: 3, child: _NotesBand()),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<TasklyColors>()!;
    final themeMode = ref.read(isDarkModeProvider);

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Taskly',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${greetingForNow()}  ·  ${_dateLine()}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () => _toggleTheme(ref),
            icon: Icon(
              themeMode == ThemeMode.light
              ? SolarIconsOutline.moon
              : SolarIconsBold.sun,
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleTheme(WidgetRef ref) {
    final themeMode = ref.read(isDarkModeProvider);
    ref.read(isDarkModeProvider.notifier).state =
        themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  String _dateLine() {
    final now = DateTime.now();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

class _OverviewSection extends ConsumerWidget {
  const _OverviewSection({
    required this.completed,
    required this.total,
    required this.percent,
  });

  final int completed;
  final int total;
  final int percent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<TasklyColors>()!;
    final weekDone = ref.watch(weekCompletionsProvider);

    return Container(
      // width: MediaQuery.widthOf(context) * 0.8,
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.only(right:16),
      decoration: BoxDecoration(
        color: colors.onAccent,
        // border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [

          BoxShadow(blurRadius: 20,color: colors.accent.withAlpha(15),spreadRadius: 5)
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Overview',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(" $percent%", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: percent / 100),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 4,
                  backgroundColor: colors.surfaceMuted,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                  borderRadius: BorderRadius.circular(2),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  total == 0
                      ? 'Add your first task to begin'
                      : '$completed completed · $total tasks in total',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colors.textSecondary),
                ),
              ),
            ],
          ),
          if (total != 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        SolarIconsOutline.calendar,
                        size: 13,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        weekDone == 1 ? '1 done this week' : '$weekDone done this week',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => ref.read(selectedTabProvider.notifier).select(2),
                  icon: Icon(
                    SolarIconsOutline.chart_2,
                    size: 15,
                    color: colors.textSecondary,
                  ),
                  label: const Text('Insights'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AttentionSection extends ConsumerWidget {
  const _AttentionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final urgent = ref.watch(importantTasksProvider);

    if (urgent.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Needs attention',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(selectedTabProvider.notifier).select(1),
                child: const Text('All'),
              ),
            ],
          ),
        ),
        for (final task in urgent)
          Padding(
            padding: const EdgeInsets.only(bottom: 6, right: 16),
            child: _AttentionRow(task: task),
          ),
      ],
    );
  }
}

class _AttentionRow extends ConsumerStatefulWidget {
  const _AttentionRow({required this.task});

  final TaskData task;

  @override
  ConsumerState<_AttentionRow> createState() => _AttentionRowState();
}

class _AttentionRowState extends ConsumerState<_AttentionRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<TasklyColors>()!;
    final task = widget.task;
    final priority = TaskPriority.fromIndex(task.priority);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: _pressed ? 0.7 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ref
            .read(taskRepositoryProvider)
            .toggleComplete(task, value: true),
        onLongPress: () => showTaskActionsSheet(context, ref, task),
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            
            color: colors.onAccent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [

          BoxShadow(blurRadius: 20,color: colors.accent.withAlpha(5),spreadRadius: 0)
        ]
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                VerticalDivider(
                  width: 3,
                  thickness: 3,
                  color: priority.color(theme),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: priority.color(theme),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            priority.shortLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: priority.color(theme),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  SolarIconsOutline.checkCircle,
                  size: 20,
                  color: colors.priorityLow,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryStrip extends ConsumerWidget {
  const _CategoryStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<TasklyColors>()!;
    final categories = ref.watch(watchCategoriesProvider).value ?? [];
    final counts = ref.watch(openCountByCategoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Categories',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(selectedTabProvider.notifier).select(3),
                child: const Text('All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 16),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              final tint = category.color.categoryColor;
              final open = counts[category.id] ?? 0;

              return PressableScale(
                onTap: () => openCategoryTasks(context, ref, category.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(categoryIcon(category.icon), size: 18, color: tint),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            open == 1 ? '1 open task' : '$open open tasks',
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NotesBand extends ConsumerWidget {
  const _NotesBand();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<TasklyColors>()!;
    final notes = ref.watch(recentNotesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            'Notes',
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        if (notes.isEmpty)
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: double.maxFinite,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'No notes yet — use the + button in the bottom bar.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colors.textSecondary),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 16),
              itemCount: notes.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) =>
                  NoteCardCompact(note: notes[index]),
            ),
          ),
      ],
    );
  }
}
