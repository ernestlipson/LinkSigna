import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../infrastructure/navigation/routes.dart';
import '../../../../infrastructure/dal/services/interpreter_user.firestore.service.dart';
import '../../../../domain/users/interpreter_user.model.dart';
import '../../shared/controllers/interpreter_profile.controller.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';

class InterpreterSigninController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Validation state
  final isEmailValid = true.obs;
  final isPasswordValid = true.obs;

  // Password visibility state
  final isPasswordVisible = false.obs;

  // Remember me state
  final isRememberMe = false.obs;

  final isSubmitting = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Services
  final InterpreterUserFirestoreService _firestoreService =
      Get.find<InterpreterUserFirestoreService>();

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
      await _auth.sendPasswordResetEmail(email: email);
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

  Future<void> login() async {
    if (!validateAll()) {
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
      return;
    }

    isSubmitting.value = true;
    final email = emailController.text.trim();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: passwordController.text.trim(),
      );

      final profile = await _loadInterpreterProfile(credential.user);

      if (profile == null) {
        await _auth.signOut();
        AppSnackbar.error(
          title: 'Profile Missing',
          message: 'Interpreter profile not found for this account.',
        );
        return;
      }

      await _cacheSession(profile, rememberEmail: isRememberMe.value);

      if (Get.isRegistered<InterpreterProfileController>()) {
        Get.find<InterpreterProfileController>().setProfile(profile);
      }

      AppSnackbar.success(
        title: 'Success',
        message: 'Login successful!',
      );

      Get.offAllNamed(Routes.INTERPRETER_HOME);
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(
        title: 'Login Failed',
        message: _mapAuthError(e),
      );
    } catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Login failed: ${e.toString()}',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _prefillRememberedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberedEmail = prefs.getString('interpreter_remembered_email');
      if (rememberedEmail != null && rememberedEmail.isNotEmpty) {
        emailController.text = rememberedEmail;
        isRememberMe.value = true;
      }
    } catch (e) {
      Get.log('Error loading remembered email: $e');
    }
  }

  Future<void> _checkAuthStatus() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final profile = await _loadInterpreterProfile(user);
      if (profile == null) return;

      await _cacheSession(profile, rememberEmail: isRememberMe.value);

      if (Get.isRegistered<InterpreterProfileController>()) {
        Get.find<InterpreterProfileController>().setProfile(profile);
      }

      Get.offAllNamed(Routes.INTERPRETER_HOME);
    } catch (e) {
      Get.log('Interpreter auto-login failed: $e');
    }
  }

  Future<InterpreterUser?> _loadInterpreterProfile(User? user) async {
    if (user == null) return null;

    final byAuth = await _firestoreService.findByAuthUid(user.uid);
    if (byAuth != null) return byAuth;

    final email = user.email ?? emailController.text.trim();
    if (email.isEmpty) return null;

    final byEmail = await _firestoreService.findByEmail(email);
    if (byEmail != null) {
      await _firestoreService.updateFields(byEmail.interpreterID, {
        'authUid': user.uid,
      });
      return byEmail.copyWith(authUid: user.uid);
    }

    if (user.displayName != null) {
      final parts = user.displayName!.trim().split(' ');
      final firstName = parts.isNotEmpty ? parts.first : '';
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      return _firestoreService.getOrCreateByAuthUid(
        authUid: user.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
      );
    }

    return _firestoreService.getOrCreateByAuthUid(
      authUid: user.uid,
      email: email,
      firstName: '',
      lastName: '',
    );
  }

  Future<void> _cacheSession(InterpreterUser profile,
      {required bool rememberEmail}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('interpreter_logged_in', true);
    await prefs.setString('interpreter_email', profile.email);
    await prefs.setString('interpreter_name', profile.displayName.trim());
    await prefs.setString('interpreter_id', profile.interpreterID);
    if (profile.university != null && profile.university!.isNotEmpty) {
      await prefs.setString('university', profile.university!);
    }

    if (rememberEmail) {
      await prefs.setString('interpreter_remembered_email', profile.email);
      emailController.text = profile.email;
      isRememberMe.value = true;
    } else {
      await prefs.remove('interpreter_remembered_email');
      isRememberMe.value = false;
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
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

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    await _prefillRememberedEmail();
    await _checkAuthStatus();
  }
}
