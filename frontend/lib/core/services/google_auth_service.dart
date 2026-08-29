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
    if (_initialized) return;

    await _googleSignIn.initialize();

    _initialized = true;
  }

  // ==========================================
  // Google Sign-In
  // ==========================================

  static Future<firebase_auth.User> signIn() async {
    await initialize();

    // ------------------------------------------
    // Mobile / supported platforms
    // ------------------------------------------

    if (!kIsWeb &&
        _googleSignIn.supportsAuthenticate()) {
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

    // ------------------------------------------
    // Web
    // ------------------------------------------

    if (kIsWeb) {
      final provider =
          firebase_auth.GoogleAuthProvider();

      final userCredential =
          await firebase_auth.FirebaseAuth.instance
              .signInWithPopup(provider);

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
  }

  // ==========================================
  // Sign out
  // ==========================================

  static Future<void> signOut() async {
    await firebase_auth.FirebaseAuth.instance
        .signOut();
  }
}