import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'undo_snackbar.dart';

/// The persistent "Call my caregiver" action (WCAG 2.2 SC 3.2.6 Consistent
/// Help). Always the top-right 48×48 icon button on every care-recipient
/// screen; the caregiver experience mirrors it with "Call Muhammad".
class CallContactButton extends StatelessWidget {
  const CallContactButton({
    required this.contactName,
    required this.relationship,
    required this.phone,
    super.key,
  });

  final String contactName;

  /// "your caregiver" / "your care recipient"
  final String relationship;
  final String phone;

  @override
  Widget build(BuildContext context) {
    final label = 'Call $contactName, $relationship';
    return IconButton(
      tooltip: label,
      iconSize: 26,
      constraints: const BoxConstraints(
        minWidth: TapTarget.icon,
        minHeight: TapTarget.icon,
      ),
      icon: const Icon(Icons.phone),
      onPressed: () => _confirm(context),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final theme = Theme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Call $contactName?',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: Space.sm),
              Text(
                '$contactName — $relationship · $phone',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: Space.lg),
              FilledButton.icon(
                icon: const Icon(Icons.phone),
                label: Text('Call $phone'),
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  showConfirmationSnackBar(
                    context,
                    'This prototype does not place calls. '
                    '$contactName’s number is $phone.',
                  );
                },
              ),
              const SizedBox(height: Space.sm),
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: const Text('Not now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
