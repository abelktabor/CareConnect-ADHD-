import '../models/session.dart';
import '../models/user_role.dart';

/// Pure routing guard, kept free of Flutter so it is trivially unit-tested.
///
/// * Signed out → everything goes to `/sign-in`.
/// * Signed in → `/sign-in` and `/` go to the role's home.
/// * A care recipient cannot land on caregiver screens, and vice versa.
///
/// Returns the location to redirect to, or null to allow [location].
String? resolveRedirect({required Session? session, required String location}) {
  const signIn = '/sign-in';
  if (session == null) {
    return location == signIn ? null : signIn;
  }
  final home = session.role.homeLocation;
  if (location == signIn || location == '/' || location.isEmpty) {
    return home;
  }
  final otherRole = session.role == UserRole.caregiver
      ? UserRole.careRecipient
      : UserRole.caregiver;
  if (location.startsWith(otherRole.routePrefix)) {
    return home;
  }
  return null;
}
