import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/repositories/auth.repo.dart';
import '../../../infrastructure/navigation/routes.dart';

class OtpController extends GetxController {
  final IAuthRepo authRepo = Get.find<IAuthRepo>();
  
  final otpController = TextEditingController();
  
  // Arguments from previous screen
  late String userId;
  late String phoneNumber;
  
  // Loading state
  final RxBool isVerifyingOtp = false.obs;
  final RxBool isResendingOtp = false.obs;
  
  // Timer for resend OTP
  final RxInt resendTimer = 60.obs;
  final RxBool canResend = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Get arguments from previous screen
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      userId = args['userId'] ?? '';
      phoneNumber = args['phone'] ?? '';
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

  Future<void> verifyOTP() async {
    if (otpController.text.trim().isEmpty || otpController.text.trim().length != 6) {
      Get.snackbar('Error', 'Please enter a valid 6-digit OTP',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isVerifyingOtp.value = true;
    try {
      final user = await authRepo.verifyOtp(userId, otpController.text.trim());
      
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
      final newUserId = await authRepo.sendOtp(phoneNumber);
      userId = newUserId; // Update userId for new OTP
      
      Get.snackbar('Success', 'OTP sent again to your phone',
          snackPosition: SnackPosition.BOTTOM);
      
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
    otpController.dispose();
    super.onClose();
  }
}
