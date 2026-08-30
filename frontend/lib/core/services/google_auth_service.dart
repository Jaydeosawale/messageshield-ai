import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static bool _initialized = false;

  // ==========================================
  // Initialize Google Sign-In
  // ==========================================

  static Future<void> initialize() async {
    // Web uses Firebase signInWithPopup().
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
    if (kIsWeb) {
      return _signInOnWeb();
    }

    return _signInOnMobile();
  }

  // ==========================================
  // Web Google Sign-In
  // ==========================================

  static Future<firebase_auth.User> _signInOnWeb() async {
    try {
      final firebaseAuth = firebase_auth.FirebaseAuth.instance;

      // Clear previous Firebase session so the
      // Google account chooser can appear.
      await firebaseAuth.signOut();

      final provider = firebase_auth.GoogleAuthProvider();

      provider.addScope('email');
      provider.addScope('profile');

      provider.setCustomParameters({
        'prompt': 'select_account',
      });

      final userCredential = await firebaseAuth.signInWithPopup(
        provider,
      );

      final user = userCredential.user;

      if (user == null) {
        throw Exception(
          'Google sign-in did not return a user.',
        );
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw Exception(
        _getFirebaseErrorMessage(error),
      );
    } catch (error) {
      throw Exception(
        _getGeneralErrorMessage(error),
      );
    }
  }

  // ==========================================
  // Mobile Google Sign-In
  // ==========================================

  static Future<firebase_auth.User> _signInOnMobile() async {
    try {
      await initialize();

      if (!_googleSignIn.supportsAuthenticate()) {
        throw UnsupportedError(
          'Google sign-in is not supported on this platform.',
        );
      }

      final GoogleSignInAccount googleAccount =
          await _googleSignIn.authenticate();

      final GoogleSignInAuthentication authentication =
          googleAccount.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: authentication.idToken,
      );

      final userCredential =
          await firebase_auth.FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final user = userCredential.user;

      if (user == null) {
        throw Exception(
          'Google sign-in did not return a user.',
        );
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw Exception(
        _getFirebaseErrorMessage(error),
      );
    } catch (error) {
      throw Exception(
        _getGeneralErrorMessage(error),
      );
    }
  }

  // ==========================================
  // Sign out
  // ==========================================

  static Future<void> signOut() async {
    await firebase_auth.FirebaseAuth.instance.signOut();
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
            'internet connection and try again.';

      case 'operation-not-allowed':
        return 'Google sign-in is not enabled.';

      case 'invalid-credential':
        return 'The Google sign-in credential is invalid '
            'or has expired. Please try again.';

      case 'user-disabled':
        return 'This Google account has been disabled.';

      default:
        return error.message ?? 'Google sign-in failed. Please try again.';
    }
  }

  // ==========================================
  // General Error Messages
  // ==========================================

  static String _getGeneralErrorMessage(
    Object error,
  ) {
    var message = error.toString().trim();

    message = message.replaceFirst(
      'Exception: ',
      '',
    );

    if (message.isEmpty) {
      return 'Google sign-in failed. Please try again.';
    }

    return message;
  }
}
