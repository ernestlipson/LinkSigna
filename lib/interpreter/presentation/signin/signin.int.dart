import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/navigation/routes.dart';
import '../../../shared/components/signin.screen.dart';
import 'controllers/signin.controller.dart';

class InterpreterSignInScreen extends StatelessWidget {
  const InterpreterSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InterpreterSigninController>();

    return SharedSignInScreen(
      emailController: controller.emailController,
      passwordController: controller.passwordController,
      isEmailValid: controller.isEmailValid,
      isPasswordValid: controller.isPasswordValid,
      isPasswordVisible: controller.isPasswordVisible,
      isRememberMe: controller.isRememberMe,
      isSubmitting: controller.isSubmitting,
      onSubmit: () => controller.login(),
      onTogglePasswordVisibility: () => controller.togglePasswordVisibility(),
      onForgotPassword: () => controller.sendPasswordReset(),
      onEmailChanged: () => controller.validateEmail(),
      onPasswordChanged: () => controller.validatePassword(),
      signUpRoute: Routes.INTERPRETER_SIGNUP,
      loadingButtonText: 'Signing In...',
      showPasswordField: true,
    );
  }
}
