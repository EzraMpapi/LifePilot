import 'package:crypto/crypto.dart' show sha256;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../core/storage/local_storage.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

/// Local-only implementation of [AuthRepository], backed by Hive.
///
/// Stores exactly one profile (this is a single-user local app for
/// now — no real accounts, no server). The PIN is stored as a SHA-256
/// hash, never in plaintext, even though it's only protecting local
/// data on this device — there's no good reason to store any secret
/// in plaintext even when the threat model is limited.
class LocalAuthRepository implements AuthRepository {
  Box get _box => Hive.box(LocalStorage.authBox);

  static const _userKey = 'current_user';
  static const _pinHashKey = 'pin_hash';

  @override
  Future<AppUser?> getCurrentUser() async {
    final map = _box.get(_userKey);
    if (map == null) return null;
    return AppUser.fromMap(map as Map);
  }

  @override
  Future<AppUser> signInWithLocalProfile({
    required String displayName,
    String? email,
  }) async {
    final existing = await getCurrentUser();
    final user = AppUser(
      id: existing?.id ?? const Uuid().v4(),
      displayName: displayName,
      email: email,
      pinEnabled: existing?.pinEnabled ?? false,
    );
    await _box.put(_userKey, user.toMap());
    return user;
  }

  @override
  Future<void> setPin(String? pin) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw StateError('Cannot set a PIN before signing in.');
    }

    if (pin == null || pin.isEmpty) {
      await _box.delete(_pinHashKey);
      await _box.put(_userKey, user.copyWith(pinEnabled: false).toMap());
      return;
    }

    await _box.put(_pinHashKey, _hashPin(pin));
    await _box.put(_userKey, user.copyWith(pinEnabled: true).toMap());
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final storedHash = _box.get(_pinHashKey) as String?;
    if (storedHash == null) return false;
    return storedHash == _hashPin(pin);
  }

  @override
  Future<void> signOut() async {
    // Deliberately keeps the stored profile/PIN — "signing out" of a
    // local-only app just clears the in-memory session, which is
    // handled by the provider that wraps this repository, not here.
    // See lib/features/auth/presentation/auth_controller.dart.
  }

  String _hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }
}
