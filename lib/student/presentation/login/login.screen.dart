import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/navigation/routes.dart';
import '../../../shared/components/signin.screen.dart';
import 'controllers/login.controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedSignInScreen(
      emailController: controller.emailController,
      passwordController: controller.passwordController,
      isEmailValid: controller.isEmailValid,
      isPasswordValid: controller.isPasswordValid,
      isPasswordVisible: controller.isPasswordVisible,
      isRememberMe: controller.isRememberMe,
      isSubmitting: controller.isLoading,
      onSubmit: () => controller.login(),
      onTogglePasswordVisibility: () => controller.togglePasswordVisibility(),
      onForgotPassword: () => controller.sendPasswordReset(),
      onEmailChanged: () => controller.validateEmail(),
      onPasswordChanged: () => controller.validatePassword(),
      signUpRoute: Routes.STUDENT_SIGNUP,
      showPasswordField: true,
    );
  }
}
