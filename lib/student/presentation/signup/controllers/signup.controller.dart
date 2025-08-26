import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:email_otp/email_otp.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../infrastructure/dal/services/google.signin.service.dart';
import '../../../infrastructure/dal/services/country.service.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../components/coming.soon.placeholder.dart';
import '../../shared/controllers/country.controller.dart';
import '../../shared/controllers/user.controller.dart';

class SignupController extends GetxController {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // User type selection
  final RxString selectedUserType = 'student'.obs;

  // Loading states
  final RxBool isPhoneOtpLoading = false.obs;
  final RxBool isGoogleSignInLoading = false.obs;

  // OTP related
  final RxString otpUserId = ''.obs;

  final RxBool isTermsAccepted = false.obs;
  CountryController get countryController => Get.find<CountryController>();

  final isNameValid = true.obs;
  final isPhoneValid = true.obs;

  // Country flag for phone field
  final RxString countryFlagUrl = ''.obs;
  final RxBool isLoadingFlag = false.obs;

  void validateName() {
    isNameValid.value = nameController.text.trim().isNotEmpty;
  }

  void validatePhone() {
    final value = phoneController.text.trim();
    // Simple phone validation - should be 10 digits
    final phoneRegex = RegExp(r'^\d{10}$');
    isPhoneValid.value = phoneRegex.hasMatch(value);
  }

  bool validateAll() {
    validateName();
    validatePhone();
    return isNameValid.value && isPhoneValid.value && isTermsAccepted.value;
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

    isPhoneOtpLoading.value = true;
    try {
      final phone = phoneController.text.trim();
      // For now, we'll use a mock email for OTP since EmailOTP requires email
      // In a real app, you'd use SMS OTP or email the user
      final mockEmail = 'user@linksigna.com';
      final sent = await EmailOTP.sendOTP(email: mockEmail);
      if (!sent) {
        throw Exception('Failed to send OTP');
      }

      // Save user name to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', nameController.text.trim());

      Get.snackbar('Success', 'OTP sent to your phone',
          snackPosition: SnackPosition.BOTTOM);
      Get.toNamed(Routes.OTP, arguments: {'email': mockEmail});
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

    if (!Get.isRegistered<GoogleSignInService>()) {
      Get.put(GoogleSignInService());
    }

    // Fetch country flag for phone field
    fetchCountryFlag();
  }

  Future<void> fetchCountryFlag() async {
    try {
      isLoadingFlag.value = true;
      final countryController = Get.find<CountryController>();
      await countryController.fetchCountryFlag();

      // Get the flag URL from the country controller
      if (countryController.countryFlag.value != null) {
        // Use PNG for better compatibility
        countryFlagUrl.value = countryController.countryFlag.value!.png;
      } else {
        // Fallback to Ghana flag if no flag is available
        countryFlagUrl.value = 'https://flagcdn.com/w40/gh.png';
      }
    } catch (e) {
      Get.log('Error fetching country flag: $e');
      // Fallback to Ghana flag on error
      countryFlagUrl.value = 'https://flagcdn.com/w40/gh.png';
    } finally {
      isLoadingFlag.value = false;
    }
  }
}
