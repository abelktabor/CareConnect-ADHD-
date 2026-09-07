import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/role_themed.dart';
import 'models/user_role.dart';
import 'router/app_router.dart';
import 'state/settings_provider.dart';

/// Root widget: wires the theme, the router and the role-aware colour accent.
///
/// The care-recipient experience is Harbor Teal and the caregiver experience is
/// Dusk Violet. The switch happens in [RoleThemed], which reads the signed-in
/// role and re-themes everything below it — app bars, navigation, buttons —
/// so a caregiver always has a consistent visual cue that they are looking at
/// someone else's care (WCAG 2.2 SC 3.2.3 / 3.2.4 consistent identification).
class CareConnectApp extends ConsumerWidget {
  const CareConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'CareConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(
        brightness: Brightness.light,
        role: UserRole.careRecipient,
      ),
      darkTheme: AppTheme.build(
        brightness: Brightness.dark,
        role: UserRole.careRecipient,
      ),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) => RoleThemed(child: child ?? const SizedBox()),
    );
  }
}
