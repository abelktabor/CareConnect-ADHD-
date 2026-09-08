import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/clock.dart';
import '../../core/utils/date_formatting.dart';
import '../../core/widgets/cc_app_bar.dart';
import '../../core/widgets/responsive.dart';
import '../../core/widgets/section_heading.dart';
import '../../core/widgets/undo_snackbar.dart';
import '../../models/user_role.dart';
import '../../state/care_data_provider.dart';
import '../../state/care_selectors.dart';
import '../../state/session_provider.dart';
import '../../state/settings_provider.dart';

/// App Settings — profile, appearance, the demo clock and sign-out.
class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  static const String versionLabel = 'CareConnect 0.4.0 · Assignment 4 build';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final settings = ref.watch(appSettingsProvider);
    final patient = ref.watch(patientProvider);
    final caregiver = ref.watch(caregiverProvider);
    final theme = Theme.of(context);
    final colors = context.ccColors;

    final role = session?.role ?? UserRole.careRecipient;
    final displayName = role == UserRole.caregiver
        ? caregiver.displayName
        : patient.displayName;
    final email =
        session?.email ??
        (role == UserRole.caregiver ? 'renee@example.test' : patient.email);

    return Scaffold(
      appBar: const CcAppBar(title: 'App Settings', showBack: true),
      body: ResponsiveBody(
        primary: [
          const SectionHeading('Profile', level: HeadingLevel.h4),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Space.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName, style: theme.textTheme.titleMedium),
                  Text(email, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: Space.xs),
                  Text(
                    'Signed in as ${role.label.toLowerCase()}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SectionHeading('Appearance', level: HeadingLevel.h4),
          SegmentedButton<ThemeMode>(
            key: const Key('theme-mode'),
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (selection) => ref
                .read(appSettingsProvider.notifier)
                .setThemeMode(selection.first),
          ),
        ],
        secondary: [
          const SectionHeading('Sample data', level: HeadingLevel.h4),
          Card(
            child: SwitchListTile(
              key: const Key('demo-clock'),
              title: const Text('Demo clock'),
              subtitle: Text(
                'Freezes time at ${DateFormatting.dateAndTime(kDemoInstant)} '
                'so every screen matches the Week 3 design.',
              ),
              value: settings.demoClock,
              onChanged: (value) => _setDemoClock(context, ref, value),
            ),
          ),
          const SizedBox(height: Space.sm),
          OutlinedButton.icon(
            key: const Key('reset-sample-data'),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset sample data'),
            onPressed: () => _confirmReset(context, ref),
          ),
          const SectionHeading('Account', level: HeadingLevel.h4),
          OutlinedButton.icon(
            key: const Key('sign-out'),
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
            onPressed: () => ref.read(sessionProvider.notifier).signOut(),
          ),
          const SizedBox(height: Space.lg),
          Text(
            versionLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setDemoClock(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final settings = ref.read(appSettingsProvider.notifier);
    final data = ref.read(careDataProvider.notifier);
    if (!enabled) {
      await settings.setDemoClock(enabled: false);
      return;
    }
    final confirmed = await _confirm(
      context,
      title: 'Turn on the demo clock?',
      body:
          'The clock freezes at '
          '${DateFormatting.dateAndTime(kDemoInstant)} and the sample data '
          'resets to the Week 3 design state. Your own changes are discarded.',
      confirmLabel: 'Turn on',
    );
    if (confirmed != true) return;
    await settings.setDemoClock(enabled: true);
    await data.resetDemoData();
    if (context.mounted) {
      showConfirmationSnackBar(context, 'Demo clock on. Sample data reset.');
    }
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirm(
      context,
      title: 'Reset sample data?',
      body:
          'This puts the medications, appointments and activity back to the '
          'starting sample. Your own changes are discarded.',
      confirmLabel: 'Reset',
    );
    if (confirmed != true) return;
    await ref.read(careDataProvider.notifier).resetDemoData();
    if (context.mounted) {
      showConfirmationSnackBar(context, 'Sample data reset');
    }
  }

  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
