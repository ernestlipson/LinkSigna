import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/navigation/routes.dart';
import '../../../shared/components/signup.screen.dart';
import 'controllers/signup.controller.dart';

class StudentSignupScreen extends GetView<SignupController> {
  const StudentSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedSignUpScreen(
      nameController: controller.nameController,
      emailController: controller.emailController,
      passwordController: controller.passwordController,
      isNameValid: controller.isNameValid,
      isEmailValid: controller.isEmailValid,
      isPasswordValid: controller.isPasswordValid,
      isUniversityValid: controller.isUniversityValid,
      isTermsAccepted: controller.isTermsAccepted,
      isPasswordVisible: controller.isPasswordVisible,
      isSubmitting: controller.isPhoneOtpLoading,
      selectedUniversity: controller.selectedUniversity,
      universities: controller.universities,
      onUniversitySelected: controller.selectUniversity,
      onNameChanged: (_) => controller.validateName(),
      onEmailChanged: (_) => controller.validateEmail(),
      onPasswordChanged: (_) => controller.validatePassword(),
      onSubmit: () => controller.signUp(),
      onTogglePasswordVisibility: () => controller.togglePasswordVisibility(),
      loginRoute: Routes.STUDENT_LOGIN,
      showUserTypeSelector: true,
      selectedUserType: controller.selectedUserType,
      onUserTypeChanged: (value) {
        controller.selectedUserType.value = value;
        if (value == 'interpreter') {
          Get.offAllNamed(Routes.INTERPRETER_SIGNUP);
        }
      },
    );
  }
}
