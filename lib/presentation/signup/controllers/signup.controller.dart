import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/entities/flag.entity.dart';
import '../../../domain/repositories/country.repo.dart';

class SignupController extends GetxController {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isTermsAccepted = false.obs;
  final RxBool isPasswordVisible = false.obs;

  final countryLoading = false.obs;

  final CountryRepository countryRepository = CountryRepository.instance;

  final Rx<Flag?> countryFlag = Rx<Flag?>(null);

  @override
  void onInit() {
    fetchCountryFlag();
    super.onInit();
  }

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

  void fetchCountryFlag() async {
    try {
      countryLoading.value = true;
      final flag = await countryRepository.getCountryFlag();
      countryFlag.value = flag;
      countryLoading.value = false;
    } catch (e, s) {
      Get.log("Fetch Flag: $e $s");
      Get.snackbar('Error', 'Failed to fetch country flag',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
