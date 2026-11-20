import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_best_todo/core/database/app_database.dart';
import 'package:the_best_todo/core/theme/taskly_colors.dart';
import 'package:the_best_todo/features/category/data/category_repository.dart';
import 'package:the_best_todo/features/category/model/category_palette.dart';

/// Add or edit a category: name, one of 12 curated swatches (plus a hex
/// override), an icon picked from the Solar registry, and delete.
Future<void> showCategoryEditSheet(
  BuildContext context, {
  CategoryData? category,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: _CategoryEditSheet(category: category),
    ),
  );
}

class _CategoryEditSheet extends ConsumerStatefulWidget {
  const _CategoryEditSheet({this.category});

  final CategoryData? category;

  @override
  ConsumerState<_CategoryEditSheet> createState() => _CategoryEditSheetState();
}

class _CategoryEditSheetState extends ConsumerState<_CategoryEditSheet> {
  late final TextEditingController _name;
  late Color _color;
  late String _iconKey;
  late final bool _isEdit;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.category != null;
    _name = TextEditingController(text: widget.category?.name ?? '');
    _color = Color(widget.category?.color ?? categorySwatches.first.toARGB32());
    _iconKey = widget.category?.icon ?? categoryIconRegistry.keys.first;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<TasklyColors>()!;
    final selectedArgb = _color.toARGB32();

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEdit ? 'Edit category' : 'New category',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _name,
                    autofocus: !_isEdit,
                    maxLength: 32,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      counterText: '',
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
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(categoryIcon(_iconKey), color: _color, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Color',
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final swatch in categorySwatches)
                  _Swatch(
                    color: swatch,
                    selected: selectedArgb == swatch.toARGB32(),
                    onTap: () => setState(() => _color = swatch),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Custom hex (e.g. 5A7BD6)',
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
                isDense: true,
              ),
              onSubmitted: (value) {
                final cleaned = value.trim().replaceAll('#', '').toUpperCase();
                if (cleaned.length == 6) {
                  setState(
                    () => _color =
                        Color(int.parse('FF$cleaned', radix: 16)),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            Text('Icon',
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final entry in categoryIconRegistry.entries)
                  _IconChoice(
                    icon: entry.value,
                    selected: _iconKey == entry.key,
                    onTap: () => setState(() => _iconKey = entry.key),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (_isEdit) ...[
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: _delete,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                   '<-- delete category',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colors.textSecondary),
                  ),
                ],
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.onAccent,
                    // fixedSize: Size(_isEdit ? 72 : 96, 44),
                  ),
                  child: Text(_isEdit ? 'Save' : 'Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;

    final repo = ref.read(categoryRepositoryProvider);

    if (_isEdit) {
      await repo.update(
        CategoryData(
          id: widget.category!.id,
          name: name,
          color: _color.toARGB32(),
          icon: _iconKey,
          sortOrder: widget.category!.sortOrder,
        ),
      );
    } else {
      await repo.add(
        name: name,
        color: _color.toARGB32(),
        iconKey: _iconKey,
      );
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    await ref.read(categoryRepositoryProvider).delete(
          widget.category!.id,
        );
    if (!mounted) return;
    Navigator.pop(context);
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: selected ? Border.all(width: 2, color: Colors.white) : null,
        ),
        child: selected
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TasklyColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: selected ? colors.accent : colors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: selected ? colors.onAccent : colors.textSecondary,
        ),
      ),
    );
  }
}
