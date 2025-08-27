import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../infrastructure/navigation/routes.dart';
import '../../shared/controllers/user.controller.dart';

class OtpController extends GetxController {
  // OTP Controllers for 6 separate boxes
  late List<TextEditingController> otpControllers;
  late List<FocusNode> focusNodes;
  final focusedIndex = 0.obs;

  // Arguments from previous screen
  late String userId;
  final destination = ''.obs; // email or phone
  final isEmailFlow = false.obs;
  final verificationId = ''.obs; // Firebase verification ID for phone

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
      if ((args['email'] ?? '').toString().isNotEmpty) {
        destination.value = args['email'];
        isEmailFlow.value = true;
      } else if ((args['phone'] ?? '').toString().isNotEmpty) {
        destination.value = args['phone'];
        isEmailFlow.value = false;
        // Store verification ID for phone verification
        verificationId.value = args['verificationId'] ?? '';
      }
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
      if (isEmailFlow.value) {
        // Email OTP verification
        final isValid = await EmailOTP.verifyOTP(otp: otpCode);
        if (!isValid) {
          throw Exception('Invalid OTP');
        }
      } else {
        // Phone OTP verification using Firebase
        if (verificationId.value.isEmpty) {
          throw Exception('Verification ID not found');
        }

        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId.value,
          smsCode: otpCode,
        );

        // Sign in with the credential
        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      // Mark that user has logged in before
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_logged_in_before', true);

      // Load user data and set it in UserController
      final userName = prefs.getString('userName') ?? 'User';
      final userPhone = prefs.getString('userPhone') ?? '';
      if (!Get.isRegistered<UserController>()) {
        Get.put(UserController());
      }
      final userController = Get.find<UserController>();
      userController.setUser(name: userName, phone: userPhone);

      // Navigate to home page and clear navigation stack
      Get.offAllNamed(StudentRoutes.HOME);
    } catch (e) {
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
      if (isEmailFlow.value) {
        // Resend email OTP
        await EmailOTP.sendOTP(email: destination.value);
        Get.snackbar('Success', 'OTP sent again to your email',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        // Resend phone OTP using Firebase
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: destination.value,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await FirebaseAuth.instance.signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            Get.snackbar('Error', 'Failed to resend OTP: ${e.message}',
                snackPosition: SnackPosition.BOTTOM);
          },
          codeSent: (String newVerificationId, int? resendToken) {
            verificationId.value = newVerificationId;
            Get.snackbar('Success', 'OTP sent again to your phone',
                snackPosition: SnackPosition.BOTTOM);
          },
          codeAutoRetrievalTimeout: (String newVerificationId) {
            verificationId.value = newVerificationId;
          },
          forceResendingToken:
              null, // You can implement this for better resend functionality
        );
      }

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
