import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_best_todo/core/navigation/nav_state.dart';
import 'package:the_best_todo/core/navigation/taskly_nav_bar.dart';
import 'package:the_best_todo/features/analytics/view/insights_screen.dart';
import 'package:the_best_todo/features/category/view/categories_screen.dart';
import 'package:the_best_todo/features/home/view/home_screen.dart';
import 'package:the_best_todo/features/shared/view/quick_add_sheet.dart';
import 'package:the_best_todo/features/tasks/view/tasks_screen.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(selectedTabProvider);

    final screens = [
      const HomeScreen(),
      const TasksScreen(),
      const InsightsScreen(),
      const CategoriesScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [
          for (var i = 0; i < screens.length; i++)
            _TabFade(active: i == index, child: screens[i]),
        ],
      ),
      bottomNavigationBar: TasklyNavBar(
        currentIndex: index,
        onSelect: ref.read(selectedTabProvider.notifier).select,
        onQuickAdd: () => showQuickAddSheet(context),
      ),
    );
  }
}

/// Keeps every tab alive (state, scroll position) while cross-fading the
/// visible one. Hidden tabs ignore pointer events.
class _TabFade extends StatelessWidget {
  const _TabFade({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !active,
      child: AnimatedOpacity(
        opacity: active ? 1 : 0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }
}
