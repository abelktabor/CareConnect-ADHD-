import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/appointments/appointment_form_screen.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/caregiver/activity_timeline_screen.dart';
import '../features/caregiver/caregiver_dashboard_screen.dart';
import '../features/caregiver/caregiver_shell.dart';
import '../features/caregiver/manage_screen.dart';
import '../features/medications/medication_form_screen.dart';
import '../features/patient/appointments_screen.dart';
import '../features/patient/medication_detail_screen.dart';
import '../features/patient/medications_screen.dart';
import '../features/patient/patient_shell.dart';
import '../features/patient/today_screen.dart';
import '../features/settings/app_settings_screen.dart';
import '../features/settings/caregiver_access_screen.dart';
import '../features/settings/notifications_settings_screen.dart';
import '../features/settings/settings_screen.dart';
import '../state/session_provider.dart';
import 'redirects.dart';

/// Root navigator, used for full-screen forms that cover the bottom nav.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Where the app opens. Tests override this to start on a given screen.
final initialLocationProvider = Provider<String>((ref) => '/');

/// Bridges Riverpod session changes to GoRouter's `refreshListenable` so the
/// redirect guard re-runs on sign-in and sign-out.
class RouterRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}

/// Route paths, in one place for deep links and tests.
///
/// Deep links: `careconnect://app<path>` on Android and iOS, or the same
/// path on the web build — e.g. `careconnect://app/patient/medications`.
abstract final class Routes {
  static const signIn = '/sign-in';
  static const today = '/patient/today';
  static const medications = '/patient/medications';
  static const appointments = '/patient/appointments';
  static const settings = '/patient/settings';
  static const dashboard = '/caregiver/dashboard';
  static const manage = '/caregiver/manage';
  static const activity = '/caregiver/activity';
  static const caregiverSettings = '/caregiver/settings';
  static const newMedication = '/medications/new';
  static const newAppointment = '/appointments/new';
}

/// Wraps a screen in a page whose transition respects the OS reduce-motion
/// setting: no animation at all when `disableAnimations` is on.
Page<void> accessiblePage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  if (MediaQuery.disableAnimationsOf(context)) {
    return NoTransitionPage<void>(key: state.pageKey, child: child);
  }
  return MaterialPage<void>(key: state.pageKey, child: child);
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = RouterRefresh();
  ref.listen(sessionProvider, (_, _) => refresh.notify());
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: ref.read(initialLocationProvider),
    refreshListenable: refresh,
    redirect: (context, state) => resolveRedirect(
      session: ref.read(sessionProvider),
      location: state.uri.path,
    ),
    routes: [
      GoRoute(path: '/', redirect: (_, _) => Routes.signIn),
      GoRoute(
        path: Routes.signIn,
        pageBuilder: (context, state) =>
            accessiblePage(context, state, const SignInScreen()),
      ),

      // ── Care recipient ────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            PatientShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.today,
                pageBuilder: (context, state) =>
                    accessiblePage(context, state, const TodayScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.medications,
                pageBuilder: (context, state) =>
                    accessiblePage(context, state, const MedicationsScreen()),
                routes: [
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) => accessiblePage(
                      context,
                      state,
                      MedicationDetailScreen(
                        medicationId: state.pathParameters['id']!,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.appointments,
                pageBuilder: (context, state) =>
                    accessiblePage(context, state, const AppointmentsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.settings,
                pageBuilder: (context, state) =>
                    accessiblePage(context, state, const SettingsScreen()),
                routes: [
                  GoRoute(
                    path: 'notifications',
                    pageBuilder: (context, state) => accessiblePage(
                      context,
                      state,
                      const NotificationsSettingsScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'caregiver-access',
                    pageBuilder: (context, state) => accessiblePage(
                      context,
                      state,
                      const CaregiverAccessScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'app',
                    pageBuilder: (context, state) => accessiblePage(
                      context,
                      state,
                      const AppSettingsScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ── Caregiver ─────────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            CaregiverShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.dashboard,
                pageBuilder: (context, state) => accessiblePage(
                  context,
                  state,
                  const CaregiverDashboardScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.manage,
                pageBuilder: (context, state) =>
                    accessiblePage(context, state, const ManageScreen()),
                routes: [
                  GoRoute(
                    path: 'medications/:id',
                    pageBuilder: (context, state) => accessiblePage(
                      context,
                      state,
                      MedicationDetailScreen(
                        medicationId: state.pathParameters['id']!,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.activity,
                pageBuilder: (context, state) => accessiblePage(
                  context,
                  state,
                  const ActivityTimelineScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.caregiverSettings,
                pageBuilder: (context, state) =>
                    accessiblePage(context, state, const SettingsScreen()),
                routes: [
                  GoRoute(
                    path: 'notifications',
                    pageBuilder: (context, state) => accessiblePage(
                      context,
                      state,
                      const NotificationsSettingsScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'app',
                    pageBuilder: (context, state) => accessiblePage(
                      context,
                      state,
                      const AppSettingsScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ── Full-screen forms (no bottom nav) ─────────────────────────────
      GoRoute(
        path: Routes.newMedication,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            accessiblePage(context, state, const MedicationFormScreen()),
      ),
      GoRoute(
        path: '/medications/:id/edit',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => accessiblePage(
          context,
          state,
          MedicationFormScreen(editingId: state.pathParameters['id']),
        ),
      ),
      GoRoute(
        path: Routes.newAppointment,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            accessiblePage(context, state, const AppointmentFormScreen()),
      ),
      GoRoute(
        path: '/appointments/:id/edit',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => accessiblePage(
          context,
          state,
          AppointmentFormScreen(editingId: state.pathParameters['id']),
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
