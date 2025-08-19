import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:email_otp/email_otp.dart';

class InteerpreterController extends GetxController {
  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final otpController = TextEditingController();

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

  Future<void> sendOtp() async {
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
      await EmailOTP.sendOTP(email: emailController.text.trim());
      isOtpSent.value = true;
      Get.snackbar('OTP Sent', 'Verification code sent to your email',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900]);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send OTP: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
    } finally {
      isSendingOtp.value = false;
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
    try {
      await EmailOTP.sendOTP(email: emailController.text.trim());
      Get.snackbar('OTP Resent', 'New verification code sent to your email',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900]);
    } catch (e) {
      Get.snackbar('Error', 'Failed to resend OTP: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
    } finally {
      isSendingOtp.value = false;
    }
  }

  Future<void> verifyOtp() async {
    if (otpController.text.trim().isEmpty) {
      Get.snackbar('OTP Required', 'Please enter the verification code',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
      return;
    }

    isVerifyingOtp.value = true;
    try {
      final isValid = EmailOTP.verifyOTP(otp: otpController.text.trim());
      if (isValid) {
        isOtpVerified.value = true;
        Get.snackbar('Success', 'Email verified successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green[100],
            colorText: Colors.green[900]);
      } else {
        Get.snackbar('Invalid OTP', 'Please check your verification code',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100],
            colorText: Colors.red[900]);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to verify OTP: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
    } finally {
      isVerifyingOtp.value = false;
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

    if (!isOtpVerified.value) {
      Get.snackbar(
          'Email Verification Required', 'Please verify your email first',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
      return;
    }

    isSubmitting.value = true;
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      Get.snackbar('Success', 'Interpreter account created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900]);
      // Navigate to home or next step
      // Get.offAllNamed(Routes.HOME);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create account: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
