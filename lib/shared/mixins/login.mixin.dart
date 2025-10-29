import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';

mixin LoginMixin on GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Validation state
  final isEmailValid = true.obs;
  final isPasswordValid = true.obs;

  // UI state
  final isPasswordVisible = false.obs;
  final isRememberMe = false.obs;
  final isLoading = false.obs;

  final FirebaseAuth auth = FirebaseAuth.instance;

  void validateEmail() {
    final email = emailController.text.trim();
    isEmailValid.value = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  void validatePassword() {
    isPasswordValid.value = passwordController.text.trim().isNotEmpty;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  bool validateAll() {
    validateEmail();
    validatePassword();
    return isEmailValid.value && isPasswordValid.value;
  }

  /// Show validation errors for empty fields
  void showValidationErrors() {
    if (emailController.text.trim().isEmpty) {
      isEmailValid.value = false;
      AppSnackbar.error(
        title: 'Email Required',
        message: 'Enter your university email',
      );
    }
    if (passwordController.text.trim().isEmpty) {
      isPasswordValid.value = false;
      AppSnackbar.error(
        title: 'Password Required',
        message: 'Enter your password',
      );
    }
  }

  /// Send password reset email
  Future<void> sendPasswordReset() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      AppSnackbar.error(
        title: 'Email Required',
        message: 'Enter your university email',
      );
      return;
    }

    try {
      await auth.sendPasswordResetEmail(email: email);
      AppSnackbar.success(
        title: 'Email Sent',
        message: 'Check your inbox to reset your password',
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Failed to send reset email';
      if (e.code == 'user-not-found') msg = 'No account found with this email';
      if (e.code == 'invalid-email') msg = 'Invalid email format';
      AppSnackbar.error(
        title: 'Error',
        message: msg,
      );
    } catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: e.toString(),
      );
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailPassword() async {
    return await auth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
  }

  /// Map Firebase Auth errors to user-friendly messages
  String mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email format';
      case 'user-disabled':
        return 'This account has been disabled';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  /// Save or remove remembered email
  Future<void> saveRememberedEmail(String key, String email,
      {required bool remember}) async {
    final prefs = await SharedPreferences.getInstance();
    if (remember) {
      await prefs.setString(key, email);
    } else {
      await prefs.remove(key);
    }
  }

  /// Load remembered email from SharedPreferences
  Future<void> loadRememberedEmail(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberedEmail = prefs.getString(key);
      if (rememberedEmail != null && rememberedEmail.isNotEmpty) {
        emailController.text = rememberedEmail;
        isRememberMe.value = true;
      }
    } catch (e) {
      Get.log('Error loading remembered email: $e');
    }
  }

  /// Parse full name into first and last name
  Map<String, String> parseFullName(String fullName) {
    final nameParts = fullName.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
    return {'firstName': firstName, 'lastName': lastName};
  }

  void disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
  }
}
