/// The two experiences the app serves.
///
/// The role is chosen on the sign-in screen ("I am a…") and drives the
/// colour accent, the bottom navigation and which home screen opens.
enum UserRole {
  careRecipient,
  caregiver;

  /// Label shown on the role chooser and in settings.
  String get label => switch (this) {
    UserRole.careRecipient => 'Care Recipient',
    UserRole.caregiver => 'Caregiver',
  };

  /// First path segment for this role's screens (`/patient/...`).
  String get routePrefix => switch (this) {
    UserRole.careRecipient => '/patient',
    UserRole.caregiver => '/caregiver',
  };

  /// Where the role lands after sign-in.
  String get homeLocation => switch (this) {
    UserRole.careRecipient => '/patient/today',
    UserRole.caregiver => '/caregiver/dashboard',
  };

  static UserRole fromStorage(String? value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.careRecipient,
    );
  }
}
