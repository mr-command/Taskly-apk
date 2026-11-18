import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:the_best_todo/core/animation/reveal.dart';
import 'package:the_best_todo/core/theme/taskly_colors.dart';

class _NavItem {
  final String label;
  final IconData inactive;
  final IconData active;
  const _NavItem({
    required this.label,
    required this.inactive,
    required this.active,
  });
}

const List<_NavItem> _items = [
  _NavItem(
    label: 'Home',
    inactive: SolarIconsOutline.home,
    active: SolarIconsBold.home,
  ),
  _NavItem(
    label: 'Tasks',
    inactive: SolarIconsOutline.listCheck,
    active: SolarIconsBold.listCheck,
  ),
  _NavItem(
    label: 'Insights',
    inactive: SolarIconsOutline.chart_2,
    active: SolarIconsBold.chart_2,
  ),
  _NavItem(
    label: 'Categories',
    inactive: SolarIconsOutline.folder,
    active: SolarIconsBold.folder,
  ),
];

class TasklyNavBar extends StatelessWidget {
  const TasklyNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    required this.onQuickAdd,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<TasklyColors>()!;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: colors.border, width: 1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 8,
          right: 8,
          top: 8,
          bottom: bottomInset > 0 ? bottomInset : 8,
        ),
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              Expanded(
                child: _Tab(
                  index: 0,
                  item: _items[0],
                  selected: currentIndex == 0,
                  onSelect: onSelect,
                ),
              ),
              Expanded(
                child: _Tab(
                  index: 1,
                  item: _items[1],
                  selected: currentIndex == 1,
                  onSelect: onSelect,
                ),
              ),
              const SizedBox(width: 8),
              PressableScale(onTap: onQuickAdd, child: const _QuickAddButton()),
              const SizedBox(width: 8),
              Expanded(
                child: _Tab(
                  index: 2,
                  item: _items[2],
                  selected: currentIndex == 2,
                  onSelect: onSelect,
                ),
              ),
              Expanded(
                child: _Tab(
                  index: 3,
                  item: _items[3],
                  selected: currentIndex == 3,
                  onSelect: onSelect,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.index,
    required this.item,
    required this.selected,
    required this.onSelect,
  });

  final int index;
  final _NavItem item;
  final bool selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = theme.extension<TasklyColors>()!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelect(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? colors.surfaceMuted : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: Tween<double>(begin: 0.85, end: 1)
                    .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                selected ? item.active : item.inactive,
                key: ValueKey(selected),
                size: 22,
                color: selected ? scheme.onSurface : colors.textSecondary,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child:
                  selected
                      ? Text(
                          item.label,
                          key: ValueKey(selected),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.0,
                            color: scheme.onSurface,
                          ),
                        )
                      : const SizedBox(
                          height: 11,
                          key: ValueKey(false),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TasklyColors>()!;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        SolarIconsBold.addCircle,
        size: 30,
        color: colors.onAccent,
      ),
    );
  }
}
