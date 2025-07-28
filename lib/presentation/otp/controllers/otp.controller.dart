import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/repositories/auth.repo.dart';
import '../../../infrastructure/navigation/routes.dart';

class OtpController extends GetxController {
  final IAuthRepo authRepo = Get.find<IAuthRepo>();

  // OTP Controllers for 6 separate boxes
  late List<TextEditingController> otpControllers;
  late List<FocusNode> focusNodes;
  final focusedIndex = 0.obs;

  // Arguments from previous screen
  late String userId;
  final phoneNumber = ''.obs;

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

    // Get arguments from previous screen
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      userId = args['userId'] ?? '';
      phoneNumber.value = args['phone'] ?? '';
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
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isVerifyingOtp.value = true;
    try {
      final user = await authRepo.verifyOtp(userId, otpCode);

      Get.snackbar('Success', 'Welcome ${user.name ?? 'User'}!',
          snackPosition: SnackPosition.BOTTOM);

      // Navigate to home screen
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      Get.snackbar('Error', 'Invalid OTP. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isVerifyingOtp.value = false;
    }
  }

  Future<void> resendOTP() async {
    if (!canResend.value) return;

    isResendingOtp.value = true;
    try {
      final newUserId = await authRepo.sendOtp(phoneNumber.value);
      userId = newUserId; // Update userId for new OTP

      Get.snackbar('Success', 'OTP sent again to your phone',
          snackPosition: SnackPosition.BOTTOM);

      // Clear OTP fields for new code
      clearOtpFields();
      startResendTimer();
    } catch (e) {
      Get.snackbar('Error', 'Failed to resend OTP: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
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
