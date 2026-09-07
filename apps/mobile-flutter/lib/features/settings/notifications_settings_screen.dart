import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/cc_app_bar.dart';
import '../../core/widgets/choice_group.dart';
import '../../core/widgets/responsive.dart';
import '../../core/widgets/section_heading.dart';
import '../../models/notification_settings.dart';
import '../../state/notification_settings_provider.dart';

/// Screen 09 — Notifications Settings.
///
/// The user controls the digest and how far ahead reminders fire. Overdue
/// alerts are shown as an always-on control with the reason, rather than
/// hidden, so nothing about the app's behaviour is a surprise.
class NotificationsSettingsScreen extends ConsumerWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);
    final colors = context.ccColors;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CcAppBar(title: 'Notifications', showBack: true),
      body: ResponsiveBody(
        primary: [
          SwitchListTile(
            key: const Key('daily-digest'),
            title: const Text('Daily digest'),
            subtitle: const Text(
              'One summary each morning of what is due today',
            ),
            value: settings.dailyDigest,
            onChanged: (value) => notifier.setDailyDigest(enabled: value),
          ),
          MergeSemantics(
            child: ListTile(
              key: const Key('overdue-alerts'),
              title: const Text('Overdue alerts'),
              subtitle: Text(
                'Always escalate immediately — never held for the digest',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              trailing: Semantics(
                label: 'Always on',
                child: const Switch(
                  value: NotificationSettings.overdueAlertsAlwaysOn,
                  onChanged: null,
                ),
              ),
            ),
          ),
        ],
        secondary: [
          const SectionHeading('Reminder lead time'),
          const SizedBox(height: Space.xs),
          ChoiceGroup<ReminderLeadTime>(
            groupLabel: 'Reminder lead time',
            circular: true,
            selected: settings.leadTime,
            onSelected: notifier.setLeadTime,
            options: [
              for (final lead in ReminderLeadTime.values)
                ChoiceOption(
                  value: lead,
                  label: lead.label,
                  spoken: lead.spoken,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
