import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';
import '../../infrastructure/utils/validation_utils.dart';

mixin SignupMixin on GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isNameValid = true.obs;
  final isEmailValid = true.obs;
  final isPasswordValid = true.obs;
  final isUniversityValid = true.obs;
  final isTermsAccepted = false.obs;
  final isPasswordVisible = false.obs;
  final isSubmitting = false.obs;

  final RxString selectedUniversity = ''.obs;

  final List<String> universities = [
    'Takoradi Technical University (TTU)',
    'University of Education, Winneba (UEW)',
    'Kwame Nkrumah University of Science and Technology (KNUST)',
    'University of Ghana, Legon',
    'Other Ghana University',
  ];

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

  void validateUniversity() {
    isUniversityValid.value = selectedUniversity.value.isNotEmpty;
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

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void selectUniversity(String university) {
    selectedUniversity.value = university;
    validateUniversity();
  }

  void showTermsRequiredError() {
    AppSnackbar.warning(
      title: 'Terms Required',
      message: 'Please accept the terms to continue',
    );
  }

  void showFirebaseAuthError(String code) {
    String errorMessage = 'An error occurred. Please try again.';
    switch (code) {
      case 'email-already-in-use':
        errorMessage =
            'An account with this email already exists. Please sign in instead.';
        break;
      case 'weak-password':
        errorMessage =
            'Password is too weak. Please choose a stronger password.';
        break;
      case 'invalid-email':
        errorMessage = 'Please enter a valid email address.';
        break;
      case 'operation-not-allowed':
        errorMessage =
            'Email/password accounts are not enabled. Please contact support.';
        break;
    }
    AppSnackbar.error(
      title: 'Error',
      message: errorMessage,
    );
  }

  void disposeControllers() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  Future<UserCredential> createFirebaseAuthUser() async {
    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    await credential.user?.updateDisplayName(nameController.text.trim());
    return credential;
  }

  Map<String, String> parseFullName(String fullName) {
    final nameParts = fullName.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
    return {'firstName': firstName, 'lastName': lastName};
  }
}
