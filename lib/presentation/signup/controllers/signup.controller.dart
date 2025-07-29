import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/infrastructure/dal/services/firebase.auth.service.dart';

import '../../../infrastructure/dal/services/google.signin.service.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../shared/controllers/country.controller.dart';
import '../../shared/controllers/user.controller.dart';

class SignupController extends GetxController {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // Inject FirebaseAuthService
  late final FirebaseAuthService firebaseAuthService;

  // Loading states
  final RxBool isPhoneOtpLoading = false.obs;
  final RxBool isGoogleSignInLoading = false.obs;

  // OTP related
  final RxString otpUserId = ''.obs;

  final RxBool isTermsAccepted = false.obs;
  CountryController get countryController => Get.find<CountryController>();

  final isNameValid = true.obs;
  final isPhoneValid = true.obs;

  void validateName() {
    isNameValid.value = nameController.text.trim().isNotEmpty;
  }

  void validatePhone() {
    isPhoneValid.value = phoneController.text.trim().isNotEmpty;
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
      // The phone number from InternationalPhoneNumberInput is already in E.164 format
      String phoneNumber = phoneController.text.trim();

      // Request OTP using FirebaseAuthService
      await firebaseAuthService.requestPhoneOTP(phoneNumber);

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

    // Initialize FirebaseAuthService
    firebaseAuthService = Get.find<FirebaseAuthService>();

    if (!Get.isRegistered<GoogleSignInService>()) {
      Get.put(GoogleSignInService());
    }
  }
}
