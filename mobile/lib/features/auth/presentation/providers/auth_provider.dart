import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_service.dart';

// ─── Singleton AuthService ────────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ─── Auth state stream (User? — null = logged out) ────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// ─── Auth notifier for sign-in / sign-out actions ────────────────────────────
class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    return ref.watch(authServiceProvider).currentUser;
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async {
        final cred = await ref.read(authServiceProvider).signInWithGoogle();
        return cred?.user;
      },
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    await ref.read(authServiceProvider).signOut();
    state = const AsyncData(null);
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, User?>(() => AuthNotifier());
