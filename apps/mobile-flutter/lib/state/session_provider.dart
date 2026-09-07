import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_store.dart';
import '../models/session.dart';
import '../models/user_role.dart';
import 'clock_provider.dart';

/// Signed-in state. Null means the sign-in screen is showing.
///
/// There is no real authentication this term; the point of the screen is the
/// accessible pattern (passkey first, email second, no password) and the role
/// choice that drives the rest of the app.
class SessionNotifier extends Notifier<Session?> {
  @override
  Session? build() {
    final json = ref.watch(localStoreProvider).readJson(StoreKeys.session);
    return json == null ? null : Session.fromJson(json);
  }

  Future<void> signIn({
    required UserRole role,
    required SignInMethod method,
    String? email,
  }) async {
    final session = Session(
      role: role,
      method: method,
      signedInAt: ref.read(currentTimeProvider),
      email: email?.trim().isEmpty ?? true ? null : email!.trim(),
    );
    state = session;
    await ref
        .read(localStoreProvider)
        .writeJson(StoreKeys.session, session.toJson());
  }

  Future<void> signOut() async {
    state = null;
    await ref.read(localStoreProvider).remove(StoreKeys.session);
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, Session?>(
  SessionNotifier.new,
);

/// The signed-in role, defaulting to care recipient before sign-in so the
/// sign-in screen itself is themed in the care-recipient teal.
final currentRoleProvider = Provider<UserRole>(
  (ref) => ref.watch(sessionProvider)?.role ?? UserRole.careRecipient,
);
