import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/firebase.auth.service.dart';
import '../../../infrastructure/dal/services/google.signin.service.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../shared/controllers/country.controller.dart';

class LoginController extends GetxController {
  late final FirebaseAuthService firebaseAuthService;

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
  final RxBool isPhoneOtpLoading = false.obs;
  final RxBool isGoogleSignInLoading = false.obs;

  // OTP related
  final RxString otpUserId = ''.obs;

  // Get the shared country controller
  CountryController get countryController => Get.find<CountryController>();

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
    if (!isPhoneValid.value || phoneController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a valid phone number',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isPhoneOtpLoading.value = true;
    try {
      await firebaseAuthService.requestPhoneOTP(phoneController.text.trim());

      Get.snackbar('Success', 'OTP sent to your phone',
          snackPosition: SnackPosition.BOTTOM);

      // Navigate to OTP screen with phone number
      Get.toNamed(Routes.OTP,
          arguments: {'phone': phoneController.text.trim()});
    } catch (e) {
      Get.snackbar('Error', 'Failed to send OTP: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isPhoneOtpLoading.value = false;
    }
  }

  // Google Authentication
  Future<void> signInWithGoogle() async {
    isGoogleSignInLoading.value = true;
    try {
      // For now, we'll keep the Google Sign-in service separate
      // You can integrate Firebase Google Auth later if needed
      final user = await GoogleSignInService.instance.signInWithGoogle();
      if (user != null) {
        Get.snackbar('Success', 'Welcome! Google sign-in successful',
            snackPosition: SnackPosition.BOTTOM);
        // Navigate to home screen
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      Get.snackbar('Error', 'Google Sign-in failed: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isGoogleSignInLoading.value = false;
    }
  }

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    try {
      final isLoggedIn = firebaseAuthService.isLoggedIn();
      if (isLoggedIn) {
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      print('Error checking auth status: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    firebaseAuthService = Get.find<FirebaseAuthService>();

    checkAuthStatus();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
