import 'dart:developer';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  // Singleton instance using GetX
  static GoogleSignInService get instance => Get.find<GoogleSignInService>();
  static GoogleSignInService get initialize => Get.put(GoogleSignInService());

  // Private static instance
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  // User data model
  GoogleSignInAccount? currentUser;

  // Sign in method with proper error handling
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw SignInAbortedException('Sign in was aborted by user');
      }

      currentUser = googleUser;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      _logAuthDetails(googleAuth);

      return googleUser;
    } on SignInAbortedException catch (e) {
      log('Sign in aborted: ${e.message}');
      rethrow;
    } catch (error) {
      log('Google sign in error: $error');
      throw SignInFailedException('Failed to sign in with Google: $error');
    }
  }

  // Sign out method with error handling
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      currentUser = null;
    } catch (error) {
      log('Sign out error: $error');
      throw SignOutFailedException('Failed to sign out: $error');
    }
  }

  // Check if user is signed in
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  // Get current user
  GoogleSignInAccount? getCurrentUser() {
    return currentUser;
  }

  // Private method to log auth details
  void _logAuthDetails(GoogleSignInAuthentication auth) {
    log('Access Token: ${auth.accessToken}');
    log('ID Token: ${auth.idToken}');
  }
}

// Custom exceptions for better error handling
class SignInAbortedException implements Exception {
  final String message;
  SignInAbortedException(this.message);
}

class SignInFailedException implements Exception {
  final String message;
  SignInFailedException(this.message);
}

class SignOutFailedException implements Exception {
  final String message;
  SignOutFailedException(this.message);
}
