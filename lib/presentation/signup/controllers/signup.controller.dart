import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/repositories/auth.repo.dart';
import '../../../infrastructure/dal/services/google.signin.service.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../shared/controllers/country.controller.dart';
import '../../shared/controllers/user.controller.dart';

class SignupController extends GetxController {
  final IAuthRepo authRepo = Get.find<IAuthRepo>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // Loading states
  final RxBool isPhoneOtpLoading = false.obs;
  final RxBool isGoogleSignInLoading = false.obs;

  // OTP related
  final RxString otpUserId = ''.obs;

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
    return isNameValid.value && isPhoneValid.value;
  }

  Future<void> signUp() async {
    final isFormValid = validateAll();
    if (!isFormValid) return;

    isPhoneOtpLoading.value = true;
    try {
      // final userId = await authRepo.sendOtp(phoneController.text.trim());
      // otpUserId.value = userId;

      Get.snackbar('Success', 'OTP sent to your phone',
          snackPosition: SnackPosition.BOTTOM);

      // Navigate to OTP screen with userId
      Get.toNamed(Routes.OTP, arguments: {
        'userId': "userId",
        'phone': phoneController.text.trim()
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to send OTP:  ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isPhoneOtpLoading.value = false;
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
