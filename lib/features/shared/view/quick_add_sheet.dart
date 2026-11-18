import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_best_todo/core/theme/taskly_colors.dart';
import 'package:the_best_todo/features/category/data/category_repository.dart';
import 'package:the_best_todo/features/category/model/category_palette.dart';
import 'package:the_best_todo/features/notes/data/note_repository.dart';
import 'package:the_best_todo/features/priority/model/priority.dart';
import 'package:the_best_todo/features/tasks/data/task_repository.dart';

/// Center nav button target: one sheet, Task and Note side by side.
/// Saving a task keeps the sheet open so several can be added in a row.
Future<void> showQuickAddSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _QuickAddSheet(),
  );
}

enum _QuickAddMode { task, note }

class _QuickAddSheet extends ConsumerStatefulWidget {
  const _QuickAddSheet();

  @override
  ConsumerState<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<_QuickAddSheet> {
  _QuickAddMode _mode = _QuickAddMode.task;

  final _taskController = TextEditingController();
  final _noteTitleController = TextEditingController();
  final _noteContentController = TextEditingController();

  TaskPriority _priority = TaskPriority.medium;
  int? _categoryId;

  @override
  void dispose() {
    _taskController.dispose();
    _noteTitleController.dispose();
    _noteContentController.dispose();
    super.dispose();
  }

  void _resetTaskInputs() {
    _taskController.clear();
    _priority = TaskPriority.medium;
    _categoryId = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<TasklyColors>()!;
    final categories = ref.watch(watchCategoriesProvider).value ?? [];

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ModeOption(
                      label: 'New task',
                      selected: _mode == _QuickAddMode.task,
                      onTap: () => setState(() => _mode = _QuickAddMode.task),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _ModeOption(
                      label: 'New note',
                      selected: _mode == _QuickAddMode.note,
                      onTap: () => setState(() => _mode = _QuickAddMode.note),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_mode == _QuickAddMode.task) ...[
                TextField(
                  controller: _taskController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _saveTask(),
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    labelText: 'Task title',
                    filled: true,
                    fillColor: colors.surfaceMuted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.accent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Priority',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (final priority in TaskPriority.values) ...[
                      _PriorityDot(
                        priority: priority,
                        colors: colors,
                        selected: _priority == priority,
                        onTap: () => setState(() => _priority = priority),
                      ),
                      if (priority != TaskPriority.low) const SizedBox(width: 16),
                    ],
                    const Spacer(),
                    Text(
                      _priority.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _priority.color(theme),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Category',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _CategoryChoice(
                      label: 'No category',
                      selected: _categoryId == null,
                      colors: colors,
                      onTap: () => setState(() => _categoryId = null),
                    ),
                    for (final category in categories)
                      _CategoryChoice(
                        label: category.name,
                        dotColor: category.color.categoryColor,
                        selected: _categoryId == category.id,
                        colors: colors,
                        onTap: () =>
                            setState(() => _categoryId = category.id),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton(
                    onPressed: _saveTask,
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.accent,
                      foregroundColor: colors.onAccent,
                    ),
                    child: const Text('Add task'),
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _noteTitleController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    labelText: 'Note title',
                    filled: true,
                    fillColor: colors.surfaceMuted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.accent),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteContentController,
                  minLines: 5,
                  maxLines: 8,
                  textCapitalization: TextCapitalization.sentences,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    labelText: 'Note content',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: colors.surfaceMuted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.accent),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton(
                    onPressed: _saveNote,
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.accent,
                      foregroundColor: colors.onAccent,
                    ),
                    child: const Text('Add note'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveTask() async {
    final title = _taskController.text.trim();
    if (title.isEmpty) return;

    await ref.read(taskRepositoryProvider).add(
          title: title,
          priority: _priority,
          categoryId: _categoryId,
        );

    setState(_resetTaskInputs);
  }

  Future<void> _saveNote() async {
    final title = _noteTitleController.text.trim();
    final content = _noteContentController.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    await ref.read(noteRepositoryProvider).add(
          title: title,
          content: content,
        );
    _noteTitleController.clear();
    _noteContentController.clear();

    if (!mounted) return;
    Navigator.pop(context);
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<TasklyColors>()!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colors.accent : colors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: selected ? colors.onAccent : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  const _PriorityDot({
    required this.priority,
    required this.colors,
    required this.selected,
    required this.onTap,
  });

  final TaskPriority priority;
  final TasklyColors colors;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = priority.color(Theme.of(context));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? tint : colors.textSecondary.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? tint : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChoice extends StatelessWidget {
  const _CategoryChoice({
    required this.label,
    required this.selected,
    required this.colors,
    required this.onTap,
    this.dotColor,
  });

  final String label;
  final bool selected;
  final TasklyColors colors;
  final VoidCallback onTap;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 30,
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
          border: selected ? Border.all(color: colors.accent) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
              const SizedBox(width: 6),
            ],
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
