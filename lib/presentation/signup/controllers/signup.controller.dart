import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/controllers/country.controller.dart';

class SignupController extends GetxController {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isTermsAccepted = false.obs;
  final RxBool isPasswordVisible = false.obs;
  CountryController get countryController => Get.find<CountryController>();

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  final isNameValid = true.obs;
  final isPhoneValid = true.obs;
  final isPasswordValid = true.obs;

  void validateName() {
    isNameValid.value = nameController.text.trim().isNotEmpty;
  }

  void validatePhone() {
    isPhoneValid.value = phoneController.text.trim().isNotEmpty;
  }

  void validatePassword() {
    isPasswordValid.value = passwordController.text.trim().isNotEmpty;
  }

  bool validateAll() {
    validateName();
    validatePhone();
    validatePassword();
    return isNameValid.value && isPhoneValid.value && isPhoneValid.value;
  }

  void signUp() {
    final isFormValid = validateAll();
    if (!isFormValid) return;
    Get.snackbar('Success', 'All fields are valid!',
        snackPosition: SnackPosition.BOTTOM);
  }
}
