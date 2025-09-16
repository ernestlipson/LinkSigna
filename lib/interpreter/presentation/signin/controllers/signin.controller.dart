import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:email_otp/email_otp.dart';

import '../../../../infrastructure/navigation/routes.dart';
import '../../../../infrastructure/dal/services/interpreter_user.firestore.service.dart';

class InterpreterSigninController extends GetxController {
  final emailController = TextEditingController();

  // Validation state
  final isEmailValid = true.obs;

  final isSubmitting = false.obs;
  final isSendingOtp = false.obs;

  // Services
  final InterpreterUserFirestoreService _firestoreService =
      Get.find<InterpreterUserFirestoreService>();

  void validateEmail() {
    final email = emailController.text.trim();
    isEmailValid.value = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  bool validateAll() {
    validateEmail();
    return isEmailValid.value;
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
      Get.snackbar('Invalid Email', 'Please enter a valid email address',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
      return;
    }

    isSendingOtp.value = true;
    final success = await _sendOtp(emailController.text.trim());

    if (success) {
      Get.snackbar('OTP Resent', 'New verification code sent to your email',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900]);
    } else {
      Get.snackbar('Error', 'Failed to resend OTP',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
    }

    isSendingOtp.value = false;
  }

  Future<void> submit() async {
    if (!validateAll()) {
      Get.snackbar('Invalid Email', 'Please enter a valid email address',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
      return;
    }

    isSubmitting.value = true;

    try {
      // Check if user exists in Firestore
      final existingUser =
          await _firestoreService.findByEmail(emailController.text.trim());
      if (existingUser == null) {
        Get.snackbar('Account Not Found',
            'No account found with this email. Please sign up first.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange[100],
            colorText: Colors.orange[900]);
        isSubmitting.value = false;
        return;
      }

      // User exists, proceed with OTP
      final success = await _sendOtp(emailController.text.trim());

      if (success) {
        Get.snackbar('OTP Sent', 'Verification code sent to your email',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green[100],
            colorText: Colors.green[900]);

        Get.toNamed(Routes.INTERPRETER_OTP, arguments: {
          'email': emailController.text.trim(),
          'isSignin': true, // Flag to indicate this is signin flow
          'interpreterUser': existingUser.toMap(),
        });
      } else {
        Get.snackbar('Error', 'Failed to send OTP',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100],
            colorText: Colors.red[900]);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to check account: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
