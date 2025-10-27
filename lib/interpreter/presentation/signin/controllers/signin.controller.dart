import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:email_otp/email_otp.dart';

import '../../../../infrastructure/navigation/routes.dart';
import '../../../../infrastructure/dal/services/interpreter_user.firestore.service.dart';
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
  final isSendingOtp = false.obs;

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

  Future<void> sendPasswordReset() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      AppSnackbar.error(
        title: 'Email Required',
        message: 'Enter your university email',
      );
      return;
    }
    AppSnackbar.info(
      title: 'Password Reset',
      message: 'Please contact support for password assistance',
    );
  }

  bool validateAll() {
    validateEmail();
    validatePassword();
    return isEmailValid.value && isPasswordValid.value;
  }

  Future<bool> _sendOtp(String email) async {
    try {
      final result = await EmailOTP.sendOTP(email: email);
      if (result == true) {
        return true;
      } else {
        throw Exception('Failed to send OTP');
      }
    } catch (e) {
      Get.log('Error sending OTP: $e');
      return false;
    }
  }

  Future<void> resendOtp() async {
    validateEmail();
    if (!isEmailValid.value) {
      AppSnackbar.error(
        title: 'Invalid Email',
        message: 'Please enter a valid email address',
      );
      return;
    }

    isSendingOtp.value = true;
    final success = await _sendOtp(emailController.text.trim());

    if (success) {
      AppSnackbar.success(
        title: 'OTP Resent',
        message: 'New verification code sent to your email',
      );
    } else {
      AppSnackbar.error(
        title: 'Error',
        message: 'Failed to resend OTP',
      );
    }

    isSendingOtp.value = false;
  }

  Future<void> submit() async {
    if (!validateAll()) {
      AppSnackbar.error(
        title: 'Invalid Email',
        message: 'Please enter a valid email address',
      );
      return;
    }

    isSubmitting.value = true;

    try {
      // Check if user exists in Firestore
      final existingUser =
          await _firestoreService.findByEmail(emailController.text.trim());
      if (existingUser == null) {
        AppSnackbar.warning(
          title: 'Account Not Found',
          message: 'No account found with this email. Please sign up first.',
        );
        isSubmitting.value = false;
        return;
      }

      // User exists, proceed with OTP
      final success = await _sendOtp(emailController.text.trim());

      if (success) {
        AppSnackbar.success(
          title: 'OTP Sent',
          message: 'Verification code sent to your email',
        );

        Get.toNamed(Routes.INTERPRETER_OTP, arguments: {
          'email': emailController.text.trim(),
          'isSignin': true, // Flag to indicate this is signin flow
          'interpreterUser': existingUser.toMap(),
        });
      } else {
        AppSnackbar.error(
          title: 'Error',
          message: 'Failed to send OTP',
        );
      }
    } catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Failed to check account: ${e.toString()}',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
