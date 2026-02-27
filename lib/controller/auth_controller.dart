import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  static Future<void>? _googleSignInInit;

  static Future<void> _ensureGoogleSignInInitialized() {
    _googleSignInInit ??= GoogleSignIn.instance.initialize();
    return _googleSignInInit!;
  }

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential = await auth.signInWithPopup(
          authProvider,
        );

        user = userCredential.user;
      } catch (e) {
        print(e);
      }
    } else {
      try {
        await _ensureGoogleSignInInitialized();

        final GoogleSignInAccount googleAccount = await GoogleSignIn.instance
            .authenticate();
        final GoogleSignInAuthentication googleAuth =
            googleAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await auth.signInWithCredential(
          credential,
        );
        user = userCredential.user;
      } on FirebaseAuthException {
        rethrow;
      } catch (e) {
        // Preserve existing behavior: swallow and return null.
        print(e);
      }
    }
    // print(user);
    return user;
  }

  static Future<void> signOut({required BuildContext context}) async {
    try {
      if (!kIsWeb) {
        await _ensureGoogleSignInInitialized();
        await GoogleSignIn.instance.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e);
    }
  }
}
