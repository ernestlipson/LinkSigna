import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../infrastructure/navigation/routes.dart';
import '../../../../infrastructure/dal/services/student_user.firestore.service.dart';
import '../../../../shared/mixins/country_flag_loader.mixin.dart';
import '../../../../shared/mixins/signup.mixin.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';

class SignupController extends GetxController
    with CountryFlagLoader, SignupMixin {
  final phoneController = TextEditingController();
  final universityController = TextEditingController();

  final RxString selectedUserType = 'student'.obs;
  final RxBool isPhoneOtpLoading = false.obs;
  final RxBool isGoogleSignInLoading = false.obs;
  final RxString otpUserId = ''.obs;
  final isPhoneValid = true.obs;

  void validatePhone() {
    final value = phoneController.text.trim();
    final phoneRegex =
        RegExp(r'^(\+?233)?[0-9]{9}$|^(\+?233)?[0-9]{10}$|^[0-9]{10,15}$');
    isPhoneValid.value = phoneRegex.hasMatch(value);
  }

  @override
  void selectUniversity(String university) {
    super.selectUniversity(university);
    universityController.text = university;
  }

  Future<void> signUp() async {
    if (!validateAll()) {
      if (!isTermsAccepted.value) {
        showTermsRequiredError();
      }
      return;
    }

    isSubmitting.value = true;
    isPhoneOtpLoading.value = true;
    try {
      // Create Firebase Auth user with email/password
      final credential = await createFirebaseAuthUser();

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
      showFirebaseAuthError(e.code);
    } catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Signup failed: ${e.toString()}',
      );
    } finally {
      isSubmitting.value = false;
      isPhoneOtpLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadCountryFlag();
  }

  @override
  void onClose() {
    phoneController.dispose();
    universityController.dispose();
    disposeControllers();
    super.onClose();
  }
}
