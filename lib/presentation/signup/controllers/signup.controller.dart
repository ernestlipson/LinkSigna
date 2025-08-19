import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:email_otp/email_otp.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../infrastructure/dal/services/google.signin.service.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../components/coming.soon.placeholder.dart';
import '../../shared/controllers/country.controller.dart';
import '../../shared/controllers/user.controller.dart';

class SignupController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  // User type selection
  final RxString selectedUserType = 'student'.obs;

  // Loading states
  final RxBool isEmailOtpLoading = false.obs;
  final RxBool isGoogleSignInLoading = false.obs;

  // OTP related
  final RxString otpUserId = ''.obs;

  final RxBool isTermsAccepted = false.obs;
  CountryController get countryController => Get.find<CountryController>();

  final isNameValid = true.obs;
  final isEmailValid = true.obs;

  void validateName() {
    isNameValid.value = nameController.text.trim().isNotEmpty;
  }

  void validateEmail() {
    final value = emailController.text.trim();
    // Simple email regex validation
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    isEmailValid.value = emailRegex.hasMatch(value);
  }

  bool validateAll() {
    validateName();
    validateEmail();
    return isNameValid.value && isEmailValid.value && isTermsAccepted.value;
  }

  Future<void> signUp() async {
    final isFormValid = validateAll();
    if (!isFormValid) return;

    // Check if user type is interpreter
    if (selectedUserType.value == 'interpreter') {
      // Show placeholder screen for interpreter
      Get.to(() => const ComingSoonPlaceholder());
      return;
    }

    isEmailOtpLoading.value = true;
    try {
      final email = emailController.text.trim();
      final sent = await EmailOTP.sendOTP(email: email);
      if (!sent) {
        throw Exception('Failed to send OTP');
      }

      // Save user name to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', nameController.text.trim());

      Get.snackbar('Success', 'OTP sent to your email',
          snackPosition: SnackPosition.BOTTOM);
      Get.toNamed(Routes.OTP, arguments: {'email': email});
    } catch (e) {
      Get.snackbar('Error', 'Failed to send OTP: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isEmailOtpLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    isGoogleSignInLoading.value = true;
    try {
      final user = await GoogleSignInService.instance.signInWithGoogle();
      if (user != null) {
        if (!Get.isRegistered<UserController>()) {
          Get.put(UserController());
        }
        final userController = Get.find<UserController>();
        userController.setUser(name: user.displayName, photo: user.photoUrl);
        Get.snackbar('Success', 'Welcome ${user.displayName ?? 'User'}!',
            snackPosition: SnackPosition.BOTTOM);
        // Navigate to home or wherever appropriate
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      Get.snackbar('Error', 'Google Sign-in failed: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isGoogleSignInLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();

    if (!Get.isRegistered<GoogleSignInService>()) {
      Get.put(GoogleSignInService());
    }
  }
}
