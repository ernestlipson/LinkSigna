import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/controllers/country.controller.dart';
import '../../utils/screens.strings.dart';

class ForgotPasswordController extends GetxController {
  final phoneController = TextEditingController();
  final isPhoneValid = true.obs;
  final phoneErrorMessage = ''.obs;
  final isLoading = false.obs;

  // Get the shared country controller
  CountryController get countryController => Get.find<CountryController>();

  @override
  void onInit() {
    super.onInit();
    // Listen to phone input changes and validate in real-time
    phoneController.addListener(_onPhoneChanged);
  }

  @override
  void onClose() {
    phoneController.removeListener(_onPhoneChanged);
    phoneController.dispose();
    super.onClose();
  }

  void _onPhoneChanged() {
    validatePhone();
  }

  void validatePhone() {
    final phone = phoneController.text.trim();
    
    if (phone.isEmpty) {
      isPhoneValid.value = false;
      phoneErrorMessage.value = ScreenStrings.requiredFieldError;
      return;
    }

    // Check if phone contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      isPhoneValid.value = false;
      phoneErrorMessage.value = "Phone number must contain only digits";
      return;
    }

    // Check if phone number is exactly 10 digits
    if (phone.length != 10) {
      isPhoneValid.value = false;
      phoneErrorMessage.value = ScreenStrings.phoneValidationError;
      return;
    }

    isPhoneValid.value = true;
    phoneErrorMessage.value = '';
  }

  Future<void> sendVerificationCode() async {
    validatePhone();
    if (!isPhoneValid.value) return;

    isLoading.value = true;
    try {
      // Simulate API call to send verification code
      await Future.delayed(const Duration(seconds: 2));
      Get.snackbar(
          'Success', 'A 6-digit code has been sent to ${phoneController.text}',
          snackPosition: SnackPosition.BOTTOM);

      // Navigate to verification code screen (You'll need to create this later)
      // Get.toNamed(Routes.VERIFICATION_CODE);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send verification code',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
