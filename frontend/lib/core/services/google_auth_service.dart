import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static final GoogleSignIn _googleSignIn =
      GoogleSignIn.instance;

  static bool _initialized = false;

  // ==========================================
  // Initialize Google Sign-In
  // ==========================================

  static Future<void> initialize() async {
    // Web uses Firebase signInWithPopup().
    // GoogleSignIn.initialize() is not required
    // for the web flow.
    if (kIsWeb) {
      return;
    }

    if (_initialized) {
      return;
    }

    await _googleSignIn.initialize();

    _initialized = true;
  }

  // ==========================================
  // Google Sign-In
  // ==========================================

  static Future<firebase_auth.User> signIn() async {
    // ------------------------------------------
    // WEB
    // ------------------------------------------

    if (kIsWeb) {
      try {
        final firebaseAuth =
            firebase_auth.FirebaseAuth.instance;

        // Clear any previous Firebase session.
        //
        // This prevents Firebase from silently
        // reusing the previously authenticated user.
        await firebaseAuth.signOut();

        final provider =
            firebase_auth.GoogleAuthProvider();

        provider.addScope('email');
        provider.addScope('profile');

        // IMPORTANT:
        // Force Google to show account selection.
        provider.setCustomParameters({
          'prompt': 'select_account',
        });

        final userCredential =
            await firebaseAuth.signInWithPopup(
          provider,
        );

        final user = userCredential.user;

        if (user == null) {
          throw Exception(
            'Google sign-in did not return a user',
          );
        }

        return user;
      } on firebase_auth.FirebaseAuthException catch (
        error,
      ) {
        throw Exception(
          _getFirebaseErrorMessage(error),
        );
      }
    }

    // ------------------------------------------
    // MOBILE / SUPPORTED PLATFORMS
    // ------------------------------------------

    await initialize();

    try {
      if (_googleSignIn.supportsAuthenticate()) {
        final GoogleSignInAccount googleAccount =
            await _googleSignIn.authenticate();

        final GoogleSignInAuthentication authentication =
            googleAccount.authentication;

        final credential =
            firebase_auth.GoogleAuthProvider.credential(
          idToken: authentication.idToken,
        );

        final userCredential =
            await firebase_auth.FirebaseAuth.instance
                .signInWithCredential(
          credential,
        );

        final user = userCredential.user;

        if (user == null) {
          throw Exception(
            'Google sign-in did not return a user',
          );
        }

        return user;
      }

      throw UnsupportedError(
        'Google sign-in is not supported on this platform',
      );
    } on firebase_auth.FirebaseAuthException catch (
      error,
    ) {
      throw Exception(
        _getFirebaseErrorMessage(error),
      );
    }
  }

  // ==========================================
  // Sign out
  // ==========================================

  static Future<void> signOut() async {
    await firebase_auth.FirebaseAuth.instance
        .signOut();
  }

  // ==========================================
  // Firebase Error Messages
  // ==========================================

  static String _getFirebaseErrorMessage(
    firebase_auth.FirebaseAuthException error,
  ) {
    switch (error.code) {
      case 'popup-closed-by-user':
        return 'Google sign-in was cancelled.';

      case 'popup-blocked':
        return 'Google sign-in popup was blocked. '
            'Please allow popups and try again.';

      case 'account-exists-with-different-credential':
        return 'This email is already associated with '
            'a different sign-in method.';

      case 'network-request-failed':
        return 'Network error. Please check your '
            'internet connection.';

      case 'operation-not-allowed':
        return 'Google sign-in is not enabled.';

      default:
        return error.message ??
            'Google sign-in failed. Please try again.';
    }
  }
}
