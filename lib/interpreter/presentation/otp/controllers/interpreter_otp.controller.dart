import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:email_otp/email_otp.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../infrastructure/navigation/routes.dart';

class InterpreterOtpController extends GetxController {
  // OTP Controllers for 6 separate boxes
  late List<TextEditingController> otpControllers;
  late List<FocusNode> focusNodes;
  final focusedIndex = 0.obs;

  // Arguments from previous screen
  final email = ''.obs;

  // Loading state
  final RxBool isVerifyingOtp = false.obs;
  final RxBool isResendingOtp = false.obs;

  // Timer for resend OTP
  final RxInt resendTimer = 60.obs;
  final RxBool canResend = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize OTP controllers and focus nodes
    otpControllers = List.generate(6, (index) => TextEditingController());
    focusNodes = List.generate(6, (index) => FocusNode());

    // Get email from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['email'] != null) {
      email.value = args['email'];
    }

    startResendTimer();
  }

  void startResendTimer() {
    canResend.value = false;
    resendTimer.value = 60;

    // Countdown timer
    Stream.periodic(const Duration(seconds: 1), (i) => 60 - i - 1)
        .take(60)
        .listen((time) {
      resendTimer.value = time;
      if (time == 0) {
        canResend.value = true;
      }
    });
  }

  void onOtpChanged(int index, String value) {
    if (value.isNotEmpty) {
      // Move to next field if current field is filled
      if (index < 5) {
        focusNodes[index + 1].requestFocus();
        focusedIndex.value = index + 1;
      }
    } else {
      // Move to previous field if current field is cleared
      if (index > 0) {
        focusNodes[index - 1].requestFocus();
        focusedIndex.value = index - 1;
      }
    }
  }

  String getOtpCode() {
    return otpControllers.map((controller) => controller.text).join();
  }

  void clearOtpFields() {
    for (var controller in otpControllers) {
      controller.clear();
    }
    // Focus on first field
    focusNodes[0].requestFocus();
    focusedIndex.value = 0;
  }

  Future<void> verifyOTP() async {
    final otpCode = getOtpCode();
    if (otpCode.isEmpty || otpCode.length != 6) {
      Get.snackbar('Error', 'Please enter a valid 6-digit OTP',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
      return;
    }

    isVerifyingOtp.value = true;
    try {
      final isValid = EmailOTP.verifyOTP(otp: otpCode);
      if (isValid != true) {
        throw Exception('Invalid OTP');
      }

      // Mark that interpreter has logged in before
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('interpreter_logged_in', true);

      // Store interpreter data
      final args = Get.arguments as Map<String, dynamic>?;
      if (args != null && args['name'] != null) {
        await prefs.setString('userName', args['name']);
      }
      await prefs.setString('userEmail', email.value);

      Get.snackbar('Success', 'Email verified successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900]);

      // Navigate to interpreter home screen
      Get.offAllNamed(Routes.INTERPRETER_HOME);
    } catch (e) {
      Get.snackbar('Error', 'Invalid OTP. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
      // Clear OTP fields on error
      clearOtpFields();
    } finally {
      isVerifyingOtp.value = false;
    }
  }

  Future<void> resendOTP() async {
    if (!canResend.value) return;

    isResendingOtp.value = true;
    try {
      final result = await EmailOTP.sendOTP(email: email.value);
      if (result == true) {
        Get.snackbar('Success', 'OTP sent again to your email',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green[100],
            colorText: Colors.green[900]);

        // Clear OTP fields for new code
        clearOtpFields();
        startResendTimer();
      } else {
        throw Exception('Failed to resend OTP');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to resend OTP: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
    } finally {
      isResendingOtp.value = false;
    }
  }

  @override
  void onClose() {
    // Dispose all OTP controllers and focus nodes
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.onClose();
  }
}
