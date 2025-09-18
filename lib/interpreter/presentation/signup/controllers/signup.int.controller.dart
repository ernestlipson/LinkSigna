import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:email_otp/email_otp.dart';

import '../../../../infrastructure/navigation/routes.dart';

class InterpreterSignupController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  // Validation state
  final isNameValid = true.obs;
  final isEmailValid = true.obs;
  final isTermsAccepted = false.obs;
  final isOtpSent = false.obs;
  final isOtpVerified = false.obs;

  final isSubmitting = false.obs;
  final isSendingOtp = false.obs;
  final isVerifyingOtp = false.obs;

  void validateName() {
    isNameValid.value = nameController.text.trim().isNotEmpty;
  }

  void validateEmail() {
    final email = emailController.text.trim();
    isEmailValid.value = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  bool validateAll() {
    validateName();
    validateEmail();
    return isNameValid.value && isEmailValid.value && isTermsAccepted.value;
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
    try {
      final result = await EmailOTP.sendOTP(email: emailController.text.trim());
      if (result == true) {
        Get.snackbar('OTP Resent', 'New verification code sent to your email',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green[100],
            colorText: Colors.green[900]);
      } else {
        throw Exception('Failed to resend OTP');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to resend OTP: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
    } finally {
      isSendingOtp.value = false;
    }
  }

  Future<void> submit() async {
    if (!validateAll()) {
      if (!isTermsAccepted.value) {
        Get.snackbar('Terms Required', 'Please accept the terms to continue',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100],
            colorText: Colors.red[900]);
      }
      return;
    }

    isSubmitting.value = true;
    try {
      final result = await EmailOTP.sendOTP(email: emailController.text.trim());

      if (result == true) {
        Get.snackbar('OTP Sent', 'Verification code sent to your email',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green[100],
            colorText: Colors.green[900]);

        Get.toNamed(Routes.INTERPRETER_OTP, arguments: {
          'email': emailController.text.trim(),
          'name': nameController.text.trim(),
        });
      } else {
        throw Exception('Failed to send OTP');
      }
    } catch (e, stackTrace) {
      Get.snackbar('Error', 'Failed to send OTP: ${e.toString()} $stackTrace',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
      Get.log("Error: $e $stackTrace");
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
