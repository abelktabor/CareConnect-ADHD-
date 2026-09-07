import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/session_provider.dart';
import '../theme/app_theme.dart';

/// Re-themes its subtree in the signed-in role's accent colour.
///
/// Inserted through `MaterialApp.builder`, so every route, dialog and snackbar
/// inherits it. Care recipient → Harbor Teal; caregiver → Dusk Violet.
class RoleThemed extends ConsumerWidget {
  const RoleThemed({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentRoleProvider);
    final brightness = Theme.of(context).brightness;
    return Theme(
      data: AppTheme.build(brightness: brightness, role: role),
      child: child,
    );
  }
}
