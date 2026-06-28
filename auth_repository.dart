import 'app_user.dart';

/// The contract every part of the app depends on for auth — never the
/// concrete implementation. Today, [LocalAuthRepository] (in
/// ../data/local_auth_repository.dart) implements this using Hive.
/// Later, a `FirebaseAuthRepository` can implement the exact same
/// interface using `firebase_auth`, and nothing outside the auth
/// feature needs to change — every other feature, and the router,
/// only ever call methods on this interface.
abstract class AuthRepository {
  /// The currently signed-in user, or null if no one is signed in.
  Future<AppUser?> getCurrentUser();

  /// Creates a local profile and signs in as it. There's no real
  /// "account" yet (no password, no server) — this is a placeholder
  /// for real authentication, deliberately named the same as what the
  /// Firebase equivalent will be called later.
  Future<AppUser> signInWithLocalProfile({
    required String displayName,
    String? email,
  });

  /// Sets or clears a numeric PIN used to lock the app locally.
  Future<void> setPin(String? pin);

  /// Verifies a PIN against the one stored for the current user.
  Future<bool> verifyPin(String pin);

  Future<void> signOut();
}
