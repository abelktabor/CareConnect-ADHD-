import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/call_contact_button.dart';
import '../../core/widgets/cc_app_bar.dart';
import '../../core/widgets/cc_list_item.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive.dart';
import '../../state/care_selectors.dart';

/// Screen 04 — Appointments List.
///
/// Each row carries the full-word date, the time, the place and who is
/// taking the care recipient — nothing to look up on another screen.
class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(upcomingAppointmentsProvider);
    final caregiver = ref.watch(caregiverProvider);

    return Scaffold(
      appBar: CcAppBar(
        title: 'Appointments',
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
          if (appointments.isEmpty)
            const EmptyState(
              icon: Icons.event_available,
              message: 'No upcoming appointments.',
              detail: 'Add one and it will show here with who is taking you.',
            )
          else
            for (final appointment in appointments)
              CcListItem(
                title: appointment.title,
                subtitle: appointment.summaryLine,
                semanticHint: 'Opens the appointment to edit it',
                onTap: () =>
                    context.push('/appointments/${appointment.id}/edit'),
              ),
          const SizedBox(height: Space.md),
          FilledButton.icon(
            key: const Key('add-appointment'),
            icon: const Icon(Icons.add),
            label: const Text('Add Appointment'),
            onPressed: () => context.push('/appointments/new'),
          ),
        ],
      ),
    );
  }
}
