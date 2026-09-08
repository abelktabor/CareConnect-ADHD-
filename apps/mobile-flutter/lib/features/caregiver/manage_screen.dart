import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/call_contact_button.dart';
import '../../core/widgets/cc_app_bar.dart';
import '../../core/widgets/cc_list_item.dart';
import '../../core/widgets/dose_status.dart';
import '../../core/widgets/responsive.dart';
import '../../core/widgets/section_heading.dart';
import '../../models/dose_event.dart';
import '../../state/care_selectors.dart';
import '../../state/clock_provider.dart';

/// Caregiver "Manage" tab: the care recipient's medications and
/// appointments, each opening the same step-by-step forms (screens 07 and
/// 08) in the caregiver accent.
class ManageScreen extends ConsumerWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = ref.watch(patientProvider);
    final medications = ref.watch(activeMedicationsProvider);
    final appointments = ref.watch(upcomingAppointmentsProvider);
    final now = ref.watch(currentTimeProvider);

    return Scaffold(
      appBar: CcAppBar(
        title: 'Manage',
        subtitle: '${patient.displayName}’s medications and appointments',
        actions: [
          CallContactButton(
            contactName: patient.displayName,
            relationship: 'your care recipient',
            phone: '555-0199',
          ),
        ],
      ),
      body: ResponsiveBody(
        primary: [
          const SectionHeading('Medications'),
          for (final medication in medications)
            Consumer(
              builder: (context, ref, _) {
                final dose = ref.watch(
                  medicationTodayDoseProvider(medication.id),
                );
                final subtitle = dose == null
                    ? 'No dose scheduled today'
                    : _chipText(dose, now);
                return CcListItem(
                  title: medication.displayName,
                  subtitle: subtitle,
                  tone: dose == null ? StatusTone.info : _tone(dose, now),
                  semanticHint: 'Opens the medication',
                  onTap: () => context.go(
                    '/caregiver/manage/medications/${medication.id}',
                  ),
                );
              },
            ),
          const SizedBox(height: Space.sm),
          FilledButton.icon(
            key: const Key('manage-add-medication'),
            icon: const Icon(Icons.add),
            label: const Text('Add Medication'),
            onPressed: () => context.push('/medications/new'),
          ),
        ],
        secondary: [
          const SectionHeading('Appointments'),
          for (final appointment in appointments)
            CcListItem(
              title: appointment.title,
              subtitle: appointment.summaryLine,
              semanticHint: 'Opens the appointment to edit it',
              onTap: () => context.push('/appointments/${appointment.id}/edit'),
            ),
          const SizedBox(height: Space.sm),
          FilledButton.icon(
            key: const Key('manage-add-appointment'),
            icon: const Icon(Icons.add),
            label: const Text('Add Appointment'),
            onPressed: () => context.push('/appointments/new'),
          ),
        ],
      ),
    );
  }

  static String _chipText(DoseEvent dose, DateTime now) =>
      DoseStatusPresentation.of(dose, now).chipText;

  static StatusTone _tone(DoseEvent dose, DateTime now) =>
      DoseStatusPresentation.of(dose, now).tone;
}
