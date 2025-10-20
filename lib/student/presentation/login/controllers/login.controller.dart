import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/infrastructure/navigation/routes.dart';
import 'package:sign_language_app/infrastructure/dal/services/student_user.firestore.service.dart';
import 'package:sign_language_app/student/presentation/shared/controllers/student_user.controller.dart';

import '../../shared/controllers/country.controller.dart';

class LoginController extends GetxController {
  // Firebase removed

  // Controllers to read the text values
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Add this to your LoginController class
  final RxBool isPasswordVisible = false.obs;

  // Remember me state
  final RxBool isRememberMe = false.obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isGoogleSignInLoading = false.obs;

  // Get the shared country controller
  CountryController get countryController => Get.find<CountryController>();

  // Flag loading state (mirrors signup controller behavior)
  final RxBool isLoadingFlag = false.obs;
  final RxString countryFlagUrl = ''.obs;

  Future<void> fetchCountryFlag() async {
    try {
      isLoadingFlag.value = true;
      await countryController.fetchCountryFlag();
      if (countryController.countryFlag.value != null) {
        countryFlagUrl.value = countryController.countryFlag.value!.png;
      } else {
        countryFlagUrl.value = 'https://flagcdn.com/w40/gh.png';
      }
      // Log flag URL
      // ignore: avoid_print
      print('Login flag URL => ${countryFlagUrl.value}');
    } catch (e) {
      countryFlagUrl.value = 'https://flagcdn.com/w40/gh.png';
      // ignore: avoid_print
      print('Flag fetch error (login): $e');
    } finally {
      isLoadingFlag.value = false;
    }
  }

  // Add this method to toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Reactive validation states
  final isEmailValid = true.obs;
  final isPasswordValid = true.obs;

  // Validation logic
  void validateEmail() {
    final value = emailController.text.trim();
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.gh$');
    isEmailValid.value = emailRegex.hasMatch(value);
  }

  void validatePassword() {
    isPasswordValid.value = passwordController.text.trim().isNotEmpty;
  }

  // Validate all fields at once (e.g., on form submit)
  bool validateAll() {
    validateEmail();
    validatePassword();
    return isEmailValid.value && isPasswordValid.value;
  }

  Future<void> sendPasswordReset() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar('Email Required', 'Enter your university email',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Get.snackbar('Email Sent', 'Check your inbox to reset your password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900]);
    } on FirebaseAuthException catch (e) {
      String msg = 'Failed to send reset email';
      if (e.code == 'user-not-found') msg = 'No account found with this email';
      if (e.code == 'invalid-email') msg = 'Invalid email format';
      Get.snackbar('Error', msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Email/Password Authentication
  Future<void> login() async {
    if (!validateAll()) {
      if (emailController.text.trim().isEmpty) {
        isEmailValid.value = false;
        Get.snackbar('Email Required', 'Enter your university email',
            snackPosition: SnackPosition.BOTTOM);
      }
      if (passwordController.text.trim().isEmpty) {
        isPasswordValid.value = false;
        Get.snackbar('Password Required', 'Enter your password',
            snackPosition: SnackPosition.BOTTOM);
      }
      return;
    }

    isLoading.value = true;
    try {
      // Sign in with email and password
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Load complete user profile from Firestore
      final studentService = Get.find<StudentUserFirestoreService>();
      final userProfile =
          await studentService.findByAuthUid(credential.user!.uid);

      // Save user data to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userEmail', emailController.text.trim());
      await prefs.setString('userName',
          userProfile?.displayName ?? credential.user?.displayName ?? 'User');
      await prefs.setBool('student_logged_in', true);

      if (userProfile != null) {
        await prefs.setString('university', userProfile.university ?? '');

        // Update StudentUserController if registered
        if (Get.isRegistered<StudentUserController>()) {
          Get.find<StudentUserController>().current.value = userProfile;
        }
      }

      // Save remember me preference (persist email only)
      if (isRememberMe.value) {
        await prefs.setString('remembered_email', emailController.text.trim());
      } else {
        await prefs.remove('remembered_email');
      }

      Get.snackbar('Success', 'Login successful!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900]);

      // Navigate to home screen
      Get.offAllNamed(Routes.STUDENT_HOME);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';
      if (e.code == 'user-not-found') {
        errorMessage = 'No account found with this email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This account has been disabled';
      }

      Get.snackbar('Login Failed', errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
    } catch (e) {
      Get.snackbar('Error', 'Login failed: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    try {
      // Prefill remembered email
      final prefs = await SharedPreferences.getInstance();
      final rememberedEmail = prefs.getString('remembered_email');
      if (rememberedEmail != null && rememberedEmail.isNotEmpty) {
        emailController.text = rememberedEmail;
        isRememberMe.value = true;
      }

      // Navigate if already signed in
      if (FirebaseAuth.instance.currentUser != null) {
        Get.offAllNamed(Routes.STUDENT_HOME);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error checking auth status: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
    fetchCountryFlag();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
