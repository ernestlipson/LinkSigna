import 'dart:developer';

import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        throw Exception('Sign in aborted by user');
      }
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      log("GoogleSignInService: $googleAuth");

      // Use the googleAuth object to authenticate with your backend
      // For example, you can send the idToken and accessToken to your server
      // and create a session for the user

      // Example:
      // final response = await http.post(
      //   'https://yourbackend.com/authenticate',
      //   body: {
      //     'idToken': googleAuth.idToken,
      //     'accessToken': googleAuth.accessToken,
      //   },
      // );

      // Handle the response from your backend
    } catch (error) {
      throw Exception('Failed to sign in with Google: $error');
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
