import 'package:flutter/material.dart';
import 'package:the_best_todo/core/theme/taskly_colors.dart';

/// Priority levels, stored as this enum's index (0..3).
enum TaskPriority {
  critical,
  high,
  medium,
  low;

  String get label => switch (this) {
        critical => 'Critical',
        high => 'High',
        medium => 'Medium',
        low => 'Low',
      };

  String get shortLabel => switch (this) {
        critical => 'Critical',
        high => 'High',
        medium => 'Med',
        low => 'Low',
      };

  /// Low priority deliberately uses a neutral gray from the active theme so
  /// it never visually competes with the three urgent levels.
  Color color(ThemeData theme) {
    final taskly = theme.extension<TasklyColors>()!;
    return switch (this) {
      TaskPriority.critical => taskly.priorityCritical,
      TaskPriority.high => taskly.priorityHigh,
      TaskPriority.medium => taskly.priorityMedium,
      TaskPriority.low => taskly.priorityLow,
    };
  }

  static TaskPriority fromIndex(int index) {
    final clamped = index.clamp(0, TaskPriority.values.length - 1);
    return TaskPriority.values[clamped];
  }
}
