import 'package:flutter/material.dart';

import 'package:the_best_todo/core/theme/taskly_colors.dart';

/// GitHub-style contribution heatmap: one column per week, one square per
/// day, shaded by how many tasks were completed that day.
class ContributionGraph extends StatefulWidget {
  const ContributionGraph({
    super.key,
    required this.completions,
    this.weeks = 53,
    this.cellSize = 11,
    this.cellGap = 3,
  });

  /// Completion counts keyed by local calendar date (time of day ignored).
  final Map<DateTime, int> completions;

  /// Number of week columns; the last column is the current week.
  final int weeks;

  final double cellSize;
  final double cellGap;

  @override
  State<ContributionGraph> createState() => _ContributionGraphState();
}

class _ContributionGraphState extends State<ContributionGraph> {
  static const _weekdayLabelWidth = 32.0;
  static const _monthRowHeight = 18.0;
  static const _weekdayLabels = ['Mon', '', 'Wed', '', 'Fri', '', ''];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToLatest());
  }

  @override
  void didUpdateWidget(covariant ContributionGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weeks != widget.weeks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToLatest());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToLatest() {
    if (!_scrollController.hasClients) return;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  DateTime _addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<TasklyColors>()!;

    final today = _dateOnly(DateTime.now());
    final thisMonday = _addDays(today, -(today.weekday - 1));
    final windowStart = _addDays(thisMonday, -(widget.weeks - 1) * 7);

    final days = List<DateTime>.generate(
      widget.weeks * 7,
      (index) => _addDays(windowStart, index),
    );

    final counts = <int>[
      for (final day in days)
        day.isAfter(today) ? 0 : (widget.completions[day] ?? 0),
    ];

    var total = 0;
    var maxCount = 0;
    for (var i = 0; i < days.length; i++) {
      if (days[i].isAfter(today)) continue;
      total += counts[i];
      if (counts[i] > maxCount) maxCount = counts[i];
    }

    final levelColors = _levelColors(colors);
    final step = widget.cellSize + widget.cellGap;
    final monthLabels = _monthLabels(windowStart, days);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _totalLabel(total),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: _weekdayLabelWidth + widget.weeks * step,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: _weekdayLabelWidth),
                    ..._buildMonthLabels(theme, colors, monthLabels, step),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWeekdayLabels(theme, colors, step),
                    for (var week = 0; week < widget.weeks; week++)
                      Column(
                        children: [
                          for (var row = 0; row < 7; row++)
                            _buildDayCell(
                              date: days[week * 7 + row],
                              count: counts[week * 7 + row],
                              isFuture: days[week * 7 + row].isAfter(today),
                              maxCount: maxCount,
                              levelColors: levelColors,
                              step: step,
                            ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Less',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            for (final color in levelColors)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _LegendSquare(color: color),
              ),
            const SizedBox(width: 4),
            Text(
              'More',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Color> _levelColors(TasklyColors colors) {
    final empty = colors.surfaceMuted;
    return [
      empty,
      Color.lerp(empty, colors.accent, 0.30)!,
      Color.lerp(empty, colors.accent, 0.55)!,
      Color.lerp(empty, colors.accent, 0.78)!,
      colors.accent,
    ];
  }

  int _levelFor(int count) {
    if(count <= 0) return 0;
    if(count <= 1) return 1;
    if(count <= 2) return 2;
    if(count <= 3) return 3;

    return 4;
  }
  /// Weeks that start a new month, paired with the width they can occupy
  /// before the next label so labels never overlap.
  List<_MonthLabel> _monthLabels(DateTime windowStart, List<DateTime> days) {
    final starts = <int, DateTime>{};
    for (var week = 0; week < widget.weeks; week++) {
      for (var row = 0; row < 7; row++) {
        final date = days[week * 7 + row];
        if (date.day == 1) {
          starts[week] = date;
          break;
        }
      }
    }

    // Label the first visible week too, but only when the first real month
    // boundary is far enough away for the labels not to collide.
    if (!starts.containsKey(0)) {
      final firstBoundary = starts.keys.isEmpty
          ? widget.weeks
          : starts.keys.reduce((a, b) => a < b ? a : b);
      if (firstBoundary >= 3) starts[0] = windowStart;
    }

    final columns = starts.keys.toList()..sort();
    return [
      for (var i = 0; i < columns.length; i++)
        _MonthLabel(
          column: columns[i],
          endColumn: i + 1 < columns.length ? columns[i + 1] : widget.weeks,
          date: starts[columns[i]]!,
        ),
    ];
  }

  List<Widget> _buildMonthLabels(
    ThemeData theme,
    TasklyColors colors,
    List<_MonthLabel> labels,
    double step,
  ) {
    return [
      if (labels.isNotEmpty && labels.first.column > 0)
        SizedBox(width: labels.first.column * step, height: _monthRowHeight),
      for (final label in labels)
        SizedBox(
          width: (label.endColumn - label.column) * step,
          height: _monthRowHeight,
          child: Text(
            _monthName(label.date.month),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              color: colors.textSecondary,
            ),
          ),
        ),
    ];
  }

  Widget _buildWeekdayLabels(
    ThemeData theme,
    TasklyColors colors,
    double step,
  ) {
    return SizedBox(
      width: _weekdayLabelWidth,
      child: Column(
        children: [
          for (var row = 0; row < 7; row++)
            SizedBox(
              height: step,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _weekdayLabels[row],
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayCell({
    required DateTime date,
    required int count,
    required bool isFuture,
    required int maxCount,
    required List<Color> levelColors,
    required double step,
  }) {
    if (isFuture) {
      return SizedBox(width: step, height: step);
    }

    final level = _levelFor(count);

    return SizedBox(
      width: step,
      height: step,
      child: Padding(
        padding: EdgeInsets.only(right: widget.cellGap, bottom: widget.cellGap),
        child: Tooltip(
          message: _tooltip(count, date),
          waitDuration: const Duration(milliseconds: 250),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: levelColors[level],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
        ),
      ),
    );
  }

  String _totalLabel(int total) {
    final range = widget.weeks >= 52
        ? 'the last year'
        : widget.weeks == 1
        ? 'the last week'
        : 'the last ${widget.weeks} weeks';
    final noun = total == 1 ? 'completion' : 'completions';
    return '$total $noun in $range';
  }

  String _tooltip(int count, DateTime date) {
    final label =
        '${_weekdayName(date.weekday)}, '
        '${_monthName(date.month)} ${date.day}, ${date.year}';
    if (count == 0) return 'No tasks completed on $label';
    if (count == 1) return '1 task completed on $label';
    return '$count tasks completed on $label';
  }

  String _monthName(int month) {
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
    return months[month - 1];
  }

  String _weekdayName(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[weekday - 1];
  }
}

class _MonthLabel {
  const _MonthLabel({
    required this.column,
    required this.endColumn,
    required this.date,
  });

  final int column;
  final int endColumn;
  final DateTime date;
}

class _LegendSquare extends StatelessWidget {
  const _LegendSquare({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
