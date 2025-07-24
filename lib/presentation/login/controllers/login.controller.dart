import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/google.signin.service.dart';
import '../../shared/controllers/country.controller.dart';

class LoginController extends GetxController {
  GoogleSignInService googleSignInService = GoogleSignInService.initialize;
  // Controllers to read the text values
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isTermsAccepted = false.obs;

  // Add this to your LoginController class
  final RxBool isPasswordVisible = false.obs;

  // Remember me state
  final RxBool isRememberMe = false.obs;

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

  Future<void> signInWithGoogle() async {
    try {
      final user = await GoogleSignInService.instance.signInWithGoogle();
      if (user != null) {
        Get.snackbar('Google Sign-In', 'Sign-in successful!',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Google Sign-In', 'Sign-in failed: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
