import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../infrastructure/navigation/routes.dart';
import '../../shared/controllers/country.controller.dart';

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
    final phoneRegex =
        RegExp(r'^(\+?233)?[0-9]{9}$|^(\+?233)?[0-9]{10}$|^[0-9]{10,15}$');
    isPhoneValid.value = phoneRegex.hasMatch(value);
  }

  bool validateAll() {
    validateName();
    validatePhone();
    return isNameValid.value && isPhoneValid.value && isTermsAccepted.value;
  }

  Future<void> signUp() async {
    if (!validateAll()) {
      if (!isTermsAccepted.value) {
        Get.snackbar(
          'Terms Required',
          'Please accept the terms to continue',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      }
      return;
    }

    isPhoneOtpLoading.value = true;
    try {
      final phone = phoneController.text.trim();
      await verifyPhoneNumber(phone);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', nameController.text.trim());
      await prefs.setString('userPhone', phone);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send OTP: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isPhoneOtpLoading.value = false;
    }
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber.startsWith('+233')
            ? phoneNumber
            : '+233${phoneNumber.startsWith('0') ? phoneNumber.substring(1) : phoneNumber}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar(
              'Error', 'Failed to verify phone number: ${e.toString()}',
              snackPosition: SnackPosition.BOTTOM);
        },
        codeSent: (String verificationId, int? resendToken) {
          otpUserId.value = verificationId;
          Get.toNamed(Routes.STUDENT_OTP, arguments: {
            'phone': phoneNumber,
            'verificationId': verificationId,
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {}
  }

  @override
  void onInit() {
    super.onInit();
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
