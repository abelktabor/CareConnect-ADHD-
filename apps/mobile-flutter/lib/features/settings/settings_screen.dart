import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/call_contact_button.dart';
import '../../core/widgets/cc_app_bar.dart';
import '../../core/widgets/cc_list_item.dart';
import '../../core/widgets/responsive.dart';
import '../../models/user_role.dart';
import '../../state/care_selectors.dart';
import '../../state/session_provider.dart';

/// Screen 11 — Settings. Three plain rows; the destinations differ slightly
/// by role (caregivers have no "My Caregiver Access").
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentRoleProvider);
    final caregiver = ref.watch(caregiverProvider);
    final patient = ref.watch(patientProvider);
    final primary = Theme.of(context).colorScheme.primary;
    final prefix = role.routePrefix;

    return Scaffold(
      appBar: CcAppBar(
        title: 'Settings',
        actions: [
          if (role == UserRole.careRecipient)
            CallContactButton(
              contactName: caregiver.displayName,
              relationship: caregiver.relationshipToPatient,
              phone: caregiver.phone,
            )
          else
            CallContactButton(
              contactName: patient.displayName,
              relationship: 'your care recipient',
              phone: '555-0199',
            ),
        ],
      ),
      body: ResponsiveBody(
        primary: [
          CcListItem(
            key: const Key('settings-notifications'),
            title: 'Notifications',
            subtitle: 'Digest, alerts, and reminder lead time',
            dotColor: primary,
            onTap: () => context.go('$prefix/settings/notifications'),
          ),
          if (role == UserRole.careRecipient)
            CcListItem(
              key: const Key('settings-caregiver-access'),
              title: 'My Caregiver Access',
              subtitle:
                  'See what ${caregiver.displayName} can see and manage access',
              dotColor: primary,
              onTap: () => context.go('$prefix/settings/caregiver-access'),
            ),
          CcListItem(
            key: const Key('settings-app'),
            title: 'App Settings',
            subtitle: 'Profile, account, and general preferences',
            dotColor: primary,
            onTap: () => context.go('$prefix/settings/app'),
          ),
        ],
      ),
    );
  }
}
