import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/call_contact_button.dart';
import '../../core/widgets/cc_app_bar.dart';
import '../../core/widgets/dose_status.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive.dart';
import '../../core/widgets/status_chip.dart';
import '../../models/medication.dart';
import '../../state/care_selectors.dart';
import '../../state/clock_provider.dart';

/// Screen 03 — Medications List.
///
/// Every medication with its status for today as icon + text. Tapping a
/// card opens the detail; "+ Add Medication" starts the three-step form.
class MedicationsScreen extends ConsumerWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(activeMedicationsProvider);
    final caregiver = ref.watch(caregiverProvider);

    return Scaffold(
      appBar: CcAppBar(
        title: 'Medications',
        actions: [
          CallContactButton(
            contactName: caregiver.displayName,
            relationship: caregiver.relationshipToPatient,
            phone: caregiver.phone,
          ),
        ],
      ),
      body: ResponsiveBody(
        primary: [
          if (medications.isEmpty)
            const EmptyState(
              icon: Icons.medication,
              message: 'No medications yet.',
              detail: 'Add one and its doses will appear on Today.',
            )
          else
            ResponsiveCardGrid(
              children: [
                for (final medication in medications)
                  MedicationCard(
                    medication: medication,
                    onTap: () =>
                        context.go('/patient/medications/${medication.id}'),
                  ),
              ],
            ),
          const SizedBox(height: Space.md),
          FilledButton.icon(
            key: const Key('add-medication'),
            icon: const Icon(Icons.add),
            label: const Text('Add Medication'),
            onPressed: () => context.push('/medications/new'),
          ),
        ],
      ),
    );
  }
}

/// Card with the medication name and today's status chip.
class MedicationCard extends ConsumerWidget {
  const MedicationCard({
    required this.medication,
    required this.onTap,
    super.key,
  });

  final Medication medication;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(currentTimeProvider);
    final dose = ref.watch(medicationTodayDoseProvider(medication.id));
    final theme = Theme.of(context);
    final colors = context.ccColors;

    return MergeSemantics(
      child: Semantics(
        button: true,
        hint: 'Opens the medication',
        child: Card(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(CcRadius.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: TapTarget.dominantAction,
              ),
              child: Padding(
                padding: const EdgeInsets.all(Space.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.displayName,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: Space.xs),
                    if (dose != null)
                      StatusChip.dose(dose, now)
                    else
                      const StatusChip(
                        tone: StatusTone.info,
                        text: 'No dose scheduled today',
                        spoken: 'Status: no dose scheduled today',
                      ),
                    if (medication.instructions != null) ...[
                      const SizedBox(height: Space.xs),
                      Text(
                        medication.instructions!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
