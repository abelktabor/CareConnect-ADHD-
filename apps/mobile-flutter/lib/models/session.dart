import 'package:flutter/foundation.dart';

import 'user_role.dart';

/// How the user signed in. No password ever: passkey / Face ID or a plain
/// email handoff, per WCAG 2.2 SC 3.3.8 Accessible Authentication.
enum SignInMethod {
  passkey,
  email;

  static SignInMethod fromStorage(String? value) => SignInMethod.values
      .firstWhere((m) => m.name == value, orElse: () => SignInMethod.passkey);
}

/// The signed-in state. Absent until the sign-in screen completes.
@immutable
class Session {
  const Session({
    required this.role,
    required this.method,
    required this.signedInAt,
    this.email,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    role: UserRole.fromStorage(json['role'] as String?),
    method: SignInMethod.fromStorage(json['method'] as String?),
    signedInAt: DateTime.parse(json['signedInAt'] as String),
    email: json['email'] as String?,
  );

  final UserRole role;
  final SignInMethod method;
  final DateTime signedInAt;
  final String? email;

  Map<String, dynamic> toJson() => {
    'role': role.name,
    'method': method.name,
    'signedInAt': signedInAt.toIso8601String(),
    'email': email,
  };

  @override
  bool operator ==(Object other) =>
      other is Session &&
      other.role == role &&
      other.method == method &&
      other.signedInAt == signedInAt &&
      other.email == email;

  @override
  int get hashCode => Object.hash(role, method, signedInAt, email);
}
