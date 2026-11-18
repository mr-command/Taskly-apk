import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_best_todo/core/database/app_database.dart';
import 'package:the_best_todo/features/priority/model/priority.dart';
import 'package:the_best_todo/features/tasks/data/task_repository.dart';

/// Quick actions on a single task: priority (one tap), rename, delete.
/// Opened by tapping the flag on the card or long-pressing the card.
Future<void> showTaskActionsSheet(
  BuildContext context,
  WidgetRef ref,
  TaskData task,
) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) => _TaskActionsSheet(task: task),
  );
}

class _TaskActionsSheet extends ConsumerWidget {
  const _TaskActionsSheet({required this.task});

  final TaskData task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final current = TaskPriority.fromIndex(task.priority);
    final repo = ref.read(taskRepositoryProvider);

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text(
              task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          for (final priority in TaskPriority.values)
            _PriorityRow(
              label: priority.label,
              dotColor: priority.color(theme),
              selected: current == priority,
              onTap: () async {
                await repo.setPriority(task, priority);
                if (context.mounted) Navigator.pop(context);
              },
            ),
          const Divider(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton.icon(
                    onPressed: () => _rename(context),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Rename task'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton.icon(
                    onPressed: () async {
                      await repo.delete(task.id);
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: theme.colorScheme.error,
                    ),
                    label: Text(
                      'Delete task',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    style: TextButton.styleFrom(
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _rename(BuildContext context) {
    final theme = Theme.of(context);
    final repo = task;
    final controller = TextEditingController(text: task.title);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Rename task', style: theme.textTheme.titleMedium),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final newTitle = controller.text.trim();
                if (newTitle.isNotEmpty && newTitle != repo.title) {
                  final ref = ProviderScope.containerOf(dialogContext);
                  await ref.read(taskRepositoryProvider).setTitle(
                        task.id,
                        newTitle,
                      );
                }
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _PriorityRow extends StatelessWidget {
  const _PriorityRow({
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: onTap,
              icon: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              label: Text(
                label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface,
                minimumSize: const Size(0, 44),
              ),
            ),
          ),
          if (selected)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
