import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/infrastructure/navigation/routes.dart';

import '../../shared/controllers/country.controller.dart';

class LoginController extends GetxController {
  // Firebase removed

  // Controllers to read the text values
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isTermsAccepted = false.obs;

  // Add this to your LoginController class
  final RxBool isPasswordVisible = false.obs;

  // Remember me state
  final RxBool isRememberMe = false.obs;

  // Loading states
  final RxBool isPhoneOtpLoading = false.obs; // deprecated
  final RxBool isGoogleSignInLoading = false.obs;

  // OTP related
  final RxString otpUserId = ''.obs;

  // Get the shared country controller
  CountryController get countryController => Get.find<CountryController>();

  // Flag loading state (mirrors signup controller behavior)
  final RxBool isLoadingFlag = false.obs;
  final RxString countryFlagUrl = ''.obs;

  Future<void> fetchCountryFlag() async {
    try {
      isLoadingFlag.value = true;
      await countryController.fetchCountryFlag();
      if (countryController.countryFlag.value != null) {
        countryFlagUrl.value = countryController.countryFlag.value!.png;
      } else {
        countryFlagUrl.value = 'https://flagcdn.com/w40/gh.png';
      }
      // Log flag URL
      // ignore: avoid_print
      print('Login flag URL => ${countryFlagUrl.value}');
    } catch (e) {
      countryFlagUrl.value = 'https://flagcdn.com/w40/gh.png';
      // ignore: avoid_print
      print('Flag fetch error (login): $e');
    } finally {
      isLoadingFlag.value = false;
    }
  }

  // Add this method to toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Reactive validation states
  final isNameValid = true.obs;
  final isPhoneValid = true.obs;
  final isPasswordValid = true.obs;

  // Validation logic
  void validateName() {
    isNameValid.value = nameController.text.trim().isNotEmpty;
  }

  void validatePhone() {
    isPhoneValid.value = phoneController.text.trim().isNotEmpty;
  }

  void validatePassword() {
    isPasswordValid.value = passwordController.text.trim().isNotEmpty;
  }

  // Validate all fields at once (e.g., on form submit)
  bool validateAll() {
    validateName();
    validatePhone();
    validatePassword();
    return isNameValid.value && isPhoneValid.value && isPasswordValid.value;
  }

  // Phone OTP Authentication
  Future<void> sendPhoneOTP() async {
    if (phoneController.text.trim().isEmpty) {
      isPhoneValid.value = false;
      Get.snackbar('Phone Required', 'Enter your phone number',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isPhoneOtpLoading.value = true;
    final raw = phoneController.text.trim();
    // Basic Ghana formatting fallback
    final formatted = raw.startsWith('+')
        ? raw
        : (raw.startsWith('0') ? '+233${raw.substring(1)}' : '+233$raw');
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formatted,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Optional: Auto-sign in handler; skipping immediate signIn to preserve manual OTP UX
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar('OTP Failed', e.message ?? 'Verification failed',
              snackPosition: SnackPosition.BOTTOM);
          isPhoneOtpLoading.value = false;
        },
        codeSent: (String verificationId, int? resendToken) async {
          // Persist phone locally for subsequent profile creation
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userPhone', formatted);
          await prefs.setString(
              'userName',
              nameController.text.trim().isEmpty
                  ? 'User'
                  : nameController.text.trim());
          // Navigate to OTP screen
          Get.toNamed(Routes.STUDENT_OTP, arguments: {
            'phone': formatted,
            'verificationId': verificationId,
          });
          isPhoneOtpLoading.value = false;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Timeout - user can request resend
        },
      );
    } catch (e) {
      isPhoneOtpLoading.value = false;
      Get.snackbar('Error', 'Could not send OTP: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('student_logged_in') ?? false) {
        Get.offAllNamed(Routes.STUDENT_HOME);
      }
    } catch (e) {
      print('Error checking auth status: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
    fetchCountryFlag();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
