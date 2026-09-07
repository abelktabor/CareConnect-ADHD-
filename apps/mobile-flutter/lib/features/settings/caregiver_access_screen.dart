import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/call_contact_button.dart';
import '../../core/widgets/cc_app_bar.dart';
import '../../core/widgets/responsive.dart';
import '../../core/widgets/section_heading.dart';
import '../../state/care_selectors.dart';
import '../../state/settings_provider.dart';

/// Screen 05 — My Caregiver Access.
///
/// Exactly what the caregiver can see, as a closed list. Nothing outside it
/// is ever shared, and the care recipient can pause sharing here.
class CaregiverAccessScreen extends ConsumerWidget {
  const CaregiverAccessScreen({super.key});

  static const List<String> visibleToCaregiver = [
    'Medication names, doses, and status',
    'Appointment times and locations',
    'Whether a dose was taken, skipped, or missed',
    'Recent activity timeline',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caregiver = ref.watch(caregiverProvider);
    final sharing = ref.watch(
      appSettingsProvider.select((s) => s.shareWithCaregiver),
    );
    final theme = Theme.of(context);
    final colors = context.ccColors;
    final name = caregiver.displayName;

    return Scaffold(
      appBar: CcAppBar(
        title: 'My Caregiver Access',
        showBack: true,
        actions: [
          CallContactButton(
            contactName: name,
            relationship: caregiver.relationshipToPatient,
            phone: caregiver.phone,
          ),
        ],
      ),
      body: ResponsiveBody(
        primary: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Space.md),
              child: Text(
                '$name — ${caregiver.relationshipToPatient}',
                style: theme.textTheme.titleSmall,
              ),
            ),
          ),
          SectionHeading('What $name can see', level: HeadingLevel.h4),
          for (final item in visibleToCaregiver)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.check_circle,
                      size: 18,
                      color: colors.success,
                      semanticLabel: 'Shared',
                    ),
                  ),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Text(item, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          const SizedBox(height: Space.sm),
          Text(
            'Nothing outside this list is ever visible to $name. '
            'This is the only data caregivers can see.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
        secondary: [
          const SectionHeading('Sharing', level: HeadingLevel.h4),
          Card(
            child: SwitchListTile(
              key: const Key('share-with-caregiver'),
              title: Text('Share with $name'),
              subtitle: Text(
                sharing
                    ? 'Sharing is on. $name sees the list above.'
                    : 'Sharing is paused. $name sees nothing until you turn it back on.',
              ),
              value: sharing,
              onChanged: (value) => ref
                  .read(appSettingsProvider.notifier)
                  .setShareWithCaregiver(enabled: value),
            ),
          ),
        ],
      ),
    );
  }
}
