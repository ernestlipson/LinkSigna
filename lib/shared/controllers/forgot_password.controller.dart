import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../infrastructure/utils/app_strings.dart';
import '../../infrastructure/dal/services/firebase.exception.dart';
import '../components/app.snackbar.dart';

class ForgotPasswordController extends GetxController
    with FirebaseExceptionMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final isEmailValid = true.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to email input changes and validate in real-time
    emailController.addListener(_onEmailChanged);
  }

  @override
  void onClose() {
    emailController.removeListener(_onEmailChanged);
    emailController.dispose();
    super.onClose();
  }

  void _onEmailChanged() {
    validateEmail();
  }

  void validateEmail() {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      isEmailValid.value = true; // Don't show error for empty field
      return;
    }

    // Validate email format and .gh domain
    isEmailValid.value = RegExp(r'^[^@\s]+@[^@\s]+\.gh$').hasMatch(email);
  }

  Future<void> sendVerificationCode() async {
    validateEmail();

    if (emailController.text.trim().isEmpty) {
      AppSnackbar.error(
        title: 'Error',
        message: AppStrings.requiredFieldError,
      );
      return;
    }

    if (!isEmailValid.value) {
      AppSnackbar.error(
        title: 'Error',
        message: AppStrings.emailValidationError,
      );
      return;
    }

    isLoading.value = true;
    try {
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());
      AppSnackbar.success(
        title: 'Success',
        message:
            'A password reset link has been sent to ${emailController.text}',
      );
      Get.back();
    } on FirebaseAuthException catch (e) {
      handleFirebaseAuthException(
        e,
        defaultMessage: 'Failed to send password reset link',
      );
    } catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: 'An unexpected error occurred. Please try again',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
