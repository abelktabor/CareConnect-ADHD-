import 'package:careconnect_mobile/models/session.dart';
import 'package:careconnect_mobile/models/user_role.dart';
import 'package:careconnect_mobile/router/redirects.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Session session(UserRole role) => Session(
    role: role,
    method: SignInMethod.passkey,
    signedInAt: DateTime(2026, 8, 25),
  );

  group('signed out', () {
    test('everything goes to sign-in except sign-in itself', () {
      expect(resolveRedirect(session: null, location: '/'), '/sign-in');
      expect(
        resolveRedirect(session: null, location: '/patient/today'),
        '/sign-in',
      );
      expect(
        resolveRedirect(session: null, location: '/medications/new'),
        '/sign-in',
      );
      expect(resolveRedirect(session: null, location: '/sign-in'), isNull);
    });
  });

  group('care recipient', () {
    final s = session(UserRole.careRecipient);

    test('lands on Today from the root or sign-in', () {
      expect(resolveRedirect(session: s, location: '/'), '/patient/today');
      expect(resolveRedirect(session: s, location: ''), '/patient/today');
      expect(
        resolveRedirect(session: s, location: '/sign-in'),
        '/patient/today',
      );
    });

    test('may visit patient and shared routes', () {
      expect(
        resolveRedirect(session: s, location: '/patient/medications/med-1'),
        isNull,
      );
      expect(resolveRedirect(session: s, location: '/medications/new'), isNull);
      expect(
        resolveRedirect(session: s, location: '/appointments/a1/edit'),
        isNull,
      );
    });

    test('is bounced away from caregiver screens', () {
      expect(
        resolveRedirect(session: s, location: '/caregiver/dashboard'),
        '/patient/today',
      );
      expect(
        resolveRedirect(session: s, location: '/caregiver/activity'),
        '/patient/today',
      );
    });
  });

  group('caregiver', () {
    final s = session(UserRole.caregiver);

    test('lands on the dashboard and cannot open patient screens', () {
      expect(
        resolveRedirect(session: s, location: '/'),
        '/caregiver/dashboard',
      );
      expect(
        resolveRedirect(session: s, location: '/sign-in'),
        '/caregiver/dashboard',
      );
      expect(
        resolveRedirect(session: s, location: '/patient/today'),
        '/caregiver/dashboard',
      );
      expect(
        resolveRedirect(session: s, location: '/caregiver/manage'),
        isNull,
      );
      expect(resolveRedirect(session: s, location: '/medications/new'), isNull);
    });
  });
}
