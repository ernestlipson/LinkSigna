import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:email_otp/email_otp.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../infrastructure/navigation/routes.dart';
import '../../../../infrastructure/dal/services/interpreter_user.firestore.service.dart';
import '../../../../domain/users/interpreter_user.model.dart';
import '../../../presentation/shared/controllers/interpreter_profile.controller.dart';

class InterpreterOtpController extends GetxController {
  // OTP Controllers for 6 separate boxes
  late List<TextEditingController> otpControllers;
  late List<FocusNode> focusNodes;
  final focusedIndex = 0.obs;

  // Arguments from previous screen
  final email = ''.obs;
  final name = ''.obs;
  final isSignin = false.obs;
  final Rx<InterpreterUser?> existingUser = Rx<InterpreterUser?>(null);

  // Loading state
  final RxBool isVerifyingOtp = false.obs;
  final RxBool isResendingOtp = false.obs;

  // Timer for resend OTP
  final RxInt resendTimer = 60.obs;
  final RxBool canResend = false.obs;

  // Services
  final InterpreterUserFirestoreService _firestoreService =
      Get.find<InterpreterUserFirestoreService>();

  @override
  void onInit() {
    super.onInit();

    // Initialize OTP controllers and focus nodes
    otpControllers = List.generate(6, (index) => TextEditingController());
    focusNodes = List.generate(6, (index) => FocusNode());

    // Get email, name, and signin flag from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (args['email'] != null) email.value = args['email'];
      if (args['name'] != null) name.value = args['name'];
      if (args['isSignin'] != null) isSignin.value = args['isSignin'];
      if (args['interpreterUser'] != null) {
        final userData = args['interpreterUser'] as Map<String, dynamic>;
        // Create a temporary document snapshot to use fromFirestore
        existingUser.value = InterpreterUser(
          interpreterID: userData['interpreter_id'] ?? '',
          firstName: userData['firstName'] ?? '',
          lastName: userData['lastName'] ?? '',
          email: userData['email'] ?? '',
          phone: userData['phone'],
          languages: List<String>.from(userData['languages'] ?? []),
          specializations: List<String>.from(userData['specializations'] ?? []),
          rating: (userData['rating'] ?? 0.0).toDouble(),
          bio: userData['bio'],
          isAvailable: userData['isAvailable'] ?? false,
          profilePictureUrl: userData['profilePictureUrl'],
        );
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

      InterpreterUser interpreterUser;

      if (isSignin.value && existingUser.value != null) {
        // Signin flow - use existing user data
        interpreterUser = existingUser.value!;

        Get.snackbar('Success', 'Welcome back, ${interpreterUser.firstName}!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green[100],
            colorText: Colors.green[900]);
      } else {
        // Signup flow - create new user
        // Parse name into first and last name
        final nameParts = name.value.trim().split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : '';
        final lastName =
            nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';

        // Check if user already exists (for redundancy)
        final existing = await _firestoreService.findByEmail(email.value);
        if (existing != null) {
          interpreterUser = existing;
          Get.snackbar('Info', 'Account already exists. Signing you in.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.blue[100],
              colorText: Colors.blue[900]);
        } else {
          // Create new Firestore document for interpreter
          interpreterUser = await _firestoreService.createNew(
            firstName: firstName,
            lastName: lastName,
            email: email.value,
          );

          Get.snackbar('Success', 'Account created successfully!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green[100],
              colorText: Colors.green[900]);
        }
      }

      // Store interpreter data in SharedPreferences for redundancy
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('interpreter_logged_in', true);
      await prefs.setString('interpreter_id', interpreterUser.interpreterID);
      await prefs.setString('interpreter_email', interpreterUser.email);
      await prefs.setString('interpreter_name', interpreterUser.displayName);

      // Set profile in profile controller if it exists
      if (Get.isRegistered<InterpreterProfileController>()) {
        final profileController = Get.find<InterpreterProfileController>();
        profileController.setProfile(interpreterUser);
      }

      // Navigate to interpreter home screen
      Get.offAllNamed(Routes.INTERPRETER_HOME);
    } catch (e) {
      String errorMessage = 'Invalid OTP. Please try again.';
      if (e.toString().contains('email-already-in-use') ||
          e.toString().contains('already exists')) {
        errorMessage =
            'Account with this email already exists. Please sign in instead.';
      }

      Get.snackbar('Error', errorMessage,
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
