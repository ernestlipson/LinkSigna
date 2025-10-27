import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../infrastructure/navigation/routes.dart';
import '../../../../infrastructure/dal/services/student_user.firestore.service.dart';
import '../../../../infrastructure/utils/validation_utils.dart';
import '../../shared/controllers/country.controller.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';

class SignupController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final universityController = TextEditingController();

  // User type selection
  final RxString selectedUserType = 'student'.obs;

  // Loading states
  final RxBool isPhoneOtpLoading = false.obs;
  final RxBool isGoogleSignInLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  // OTP related
  final RxString otpUserId = ''.obs;

  final RxBool isTermsAccepted = false.obs;
  CountryController get countryController => Get.find<CountryController>();

  final isNameValid = true.obs;
  final isEmailValid = true.obs;
  final isPasswordValid = true.obs;
  final isPhoneValid = true.obs;
  final isUniversityValid = true.obs;

  // Selected university
  final RxString selectedUniversity = ''.obs;

  // Country flag for phone field
  final RxString countryFlagUrl = ''.obs;
  final RxBool isLoadingFlag = false.obs;

  void validateName() {
    isNameValid.value = ValidationUtils.isNotEmpty(nameController.text);
  }

  void validateEmail() {
    isEmailValid.value = ValidationUtils.isValidEmail(emailController.text);
  }

  void validatePassword() {
    isPasswordValid.value =
        ValidationUtils.isValidPassword(passwordController.text);
  }

  void validatePhone() {
    final value = phoneController.text.trim();
    final phoneRegex =
        RegExp(r'^(\+?233)?[0-9]{9}$|^(\+?233)?[0-9]{10}$|^[0-9]{10,15}$');
    isPhoneValid.value = phoneRegex.hasMatch(value);
  }

  void validateUniversity() {
    isUniversityValid.value = selectedUniversity.value.isNotEmpty;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  bool validateAll() {
    validateName();
    validateEmail();
    validatePassword();
    validateUniversity();
    return isNameValid.value &&
        isEmailValid.value &&
        isPasswordValid.value &&
        isUniversityValid.value &&
        isTermsAccepted.value;
  }

  Future<void> signUp() async {
    if (!validateAll()) {
      if (!isTermsAccepted.value) {
        AppSnackbar.warning(
          title: 'Terms Required',
          message: 'Please accept the terms to continue',
        );
      }
      return;
    }

    isPhoneOtpLoading.value = true;
    try {
      // Create Firebase Auth user with email/password
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Update Firebase Auth displayName
      await credential.user?.updateDisplayName(nameController.text.trim());

      // Create Firestore user document
      final studentService = Get.find<StudentUserFirestoreService>();
      await studentService.getOrCreateByAuthUid(
        authUid: credential.user!.uid,
        displayName: nameController.text.trim(),
        email: emailController.text.trim(),
        university: selectedUniversity.value,
      );

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('student_logged_in', true);
      await prefs.setString('userName', nameController.text.trim());
      await prefs.setString('userEmail', emailController.text.trim());

      // Navigate to home
      Get.offAllNamed(Routes.STUDENT_HOME);

      AppSnackbar.success(
        title: 'Success',
        message: 'Account created successfully!',
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Signup failed';
      if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists with this email';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format';
      }

      AppSnackbar.error(
        title: 'Signup Failed',
        message: errorMessage,
      );
    } catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Signup failed: ${e.toString()}',
      );
    } finally {
      isPhoneOtpLoading.value = false;
    }
  }

  final List<String> universities = [
    'Takoradi Technical University (TTU)',
    'University of Education, Winneba (UEW)',
    'Kwame Nkrumah University of Science and Technology (KNUST)',
    'University of Ghana, Legon',
    'Other Ghana University',
  ];

  void selectUniversity(String university) {
    selectedUniversity.value = university;
    universityController.text = university;
    validateUniversity();
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

      if (countryController.countryFlag.value != null) {
        countryFlagUrl.value = countryController.countryFlag.value!.png;
      } else {
        countryFlagUrl.value = 'https://flagcdn.com/w40/gh.png';
      }
    } catch (e) {
      Get.log('Error fetching country flag: $e');
      countryFlagUrl.value = 'https://flagcdn.com/w40/gh.png';
    } finally {
      isLoadingFlag.value = false;
    }
  }
}
