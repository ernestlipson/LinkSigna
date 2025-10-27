import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../infrastructure/navigation/routes.dart';
import '../../../../infrastructure/dal/services/interpreter_user.firestore.service.dart';
import '../../../../infrastructure/utils/validation_utils.dart';

class InterpreterSignupController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Validation state
  final isNameValid = true.obs;
  final isEmailValid = true.obs;
  final isPasswordValid = true.obs;
  final isUniversityValid = true.obs;
  final isTermsAccepted = false.obs;

  // UI state
  final RxBool isPasswordVisible = false.obs;

  final isSubmitting = false.obs;

  // Selected university
  final RxString selectedUniversity = ''.obs;

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

  Future<void> submit() async {
    if (!validateAll()) {
      if (!isTermsAccepted.value) {
        Get.snackbar('Terms Required', 'Please accept the terms to continue',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100],
            colorText: Colors.red[900]);
      }
      return;
    }

    isSubmitting.value = true;
    try {
      // Create Firebase Auth user
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Update display name
      await credential.user?.updateDisplayName(nameController.text.trim());

      // Parse name into first and last name
      final nameParts = nameController.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';

      // Create Firestore interpreter profile
      final interpreterService = Get.find<InterpreterUserFirestoreService>();
      await interpreterService.getOrCreateByAuthUid(
        authUid: credential.user!.uid,
        firstName: firstName,
        lastName: lastName,
        email: emailController.text.trim(),
        university: selectedUniversity.value,
      );

      // Store session in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('interpreter_logged_in', true);
      await prefs.setString('interpreter_email', emailController.text.trim());
      await prefs.setString('interpreter_name', nameController.text.trim());
      await prefs.setString('university', selectedUniversity.value);

      Get.snackbar('Success', 'Account created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900]);

      // Navigate directly to interpreter home
      Get.offAllNamed(Routes.INTERPRETER_HOME);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      switch (e.code) {
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
      Get.snackbar('Error', errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // List of universities in Ghana
  final List<String> universities = [
    'Takoradi Technical University (TTU)',
    'University of Education, Winneba (UEW)',
    'Kwame Nkrumah University of Science and Technology (KNUST)',
    'University of Ghana, Legon',
    'Other Ghana University',
  ];

  void selectUniversity(String university) {
    selectedUniversity.value = university;
    validateUniversity();
  }
}
