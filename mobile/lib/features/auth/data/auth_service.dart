import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
        final GoogleSignInAccount? googleUser =
            await GoogleSignIn.instance.authenticate();
        if (googleUser == null) return null; // User cancelled

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

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
