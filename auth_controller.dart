import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_auth_repository.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

/// The single place that decides which [AuthRepository] implementation
/// the app uses. Swapping to Firebase later means changing only this
/// one line — every widget and controller below depends on the
/// interface (`AuthRepository`), never on `LocalAuthRepository`
/// directly, via Riverpod's standard dependency-injection pattern.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return LocalAuthRepository();
});

/// Holds the current signed-in user (or null) as app-wide state.
/// UI watches this provider; nothing in the UI talks to the repository
/// directly.
final authControllerProvider =
    AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);

class AuthController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    final repo = ref.watch(authRepositoryProvider);
    return repo.getCurrentUser();
  }

  Future<void> signIn({required String displayName, String? email}) async {
    final repo = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repo.signInWithLocalProfile(displayName: displayName, email: email),
    );
  }

  Future<void> setPin(String? pin) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.setPin(pin);
    state = await AsyncValue.guard(() => repo.getCurrentUser());
  }

  Future<bool> verifyPin(String pin) {
    final repo = ref.read(authRepositoryProvider);
    return repo.verifyPin(pin);
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    state = const AsyncData(null);
  }
}
