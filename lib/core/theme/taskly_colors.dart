import 'package:flutter/material.dart';

/// Taskly semantic tokens that Material's ColorScheme doesn't cover:
/// the interactive accent, hairline borders, muted surfaces and the
/// fixed priority hues. Registered on both themes via ThemeData.defaults.
class TasklyColors extends ThemeExtension<TasklyColors> {
  const TasklyColors({
    required this.accent,
    required this.onAccent,
    required this.border,
    required this.surfaceMuted,
    required this.textSecondary,
    required this.priorityCritical,
    required this.priorityHigh,
    required this.priorityMedium,
    required this.priorityLow,
  });

  /// Interactive accent: filled buttons, active nav, selected segments.
  /// Near-black in light theme, near-white in dark theme — the app keeps
  /// its monochrome identity and lets urgency colors mean urgency only.
  final Color accent;
  final Color onAccent;

  /// 1px hairline for cards, dividers, nav bar top edge.
  final Color border;

  /// Chip / segmented-control / strip backgrounds.
  final Color surfaceMuted;

  /// Secondary text (counts, timestamps, inactive labels).
  final Color textSecondary;

  final Color priorityCritical;
  final Color priorityHigh;
  final Color priorityMedium;
  final Color priorityLow;

  @override
  TasklyColors copyWith({
    Color? accent,
    Color? onAccent,
    Color? border,
    Color? surfaceMuted,
    Color? textSecondary,
    Color? priorityCritical,
    Color? priorityHigh,
    Color? priorityMedium,
    Color? priorityLow,
  }) {
    return TasklyColors(
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      border: border ?? this.border,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      textSecondary: textSecondary ?? this.textSecondary,
      priorityCritical: priorityCritical ?? this.priorityCritical,
      priorityHigh: priorityHigh ?? this.priorityHigh,
      priorityMedium: priorityMedium ?? this.priorityMedium,
      priorityLow: priorityLow ?? this.priorityLow,
    );
  }

  @override
  TasklyColors lerp(ThemeExtension<TasklyColors>? other, double t) {
    if (other is! TasklyColors) return this;
    return TasklyColors(
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      border: Color.lerp(border, other.border, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      priorityCritical:
          Color.lerp(priorityCritical, other.priorityCritical, t)!,
      priorityHigh: Color.lerp(priorityHigh, other.priorityHigh, t)!,
      priorityMedium: Color.lerp(priorityMedium, other.priorityMedium, t)!,
      priorityLow: Color.lerp(priorityLow, other.priorityLow, t)!,
    );
  }
}

const TasklyColors tasklyColorsLight = TasklyColors(
  accent: Color(0xFF111111),
  onAccent: Color(0xFFFFFFFF),
  border: Color(0xFFE8E8E8),
  surfaceMuted: Color(0xFFF5F5F5),
  textSecondary: Color(0xFF6E6E73),
  priorityCritical: Color(0xFFFF3737),
  priorityHigh: Color(0xFFE8853D),
  priorityMedium: Color(0xFFD9B23A),
  priorityLow: Color(0xFFC2C2C6),
);

const TasklyColors tasklyColorsDark = TasklyColors(
  accent: Color(0xFFF5F5F5),
  onAccent: Color(0xFF111111),
  border: Color(0xFF2C2C2C),
  surfaceMuted: Color(0xFF232323),
  textSecondary: Color(0xFF9E9EA6),
  priorityCritical: Color(0xFFFF3737),
  priorityHigh: Color(0xFFE8853D),
  priorityMedium: Color(0xFFD9B23A),
  priorityLow: Color(0xFF55555C),
);
