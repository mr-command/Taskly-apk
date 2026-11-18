import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_best_todo/core/theme/taskly_colors.dart';
import 'package:the_best_todo/core/animation/reveal.dart';
import 'package:the_best_todo/features/analytics/view_model/analytics_providers.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<TasklyColors>()!;
    final (completed, created, percent) = ref.watch(weeklyProgressProvider);
    final buckets = ref.watch(dailyCompletionsProvider);
    final trend = ref.watch(weeklyTrendDeltaProvider);
    final distribution = ref.watch(categoryDistributionProvider);
    final (doneTotal, openTotal) = ref.watch(statusTotalsProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          Text(
            'Insights',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Real numbers from your tasks — nothing estimated',
            style: theme.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 20),
          // RevealOnMount(
          //   index: 0,
          //   child: _InsightCard(
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text(
          //           'This week',
          //           style: theme.textTheme.bodySmall
          //               ?.copyWith(fontWeight: FontWeight.w600),
          //         ),
          //         const SizedBox(height: 6),
          //         created == 0
          //             ? Text(
          //                 'No tasks created this week yet.',
          //                 style: theme.textTheme.bodyMedium
          //                     ?.copyWith(color: colors.textSecondary),
          //               )
          //             : Text(
          //                 '$completed of $created completed ($percent%)',
          //                 style: theme.textTheme.titleMedium
          //                     ?.copyWith(fontWeight: FontWeight.w600),
          //               ),
          //         const SizedBox(height: 12),
          //         _WeekBar(
          //           completed: completed,
          //           created: created,
          //           colors: colors,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          RevealOnMount(
            index: 1,
            child: _InsightCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Completions, last 7 days',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _DailyBars(
                    buckets: buckets,
                    colors: colors,
                  ),
                ],
              ),
            ),
          ),
          RevealOnMount(
            index: 2,
            child: _InsightCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Open tasks by category',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  if (distribution.isEmpty)
                    Text(
                      'Open tasks land here once you assign categories.',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: colors.textSecondary),
                    )
                  else
                    ..._buildDistribution(
                      distribution: distribution,
                      colors: colors,
                    ),
                ],
              ),
            ),
          ),
          RevealOnMount(
            index: 3,
            child: _InsightCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$doneTotal completed · $openTotal open',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trend',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          trend == 0
                              ? 'Same as previous week'
                              : trend > 0
                                  ? '+$trend vs previous week'
                                  : '$trend vs previous week',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDistribution({
    required List<(int, String, int, int)> distribution,
    required TasklyColors colors,
  }) {
    final max = distribution.map((row) => row.$4).reduce(
          (a, b) => a > b ? a : b,
        );

    return [
      for (final row in distribution)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 84,
                child: Text(
                  row.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: row.$4 / max),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: colors.surfaceMuted,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(row.$3),
                        ),
                        borderRadius: BorderRadius.circular(2),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 24,
                child: Text(
                  '${row.$4}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
    ];
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TasklyColors>()!;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}

class _WeekBar extends StatelessWidget {
  const _WeekBar({
    required this.completed,
    required this.created,
    required this.colors,
  });

  final int completed;
  final int created;
  final TasklyColors colors;

  @override
  Widget build(BuildContext context) {
    final value = created == 0 ? 0.0 : completed / created;

    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: value),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, animated, _) {
          return LinearProgressIndicator(
            value: animated,
            minHeight: 6,
            backgroundColor: colors.surfaceMuted,
            valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
            borderRadius: BorderRadius.circular(2),
          );
        },
      ),
    );
  }
}

class _DailyBars extends StatelessWidget {
  const _DailyBars({
    required this.buckets,
    required this.colors,
  });

  final List<DayBucket> buckets;
  final TasklyColors colors;

  @override
  Widget build(BuildContext context) {
    // Days with no completions still render as a dot, so the divisor is
    // never zero and buckets keep their letters aligned with real dates.
    final maxCount = buckets
        .map((b) => b.count)
        .reduce((a, b) => a > b ? a : b)
        .clamp(1, 1 << 30);
    final theme = Theme.of(context);
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < buckets.length; i++)
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 72,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: buckets[i].count == 0
                        ? Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.textSecondary.withValues(alpha: 0.4),
                            ),
                          )
                        : TweenAnimationBuilder<double>(
                            tween: Tween(end: buckets[i].count / maxCount),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) => FractionallySizedBox(
                              heightFactor: value,
                              widthFactor: 0.55,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colors.accent,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  letters[buckets[i].day.weekday - 1],
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
