import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:the_best_todo/core/database/app_database.dart';
import 'package:the_best_todo/core/theme/taskly_colors.dart';
import 'package:the_best_todo/features/category/data/category_repository.dart';
import 'package:the_best_todo/features/category/model/category_palette.dart';
import 'package:the_best_todo/features/priority/model/priority.dart';
import 'package:the_best_todo/features/tasks/data/task_repository.dart';
import 'package:the_best_todo/features/tasks/view/components/priority_sheet.dart';

/// One task row: 3px priority rail, completion control, title,
/// category chip and a flag button that opens the priority sheet.
/// Swipe right to complete, left to delete.
class TaskCard extends ConsumerWidget {
  const TaskCard({super.key, required this.task});

  final TaskData task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<TasklyColors>()!;
    final priority = TaskPriority.fromIndex(task.priority);
    final categories = ref.watch(watchCategoriesProvider).value ?? [];
    final repo = ref.read(taskRepositoryProvider);

    final category = task.categoryId == null
        ? null
        : categories
            .cast<CategoryData?>()
            .firstWhere(
              (c) => c!.id == task.categoryId,
              orElse: () => null,
            );

    final done = task.isCompleted;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          repo.toggleComplete(task, value: true);
        } else {
          repo.delete(task.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task deleted')),
          );
        }
      },
      background: const _SwipeBackground.filled(
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: const _SwipeBackground.danger(
        alignment: Alignment.centerRight,
      ),
      child: InkWell(
        onLongPress: () => showTaskActionsSheet(context, ref, task),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.border, width: 1),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Animated priority rail: recolours at 180ms when the
                // priority or completion state changes.
                AnimatedContainer(
                  width: 3,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  color: done ? colors.priorityLow : priority.color(theme),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
                    child: Row(
                      children: [
                        _CompletionCircle(
                          done: done,
                          colors: colors,
                          onToggle: () => repo.toggleComplete(task),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                style: (theme.textTheme.bodyMedium ??
                                        const TextStyle(fontSize: 14))
                                    .copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14),
                                  color: done ? colors.textSecondary : theme.colorScheme.onSurface,
                                  decoration:
                                      done ? TextDecoration.lineThrough : TextDecoration.none,
                                  decorationColor: colors.textSecondary,
                                ),
                                child: Text(
                                  task.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (category != null) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
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
                                      category.name,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                              color: colors.textSecondary),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _FlagButton(
                          onTap: () =>
                              showTaskActionsSheet(context, ref, task),
                          tint:
                              done ? colors.priorityLow : priority.color(theme),
                          label: done ? null : priority.shortLabel,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletionCircle extends StatelessWidget {
  const _CompletionCircle({
    required this.done,
    required this.colors,
    required this.onToggle,
  });

  final bool done;
  final TasklyColors colors;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: Tween<double>(begin: 0.75, end: 1)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: done
            ? Icon(
                SolarIconsBold.checkCircle,
                key: const ValueKey('done'),
                size: 20,
                color: colors.accent,
              )
            : Container(
                key: const ValueKey('open'),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.textSecondary.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
              ),
      ),
    );
  }
}

class _FlagButton extends StatelessWidget {
  const _FlagButton({
    required this.onTap,
    required this.tint,
    required this.label,
  });

  final VoidCallback onTap;
  final Color tint;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            if (label != null) ...[
              Text(
                label!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: tint, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 4),
            ],
            Icon(SolarIconsOutline.flag, size: 17, color: tint),
          ],
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground.filled({required this.alignment})
      : isDanger = false,
        color = null;

  const _SwipeBackground.danger({required this.alignment})
      : isDanger = true,
        color = null;

  final Alignment alignment;
  final bool isDanger;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<TasklyColors>()!;
    final background = isDanger ? theme.colorScheme.error : colors.accent;

    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: background,
      child: isDanger
          ? Icon(
              SolarIconsBold.trashBinTrash,
              size: 20,
              color: theme.colorScheme.onError,
            )
          : CustomPaint(
              size: const Size(20, 20),
              painter: _CheckMarkPainter(
                color: colors.onAccent,
                strokeWidth: 2.2,
              ),
            ),
    );
  }
}

/// A plain check glyph so the completion gesture does not introduce a
/// second icon style.
class _CheckMarkPainter extends CustomPainter {
  const _CheckMarkPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.55)
      ..lineTo(size.width * 0.42, size.height * 0.78)
      ..lineTo(size.width * 0.84, size.height * 0.25);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
