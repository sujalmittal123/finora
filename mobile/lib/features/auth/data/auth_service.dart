import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService() {
    // On mobile, initialize GoogleSignIn eagerly
    if (!kIsWeb) {
      GoogleSignIn.instance.initialize();
    }
  }

  /// Stream that emits whenever auth state changes (login / logout)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently signed-in Firebase user (null if logged out)
  User? get currentUser => _auth.currentUser;

  /// Sign in with Google. Returns [UserCredential] on success, null if cancelled.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web: use popup to avoid DWDS hang
        final provider = GoogleAuthProvider();
        return await _auth.signInWithPopup(provider);
      } else {
        // Mobile: standard GoogleSignIn flow (v7.x uses authenticate())
        final googleUser = await GoogleSignIn.instance.authenticate();
        final googleAuth = googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          // accessToken not needed for Firebase Auth only
        );

        return await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} — ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      rethrow;
    }
  }

  /// Sign up with email + password, then set the display name.
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(name.trim());
    return credential;
  }

  /// Updates the Firebase profile (best-effort; safe when signed out).
  Future<void> updateProfile({
    required String name,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await user.updateDisplayName(name);
      if (photoUrl != null && photoUrl.isNotEmpty) {
        await user.updatePhotoURL(photoUrl);
      }
    } catch (e) {
      debugPrint('Profile update failed: $e');
    }
  }

  /// Sign out from both Firebase and Google
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await GoogleSignIn.instance.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign-out error: $e');
    }
  }
}
