import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatting.dart';
import '../../core/widgets/cc_app_bar.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive.dart';
import '../../state/care_selectors.dart';

/// The selected timeline filter, kept across tab switches.
class ActivityFilterNotifier extends Notifier<ActivityFilter> {
  @override
  ActivityFilter build() => ActivityFilter.all;

  void set(ActivityFilter filter) => state = filter;
}

final activityFilterProvider =
    NotifierProvider<ActivityFilterNotifier, ActivityFilter>(
      ActivityFilterNotifier.new,
    );

/// Screen 10 — Activity Timeline. Plain-language entries grouped by day,
/// newest first, with a simple filter.
class ActivityTimelineScreen extends ConsumerWidget {
  const ActivityTimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(activityFilterProvider);
    final days = ref.watch(activityTimelineProvider(filter));
    final theme = Theme.of(context);
    final colors = context.ccColors;

    return Scaffold(
      appBar: const CcAppBar(title: 'Activity Timeline'),
      body: ResponsiveBody(
        primary: [
          Text(
            'Filter: ${filter.label}',
            style: AppTypography.bodyEmphasis.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: Space.sm),
          SegmentedButton<ActivityFilter>(
            key: const Key('activity-filter'),
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: ActivityFilter.all, label: Text('All')),
              ButtonSegment(
                value: ActivityFilter.medications,
                label: Text('Medications'),
              ),
              ButtonSegment(
                value: ActivityFilter.appointments,
                label: Text('Appointments'),
              ),
            ],
            selected: {filter},
            onSelectionChanged: (selection) =>
                ref.read(activityFilterProvider.notifier).set(selection.first),
          ),
          const SizedBox(height: Space.sm),
          if (days.isEmpty)
            const EmptyState(
              icon: Icons.history,
              message: 'No activity to show.',
              detail: 'Logged doses and appointment changes appear here.',
            ),
          for (final day in days) ...[
            Padding(
              padding: const EdgeInsets.only(top: Space.md, bottom: Space.xs),
              child: Semantics(
                header: true,
                child: Text(
                  DateFormatting.dayHeading(day.day),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            for (final entry in day.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.xs + 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7, left: Space.sm),
                      child: ExcludeSemantics(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colors.info,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Space.md),
                    Expanded(
                      child: Text(
                        entry.summary,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
