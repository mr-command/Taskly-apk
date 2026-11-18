import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_best_todo/core/database/app_database.dart';
import 'package:the_best_todo/core/theme/taskly_colors.dart';
import 'package:the_best_todo/features/notes/data/note_repository.dart';

/// A note tile on the Home notes band.
class NoteCardCompact extends ConsumerWidget {
  const NoteCardCompact({super.key, required this.note});

  final NoteData note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<TasklyColors>()!;

    return GestureDetector(
      onTap: () => showNoteDetailSheet(context, note),
      child: Container(
        width: 168,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                note.content,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colors.textSecondary, height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Read + delete for an existing note (editing notes is intentionally
/// scoped out; notes are short-form, write-once content).
Future<void> showNoteDetailSheet(BuildContext context, NoteData note) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _NoteDetailSheet(note: note),
  );
}

class _NoteDetailSheet extends ConsumerWidget {
  const _NoteDetailSheet({required this.note});

  final NoteData note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              note.content,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () async {
                    await ref.read(noteRepositoryProvider).delete(
                          note.id,
                        );
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: theme.colorScheme.error,
                  ),
                  label: Text(
                    'Delete',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
