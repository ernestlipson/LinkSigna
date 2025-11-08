import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/navigation/routes.dart';
import '../../../shared/components/signup.screen.dart';
import 'controllers/signup.int.controller.dart';
import 'package:sign_language_app/infrastructure/utils/app_strings.dart';

class InterpreterSignupScreen extends GetView<InterpreterSignupController> {
  const InterpreterSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<InterpreterSignupController>()) {
      Get.put(InterpreterSignupController());
    }

    final RxString selectedType = 'interpreter'.obs;

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
      isSubmitting: controller.isSubmitting,
      selectedUniversity: controller.selectedUniversity,
      universities: controller.universities,
      onUniversitySelected: controller.selectUniversity,
      onNameChanged: (_) => controller.validateName(),
      onEmailChanged: (_) => controller.validateEmail(),
      onPasswordChanged: (_) => controller.validatePassword(),
      onSubmit: () => controller.submit(),
      onTogglePasswordVisibility: () => controller.togglePasswordVisibility(),
      loginRoute: Routes.INTERPRETER_SIGNIN,
      showUserTypeSelector: true,
      selectedUserType: selectedType,
      onUserTypeChanged: (value) {
        selectedType.value = value;
        if (value == 'student') {
          Get.offNamed(Routes.STUDENT_SIGNUP);
        }
      },
      emailErrorText: AppStrings.emailValidationError,
      passwordErrorText: AppStrings.passwordValidationError,
      emailHint: AppStrings.emailHint,
    );
  }
}
